# Calculator Microservices System

A distributed calculator system built with NestJS microservices architecture.

## Architecture

- **Gateway** (Port 3001): HTTP API gateway that routes requests to appropriate microservices
- **Sum Service** (Port 3002): Handles addition operations
- **Subtract Service** (Port 3003): Handles subtraction operations  
- **Multiply Service** (Port 3004): Handles multiplication operations
- **Divide Service** (Port 3005): Handles division operations

## Prerequisites

- Node.js v20 or later
- npm v10 or later

## Quick Start

1. **Install dependencies for all services:**

   ```bash
   cd gateway && npm install && cd ..
   cd sum && npm install && cd ..
   cd subtract && npm install && cd ..
   cd multiply && npm install && cd ..
   cd divide && npm install && cd ..
   cd test-client && npm install && cd ..
   ```

2. **Start all services:**

   ```bash
   ./run-calculator.sh
   ```

3. **Test the system:**
   In a new terminal:

   ```bash
   cd test-client
   npm start
   ```

## Manual Setup

If you prefer to start services manually:

1. **Start microservices (in separate terminals):**

   ```bash
   # Terminal 1 - Sum service
   cd sum && npm run start:dev

   # Terminal 2 - Subtract service  
   cd subtract && npm run start:dev

   # Terminal 3 - Multiply service
   cd multiply && npm run start:dev

   # Terminal 4 - Divide service
   cd divide && npm run start:dev

   # Terminal 5 - Gateway
   cd gateway && npm run start:dev
   ```

2. **Test with curl:**

   ```bash
   # Test sum
   curl -X POST http://localhost:3001/calculate \
     -H "Content-Type: application/json" \
     -d '{"operation": "sum", "numbers": [1, 2, 3, 4]}'

   # Test multiply
   curl -X POST http://localhost:3001/calculate \
     -H "Content-Type: application/json" \
     -d '{"operation": "multiply", "numbers": [2, 3, 4]}'

   # Test subtract
   curl -X POST http://localhost:3001/calculate \
     -H "Content-Type: application/json" \
     -d '{"operation": "subtract", "numbers": [10, 3, 2]}'

   # Test divide
   curl -X POST http://localhost:3001/calculate \
     -H "Content-Type: application/json" \
     -d '{"operation": "divide", "numbers": [100, 5, 2]}'
   ```

## API Endpoints

### Gateway (<http://localhost:3001>)

- **GET /** - Health check endpoint
- **POST /calculate** - Perform calculations

#### Calculate Request Format

```json
{
  "operation": "sum|subtract|multiply|divide",
  "numbers": [1, 2, 3, 4]
}
```

#### Calculate Response Format

```json
{
  "result": 10
}
```

## How It Works

1. Client sends HTTP request to Gateway (port 3001)
2. Gateway validates the request and routes it to the appropriate microservice via TCP
3. Microservice performs the calculation and returns the result
4. Gateway returns the result to the client

## Features

- **Microservices Architecture**: Each operation is handled by a separate service
- **TCP Communication**: Inter-service communication via TCP
- **HTTP Gateway**: RESTful API for client access
- **Error Handling**: Proper error handling and validation
- **Retry Logic**: Connection retry logic for resilience
- **Health Checks**: Service health monitoring

## Development

Each service can be developed and deployed independently:

```bash
# Watch mode for development
npm run start:dev

# Build for production
npm run build

# Run tests
npm run test
```

## Troubleshooting

1. **Port conflicts**: Make sure ports 3001-3005 are available
2. **Service connection issues**: Ensure all microservices are running before starting the gateway
3. **Dependencies**: Run `npm install` in each service directory

## Service Details

- **Gateway**: Exposes HTTP endpoints and manages client requests
- **Sum**: Calculates sum of an array of numbers
- **Subtract**: Performs sequential subtraction on an array of numbers  
- **Multiply**: Calculates product of an array of numbers
- **Divide**: Performs sequential division on an array of numbers (with zero-division protection)
