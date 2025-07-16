import { Injectable, OnModuleDestroy, OnModuleInit } from '@nestjs/common';
import {
  ClientProxy,
  ClientProxyFactory,
  Transport,
} from '@nestjs/microservices';

@Injectable()
export class AppService implements OnModuleInit, OnModuleDestroy {
  private clients: { [key: string]: ClientProxy } = {};

  constructor() {
    // Initialize the client proxy to connect to the server microservice
    const services = [
      {
        operation: 'sum',
        port: 3002,
      },
      {
        operation: 'subtract',
        port: 3003,
      },
      {
        operation: 'multiply',
        port: 3004,
      },
      {
        operation: 'divide',
        port: 3005,
      },
    ];
    services.forEach(({ operation, port }) => {
      this.clients[operation] = ClientProxyFactory.create({
        transport: Transport.TCP,
        options: {
          host: '127.0.0.1',
          port: port,
        },
      });
    });
  }

  async onModuleInit() {
    await Promise.all(
      Object.keys(this.clients).map((operation) =>
        this.connectWithRetry(operation, this.clients[operation]),
      ),
    );
    console.log('All clients connected successfully');
  }

  async connectWithRetry(operation: string, client: ClientProxy) {
    let retries = 5;
    while (retries > 0) {
      try {
        await client.connect();
        console.log(`Connected to ${operation} microservice`);
        return;
      } catch (error) {
        console.warn(
          `Connection to ${operation} failed, retrying... (${retries} attempts left)`,
        );
        retries--;
        if (retries === 0) throw error;
        await new Promise((resolve) => setTimeout(resolve, 1000));
      }
    }
  }

  async connectToProcessingServices() {
    console.log('Connecting to processing services...');
    await Promise.all(
      Object.values(this.clients).map((client) => client.connect()),
    );
    console.log('All processing services connected successfully');
  }

  async calculate(operation: string, data: number[]): Promise<number> {
    const client = this.clients[operation];
    if (!client) {
      throw new Error(`Unsupported operation: ${operation}`);
    }
    try {
      const pattern = { cmd: operation };
      const payload = data;
      const result = await client.send<number>(pattern, payload).toPromise();
      console.log(`Result from microservice for ${operation}:`, result);
      return result;
    } catch (error: any) {
      const errorMessage =
        error && typeof error === 'object' && 'message' in error
          ? (error as { message: string }).message
          : String(error);
      console.error(
        'Failed to communicate with server microservice:',
        errorMessage,
      );
      throw new Error(`Calculation failed for ${operation}: ${errorMessage}`);
    }
  }

  onModuleDestroy() {
    for (const operation in this.clients) {
      if (this.clients[operation]) {
        this.clients[operation].close();
        console.log(`Connection to ${operation} microservice closed`);
      }
    }
  }
}
