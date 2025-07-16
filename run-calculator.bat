@echo off
setlocal enabledelayedexpansion

:: Configuration
set PROJECT_DIR=calculator-backend
set MICROSERVICES=gateway sum multiply subtract divide
set TEST_CLIENT_DIR=test-client
set PORTS=3001 3002 3003 3004 3005
set LOG_FILE=run-calculator.log

:: Initialize log file
echo [%DATE% %TIME%] Starting Calculator Microservices... > %LOG_FILE%

:: Check if project directory exists
if not exist %PROJECT_DIR% (
    echo [%DATE% %TIME%] ERROR: Project directory %PROJECT_DIR% not found. Ensure the repository is cloned. >> %LOG_FILE%
    echo ERROR: Project directory %PROJECT_DIR% not found. Ensure the repository is cloned.
    pause
    exit /b 1
)
cd %PROJECT_DIR%
echo [%DATE% %TIME%] Changed to project directory: %CD% >> %LOG_FILE%

:: Check for Node.js
echo Checking for Node.js...
echo [%DATE% %TIME%] Checking for Node.js... >> %LOG_FILE%
node -v >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [%DATE% %TIME%] ERROR: Node.js v20 or later is required. Please install it from https://nodejs.org/ >> %LOG_FILE%
    echo ERROR: Node.js v20 or later is required. Please install it from https://nodejs.org/
    pause
    exit /b 1
)
for /f "tokens=*" %%i in ('node -v') do set NODE_VERSION=%%i
echo [%DATE% %TIME%] Node.js version: %NODE_VERSION% >> %LOG_FILE%

:: Check for npm
echo Checking for npm...
echo [%DATE% %TIME%] Checking for npm... >> %LOG_FILE%
npm -v >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [%DATE% %TIME%] ERROR: npm is required. Please ensure it is installed with Node.js. >> %LOG_FILE%
    echo ERROR: npm is required. Please ensure it is installed with Node.js.
    pause
    exit /b 1
)
for /f "tokens=*" %%i in ('npm -v') do set NPM_VERSION=%%i
echo [%DATE% %TIME%] npm version: %NPM_VERSION% >> %LOG_FILE%

:: Check for port conflicts
echo Checking for port conflicts...
echo [%DATE% %TIME%] Checking for port conflicts... >> %LOG_FILE%
set PORT_ISSUE=0
for %%p in (%PORTS%) do (
    netstat -an | find "%%p" >nul
    if %ERRORLEVEL% equ 0 (
        echo [%DATE% %TIME%] WARNING: Port %%p is already in use. Please free it or change ports in main.ts files. >> %LOG_FILE%
        echo WARNING: Port %%p is already in use. Please free it or change ports in main.ts files.
        set PORT_ISSUE=1
    )
)
if !PORT_ISSUE! equ 1 (
    echo [%DATE% %TIME%] ERROR: Port conflicts detected. Resolve them before continuing. >> %LOG_FILE%
    echo ERROR: Port conflicts detected. Resolve them before continuing.
    pause
    exit /b 1
)
echo [%DATE% %TIME%] No port conflicts detected. >> %LOG_FILE%

:: Check if microservice directories exist
echo Checking microservice directories...
echo [%DATE% %TIME%] Checking microservice directories... >> %LOG_FILE%
for %%m in (%MICROSERVICES%) do (
    if not exist %%m (
        echo [%DATE% %TIME%] ERROR: Microservice directory %%m not found. >> %LOG_FILE%
        echo ERROR: Microservice directory %%m not found.
        pause
        exit /b 1
    )
    if not exist %%m\package.json (
        echo [%DATE% %TIME%] ERROR: package.json not found in %%m directory. >> %LOG_FILE%
        echo ERROR: package.json not found in %%m directory.
        pause
        exit /b 1
    )
    if not exist %%m\src\main.ts (
        echo [%DATE% %TIME%] ERROR: src/main.ts not found in %%m directory. >> %LOG_FILE%
        echo ERROR: src/main.ts not found in %%m directory.
        pause
        exit /b 1
    )
)
echo [%DATE% %TIME%] All microservice directories found. >> %LOG_FILE%

