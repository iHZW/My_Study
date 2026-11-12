import { Type } from 'class-transformer';
import {
  ArrayNotEmpty,
  IsArray,
  IsIn,
  IsInt,
  IsNumber,
  IsOptional,
  IsString,
  MaxLength,
  Min,
} from 'class-validator';
import { PaginationDto } from '../../common/pagination.dto';

/** 创建优惠券模板 */
export class CreateCouponTemplateDto {
  @IsString({ message: '券名必须是字符串' })
  @MaxLength(50)
  name: string;

  /** 1 满减券 / 2 折扣券 / 3 代金券 */
  @Type(() => Number)
  @IsIn([1, 2, 3], { message: '券类型只能是 1 满减 / 2 折扣 / 3 代金' })
  type: number;

  /** 使用门槛金额，0 = 无门槛 */
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0)
  threshold: number;

  /** 满减/代金 = 抵扣金额；折扣 = 折扣率（0.88 = 88 折） */
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 2 }, { message: '优惠值必须是数字' })
  @Min(0.01)
  value: number;

  /** 发放总量，-1 = 不限量 */
  @Type(() => Number)
  @IsInt()
  @Min(-1)
  totalQuantity: number;

  /** 领取后有效天数 */
  @Type(() => Number)
  @IsInt()
  @Min(1)
  validDays: number;

  @IsOptional()
  @IsString()
  remark?: string;
}

export class UpdateCouponTemplateDto {
  @IsOptional()
  @IsString()
  @MaxLength(50)
  name?: string;

  @IsOptional()
  @Type(() => Number)
  @IsIn([1, 2, 3])
  type?: number;

  @IsOptional()
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0)
  threshold?: number;

  @IsOptional()
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0.01)
  value?: number;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(-1)
  totalQuantity?: number;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  validDays?: number;

  /** 0 停用（不再可发）/ 1 启用 */
  @IsOptional()
  @Type(() => Number)
  @IsIn([0, 1])
  status?: number;

  @IsOptional()
  @IsString()
  remark?: string;
}

/** 给指定会员发券 */
export class IssueCouponDto {
  @Type(() => Number)
  @IsInt()
  templateId: number;

  @IsArray()
  @ArrayNotEmpty({ message: '请选择至少一位会员' })
  @IsInt({ each: true })
  memberIds: number[];
}

/** 会员持券列表查询 */
export class MemberCouponQueryDto extends PaginationDto {
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  memberId?: number;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  templateId?: number;

  /** 0 未使用 / 1 已使用 / 2 已过期 */
  @IsOptional()
  @Type(() => Number)
  @IsIn([0, 1, 2])
  status?: number;
}
