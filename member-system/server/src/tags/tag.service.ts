import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Tag } from '../database/entities/tag.entity';
import { CreateTagDto, UpdateTagDto } from './dto/tag.dto';

@Injectable()
export class TagService {
  constructor(@InjectRepository(Tag) private readonly tagRepo: Repository<Tag>) {}

  /** 全部标签，附带每个标签下的会员数量 */
  async findAll() {
    const tags = await this.tagRepo.find({
      order: { groupName: 'ASC', sortOrder: 'ASC', id: 'ASC' },
    });
    const counts: { tagId: number; count: string }[] = await this.tagRepo.query(
      `SELECT r.tagId AS tagId, COUNT(*) AS count
       FROM member_tag_rel r
       JOIN member m ON m.id = r.memberId AND m.deletedAt IS NULL
       GROUP BY r.tagId`,
    );
    const countMap = new Map(counts.map((c) => [Number(c.tagId), Number(c.count)]));
    return tags.map((t) => ({ ...t, memberCount: countMap.get(t.id) ?? 0 }));
  }

  async create(dto: CreateTagDto) {
    const exists = await this.tagRepo.findOne({ where: { name: dto.name } });
    if (exists) {
      throw new BadRequestException(`标签「${dto.name}」已存在`);
    }
    const tag = this.tagRepo.create(dto);
    return this.tagRepo.save(tag);
  }

  async update(id: number, dto: UpdateTagDto) {
    const tag = await this.tagRepo.findOne({ where: { id } });
    if (!tag) {
      throw new NotFoundException('标签不存在');
    }
    if (dto.name && dto.name !== tag.name) {
      const exists = await this.tagRepo.findOne({ where: { name: dto.name } });
      if (exists) {
        throw new BadRequestException(`标签「${dto.name}」已存在`);
      }
    }
    Object.assign(tag, dto);
    return this.tagRepo.save(tag);
  }

  async remove(id: number) {
    const tag = await this.tagRepo.findOne({ where: { id } });
    if (!tag) {
      throw new NotFoundException('标签不存在');
    }
    // 清理会员关联关系后删除标签
    await this.tagRepo.query('DELETE FROM member_tag_rel WHERE tagId = ?', [id]);
    await this.tagRepo.remove(tag);
    return { id };
  }
}