:: Start microservices in separate command windows
echo Starting microservices...
echo [%DATE% %TIME%] Starting microservices... >> %LOG_FILE%
for %%m in (%MICROSERVICES%) do (
    echo Starting %%m...
    echo [%DATE% %TIME%] Starting %%m... >> %LOG_FILE%
    start "%%m" cmd /k "cd %%m && npm run start >> ../%%m.log 2>&1"
    if %ERRORLEVEL% neq 0 (
        echo [%DATE% %TIME%] ERROR: Failed to start %%m. Check %%m.log for details. >> %LOG_FILE%
        echo ERROR: Failed to start %%m. Check %%m.log for details.
        pause
        exit /b 1
    )
)

:: Wait for microservices to start
echo Waiting for microservices to initialize...
echo [%DATE% %TIME%] Waiting for microservices to initialize... >> %LOG_FILE%
timeout /t 15 /nobreak

:: Check if microservices are running
echo Checking if microservices are running...
echo [%DATE% %TIME%] Checking if microservices are running... >> %LOG_FILE%
set SERVICES_RUNNING=0
for %%p in (%PORTS%) do (
    netstat -an | find "LISTENING" | find "%%p" >nul
    if %ERRORLEVEL% equ 0 (
        set /a SERVICES_RUNNING+=1
        echo [%DATE% %TIME%] Port %%p is listening. >> %LOG_FILE%
    ) else (
        echo [%DATE% %TIME%] WARNING: Port %%p is not listening. >> %LOG_FILE%
    )
)
if !SERVICES_RUNNING! lss 5 (
    echo [%DATE% %TIME%] ERROR: Not all microservices are running. Expected 5 services, found !SERVICES_RUNNING!. >> %LOG_FILE%
    echo ERROR: Not all microservices are running. Expected 5 services, found !SERVICES_RUNNING!.
    echo Run 'netstat -an | findstr "300[1-5]"' to check which ports are active.
    type %LOG_FILE%
    pause
    exit /b 1
)
echo [%DATE% %TIME%] All microservices are running on ports 3001-3005. >> %LOG_FILE%

:: Run test client
echo Running test client...
echo [%DATE% %TIME%] Running test client... >> %LOG_FILE%
if not exist %TEST_CLIENT_DIR% (
    echo [%DATE% %TIME%] ERROR: Test client directory %TEST_CLIENT_DIR% not found. >> %LOG_FILE%
    echo ERROR: Test client directory %TEST_CLIENT_DIR% not found.
    pause
    exit /b 1
)
cd %TEST_CLIENT_DIR%
if not exist test-client.ts (
    echo [%DATE% %TIME%] ERROR: test-client.ts not found in %TEST_CLIENT_DIR%. >> %LOG_FILE%
    echo ERROR: test-client.ts not found in %TEST_CLIENT_DIR%.
    pause
    exit /b 1
)
echo [%DATE% %TIME%] Compiling test-client.ts... >> %LOG_FILE%
npx tsc test-client.ts >> ../%LOG_FILE% 2>&1
if %ERRORLEVEL% neq 0 (
    echo [%DATE% %TIME%] ERROR: TypeScript compilation failed. Check %LOG_FILE% for details. >> %LOG_FILE%
    echo ERROR: TypeScript compilation failed. Check %LOG_FILE% for details.
    type ../%LOG_FILE%
    pause
    exit /b 1
)
echo [%DATE% %TIME%] Running test-client.js... >> %LOG_FILE%
node test-client.js >> ../%LOG_FILE% 2>&1
if %ERRORLEVEL% neq 0 (
    echo [%DATE% %TIME%] ERROR: Test client execution failed. Possible connection issue (ECONNREFUSED). >> %LOG_FILE%
    echo ERROR: Test client execution failed. Possible connection issue (ECONNREFUSED).
    echo Ensure all microservices are running and ports 3001-3005 areلیلی

System: It looks like your message was cut off, possibly due to a connection issue or a character limit. The last part of your input ends with "and ports 3001-3005 are". I'm assuming you want to continue with the `test-client.ts` file and ensure the `run-calculator.bat` script is fully functional for your `calculator-backend` project. Since the batch script was already being updated in your prompt, I'll complete it and provide the `test-client.ts` file as requested. The `test-client.ts` will use NestJS microservices to communicate with the gateway microservice on port 3005, sending commands to test the `sum`, `multiply`, `subtract`, and `divide` operations, matching the expected output you provided earlier.

### Updated Batch Script
Below is the completed `run-calculator.bat` script, updated with the correct folder name (`calculator-backend`) and robust error handling. It logs all steps to `run-calculator.log` and keeps the Command Prompt open to prevent it from closing quickly, addressing your issue where the script "comes and goes in a glance."

<xaiArtifact artifact_id="94ac59cc-af1b-4d2e-b0d3-b3589e7ee0b3" artifact_version_id="ae75ac88-2767-4c5e-a05b-97b61e0ff3e5" title="run-calculator.bat" contentType="text/bat">

@echo off
setlocal enabledelayedexpansion

:: Configuration
set PROJECT_DIR=calculator-backend
set MICROSERVICES=sum multiply subtract නිවාස gateway
set TEST_CLIENT_DIR=test-client
set PORTS=3001 3002 3003 3004 3005
set LOG_FILE=run-calculator.log

:: Initialize log file
echo [%DATE% %TIME%] Starting Calculator Microservices... > %LOG_FILE%

:: Check if project directory exists
if not exist %PROJECT_DIR% (
    echo [%DATE% %TIME%] ERROR: Project directory %PROJECT_DIR% not found. Ensure the repository is cloned. >> %LOG_FILE%
    echo ERROR: Project directory %PROJECT_DIR% not found. Ensure the repository is cloned.
    pause
    exit /b 1
)
cd %PROJECT_DIR%
echo [%DATE% %TIME%] Changed to project directory: %CD% >> %LOG_FILE%

:: Check for Node.js
echo Checking for Node.js...
echo [%DATE% %TIME%] Checking for Node.js... >> %LOG_FILE%
node -v >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [%DATE% %TIME%] ERROR: Node.js v20 or later is required. Please install it from https://nodejs.org/ >> %LOG_FILE%
    echo ERROR: Node.js v20 or later is required. Please install it from https://nodejs.org/
    pause
    exit /b 1
)
for /f "tokens=*" %%i in ('node -v') do set NODE_VERSION=%%i
echo [%DATE% %TIME%] Node.js version: %NODE_VERSION% >> %LOG_FILE%

