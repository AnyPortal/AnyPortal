@echo off
setlocal enabledelayedexpansion

:: Check for required arguments
if "%~1"=="" (
    echo Error: Missing source.
    echo Usage: %~nx0 "source" "destination"
    exit /b 1
)

if "%~2"=="" (
    echo Error: Missing destination.
    echo Usage: %~nx0 "source" "destination"
    exit /b 1
)

set "SOURCE=%~1"
set "DESTINATION=%~2"

:: Try moving the folder
rmdir /s /q "%DESTINATION%"
robocopy "%SOURCE%" "%DESTINATION%" /MOVE /E /NFL /NDL /NJH /NJS /NP >nul 2>nul

:: Check if the move was successful
if %ERRORLEVEL% LSS 8 (
    echo Move completed successfully.
    exit /b 0
)

:: If already running as admin, stop retrying
net session >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo Move failed, even with administrative privileges. Exiting...
    exit /b 1
)

:: Request admin privileges and retry
echo Move failed. Requesting administrative privileges...
powershell -Command "Start-Process cmd -ArgumentList '/c \"%~f0\" \"%SOURCE%\" \"%DESTINATION%\"' -Verb RunAs"
exit /b
