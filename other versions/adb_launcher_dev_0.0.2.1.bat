@echo off
setlocal EnableExtensions EnableDelayedExpansion
title ADB Launcher Beta 0.0.2.1
color 0A

:: =================================
:: ADB Launcher
:: Version: 0.0.2.1-dev
:: Created by ars7236
:: Do not remove credits
:: =================================

set "SCRIPT_DIR=%~dp0"
set "ADB_DIR="
set "ADB_EXE="
set "SCRCPY_EXE="
set "SELECTED_SERIAL="
set "SELECTED_LABEL=No device selected"
set "TARGET_ARG="

call :findPlatformTools
if not defined ADB_EXE goto noadb

cd /d "%ADB_DIR%"
call :findScrcpy

goto menu

:menu
cls
echo ==============================
echo   ADB LAUNCHER BETA 0.0.2.1
echo ==============================
echo ADB folder  : %ADB_DIR%
echo Device      : %SELECTED_LABEL%
if defined SCRCPY_EXE (
    echo Scrcpy      : Ready
) else (
    echo Scrcpy      : Not found
)
echo ==============================
echo [1] Check devices
echo [2] Select / switch device
echo [3] Install APK
echo [4] Uninstall app
echo [5] Reboot menu
echo [6] Push file to device
echo [7] Pull file from device
echo [8] Open shell
echo [9] Show connected device info
echo [10] Kill ADB server
echo [11] Start ADB server
echo [12] Start Shizuku
echo [13] Scrcpy menu
echo [14] App list
echo [0] Exit
echo ==============================
set /p choice=Choose an option: 

if "%choice%"=="1" goto devices
if "%choice%"=="2" goto selectdevice
if "%choice%"=="3" goto installapk
if "%choice%"=="4" goto uninstallapp
if "%choice%"=="5" goto rebootmenu
if "%choice%"=="6" goto pushfile
if "%choice%"=="7" goto pullfile
if "%choice%"=="8" goto shell
if "%choice%"=="9" goto deviceinfo
if "%choice%"=="10" goto killserver
if "%choice%"=="11" goto startserver
if "%choice%"=="12" goto shizuku
if "%choice%"=="13" goto scrcpymenu
if "%choice%"=="14" goto applist
if "%choice%"=="0" goto end

echo Invalid choice.
pause
goto menu

:devices
cls
echo Checking connected devices...
echo.
adb devices -l
echo.
echo Current selected device: %SELECTED_LABEL%
pause
goto menu

:selectdevice
call :pickDevice
pause
goto menu

:installapk
call :requireDeviceSelection || goto menu
cls
echo Paste the FULL path to your APK file.
echo Example: C:\Users\YourName\Downloads\app.apk
set /p apkpath=APK path: 
call :stripQuotes apkpath
if not exist "%apkpath%" (
    echo File not found.
    pause
    goto menu
)
echo.
echo [1] Normal install
echo [2] Reinstall / upgrade existing app
set /p installmode=Choose install mode: 
if "%installmode%"=="2" (
    adb %TARGET_ARG% install -r "%apkpath%"
) else (
    adb %TARGET_ARG% install "%apkpath%"
)
pause
goto menu

:uninstallapp
call :requireDeviceSelection || goto menu
cls
echo Enter the package name to uninstall.
echo Example: com.example.app
set /p package=Package name: 
if not defined package (
    echo Package name cannot be empty.
    pause
    goto menu
)
adb %TARGET_ARG% uninstall "%package%"
pause
goto menu

:rebootmenu
call :requireDeviceSelection || goto menu
cls
echo ==============================
echo          REBOOT MENU
echo ==============================
echo [1] Reboot device
echo [2] Reboot to bootloader
echo [3] Reboot to recovery
echo [0] Back
echo ==============================
set /p rebootchoice=Choose an option: 

if "%rebootchoice%"=="1" (
    adb %TARGET_ARG% reboot
    pause
    goto menu
)
if "%rebootchoice%"=="2" (
    adb %TARGET_ARG% reboot bootloader
    pause
    goto menu
)
if "%rebootchoice%"=="3" (
    adb %TARGET_ARG% reboot recovery
    pause
    goto menu
)
if "%rebootchoice%"=="0" goto menu

echo Invalid choice.
pause
goto rebootmenu

:pushfile
call :requireDeviceSelection || goto menu
cls
echo Paste the FULL path of the file on your PC.
set /p localfile=Local file path: 
call :stripQuotes localfile
if not exist "%localfile%" (
    echo File not found.
    pause
    goto menu
)
echo Enter destination path on device.
echo Example: /sdcard/Download/
set /p remotepath=Device path: 
if not defined remotepath (
    echo Device path cannot be empty.
    pause
    goto menu
)
adb %TARGET_ARG% push "%localfile%" "%remotepath%"
pause
goto menu

