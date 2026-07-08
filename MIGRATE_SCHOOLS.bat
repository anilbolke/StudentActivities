@echo off
REM ===========================================================
REM Schools Table Migration Script
REM Execute this to add missing columns to schools table
REM ===========================================================

setlocal enabledelayedexpansion
cls

echo.
echo ===========================================================
echo   SCHOOLS TABLE MIGRATION
echo ===========================================================
echo.

set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

set "SQL_FILE=%SCRIPT_DIR%MIGRATE_SCHOOLS_TABLE.sql"

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

echo Running migration...
echo   SQL File: %SQL_FILE%
echo   Database: %MYSQL_DB%
echo.

REM Execute SQL file
mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASS% %MYSQL_DB% < "%SQL_FILE%"

if %errorlevel% equ 0 (
    echo.
    echo ===========================================================
    echo   SUCCESS - Schools table migrated!
    echo ===========================================================
    echo.
    echo Next steps:
    echo   1. Restart Tomcat
    echo   2. Login as admin1 / admin123
    echo   3. Try adding a school
    echo.
) else (
    echo.
    echo ===========================================================
    echo   ERROR - Migration failed
    echo ===========================================================
    echo.
    echo Troubleshooting:
    echo   1. Make sure MySQL is running
    echo   2. Verify credentials:
    echo      Host: %MYSQL_HOST%
    echo      User: %MYSQL_USER%
    echo      Database: %MYSQL_DB%
    echo   3. Check that exam_db database exists
    echo.
)

pause
