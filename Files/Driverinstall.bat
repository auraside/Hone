@echo off
echo The drivers are 732Mb to 1Gb, so this will take a moment to download. (768,102,400 or 1,073,691,829 bytes)
echo.
echo Would you like to install?
choice /c:YN /n /m "[Y] Yes  [N] No"
if %errorlevel% equ 2 goto Tweaks

cls
title Downloading Nvidia driver...
echo Do you need shadowplay and other components of the driver? Y or N?
choice /c:YN /n /m "[Y] Yes  [N] No"
if %errorlevel% equ 1 (
curl -g -L -# -o "C:\Hone\Drivers\NvidiaHone.exe" "https://github.com/auraside/HoneCtrl/releases/download/2.52/Hone.512.95.Default.exe"
) else (
curl -g -L -# -o "C:\Hone\Drivers\NvidiaHone.exe" "https://github.com/auraside/HoneCtrl/releases/download/2.52/Hone.512.95.Tweaked.exe"
)

C:\Hone\Drivers\NvidiaHone.exe

goto 2>nul & del "%~f0"
