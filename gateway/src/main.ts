import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  // Create the HTTP application (gateway)
  const app = await NestFactory.create(AppModule);

  // Enable CORS for frontend integration
  app.enableCors({
    origin: ['http://localhost:3000', 'https://your-username.github.io'],
    credentials: true,
  });

  // Start the HTTP server
  await app.listen(3001);
  console.log('Calculator Gateway is running on  port 3001');
}

bootstrap().catch(console.error);
