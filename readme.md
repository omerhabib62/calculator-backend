# Calculator Microservices System

This repository contains a calculator system implemented using NestJS microservices. It consists of four processing microservices (`sum`, `multiply`, `subtract`, `divide`) and a gateway microservice that routes client requests to the appropriate processing microservice.

## Project Structure

```
calculator/
├── divide/                 # Divide microservice (port 3005)
├── multiply/               # Multiply microservice (port 3003)
├── subtract/               # Subtract microservice (port 3004)
├── sum/                    # Sum microservice (port 3002)
├── gateway/                # Gateway microservice (port 3001)
├── test-client/            # Test client script
├── docs/                   # Documentation (LaTeX and PDF)
│   ├── calculator-microservices-guide.tex
│   ├── generated-pdf.pdf
├── .gitignore
├── README.md
```

## Prerequisites

- Node.js v20 or later
- npm
- TypeScript
- LaTeX distribution (for PDF compilation)

## Setup Instructions

1. **Clone the Repository**:
   ```bash
   git clone <repository-url>
   cd calculator
   ```

2. **Install Dependencies**:
   For each microservice folder (`divide`, `multiply`, `subtract`, `sum`, `gateway`):
   ```bash
   cd <microservice-folder>
   npm install
   ```
   For the test client:
   ```bash
   cd test-client
   npm install
   ```

3. **Start Microservices**:
   Start each processing microservice in a separate terminal:
   ```bash
   cd sum && npm run start
   cd multiply && npm run start
   cd subtract && npm run start
   cd divide && npm run start
   ```
   Start the gateway:
   ```bash
   cd gateway && npm run start
   ```

4. **Run the Test Client**:
   ```bash
   cd test-client
   npx tsc test-client.ts
   node test-client.js
   ```

   Expected output:
   ```
   Connected to gateway microservice
   Result of sum([1,2,3,4]): 10
   Result of multiply([2,3,4]): 24
   Result of subtract([10,3,2]): 5
   Result of divide([100,5,2]): 10
   ```

5. **View Documentation**:
   - The PDF guide is located at `docs/generated-pdf.pdf`.
   - To recompile the LaTeX source:
     ```bash
     cd docs
     latexmk -pdf calculator-microservices-guide.tex
     ```

## Troubleshooting

- **ECONNREFUSED**: Ensure all microservices are running on their respective ports (3001–3005). Check with:
  ```bash
  netstat -tuln | grep 300[1-5]
  ```
- **Port Conflicts**: Change ports in `main.ts` files if needed.
- **Dependencies**: Ensure `@nestjs/core`, `@nestjs/microservices`, and `rxjs` are installed in each microservice.
- **Firewall**: Allow ports 3001–3005:
  ```bash
  sudo ufw allow 3001:3005/tcp
  ```

## Next Steps

- Add input validation using `@nestjs/class-validator`.
- Implement a logging microservice with `@EventPattern`.
- Switch to Redis or NATS for communication.
- Write unit tests with `@nestjs/testing`.