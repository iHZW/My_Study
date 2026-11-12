import { Injectable, UnauthorizedException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';
import { Repository } from 'typeorm';
import { User } from '../database/entities/user.entity';
import { LoginDto } from './dto/login.dto';
import { JwtPayload } from '../common/auth.guard';

export interface LoginResult {
  token: string;
  expiresIn: number;
  user: { id: number; username: string; realName: string; role: string };
}

@Injectable()
export class AuthService {
  /** token 有效期（秒），7 天 */
  private readonly expiresInSeconds = 7 * 24 * 3600;

  constructor(
    @InjectRepository(User) private readonly userRepo: Repository<User>,
    private readonly jwtService: JwtService,
  ) {}

  async login(dto: LoginDto): Promise<LoginResult> {
    const user = await this.userRepo
      .createQueryBuilder('u')
      .addSelect('u.password')
      .where('u.username = :username', { username: dto.username })
      .getOne();

    if (!user || user.status !== 1) {
      throw new UnauthorizedException('账号不存在或已停用');
    }
    const matched = await bcrypt.compare(dto.password, user.password);
    if (!matched) {
      throw new UnauthorizedException('密码错误');
    }

    const payload: JwtPayload = { sub: user.id, username: user.username, role: user.role };
    const token = await this.jwtService.signAsync(payload, { expiresIn: this.expiresInSeconds });

    user.lastLoginAt = new Date();
    await this.userRepo.save(user);

    return {
      token,
      expiresIn: this.expiresInSeconds,
      user: { id: user.id, username: user.username, realName: user.realName, role: user.role },
    };
  }

  async profile(userId: number) {
    const user = await this.userRepo.findOne({ where: { id: userId } });
    if (!user) {
      throw new UnauthorizedException('登录状态已失效');
    }
    return { id: user.id, username: user.username, realName: user.realName, role: user.role, lastLoginAt: user.lastLoginAt };
  }
}
