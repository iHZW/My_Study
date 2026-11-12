import 'reflect-metadata';
import { Logger, ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { NestExpressApplication } from '@nestjs/platform-express';
import { existsSync, mkdirSync } from 'fs';
import { networkInterfaces } from 'os';
import { join } from 'path';
import { AppModule } from './app.module';
import { AllExceptionsFilter } from './common/all-exceptions.filter';

/** 数据目录：SQLite 数据库文件存放位置，可通过环境变量 DATA_DIR 覆盖 */
export function ensureDataDir(): string {
  const dataDir = process.env.DATA_DIR || join(__dirname, '..', 'data');
  if (!existsSync(dataDir)) {
    mkdirSync(dataDir, { recursive: true });
  }
  return dataDir;
}

/** 获取本机局域网 IP，方便手机在同一 WiFi 下访问 */
function getLanAddresses(): string[] {
  const result: string[] = [];
  const nets = networkInterfaces();
  for (const name of Object.keys(nets)) {
    for (const net of nets[name] ?? []) {
      if (net.family === 'IPv4' && !net.internal) {
        result.push(`${name}: ${net.address}`);
      }
    }
  }
  return result;
}

async function bootstrap() {
  const dataDir = ensureDataDir();
  const app = await NestFactory.create<NestExpressApplication>(AppModule);

  app.setGlobalPrefix('api');
  app.enableCors({ origin: true, credentials: true });
  app.useGlobalPipes(
    new ValidationPipe({
      transform: true,
      whitelist: true,
      transformOptions: { enableImplicitConversion: true },
    }),
  );
  app.useGlobalFilters(new AllExceptionsFilter());

  // 托管管理后台静态资源：admin 构建产物存在时启用（单端口同时提供 API 与后台页面）
  const adminDist = join(__dirname, '..', '..', 'admin', 'dist');
  if (existsSync(adminDist)) {
    app.useStaticAssets(adminDist);
    const expressApp = app.getHttpAdapter().getInstance();
    // SPA history 路由回退：非 /api、非静态资源的 GET 请求一律返回 index.html
    expressApp.use((req: any, res: any, next: any) => {
      if (req.method === 'GET' && !req.path.startsWith('/api') && !req.path.includes('.')) {
        res.sendFile(join(adminDist, 'index.html'));
      } else {
        next();
      }
    });
  }

  const port = Number(process.env.PORT || 3000);
  await app.listen(port, '0.0.0.0');

  const logger = new Logger('Bootstrap');
  logger.log(`数据目录: ${dataDir}`);
  logger.log(`管理后台: ${existsSync(adminDist) ? `http://localhost:${port}/` : '（尚未构建，请先执行 pnpm build）'}`);
  logger.log(`接口地址: http://localhost:${port}/api`);
  const lans = getLanAddresses();
  if (lans.length) {
    logger.log(`手机/局域网访问: ${lans.map((i) => `http://${i.split(': ')[1]}:${port}`).join('  ')}`);
  }
  logger.log(`网卡信息: ${lans.join(' | ') || '未检测到局域网 IP'}`);
}

bootstrap();
