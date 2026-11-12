import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Level } from '../database/entities/level.entity';
import { Member } from '../database/entities/member.entity';
import { CreateLevelDto, UpdateLevelDto } from './dto/level.dto';

@Injectable()
export class LevelService {
  constructor(
    @InjectRepository(Level) private readonly levelRepo: Repository<Level>,
    @InjectRepository(Member) private readonly memberRepo: Repository<Member>,
  ) {}

  /** 全部等级，附带每个等级的会员数量 */
  async findAll() {
    const levels = await this.levelRepo.find({
      order: { upgradeAmount: 'ASC', sortOrder: 'ASC', id: 'ASC' },
    });
    const counts = await this.memberRepo
      .createQueryBuilder('m')
      .select('m.levelId', 'levelId')
      .addSelect('COUNT(*)', 'count')
      .where('m.levelId IS NOT NULL')
      .groupBy('m.levelId')
      .getRawMany<{ levelId: number; count: string }>();
    const countMap = new Map(counts.map((c) => [Number(c.levelId), Number(c.count)]));
    return levels.map((l) => ({ ...l, memberCount: countMap.get(l.id) ?? 0 }));
  }

  async create(dto: CreateLevelDto) {
    const level = this.levelRepo.create(dto);
    return this.levelRepo.save(level);
  }

  async update(id: number, dto: UpdateLevelDto) {
    const level = await this.levelRepo.findOne({ where: { id } });
    if (!level) {
      throw new NotFoundException('等级不存在');
    }
    Object.assign(level, dto);
    return this.levelRepo.save(level);
  }

  async remove(id: number) {
    const level = await this.levelRepo.findOne({ where: { id } });
    if (!level) {
      throw new NotFoundException('等级不存在');
    }
    const inUse = await this.memberRepo.count({ where: { levelId: id } });
    if (inUse > 0) {
      throw new BadRequestException(`该等级下还有 ${inUse} 位会员，请先调整会员等级后再删除`);
    }
    await this.levelRepo.remove(level);
    return { id };
  }
}
