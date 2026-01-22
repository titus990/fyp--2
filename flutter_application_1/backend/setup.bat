@echo off
echo ================================
echo Stripe Backend Setup Script
echo ================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python 3.8+ from https://www.python.org/downloads/
    pause
    exit /b 1
)

echo [1/4] Python found!
echo.

REM Navigate to backend directory
cd /d "%~dp0"

REM Check if .env file exists
if not exist .env (
    echo [2/4] Creating .env file from template...
    copy .env.example .env
    echo.
    echo IMPORTANT: Please edit the .env file and add your Stripe secret key!
    echo           Your secret key is in lib\consts.dart
    echo.
) else (
    echo [2/4] .env file already exists
    echo.
)

REM Install dependencies
echo [3/4] Installing Python dependencies...
pip install -r requirements.txt
if %errorlevel% neq 0 (
    echo ERROR: Failed to install dependencies
    pause
    exit /b 1
)
echo.

echo [4/4] Setup complete!
echo.
echo ================================
echo Next Steps:
echo ================================
echo 1. Edit the .env file and add your Stripe secret key
echo 2. Run: python stripe_backend.py
echo 3. The server will start on http://localhost:5000
echo.
echo Your Stripe secret key (from Flutter code):
echo sk_test_51SOoYlPzFOvAOgSvHPQ4YKu9suVSELaZM0gkYrMdl6S9bA7QRqFmJvO8KIJTPcl7BorYwBCDznQouOq6WLe8AxMR00z9dccLew
echo.
pause
