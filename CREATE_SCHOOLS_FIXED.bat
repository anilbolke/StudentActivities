@echo off
REM ===========================================================
REM Create New Schools Table (Fixed - Handles Foreign Keys)
REM ===========================================================
REM This script safely drops the foreign key constraint,
REM then creates the new schools table, then recreates it

setlocal enabledelayedexpansion
cls

echo.
echo ===========================================================
echo   CREATE NEW SCHOOLS TABLE (Fixed)
echo ===========================================================
echo.
echo This will:
echo   1. Drop foreign key constraint from users table
echo   2. Drop the old schools table
echo   3. Create a new schools table with complete schema
echo   4. Re-create the foreign key constraint
echo   5. Insert sample data
echo.

set /p confirm="Are you sure? (YES/NO): "
if /i not "%confirm%"=="YES" (
    echo Cancelled.
    pause
    exit /b 0
)

set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

set "SQL_FILE=%SCRIPT_DIR%CREATE_SCHOOLS_TABLE_FIXED.sql"

REM MySQL Credentials
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

echo.
echo Executing: %SQL_FILE%
echo.

REM Execute SQL file
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASS% %MYSQL_DB% < "%SQL_FILE%"

if %errorlevel% equ 0 (
    echo.
    echo ===========================================================
    echo   SUCCESS - Schools table created with foreign key!
    echo ===========================================================
    echo.
    echo What was done:
    echo   1. Foreign key constraint dropped safely
    echo   2. Old schools table deleted
    echo   3. New schools table created (16 columns)
    echo   4. Foreign key constraint restored
    echo   5. 2 sample schools inserted
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
    echo   3. Check MySQL error message above
    echo.
)

pause
