@echo off
REM ===========================================================
REM Create New Schools Table - Batch Script
REM ===========================================================
REM This script drops the old schools table and creates a new one
REM with all required columns and sample data

setlocal enabledelayedexpansion
cls

echo.
echo ===========================================================
echo   CREATE NEW SCHOOLS TABLE
echo ===========================================================
echo.
echo This will:
echo   1. Drop the old schools table
echo   2. Create a new schools table with complete schema
echo   3. Insert sample data
echo.

set /p confirm="Are you sure? (YES/NO): "
if /i not "%confirm%"=="YES" (
    echo Cancelled.
    pause
    exit /b 0
)

set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

set "SQL_FILE=%SCRIPT_DIR%CREATE_SCHOOLS_TABLE.sql"

REM MySQL Credentials
set "MYSQL_HOST=localhost"
set "MYSQL_USER=root"
set "MYSQL_PASS=root"
set "MYSQL_DB=`school_exam_system`"

REM Check if SQL file exists
if not exist "%SQL_FILE%" (
    echo ERROR: SQL file not found: %SQL_FILE%
    echo.
    pause
    exit /b 1
)

echo.
echo Executing: %SQL_FILE%
echo.

REM Execute SQL file
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASS% %MYSQL_DB% < "%SQL_FILE%"

if %errorlevel% equ 0 (
    echo.
    echo ===========================================================
    echo   SUCCESS - Schools table created!
    echo ===========================================================
    echo.
    echo Table created with:
    echo   - All 14 required columns
    echo   - Proper indexes for performance
    echo   - 2 sample schools for testing
    echo.
    echo Next steps:
    echo   1. Restart Tomcat
    echo   2. Login as admin1 / admin123
    echo   3. Try adding a school
    echo.
) else (
    echo.
    echo ===========================================================
    echo   ERROR - Table creation failed
    echo ===========================================================
    echo.
    echo Troubleshooting:
    echo   1. Make sure MySQL is running
    echo   2. Verify credentials:
    echo      Host: %MYSQL_HOST%
    echo      User: %MYSQL_USER%
    echo      Database: %MYSQL_DB%
    echo   3. Check database `school_exam_system` exists
    echo.
)

pause
