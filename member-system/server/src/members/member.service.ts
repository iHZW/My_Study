import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { paginate, Paginated } from '../common/pagination.dto';
import { Level } from '../database/entities/level.entity';
import { Member } from '../database/entities/member.entity';
import { PointChangeType, PointRecord } from '../database/entities/point-record.entity';
import { Tag } from '../database/entities/tag.entity';
import {
  AdjustPointsDto,
  BatchTagDto,
  CreateMemberDto,
  MemberQueryDto,
  RechargeDto,
  UpdateMemberDto,
} from './dto/member.dto';

@Injectable()
export class MemberService {
  constructor(
    @InjectRepository(Member) private readonly memberRepo: Repository<Member>,
    @InjectRepository(Tag) private readonly tagRepo: Repository<Tag>,
    @InjectRepository(Level) private readonly levelRepo: Repository<Level>,
    @InjectRepository(PointRecord) private readonly pointRepo: Repository<PointRecord>,
  ) {}

  /** 分页查询会员列表 */
  async findAll(query: MemberQueryDto): Promise<Paginated<Member>> {
    const { page = 1, size = 20, keyword, levelId, tagId, status, startDate, endDate, sortField = 'createdAt', sortOrder = 'DESC' } = query;

    // 关联查询等级，否则列表无法展示会员等级名称
    const qb = this.memberRepo
      .createQueryBuilder('m')
      .leftJoinAndSelect('m.level', 'level');
    if (keyword) {
      qb.andWhere('(m.name LIKE :kw OR m.phone LIKE :kw OR m.memberNo LIKE :kw)', { kw: `%${keyword}%` });
    }
    if (levelId !== undefined) {
      qb.andWhere('m.levelId = :levelId', { levelId });
    }
    if (status !== undefined) {
      qb.andWhere('m.status = :status', { status });
    }
    if (startDate) {
      qb.andWhere('date(m.createdAt) >= :startDate', { startDate });
    }
    if (endDate) {
      qb.andWhere('date(m.createdAt) <= :endDate', { endDate });
    }
    if (tagId !== undefined) {
      qb.andWhere('m.id IN (SELECT r.memberId FROM member_tag_rel r WHERE r.tagId = :tagId)', { tagId });
    }

    qb.orderBy(`m.${sortField}`, sortOrder).addOrderBy('m.id', 'DESC');
    qb.skip((page - 1) * size).take(size);

    const [list, total] = await qb.getManyAndCount();
    return paginate(list, total, page, size);
  }

  /** 会员详情（含最近积分流水） */
  async findOne(id: number) {
    const member = await this.memberRepo.findOne({ where: { id } });
    if (!member) {
      throw new NotFoundException('会员不存在或已被删除');
    }
    const recentPoints = await this.pointRepo.find({
      where: { memberId: id },
      order: { id: 'DESC' },
      take: 20,
    });
    return { ...member, recentPoints };
  }

  async create(dto: CreateMemberDto) {
    const exists = await this.memberRepo.findOne({ where: { phone: dto.phone } });
    if (exists) {
      throw new BadRequestException(`手机号 ${dto.phone} 已注册（会员：${exists.name}），请勿重复添加`);
    }
    const { tagIds, levelId, ...rest } = dto;

    if (levelId) {
      const level = await this.levelRepo.findOne({ where: { id: levelId } });
      if (!level) {
        throw new BadRequestException('所选会员等级不存在');
      }
    }

    const member = this.memberRepo.create({
      ...rest,
      memberNo: await this.generateMemberNo(),
      levelId: levelId || null,
      source: rest.source || '门店登记',
    });
    if (tagIds?.length) {
      member.tags = await this.tagRepo.find({ where: { id: In(tagIds) } });
    }
    const saved = await this.memberRepo.save(member);

    // 初始积分若大于 0，补一条积分流水保证账目可追溯
    if (saved.points > 0) {
      await this.pointRepo.save(
        this.pointRepo.create({
          memberId: saved.id,
          changeType: PointChangeType.ADJUST,
          points: saved.points,
          balanceAfter: saved.points,
          source: '开户初始',
          remark: '新增会员时录入的初始积分',
        }),
      );
    }
    return saved;
  }

