@echo off
REM ===========================================================
REM Alter Schools Table - Add Missing Columns
REM ===========================================================
REM This script safely adds 9 missing columns to the schools
REM table while preserving all existing data

setlocal enabledelayedexpansion
cls

echo.
echo ===========================================================
echo   ALTER SCHOOLS TABLE - Add Missing Columns
echo ===========================================================
echo.
echo This will:
echo   1. Add 9 new columns (school_code, state, pincode, etc)
echo   2. Keep all existing data safe
echo   3. Auto-generate school_code for existing schools
echo   4. Add performance indexes
echo.
echo Columns being added:
echo   - school_code (unique identifier)
echo   - state
echo   - pincode
echo   - phone
echo   - principal_name
echo   - principal_contact
echo   - registration_number
echo   - status (ACTIVE/INACTIVE)
echo   - established_year
echo.

set /p confirm="Are you sure? (YES/NO): "
if /i not "%confirm%"=="YES" (
    echo Cancelled.
    pause
    exit /b 0
)

set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

set "SQL_FILE=%SCRIPT_DIR%ALTER_SCHOOLS_TABLE.sql"

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
    echo   SUCCESS - Schools table updated!
    echo ===========================================================
    echo.
    echo What was done:
    echo   1. Added 9 new columns to schools table
    echo   2. All existing data preserved
    echo   3. Auto-generated school_code for existing schools
    echo   4. Added performance indexes
    echo   5. All schools set to ACTIVE status
    echo.
    echo Table now has 17 columns:
    echo   Original (8): school_id, school_name, address, city,
    echo                 contact_number, email, created_at, updated_at
    echo.
    echo   New (9):      school_code, state, pincode, phone,
    echo                 principal_name, principal_contact,
    echo                 registration_number, status, established_year
    echo.
    echo Next steps:
    echo   1. Restart Tomcat
    echo   2. Login as admin1 / admin123
    echo   3. Try adding or editing a school
    echo.
) else (
    echo.
    echo ===========================================================
    echo   ERROR - Table update failed
    echo ===========================================================
    echo.
    echo Troubleshooting:
    echo   1. Make sure MySQL is running
    echo   2. Verify credentials:
    echo      Host: %MYSQL_HOST%
    echo      User: %MYSQL_USER%
    echo      Database: %MYSQL_DB%
    echo   3. Check MySQL error message above
    echo   4. Ensure schools table exists
    echo.
)

pause
