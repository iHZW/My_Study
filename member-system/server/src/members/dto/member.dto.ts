import { Type } from 'class-transformer';
import {
  ArrayNotEmpty,
  IsArray,
  IsIn,
  IsInt,
  IsNumber,
  IsOptional,
  IsString,
  Matches,
  MaxLength,
  Min,
} from 'class-validator';
import { PaginationDto } from '../../common/pagination.dto';

/** 会员列表查询参数 */
export class MemberQueryDto extends PaginationDto {
  /** 关键词：姓名 / 手机号 / 会员编号 模糊匹配 */
  @IsOptional()
  @IsString()
  keyword?: string;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  levelId?: number;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  tagId?: number;

  @IsOptional()
  @Type(() => Number)
  @IsIn([0, 1])
  status?: number;

  /** 注册时间范围，格式 YYYY-MM-DD */
  @IsOptional()
  @Matches(/^\d{4}-\d{2}-\d{2}$/, { message: '日期格式应为 YYYY-MM-DD' })
  startDate?: string;

  @IsOptional()
  @Matches(/^\d{4}-\d{2}-\d{2}$/, { message: '日期格式应为 YYYY-MM-DD' })
  endDate?: string;

  /** 排序字段白名单 */
  @IsOptional()
  @IsIn(['createdAt', 'totalConsumption', 'points', 'balance', 'lastConsumeAt'])
  sortField?: string = 'createdAt';

  @IsOptional()
  @IsIn(['ASC', 'DESC'])
  sortOrder?: 'ASC' | 'DESC' = 'DESC';
}

export class CreateMemberDto {
  @IsString({ message: '姓名必须是字符串' })
  @MaxLength(50, { message: '姓名不能超过 50 个字符' })
  name: string;

  @Matches(/^1[3-9]\d{9}$/, { message: '手机号格式不正确' })
  phone: string;

  @IsOptional()
  @Type(() => Number)
  @IsIn([0, 1, 2], { message: '性别只能是 0 未知 / 1 男 / 2 女' })
  gender?: number;

  @IsOptional()
  @Matches(/^\d{4}-\d{2}-\d{2}$/, { message: '生日格式应为 YYYY-MM-DD' })
  birthday?: string;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  levelId?: number;

  @IsOptional()
  @IsArray()
  @IsInt({ each: true })
  tagIds?: number[];

  @IsOptional()
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0)
  balance?: number;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  points?: number;

  @IsOptional()
  @IsString()
  @MaxLength(30)
  source?: string;

  @IsOptional()
  @IsString()
  @MaxLength(50)
  storeName?: string;

  @IsOptional()
  @IsString()
  @MaxLength(255)
  avatar?: string;

  @IsOptional()
  @IsString()
  remark?: string;
}

export class UpdateMemberDto {
  @IsOptional()
  @IsString()
  @MaxLength(50)
  name?: string;

  @IsOptional()
  @Matches(/^1[3-9]\d{9}$/, { message: '手机号格式不正确' })
  phone?: string;

  @IsOptional()
  @Type(() => Number)
  @IsIn([0, 1, 2])
  gender?: number;

  @IsOptional()
  @Matches(/^\d{4}-\d{2}-\d{2}$/, { message: '生日格式应为 YYYY-MM-DD' })
  birthday?: string;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  levelId?: number;

  @IsOptional()
  @IsArray()
  @IsInt({ each: true })
  tagIds?: number[];

  @IsOptional()
  @Type(() => Number)
  @IsIn([0, 1], { message: '状态只能是 0 禁用 / 1 正常' })
  status?: number;

  @IsOptional()
  @IsString()
  @MaxLength(30)
  source?: string;

  @IsOptional()
  @IsString()
  @MaxLength(50)
  storeName?: string;

  @IsOptional()
  @IsString()
  @MaxLength(255)
  avatar?: string;

  @IsOptional()
  @IsString()
  remark?: string;
}

/** 后台手动调整积分（正加负减） */
export class AdjustPointsDto {
  @Type(() => Number)
  @IsInt({ message: '积分必须是整数' })
  points: number;

  @IsOptional()
  @IsString()
  @MaxLength(255)
  remark?: string;
}

/** 储值充值 */
export class RechargeDto {
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 2 }, { message: '金额必须是数字' })
  @Min(0.01, { message: '充值金额必须大于 0' })
  amount: number;

  @IsOptional()
  @IsString()
  @MaxLength(255)
  remark?: string;
}

/** 批量打标签 */
export class BatchTagDto {
  @IsArray()
  @ArrayNotEmpty({ message: '请选择至少一位会员' })
  @IsInt({ each: true })
  memberIds: number[];

  @IsArray()
  @ArrayNotEmpty({ message: '请选择至少一个标签' })
  @IsInt({ each: true })
  tagIds: number[];

  /** set 覆盖 / add 追加 / remove 移除 */
  @IsIn(['set', 'add', 'remove'])
  mode: 'set' | 'add' | 'remove';
}
