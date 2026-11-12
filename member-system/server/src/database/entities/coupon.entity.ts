import { Column, CreateDateColumn, Entity, Index, JoinColumn, ManyToOne, PrimaryGeneratedColumn } from 'typeorm';
import { moneyColumn } from '../../common/pagination.dto';
import { Member } from './member.entity';

/** 优惠券类型 */
export enum CouponType {
  /** 满减券：满 threshold 减 value */
  FULL_REDUCTION = 1,
  /** 折扣券：满 threshold 打 value 折（value 为 0~1 的小数，如 0.88） */
  DISCOUNT = 2,
  /** 代金券：无门槛抵扣 value 元 */
  CASH = 3,
}

/** 优惠券模板 */
@Entity('coupon_template')
export class CouponTemplate {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ length: 50 })
  name: string;

  @Column({ type: 'int', default: CouponType.FULL_REDUCTION })
  type: CouponType;

  /** 使用门槛金额，0 表示无门槛 */
  @Column(moneyColumn())
  threshold: number;

  /** 优惠值：满减/代金为金额，折扣券为折扣率（0.88 = 88 折） */
  @Column({ type: 'decimal', precision: 12, scale: 2, default: 0, transformer: { to: (v: any) => v, from: (v: any) => (v == null ? v : Number(v)) } })
  value: number;

  /** 发行总量 */
  @Column({ type: 'int', default: 0 })
  totalQuantity: number;

  /** 已发放数量 */
  @Column({ type: 'int', default: 0 })
  issuedQuantity: number;

  /** 领取后有效天数 */
  @Column({ type: 'int', default: 30 })
  validDays: number;

  /** 1 启用 / 0 停用 */
  @Column({ type: 'int', default: 1 })
  status: number;

  @Column({ length: 255, nullable: true })
  remark: string;

  @CreateDateColumn()
  createdAt: Date;
}

/** 会员券状态 */
export enum MemberCouponStatus {
  /** 未使用 */
  UNUSED = 1,
  /** 已使用 */
  USED = 2,
  /** 已过期 */
  EXPIRED = 3,
}

/** 会员持有的优惠券 */
@Entity('member_coupon')
export class MemberCoupon {
  @PrimaryGeneratedColumn()
  id: number;

  @Index()
  @Column({ type: 'int' })
  templateId: number;

  @ManyToOne(() => CouponTemplate, { eager: true, onDelete: 'CASCADE' })
  @JoinColumn({ name: 'templateId' })
  template: CouponTemplate;

  @Index()
  @Column({ type: 'int' })
  memberId: number;

  @ManyToOne(() => Member, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'memberId' })
  member: Member;

  /** 券码，核销时校验 */
  @Index({ unique: true })
  @Column({ length: 32 })
  code: string;

  @Column({ type: 'int', default: MemberCouponStatus.UNUSED })
  status: MemberCouponStatus;

  @Column({ type: 'datetime' })
  receiveAt: Date;

  @Column({ type: 'datetime' })
  expireAt: Date;

  @Column({ type: 'datetime', nullable: true })
  usedAt: Date;

  /** 核销该券的订单号 */
  @Column({ length: 32, nullable: true })
  usedOrderNo: string;

  @CreateDateColumn()
  createdAt: Date;
}
