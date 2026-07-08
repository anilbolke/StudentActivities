@echo off
REM ==========================================
REM Execute SQL Database Setup Only
REM ==========================================

setlocal enabledelayedexpansion
cls

echo.
echo ==========================================
echo   DATABASE SETUP - SCHOOL ADMIN SYSTEM
echo ==========================================
echo.

set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

set "SQL_FILE=%SCRIPT_DIR%SCHOOL_ADMIN_SETUP.sql"

REM MySQL Credentials - UPDATE THESE IF NEEDED
set "MYSQL_HOST=localhost"
set "MYSQL_USER=root"
set "MYSQL_PASS=root"
set "MYSQL_DB=exam_db"

REM Check if SQL file exists
if not exist "%SQL_FILE%" (
    echo ERROR: SQL file not found: %SQL_FILE%
    echo.
    pause
    exit /b 1
)

echo Connecting to MySQL...
echo   Host:     %MYSQL_HOST%
echo   User:     %MYSQL_USER%
echo   Database: %MYSQL_DB%
echo.

REM Execute SQL file
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASS% %MYSQL_DB% < "%SQL_FILE%"

if %errorlevel% equ 0 (
    echo.
    echo ==========================================
    echo   SUCCESS - Database Updated!
    echo ==========================================
    echo.
    echo Changes Applied:
    echo   1. Added SCHOOL_ADMIN role to users table
    echo   2. Inserted sample schooladmin1 user
    echo   3. System ready for login
    echo.
) else (
    echo.
    echo ==========================================
    echo   ERROR - Database Update Failed
    echo ==========================================
    echo.
    echo Troubleshooting:
    echo   1. Ensure MySQL is running
    echo   2. Verify credentials are correct
    echo   3. Verify database %MYSQL_DB% exists
    echo   4. Check MySQL user permissions
    echo.
    pause
    exit /b 1
)

echo.
pause
