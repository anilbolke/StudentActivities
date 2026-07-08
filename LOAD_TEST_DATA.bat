@echo off
REM Load test data for exam system
REM This script loads questions and all test data into the database

REM Configure these variables:
set DB_HOST=localhost
set DB_PORT=3306
set DB_USER=root
set DB_PASSWORD=
set DB_NAME=student_activities

REM Path to SQL file
set SQL_FILE=COMPLETE_TEST_DATA_WITH_QUESTIONS.sql

echo Loading test data...
echo Database: %DB_NAME%
echo Host: %DB_HOST%:%DB_PORT%
echo User: %DB_USER%
echo.

REM Execute SQL file
mysql -h %DB_HOST% -P %DB_PORT% -u %DB_USER% -p%DB_PASSWORD% %DB_NAME% < %SQL_FILE%

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✓ Test data loaded successfully!
    echo.
    echo You can now:
    echo 1. Restart Tomcat
    echo 2. Login with: teacher1 / password123
    echo 3. Test Create Exam with Preview Questions
    pause
) else (
    echo.
    echo ✗ Error loading test data!
    echo Check:
    echo - MySQL is running
    echo - Database name is correct: %DB_NAME%
    echo - SQL file exists: %SQL_FILE%
    echo - MySQL credentials are correct
    pause
)
