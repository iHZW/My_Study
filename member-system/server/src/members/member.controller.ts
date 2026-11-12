import {
  Body,
  Controller,
  Delete,
  Get,
  Header,
  Param,
  ParseIntPipe,
  Post,
  Put,
  Query,
  StreamableFile,
  UploadedFile,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import {
  AdjustPointsDto,
  BatchTagDto,
  CreateMemberDto,
  MemberQueryDto,
  RechargeDto,
  UpdateMemberDto,
} from './dto/member.dto';
import { MemberExcelService } from './member-excel.service';
import { MemberService } from './member.service';

const XLSX_MIME = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

/** 生成带中文文件名的下载头 */
function attachment(filename: string): string {
  return `attachment; filename="file.xlsx"; filename*=UTF-8''${encodeURIComponent(filename)}`;
}

@Controller('members')
export class MemberController {
  constructor(
    private readonly memberService: MemberService,
    private readonly excelService: MemberExcelService,
  ) {}

  /** 导出当前筛选条件下的会员列表（注意：需声明在 /:id 之前） */
  @Get('export')
  @Header('Content-Type', XLSX_MIME)
  async exportExcel(@Query() query: MemberQueryDto) {
    const buffer = await this.excelService.exportMembers(query);
    return new StreamableFile(buffer, {
      type: XLSX_MIME,
      disposition: attachment(`会员列表_${new Date().toISOString().slice(0, 10)}.xlsx`),
    });
  }

  /** 下载批量导入模板 */
  @Get('import-template')
  @Header('Content-Type', XLSX_MIME)
  async downloadTemplate() {
    const buffer = await this.excelService.exportTemplate();
    return new StreamableFile(buffer, {
      type: XLSX_MIME,
      disposition: attachment('会员导入模板.xlsx'),
    });
  }

  /** 批量导入：multipart/form-data，file=xlsx 文件，mode=skip|update */
  @Post('import')
  @UseInterceptors(FileInterceptor('file'))
  async importExcel(
    @UploadedFile() file: Express.Multer.File,
    @Body('mode') mode?: string,
  ) {
    return this.excelService.importMembers(file?.buffer, mode === 'update' ? 'update' : 'skip');
  }

  @Get()
  findAll(@Query() query: MemberQueryDto) {
    return this.memberService.findAll(query);
  }

  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number) {
    return this.memberService.findOne(id);
  }

  @Post()
  create(@Body() dto: CreateMemberDto) {
    return this.memberService.create(dto);
  }

  @Put(':id')
  update(@Param('id', ParseIntPipe) id: number, @Body() dto: UpdateMemberDto) {
    return this.memberService.update(id, dto);
  }

  @Delete(':id')
  remove(@Param('id', ParseIntPipe) id: number) {
    return this.memberService.remove(id);
  }

  /** 手动调整积分 */
  @Post(':id/points')
  adjustPoints(@Param('id', ParseIntPipe) id: number, @Body() dto: AdjustPointsDto) {
    return this.memberService.adjustPoints(id, dto);
  }

  /** 储值充值 */
  @Post(':id/recharge')
  recharge(@Param('id', ParseIntPipe) id: number, @Body() dto: RechargeDto) {
    return this.memberService.recharge(id, dto);
  }

  /** 批量打标签 */
  @Post('batch-tag')
  batchTag(@Body() dto: BatchTagDto) {
    return this.memberService.batchTag(dto);
  }
}
