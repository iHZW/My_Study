import { Column, CreateDateColumn, Entity, Index, JoinColumn, ManyToOne, PrimaryGeneratedColumn } from 'typeorm';
import { Member } from './member.entity';

/** 积分变动类型 */
export enum PointChangeType {
  /** 获取（消费赠送、活动赠送、注册赠送） */
  EARN = 1,
  /** 消耗（积分抵扣、积分兑换） */
  SPEND = 2,
  /** 人工调整（后台手动加减） */
  ADJUST = 3,
  /** 过期清零 */
  EXPIRE = 4,
}

/** 积分流水：每一笔积分变动都留痕，保证余额可追溯 */
@Entity('point_record')
export class PointRecord {
  @PrimaryGeneratedColumn()
  id: number;

  @Index()
  @Column({ type: 'int' })
  memberId: number;

  @ManyToOne(() => Member, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'memberId' })
  member: Member;

  @Column({ type: 'int', default: PointChangeType.EARN })
  changeType: PointChangeType;

  /** 变动值，正数为增加、负数为减少 */
  @Column({ type: 'int' })
  points: number;

  /** 变动后的积分余额快照 */
  @Column({ type: 'int', default: 0 })
  balanceAfter: number;

  /** 来源说明：消费赠送 / 积分抵扣 / 手动调整 */
  @Column({ length: 50, nullable: true })
  source: string;

  /** 关联订单号 */
  @Column({ length: 32, nullable: true })
  orderNo: string;

  @Column({ length: 255, nullable: true })
  remark: string;

  @CreateDateColumn()
  createdAt: Date;
}
