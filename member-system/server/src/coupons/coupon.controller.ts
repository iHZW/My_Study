import { Body, Controller, Delete, Get, Param, ParseIntPipe, Post, Put, Query } from '@nestjs/common';
import { CouponService } from './coupon.service';
import {
  CreateCouponTemplateDto,
  IssueCouponDto,
  MemberCouponQueryDto,
  UpdateCouponTemplateDto,
} from './dto/coupon.dto';

@Controller('coupons')
export class CouponController {
  constructor(private readonly couponService: CouponService) {}

  /** 券模板列表 */
  @Get('templates')
  findAllTemplates() {
    return this.couponService.findAllTemplates();
  }

  @Post('templates')
  createTemplate(@Body() dto: CreateCouponTemplateDto) {
    return this.couponService.createTemplate(dto);
  }

  @Put('templates/:id')
  updateTemplate(@Param('id', ParseIntPipe) id: number, @Body() dto: UpdateCouponTemplateDto) {
    return this.couponService.updateTemplate(id, dto);
  }

  @Delete('templates/:id')
  removeTemplate(@Param('id', ParseIntPipe) id: number) {
    return this.couponService.removeTemplate(id);
  }

  /** 给会员发券 */
  @Post('issue')
  issue(@Body() dto: IssueCouponDto) {
    return this.couponService.issue(dto);
  }

  /** 会员持券列表 */
  @Get('member-coupons')
  findMemberCoupons(@Query() query: MemberCouponQueryDto) {
    return this.couponService.findMemberCoupons(query);
  }
}
