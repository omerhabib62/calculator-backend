import { Controller, Post, Body, Get } from '@nestjs/common';
import { AppService } from './app.service';

interface CalculateDto {
  operation: string;
  numbers: number[];
}

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  getHello(): string {
    return 'Calculator Gateway is running!';
  }

  @Post('calculate')
  async calculate(
    @Body() calculateDto: CalculateDto,
  ): Promise<{ result: number }> {
    const result = await this.appService.calculate(
      calculateDto.operation,
      calculateDto.numbers,
    );
    return { result };
  }
}
