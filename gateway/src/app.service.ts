import { Injectable, OnModuleInit } from '@nestjs/common';
import { ClientProxy, ClientProxyFactory, Transport } from '@nestjs/microservices';

@Injectable()
export class AppService implements OnModuleInit {
  private client: ClientProxy;

  constructor() {
    // Initialize the client proxy to connect to the server microservice
    this.client = ClientProxyFactory.create({
      transport: Transport.TCP,
      options: {
        host: '127.0.0.1',
        port: 3002, // Server microservice port
      },
    });
  }

  async onModuleInit() {
    // Optionally connect when the module initializes
    await this.connectWithRetry();
  }

  async connectWithRetry() {
    let retries = 5;
    while (retries > 0) {
      try {
        await this.client.connect();
        console.log('Connected to server microservice');
        return;
      } catch (error) {
        console.warn(`Connection failed, retrying... (${retries} attempts left)`);
        retries--;
        if (retries === 0) throw error;
        await new Promise(resolve => setTimeout(resolve, 1000));
      }
    }
  }

  async sendSumRequest() {
    try {
      const pattern = { cmd: 'sum' };
      const payload = [1, 2, 3, 4];
      const result = await this.client.send<number>(pattern, payload).toPromise();
      console.log('Result from microservice for sum:', result); // Should print 10
    } catch (error) {
      console.error('Failed to communicate with server microservice:', error.message);
    }
  }

  async onModuleDestroy() {
    if (this.client) {
      this.client.close();
      console.log('Client connection closed');
    }
  }
}