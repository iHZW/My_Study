import { ArgumentsHost, Catch, ExceptionFilter, HttpException, HttpStatus, Logger } from '@nestjs/common';
import { Response } from 'express';

/**
 * 全局异常过滤器：保证任何错误都以统一结构返回
 * { status: "0", errmsg: "错误信息", code: <httpStatus>, data: null }
 */
@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  private readonly logger = new Logger('Exception');

  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();

    let status = HttpStatus.INTERNAL_SERVER_ERROR;
    let message = '服务器内部错误';

    if (exception instanceof HttpException) {
      status = exception.getStatus();
      const res = exception.getResponse() as any;
      if (typeof res === 'string') {
        message = res;
      } else if (Array.isArray(res?.message)) {
        // class-validator 校验失败时 message 为数组，取第一条并附带字段信息
        message = res.message.join('；');
      } else if (res?.message) {
        message = res.message;
      } else {
        message = exception.message;
      }
    } else if (exception instanceof Error) {
      message = exception.message;
      this.logger.error(exception.message, exception.stack);
    }

    response.status(status).json({
      status: '0',
      errmsg: message,
      code: status,
      data: null,
      timestamp: Date.now(),
    });
  }
}