:pullfile
call :requireDeviceSelection || goto menu
cls
echo Enter the FULL path of the file on the device.
echo Example: /sdcard/Download/file.txt
set /p remotefile=Device file path: 
if not defined remotefile (
    echo Device file path cannot be empty.
    pause
    goto menu
)
echo Enter destination folder on your PC.
echo Example: C:\Users\YourName\Desktop
set /p localdest=PC destination: 
call :stripQuotes localdest
if not defined localdest (
    echo PC destination cannot be empty.
    pause
    goto menu
)
adb %TARGET_ARG% pull "%remotefile%" "%localdest%"
pause
goto menu

:shell
call :requireDeviceSelection || goto menu
cls
echo Opening ADB shell on %SELECTED_SERIAL%...
adb %TARGET_ARG% shell
pause
goto menu

:deviceinfo
call :requireDeviceSelection || goto menu
cls
echo Selected device serial:
echo %SELECTED_SERIAL%
echo.
echo Device model:
adb %TARGET_ARG% shell getprop ro.product.model
echo.
echo Android version:
adb %TARGET_ARG% shell getprop ro.build.version.release
echo.
echo Device codename:
adb %TARGET_ARG% shell getprop ro.product.device
echo.
echo Manufacturer:
adb %TARGET_ARG% shell getprop ro.product.manufacturer
pause
goto menu

:applist
call :requireDeviceSelection || goto menu
cls
echo Building app list for %SELECTED_SERIAL%...
echo This may take a bit on devices with many apps.
echo.
set "APP_LIST_FILE=%TEMP%\adb_launcher_applist_%RANDOM%_%RANDOM%.txt"
>"%APP_LIST_FILE%" echo =============================================
>>"%APP_LIST_FILE%" echo APP LIST FOR %SELECTED_SERIAL%
>>"%APP_LIST_FILE%" echo Format: APP NAME [package.name]
>>"%APP_LIST_FILE%" echo =============================================
for /f "tokens=2 delims=: " %%P in ('adb %TARGET_ARG% shell pm list packages ^| findstr /R /C:"^package:"') do (
    set "APP_PACKAGE=%%P"
    set "APP_LABEL="
    for /f "tokens=2 delims=:" %%L in ('adb %TARGET_ARG% shell dumpsys package "%%P" ^| findstr /C:"application-label:" /C:"application-label-en:"') do (
        if not defined APP_LABEL set "APP_LABEL=%%L"
    )
    if defined APP_LABEL (
        for /f "tokens=* delims= " %%Z in ("!APP_LABEL!") do set "APP_LABEL=%%Z"
    ) else (
        set "APP_LABEL=%%P"
    )
    >>"%APP_LIST_FILE%" echo !APP_LABEL! [%%P]
)
echo Done.
echo.
type "%APP_LIST_FILE%"
del "%APP_LIST_FILE%" >nul 2>nul
echo.
pause
goto menu

:killserver
cls
adb kill-server
echo ADB server stopped.
set "SELECTED_SERIAL="
set "SELECTED_LABEL=No device selected"
set "TARGET_ARG="
pause
goto menu

:startserver
cls
adb start-server
echo ADB server started.
pause
goto menu

:shizuku
call :requireDeviceSelection || goto menu
cls
echo Starting Shizuku on %SELECTED_SERIAL%...
echo.
adb %TARGET_ARG% shell sh /storage/emulated/0/Android/data/moe.shizuku.privileged.api/start.sh
if errorlevel 1 (
    echo First path failed, trying /sdcard path...
    adb %TARGET_ARG% shell sh /sdcard/Android/data/moe.shizuku.privileged.api/start.sh
)
echo.
echo Done.
pause
goto menu

:scrcpymenu
call :requireDeviceSelection || goto menu
cls
if not defined SCRCPY_EXE (
    echo scrcpy.exe was not found.
    echo.
    echo Put scrcpy.exe in one of these places:
    echo - %ADB_DIR%
    echo - %SCRIPT_DIR%
    echo - any folder already in PATH
    echo.
    pause
    goto menu
)
echo ==============================
echo          SCRCPY MENU
echo ==============================
echo Selected device: %SELECTED_SERIAL%
echo [1] Normal Scrcpy
echo [2] Scrcpy with parameters
echo [0] Back
echo ==============================
set /p scrcpychoice=Choose an option: 

if "%scrcpychoice%"=="1" goto scrcpynormal
if "%scrcpychoice%"=="2" goto scrcpyparams
if "%scrcpychoice%"=="0" goto menu

echo Invalid choice.
pause
goto scrcpymenu

:scrcpynormal
cls
echo Launching Scrcpy on %SELECTED_SERIAL%...
start "scrcpy" "%SCRCPY_EXE%" -s "%SELECTED_SERIAL%"
goto menu

:scrcpyparams
cls
echo Type scrcpy parameters for device %SELECTED_SERIAL%.
echo Example: --turn-screen-off --max-size 1280
echo.
echo Type --help to open scrcpy help first.
set /p scrcpyargs=Parameters: 
if /I "%scrcpyargs%"=="--help" goto scrcpyhelp
start "scrcpy" "%SCRCPY_EXE%" -s "%SELECTED_SERIAL%" %scrcpyargs%
goto menu

