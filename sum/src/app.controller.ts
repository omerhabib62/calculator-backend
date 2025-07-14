import { Controller, Get } from '@nestjs/common';
import { AppService } from './app.service';
import { MessagePattern } from '@nestjs/microservices';
import { from, Observable } from 'rxjs';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) { }

  @Get()
  getHello(): string {
    return this.appService.getHello();
  }

  @MessagePattern({ cmd: 'sum' })
  accumulate(data: number[]): number {
    return (data || []).reduce((a, b) => a + b, 0);
  }

  @MessagePattern({ cmd: 'subtract' })
  subtract(data: number[]): number {
    if (data.length === 0) return 0;
    return data.reduce((a, b) => a - b);
  }

  @MessagePattern({ cmd: 'multiply' })
  multiply(data: number[]): number {
    return (data || []).reduce((a, b) => a * b);
  }
  @MessagePattern({ cmd: 'divide' })
  divide(data: number[]): number {
    if (data.length === 0) return 0;
    return data.reduce((a, b) => a / b);
  }
}