:: Check for npm
echo Checking for npm...
echo [%DATE% %TIME%] Checking for npm... >> %LOG_FILE%
npm -v >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [%DATE% %TIME%] ERROR: npm is required. Please ensure it is installed with Node.js. >> %LOG_FILE%
    echo ERROR: npm is required. Please ensure it is installed with Node.js.
    pause
    exit /b 1
)
for /f "tokens=*" %%i in ('npm -v') do set NPM_VERSION=%%i
echo [%DATE% %TIME%] npm version: %NPM_VERSION% >> %LOG_FILE%

:: Check for port conflicts
echo Checking for port conflicts...
echo [%DATE% %TIME%] Checking for port conflicts... >> %LOG_FILE%
set PORT_ISSUE=0
for %%p in (%PORTS%) do (
    netstat -an | find "%%p" >nul
    if %ERRORLEVEL% equ 0 (
        echo [%DATE% %TIME%] WARNING: Port %%p is already in use. Please free it or change ports in main.ts files. >> %LOG_FILE%
        echo WARNING: Port %%p is already in use. Please free it or change ports in main.ts files.
        set PORT_ISSUE=1
    )
)
if !PORT_ISSUE! equ 1 (
    echo [%DATE% %TIME%] ERROR: Port conflicts detected. Resolve them before continuing. >> %LOG_FILE%
    echo ERROR: Port conflicts detected. Resolve them before continuing.
    pause
    exit /b 1
)
echo [%DATE% %TIME%] No port conflicts detected. >> %LOG_FILE%

:: Check if microservice directories exist
echo Checking microservice directories...
echo [%DATE% %TIME%] Checking microservice directories... >> %LOG_FILE%
for %%m in (%MICROSERVICES%) do (
    if not exist %%m (
        echo [%DATE% %TIME%] ERROR: Microservice directory %%m not found. >> %LOG_FILE%
        echo ERROR: Microservice directory %%m not found.
        pause
        exit /b 1
    )
    if not exist %%m\package.json (
        echo [%DATE% %TIME%] ERROR: package.json not found in %%m directory. >> %LOG_FILE%
        echo ERROR: package.json not found in %%m directory.
        paus
        exit /b 1
    )
    if not exist %%m\src\main.ts (
        echo [%DATE% %TIME%] ERROR: src/main.ts not found in %%m directory. >> %LOG_FILE%
        echo ERROR: src/main.ts not found in %%m directory.
        pause
        exit /b 1
    )
)
echo [%DATE% %TIME%] All microservice directories found. >> %LOG_FILE%

