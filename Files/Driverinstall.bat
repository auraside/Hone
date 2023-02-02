@echo off
title Downloading Nvidia driver...
echo The drivers are 664Mb to 855Mb, so this will take a moment to download. (696,519,945 or 897,058,453 bytes)
echo PLEASE, do NOT open HoneCtrl until the driver installation is done.
echo.
:start
set /p choice=Do you need shadowplay and other components of the driver? Y or N?: 
if /i "%choice%" == "y" (
  curl -g -L -# -o "C:\Hone\Drivers\NvidiaHone.exe" "https://github.com/auraside/HoneCtrl/releases/download/2.58/HoneDefault.exe"
) else if /i "%choice%" == "n" (
  curl -g -L -# -o "C:\Hone\Drivers\NvidiaHone.exe" "https://github.com/auraside/HoneCtrl/releases/download/2.58/HoneTweaked.exe"
) else (
  goto start
)

C:\Hone\Drivers\NvidiaHone.exe

goto 2>nul & del "%~f0"
