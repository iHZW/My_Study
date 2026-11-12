import { Controller, DefaultValuePipe, Get, ParseIntPipe, Query } from '@nestjs/common';
import { StatsService } from './stats.service';

@Controller('stats')
export class StatsController {
  constructor(private readonly statsService: StatsService) {}

  /** 指标卡汇总 */
  @Get('overview')
  overview() {
    return this.statsService.overview();
  }

  /** 新增会员趋势 */
  @Get('member-trend')
  memberTrend(@Query('days', new DefaultValuePipe(30), ParseIntPipe) days: number) {
    return this.statsService.memberTrend(days);
  }

  /** 消费趋势 */
  @Get('consumption-trend')
  consumptionTrend(@Query('days', new DefaultValuePipe(30), ParseIntPipe) days: number) {
    return this.statsService.consumptionTrend(days);
  }

  /** 等级分布 */
  @Get('level-distribution')
  levelDistribution() {
    return this.statsService.levelDistribution();
  }

  /** 标签分布 */
  @Get('tag-distribution')
  tagDistribution(@Query('limit', new DefaultValuePipe(10), ParseIntPipe) limit: number) {
    return this.statsService.tagDistribution(limit);
  }

  /** 订单类型分布 */
  @Get('order-type-distribution')
  orderTypeDistribution() {
    return this.statsService.orderTypeDistribution();
  }

  /** 消费排行 */
  @Get('top-members')
  topMembers(@Query('limit', new DefaultValuePipe(10), ParseIntPipe) limit: number) {
    return this.statsService.topMembers(limit);
  }
}
