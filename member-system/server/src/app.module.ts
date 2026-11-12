import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { APP_GUARD, APP_INTERCEPTOR } from '@nestjs/core';
import { TypeOrmModule } from '@nestjs/typeorm';
import { existsSync, mkdirSync } from 'fs';
import { dirname, join } from 'path';
import { AuthModule } from './auth/auth.module';
import { JwtAuthGuard } from './common/auth.guard';
import { ResponseInterceptor } from './common/response.interceptor';
import { CouponModule } from './coupons/coupon.module';
import { LevelModule } from './levels/level.module';
import { MemberModule } from './members/member.module';
import { OrderModule } from './orders/order.module';
import { SeedModule } from './seed/seed.module';
import { StatsModule } from './stats/stats.module';
import { TagModule } from './tags/tag.module';

/** SQLite 数据库文件路径 */
function resolveDatabasePath(): string {
  const dataDir = process.env.DATA_DIR || join(__dirname, '..', 'data');
  if (!existsSync(dataDir)) {
    mkdirSync(dataDir, { recursive: true });
  }
  return join(dataDir, 'member.db');
}

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    TypeOrmModule.forRoot({
      type: 'better-sqlite3',
      database: resolveDatabasePath(),
      entities: [join(__dirname, '**', '*.entity{.ts,.js}')],
      synchronize: true,
      logging: false,
    }),
    AuthModule,
    MemberModule,
    TagModule,
    LevelModule,
    OrderModule,
    CouponModule,
    StatsModule,
    SeedModule,
  ],
  providers: [
    { provide: APP_INTERCEPTOR, useClass: ResponseInterceptor },
    { provide: APP_GUARD, useClass: JwtAuthGuard },
  ],
})
export class AppModule {}
