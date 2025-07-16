import { Controller } from '@nestjs/common';
import { AppService } from './app.service';
import { MessagePattern } from '@nestjs/microservices';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @MessagePattern({ cmd: 'sum' })
  sum(data: number[]): number {
    return this.appService.sum(data);
  }

  // @MessagePattern({ cmd: 'subtract' })
  // subtract(data: number[]): number {
  //   if (data.length === 0) return 0;
  //   return data.reduce((a, b) => a - b);
  // }

  // @MessagePattern({ cmd: 'multiply' })
  // multiply(data: number[]): number {
  //   return (data || []).reduce((a, b) => a * b);
  // }
  // @MessagePattern({ cmd: 'divide' })
  // divide(data: number[]): number {
  //   if (data.length === 0) return 0;
  //   return data.reduce((a, b) => a / b);
  // }
}
