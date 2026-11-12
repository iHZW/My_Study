import { CallHandler, ExecutionContext, Injectable, NestInterceptor, StreamableFile } from '@nestjs/common';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';

/**
 * 统一响应结构
 *
 * 同时兼容两类客户端：
 * - Web 管理后台：读取 data 字段
 * - iOS App（复用工程内 CacheDataLoader 的解析约定）：读取 status（"1" 表示成功）与 errmsg
 */
export interface ApiResponse<T> {
  status: '0' | '1';
  errmsg: string;
  code: number;
  data: T;
  timestamp: number;
}

@Injectable()
export class ResponseInterceptor<T> implements NestInterceptor<T, ApiResponse<T>> {
  intercept(context: ExecutionContext, next: CallHandler): Observable<ApiResponse<T>> {
    return next.handle().pipe(
      map((data) => {
        // 文件下载（Excel 导出等）直接透传，不做 JSON 包装
        if (data instanceof StreamableFile) {
          return data as unknown as ApiResponse<T>;
        }
        return {
          status: '1' as const,
          errmsg: 'ok',
          code: 200,
          data: data === undefined ? null : data,
          timestamp: Date.now(),
        };
      }),
    );
  }
}
