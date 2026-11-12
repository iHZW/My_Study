import { BadRequestException, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import * as ExcelJS from 'exceljs';
import { Repository } from 'typeorm';
import { Level } from '../database/entities/level.entity';
import { Gender, Member, MemberStatus } from '../database/entities/member.entity';
import { Tag } from '../database/entities/tag.entity';
import { MemberQueryDto } from './dto/member.dto';
import { MemberService } from './member.service';

/** 导入结果汇总 */
export interface ImportResult {
  total: number;
  created: number;
  updated: number;
  skipped: number;
  failed: { row: number; phone: string; reason: string }[];
}

const GENDER_TEXT: Record<number, string> = { 0: '未知', 1: '男', 2: '女' };

function parseGender(value: unknown): Gender {
  if (value === 1 || value === '1' || value === '男') return Gender.MALE;
  if (value === 2 || value === '2' || value === '女') return Gender.FEMALE;
  return Gender.UNKNOWN;
}

function parseDateText(value: unknown): string | undefined {
  if (!value) return undefined;
  if (value instanceof Date) {
    return `${value.getFullYear()}-${String(value.getMonth() + 1).padStart(2, '0')}-${String(value.getDate()).padStart(2, '0')}`;
  }
  const text = String(value).trim();
  const match = text.match(/^(\d{4})[-/.年](\d{1,2})[-/.月](\d{1,2})/);
  if (match) {
    return `${match[1]}-${match[2].padStart(2, '0')}-${match[3].padStart(2, '0')}`;
  }
  return undefined;
}

function dateText(value: unknown): string {
  if (!value) return '';
  const d = value instanceof Date ? value : new Date(String(value));
  if (isNaN(d.getTime())) return '';
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')} ${String(d.getHours()).padStart(2, '0')}:${String(d.getMinutes()).padStart(2, '0')}`;
}

@Injectable()
export class MemberExcelService {
  constructor(
    @InjectRepository(Member) private readonly memberRepo: Repository<Member>,
    @InjectRepository(Tag) private readonly tagRepo: Repository<Tag>,
    @InjectRepository(Level) private readonly levelRepo: Repository<Level>,
    private readonly memberService: MemberService,
  ) {}

  /** 按当前筛选条件导出会员列表 */
  async exportMembers(query: MemberQueryDto): Promise<Buffer> {
    const qb = this.memberRepo.createQueryBuilder('m');
    if (query.keyword) {
      qb.andWhere('(m.name LIKE :kw OR m.phone LIKE :kw OR m.memberNo LIKE :kw)', { kw: `%${query.keyword}%` });
    }
    if (query.levelId !== undefined) {
      qb.andWhere('m.levelId = :levelId', { levelId: query.levelId });
    }
    if (query.status !== undefined) {
      qb.andWhere('m.status = :status', { status: query.status });
    }
    if (query.startDate) {
      qb.andWhere('date(m.createdAt) >= :startDate', { startDate: query.startDate });
    }
    if (query.endDate) {
      qb.andWhere('date(m.createdAt) <= :endDate', { endDate: query.endDate });
    }
    if (query.tagId !== undefined) {
      qb.andWhere('m.id IN (SELECT r.memberId FROM member_tag_rel r WHERE r.tagId = :tagId)', { tagId: query.tagId });
    }
    qb.orderBy('m.id', 'ASC');
    const members = await qb.getMany();

    const workbook = new ExcelJS.Workbook();
    const sheet = workbook.addWorksheet('会员列表');
    sheet.columns = [
      { header: '会员编号', key: 'memberNo', width: 18 },
      { header: '姓名', key: 'name', width: 12 },
      { header: '手机号', key: 'phone', width: 15 },
      { header: '性别', key: 'gender', width: 6 },
      { header: '生日', key: 'birthday', width: 12 },
      { header: '等级', key: 'level', width: 10 },
      { header: '标签', key: 'tags', width: 24 },
      { header: '积分', key: 'points', width: 8 },
      { header: '储值余额', key: 'balance', width: 10 },
      { header: '累计消费', key: 'totalConsumption', width: 10 },
      { header: '消费次数', key: 'consumptionCount', width: 9 },
      { header: '状态', key: 'status', width: 8 },
      { header: '来源', key: 'source', width: 10 },
      { header: '门店', key: 'storeName', width: 12 },
      { header: '注册时间', key: 'createdAt', width: 18 },
      { header: '最近消费时间', key: 'lastConsumeAt', width: 18 },
      { header: '备注', key: 'remark', width: 24 },
    ];
    sheet.getRow(1).font = { bold: true };

    members.forEach((m) => {
      sheet.addRow({
        memberNo: m.memberNo,
        name: m.name,
        phone: m.phone,
        gender: GENDER_TEXT[m.gender] ?? '未知',
        birthday: m.birthday ?? '',
        level: m.level?.name ?? '',
        tags: (m.tags || []).map((t) => t.name).join('、'),
        points: m.points,
        balance: m.balance,
        totalConsumption: m.totalConsumption,
        consumptionCount: m.consumptionCount,
        status: m.status === MemberStatus.NORMAL ? '正常' : '禁用',
        source: m.source ?? '',
        storeName: m.storeName ?? '',
        createdAt: dateText(m.createdAt),
        lastConsumeAt: dateText(m.lastConsumeAt),
        remark: m.remark ?? '',
      });
    });

    const buffer = await workbook.xlsx.writeBuffer();
    return Buffer.from(buffer);
  }

  /** 下载导入模板 */
  async exportTemplate(): Promise<Buffer> {
    const levels = await this.levelRepo.find({ order: { upgradeAmount: 'ASC' } });
    const tags = await this.tagRepo.find({ order: { id: 'ASC' }, take: 10 });

    const workbook = new ExcelJS.Workbook();
    const sheet = workbook.addWorksheet('会员导入');
    sheet.columns = [
      { header: '姓名*', key: 'name', width: 12 },
      { header: '手机号*', key: 'phone', width: 15 },
      { header: '性别', key: 'gender', width: 6 },
      { header: '生日', key: 'birthday', width: 12 },
      { header: '等级', key: 'level', width: 10 },
      { header: '标签', key: 'tags', width: 24 },
      { header: '积分', key: 'points', width: 8 },
      { header: '储值余额', key: 'balance', width: 10 },
      { header: '门店', key: 'storeName', width: 12 },
      { header: '备注', key: 'remark', width: 24 },
    ];
    sheet.getRow(1).font = { bold: true };
    sheet.addRow({
      name: '张三',
      phone: '13800001111',
      gender: '男',
      birthday: '1995-06-15',
      level: levels[0]?.name ?? '',
      tags: tags.slice(0, 2).map((t) => t.name).join('、'),
      points: 0,
      balance: 0,
      storeName: '总店',
      remark: '示例行，导入前请删除',
    });

    const note = workbook.addWorksheet('填写说明');
    note.getColumn(1).width = 90;
    [
      '1. 带 * 的列为必填项；姓名、手机号不能为空。',
      '2. 手机号必须是 11 位大陆手机号，作为会员唯一标识。',
      '3. 性别填写：男 / 女 / 未知。',
      '4. 生日格式：1995-06-15。',
      `5. 等级填写等级名称，可选值：${levels.map((l) => l.name).join(' / ') || '（暂无等级）'}；不填则不设等级。`,
      '6. 多个标签用「、」或「，」分隔；标签不存在时会自动创建。',
      '7. 积分、储值余额填数字，不填默认为 0。',
      '8. 手机号已存在时：按导入时选择的模式「跳过」或「覆盖更新」。',
    ].forEach((line) => note.addRow([line]));

    const buffer = await workbook.xlsx.writeBuffer();
    return Buffer.from(buffer);
  }

  /**
   * 批量导入会员
   * @param fileBuffer 上传的 xlsx 文件内容
   * @param mode 手机号重复时：skip 跳过 / update 覆盖更新
   */
  async importMembers(fileBuffer: Buffer, mode: 'skip' | 'update'): Promise<ImportResult> {
    let workbook: ExcelJS.Workbook;
    try {
      workbook = new ExcelJS.Workbook();
      await workbook.xlsx.load(fileBuffer as unknown as ArrayBuffer);
    } catch {
      throw new BadRequestException('文件解析失败，请上传 .xlsx 格式的 Excel 文件（可先下载导入模板）');
    }
    const sheet = workbook.worksheets[0];
    if (!sheet || sheet.rowCount < 2) {
      throw new BadRequestException('Excel 中没有数据行，请按模板填写后重新上传');
    }

    const levels = await this.levelRepo.find();
    const existingTags = await this.tagRepo.find();
    const result: ImportResult = { total: 0, created: 0, updated: 0, skipped: 0, failed: [] };

    // 表头 → 列号映射（按列名关键字识别，容忍列顺序变化）
    const headerMap = new Map<string, number>();
    sheet.getRow(1).eachCell((cell, colNumber) => {
      headerMap.set(String(cell.value ?? '').replace(/[*\s]/g, ''), colNumber);
    });
    const col = (...names: string[]): number | undefined => {
      for (const n of names) {
        if (headerMap.has(n)) return headerMap.get(n);
      }
      return undefined;
    };
    const columns = {
      name: col('姓名'),
      phone: col('手机号', '手机', '电话'),
      gender: col('性别'),
      birthday: col('生日'),
      level: col('等级', '会员等级'),
      tags: col('标签'),
      points: col('积分'),
      balance: col('储值余额', '余额'),
      storeName: col('门店', '所属门店'),
      remark: col('备注'),
    };
    if (!columns.name || !columns.phone) {
      throw new BadRequestException('Excel 缺少「姓名」或「手机号」列，请下载最新导入模板');
    }

    const cellText = (row: ExcelJS.Row, colNumber?: number): string => {
      if (!colNumber) return '';
      const value = row.getCell(colNumber).value;
      if (value === null || value === undefined) return '';
      if (typeof value === 'object' && 'text' in value) return String((value as { text: unknown }).text).trim();
      return String(value).trim();
    };

    for (let rowNumber = 2; rowNumber <= sheet.rowCount; rowNumber++) {
      const row = sheet.getRow(rowNumber);
      const name = cellText(row, columns.name);
      const phone = cellText(row, columns.phone);
      if (!name && !phone) continue; // 整行空白直接忽略
      result.total++;

      if (!name) {
        result.failed.push({ row: rowNumber, phone, reason: '姓名为空' });
        continue;
      }
      if (!/^1[3-9]\d{9}$/.test(phone)) {
        result.failed.push({ row: rowNumber, phone, reason: `手机号格式不正确：${phone || '（空）'}` });
        continue;
      }

      // 等级：按名称/编码匹配
      let levelId: number | undefined;
      const levelText = cellText(row, columns.level);
      if (levelText) {
        const level = levels.find((l) => l.name === levelText || l.code === levelText);
        if (!level) {
          result.failed.push({ row: rowNumber, phone, reason: `等级「${levelText}」不存在` });
          continue;
        }
        levelId = level.id;
      }

      // 标签：按名称匹配，不存在则自动创建（分组「导入」）
      const tagText = cellText(row, columns.tags);
      let tags: Tag[] = [];
      if (tagText) {
        const names = tagText.split(/[、，,/;；\s]+/).filter(Boolean);
        for (const tagName of names) {
          let tag = existingTags.find((t) => t.name === tagName);
          if (!tag) {
            tag = await this.tagRepo.save(this.tagRepo.create({ name: tagName, groupName: '导入' }));
            existingTags.push(tag);
          }
          tags.push(tag);
        }
      }

      const points = Number(cellText(row, columns.points)) || 0;
      const balance = Number(cellText(row, columns.balance)) || 0;
      const birthday = parseDateText(columns.birthday ? row.getCell(columns.birthday).value : undefined);
      const gender = parseGender(columns.gender ? row.getCell(columns.gender).value : undefined);
      const storeName = cellText(row, columns.storeName) || undefined;
      const remark = cellText(row, columns.remark) || undefined;

      const existing = await this.memberRepo.findOne({ where: { phone } });
      if (existing) {
        if (mode === 'skip') {
          result.skipped++;
          continue;
        }
        // 覆盖更新基础资料（不动积分/余额/消费统计，避免覆盖经营数据）
        existing.name = name;
        existing.gender = gender;
        if (birthday) existing.birthday = birthday;
        if (levelId !== undefined) existing.levelId = levelId;
        if (storeName) existing.storeName = storeName;
        if (remark) existing.remark = remark;
        existing.tags = tags;
        await this.memberRepo.save(existing);
        result.updated++;
        continue;
      }

      const member = this.memberRepo.create({
        memberNo: await this.memberService.generateMemberNo(),
        name,
        phone,
        gender,
        birthday,
        levelId,
        points: Math.max(0, Math.floor(points)),
        balance: Math.max(0, balance),
        storeName,
        remark,
        source: '批量导入',
        tags,
      });
      await this.memberRepo.save(member);
      result.created++;
    }

    return result;
  }
}
