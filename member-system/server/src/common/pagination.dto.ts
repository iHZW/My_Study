import { Type } from 'class-transformer';
import { IsInt, IsOptional, Max, Min } from 'class-validator';
import { ColumnOptions, ValueTransformer } from 'typeorm';

/** 通用分页查询参数 */
export class PaginationDto {
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number = 1;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(500)
  size?: number = 20;
}

/** 分页返回结构 */
export interface Paginated<T> {
  list: T[];
  total: number;
  page: number;
  size: number;
  totalPages: number;
}

export function paginate<T>(list: T[], total: number, page: number, size: number): Paginated<T> {
  return {
    list,
    total,
    page,
    size,
    totalPages: size > 0 ? Math.ceil(total / size) : 0,
  };
}

/** SQLite 中 decimal 列可能返回字符串，统一转成 number 便于前端直接计算 */
const numericTransformer: ValueTransformer = {
  to: (value: any) => value,
  from: (value: any) => (value === null || value === undefined ? value : Number(value)),
};

/** 金额列的统一配置 */
export function moneyColumn(extra: Partial<ColumnOptions> = {}): ColumnOptions {
  return {
    type: 'decimal',
    precision: 12,
    scale: 2,
    default: 0,
    transformer: numericTransformer,
    ...extra,
  };
}
