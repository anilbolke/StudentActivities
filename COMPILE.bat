@echo off
REM ==========================================
REM Compile Java Files Only
REM ==========================================

setlocal enabledelayedexpansion
cls

echo.
echo Compiling Java Files...
echo.

set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

set "BIN_DIR=%SCRIPT_DIR%bin"
set "LIB_DIR=%SCRIPT_DIR%lib"
set "SRC_DIR=%SCRIPT_DIR%src"

if not exist "%BIN_DIR%" (
    echo Creating bin directory...
    mkdir "%BIN_DIR%"
)

echo Compiling UserDAO.java...
javac -d "%BIN_DIR%" -cp "%BIN_DIR%;%LIB_DIR%\*" -sourcepath "%SRC_DIR%" "%SRC_DIR%\com\school\exam\dao\UserDAO.java"

if %errorlevel% equ 0 (
    echo.
    echo [OK] Compilation successful!
) else (
    echo.
    echo [ERROR] Compilation failed. Check console output above.
    pause
    exit /b 1
)

echo.
pause
