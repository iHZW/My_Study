import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { paginate, Paginated } from '../common/pagination.dto';
import { CouponTemplate, MemberCoupon, MemberCouponStatus } from '../database/entities/coupon.entity';
import { Member } from '../database/entities/member.entity';
import {
  CreateCouponTemplateDto,
  IssueCouponDto,
  MemberCouponQueryDto,
  UpdateCouponTemplateDto,
} from './dto/coupon.dto';

const DAY = 24 * 3600 * 1000;

@Injectable()
export class CouponService {
  constructor(
    @InjectRepository(CouponTemplate) private readonly templateRepo: Repository<CouponTemplate>,
    @InjectRepository(MemberCoupon) private readonly memberCouponRepo: Repository<MemberCoupon>,
    @InjectRepository(Member) private readonly memberRepo: Repository<Member>,
  ) {}

  // ---------- 券模板 ----------

  /** 模板列表，附带已发放/已核销数量统计 */
  async findAllTemplates() {
    const templates = await this.templateRepo.find({ order: { id: 'DESC' } });
    const stats: { templateId: number; issued: string; used: string }[] = await this.memberCouponRepo.query(
      `SELECT templateId,
              COUNT(*) AS issued,
              SUM(CASE WHEN status = 1 THEN 1 ELSE 0 END) AS used
       FROM member_coupon
       GROUP BY templateId`,
    );
    const statMap = new Map(stats.map((s) => [Number(s.templateId), s]));
    return templates.map((t) => {
      const stat = statMap.get(t.id);
      return {
        ...t,
        issuedQuantity: stat ? Number(stat.issued) : 0,
        usedQuantity: stat ? Number(stat.used) : 0,
      };
    });
  }

  async createTemplate(dto: CreateCouponTemplateDto) {
    if (dto.type === 2 && (dto.value <= 0 || dto.value >= 1)) {
      throw new BadRequestException('折扣券的折扣率必须在 0 和 1 之间，如 0.88 表示 88 折');
    }
    const template = this.templateRepo.create(dto);
    return this.templateRepo.save(template);
  }

  async updateTemplate(id: number, dto: UpdateCouponTemplateDto) {
    const template = await this.templateRepo.findOne({ where: { id } });
    if (!template) {
      throw new NotFoundException('优惠券模板不存在');
    }
    Object.assign(template, dto);
    return this.templateRepo.save(template);
  }

  async removeTemplate(id: number) {
    const template = await this.templateRepo.findOne({ where: { id } });
    if (!template) {
      throw new NotFoundException('优惠券模板不存在');
    }
    const issued = await this.memberCouponRepo.count({ where: { templateId: id } });
    if (issued > 0) {
      throw new BadRequestException(`该券已发放 ${issued} 张，不能删除；可将其「停用」停止继续发放`);
    }
    await this.templateRepo.remove(template);
    return { id };
  }

  // ---------- 发券 / 持券 ----------

  /** 给指定会员批量发券 */
  async issue(dto: IssueCouponDto) {
    const template = await this.templateRepo.findOne({ where: { id: dto.templateId } });
    if (!template) {
      throw new NotFoundException('优惠券模板不存在');
    }
    if (template.status !== 1) {
      throw new BadRequestException('该券已停用，无法发放');
    }
    const members = await this.memberRepo.find({ where: { id: In(dto.memberIds) } });
    if (!members.length) {
      throw new NotFoundException('所选会员不存在');
    }
    const issued = await this.memberCouponRepo.count({ where: { templateId: template.id } });
    if (template.totalQuantity >= 0 && issued + members.length > template.totalQuantity) {
      throw new BadRequestException(
        `库存不足：总量 ${template.totalQuantity}，已发 ${issued}，本次需发 ${members.length}`,
      );
    }

    const now = Date.now();
    const coupons = members.map((m, index) =>
      this.memberCouponRepo.create({
        templateId: template.id,
        memberId: m.id,
        code: `C${template.id}${String(m.id).padStart(6, '0')}${String(now).slice(-4)}${index}`,
        status: MemberCouponStatus.UNUSED,
        receiveAt: new Date(now),
        expireAt: new Date(now + template.validDays * DAY),
      }),
    );
    const saved = await this.memberCouponRepo.save(coupons);
    return { issued: saved.length, expireAt: coupons[0].expireAt };
  }

  /** 会员持券分页列表 */
  async findMemberCoupons(query: MemberCouponQueryDto): Promise<Paginated<MemberCoupon>> {
    const { page = 1, size = 20, memberId, templateId, status } = query;
    const qb = this.memberCouponRepo
      .createQueryBuilder('c')
      .leftJoinAndSelect('c.template', 'template')
      .leftJoinAndSelect('c.member', 'member')
      .orderBy('c.id', 'DESC');

    if (memberId !== undefined) {
      qb.andWhere('c.memberId = :memberId', { memberId });
    }
    if (templateId !== undefined) {
      qb.andWhere('c.templateId = :templateId', { templateId });
    }
    if (status !== undefined) {
      qb.andWhere('c.status = :status', { status });
    }

    qb.skip((page - 1) * size).take(size);
    const [list, total] = await qb.getManyAndCount();
    return paginate(list, total, page, size);
  }
}
