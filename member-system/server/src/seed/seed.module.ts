import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CouponTemplate, MemberCoupon } from '../database/entities/coupon.entity';
import { Level } from '../database/entities/level.entity';
import { Member } from '../database/entities/member.entity';
import { Order } from '../database/entities/order.entity';
import { PointRecord } from '../database/entities/point-record.entity';
import { Tag } from '../database/entities/tag.entity';
import { User } from '../database/entities/user.entity';
import { SeedService } from './seed.service';

/** 首次启动时自动初始化账号、基础配置与演示数据 */
@Module({
  imports: [TypeOrmModule.forFeature([User, Level, Tag, Member, Order, PointRecord, CouponTemplate, MemberCoupon])],
  providers: [SeedService],
})
export class SeedModule {}
