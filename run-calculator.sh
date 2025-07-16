#!/bin/bash

# Calculator Microservices Startup Script

echo "Starting Calculator Microservices..."

# Function to check if a port is available
check_port() {
    local port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null; then
        echo "Port $port is already in use. Please stop the process using this port and try again."
        return 1
    fi
    return 0
}

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "Node.js is not installed. Please install Node.js v20 or later."
    exit 1
fi

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "npm is not installed. Please install npm."
    exit 1
fi

echo "Node.js version: $(node -v)"
echo "npm version: $(npm -v)"

# Check ports
echo "Checking port availability..."
for port in 3001 3002 3003 3004 3005; do
    if ! check_port $port; then
        exit 1
    fi
done

# Function to install dependencies if needed
install_deps() {
    local service=$1
    echo "Installing dependencies for $service..."
    cd $service
    if [ ! -d "node_modules" ]; then
        npm install
    fi
    cd ..
}

# Install dependencies for all services
echo "Installing dependencies..."
for service in gateway sum subtract multiply divide; do
    install_deps $service
done

# Install test client dependencies
cd test-client
if [ ! -d "node_modules" ]; then
    npm install
fi
cd ..

# Start microservices in background
echo "Starting microservices..."

# Start sum service (port 3002)
echo "Starting sum service on port 3002..."
cd sum
npm run start:dev &
SUM_PID=$!
cd ..
sleep 2

# Start subtract service (port 3003)
echo "Starting subtract service on port 3003..."
cd subtract
npm run start:dev &
SUBTRACT_PID=$!
cd ..
sleep 2

# Start multiply service (port 3004)
echo "Starting multiply service on port 3004..."
cd multiply
npm run start:dev &
MULTIPLY_PID=$!
cd ..
sleep 2

# Start divide service (port 3005)
echo "Starting divide service on port 3005..."
cd divide
npm run start:dev &
DIVIDE_PID=$!
cd ..
sleep 2

# Start gateway (port 3001)
echo "Starting gateway on port 3001..."
cd gateway
npm run start:dev &
GATEWAY_PID=$!
cd ..
sleep 5

echo "All services started!"
echo "Gateway: http://localhost:3001"
echo "Sum service: localhost:3002"
echo "Subtract service: localhost:3003"
echo "Multiply service: localhost:3004"
echo "Divide service: localhost:3005"
echo ""
echo "You can test the system by running:"
echo "cd test-client && npm start"
echo ""
echo "Press Ctrl+C to stop all services"

# Function to cleanup on exit
cleanup() {
    echo "Stopping all services..."
    kill $GATEWAY_PID $SUM_PID $SUBTRACT_PID $MULTIPLY_PID $DIVIDE_PID 2>/dev/null
    exit 0
}

# Set trap to cleanup on exit
trap cleanup INT TERM

# Wait for any process to exit
wait
