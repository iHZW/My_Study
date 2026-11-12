import { Body, Controller, Get, Post } from '@nestjs/common';
import { CurrentUser, Public } from '../common/auth.guard';
import { AuthService } from './auth.service';
import { LoginDto } from './dto/login.dto';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  /** 登录：POST /api/auth/login */
  @Public()
  @Post('login')
  login(@Body() dto: LoginDto) {
    return this.authService.login(dto);
  }

  /** 获取当前登录用户信息：GET /api/auth/profile */
  @Get('profile')
  profile(@CurrentUser('sub') userId: number) {
    return this.authService.profile(userId);
  }
}
