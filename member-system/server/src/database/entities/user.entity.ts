import { Column, CreateDateColumn, Entity, Index, PrimaryGeneratedColumn, UpdateDateColumn } from 'typeorm';

/** 后台账号角色 */
export enum UserRole {
  /** 超级管理员：可管理会员、订单、优惠券、账号 */
  ADMIN = 'admin',
  /** 门店员工：可查看与登记消费，不能删除数据 */
  STAFF = 'staff',
}

/** 后台登录账号（Web 管理后台与 iOS App 共用） */
@Entity('sys_user')
export class User {
  @PrimaryGeneratedColumn()
  id: number;

  @Index({ unique: true })
  @Column({ length: 50 })
  username: string;

  /** bcrypt 加密后的密码，接口永不返回该字段 */
  @Column({ length: 100, select: false })
  password: string;

  @Column({ length: 50, nullable: true })
  realName: string;

  @Column({ type: 'varchar', length: 20, default: UserRole.ADMIN })
  role: UserRole;

  /** 1 启用 / 0 停用 */
  @Column({ type: 'int', default: 1 })
  status: number;

  @Column({ type: 'datetime', nullable: true })
  lastLoginAt: Date;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
