import axios from 'axios';

async function runTests() {
  const gatewayUrl = 'http://localhost:3001';

  try {
    console.log('Testing Calculator Gateway...');

    // Test sum operation
    const sumResponse = await axios.post(`${gatewayUrl}/calculate`, {
      operation: 'sum',
      numbers: [1, 2, 3, 4]
    });
    console.log(`Result of sum([1,2,3,4]): ${sumResponse.data.result}`);

    // Test multiply operation
    const multiplyResponse = await axios.post(`${gatewayUrl}/calculate`, {
      operation: 'multiply',
      numbers: [2, 3, 4]
    });
    console.log(`Result of multiply([2,3,4]): ${multiplyResponse.data.result}`);

    // Test subtract operation
    const subtractResponse = await axios.post(`${gatewayUrl}/calculate`, {
      operation: 'subtract',
      numbers: [10, 3, 2]
    });
    console.log(`Result of subtract([10,3,2]): ${subtractResponse.data.result}`);

    // Test divide operation
    const divideResponse = await axios.post(`${gatewayUrl}/calculate`, {
      operation: 'divide',
      numbers: [100, 5, 2]
    });
    console.log(`Result of divide([100,5,2]): ${divideResponse.data.result}`);

    // Test the health endpoint
    const healthResponse = await axios.get(gatewayUrl);
    console.log(`Gateway health check: ${healthResponse.data}`);

  } catch (error: any) {
    console.error('Error during test execution:', error.response?.data || error.message);
  }
}

runTests().catch(console.error);