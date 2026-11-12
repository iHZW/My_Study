import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Level } from '../database/entities/level.entity';
import { Member } from '../database/entities/member.entity';
import { LevelController } from './level.controller';
import { LevelService } from './level.service';

@Module({
  imports: [TypeOrmModule.forFeature([Level, Member])],
  controllers: [LevelController],
  providers: [LevelService],
  exports: [LevelService],
})
export class LevelModule {}
