import { Column, CreateDateColumn, Entity, Index, PrimaryGeneratedColumn } from 'typeorm';

/**
 * 会员标签（用于分组筛选），如「高频消费」「价格敏感」「生日当月」
 * 与会员是多对多关系，中间表 member_tag
 */
@Entity('member_tag')
export class Tag {
  @PrimaryGeneratedColumn()
  id: number;

  @Index({ unique: true })
  @Column({ length: 30 })
  name: string;

  /** 标签分组，如「消费特征」「渠道来源」 */
  @Column({ length: 30, nullable: true })
  groupName: string;

  @Column({ length: 20, nullable: true })
  color: string;

  @Column({ type: 'int', default: 0 })
  sortOrder: number;

  @Column({ type: 'text', nullable: true })
  remark: string;

  @CreateDateColumn()
  createdAt: Date;
}
