import { Body, Controller, Delete, Get, Param, ParseIntPipe, Post, Put } from '@nestjs/common';
import { CreateLevelDto, UpdateLevelDto } from './dto/level.dto';
import { LevelService } from './level.service';

@Controller('levels')
export class LevelController {
  constructor(private readonly levelService: LevelService) {}

  @Get()
  findAll() {
    return this.levelService.findAll();
  }

  @Post()
  create(@Body() dto: CreateLevelDto) {
    return this.levelService.create(dto);
  }

  @Put(':id')
  update(@Param('id', ParseIntPipe) id: number, @Body() dto: UpdateLevelDto) {
    return this.levelService.update(id, dto);
  }

  @Delete(':id')
  remove(@Param('id', ParseIntPipe) id: number) {
    return this.levelService.remove(id);
  }
}
