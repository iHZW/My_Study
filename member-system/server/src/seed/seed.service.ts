import { Injectable, Logger, OnApplicationBootstrap } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import * as bcrypt from 'bcryptjs';
import { Repository } from 'typeorm';
import { CouponTemplate, MemberCoupon, MemberCouponStatus } from '../database/entities/coupon.entity';
import { Level } from '../database/entities/level.entity';
import { Gender, Member, MemberStatus } from '../database/entities/member.entity';
import { Order, OrderType, PayMethod } from '../database/entities/order.entity';
import { PointChangeType, PointRecord } from '../database/entities/point-record.entity';
import { Tag } from '../database/entities/tag.entity';
import { UserRole, User } from '../database/entities/user.entity';

/** 固定种子的伪随机数生成器，保证每次初始化的演示数据一致，便于排查问题 */
class Random {
  private seed: number;
  constructor(seed = 20261029) {
    this.seed = seed;
  }
  next(): number {
    this.seed = (this.seed * 1103515245 + 12345) % 2147483648;
    return this.seed / 2147483648;
  }
  int(min: number, max: number): number {
    return Math.floor(this.next() * (max - min + 1)) + min;
  }
  pick<T>(arr: T[]): T {
    return arr[this.int(0, arr.length - 1)];
  }
  /** 有 probability 概率返回 true */
  chance(probability: number): boolean {
    return this.next() < probability;
  }
}

const SURNAMES = ['张', '王', '李', '赵', '刘', '陈', '杨', '黄', '周', '吴', '徐', '孙', '马', '朱', '胡', '林', '郭', '何', '高', '罗'];
const GIVEN_NAMES = ['伟', '芳', '娜', '敏', '静', '磊', '洋', '艳', '勇', '军', '杰', '娟', '涛', '明', '超', '秀英', '霞', '平', '刚', '桂英', '浩然', '梓萱', '一鸣', '思远'];
const STORES = ['南山科技园店', '福田中心店', '宝安海雅店', '龙华壹方城店'];
const SOURCES = ['门店登记', '小程序注册', '批量导入', '活动扫码'];
const DISHES = ['招牌牛肉面', '黑椒牛排', '蒜蓉虾', '清蒸鲈鱼', '水煮鱼片', '干锅花菜', '杨枝甘露', '芝士焗饭', '手冲咖啡', '鲜果茶', '烤鸡翅', '菌菇汤'];

@Injectable()
export class SeedService implements OnApplicationBootstrap {
  private readonly logger = new Logger('Seed');

  constructor(
    @InjectRepository(User) private readonly userRepo: Repository<User>,
    @InjectRepository(Level) private readonly levelRepo: Repository<Level>,
    @InjectRepository(Tag) private readonly tagRepo: Repository<Tag>,
    @InjectRepository(Member) private readonly memberRepo: Repository<Member>,
    @InjectRepository(Order) private readonly orderRepo: Repository<Order>,
    @InjectRepository(PointRecord) private readonly pointRepo: Repository<PointRecord>,
    @InjectRepository(CouponTemplate) private readonly couponRepo: Repository<CouponTemplate>,
    @InjectRepository(MemberCoupon) private readonly memberCouponRepo: Repository<MemberCoupon>,
  ) {}

  async onApplicationBootstrap() {
    await this.seedUsers();
    await this.seedLevels();
    const tags = await this.seedTags();
    await this.seedCoupons();
    const hasMembers = (await this.memberRepo.count()) > 0;
    if (!hasMembers) {
      await this.seedDemoBusinessData(tags);
    }
  }

  /** 初始化后台账号：admin / admin123（管理员）、staff / staff123（门店员工） */
  private async seedUsers() {
    const count = await this.userRepo.count();
    if (count > 0) return;

    const users = this.userRepo.create([
      {
        username: 'admin',
        password: await bcrypt.hash('admin123', 10),
        realName: '系统管理员',
        role: UserRole.ADMIN,
        status: 1,
      },
      {
        username: 'staff',
        password: await bcrypt.hash('staff123', 10),
        realName: '门店员工',
        role: UserRole.STAFF,
        status: 1,
      },
    ]);
    await this.userRepo.save(users);
    this.logger.log('已初始化默认账号：admin/admin123、staff/staff123（请尽快修改密码）');
  }

