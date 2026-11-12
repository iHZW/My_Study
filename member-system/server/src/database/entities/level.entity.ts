import { Column, CreateDateColumn, Entity, PrimaryGeneratedColumn, UpdateDateColumn } from 'typeorm';
import { moneyColumn } from '../../common/pagination.dto';

/**
 * 会员等级
 * 升级依据：累计消费金额达到 upgradeAmount 即自动升级（也可手动指定）
 */
@Entity('member_level')
export class Level {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ length: 30 })
  name: string;

  /** 等级编码，如 V1/V2/V3 */
  @Column({ length: 20, nullable: true })
  code: string;

  /** 升级到该等级所需的累计消费金额 */
  @Column(moneyColumn())
  upgradeAmount: number;

  /** 消费折扣，0.95 表示 95 折；1 表示无折扣 */
  @Column({ type: 'decimal', precision: 4, scale: 2, default: 1, transformer: { to: (v: any) => v, from: (v: any) => (v == null ? v : Number(v)) } })
  discount: number;

  /** 积分倍率，消费 1 元获得 pointsRate 积分 */
  @Column({ type: 'decimal', precision: 6, scale: 2, default: 1, transformer: { to: (v: any) => v, from: (v: any) => (v == null ? v : Number(v)) } })
  pointsRate: number;

  /** 展示颜色，前端标签底色 */
  @Column({ length: 20, nullable: true })
  color: string;

  @Column({ type: 'int', default: 0 })
  sortOrder: number;

  @Column({ type: 'text', nullable: true })
  remark: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
