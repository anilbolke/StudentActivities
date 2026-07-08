@echo off
REM ==========================================
REM School Exam Management System - Deployment Script
REM ==========================================
REM This script automates the complete deployment process:
REM 1. Executes SQL database updates
REM 2. Compiles Java files
REM 3. Restarts Apache Tomcat
REM ==========================================

setlocal enabledelayedexpansion
cls

echo.
echo ==========================================
echo   SCHOOL EXAM SYSTEM - DEPLOYMENT
echo ==========================================
echo.

REM Get the directory where the script is located
set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

REM Define paths
set "SQL_FILE=%SCRIPT_DIR%SCHOOL_ADMIN_SETUP.sql"
set "SRC_DIR=%SCRIPT_DIR%src"
set "BIN_DIR=%SCRIPT_DIR%bin"
set "LIB_DIR=%SCRIPT_DIR%lib"
set "JAVA_SRC=%SRC_DIR%\com\school\exam\dao\UserDAO.java"
set "TOMCAT_HOME=C:\Program Files\Apache Software Foundation\Tomcat 9.0"

REM Color codes
set "GREEN=[92m"
set "RED=[91m"
set "YELLOW=[93m"
set "RESET=[0m"

REM ==========================================
REM STEP 1: Database Setup
REM ==========================================
echo.
echo [STEP 1/3] Executing SQL Database Updates...
echo -------------------------------------------

if not exist "%SQL_FILE%" (
    echo %RED%ERROR: SQL file not found: %SQL_FILE%%RESET%
    pause
    exit /b 1
)

echo Executing: %SQL_FILE%
REM Note: You need MySQL credentials. Update the values below:
set "MYSQL_USER=root"
set "MYSQL_PASS=root"
set "MYSQL_HOST=localhost"
set "MYSQL_DB=exam_db"

mysql -h %MYSQL_HOST% -u %MYSQL_USER% -p%MYSQL_PASS% %MYSQL_DB% < "%SQL_FILE%"

if %errorlevel% equ 0 (
    echo [OK] SQL execution completed successfully
) else (
    echo %RED%ERROR: SQL execution failed (Error Code: %errorlevel%)%RESET%
    echo.
    echo Make sure MySQL is running and credentials are correct:
    echo   Host: %MYSQL_HOST%
    echo   User: %MYSQL_USER%
    echo   Database: %MYSQL_DB%
    pause
    exit /b 1
)

REM ==========================================
REM STEP 2: Compile Java Files
REM ==========================================
echo.
echo [STEP 2/3] Compiling Java Files...
echo -------------------------------------------

if not exist "%BIN_DIR%" (
    echo Creating bin directory...
    mkdir "%BIN_DIR%"
)

if not exist "%JAVA_SRC%" (
    echo %RED%ERROR: Source file not found: %JAVA_SRC%%RESET%
    pause
    exit /b 1
)

echo Compiling: UserDAO.java
javac -d "%BIN_DIR%" -cp "%BIN_DIR%;%LIB_DIR%\*" -sourcepath "%SRC_DIR%" "%JAVA_SRC%"

if %errorlevel% equ 0 (
    echo [OK] Java compilation completed successfully
) else (
    echo %RED%ERROR: Java compilation failed (Error Code: %errorlevel%)%RESET%
    echo.
    echo Make sure Java Development Kit (JDK) is installed and in PATH
    pause
    exit /b 1
)

REM ==========================================
REM STEP 3: Restart Tomcat
REM ==========================================
echo.
echo [STEP 3/3] Restarting Apache Tomcat...
echo -------------------------------------------

if not exist "%TOMCAT_HOME%\bin\catalina.bat" (
    echo %YELLOW%WARNING: Tomcat not found at: %TOMCAT_HOME%%RESET%
    echo.
    echo Please restart Tomcat manually. Update TOMCAT_HOME if needed:
    echo   Current: %TOMCAT_HOME%
    echo.
) else (
    echo Stopping Tomcat...
    call "%TOMCAT_HOME%\bin\shutdown.bat"
    timeout /t 5 /nobreak
    
    echo Starting Tomcat...
    call "%TOMCAT_HOME%\bin\startup.bat"
    timeout /t 3 /nobreak
    
    if %errorlevel% equ 0 (
        echo [OK] Tomcat restarted successfully
    ) else (
        echo %YELLOW%WARNING: Tomcat restart completed (check Tomcat console for details)%RESET%
    )
)

REM ==========================================
REM Deployment Complete
REM ==========================================
echo.
echo ==========================================
echo   DEPLOYMENT COMPLETED SUCCESSFULLY
echo ==========================================
echo.
echo Next Steps:
echo   1. Wait 10-15 seconds for Tomcat to fully start
echo   2. Open: http://localhost:8080/StudentActivities/
echo   3. Login with credentials:
echo      - School Admin: schooladmin1 / school123
echo      - Teacher:      teacher1 / password123
echo.
echo System Status:
echo   - Database:    Updated (School Admin role added)
echo   - Java Code:   Compiled (UserDAO enhanced)
echo   - Tomcat:      Restarted (ready to serve)
echo.
pause
