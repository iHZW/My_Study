import { Type } from 'class-transformer';
import {
  IsArray,
  IsIn,
  IsInt,
  IsNumber,
  IsOptional,
  IsString,
  Matches,
  MaxLength,
  Min,
  ValidateNested,
} from 'class-validator';
import { PaginationDto } from '../../common/pagination.dto';

/** 订单商品/菜品明细行 */
export class OrderItemDto {
  @IsString({ message: '商品名称必须是字符串' })
  @MaxLength(100)
  name: string;

  @Type(() => Number)
  @IsInt({ message: '数量必须是整数' })
  @Min(1)
  quantity: number;

  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 2 }, { message: '单价必须是数字' })
  @Min(0)
  price: number;
}

/** 录入消费订单 */
export class CreateOrderDto {
  @Type(() => Number)
  @IsInt()
  @Min(1)
  memberId: number;

  /** 1 堂食 / 2 外卖 / 3 零售 */
  @IsOptional()
  @Type(() => Number)
  @IsIn([1, 2, 3])
  type?: number;

  /** 原价总额；传了 items 时以 items 合计为准 */
  @IsOptional()
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0.01)
  totalAmount?: number;

  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => OrderItemDto)
  items?: OrderItemDto[];

  /** 使用的会员券 ID */
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  memberCouponId?: number;

  /** 本单使用的积分数（100 积分抵 1 元） */
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  pointsUsed?: number;

  @IsOptional()
  @IsIn(['cash', 'wechat', 'alipay', 'balance'])
  payMethod?: string;

  @IsOptional()
  @IsString()
  @MaxLength(50)
  storeName?: string;

  @IsOptional()
  @IsString()
  @MaxLength(255)
  remark?: string;

  /** 消费时间，缺省为当前时间；支持补录历史订单 */
  @IsOptional()
  @IsString()
  consumeAt?: string;
}

/** 订单列表查询 */
export class OrderQueryDto extends PaginationDto {
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  memberId?: number;

  @IsOptional()
  @Type(() => Number)
  @IsIn([1, 2, 3])
  type?: number;

  /** 关键词：订单号 / 会员姓名 / 手机号 */
  @IsOptional()
  @IsString()
  keyword?: string;

  @IsOptional()
  @Matches(/^\d{4}-\d{2}-\d{2}$/, { message: '日期格式应为 YYYY-MM-DD' })
  startDate?: string;

  @IsOptional()
  @Matches(/^\d{4}-\d{2}-\d{2}$/, { message: '日期格式应为 YYYY-MM-DD' })
  endDate?: string;
}
