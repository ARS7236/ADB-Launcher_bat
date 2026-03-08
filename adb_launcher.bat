@echo off
title ADB Launcher
color 0A

:: =================================
:: ADB Launcher
:: Created by ars7236
:: Do not remove credits
:: =================================

:: Always go to platform-tools
cd /d C:\platform-tools

:menu
cls
echo ==============================
echo         ADB LAUNCHER
echo         by ars7236
echo ==============================
echo [1] Check devices
echo [2] Install APK
echo [3] Uninstall app
echo [4] Reboot device
echo [5] Reboot to bootloader
echo [6] Reboot to recovery
echo [7] Push file to device
echo [8] Pull file from device
echo [9] Open shell
echo [10] Show connected device info
echo [11] Kill ADB server
echo [12] Start ADB server
echo [13] Start Shizuku
echo [0] Exit
echo ==============================
set /p choice=Choose an option: 

if "%choice%"=="1" goto devices
if "%choice%"=="2" goto installapk
if "%choice%"=="3" goto uninstallapp
if "%choice%"=="4" goto reboot
if "%choice%"=="5" goto bootloader
if "%choice%"=="6" goto recovery
if "%choice%"=="7" goto pushfile
if "%choice%"=="8" goto pullfile
if "%choice%"=="9" goto shell
if "%choice%"=="10" goto deviceinfo
if "%choice%"=="11" goto killserver
if "%choice%"=="12" goto startserver
if "%choice%"=="13" goto shizuku
if "%choice%"=="0" goto end

echo Invalid choice.
pause
goto menu

:devices
cls
echo Checking connected devices...
adb devices
pause
goto menu

:installapk
cls
echo Paste the FULL path to your APK file.
echo Example: C:\Users\YourName\Downloads\app.apk
set /p apkpath=APK path: 
if not exist "%apkpath%" (
    echo File not found.
    pause
    goto menu
)
adb install "%apkpath%"
pause
goto menu

:uninstallapp
cls
echo Enter the package name to uninstall.
echo Example: com.example.app
set /p package=Package name: 
adb uninstall "%package%"
pause
goto menu

:reboot
cls
adb reboot
pause
goto menu

:bootloader
cls
adb reboot bootloader
pause
goto menu

:recovery
cls
adb reboot recovery
pause
goto menu

:pushfile
cls
echo Paste the FULL path of the file on your PC.
set /p localfile=Local file path: 
if not exist "%localfile%" (
    echo File not found.
    pause
    goto menu
)
echo Enter destination path on device.
echo Example: /sdcard/Download/
set /p remotepath=Device path: 
adb push "%localfile%" "%remotepath%"
pause
goto menu

:pullfile
cls
echo Enter the FULL path of the file on the device.
echo Example: /sdcard/Download/file.txt
set /p remotefile=Device file path: 
echo Enter destination folder on your PC.
echo Example: C:\Users\YourName\Desktop
set /p localdest=PC destination: 
adb pull "%remotefile%" "%localdest%"
pause
goto menu

:shell
cls
echo Opening ADB shell...
adb shell
pause
goto menu

:deviceinfo
cls
echo Device model:
adb shell getprop ro.product.model
echo.
echo Android version:
adb shell getprop ro.build.version.release
echo.
echo Device codename:
adb shell getprop ro.product.device
pause
goto menu

:killserver
cls
adb kill-server
echo ADB server stopped.
pause
goto menu

:startserver
cls
adb start-server
echo ADB server started.
pause
goto menu

:shizuku
cls
echo Starting Shizuku...
echo.
adb shell sh /storage/emulated/0/Android/data/moe.shizuku.privileged.api/start.sh
if errorlevel 1 (
    echo First path failed, trying /sdcard path...
    adb shell sh /sdcard/Android/data/moe.shizuku.privileged.api/start.sh
)
echo.
echo Done.
pause
goto menu

:end
exit

:: ADB Launcher
:: Created by ars7236
:: 2026