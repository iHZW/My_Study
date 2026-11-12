import { Type } from 'class-transformer';
import { IsInt, IsNumber, IsOptional, IsString, Max, MaxLength, Min } from 'class-validator';

export class CreateLevelDto {
  @IsString({ message: '等级名称必须是字符串' })
  @MaxLength(30)
  name: string;

  @IsOptional()
  @IsString()
  @MaxLength(20)
  code?: string;

  /** 升级到该等级所需累计消费金额 */
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 2 }, { message: '升级金额必须是数字' })
  @Min(0)
  upgradeAmount: number;

  /** 消费折扣，0.95 = 95 折，1 = 无折扣 */
  @IsOptional()
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0.1)
  @Max(1)
  discount?: number;

  /** 积分倍率：消费 1 元获得多少积分 */
  @IsOptional()
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0)
  pointsRate?: number;

  @IsOptional()
  @IsString()
  @MaxLength(20)
  color?: string;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  sortOrder?: number;

  @IsOptional()
  @IsString()
  remark?: string;
}

export class UpdateLevelDto {
  @IsOptional()
  @IsString()
  @MaxLength(30)
  name?: string;

  @IsOptional()
  @IsString()
  @MaxLength(20)
  code?: string;

  @IsOptional()
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0)
  upgradeAmount?: number;

  @IsOptional()
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0.1)
  @Max(1)
  discount?: number;

  @IsOptional()
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0)
  pointsRate?: number;

  @IsOptional()
  @IsString()
  @MaxLength(20)
  color?: string;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  sortOrder?: number;

  @IsOptional()
  @IsString()
  remark?: string;
}
