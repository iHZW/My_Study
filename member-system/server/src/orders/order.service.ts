import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { DataSource, EntityManager, Repository } from 'typeorm';
import { paginate, Paginated } from '../common/pagination.dto';
import { CouponType, MemberCoupon, MemberCouponStatus } from '../database/entities/coupon.entity';
import { Level } from '../database/entities/level.entity';
import { Member, MemberStatus } from '../database/entities/member.entity';
import { Order, OrderType, PayMethod } from '../database/entities/order.entity';
import { PointChangeType, PointRecord } from '../database/entities/point-record.entity';
import { CreateOrderDto, OrderQueryDto } from './dto/order.dto';

/** 保留两位小数 */
function round2(value: number): number {
  return Number(value.toFixed(2));
}

/** 积分抵扣比例：100 积分抵 1 元 */
const POINTS_PER_YUAN = 100;

@Injectable()
export class OrderService {
  constructor(
    @InjectRepository(Order) private readonly orderRepo: Repository<Order>,
    private readonly dataSource: DataSource,
  ) {}

  /**
   * 录入消费订单（事务）：
   * 等级折扣 → 优惠券 → 积分抵扣 → 计算实付 → 储值扣款 → 赠送积分 → 更新会员统计 → 自动升级
   */
  async create(dto: CreateOrderDto) {
    return this.dataSource.transaction(async (manager) => {
      const member = await manager.findOne(Member, { where: { id: dto.memberId } });
      if (!member) {
        throw new NotFoundException('会员不存在或已被删除');
      }
      if (member.status !== MemberStatus.NORMAL) {
        throw new BadRequestException('该会员已被禁用，无法录入消费');
      }

      // 1. 原价：优先按明细合计
      let totalAmount = dto.totalAmount ?? 0;
      if (dto.items?.length) {
        totalAmount = round2(dto.items.reduce((sum, it) => sum + it.price * it.quantity, 0));
      }
      if (!totalAmount || totalAmount <= 0) {
        throw new BadRequestException('订单金额必须大于 0（填写 totalAmount 或 items 明细）');
      }

      // 2. 等级折扣
      const discountRate = Number(member.level?.discount ?? 1);
      const levelDiscountAmount = round2(totalAmount * (1 - discountRate));
      let afterDiscount = round2(totalAmount - levelDiscountAmount);

      // 3. 优惠券核销
      let coupon: MemberCoupon | null = null;
      let couponAmount = 0;
      if (dto.memberCouponId) {
        coupon = await manager.findOne(MemberCoupon, {
          where: { id: dto.memberCouponId },
          relations: { template: true },
        });
        if (!coupon) {
          throw new BadRequestException('优惠券不存在');
        }
        if (coupon.memberId !== member.id) {
          throw new BadRequestException('该优惠券不属于此会员');
        }
        if (coupon.status !== MemberCouponStatus.UNUSED) {
          throw new BadRequestException('该优惠券已使用或已过期');
        }
        if (coupon.expireAt && new Date(coupon.expireAt).getTime() < Date.now()) {
          coupon.status = MemberCouponStatus.EXPIRED;
          await manager.save(coupon);
          throw new BadRequestException('该优惠券已过期');
        }
        const threshold = Number(coupon.template?.threshold ?? 0);
        if (afterDiscount < threshold) {
          throw new BadRequestException(`订单金额需满 ${threshold} 元才能使用该券`);
        }
        const value = Number(coupon.template?.value ?? 0);
        switch (coupon.template?.type) {
          case CouponType.FULL_REDUCTION:
            couponAmount = Math.min(value, afterDiscount);
            break;
          case CouponType.DISCOUNT:
            couponAmount = round2(afterDiscount * (1 - value));
            break;
          case CouponType.CASH:
            couponAmount = Math.min(value, afterDiscount);
            break;
          default:
            couponAmount = 0;
        }
        couponAmount = round2(couponAmount);
        afterDiscount = round2(afterDiscount - couponAmount);
      }
      // discountAmount 字段 = 等级折扣 + 优惠券
      const discountAmount = round2(levelDiscountAmount + couponAmount);

      // 4. 积分抵扣（不能超过会员积分余额，也不能超过应付金额）
      let pointsUsed = Math.max(0, Math.floor(dto.pointsUsed ?? 0));
      if (pointsUsed > member.points) {
        throw new BadRequestException(`积分不足：该会员当前仅有 ${member.points} 积分`);
      }
      let pointsDeductionAmount = round2(pointsUsed / POINTS_PER_YUAN);
      if (pointsDeductionAmount > afterDiscount) {
        pointsDeductionAmount = afterDiscount;
        pointsUsed = Math.ceil(afterDiscount * POINTS_PER_YUAN);
      }
      const payAmount = round2(afterDiscount - pointsDeductionAmount);

      // 5. 储值卡支付需校验并扣减余额
      const payMethod = (dto.payMethod as PayMethod) || PayMethod.WECHAT;
      if (payMethod === PayMethod.BALANCE) {
        if (member.balance < payAmount) {
          throw new BadRequestException(`会员储值余额不足：当前 ${member.balance} 元，本单需支付 ${payAmount} 元`);
        }
        member.balance = round2(member.balance - payAmount);
      }

      // 6. 消费赠送积分
      const pointsRate = Number(member.level?.pointsRate ?? 1);
      const pointsEarned = Math.floor(payAmount * pointsRate);

      const consumeAt = dto.consumeAt ? new Date(dto.consumeAt) : new Date();
      if (isNaN(consumeAt.getTime())) {
        throw new BadRequestException('消费时间格式不正确');
      }

      // 7. 保存订单
      const order = manager.create(Order, {
        orderNo: await this.generateOrderNo(manager),
        memberId: member.id,
        type: (dto.type as OrderType) || OrderType.DINE_IN,
        totalAmount,
        discountAmount,
        pointsDeductionAmount,
        pointsUsed,
        payAmount,
        pointsEarned,
        memberCouponId: coupon?.id ?? null,
        payMethod,
        storeName: dto.storeName || member.storeName || null,
        items: dto.items ? JSON.stringify(dto.items) : null,
        remark: dto.remark,
        consumeAt,
      });
      await manager.save(order);

      // 8. 核销优惠券
      if (coupon) {
        coupon.status = MemberCouponStatus.USED;
        coupon.usedAt = new Date();
        coupon.usedOrderNo = order.orderNo;
        await manager.save(coupon);
      }

      // 9. 积分流水（抵扣 + 赠送）
      let pointsAfter = member.points - pointsUsed;
      if (pointsUsed > 0) {
        await manager.save(
          manager.create(PointRecord, {
            memberId: member.id,
            changeType: PointChangeType.SPEND,
            points: -pointsUsed,
            balanceAfter: pointsAfter,
            source: '积分抵扣',
            orderNo: order.orderNo,
            remark: `本单抵扣 ${pointsDeductionAmount} 元`,
          }),
        );
      }
      pointsAfter += pointsEarned;
      if (pointsEarned > 0) {
        await manager.save(
          manager.create(PointRecord, {
            memberId: member.id,
            changeType: PointChangeType.EARN,
            points: pointsEarned,
            balanceAfter: pointsAfter,
            source: '消费赠送',
            orderNo: order.orderNo,
            remark: `实付 ${payAmount} 元 × ${pointsRate} 倍率`,
          }),
        );
      }

      // 10. 更新会员统计
      member.points = pointsAfter;
      member.totalConsumption = round2(member.totalConsumption + payAmount);
      member.consumptionCount += 1;
      if (!member.lastConsumeAt || consumeAt > new Date(member.lastConsumeAt)) {
        member.lastConsumeAt = consumeAt;
      }

      // 11. 按累计消费自动升级（只升不降）
      const levels = await manager.find(Level, { order: { upgradeAmount: 'DESC' } });
      const target = levels.find((l) => member.totalConsumption >= Number(l.upgradeAmount));
      const currentUpgradeAmount = Number(member.level?.upgradeAmount ?? -1);
      if (target && Number(target.upgradeAmount) > currentUpgradeAmount) {
        // member.level 是 eager 关系，save 时以关系对象为准，必须同步改关系对象
        member.level = target;
        member.levelId = target.id;
      }
      await manager.save(member);

      return {
        ...order,
        member: { id: member.id, name: member.name, levelId: member.levelId, points: member.points, balance: member.balance },
      };
    });
  }