  /** 初始化会员等级体系 */
  private async seedLevels() {
    const count = await this.levelRepo.count();
    if (count > 0) return;

    const levels = this.levelRepo.create([
      { name: '普通会员', code: 'V1', upgradeAmount: 0, discount: 1, pointsRate: 1, color: '#909399', sortOrder: 1, remark: '注册即为普通会员' },
      { name: '银卡会员', code: 'V2', upgradeAmount: 1000, discount: 0.98, pointsRate: 1.2, color: '#409EFF', sortOrder: 2, remark: '累计消费满 1000 元' },
      { name: '金卡会员', code: 'V3', upgradeAmount: 5000, discount: 0.95, pointsRate: 1.5, color: '#E6A23C', sortOrder: 3, remark: '累计消费满 5000 元' },
      { name: '钻石会员', code: 'V4', upgradeAmount: 20000, discount: 0.9, pointsRate: 2, color: '#F56C6C', sortOrder: 4, remark: '累计消费满 20000 元' },
    ]);
    await this.levelRepo.save(levels);
    this.logger.log('已初始化 4 个会员等级');
  }

  /** 初始化会员标签 */
  private async seedTags(): Promise<Tag[]> {
    let tags = await this.tagRepo.find({ order: { sortOrder: 'ASC' } });
    if (tags.length > 0) return tags;

    tags = this.tagRepo.create([
      { name: '高频消费', groupName: '消费特征', color: '#F56C6C', sortOrder: 1 },
      { name: '价格敏感', groupName: '消费特征', color: '#E6A23C', sortOrder: 2 },
      { name: '品质导向', groupName: '消费特征', color: '#409EFF', sortOrder: 3 },
      { name: '堂食偏好', groupName: '渠道来源', color: '#67C23A', sortOrder: 4 },
      { name: '外卖偏好', groupName: '渠道来源', color: '#13C2C2', sortOrder: 5 },
      { name: '新客', groupName: '生命周期', color: '#9254DE', sortOrder: 6 },
      { name: '沉睡客户', groupName: '生命周期', color: '#8C8C8C', sortOrder: 7 },
      { name: '生日当月', groupName: '生命周期', color: '#FF85C0', sortOrder: 8 },
    ]);
    await this.tagRepo.save(tags);
    this.logger.log('已初始化 8 个会员标签');
    return this.tagRepo.find({ order: { sortOrder: 'ASC' } });
  }

  /** 初始化优惠券模板 */
  private async seedCoupons() {
    const count = await this.couponRepo.count();
    if (count > 0) return;

    const coupons = this.couponRepo.create([
      { name: '新客立减 20 元', type: 1, threshold: 100, value: 20, totalQuantity: 1000, issuedQuantity: 0, validDays: 30, status: 1, remark: '满 100 元可用' },
      { name: '会员 88 折券', type: 2, threshold: 200, value: 0.88, totalQuantity: 500, issuedQuantity: 0, validDays: 15, status: 1, remark: '满 200 元享 88 折' },
      { name: '50 元代金券', type: 3, threshold: 0, value: 50, totalQuantity: 200, issuedQuantity: 0, validDays: 7, status: 1, remark: '无门槛抵扣' },
    ]);
    await this.couponRepo.save(coupons);
    this.logger.log('已初始化 3 个优惠券模板');
  }