  async update(id: number, dto: UpdateMemberDto) {
    const member = await this.memberRepo.findOne({ where: { id } });
    if (!member) {
      throw new NotFoundException('会员不存在或已被删除');
    }
    const { tagIds, levelId, ...rest } = dto;

    if (rest.phone && rest.phone !== member.phone) {
      const exists = await this.memberRepo.findOne({ where: { phone: rest.phone } });
      if (exists) {
        throw new BadRequestException(`手机号 ${rest.phone} 已被会员「${exists.name}」使用`);
      }
    }
    if (levelId !== undefined) {
      if (levelId === null) {
        member.level = null;
        member.levelId = null;
      } else {
        const level = await this.levelRepo.findOne({ where: { id: levelId } });
        if (!level) {
          throw new BadRequestException('所选会员等级不存在');
        }
        // 实体同时映射了 level 关系（eager）与 levelId 裸列，save 时以关系对象为准，
        // 只改 levelId 会被旧的 member.level 覆盖回去，必须改关系对象
        member.level = level;
        member.levelId = level.id;
      }
    }
    Object.assign(member, rest);
    if (tagIds) {
      member.tags = tagIds.length ? await this.tagRepo.find({ where: { id: In(tagIds) } }) : [];
    }
    return this.memberRepo.save(member);
  }

  /** 软删除，保留历史消费数据 */
  async remove(id: number) {
    const member = await this.memberRepo.findOne({ where: { id } });
    if (!member) {
      throw new NotFoundException('会员不存在或已被删除');
    }
    await this.memberRepo.softRemove(member);
    return { id };
  }

  /** 手动调整积分（正加负减） */
  async adjustPoints(id: number, dto: AdjustPointsDto) {
    if (!dto.points || dto.points === 0) {
      throw new BadRequestException('调整积分不能为 0');
    }
    const member = await this.memberRepo.findOne({ where: { id } });
    if (!member) {
      throw new NotFoundException('会员不存在或已被删除');
    }
    if (member.points + dto.points < 0) {
      throw new BadRequestException(`积分不足：当前 ${member.points}，无法扣减 ${-dto.points}`);
    }
    member.points += dto.points;
    await this.memberRepo.save(member);
    await this.pointRepo.save(
      this.pointRepo.create({
        memberId: member.id,
        changeType: PointChangeType.ADJUST,
        points: dto.points,
        balanceAfter: member.points,
        source: '手动调整',
        remark: dto.remark,
      }),
    );
    return { points: member.points };
  }

  /** 储值充值 */
  async recharge(id: number, dto: RechargeDto) {
    const member = await this.memberRepo.findOne({ where: { id } });
    if (!member) {
      throw new NotFoundException('会员不存在或已被删除');
    }
    member.balance = Number((member.balance + dto.amount).toFixed(2));
    await this.memberRepo.save(member);
    return { balance: member.balance };
  }

  /** 批量设置/追加/移除标签 */
  async batchTag(dto: BatchTagDto) {
    const tags = await this.tagRepo.find({ where: { id: In(dto.tagIds) } });
    if (!tags.length) {
      throw new BadRequestException('所选标签不存在');
    }
    const members = await this.memberRepo.find({ where: { id: In(dto.memberIds) } });
    if (!members.length) {
      throw new NotFoundException('所选会员不存在');
    }
    for (const member of members) {
      if (dto.mode === 'set') {
        member.tags = tags;
      } else if (dto.mode === 'add') {
        const map = new Map((member.tags || []).map((t) => [t.id, t]));
        tags.forEach((t) => map.set(t.id, t));
        member.tags = [...map.values()];
      } else {
        const removeIds = new Set(dto.tagIds);
        member.tags = (member.tags || []).filter((t) => !removeIds.has(t.id));
      }
    }
    await this.memberRepo.save(members);
    return { affected: members.length };
  }

  /**
   * 根据累计消费金额计算应属等级（取满足条件的最高等级）
   * 供下单后自动升级使用
   */
  async calcLevelByConsumption(totalConsumption: number): Promise<Level | null> {
    const levels = await this.levelRepo.find({ order: { upgradeAmount: 'DESC' } });
    return levels.find((l) => totalConsumption >= l.upgradeAmount) ?? null;
  }

  /** 生成会员编号：M + YYYYMMDD + 4 位当日序号 */
  async generateMemberNo(): Promise<string> {
    const now = new Date();
    const ymd = `${now.getFullYear()}${String(now.getMonth() + 1).padStart(2, '0')}${String(now.getDate()).padStart(2, '0')}`;
    const prefix = `M${ymd}`;
    const last = await this.memberRepo
      .createQueryBuilder('m')
      .withDeleted()
      .where('m.memberNo LIKE :prefix', { prefix: `${prefix}%` })
      .orderBy('m.memberNo', 'DESC')
      .getOne();
    const seq = last ? parseInt(last.memberNo.slice(-4), 10) + 1 : 1;
    return `${prefix}${String(seq).padStart(4, '0')}`;
  }
}