:scrcpyhelp
cls
echo Opening scrcpy help...
echo.
"%SCRCPY_EXE%" --help
echo.
set /p helpdone=Press Y if you finished reading help and want to continue: 
if /I "%helpdone%"=="Y" goto scrcpyparams
goto scrcpymenu

:noadb
cls
echo adb.exe was not found automatically.
echo.
echo Expected places checked:
echo - %SCRIPT_DIR%platform-tools
echo - %SCRIPT_DIR%
echo - C:\platform-tools
echo - C:\adb
echo - folders available in PATH
echo.
echo Please install Android platform-tools or place this launcher near platform-tools.
pause
goto end

:findPlatformTools
if exist "%SCRIPT_DIR%platform-tools\adb.exe" (
    set "ADB_DIR=%SCRIPT_DIR%platform-tools"
    set "ADB_EXE=%ADB_DIR%\adb.exe"
    exit /b 0
)
if exist "%SCRIPT_DIR%adb.exe" (
    set "ADB_DIR=%SCRIPT_DIR%"
    set "ADB_EXE=%ADB_DIR%adb.exe"
    exit /b 0
)
if exist "C:\platform-tools\adb.exe" (
    set "ADB_DIR=C:\platform-tools"
    set "ADB_EXE=%ADB_DIR%\adb.exe"
    exit /b 0
)
if exist "C:\adb\adb.exe" (
    set "ADB_DIR=C:\adb"
    set "ADB_EXE=%ADB_DIR%\adb.exe"
    exit /b 0
)
for /f "delims=" %%I in ('where adb.exe 2^>nul') do (
    set "ADB_EXE=%%~fI"
    for %%J in ("%%~dpI.") do set "ADB_DIR=%%~fJ"
    exit /b 0
)
exit /b 1

:findScrcpy
if exist "%ADB_DIR%\scrcpy.exe" (
    set "SCRCPY_EXE=%ADB_DIR%\scrcpy.exe"
    exit /b 0
)
if exist "%SCRIPT_DIR%scrcpy.exe" (
    set "SCRCPY_EXE=%SCRIPT_DIR%scrcpy.exe"
    exit /b 0
)
for /f "delims=" %%I in ('where scrcpy.exe 2^>nul') do (
    set "SCRCPY_EXE=%%~fI"
    exit /b 0
)
exit /b 1

:pickDevice
set "SELECTED_SERIAL="
set "SELECTED_LABEL=No device selected"
set "TARGET_ARG="
set /a DEVICE_COUNT=0
for /L %%N in (1,1,32) do (
    set "DEVICE_%%N="
    set "DEVICE_LABEL_%%N="
)
cls
echo Scanning devices...
echo.
for /f "skip=1 tokens=1,2" %%A in ('adb devices') do (
    if "%%A"=="" (
        rem skip
    ) else if "%%A"=="*" (
        rem skip
    ) else if "%%B"=="device" (
        set /a DEVICE_COUNT+=1
        set "DEVICE_!DEVICE_COUNT!=%%A"
        set "DEVICE_LABEL_!DEVICE_COUNT!=%%A [device]"
    ) else if "%%B"=="unauthorized" (
        echo %%A [unauthorized]
    ) else if "%%B"=="offline" (
        echo %%A [offline]
    )
)
if !DEVICE_COUNT! EQU 0 (
    echo No authorized devices found.
    echo Check USB debugging, authorization popup, or cable.
    exit /b 1
)
echo Authorized devices:
for /L %%N in (1,1,!DEVICE_COUNT!) do echo [%%N] !DEVICE_LABEL_%%N!
echo [0] Cancel
set /p devicechoice=Choose a device: 
if "%devicechoice%"=="0" exit /b 1
for /f "delims=0123456789" %%Z in ("%devicechoice%") do (
    echo Invalid device choice.
    exit /b 1
)
if not defined DEVICE_%devicechoice% (
    echo Invalid device choice.
    exit /b 1
)
call set "SELECTED_SERIAL=%%DEVICE_%devicechoice%%%"
set "SELECTED_LABEL=%SELECTED_SERIAL%"
set "TARGET_ARG=-s %SELECTED_SERIAL%"
echo Selected device: %SELECTED_SERIAL%
exit /b 0

:requireDeviceSelection
if defined SELECTED_SERIAL (
    adb %TARGET_ARG% get-state 1>nul 2>nul
    if not errorlevel 1 exit /b 0
    echo Previously selected device is no longer available.
    echo.
)
call :pickDevice
exit /b %errorlevel%

:stripQuotes
set "%~1=!%~1:\"=!"
set "%~1=!%~1:"=!"
exit /b 0

:end
endlocal
exit

:: ADB Launcher
:: Created by ars7236
:: 2026
