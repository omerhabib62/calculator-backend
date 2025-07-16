import { Injectable } from '@nestjs/common';

@Injectable()
export class AppService {
  divide(data: number[]): number {
    if (!data || data.length === 0)
      throw new Error('Input must be a non-empty array of numbers');
    if (data.slice(1).includes(0))
      throw new Error(' Division by zero is not allowed ');
    return data.reduce((a, b) => a / b);
  }
}