  /**
   * 生成演示业务数据：会员档案 + 消费订单 + 积分流水 + 优惠券发放
   * 数据分布在最近 120 天内，保证看板图表有内容可看
   */
  private async seedDemoBusinessData(tags: Tag[]) {
    const rand = new Random();
    const levels = await this.levelRepo.find({ order: { sortOrder: 'ASC' } });
    const coupons = await this.couponRepo.find();
    const now = Date.now();
    const DAY = 24 * 3600 * 1000;

    const members: Member[] = [];
    const orders: Order[] = [];
    const pointRecords: PointRecord[] = [];
    const memberCoupons: MemberCoupon[] = [];

    for (let i = 0; i < 48; i++) {
      const createdAt = new Date(now - rand.int(0, 120) * DAY);
      const name = rand.pick(SURNAMES) + rand.pick(GIVEN_NAMES);
      const phone = `1${rand.pick(['3', '5', '7', '8', '9'])}${String(rand.int(100000000, 999999999))}`;
      const storeName = rand.pick(STORES);

      const member = this.memberRepo.create({
        memberNo: `M${this.formatDate(createdAt)}${String(i + 1).padStart(4, '0')}`,
        name,
        phone,
        gender: rand.chance(0.5) ? Gender.MALE : Gender.FEMALE,
        birthday: `${rand.int(1970, 2005)}-${String(rand.int(1, 12)).padStart(2, '0')}-${String(rand.int(1, 28)).padStart(2, '0')}`,
        status: rand.chance(0.95) ? MemberStatus.NORMAL : MemberStatus.DISABLED,
        source: rand.pick(SOURCES),
        storeName,
        remark: rand.chance(0.3) ? '口味偏清淡，忌辛辣' : null,
        tags: rand.chance(0.7) ? [rand.pick(tags), ...(rand.chance(0.4) ? [rand.pick(tags)] : [])] : [],
        createdAt,
      } as Partial<Member>);
      // 去重标签
      member.tags = Array.from(new Map((member.tags || []).map((t) => [t.id, t])).values());

      // 生成该会员的消费订单
      const orderCount = rand.int(0, 9);
      let totalConsumption = 0;
      let points = 0;
      let lastConsumeAt: Date | null = null;

      for (let j = 0; j < orderCount; j++) {
        const consumeAt = new Date(Math.min(now, createdAt.getTime() + rand.int(0, 120) * DAY));
        if (consumeAt > new Date(now)) continue;

        const itemCount = rand.int(1, 4);
        const items = Array.from({ length: itemCount }, () => {
          const price = rand.int(18, 168);
          return { name: rand.pick(DISHES), quantity: rand.int(1, 3), price };
        });
        const totalAmount = Number(items.reduce((s, it) => s + it.price * it.quantity, 0).toFixed(2));
        const level = this.matchLevel(levels, totalConsumption);
        const discountAmount = Number((totalAmount * (1 - level.discount)).toFixed(2));
        const usePoints = rand.chance(0.3) && points >= 100;
        const pointsUsed = usePoints ? Math.min(points, 100) : 0;
        const pointsDeductionAmount = Number((pointsUsed / 100).toFixed(2));
        const payAmount = Number(Math.max(0, totalAmount - discountAmount - pointsDeductionAmount).toFixed(2));
        const pointsEarned = Math.floor(payAmount * level.pointsRate);

        const order = this.orderRepo.create({
          orderNo: `SO${this.formatDate(consumeAt)}${String(orders.length + 1).padStart(5, '0')}`,
          memberId: 0, // 会员保存后回填
          type: rand.chance(0.7) ? OrderType.DINE_IN : rand.chance(0.6) ? OrderType.TAKEAWAY : OrderType.RETAIL,
          totalAmount,
          discountAmount,
          pointsDeductionAmount,
          pointsUsed,
          payAmount,
          pointsEarned,
          payMethod: rand.pick([PayMethod.WECHAT, PayMethod.ALIPAY, PayMethod.CASH, PayMethod.BALANCE]),
          storeName,
          items: JSON.stringify(items),
          consumeAt,
          createdAt: consumeAt,
        });
        orders.push(order);

        totalConsumption = Number((totalConsumption + payAmount).toFixed(2));
        points += pointsEarned - pointsUsed;
        if (!lastConsumeAt || consumeAt > lastConsumeAt) lastConsumeAt = consumeAt;

        pointRecords.push(
          this.pointRepo.create({
            memberId: 0,
            changeType: PointChangeType.EARN,
            points: pointsEarned,
            balanceAfter: 0,
            source: '消费赠送',
            orderNo: order.orderNo,
            createdAt: consumeAt,
          }),
        );
        if (pointsUsed > 0) {
          pointRecords.push(
            this.pointRepo.create({
              memberId: 0,
              changeType: PointChangeType.SPEND,
              points: -pointsUsed,
              balanceAfter: 0,
              source: '积分抵扣',
              orderNo: order.orderNo,
              createdAt: consumeAt,
            }),
          );
        }
      }

      member.points = Math.max(0, points);
      member.totalConsumption = totalConsumption;
      member.consumptionCount = orderCount;
      member.lastConsumeAt = lastConsumeAt;
      member.level = this.matchLevel(levels, totalConsumption);
      member.levelId = member.level?.id ?? null;
      members.push(member);
    }

    const savedMembers = await this.memberRepo.save(members);
    this.logger.log(`已生成 ${savedMembers.length} 位演示会员`);

    // 用真实的会员 ID 回填订单与积分流水，并按会员分组保持顺序一致
    const memberIdByNo = new Map(members.map((m, idx) => [m.memberNo, savedMembers[idx].id]));
    let cursor = 0;
    for (const member of members) {
      const realId = memberIdByNo.get(member.memberNo);
      const myOrders = orders.slice(cursor, cursor + member.consumptionCount);
      cursor += member.consumptionCount;
      myOrders.forEach((o) => (o.memberId = realId));
    }
    const savedOrders = await this.orderRepo.save(orders);
    this.logger.log(`已生成 ${savedOrders.length} 笔演示消费订单`);

    // 积分流水按订单归属回填 memberId 与余额快照
    const orderMemberMap = new Map(savedOrders.map((o) => [o.orderNo, o.memberId]));
    const balanceMap = new Map<number, number>();
    const sortedRecords = pointRecords.sort((a, b) => a.createdAt.getTime() - b.createdAt.getTime());
    for (const record of sortedRecords) {
      const mid = orderMemberMap.get(record.orderNo);
      record.memberId = mid;
      const balance = (balanceMap.get(mid) ?? 0) + record.points;
      balanceMap.set(mid, balance);
      record.balanceAfter = balance;
    }
    await this.pointRepo.save(sortedRecords);
    this.logger.log(`已生成 ${sortedRecords.length} 条积分流水`);

    // 给部分会员发券，其中一部分标记为已核销
    for (const member of savedMembers) {
      if (!rand.chance(0.55)) continue;
      const template = rand.pick(coupons);
      const receiveAt = new Date(now - rand.int(0, 60) * DAY);
      const used = rand.chance(0.35);
      memberCoupons.push(
        this.memberCouponRepo.create({
          templateId: template.id,
          memberId: member.id,
          code: `C${template.id}${String(member.id).padStart(5, '0')}${rand.int(100, 999)}`,
          status: used ? MemberCouponStatus.USED : MemberCouponStatus.UNUSED,
          receiveAt,
          expireAt: new Date(receiveAt.getTime() + template.validDays * DAY),
          usedAt: used ? new Date(receiveAt.getTime() + rand.int(1, 10) * DAY) : null,
          usedOrderNo: used ? `SO${this.formatDate(receiveAt)}00001` : null,
        }),
      );
    }
    await this.memberCouponRepo.save(memberCoupons);
    this.logger.log(`已发放 ${memberCoupons.length} 张演示优惠券`);
  }

  /** 根据累计消费匹配应享等级 */
  private matchLevel(levels: Level[], totalConsumption: number): Level {
    const sorted = [...levels].sort((a, b) => Number(b.upgradeAmount) - Number(a.upgradeAmount));
    return sorted.find((l) => totalConsumption >= Number(l.upgradeAmount)) ?? sorted[sorted.length - 1];
  }

  private formatDate(date: Date): string {
    return `${date.getFullYear()}${String(date.getMonth() + 1).padStart(2, '0')}${String(date.getDate()).padStart(2, '0')}`;
  }
}