  /** 分页查询订单 */
  async findAll(query: OrderQueryDto): Promise<Paginated<Order>> {
    const { page = 1, size = 20, memberId, type, keyword, startDate, endDate } = query;
    const qb = this.orderRepo
      .createQueryBuilder('o')
      .leftJoinAndSelect('o.member', 'member')
      .orderBy('o.consumeAt', 'DESC')
      .addOrderBy('o.id', 'DESC');

    if (memberId !== undefined) {
      qb.andWhere('o.memberId = :memberId', { memberId });
    }
    if (type !== undefined) {
      qb.andWhere('o.type = :type', { type });
    }
    if (keyword) {
      qb.andWhere('(o.orderNo LIKE :kw OR member.name LIKE :kw OR member.phone LIKE :kw)', { kw: `%${keyword}%` });
    }
    if (startDate) {
      qb.andWhere('date(o.consumeAt) >= :startDate', { startDate });
    }
    if (endDate) {
      qb.andWhere('date(o.consumeAt) <= :endDate', { endDate });
    }

    qb.skip((page - 1) * size).take(size);
    const [list, total] = await qb.getManyAndCount();
    // items 是 JSON 字符串，返回前解析成数组方便前端展示
    const parsed = list.map((o) => ({ ...o, items: this.parseItems(o.items) }));
    return paginate(parsed as unknown as Order[], total, page, size);
  }

  /** 订单详情 */
  async findOne(id: number) {
    const order = await this.orderRepo.findOne({
      where: { id },
      relations: { member: { level: true } },
    });
    if (!order) {
      throw new NotFoundException('订单不存在');
    }
    return { ...order, items: this.parseItems(order.items) };
  }

  private parseItems(items: string | null): unknown[] {
    if (!items) return [];
    try {
      return JSON.parse(items);
    } catch {
      return [];
    }
  }

  /** 生成订单号：SO + YYYYMMDD + 5 位当日序号 */
  private async generateOrderNo(manager: EntityManager): Promise<string> {
    const now = new Date();
    const ymd = `${now.getFullYear()}${String(now.getMonth() + 1).padStart(2, '0')}${String(now.getDate()).padStart(2, '0')}`;
    const prefix = `SO${ymd}`;
    const last = await manager
      .createQueryBuilder(Order, 'o')
      .where('o.orderNo LIKE :prefix', { prefix: `${prefix}%` })
      .orderBy('o.orderNo', 'DESC')
      .getOne();
    const seq = last ? parseInt(last.orderNo.slice(-5), 10) + 1 : 1;
    return `${prefix}${String(seq).padStart(5, '0')}`;
  }
}
