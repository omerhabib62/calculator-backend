import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  // Create the HTTP application (gateway)
  const app = await NestFactory.create(AppModule);

  // Enable CORS for frontend integration
  app.enableCors();

  // Start the HTTP server
  await app.listen(3001);
  console.log('Calculator Gateway is running on http://localhost:3001');
}

bootstrap().catch(console.error);
