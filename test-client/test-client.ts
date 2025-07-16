import { ClientTCP } from '@nestjs/microservices';
import { firstValueFrom } from 'rxjs';

async function runTests() {
  const client = new ClientTCP({
    host: 'localhost',
    port: 3005,
  });

  try {
    console.log('Connected to gateway microservice');

    // Test sum operation
    const sumResult = await firstValueFrom(
      client.send({ cmd: 'sum' }, [1, 2, 3, 4])
    );
    console.log(`Result of sum([1,2,3,4]): ${sumResult}`);

    // Test multiply operation
    const multiplyResult = await firstValueFrom(
      client.send({ cmd: 'multiply' }, [2, 3, 4])
    );
    console.log(`Result of multiply([2,3,4]): ${multiplyResult}`);

    // Test subtract operation
    const subtractResult = await firstValueFrom(
      client.send({ cmd: 'subtract' }, [10, 3, 2])
    );
    console.log(`Result of subtract([10,3,2]): ${subtractResult}`);

    // Test divide operation
    const divideResult = await firstValueFrom(
      client.send({ cmd: 'divide' }, [100, 5, 2])
    );
    console.log(`Result of divide([100,5,2]): ${divideResult}`);
  } catch (error) {
    console.error('Error during test execution:', error);
  } finally {
    await client.close();
  }
}

runTests().catch(console.error);