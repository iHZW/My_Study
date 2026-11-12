import { Column, CreateDateColumn, Entity, Index, JoinColumn, ManyToOne, PrimaryGeneratedColumn } from 'typeorm';
import { moneyColumn } from '../../common/pagination.dto';
import { Member } from './member.entity';

/** 订单类型（餐饮/零售） */
export enum OrderType {
  /** 堂食 */
  DINE_IN = 1,
  /** 外卖 */
  TAKEAWAY = 2,
  /** 零售 */
  RETAIL = 3,
}

/** 支付方式 */
export enum PayMethod {
  CASH = 'cash',
  WECHAT = 'wechat',
  ALIPAY = 'alipay',
  /** 会员储值卡 */
  BALANCE = 'balance',
}

/** 消费订单 */
@Entity('consume_order')
export class Order {
  @PrimaryGeneratedColumn()
  id: number;

  @Index({ unique: true })
  @Column({ length: 32 })
  orderNo: string;

  @Index()
  @Column({ type: 'int' })
  memberId: number;

  @ManyToOne(() => Member, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'memberId' })
  member: Member;

  @Column({ type: 'int', default: OrderType.DINE_IN })
  type: OrderType;

  /** 订单原价总额 */
  @Column(moneyColumn())
  totalAmount: number;

  /** 优惠金额（等级折扣 + 优惠券） */
  @Column(moneyColumn())
  discountAmount: number;

  /** 积分抵扣金额 */
  @Column(moneyColumn())
  pointsDeductionAmount: number;

  /** 本次消耗的积分数 */
  @Column({ type: 'int', default: 0 })
  pointsUsed: number;

  /** 实付金额 = 原价 - 优惠 - 积分抵扣 */
  @Column(moneyColumn())
  payAmount: number;

  /** 本单获得的积分 */
  @Column({ type: 'int', default: 0 })
  pointsEarned: number;

  /** 使用的会员券 ID */
  @Column({ type: 'int', nullable: true })
  memberCouponId: number;

  @Column({ length: 20, default: PayMethod.WECHAT })
  payMethod: PayMethod;

  @Column({ length: 50, nullable: true })
  storeName: string;

  /** 商品/菜品明细，JSON 字符串存储，格式 [{name, quantity, price}] */
  @Column({ type: 'text', nullable: true })
  items: string;

  @Column({ length: 255, nullable: true })
  remark: string;

  /** 消费时间（可与创建时间不同，支持补录历史订单） */
  @Index()
  @Column({ type: 'datetime' })
  consumeAt: Date;

  @CreateDateColumn()
  createdAt: Date;
}
