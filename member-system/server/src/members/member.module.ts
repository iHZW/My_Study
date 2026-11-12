import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Level } from '../database/entities/level.entity';
import { Member } from '../database/entities/member.entity';
import { PointRecord } from '../database/entities/point-record.entity';
import { Tag } from '../database/entities/tag.entity';
import { MemberController } from './member.controller';
import { MemberExcelService } from './member-excel.service';
import { MemberService } from './member.service';

@Module({
  imports: [TypeOrmModule.forFeature([Member, Tag, Level, PointRecord])],
  controllers: [MemberController],
  providers: [MemberService, MemberExcelService],
  exports: [MemberService],
})
export class MemberModule {}
