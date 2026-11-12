import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CouponTemplate, MemberCoupon } from '../database/entities/coupon.entity';
import { Member } from '../database/entities/member.entity';
import { CouponController } from './coupon.controller';
import { CouponService } from './coupon.service';

@Module({
  imports: [TypeOrmModule.forFeature([CouponTemplate, MemberCoupon, Member])],
  controllers: [CouponController],
  providers: [CouponService],
  exports: [CouponService],
})
export class CouponModule {}
