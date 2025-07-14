import { NestFactory } from '@nestjs/core';
import { Transport, MicroserviceOptions } from '@nestjs/microservices';
import { AppModule } from './app.module';
import { AppService } from './app.service';

async function bootstrap() {
  // Create the microservice
  const app = await NestFactory.createMicroservice<MicroserviceOptions>(
    AppModule,
    {
      transport: Transport.TCP,
      options: {
        host: '127.0.0.1',
        port: 3001, // Client microservice listens on a different port
      },
    },
  );

  // Get the AppService to communicate with the server microservice
  const appService = app.get(AppService);
  
  // Send a test message to the server microservice
  await appService.sendSumRequest();

  // Start the client microservice
  await app.listen();
  console.log('Client microservice is listening on port 3001');
}

bootstrap();