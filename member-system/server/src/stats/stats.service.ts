import { Injectable } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';

/** 本地时区的 YYYY-MM-DD */
function dateText(d: Date): string {
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
}

const DAY = 24 * 3600 * 1000;

@Injectable()
export class StatsService {
  constructor(@InjectDataSource() private readonly dataSource: DataSource) {}

  /** 顶部指标卡：会员总数 / 今日新增 / 本月新增 / 累计消费 / 订单总数 / 今日营业额 / 30 天活跃会员 */
  async overview() {
    const now = new Date();
    const todayStart = dateText(now);
    const monthStart = `${todayStart.slice(0, 7)}-01`;
    const active30dStart = dateText(new Date(now.getTime() - 30 * DAY));

    const memberRow = await this.dataSource.query(
      `SELECT COUNT(*) AS total,
              SUM(CASE WHEN date(createdAt) >= ? THEN 1 ELSE 0 END) AS newToday,
              SUM(CASE WHEN date(createdAt) >= ? THEN 1 ELSE 0 END) AS newMonth
       FROM member WHERE deletedAt IS NULL`,
      [todayStart, monthStart],
    );
    const orderRow = await this.dataSource.query(
      `SELECT COUNT(*) AS totalOrders,
              COALESCE(SUM(payAmount), 0) AS totalConsumption,
              COALESCE(SUM(CASE WHEN date(consumeAt) >= ? THEN payAmount ELSE 0 END), 0) AS todayAmount,
              COALESCE(SUM(CASE WHEN date(consumeAt) >= ? THEN 1 ELSE 0 END), 0) AS todayOrders
       FROM consume_order`,
      [todayStart, todayStart],
    );
    const activeRow = await this.dataSource.query(
      `SELECT COUNT(DISTINCT memberId) AS active FROM consume_order WHERE date(consumeAt) >= ?`,
      [active30dStart],
    );

    const m = memberRow[0] ?? {};
    const o = orderRow[0] ?? {};
    const a = activeRow[0] ?? {};
    return {
      totalMembers: Number(m.total ?? 0),
      newToday: Number(m.newToday ?? 0),
      newThisMonth: Number(m.newMonth ?? 0),
      totalConsumption: Number(o.totalConsumption ?? 0),
      totalOrders: Number(o.totalOrders ?? 0),
      todayAmount: Number(o.todayAmount ?? 0),
      todayOrders: Number(o.todayOrders ?? 0),
      activeMembers30d: Number(a.active ?? 0),
    };
  }

  /** 近 N 天新增会员趋势 */
  async memberTrend(days = 30) {
    const dates = this.buildDateSeries(days);
    const rows: { d: string; count: string }[] = await this.dataSource.query(
      `SELECT substr(createdAt, 1, 10) AS d, COUNT(*) AS count
       FROM member
       WHERE deletedAt IS NULL AND date(createdAt) >= ?
       GROUP BY d`,
      [dates[0]],
    );
    const map = new Map(rows.map((r) => [r.d, Number(r.count)]));
    return dates.map((date) => ({ date, count: map.get(date) ?? 0 }));
  }

  /** 近 N 天消费金额与订单数趋势 */
  async consumptionTrend(days = 30) {
    const dates = this.buildDateSeries(days);
    const rows: { d: string; amount: string; orders: string }[] = await this.dataSource.query(
      `SELECT substr(consumeAt, 1, 10) AS d,
              COALESCE(SUM(payAmount), 0) AS amount,
              COUNT(*) AS orders
       FROM consume_order
       WHERE date(consumeAt) >= ?
       GROUP BY d`,
      [dates[0]],
    );
    const map = new Map(rows.map((r) => [r.d, r]));
    return dates.map((date) => {
      const row = map.get(date);
      return {
        date,
        amount: row ? Number(row.amount) : 0,
        orders: row ? Number(row.orders) : 0,
      };
    });
  }

  /** 会员等级分布 */
  async levelDistribution() {
    const rows: { levelId: number | null; name: string | null; color: string | null; count: string }[] =
      await this.dataSource.query(
        `SELECT m.levelId AS levelId, l.name AS name, l.color AS color, COUNT(*) AS count
         FROM member m
         LEFT JOIN member_level l ON l.id = m.levelId
         WHERE m.deletedAt IS NULL
         GROUP BY m.levelId
         ORDER BY count DESC`,
      );
    return rows.map((r) => ({
      levelId: r.levelId,
      name: r.name ?? '未分级',
      color: r.color ?? '#C0C4CC',
      count: Number(r.count),
    }));
  }

  /** 会员标签分布（Top N） */
  async tagDistribution(limit = 10) {
    const rows: { name: string; color: string | null; count: string }[] = await this.dataSource.query(
      `SELECT t.name AS name, t.color AS color, COUNT(*) AS count
       FROM member_tag_rel r
       JOIN member_tag t ON t.id = r.tagId
       JOIN member m ON m.id = r.memberId AND m.deletedAt IS NULL
       GROUP BY r.tagId
       ORDER BY count DESC
       LIMIT ?`,
      [limit],
    );
    return rows.map((r) => ({ name: r.name, color: r.color ?? '#409EFF', count: Number(r.count) }));
  }

  /** 订单类型分布（堂食/外卖/零售） */
  async orderTypeDistribution() {
    const rows: { type: number; count: string; amount: string }[] = await this.dataSource.query(
      `SELECT type, COUNT(*) AS count, COALESCE(SUM(payAmount), 0) AS amount
       FROM consume_order GROUP BY type`,
    );
    const names: Record<number, string> = { 1: '堂食', 2: '外卖', 3: '零售' };
    return rows.map((r) => ({
      type: r.type,
      name: names[r.type] ?? '其他',
      count: Number(r.count),
      amount: Number(r.amount),
    }));
  }

  /** 消费排行 Top N 会员 */
  async topMembers(limit = 10) {
    const rows = await this.dataSource.query(
      `SELECT m.id AS id, m.name AS name, m.phone AS phone, m.memberNo AS memberNo,
              m.totalConsumption AS totalConsumption, m.consumptionCount AS consumptionCount,
              m.points AS points, l.name AS levelName
       FROM member m
       LEFT JOIN member_level l ON l.id = m.levelId
       WHERE m.deletedAt IS NULL
       ORDER BY m.totalConsumption DESC
       LIMIT ?`,
      [limit],
    );
    return rows.map((r: Record<string, unknown>) => ({
      ...r,
      totalConsumption: Number(r.totalConsumption),
      consumptionCount: Number(r.consumptionCount),
      points: Number(r.points),
      // 手机号打码，看板公开展示时保护隐私
      phone: String(r.phone ?? '').replace(/^(\d{3})\d{4}(\d{4})$/, '$1****$2'),
    }));
  }

  /** 生成最近 N 天的日期序列（含今天） */
  private buildDateSeries(days: number): string[] {
    const safeDays = Math.min(Math.max(days, 1), 365);
    const now = Date.now();
    const dates: string[] = [];
    for (let i = safeDays - 1; i >= 0; i--) {
      dates.push(dateText(new Date(now - i * DAY)));
    }
    return dates;
  }
}