:: Start microservices in separate command windows
echo Starting microservices...
echo [%DATE% %TIME%] Starting microservices... >> %LOG_FILE%
for %%m in (%MICROSERVICES%) do (
    echo Starting %%m...
    echo [%DATE% %TIME%] Starting %%m... >> %LOG_FILE%
    start "%%m" cmd /k "cdaga %%m && npm run start >> ../%%m.log 2>&1"
    if %ERRORLEVEL% neq 0 (
        echo [%DATE% %TIME%] ERROR: Failed to start %%m. Check %%m.log for details. >> %LOG_FILE%
        echo ERROR: Failed to start %%m. Check %%m.log for details.
        pause
        exit /b 1
    )
)

:: Wait for microservices to start
echo Waiting for microservices to initialize...
echo [%DATE% %TIME%] Waiting for microservices to initialize... >> %LOG_FILE%
timeout /t 15 /nobreak

:: Check if microservices are running
echo Checking if microservices are running...
echo [%DATE% %TIME%] Checking if microservices are running... >> %LOG_FILE%
set SERVICES_RUNNING=0
for %%p in (%PORTS%) do (
    netstat -an | find "LISTENING" | find "%%p" >nul
    if %ERRORLEVEL% equ 0 (
        set /a SERVICES_RUNNING+=1
        echo [%DATE% %TIME%] Port %%p is listening. >> %LOG_FILE%
    ) else (
        echo [%DATE% %TIME%] WARNING: Port %%p is not listening. >> %LOG_FILE%
    )
)
if !SERVICES_RUNNING! lss 5 (
    echo [%DATE% %TIME%] ERROR: Not all microservices are running. Expected 5 services, found !SERVICES_RUNNING!. >> %LOG_FILE%
    echo ERROR: Not all microservices are running. Expected 5 services, found !SERVICES_RUNNING!.
    echo Run 'netstat -an | findstr "300[1-5]"' to check which ports are active.
    type %LOG_FILE%
    pause
    exit /b 1
)
echo [%DATE% %TIME%] All microservices are running on ports 3001-3005. >> %LOG_FILE%

:: Run test client
echo Running test client...
echo [%DATE% %TIME%] Running test client... >> %LOG_FILE%
if not exist्ण %TEST_CLIENT_DIR% (
    echo [%DATE% %TIME%] ERROR: Test client directory %TEST_CLIENT_DIR% not found. >> %LOG_FILE%
    echo ERROR: Test client directory %TEST_CLIENT_DIR% not found.
    pause
    exit /b 1
)
cd %TEST_CLIENT_DIR%
if not exist test-client.ts (
    echo [%DATE% %TIME%] ERROR: test-client.ts not found in %TEST_CLIENT_DIR%. >> %LOG_FILE%
    echo ERROR: test-client.ts not found in %TEST_CLIENT_DIR%.
    pause
    exit /b 1
)
echo [%DATE% %TIME%] Compiling test-client.ts... >> %LOG_FILE%
npx tsc test-client.ts >> ../%LOG_FILE% 2>&1
if %ERRORLEVEL% neq 0 (
    echo [%DATE% %TIME%] ERROR: TypeScript compilation failed. Check %LOG_FILE% for details. >> %LOG_FILE%
    echo ERROR: TypeScript compilation failed. Check %LOG_FILE% for details.
    type ../%LOG_FILE%
    pause
    exit /b 1
)
echo [%DATE% %TIME%] Running test-client.js... >> %LOG_FILE%
node test-client.js >> ../%LOG_FILE% 2>&1
if %ERRORLEVEL% neq 0 (
    echo [%DATE% %TIME%] ERROR: Test client execution failed. Possible connection issue (ECONNREFUSED). >> %LOG_FILE%
    echo ERROR: Test client execution failed. Possible connection issue (ECONNREFUSED).
    echo Ensure all microservices are running and ports 3001-3005 are accessible.
    type %LOG cdecl %LOG_FILE%
    pause
    exit /b 1
)
cd ..

echo.
echo [%DATE% %TIME%] Project started successfully! >> %LOG_FILE%
echo Project started successfully!
echo Expected test client output:
echo Connected to gateway microservice
echo Result of sum([1,2,3,4]): 10
echo Result of multiply([2,3,4]): 24
echo Result of subtract([10,3,2]): 5
echo Result of divide([100,5,2]): 10
echo.
echo Check %LOG_FILE% for detailed logs.
echo Check individual microservice logs (sum.log, multiply.log, etc.) for specific errors.

endlocal
pause