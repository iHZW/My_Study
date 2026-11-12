import {
  Column,
  CreateDateColumn,
  DeleteDateColumn,
  Entity,
  Index,
  JoinColumn,
  JoinTable,
  ManyToMany,
  ManyToOne,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';
import { moneyColumn } from '../../common/pagination.dto';
import { Level } from './level.entity';
import { Tag } from './tag.entity';

/** 性别 */
export enum Gender {
  UNKNOWN = 0,
  MALE = 1,
  FEMALE = 2,
}

/** 会员状态 */
export enum MemberStatus {
  DISABLED = 0,
  NORMAL = 1,
}

/** 会员档案 */
@Entity('member')
export class Member {
  @PrimaryGeneratedColumn()
  id: number;

  /** 会员编号，系统自动生成，如 M202610290001 */
  @Index({ unique: true })
  @Column({ length: 32 })
  memberNo: string;

  @Column({ length: 50 })
  name: string;

  /** 手机号，作为业务唯一标识 */
  @Index({ unique: true })
  @Column({ length: 20 })
  phone: string;

  @Column({ type: 'int', default: Gender.UNKNOWN })
  gender: Gender;

  /** 生日，格式 YYYY-MM-DD，用于生日营销提醒 */
  @Column({ length: 20, nullable: true })
  birthday: string;

  @Column({ length: 255, nullable: true })
  avatar: string;

  /** 会员等级（可空：未设置等级） */
  @ManyToOne(() => Level, { nullable: true, eager: true, onDelete: 'SET NULL' })
  @JoinColumn({ name: 'levelId' })
  level: Level;

  @Column({ type: 'int', nullable: true })
  levelId: number;

  /** 积分余额 */
  @Column({ type: 'int', default: 0 })
  points: number;

  /** 储值余额 */
  @Column(moneyColumn())
  balance: number;

  /** 累计消费金额（用于自动升级等级） */
  @Column(moneyColumn())
  totalConsumption: number;

  /** 累计消费次数 */
  @Column({ type: 'int', default: 0 })
  consumptionCount: number;

  /** 会员标签 */
  @ManyToMany(() => Tag, { eager: true })
  @JoinTable({
    name: 'member_tag_rel',
    joinColumn: { name: 'memberId', referencedColumnName: 'id' },
    inverseJoinColumn: { name: 'tagId', referencedColumnName: 'id' },
  })
  tags: Tag[];

  @Column({ type: 'int', default: MemberStatus.NORMAL })
  status: MemberStatus;

  /** 来源：门店登记 / 小程序 / 批量导入 等 */
  @Column({ length: 30, nullable: true })
  source: string;

  /** 所属门店 */
  @Column({ length: 50, nullable: true })
  storeName: string;

  @Column({ type: 'text', nullable: true })
  remark: string;

  @Column({ type: 'datetime', nullable: true })
  lastConsumeAt: Date;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  /** 软删除：保留历史消费数据可追溯 */
  @DeleteDateColumn()
  deletedAt: Date;
}
