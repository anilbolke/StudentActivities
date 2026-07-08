@echo off
REM ==========================================
REM Tomcat Control Utility
REM ==========================================

setlocal enabledelayedexpansion
cls

echo.
echo ==========================================
echo   TOMCAT CONTROL UTILITY
echo ==========================================
echo.
echo 1. Start Tomcat
echo 2. Stop Tomcat
echo 3. Restart Tomcat
echo 4. Check Tomcat Status
echo 5. View Tomcat Logs
echo 6. Exit
echo.

set /p CHOICE="Enter your choice (1-6): "

set "TOMCAT_HOME=C:\Program Files\Apache Software Foundation\Tomcat 9.0"

if "%CHOICE%"=="1" goto START
if "%CHOICE%"=="2" goto STOP
if "%CHOICE%"=="3" goto RESTART
if "%CHOICE%"=="4" goto STATUS
if "%CHOICE%"=="5" goto LOGS
if "%CHOICE%"=="6" goto END

echo Invalid choice. Exiting.
goto END

:START
echo.
echo Starting Tomcat...
call "%TOMCAT_HOME%\bin\startup.bat"
echo.
echo Tomcat started. Waiting for initialization...
timeout /t 5
goto END

:STOP
echo.
echo Stopping Tomcat...
call "%TOMCAT_HOME%\bin\shutdown.bat"
echo.
echo Tomcat stopped.
timeout /t 3
goto END

:RESTART
echo.
echo Restarting Tomcat...
echo Stopping Tomcat...
call "%TOMCAT_HOME%\bin\shutdown.bat"
timeout /t 5
echo.
echo Starting Tomcat...
call "%TOMCAT_HOME%\bin\startup.bat"
timeout /t 5
echo.
echo Tomcat restarted.
goto END

:STATUS
echo.
echo Checking Tomcat status...
tasklist | findstr /I "java.exe" > nul
if %errorlevel% equ 0 (
    echo [RUNNING] Tomcat is running
    echo.
    tasklist | findstr /I "java.exe"
) else (
    echo [STOPPED] Tomcat is not running
)
echo.
goto END

:LOGS
echo.
echo Opening Tomcat logs...
if exist "%TOMCAT_HOME%\logs\catalina.out" (
    type "%TOMCAT_HOME%\logs\catalina.out" | more
) else if exist "%TOMCAT_HOME%\logs\catalina.2026-*.log" (
    for /r "%TOMCAT_HOME%\logs" %%F in (catalina.*.log) do (
        if "%%~tF" gtr "!LATEST!" set "LATEST=%%~tF" & set "LATESTFILE=%%F"
    )
    if defined LATESTFILE (
        type "!LATESTFILE!" | more
    ) else (
        echo No catalina logs found.
    )
) else (
    echo Tomcat logs not found at: %TOMCAT_HOME%\logs
)
echo.
goto END

:END
echo.
pause
