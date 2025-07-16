import { Injectable } from '@nestjs/common';

@Injectable()
export class AppService {
  multiply(data: number[]): number {
    if (!data || data.length === 0)
      throw new Error('Input must be a non-empty array of numbers');
    return data.reduce((a, b) => a * b, 1);
  }
}
