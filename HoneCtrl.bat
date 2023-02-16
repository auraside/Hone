REM Copyright (C) 2022 Auraside, Inc.

REM This program is free software: you can redistribute it and/or modify
REM it under the terms of the GNU Affero General Public License as published
REM by the Free Software Foundation, either version 3 of the License, or
REM (at your option) any later version.

REM This program is distributed in the hope that it will be useful,
REM but WITHOUT ANY WARRANTY; without even the implied warranty of
REM MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
REM GNU Affero General Public License for more details.

REM You should have received a copy of the GNU Affero General Public License
REM along with this program.  If not, see <https://www.gnu.org/licenses/>.

@echo off
title Preparing...
color 06
Mode 130,45
setlocal EnableDelayedExpansion

REM Make Directories
mkdir %SYSTEMDRIVE%\Hone >nul 2>&1
mkdir %SYSTEMDRIVE%\Hone\Resources >nul 2>&1
mkdir %SYSTEMDRIVE%\Hone\HoneRevert >nul 2>&1
mkdir %SYSTEMDRIVE%\Hone\Drivers >nul 2>&1
mkdir %SYSTEMDRIVE%\Hone\Renders >nul 2>&1
cd %SYSTEMDRIVE%\Hone

REM Run as Admin
reg add HKLM /F >nul 2>&1
if %errorlevel% neq 0 start "" /wait /I /min powershell -NoProfile -Command start -verb runas "'%~s0'" && exit /b

REM Show Detailed BSoD
reg add "HKLM\System\CurrentControlSet\Control\CrashControl" /v "DisplayParameters" /t REG_DWORD /d "1" /f >nul 2>&1


REM Blank/Color Character
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (set "DEL=%%a" & set "COL=%%b")

REM Add ANSI escape sequences
reg add HKCU\CONSOLE /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1


:Disclaimer
reg query "HKCU\Software\Hone" /v "Disclaimer" >nul 2>&1 && goto CheckForUpdates
cls
echo.
echo.
call :HoneTitle
echo.
echo                                        %COL%[90m HoneCtrl is a free and open-source desktop utility
echo                                        %COL%[90m    made to improve your day-to-day productivity
echo.
echo.
echo.
echo %COL%[91m  WARNING:
echo %COL%[37m  Please note that we cannot guarantee an FPS boost from applying our optimizations, every system + configuration is different.
echo.
echo     %COL%[33m1.%COL%[37m Everything is "use at your own risk", we are %COL%[91mNOT LIABLE%COL%[37m if you damage your system in any way
echo        (ex. not following the disclaimers carefully).
echo.
echo     %COL%[33m2.%COL%[37m If you don't know what a tweak is, do not use it and contact our support team to receive more assistance.
echo.
echo     %COL%[33m3.%COL%[37m Even though we have an automatic restore point feature, we highly recommend making a manual restore point before running.
echo.
echo   For any questions and/or concerns, please join our discord: discord.gg/hone
echo.
echo   Please enter "I agree" without quotes to continue:
echo.
echo.
echo.
set /p "input=%DEL%                                                            >: %COL%[92m"
if /i "!input!" neq "i agree" goto Disclaimer
reg add "HKCU\Software\Hone" /v "Disclaimer" /f >nul 2>&1

:CheckForUpdates
set local=2.7
set localtwo=%LOCAL%
if exist "%TEMP%\Updater.bat" DEL /S /Q /F "%TEMP%\Updater.bat" >nul 2>&1
curl -g -L -# -o "%TEMP%\Updater.bat" "https://raw.githubusercontent.com/auraside/HoneCtrl/main/Files/HoneCtrlVer" >nul 2>&1
call "%TEMP%\Updater.bat"
if "%LOCAL%" gtr "%LOCALTWO%" (
	clsr
	Mode 65,16
	echo.
	echo  --------------------------------------------------------------
	echo                           Update found
	echo  --------------------------------------------------------------
	echo.
	echo                    Your current version: %LOCALTWO%
	echo.
	echo                          New version: %LOCAL%
	echo.
	echo.
	echo.
	echo      [Y] Yes, Update
	echo      [N] No
	echo.
	%SYSTEMROOT%\System32\choice.exe /c:YN /n /m "%DEL%                                >:"
	set choice=!errorlevel!
	if !choice! == 1 (
		curl -L -o %0 "https://github.com/auraside/HoneCtrl/releases/latest/download/HoneCtrl.Bat" >nul 2>&1
		call %0
		exit /b
	)
	Mode 130,45
)

REM Restart Checks
if exist "%SYSTEMDRIVE%\Hone\Drivers\NvidiaHone.exe" "%SYSTEMDRIVE%\Desktop\Hone\Drivers\NvidiaHone.exe" >nul 2>&1
if exist "%SYSTEMDRIVE%\Hone\Drivers\NvidiaHone.exe" del /Q "%SYSTEMDRIVE%\Desktop\Hone\Drivers\NvidiaHone.exe" >nul 2>&1
if exist "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\Driverinstall.bat" del /Q "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\Driverinstall.bat" >nul 2>&1

REM Attempt to enable WMIC
dism /online /enable-feature /featurename:MicrosoftWindowsWMICore /NoRestart >nul 2>&1

REM Check If First Launch
set firstlaunch=1
>nul 2>&1 call "%SYSTEMDRIVE%\Hone\HoneRevert\firstlaunch.bat"
if "%firstlaunch%" == "0" (goto MainMenu)

REM Restore Point
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\SystemRestore" /v "SystemRestorePointCreationFrequency" /t REG_DWORD /d 0 /f >nul 2>&1
powershell -ExecutionPolicy Unrestricted -NoProfile Enable-ComputerRestore -Drive 'C:\', 'D:\', 'E:\', 'F:\', 'G:\' >nul 2>&1
powershell -ExecutionPolicy Unrestricted -NoProfile Checkpoint-Computer -Description 'Hone Restore Point' >nul 2>&1

REM HKCU & HKLM backup

for /F "tokens=2" %%i in ('date /t') do set date=%%i
set date1=%date:/=.%
>nul 2>&1 md %SYSTEMDRIVE%\Hone\HoneRevert\%date1%
reg export HKCU %SYSTEMDRIVE%\Hone\HoneRevert\%date1%\HKLM.reg /y >nul 2>&1
reg export HKCU %SYSTEMDRIVE%\Hone\HoneRevert\%date1%\HKCU.reg /y >nul 2>&1
echo set "firstlaunch=0" > %SYSTEMDRIVE%\Hone\HoneRevert\firstlaunch.bat

:MainMenu
Mode 130,45
TITLE Hone Control Panel %localtwo%
set "choice="
cls
echo.
echo.
call :HoneTitle
echo.
echo                                        %COL%[90m HoneCtrl is a free and open-source desktop utility
echo                                        %COL%[90m    made to improve your day-to-day productivity
echo.
echo.
echo.
echo.
echo.
echo.
echo                                           %COL%[33m[%COL%[37m 1 %COL%[33m]%COL%[37m Optimizations        %COL%[33m[%COL%[37m 2 %COL%[33m]%COL%[37m Game Settings
echo.
echo.
echo.
echo.
echo                                     %COL%[33m[%COL%[37m 3 %COL%[33m]%COL%[37m Media         %COL%[33m[%COL%[37m 4 %COL%[33m]%COL%[90m Privacy        %COL%[33m[%COL%[37m 5 %COL%[33m]%COL%[90m Aesthetics
echo.
echo.
echo.
echo.
echo                                               %COL%[33m[%COL%[37m 6 %COL%[33m]%COL%[37m Advanced           %COL%[33m[%COL%[37m 7 %COL%[33m]%COL%[37m More
echo.
echo.
echo.
echo.
echo.
echo.
echo                                                            %COL%[31m[ X to close ]%COL%[37m
echo.
%SYSTEMROOT%\System32\choice.exe /c:1234567XD /n /m "%DEL%                                        Select a corresponding number to the options above > "
set choice=%errorlevel%
if "%choice%"=="1" set PG=TweaksPG1 & goto Tweaks
if "%choice%"=="2" goto GameSettings
if "%choice%"=="3" goto HoneRenders
if "%choice%"=="4" call:Comingsoon
if "%choice%"=="5" call:Comingsoon
if "%choice%"=="6" goto disclaimer2
if "%choice%"=="7" goto More
if "%choice%"=="8" exit /b
if "%choice%"=="9" goto Dog
goto MainMenu

:HoneTitle
echo                                       %COL%[33m+N.
echo                            //        oMMs
echo                           +Nm`    ``yMMm-     ::::::::     ::::    :::    ::::::::::
echo                        ``dMMsoyhh-hMMd.     :+:    :+:    :+:+:   :+:    :+:
echo                        `yy/MMMMNh:dMMh`    +:+    +:+    :+:+:+  +:+    +:+                 +::+:+::      +::+:+::
echo                       .hMM.sso++:oMMs`    +#+    +:+    +#+ +:+ +#+    +#++:++#           ++:    #++    ++:    #++
echo                      -mMMy:osyyys.No     +#+    +#+    +#+  +#+#+#    +#+                +#+    +#+    +#+    +#+
echo                     :NMMs-oo+/syy:-     #+#    #+#    #+#   #+#+#    #+#          %COL%[37m#+#%COL%[33m    +#+   #+#     #+#   #+#
echo                    /NMN+ ``   :ys.      ########     ###    ####    ##########   %COL%[37m###%COL%[33m       ######        ######
echo                   `NMN:        +.                                                      ##    ###     ##    ###
echo                   om-                                                                   #######       #######
echo                    `.
goto :eof

:Comingsoon
cls
echo.
echo.
call :HoneTitle
echo.
echo                                        %COL%[90m HoneCtrl is a free and open-source desktop utility
echo                                        %COL%[90m    made to improve your day-to-day productivity
echo.
echo.
echo.
echo.
echo                                  %COL%[31m This feature has not been finished yet but will be coming soon.
echo.
echo.
echo.
echo.
echo                                                    %COL%[97m[ Press any key to go back ]%COL%[37m
pause >nul
goto :eof

:Tweaks
Mode 130,45
TITLE Hone Control Panel %localtwo%
set "choice="
set "BLANK=   "
REM Check Values
for %%i in (PWROF MEMOF AUDOF TMROF NETOF AFFOF MOUOF AFTOF NICOF DSSOF SERVOF DEBOF MITOF ME2OF NPIOF NVIOF NVTOF HDCOF CMAOF ALLOF MSIOF TCPOF DWCOF CRSOF) do (set "%%i=%COL%[92mON ") >nul 2>&1
(
	REM MSI Mode
	for /f %%g in ('wmic path win32_VideoController get PNPDeviceID ^| findstr /L "VEN_"') do (
		reg query "HKLM\SYSTEM\CurrentControlSet\Enum\%%g\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" | find "0x1" || set "MSIOF=%COL%[91mOFF"
		reg query "HKLM\System\CurrentControlSet\Enum\%%g\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" && set "MSIOF=%COL%[91mOFF"
	)
	for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID ^| findstr /L "VEN_"') do (
		reg query "HKLM\SYSTEM\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" | find "0x1" || set "MSIOF=%COL%[91mOFF"
		reg query "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" && set "MSIOF=%COL%[91mOFF"
	)
	REM Services Optimization
	for /f "tokens=2 delims==" %%i in ('wmic os get TotalVisibleMemorySize /value') do (set /a mem=%%i + 1024000)
	for /f "tokens=3" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control" /v "SvcHostSplitThresholdInKB"') do (set /a currentmem=%%a)
	if "!currentmem!" neq "!mem!" set "MEMOF=%COL%[91mOFF"
	REM Nvidia Telemetry
	reg query "HKCU\Software\Hone" /v "NVTTweaks" || set "NVTOF=%COL%[91mOFF"
	REM Nvidia HDCP
	for /f %%a in ('reg query "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /t REG_SZ /s /e /f "NVIDIA" ^| findstr "HKEY"') do reg query "%%a" /v "RMHdcpKeyglobZero" | find "0x1" || set "HDCOF=%COL%[91mOFF"
	REM Disable Preemption
	reg query "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisablePreemption" | find "0x1" || set "CMAOF=%COL%[91mOFF"
	reg query "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisableCudaContextPreemption" | find "0x1" || set "CMAOF=%COL%[91mOFF"
	reg query "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "EnableCEPreemption" | find "0x0" || set "CMAOF=%COL%[91mOFF"
	reg query "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisablePreemptionOnS3S4" | find "0x1" || set "CMAOF=%COL%[91mOFF"
	reg query "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "ComputePreemption" | find "0x0" || set "CMAOF=%COL%[91mOFF"
	REM CSRSS
	reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\csrss.exe\PerfOptions" /v CpuPriorityClass | find "0x4" || set "CRSOF=%COL%[91mOFF"
	reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\csrss.exe\PerfOptions" /v IoPriority | find "0x3" || set "CRSOF=%COL%[91mOFF"
	REM Power Plan
	powercfg /GetActiveScheme | find "Hone" || set "PWROF=%COL%[91mOFF"
	REM All GPU Tweaks
	reg query "HKCU\Software\Hone" /v "AllGPUTweaks" || set "ALLOF=%COL%[91mOFF"
	REM Profile Inspector Tweaks
	reg query "HKCU\Software\Hone" /v "NpiTweaks" || set "NPIOF=%COL%[91mOFF"
	REM TCPIP
	reg query "HKCU\Software\Hone" /v "TCPIP" || set "TCPOF=%COL%[91mOFF"
	REM Nvidia Tweaks
	reg query "HKCU\Software\Hone" /v "NvidiaTweaks" || set "NVIOF=%COL%[91mOFF"
	REM Memory Optimization
	reg query "HKCU\Software\Hone" /v "MemoryTweaks" || set "ME2OF=%COL%[91mOFF"
	REM Network Internet Tweaks
	reg query "HKCU\Software\Hone" /v "InternetTweaks" || set "NETOF=%COL%[91mOFF"
	REM Services Tweaks
	reg query "HKCU\Software\Hone" /v "ServicesTweaks" || set "SERVOF=%COL%[91mOFF"
	REM Debloat Tweaks
	reg query "HKCU\Software\Hone" /v "DebloatTweaks" || set "DEBOF=%COL%[91mOFF"
	REM Mitigations Tweaks
	reg query "HKCU\Software\Hone" /v "MitigationsTweaks" || set "MITOF=%COL%[91mOFF"
	REM Affinities
	reg query "HKCU\Software\Hone" /v "AffinityTweaks" || set "AFFOF=%COL%[91mOFF"
	REM DisableWriteCombining
	reg query "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisableWriteCombining" || set "DWCOF=%COL%[91mOFF"
	REM Mouse Fix
	reg query "HKCU\Control Panel\Mouse" /v "SmoothMouseYCurve" | find "0000000000000000000038000000000000007000000000000000A800000000000000E00000000000" || set "MOUOF=%COL%[91mOFF"
	REM NIC
	if not exist "%SYSTEMDRIVE%\Hone\HoneRevert\ognic1.reg" set "NICOF=%COL%[91mOFF"
	REM Intel iGPU
	reg query "HKLM\SOFTWARE\Intel\GMM" /v "DedicatedSegmentSize" | find "0x400" || set "DSSOF=%COL%[91mOFF"
	REM Timer Res
	sc query STR | find "RUNNING" || set "TMROF=%COL%[91mOFF"
	REM Audio Service
	sc query HoneAudio | find "RUNNING" || set "AUDOF=%COL%[91mOFF"
	REM Check If Applicable For PC
	REM Laptop
	wmic path Win32_Battery Get BatteryStatus | find "1" && set "PWROF=%COL%[93mN/A"
	REM GPU
	for /f "tokens=2 delims==" %%a in ('wmic path Win32_VideoController get VideoProcessor /value') do (
		for %%n in (GeForce NVIDIA RTX GTX) do echo %%a | find "%%n" >nul && set "NVIDIAGPU=Found"
		for %%n in (AMD Ryzen) do echo %%a | find "%%n" >nul && set "AMDGPU=Found"
		for %%n in (Intel UHD) do echo %%a | find "%%n" >nul && set "INTELGPU=Found"
	)
	if "!NVIDIAGPU!" neq "Found" for %%g in (HDCOF CMAOF NPIOF NVTOF NVIOF) do set "%%g=%COL%[93mN/A"
	if "!AMDGPU!" neq "Found" for %%g in (AMDOF) do set "%%g=%COL%[93mN/A"
	if "!INTELGPU!" neq "Found" for %%g in (DSSOF) do set "%%g=%COL%[93mN/A"
) >nul 2>&1

goto %PG%
:TweaksPG1
cls
echo.
echo                                                                                                                        %COL%[36mPage 1/2
call :HoneTitle
echo                                                               %COL%[1;4;34mTweaks%COL%[0m
echo.
echo              %COL%[33m[%COL%[37m 1 %COL%[33m]%COL%[37m Power Plan %PWROF%                 %COL%[33m[%COL%[37m 2 %COL%[33m]%COL%[37m SvcHostSplitThreshold %MEMOF%      %COL%[33m[%COL%[37m 3 %COL%[33m]%COL%[37m CSRSS High Priority %CRSOF%
echo              %COL%[90mDesktop Power Plan, not good         %COL%[90mChanges the split threshold for      %COL%[90mCSRSS is responsible for mouse input
echo              %COL%[90mto use with a laptop battery.        %COL%[90mservice host to your RAM             %COL%[90mset to high to improve input latency
echo.
echo              %COL%[33m[%COL%[37m 4 %COL%[33m]%COL%[37m Timer Resolution %TMROF%           %COL%[33m[%COL%[37m 5 %COL%[33m]%COL%[37m MSI Mode %MSIOF%                   %COL%[33m[%COL%[37m 6 %COL%[33m]%COL%[37m Affinity %AFFOF%
echo              %COL%[90mThis tweak changes how fast          %COL%[90mEnable MSI Mode for gpu and          %COL%[90mThis tweak will spread devices
echo              %COL%[90myour cpu refreshes                   %COL%[90mnetwork adapters                     %COL%[90mon multiple cpu cores
echo.
echo              %COL%[33m[%COL%[37m 7 %COL%[33m]%COL%[37m W32 Priority Seperation %BLANK%    %COL%[33m[%COL%[37m 8 %COL%[33m]%COL%[37m Memory Optimization %ME2OF%        %COL%[33m[%COL%[37m 9 %COL%[33m]%COL%[37m Mouse Fix %MOUOF%
echo              %COL%[90mOptimizes the usage priority of      %COL%[90mOptimizes your fsutil, win           %COL%[90mThis removes acceleration which
echo              %COL%[90myour running services                %COL%[90mstartup settings and more            %COL%[90mmakes your aim inconsistent
echo.
echo                                                            %COL%[1;4;34mNvidia Tweaks%COL%[0m
echo.
echo              %COL%[33m[%COL%[37m 10 %COL%[33m]%COL%[37m Disable HDCP %HDCOF%              %COL%[33m[%COL%[37m 11 %COL%[33m]%COL%[37m Disable Preemption %CMAOF%        %COL%[33m[%COL%[37m 12 %COL%[33m]%COL%[37m ProfileInspector %NPIOF%
echo              %COL%[90mDisable copy protection technology   %COL%[90mDisable preemption requests from     %COL%[90mWill edit your Nvidia control panel
echo              %COL%[90mof illegal High Definition content   %COL%[90mthe GPU scheduler                    %COL%[90mand add various tweaks
echo.
echo              %COL%[33m[%COL%[37m 13 %COL%[33m]%COL%[37m Disable Nvidia Telemetry %NVTOF%  %COL%[33m[%COL%[37m 14 %COL%[33m]%COL%[37m Nvidia Tweaks %NVIOF%             %COL%[33m[%COL%[37m 15 %COL%[33m]%COL%[37m Disable Write Combining %DWCOF%
echo              %COL%[90mRemove built in Nvidia telemetry     %COL%[90mVarious essential tweaks for         %COL%[90mStops data from being combined
echo              %COL%[90mfrom your computer and driver.       %COL%[90mNvidia graphics cards                %COL%[90mand temporarily stored
echo.
echo.
echo.
echo                                     %COL%[90m[ B for back ]         %COL%[31m[ X to close ]         %COL%[36m[ N page two ]
echo.
set /p choice="%DEL%                                        %COL%[37mSelect a corresponding number to the options above > "
if /i "%choice%"=="1" goto PowerPlan
if /i "%choice%"=="2" goto ServicesOptimization
if /i "%choice%"=="3" goto CSRSS
if /i "%choice%"=="4" goto TimerRes
if /i "%choice%"=="5" goto MSI
if /i "%choice%"=="6" goto Affinity
if /i "%choice%"=="7" goto W32PrioSep
if /i "%choice%"=="8" goto MemOptimization
if /i "%choice%"=="9" goto Mouse
echo %NPIOF% | find "N/A" >nul && if "%choice%" geq "10" if "%choice%" leq "15" call :HoneCtrlError "You don't have an NVIDIA GPU" && goto Tweaks
if /i "%choice%"=="10" goto DisableHDCP
if /i "%choice%"=="11" goto DisablePreemtion
if /i "%choice%"=="12" goto ProfileInspector
if /i "%choice%"=="13" goto NVTelemetry
if /i "%choice%"=="14" goto NvidiaTweaks
if /i "%choice%"=="15" goto DisableWriteCombining
if /i "%choice%"=="X" exit /b
if /i "%choice%"=="B" goto MainMenu
if /i "%choice%"=="N" (set "PG=TweaksPG2") & goto TweaksPG2
goto Tweaks

:TweaksPG2
cls
echo.
echo                                                                                                                        %COL%[36mPage 2/2
call :HoneTitle
echo                                                           %COL%[1;4;34mNetwork Tweaks%COL%[0m
echo.
echo              %COL%[33m[%COL%[37m 1 %COL%[33m]%COL%[37m Optimize TCP/IP %TCPOF%            %COL%[33m[%COL%[37m 2 %COL%[33m]%COL%[37m Optimize NIC %NICOF%               %COL%[33m[%COL%[37m 3 %COL%[33m]%COL%[37m Optimize Netsh %NETOF%
echo              %COL%[90mTweaks your Internet Protocol        %COL%[90mOptimize your Network Card settings  %COL%[90mThis tweak will optimize your
echo              %COL%[91mDon't use if you are using Wi-Fi     %COL%[91mDon't use if you are using Wi-Fi     %COL%[90mcomputer network configuration
echo.
echo                                                             %COL%[1;4;34mGPU ^& CPU%COL%[0m
echo.
echo              %COL%[33m[%COL%[37m 4 %COL%[33m]%COL%[37m All GPU Tweaks %ALLOF%             %COL%[33m[%COL%[37m 5 %COL%[33m]%COL%[37m Optimize Intel iGPU %DSSOF%        %COL%[33m[%COL%[37m 6 %COL%[33m]%COL%[37m AMD GPU Tweaks %AMDOF%
echo              %COL%[90mVarious essential tweaks for all     %COL%[90mIncrease dedicated video vram on     %COL%[90mConfigure AMD GPU to optimized
echo              %COL%[90mGPU brands and manufacturers         %COL%[90ma intel iGPU                         %COL%[90msettings
echo                                                               %COL%[1;4;34mBloat%COL%[0m
echo.
echo                                                        %COL%[1;4;34mMiscellaneous Tweaks%COL%[0m
echo.
echo              %COL%[33m[%COL%[37m 7 %COL%[33m]%COL%[37m Reduce Audio Latency %AUDOF%       %COL%[33m[%COL%[37m 8 %COL%[33m]%COL%[37m Debloat %COL%[93mN/A                    %COL%[33m[%COL%[37m 9 %COL%[33m]%COL%[37m Disable Mitigations %MITOF%
echo              %COL%[90mReduces Audio Latency  		  %COL%[91mComing Soon			       %COL%[90mDisable protections against memory
echo              %COL%[91mDon't use on slow or old CPU's	  %COL%[90m				       %COL%[90mbased attacks that consume perf
echo.
echo              %COL%[33m[%COL%[37m 10 %COL%[33m]%COL%[37m Cleaner %BLANK%                   %COL%[33m[%COL%[37m 11 %COL%[33m]%COL%[37m Game-Booster %BLANK%              %COL%[33m[%COL%[37m 12 %COL%[33m]%COL%[37m Soft Restart %BLANK%
echo              %COL%[90mRemove adware, unused devices, and   %COL%[90mSets GPU ^& CPU to high performance   %COL%[90mIf your PC has been running a while
echo              %COL%[90mtemp files. Empties recycle bin.     %COL%[90mDisables fullscreen optimizations    %COL%[90muse this to receive a quick boost
echo.
echo.
echo.
echo                                     %COL%[90m[ B for back ]         %COL%[31m[ X to close ]         %COL%[36m[ N page one ]
echo.
set /p choice="%DEL%                                        %COL%[37mSelect a corresponding number to the options above > "
if /i "%choice%"=="1" goto TCPIP
if /i "%choice%"=="2" goto NIC
if /i "%choice%"=="3" goto Netsh
if /i "%choice%"=="4" goto AllGPUTweaks
if /i "%choice%"=="5" goto Intel
if /i "%choice%"=="6" goto AMD
if /i "%choice%"=="7" goto AudioLatency
if /i "%choice%"=="8" call:Comingsoon
if /i "%choice%"=="9" goto Mitigations
if /i "%choice%"=="10" call:Cleaner
if /i "%choice%"=="11" call:gameBooster
if /i "%choice%"=="12" call:softRestart
if /i "%choice%"=="X" exit /b
if /i "%choice%"=="B" goto MainMenu
if /i "%choice%"=="N" (set "PG=TweaksPG1") & goto TweaksPG1
goto TweaksPG2

:PowerPlan
echo %PWROF% | find "N/A" >nul && call :HoneCtrlError "This power plan isn't recommended for batteries." && goto Tweaks
if "%PWROF%" == "%COL%[91mOFF" (
	curl -g -k -L -# -o "%SYSTEMDRIVE%\Hone\Resources\HoneV2.pow" "https://github.com/auraside/HoneCtrl/raw/main/Files/HoneV2.pow"
	powercfg /d 44444444-4444-4444-4444-444444444449
	powercfg -import "%SYSTEMDRIVE%\Hone\Resources\HoneV2.pow" 44444444-4444-4444-4444-444444444449
	powercfg /changename 44444444-4444-4444-4444-444444444449 "Hone Ultimate Power Plan V2" "The Ultimate Power Plan to increase FPS, improve latency and reduce input lag."
REM Enable Idle on Hyper-Threading
set THREADS=%NUMBER_OF_PROCESSORS%
	for /f "tokens=2 delims==" %%n in ('wmic cpu get numberOfCores /value') do set CORES=%%n
	if "%CORES%" == "%NUMBER_OF_PROCESSORS%" (
		powercfg -setacvalueindex 44444444-4444-4444-4444-444444444449 sub_processor IDLEDISABLE 1
) else (
		powercfg -setacvalueindex 44444444-4444-4444-4444-444444444449 sub_processor IDLEDISABLE 0 
)
	powercfg -setacvalueindex 44444444-4444-4444-4444-444444444449 sub_processor IDLEDISABLE 0
	powercfg -setactive "44444444-4444-4444-4444-444444444449"
) >nul 2>&1 else (
	powercfg -restoredefaultschemes
) >nul 2>&1
goto tweaks

:ServicesOptimization
if "%MEMOF%" == "%COL%[91mOFF" (
	for /f "tokens=2 delims==" %%i in ('wmic os get TotalVisibleMemorySize /value') do set /a mem=%%i + 1024000
		reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control" /v "SvcHostSplitThresholdInKB" /t REG_DWORD /d %mem% /f
) >nul 2>&1 else (
	reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control" /v "SvcHostSplitThresholdInKB" /t REG_DWORD /d 3670016 /f
) >nul 2>&1
goto tweaks

:TimerRes
cd %SYSTEMDRIVE%\Hone\Resources
sc config "STR" start= auto >nul 2>&1
start /b net start STR >nul 2>&1
if "%TMROF%" == "%COL%[91mOFF" (
	if not exist SetTimerResolutionService.exe (
		REM https://forums.guru3d.com/threads/windows-timer-resolution-tool-in-form-of-system-service.376458/
		curl -g -L -# -o "%SYSTEMDRIVE%\Hone\Resources\SetTimerResolutionService.exe" "https://github.com/auraside/HoneCtrl/raw/main/Files/SetTimerResolutionService.exe"
		%SYSTEMROOT%\Microsoft.NET\Framework\v4.0.30319\InstallUtil.exe /i SetTimerResolutionService.exe
	)
	sc config "STR" start=auto
	start /b net start STR
	bcdedit /set disabledynamictick yes
	bcdedit /deletevalue useplatformclock
	for /F "tokens=2 delims==" %%G in (
		'wmic OS get buildnumber /value'
	) do @for /F "tokens=*" %%x in ("%%G") do (
		set "VAR=%%~x"
	)
	if !VAR! geq 19042 (
		bcdedit /deletevalue useplatformtick
	)
	if !VAR! lss 19042 (
		bcdedit /set useplatformtick yes
	)
) >nul 2>&1 else (
	sc config "STR" start=disabled
	start /b net stop STR
	bcdedit /deletevalue useplatformclock
	bcdedit /deletevalue useplatformtick
	bcdedit /deletevalue disabledynamictick
) >nul 2>&1
goto tweaks

REM :KBoost
REM if "%KBOOF%" == "%COL%[91mOFF" (
	REM for /f %%i in ('reg query "HKLM\System\ControlSet001\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /t REG_SZ /s /e /f "NVIDIA" ^| findstr "HKEY"') do (
		REM reg add "%%a" /v "PowerMizerEnable" /t REG_DWORD /d "1" /f
		REM reg add "%%a" /v "PowerMizerLevel" /t REG_DWORD /d "1" /f
		REM reg add "%%a" /v "PowerMizerLevelAC" /t REG_DWORD /d "1" /f
		REM reg add "%%a" /v "PerfLevelSrc" /t REG_DWORD /d "8738" /f
	REM )
REM ) >nul 2>&1 else (
	REM for /f %%i in ('reg query "HKLM\System\ControlSet001\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /t REG_SZ /s /e /f "NVIDIA" ^| findstr "HKEY"') do (
		REM reg delete "%%a" /v "PowerMizerEnable" /f 
		REM reg delete "%%a" /v "PowerMizerLevel" /f
		REM reg delete "%%a" /v "PowerMizerLevelAC" /f
		REM reg delete "%%a" /v "PerfLevelSrc" /f
	REM )
REM ) >nul 2>&1
REM call :HoneCtrlRestart "KBoost" "%KBOOF%"
REM Mode 130,45
REM goto Tweaks

:CSRSS
if "%CRSOF%" == "%COL%[91mOFF" (
	reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\csrss.exe\PerfOptions" /v CpuPriorityClass /t Reg_DWORD /d "4" /f
	reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\csrss.exe\PerfOptions" /v IoPriority /t Reg_DWORD /d "3" /f
	reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NoLazyMode" /t REG_DWORD /d "1" /f
	reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "AlwaysOn" /t REG_DWORD /d "1" /f
	reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d "10" /f
	reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d "0" /f
) >nul 2>&1 else (
	reg delete "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\csrss.exe\PerfOptions" /v CpuPriorityClass /f
	reg delete "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\csrss.exe\PerfOptions" /v IoPriority /f
	reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NoLazyMode" /f
	reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "AlwaysOn" /f
	reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /f
	reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /f
) >nul 2>&1
goto Tweaks

:MSI
if "%MSIOF%" == "%COL%[91mOFF" (
	reg add "HKCU\Software\Hone" /v "MSIModeTweaks" /f
	for /f %%g in ('wmic path win32_VideoController get PNPDeviceID ^| findstr /L "VEN_"') do reg add "HKLM\SYSTEM\CurrentControlSet\Enum\%%g\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /t REG_DWORD /d "1" /f
	for /f %%g in ('wmic path win32_VideoController get PNPDeviceID ^| findstr /L "VEN_"') do reg delete "HKLM\System\CurrentControlSet\Enum\%%g\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" /f
	for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID ^| findstr /L "VEN_"') do reg add "HKLM\SYSTEM\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /t REG_DWORD /d "1" /f
	for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID ^| findstr /L "VEN_"') do reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" /f
) >nul 2>&1 else (
	reg delete "HKCU\Software\Hone" /v "MSIModeTweaks" /f
	for /f %%g in ('wmic path win32_VideoController get PNPDeviceID ^| findstr /L "VEN_"') do reg delete "HKLM\SYSTEM\CurrentControlSet\Enum\%%g\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /f
	for /f %%g in ('wmic path win32_VideoController get PNPDeviceID ^| findstr /L "VEN_"') do reg delete "HKLM\System\CurrentControlSet\Enum\%%g\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" /f
	for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID ^| findstr /L "VEN_"') do reg delete "HKLM\SYSTEM\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /f
	for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID ^| findstr /L "VEN_"') do reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority " /f
) >nul 2>&1
goto Tweaks

:Affinity
if "%AFFOF%" == "%COL%[91mOFF" (
reg add "HKCU\Software\Hone" /v AffinityTweaks /f
for /f "tokens=*" %%f in ('wmic cpu get NumberOfCores /value ^| find "="') do set %%f
for /f "tokens=*" %%f in ('wmic cpu get NumberOfLogicalProcessors /value ^| find "="') do set %%f
if "!NumberOfCores!" == "2" (
	cls
	echo You have 2 cores. Affinities won't work.
	pause
	reg delete "HKCU\Software\Hone" /v AffinityTweaks /f
	goto Tweaks
)
if !NumberOfCores! gtr 4 (
	for /f %%i in ('wmic path Win32_VideoController get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
		reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /t REG_DWORD /d "3" /f
		reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /f
	)
	for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
		reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /t REG_DWORD /d "5" /f
		reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /f
	)
)
if !NumberOfLogicalProcessors! gtr !NumberOfCores! (
REM HyperThreading Enabled
for /f %%i in ('wmic path Win32_USBController get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /t REG_DWORD /d "4" /f
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /t REG_BINARY /d "C0" /f
)
for /f %%i in ('wmic path Win32_VideoController get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /t REG_DWORD /d "4" /f
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /t REG_BINARY /d "C0" /f
)
for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /t REG_DWORD /d "4" /f
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /t REG_BINARY /d "30" /f
)
) else (
REM HyperThreading Disabled
for /f %%i in ('wmic path Win32_USBController get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /t REG_DWORD /d "4" /f
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /t REG_BINARY /d "08" /f
)
for /f %%i in ('wmic path Win32_VideoController get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /t REG_DWORD /d "4" /f
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /t REG_BINARY /d "02" /f
)
for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /t REG_DWORD /d "4" /f
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /t REG_BINARY /d "04" /f
)
)
) >nul 2>&1 else (
reg delete "HKCU\Software\Hone" /v AffinityTweaks /f
for /f %%i in ('wmic path Win32_USBController get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
	reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /f
	reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /f
)
for /f %%i in ('wmic path Win32_VideoController get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
	reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /f
	reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /f
)
for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
	reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /f
	reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /f
)
) >nul 2>&1
goto Tweaks

:W32PrioSep
cls
echo.
echo.
echo.
echo.
echo                                                                           %COL%[33m.
echo                                                                        +N.
echo                                                               //        oMMs
echo                                                              +Nm`    ``yMMm-
echo                                                           ``dMMsoyhh-hMMd.
echo                                                           `yy/MMMMNh:dMMh`
echo                                                          .hMM.sso++:oMMs`
echo                                                         -mMMy:osyyys.No
echo                                                        :NMMs-oo+/syy:-
echo                                                       /NMN+ ``   :ys.
echo                                                      `NMN:        +.
echo                                                      om-
echo                                                       `.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                    %COL%[33m[ %COL%[37m1 %COL%[33m] %COL%[37m26 Hex                                                   %COL%[33m[ %COL%[37m2 %COL%[33m] %COL%[37m28 Hex
echo                    %COL%[90mDefault                                                        %COL%[90mMight be better
echo                    %COL%[90mShort, Variable, High foreground boost.                        %COL%[90mShort, Fixed, No foreground boost.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                                       [ press X to go back ]
echo.
echo.
%SYSTEMROOT%\System32\choice.exe /c:12X /n /m "%DEL%                                                               >:"
if %errorlevel% == 3 goto Tweaks
if %errorlevel% == 1 reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d "38" /f >nul 2>&1
if %errorlevel% == 2 reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d "40" /f >nul 2>&1
goto Tweaks

:MemOptimization
if "%ME2OF%" == "%COL%[91mOFF" (
	reg add "HKCU\Software\Hone" /v "MemoryTweaks" /f
	REM Disable FTH
	reg add "HKLM\Software\Microsoft\FTH" /v "Enabled" /t Reg_DWORD /d "0" /f
	REM Disable Desktop Composition
	reg add "HKCU\Software\Microsoft\Windows\DWM" /v "Composition" /t REG_DWORD /d "0" /f
	REM Disable Background apps
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v "GlobalUserDisabled" /t Reg_DWORD /d "1" /f
	reg add "HKLM\Software\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsRunInBackground" /t Reg_DWORD /d "2" /f
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "BackgroundAppGlobalToggle" /t Reg_DWORD /d "0" /f
	REM Disallow drivers to get paged into virtual memory
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t Reg_DWORD /d "1" /f
	REM Disable Page Combining and Memory Compression
	powershell -NoProfile -Command "Disable-MMAgent -PagingCombining -mc"
	reg add "HKLM\System\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePageCombining" /t REG_DWORD /d "1" /f
	REM Use Large System Cache to improve microstuttering
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "LargeSystemCache" /t Reg_DWORD /d "1" /f
	REM Free unused ram
	reg add "HKLM\System\CurrentControlSet\Control\Session Manager" /v "HeapDeCommitFreeBlockThreshold" /t REG_DWORD /d "262144" /f
	REM Auto restart Powershell on error
	reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "AutoRestartShell" /t REG_DWORD /d "1" /f
	REM Disk Optimizations
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "DontVerifyRandomDrivers" /t REG_DWORD /d "1" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "LongPathsEnabled" /t REG_DWORD /d "0" /f
	REM Disable Prefetch and Superfetch
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /t Reg_DWORD /d "0" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableSuperfetch" /t Reg_DWORD /d "0" /f
	REM Disable Hibernation + Fast Startup
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d "0" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "HibernateEnabledDefault" /t REG_DWORD /d "0" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "HibernateEnabled" /t REG_DWORD /d "0" /f
	REM Wait time to kill app during shutdown
	reg add "HKCU\Control Panel\Desktop" /v "WaitToKillAppTimeout" /t Reg_SZ /d "1000" /f
	REM Wait to end service at shutdown
	reg add "HKLM\System\CurrentControlSet\Control" /v "WaitToKillServiceTimeout" /t Reg_SZ /d "1000" /f
	REM Wait to kill non-responding app
	reg add "HKCU\Control Panel\Desktop" /v "HungAppTimeout" /t Reg_SZ /d "1000" /f
	REM fsutil
	if exist "%SYSTEMROOT%\System32\fsutil.exe" (
		REM Raise the limit of paged pool memory
		fsutil behavior set memoryusage 2
		REM https://www.serverbrain.org/solutions-2003/the-mft-zone-can-be-optimized.html
		fsutil behavior set mftzone 2
		REM Disable Last Access information on directories, performance/privacy
		fsutil behavior set disablelastaccess 1
		REM Disable Virtual Memory Pagefile Encryption
		fsutil behavior set encryptpagingfile 0
		REM Disables the creation of legacy 8.3 character-length file names on FAT- and NTFS-formatted volumes.
		fsutil behavior set disable8dot3 1
		REM Disable NTFS compression
		fsutil behavior set disablecompression 1
		REM Enable Trim
		fsutil behavior set disabledeletenotify 0
	)
) >nul 2>&1 else (
	reg delete "HKCU\Software\Hone" /v MemoryTweaks /f
	REM Delete FTH
	reg delete "HKLM\Software\Microsoft\FTH" /v "Enabled" /f
	REM Delete Desktop Composition
	reg delete "HKCU\Software\Microsoft\Windows\DWM" /v "Composition" /f
	REM Enable Background apps
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v "GlobalUserDisabled" /f
	reg delete "HKLM\Software\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsRunInBackground" /f
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "BackgroundAppGlobalToggle" /f
	REM Disallow drivers to get paged into virtual memory
	reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /f
	REM Enable Page Combining and memory compression
	powershell -NoProfile -Command "Enable-MMAgent -PagingCombining -mc"
	REM Use Large System Cache to improve microstuttering
	reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "LargeSystemCache" /f
	REM Don't free unused ram
	reg delete "HKLM\System\CurrentControlSet\Control\Session Manager" /v "HeapDeCommitFreeBlockThreshold" /f
	REM Don't restart Powershell on error
	reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "AutoRestartShell" /t REG_DWORD /d "0" /f
	REM Disk Optimizations
	reg delete "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "DontVerifyRandomDrivers" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "LongPathsEnabled" /f
	REM Enable Prefetch
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /t Reg_DWORD /d "3" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableSuperfetch" /t Reg_DWORD /d "3" /f
	REM Background Apps
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v "GlobalUserDisabled" /t Reg_DWORD /d "0" /f
	reg delete "HKLM\Software\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsRunInBackground" /f
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "BackgroundAppGlobalToggle" /t Reg_DWORD /d "1" /f
	REM Hibernation + Fast Startup
	reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "HiberbootEnabled" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "HibernateEnabledDefault" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "HibernateEnabled" /f
	REM Wait time to kill app during shutdown
	reg add "HKCU\Control Panel\Desktop" /v "WaitToKillAppTimeout" /t Reg_SZ /d "20000" /f
	REM Wait to end service at shutdown
	reg add "HKLM\System\CurrentControlSet\Control" /v "WaitToKillServiceTimeout" /t Reg_SZ /d "20000" /f
	REM Wait to kill non-responding app
	reg add "HKCU\Control Panel\Desktop" /v "HungAppTimeout" /t Reg_SZ /d "5000" /f
	REM fsutil
	if exist "%SYSTEMROOT%\System32\fsutil.exe" (
		REM Set default limit of paged pool memory
		fsutil behavior set memoryusage 1
		REM https://www.serverbrain.org/solutions-2003/the-mft-zone-can-be-optimized.html
		fsutil behavior set mftzone 1
		REM Default Last Access information on directories, performance/privacy value
		fsutil behavior set disablelastaccess 2
		REM Default Virtual Memory Pagefile Encryption value
		fsutil behavior set encryptpagingfile 0
		REM Default creation of legacy 8.3 character-length file names on FAT- and NTFS-formatted volumes value
		fsutil behavior set disable8dot3 1
		REM Default NTFS compression
		fsutil behavior set disablecompression 0
		REM Enable Trim
		fsutil behavior set disabledeletenotify 0
	)
) >nul 2>&1
call :HoneCtrlRestart "Memory Optimization" "%ME2OF%"
Mode 130,45
goto Tweaks

:Mouse
cls
if "%MOUOF%" neq "%COL%[91mOFF" (
	reg add "HKEY_CURRENT_USER\Control Panel\Mouse" /v "SmoothMouseXCurve" /t REG_BINARY /d "0000000000000000156e000000000000004001000000000029dc0300000000000000280000000000" /f
	reg add "HKEY_CURRENT_USER\Control Panel\Mouse" /v "SmoothMouseYCurve" /t REG_BINARY /d "0000000000000000fd11010000000000002404000000000000fc12000000000000c0bb0100000000" /f
	goto tweaks
) >nul 2>&1
reg add "HKCU\Control Panel\Mouse" /v "MouseSpeed" /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Mouse" /v "MouseThreshold1" /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Mouse" /v "MouseThreshold2" /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Mouse" /v "MouseSensitivity" /t REG_SZ /d "10" /f >nul 2>&1
reg add "HKCU\Control Panel\Mouse" /v "SmoothMouseYCurve" /t REG_BINARY /d "0000000000000000000038000000000000007000000000000000A800000000000000E00000000000" /f >nul 2>&1
control.exe desk.cpl,Settings,@Settings
:ChooseScale
echo What is your current display scaling percentage? 100, 125, 150, 175, 200, 225, 250, 300, 350 (Don't put a %% symbol)
set /p choice=" Scale > "
if /i "%choice%"=="100" reg add "HKCU\Control Panel\Mouse" /v "SmoothMouseXCurve" /t REG_BINARY /d "0000000000000000C0CC0C0000000000809919000000000040662600000000000033330000000000" /f >nul 2>&1 & goto MouseEnd
if /i "%choice%"=="125" reg add "HKCU\Control Panel\Mouse" /v "SmoothMouseXCurve" /t REG_BINARY /d "00000000000000000000100000000000000020000000000000003000000000000000400000000000" /f >nul 2>&1 & goto MouseEnd
if /i "%choice%"=="150" reg add "HKCU\Control Panel\Mouse" /v "SmoothMouseXCurve" /t REG_BINARY /d "0000000000000000303313000000000060662600000000009099390000000000C0CC4C0000000000" /f >nul 2>&1 & goto MouseEnd
if /i "%choice%"=="175" reg add "HKCU\Control Panel\Mouse" /v "SmoothMouseXCurve" /t REG_BINARY /d "00000000000000006066160000000000C0CC2C000000000020334300000000008099590000000000" /f >nul 2>&1 & goto MouseEnd
if /i "%choice%"=="200" reg add "HKCU\Control Panel\Mouse" /v "SmoothMouseXCurve" /t REG_BINARY /d "000000000000000090991900000000002033330000000000B0CC4C00000000004066660000000000" /f >nul 2>&1 & goto MouseEnd
if /i "%choice%"=="225" reg add "HKCU\Control Panel\Mouse" /v "SmoothMouseXCurve" /t REG_BINARY /d "0000000000000000C0CC1C0000000000809939000000000040665600000000000033730000000000" /f >nul 2>&1 & goto MouseEnd
if /i "%choice%"=="250" reg add "HKCU\Control Panel\Mouse" /v "SmoothMouseXCurve" /t REG_BINARY /d "00000000000000000000200000000000000040000000000000006000000000000000800000000000" /f >nul 2>&1 & goto MouseEnd
if /i "%choice%"=="300" reg add "HKCU\Control Panel\Mouse" /v "SmoothMouseXCurve" /t REG_BINARY /d "00000000000000006066260000000000C0CC4C000000000020337300000000008099990000000000" /f >nul 2>&1 & goto MouseEnd
if /i "%choice%"=="350" reg add "HKCU\Control Panel\Mouse" /v "SmoothMouseXCurve" /t REG_BINARY /d "0000000000000000C0CC2C0000000000809959000000000040668600000000000033B30000000000" /f >nul 2>&1 & goto MouseEnd
goto ChooseScale
:MouseEnd
call :HoneCtrlRestart "Mouse Tweaks" "%MOUOF%"
Mode 130,45
goto tweaks

:DisableHDCP
for /f %%a in ('reg query "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /t REG_SZ /s /e /f "NVIDIA" ^| findstr "HKEY"') do (
	if "%HDCOF%" == "%COL%[91mOFF" (
		reg add "HKCU\Software\Hone" /v HDCTweaks /f
		reg add "%%a" /v "RMHdcpKeyglobZero" /t REG_DWORD /d "1" /f
	) else (
		reg delete "HKCU\Software\Hone" /v HDCTweaks /f
		reg add "%%a" /v "RMHdcpKeyglobZero" /t REG_DWORD /d "0" /f
	)
) >nul 2>&1
goto Tweaks

:DisablePreemtion
if "%CMAOF%" == "%COL%[91mOFF" (
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisablePreemption" /t Reg_DWORD /d "1" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisableCudaContextPreemption" /t Reg_DWORD /d "1" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "EnableCEPreemption" /t Reg_DWORD /d "0" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisablePreemptionOnS3S4" /t Reg_DWORD /d "1" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "ComputePreemption" /t Reg_DWORD /d "0" /f
) >nul 2>&1 else (
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisablePreemption" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisableCudaContextPreemption" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "EnableCEPreemption" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisablePreemptionOnS3S4" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "ComputePreemption" /f
) >nul 2>&1
goto Tweaks

:ProfileInspector
if "%NPIOF%" == "%COL%[91mOFF" (
	reg add "HKCU\Software\Hone" /v NpiTweaks /f
	rmdir /S /Q "%SYSTEMDRIVE%\Hone\Resources\nvidiaProfileInspector\"
	curl -g -L -# -o %SYSTEMDRIVE%\Hone\Resources\nvidiaProfileInspector.zip "https://github.com/Orbmu2k/nvidiaProfileInspector/releases/latest/download/nvidiaProfileInspector.zip"
	powershell -NoProfile Expand-Archive '%SYSTEMDRIVE%\Hone\Resources\nvidiaProfileInspector.zip' -DestinationPath '%SYSTEMDRIVE%\Hone\Resources\nvidiaProfileInspector\'
	del /F /Q "%SYSTEMDRIVE%\Hone\Resources\nvidiaProfileInspector.zip"
	curl -g -L -# -o "%SYSTEMDRIVE%\Hone\Resources\nvidiaProfileInspector\Latency_and_Performances_Settings_by_Hone_Team2.nip" "https://raw.githubusercontent.com/auraside/HoneCtrl/main/Files/Latency_and_Performances_Settings_by_Hone_Team2.nip"
	cd "%SYSTEMDRIVE%\Hone\Resources\nvidiaProfileInspector\"
	nvidiaProfileInspector.exe "Latency_and_Performances_Settings_by_Hone_Team2.nip"
) >nul 2>&1 else (
	rem https://github.com/Orbmu2k/nvidiaProfileInspector/releases/latest/download/nvidiaProfileInspector.zip
	reg delete "HKCU\Software\Hone" /v NpiTweaks /f
	rmdir /S /Q "%SYSTEMDRIVE%\Hone\Resources\nvidiaProfileInspector\"
	curl -g -L -# -o %SYSTEMDRIVE%\Hone\Resources\nvidiaProfileInspector.zip "https://github.com/Orbmu2k/nvidiaProfileInspector/releases/latest/download/nvidiaProfileInspector.zip"
	powershell -NoProfile Expand-Archive '%SYSTEMDRIVE%\Hone\Resources\nvidiaProfileInspector.zip' -DestinationPath '%SYSTEMDRIVE%\Hone\Resources\nvidiaProfileInspector\'
	del /F /Q "%SYSTEMDRIVE%\Hone\Resources\nvidiaProfileInspector.zip"
	curl -g -L -# -o "%SYSTEMDRIVE%\Hone\Resources\nvidiaProfileInspector\Base_Profile.nip" "https://raw.githubusercontent.com/auraside/HoneCtrl/main/Files/Base_Profile.nip"
	cd "%SYSTEMDRIVE%\Hone\Resources\nvidiaProfileInspector\"
	nvidiaProfileInspector.exe "Base_Profile.nip"
) >nul 2>&1
goto Tweaks

:NVTelemetry
if "%NVTOF%" == "%COL%[91mOFF" (
	reg add "HKCU\Software\Hone" /v NVTTweaks /f
	reg add "HKLM\SOFTWARE\NVIDIA Corporation\NvControlPanel2\Client" /v "OptInOrOutPreference" /t REG_DWORD /d 0 /f
	reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID44231" /t REG_DWORD /d 0 /f
	reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID64640" /t REG_DWORD /d 0 /f
	reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID66610" /t REG_DWORD /d 0 /f
	reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "NvBackend" /f
	schtasks /change /disable /tn "NvTmRep_CrashReport1_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}"
	schtasks /change /disable /tn "NvTmRep_CrashReport2_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}"
	schtasks /change /disable /tn "NvTmRep_CrashReport3_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}"
	schtasks /change /disable /tn "NvTmRep_CrashReport4_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}"
) >nul 2>&1 else (
	reg delete "HKCU\Software\Hone" /f
	reg delete "HKLM\SOFTWARE\NVIDIA Corporation\NvControlPanel2\Client" /v "OptInOrOutPreference" /f
	reg delete "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID44231" /f
	reg delete "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID64640" /f
	reg delete "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID66610" /f
	schtasks /change /enable /tn "NvTmRep_CrashReport1_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}"
	schtasks /change /enable /tn "NvTmRep_CrashReport2_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}"
	schtasks /change /enable /tn "NvTmRep_CrashReport3_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}"
	schtasks /change /enable /tn "NvTmRep_CrashReport4_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}"
) >nul 2>&1
goto tweaks

:NvidiaTweaks
if "%NVIOF%" == "%COL%[91mOFF" (
	reg add "HKCU\Software\Hone" /v "NvidiaTweaks" /f
	rem Nvidia Reg
	reg add "HKCU\Software\NVIDIA Corporation\Global\NVTweak\Devices\509901423-0\Color" /v "NvCplUseColorCorrection" /t Reg_DWORD /d "0" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "PlatformSupportMiracast" /t Reg_DWORD /d "0" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global\NVTweak" /v "DisplayPowerSaving" /t Reg_DWORD /d "0" /f
	rem Unrestricted Clocks
	cd "%SYSTEMDRIVE%\Program Files\NVIDIA Corporation\NVSMI\"
	nvidia-smi -acp UNRESTRICTED
	nvidia-smi -acp DEFAULT
	rem Nvidia Registry Key
	for /f %%a in ('reg query "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /t REG_SZ /s /e /f "NVIDIA" ^| findstr "HKEY"') do (
		rem Disalbe Tiled Display
		reg add "%%a" /v "EnableTiledDisplay" /t REG_DWORD /d "0" /f
		rem Disable TCC
		reg add "%%a" /v "TCCSupported" /t REG_DWORD /d "0" /f
	)
	rem Silk Smoothness Option
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\FTS" /v "EnableRID61684" /t REG_DWORD /d "1" /f
) >nul 2>&1 else (
	reg delete "HKCU\Software\Hone" /v "NvidiaTweaks" /f
	rem Nvidia Reg
	reg delete "HKCU\Software\NVIDIA Corporation\Global\NVTweak\Devices\509901423-0\Color" /v "NvCplUseColorCorrection" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "PlatformSupportMiracast" /t Reg_DWORD /d "1" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global\NVTweak" /v "DisplayPowerSaving" /f
	rem Nvidia Registry Key
	for /f %%a in ('reg query "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /t REG_SZ /s /e /f "NVIDIA" ^| findstr "HKEY"') do (
		rem Reset Tiled Display
		reg delete "%%a" /v "EnableTiledDisplay" /f
		rem Reset TCC
		reg delete "%%a" /v "TCCSupported" /f
	)
) >nul 2>&1
goto Tweaks

:DisableWriteCombining
if "%DWCOF%" == "%COL%[91mOFF" (
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisableWriteCombining" /t Reg_DWORD /d "1" /f
) >nul 2>&1 else (
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisableWriteCombining" /f
) >nul 2>&1
goto Tweaks

:Mitigations
if "%MITOF%" == "%COL%[91mOFF" (
	reg add "HKCU\Software\Hone" /v MitigationsTweaks /f
	REM Turn Core Isolation Memory Integrity OFF
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v "Enabled" /t REG_DWORD /d "0" /f
	REM Disable SEHOP
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "DisableExceptionChainValidation" /t Reg_DWORD /d "1" /f
	REM Disable Spectre And Meltdown
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettings" /t REG_DWORD /d "1" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverride" /t REG_DWORD /d "3" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverrideMask" /t REG_DWORD /d "3" /f
	cd %TEMP%
	if not exist "%TEMP%\NSudo.exe" curl -g -L -# -o "%TEMP%\NSudo.exe" "https://github.com/auraside/HoneCtrl/raw/main/Files/NSudo.exe"
	NSudo -U:S -ShowWindowMode:Hide -wait cmd /c "reg add "HKLM\SYSTEM\CurrentControlSet\Services\TrustedInstaller" /v "Start" /t Reg_DWORD /d "3" /f"
	NSudo -U:S -ShowWindowMode:Hide -wait cmd /c "sc start "TrustedInstaller""
	NSudo -U:T -P:E -M:S -ShowWindowMode:Hide -wait cmd /c "ren %SYSTEMROOT%\System32\mcupdate_GenuineIntel.dll mcupdate_GenuineIntel.old"
	NSudo -U:T -P:E -M:S -ShowWindowMode:Hide -wait cmd /c "ren %SYSTEMROOT%\System32\mcupdate_AuthenticAMD.dll mcupdate_AuthenticAMD.old"
	REM Disable CFG Lock
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "EnableCfg" /t Reg_DWORD /d "0" /f
	REM Disable NTFS/ReFS and FS Mitigations
	reg add "HKLM\System\CurrentControlSet\Control\Session Manager" /v "ProtectionMode" /t Reg_DWORD /d "0" /f
) >nul 2>&1 else (
	reg delete "HKCU\Software\Hone" /v MitigationsTweaks /f
	REM Turn Core Isolation Memory Integrity ON
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v "Enabled" /t REG_DWORD /d "1" /f
	REM Enable SEHOP
	reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "DisableExceptionChainValidation" /f
	REM Enable Spectre And Meltdown
	reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v FeatureSettings /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v FeatureSettingsOverride /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v FeatureSettingsOverrideMask /f
	cd %TEMP%
	if not exist "%TEMP%\NSudo.exe" curl -g -L -# -o "%TEMP%\NSudo.exe" "https://github.com/auraside/HoneCtrl/raw/main/Files/NSudo.exe"
	NSudo -U:S -ShowWindowMode:Hide -wait cmd /c "reg add "HKLM\SYSTEM\CurrentControlSet\Services\TrustedInstaller" /v "Start" /t Reg_DWORD /d "2" /f"
	NSudo -U:S -ShowWindowMode:Hide -wait cmd /c "sc start "TrustedInstaller"" 
	NSudo -U:T -P:E -M:S -ShowWindowMode:Hide -wait cmd /c "ren %SYSTEMROOT%\System32\mcupdate_GenuineIntel.old mcupdate_GenuineIntel.dll"
	NSudo -U:T -P:E -M:S -ShowWindowMode:Hide -wait cmd /c "ren %SYSTEMROOT%\System32\mcupdate_AuthenticAMD.old mcupdate_AuthenticAMD.dll"
	REM Enable CFG Lock
	reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "EnableCfg" /f
	REM Enable NTFS/ReFS and FS Mitigations
	reg delete "HKLM\System\CurrentControlSet\Control\Session Manager" /v "ProtectionMode" /f
) >nul 2>&1
goto Tweaks

:TCPIP
Reg query "HKCU\Software\Hone" /v "WifiDisclaimer" >nul 2>&1 && goto TCPIP2
cls
echo.
echo.
call :HoneTitle
echo.
echo                                        %COL%[90m HoneCtrl is a free and open-source desktop utility
echo                                        %COL%[90m    made to improve your day-to-day productivity
echo.
echo.
echo.
echo %COL%[91m  WARNING:
echo %COL%[91m  This tweak is for Ethernet users only, if you're on Wi-Fi, do not run this tweak.
echo.
echo   %COL%[37mFor any questions and/or concerns, please join our discord: discord.gg/hone
echo.
echo   %COL%[37mPlease enter "I understand" without quotes to continue:
echo.
echo.
echo.
set /p "input=%DEL%                                                            >: %COL%[92m"
if /i "!input!" neq "i understand" goto Tweaks
Reg add "HKCU\Software\Hone" /v "WifiDisclaimer" /f >nul 2>&1
:TCPIP2
if "%TCPOF%" == "%COL%[91mOFF" (
	reg add "HKCU\Software\Hone" /v "TCPIP" /f
	powershell -NoProfile -NonInteractive -Command ^
	Enable-NetAdapterQos -Name "*";^
	Disable-NetAdapterPowerManagement -Name "*";^
	Disable-NetAdapterIPsecOffload -Name "*";^
	Set-NetTCPSetting -SettingName "*" -MemoryPressureProtection Disabled -InitialCongestionWindow 10 -ErrorAction SilentlyContinue
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpMaxConnectRetransmissions" /t REG_DWORD /d "1" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Tcp1323Opts" /t REG_DWORD /d "1" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpTimedWaitDelay" /t REG_DWORD /d "32" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "DelayedAckFrequency" /t REG_DWORD /d "1" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "DelayedAckTicks" /t REG_DWORD /d "1" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "CongestionAlgorithm" /t REG_DWORD /d "1" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "MultihopSets" /t REG_DWORD /d "15" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "IRPStackSize" /t REG_DWORD /d "50" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "SizReqBuf" /t REG_DWORD /d "17424" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "Size" /t REG_DWORD /d "3" /f
	reg add "HKLM\Software\Policies\Microsoft\Windows\Psched" /v "TimerResolution" /t REG_DWORD /d "1" /f
	reg add "HKLM\System\CurrentControlSet\Services\Tcpip\QoS" /v "Do not use NLA" /t REG_DWORD /d "1" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "NegativeCacheTime" /t REG_DWORD /d "0" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "NegativeSOACacheTime" /t REG_DWORD /d "0" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "NetFailureCacheTime" /t REG_DWORD /d "0" /f
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "DoNotShowFeedbackNotifications" /t REG_DWORD /d "1" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "EnableAutoDoh" /t REG_DWORD /d "2" /f
	reg add "HKLM\SYSTEM\CurrDisableNagleentControlSet\Services\AFD\Parameters" /v "DoNotHoldNicBuffers" /t REG_DWORD /d "1" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "DisableRawSecurity" /t REG_DWORD /d "1" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "NonBlockingSendSpecialBuffering" /t REG_DWORD /d "1" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "IgnorePushBitOnReceives" /t REG_DWORD /d "1" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "DynamicSendBufferDisable" /t REG_DWORD /d "0" /f
	reg add "HKLM\Software\Microsoft\MSMQ\Parameters" /v "TCPNoDelay" /t REG_DWORD /d "1" /f
	for /f "tokens=3*" %%i in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkCards" /f "ServiceName" /s ^|findstr /i /l "ServiceName"') do (
		reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "TCPNoDelay" /t Reg_DWORD /d "1" /f
		reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "TcpAckFrequency" /t Reg_DWORD /d "1" /f
		reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "TcpDelAckTicks" /t Reg_DWORD /d "0" /f
		reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "TcpInitialRTT" /d "300" /t REG_DWORD /f
		reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "UseZeroBroadcast" /d "0" /t REG_DWORD /f
		reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "DeadGWDetectDefault" /d "1" /t REG_DWORD /f
	)
) >nul 2>&1 else (
	reg delete "HKCU\Software\Hone" /v "TCPIP" /f
	powershell -NoProfile -NonInteractive -Command ^
	Set-NetTCPSetting -SettingName "*" -InitialCongestionWindow 4 -ErrorAction SilentlyContinue
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpMaxConnectRetransmissions" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Tcp1323Opts" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpTimedWaitDelay" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "DelayedAckFrequency" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "DelayedAckTicks" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "CongestionAlgorithm" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "MultihopSets" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "IRPStackSize" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "SizReqBuf" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "Size" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\QoS" /v "Do not use NLA" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "NegativeCacheTime" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "NegativeSOACacheTime" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "NetFailureCacheTime" /f
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /f
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "DoNotShowFeedbackNotifications" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "EnableAutoDoh" /f
	reg delete "HKLM\SYSTEM\CurrDisableNagleentControlSet\Services\AFD\Parameters" /v "DoNotHoldNicBuffers" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "DisableRawSecurity" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "NonBlockingSendSpecialBuffering" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "IgnorePushBitOnReceives" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "DynamicSendBufferDisable" /f
	reg delete "HKLM\Software\Microsoft\MSMQ\Parameters" /v "TCPNoDelay" /f
	for /f "tokens=3*" %%i in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkCards" /f "ServiceName" /s ^|findstr /i /l "ServiceName"') do (
		reg delete "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "TCPNoDelay" /f
		reg delete "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "TcpAckFrequency" /f
		reg delete "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "TcpDelAckTicks" /f
		reg delete "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "TcpInitialRTT" /f
		reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "UseZeroBroadcast" /f
		reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "DeadGWDetectDefault" /f
	)
) >nul 2>&1
start /B cmd /c "ipconfig /release & ipconfig /renew" >nul 2>&1
goto Tweaks

:NIC
Reg query "HKCU\Software\Hone" /v "WifiDisclaimer2" >nul 2>&1 && goto NIC2
cls
echo.
echo.
call :HoneTitle
echo.
echo                                        %COL%[90m HoneCtrl is a free and open-source desktop utility
echo                                        %COL%[90m    made to improve your day-to-day productivity
echo.
echo.
echo.
echo %COL%[91m  WARNING:
echo %COL%[91m  This tweak is for ethernet users only, if you're on Wi-Fi, do not run this tweak.
echo.
echo   %COL%[37mFor any questions and/or concerns, please join our discord: discord.gg/hone
echo.
echo   %COL%[37mPlease enter "I understand" without quotes to continue:
echo.
echo.
echo.
set /p "input=%DEL%                                                            >: %COL%[92m"
if /i "!input!" neq "i understand" goto Tweaks
Reg add "HKCU\Software\Hone" /v "WifiDisclaimer2" /f >nul 2>&1
:NIC2
cd %SYSTEMDRIVE%\Hone\HoneRevert
if "%NICOF%" neq "%COL%[91mOFF" (
	reg import ognic1.reg
	reg import ognic2.reg
	reg import ognic3.reg
	reg import ognic4.reg
	del ognic1.reg
	del ognic2.reg
	del ognic3.reg
	del ognic4.reg
	goto Tweaks
) >nul 2>&1
set ognic=1
for /f "tokens=*" %%f in ('wmic cpu get NumberOfCores /value ^| find "="') do set %%f
for /f "tokens=3*" %%a in ('reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion\NetworkCards" /k /v /f "Description" /s /e ^| findstr /ri "REG_SZ"') do (
	for /f %%g in ('reg query "HKLM\System\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}" /s /f "%%b" /d ^| findstr /C:"HKEY"') do (
		reg export "%%g" "%SYSTEMDRIVE%\Hone\HoneRevert\ognic!ognic!.reg" /y
		reg add "%%g" /v "MIMOPowerSaveMode" /t REG_SZ /d "3" /f
		reg add "%%g" /v "PowerSavingMode" /t REG_SZ /d "0" /f
		reg add "%%g" /v "EnableGreenEthernet" /t REG_SZ /d "0" /f
		reg add "%%g" /v "*EEE" /t REG_SZ /d "0" /f
		reg add "%%g" /v "EnableConnectedPowerGating" /t REG_DWORD /d "0" /f
		reg add "%%g" /v "EnableDynamicPowerGating" /t REG_SZ /d "0" /f
		reg add "%%g" /v "EnableSavePowerNow" /t REG_SZ /d "0" /f
		reg add "%%g" /v "PnPCapabilities" /t REG_SZ /d "24" /f
		REM more powersaving options
		reg add "%%g" /v "*NicAutoPowerSaver" /t REG_SZ /d "0" /f
		reg add "%%g" /v "ULPMode" /t REG_SZ /d "0" /f
		reg add "%%g" /v "EnablePME" /t REG_SZ /d "0" /f
		reg add "%%g" /v "AlternateSemaphoreDelay" /t REG_SZ /d "0" /f
		reg add "%%g" /v "AutoPowerSaveModeEnabled" /t REG_SZ /d "0" /f
		set /a ognic+=1
	)
) >nul 2>&1
start /B cmd /c "ipconfig /release & ipconfig /renew" >nul 2>&1
goto Tweaks

:Netsh
if "%NETOF%" == "%COL%[91mOFF" (
	reg add "HKCU\Software\Hone" /v InternetTweaks /f
	netsh int tcp set global dca=enabled
	netsh int tcp set global netdma=enabled
	netsh interface isatap set state disabled
	netsh int tcp set global timestamps=disabled
	netsh int tcp set global rss=enabled
	netsh int tcp set global nonsackrttresiliency=disabled
	netsh int tcp set global initialRto=2000
	netsh int tcp set supplemental template=custom icw=10
	netsh interface ip set interface ethernet currenthoplimit=64
) >nul 2>&1 else (
	reg delete "HKCU\Software\Hone" /v InternetTweaks /f
	netsh int tcp set supplemental Internet congestionprovider=default
	netsh int tcp set global initialRto=3000
	netsh int tcp set global rss=default
	netsh int tcp set global chimney=default
	netsh int tcp set global dca=default
	netsh int tcp set global netdma=default
	netsh int tcp set global timestamps=default
	netsh int tcp set global nonsackrttresiliency=default
) >nul 2>&1
goto Tweaks

:AllGPUTweaks
if "%ALLOF%" == "%COL%[91mOFF" (
	reg add "HKCU\Software\Hone" /v "AllGPUTweaks" /f
	REM Enable Hardware Accelerated Scheduling
	reg query "HKLM\System\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" && reg add "HKLM\System\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t Reg_DWORD /d "2" /f
	REM Enable gdi hardware acceleration
	for /f %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class" /v "VgaCompatible" /s ^| findstr "HKEY"') do reg add "%%a" /v "KMD_EnableGDIAcceleration" /t Reg_DWORD /d "1" /f
	REM Enable GameMode
	reg add "HKCU\Software\Microsoft\GameBar" /v "AllowAutoGameMode" /t Reg_DWORD /d "1" /f
	reg add "HKCU\Software\Microsoft\GameBar" /v "AutoGameModeEnabled" /t Reg_DWORD /d "1" /f
	REM FSO
	reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d "0" /f
	reg add "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehaviorMode" /t REG_DWORD /d "2" /f
	reg add "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehavior" /t REG_DWORD /d "2" /f
	reg add "HKCU\System\GameConfigStore" /v "GameDVR_HonorUserFSEBehaviorMode" /t REG_DWORD /d "1" /f
	reg add "HKCU\System\GameConfigStore" /v "GameDVR_DXGIHonorFSEWindowsCompatible" /t REG_DWORD /d "1" /f
	reg add "HKCU\System\GameConfigStore" /v "GameDVR_EFSEFeatureFlags" /t REG_DWORD /d "0" /f
	reg add "HKCU\System\GameConfigStore" /v "GameDVR_DSEBehavior" /t REG_DWORD /d "2" /f
	REM Disable GpuEnergyDrv
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\GpuEnergyDrv" /v "Start" /t Reg_DWORD /d "4" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\GpuEnergyDr" /v "Start" /t Reg_DWORD /d "4" /f
	REM Disable Preemption
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Scheduler" /v "EnablePreemption" /t Reg_DWORD /d "0" /f
) >nul 2>&1 else (
	reg delete "HKCU\Software\Hone" /v "AllGPUTweaks" /f
	REM Enable Hardware Accelerated Scheduling
	reg query "HKLM\System\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" && reg add "HKLM\System\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t Reg_DWORD /d "1" /f
	REM Disable gdi hardware acceleration
	for /f %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class" /v "VgaCompatible" /s ^| findstr "HKEY"') do reg delete "%%a" /v "KMD_EnableGDIAcceleration" /f
	REM Enable GameMode
	reg add "HKCU\Software\Microsoft\GameBar" /v "AllowAutoGameMode" /t Reg_DWORD /d "1" /f
	reg add "HKCU\Software\Microsoft\GameBar" /v "AutoGameModeEnabled" /t Reg_DWORD /d "1" /f
	REM FSO
	reg delete "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /f
	reg delete "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehaviorMode" /f
	reg delete "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehavior" /f
	reg delete "HKCU\System\GameConfigStore" /v "GameDVR_HonorUserFSEBehaviorMode" /f
	reg delete "HKCU\System\GameConfigStore" /v "GameDVR_DXGIHonorFSEWindowsCompatible" /f
	reg delete "HKCU\System\GameConfigStore" /v "GameDVR_EFSEFeatureFlags" /f
	reg delete "HKCU\System\GameConfigStore" /v "GameDVR_DSEBehavior" /f
	REM Disable GpuEnergyDrv
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\GpuEnergyDrv" /v "Start" /t Reg_DWORD /d "2" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\GpuEnergyDr" /v "Start" /t Reg_DWORD /d "2" /f
	REM Disable Preemption
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Scheduler" /v "EnablePreemption" /t Reg_DWORD /d "1" /f
) >nul 2>&1
goto Tweaks

:Intel
echo %DSSOF% | find "N/A" >nul && call :HoneCtrlError "You don't have an intel GPU" && goto Tweaks
REM DedicatedSegmentSize in Intel iGPU
if "%DSSOF%" == "%COL%[91mOFF" (
	reg add "HKLM\SOFTWARE\Intel\GMM" /v "DedicatedSegmentSize" /t REG_DWORD /d "1024" /f
) >nul 2>&1 else (
	reg delete "HKLM\SOFTWARE\Intel\GMM" /v "DedicatedSegmentSize" /f
) >nul 2>&1
goto Tweaks

:AMD
echo %AMDOF% | find "N/A" >nul && call :HoneCtrlError "You don't have an AMD GPU" && goto Tweaks
REM AMD Registry Location
for /f %%i in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /s /v "DriverDesc"^| findstr "HKEY AMD ATI"') do if /i "%%i" neq "DriverDesc" (set "REGPATH_AMD=%%i")
REM AMD Tweaks
reg add "%REGPATH_AMD%" /v "3D_Refresh_Rate_Override_DEF" /t Reg_DWORD /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "3to2Pulldown_NA" /t Reg_DWORD /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "AAF_NA" /t Reg_DWORD /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "Adaptive De-interlacing" /t Reg_DWORD /d "1" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "AllowRSOverlay" /t Reg_SZ /d "false" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "AllowSkins" /t Reg_SZ /d "false" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "AllowSnapshot" /t Reg_DWORD /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "AllowSubscription" /t Reg_DWORD /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "AntiAlias_NA" /t Reg_SZ /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "AreaAniso_NA" /t Reg_SZ /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "ASTT_NA" /t Reg_SZ /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "AutoColorDepthReduction_NA" /t Reg_DWORD /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "DisableSAMUPowerGating" /t Reg_DWORD /d "1" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "DisableUVDPowerGatingDynamic" /t Reg_DWORD /d "1" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "DisableVCEPowerGating" /t Reg_DWORD /d "1" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "EnableAspmL0s" /t Reg_DWORD /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "EnableAspmL1" /t Reg_DWORD /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "EnableUlps" /t Reg_DWORD /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "EnableUlps_NA" /t Reg_SZ /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "KMD_DeLagEnabled" /t Reg_DWORD /d "1" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "KMD_FRTEnabled" /t Reg_DWORD /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "DisableDMACopy" /t Reg_DWORD /d "1" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "DisableBlockWrite" /t Reg_DWORD /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "StutterMode" /t Reg_DWORD /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "EnableUlps" /t Reg_DWORD /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "PP_SclkDeepSleepDisable" /t Reg_DWORD /d "1" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "PP_ThermalAutoThrottlingEnable" /t Reg_DWORD /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "DisableDrmdmaPowerGating" /t Reg_DWORD /d "1" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "KMD_EnableComputePreemption" /t Reg_DWORD /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%\UMD" /v "Main3D_DEF" /t Reg_SZ /d "1" /f >nul 2>&1
reg add "%REGPATH_AMD%\UMD" /v "Main3D" /t Reg_BINARY /d "3100" /f >nul 2>&1
reg add "%REGPATH_AMD%\UMD" /v "FlipQueueSize" /t Reg_BINARY /d "3100" /f >nul 2>&1
reg add "%REGPATH_AMD%\UMD" /v "ShaderCache" /t Reg_BINARY /d "3200" /f >nul 2>&1
reg add "%REGPATH_AMD%\UMD" /v "Tessellation_OPTION" /t Reg_BINARY /d "3200" /f >nul 2>&1
reg add "%REGPATH_AMD%\UMD" /v "Tessellation" /t Reg_BINARY /d "3100" /f >nul 2>&1
reg add "%REGPATH_AMD%\UMD" /v "VSyncControl" /t Reg_BINARY /d "3000" /f >nul 2>&1
reg add "%REGPATH_AMD%\UMD" /v "TFQ" /t Reg_BINARY /d "3200" /f >nul 2>&1
reg add "%REGPATH_AMD%\DAL2_DATA__2_0\DisplayPath_4\EDID_D109_78E9\Option" /v "ProtectionControl" /t Reg_BINARY /d "0100000001000000" /f >nul 2>&1
goto Tweaks

:AudioLatency
cd %SYSTEMDRIVE%\Hone\Resources
if "%AUDOF%" == "%COL%[91mOFF" (
	if not exist nssm.exe (
		curl -g -L -# -o "%SYSTEMDRIVE%\Hone\Resources\nssm.exe" "https://github.com/auraside/HoneCtrl/raw/main/Files/nssm.exe"
		curl -g -L -# -o "%SYSTEMDRIVE%\Hone\Resources\REAL.exe" "https://github.com/auraside/HoneCtrl/raw/main/Files/REAL.exe"
		nssm install HoneAudio "%SYSTEMDRIVE%\Hone\Resources\REAL.exe"
		nssm set HoneAudio DisplayName Hone Audio Latency Reducer Service
		nssm set HoneAudio Description Reduces Audio Latency
		nssm set HoneAudio Start SERVICE_AUTO_START
		nssm set HoneAudio AppAffinity 1
	)
nssm set HoneAudio start SERVICE_AUTO_START
nssm start HoneAudio
) >nul 2>&1 else (
nssm set HoneAudio start SERVICE_DISABLED
nssm stop HoneAudio
) >nul 2>&1
goto Tweaks

:Cleaner
cls
rmdir /S /Q "%SYSTEMDRIVE%\Hone\Resources\DeviceCleanupCmd\" >nul 2>&1
del /F /Q "%SYSTEMDRIVE%\Hone\Resources\AdwCleaner.exe" >nul 2>&1
del /F /Q "%SYSTEMDRIVE%\Hone\Resources\EmptyStandbyList.exe" >nul 2>&1
curl -g -L -# -o "%SYSTEMDRIVE%\Hone\Resources\EmptyStandbyList.exe" "https://github.com/auraside/HoneCtrl/raw/main/Files/EmptyStandbyList.exe"
curl -g -L -# -o "%SYSTEMDRIVE%\Hone\Resources\DeviceCleanupCmd.zip" "https://www.uwe-sieber.de/files/DeviceCleanupCmd.zip"
curl -g -L -# -o "%SYSTEMDRIVE%\Hone\Resources\AdwCleaner.exe" "https://adwcleaner.malwarebytes.com/adwcleaner?channel=release"
powershell -NoProfile Expand-Archive '%SYSTEMDRIVE%\Hone\Resources\DeviceCleanupCmd.zip' -DestinationPath '%SYSTEMDRIVE%\Hone\Resources\DeviceCleanupCmd\'
del /F /Q "%SYSTEMDRIVE%\Hone\Resources\DeviceCleanupCmd.zip" >nul 2>&1
del /Q %LOCALAPPDATA%\Microsoft\Windows\INetCache\IE\*.* >nul 2>&1
del /Q "%SYSTEMROOT%\Downloaded Program Files\*.*" >nul 2>&1
rd /s /q %SYSTEMDRIVE%\$Recycle.bin >nul 2>&1
del /Q %TEMP%\*.* >nul 2>&1
del /Q %SYSTEMROOT%\Temp\*.* >nul 2>&1
del /Q %SYSTEMROOT%\Prefetch\*.* >nul 2>&1
cd %SYSTEMDRIVE%\Hone\Resources >nul 2>&1
AdwCleaner.exe /eula /clean /noreboot
for %%g in (workingsets modifiedpagelist standbylist priority0standbylist) do EmptyStandbyList.exe %%g
cd "%SYSTEMDRIVE%\Hone\Resources\DeviceCleanupCmd\x64" >nul 2>&1
DeviceCleanupCmd.exe *
goto tweaks

:gameBooster
cls & echo Select the game location, you can do it a second time to revert the changes.
set dialog="about:<input type=file id=FILE><script>FILE.click();new ActiveXObject
set dialog=%dialog%('Scripting.FileSystemObject').GetStandardStream(1).WriteLine(FILE.value);
set dialog=%dialog%close();resizeTo(0,0);</script>"
for /f "tokens=* delims=" %%p in ('mshta.exe %dialog%') do set "file=%%p"
if "%file%"=="" goto :eof
for %%F in ("%file%") do reg query "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "%file%" && (
	reg delete "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "%file%" /f
	reg delete "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "%file%" /f
	reg delete "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%%~nxF\PerfOptions" /v "CpuPriorityClass" /f
	cls
	echo Game boost has been reverted!
	Timeout 5
) || (
	reg add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "%file%" /t Reg_SZ /d "GpuPreference=2;" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "%file%" /t Reg_SZ /d "~ DISABLEDXMAXIMIZEDWINDOWEDMODE" /f >nul 2>&1
	reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%%~nxF\PerfOptions" /v "CpuPriorityClass" /t Reg_DWORD /d "3" /f >nul 2>&1
) >nul 2>&1
goto :eof

:softRestart
cls
cd %TEMP%
if not exist "%TEMP%\NSudo.exe" curl -g -L -# -o "%TEMP%\NSudo.exe" "https://github.com/auraside/HoneCtrl/raw/main/Files/NSudo.exe"
NSudo.exe -U:S -ShowWindowMode:Hide cmd /c "reg add "HKLM\SYSTEM\CurrentControlSet\Services\TrustedInstaller" /v "Start" /t Reg_DWORD /d "3" /f" >nul 2>&1
NSudo.exe -U:S -ShowWindowMode:Hide cmd /c "sc start "TrustedInstaller"" >nul 2>&1
if not exist "%TEMP%\restart64.exe" curl -g -L -# -o "%TEMP%\Restart64.exe" "https://github.com/auraside/HoneCtrl/raw/main/Files/restart64.exe"
if not exist "%TEMP%\EmptyStandbyList.exe" curl -g -L -# -o "%TEMP%\EmptyStandbyList.exe" "https://github.com/auraside/HoneCtrl/raw/main/Files/EmptyStandbyList.exe"
taskkill /f /im explorer.exe >nul 2>&1
cd %SYSTEMROOT% >nul 2>&1
start explorer.exe >nul 2>&1
cd %TEMP%
echo netsh advfirewall reset >RefreshNet.bat
echo ipconfig /release >>RefreshNet.bat
echo ipconfig /renew >>RefreshNet.bat
echo nbtstat -R >>RefreshNet.bat
echo nbtstat -RR >>RefreshNet.bat
echo ipconfig /flushdns >>RefreshNet.bat
echo ipconfig /registerdns >>RefreshNet.bat
NSudo -U:T -P:E -M:S -ShowWindowMode:Hide -wait cmd /c "%TEMP%\RefreshNet.bat"
Restart64.exe
EmptyStandbyList.exe standbylist
echo.
echo.
echo  --------------------------------------------------------------
echo                      Soft Restart Completed
echo  --------------------------------------------------------------
echo.
echo.
echo                             [X] Close
echo.
%SYSTEMROOT%\System32\choice.exe /c:X /n /m "%DEL%                                >:"
goto tweaks

:GameSettings
cls
echo.
echo.
call :HoneTitle
echo.
echo.
echo.
echo                                                               %COL%[34m%COL%[1mGames%COL%[0m
echo.
echo                                                         %COL%[33m[%COL%[37m 1 %COL%[33m]%COL%[37m Minecraft
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                                 %COL%[90m[ B for back ]         %COL%[31m[ X to close ]%COL%[37m
echo.
%SYSTEMROOT%\System32\choice.exe /c:1BX /n /m "%DEL%                                        Select a corresponding number to the options above >"
set choice=%errorlevel%
if "%choice%"=="1" goto Minecraft
if "%choice%"=="2" goto MainMenu
if "%choice%"=="3" exit /b

:Minecraft
if not exist "%APPDATA%\.minecraft\" call:HoneCtrlError "Can't find your Minecraft installation." & goto GameSettings
cls
echo.
echo.
echo.
echo.
echo                                                                            %COL%[33m.
echo                                                                         +N.
echo                                                                //        oMMs
echo                                                               +Nm`    ``yMMm-
echo                                                            ``dMMsoyhh-hMMd.
echo                                                            `yy/MMMMNh:dMMh`
echo                                                           .hMM.sso++:oMMs`
echo                                                          -mMMy:osyyys.No
echo                                                         :NMMs-oo+/syy:-
echo                                                        /NMN+ ``   :ys.
echo                                                       `NMN:        +.
echo                                                       om-
echo                                                        `.
echo.
echo.
echo.
echo.
echo.
echo                                                      %COL%[1;4;34mSelect Minecraft Version%COL%[0m
echo.
echo.
echo.
echo.
echo                       %COL%[33m[ %COL%[37m1 %COL%[33m]%COL%[37m 1.7.10                         %COL%[33m[ %COL%[37m2 %COL%[33m]%COL%[37m 1.8.9                          %COL%[33m[ %COL%[37m3 %COL%[33m] %COL%[37m 1.9 - latest
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                                 %COL%[90m[ B for back ]         %COL%[31m[ X to close ]%COL%[37m
echo.
%SYSTEMROOT%\System32\choice.exe /c:123BX /n /m "%DEL%                                        Select a corresponding number to the options above >"
set choice=%errorlevel%
if %choice% == 1 goto 1.7.10
if %choice% == 2 goto 1.8.9
if %choice% == 3 goto 1.19.3
if %choice% == 4 goto GameSettings
if %choice% == 5 exit /b

:1.7.10
cd %APPDATA%\.minecraft\
(
	echo ofRenderDistanceChunks:4
	echo ofFogType:3
	echo ofFogStart:0.6
	echo ofMipmapType:0
	echo ofLoadFar:false
	echo ofPreloadedChunks:0
	echo ofOcclusionFancy:false
	echo ofSmoothFps:false
	echo ofSmoothWorld:false
	echo ofAoLevel:0.0
	echo ofClouds:3
	echo ofCloudsHeight:0.0
	echo ofTrees:1
	echo ofGrass:0
	echo ofDroppedItems:1
	echo ofRain:3
	echo ofWater:0
	echo ofAnimatedWater:0
	echo ofAnimatedLava:0
	echo ofAnimatedFire:true
	echo ofAnimatedPortal:true
	echo ofAnimatedRedstone:false
	echo ofAnimatedExplosion:true
	echo ofAnimatedFlame:true
	echo ofAnimatedSmoke:true
	echo ofVoidParticles:false
	echo ofWaterParticles:true
	echo ofPortalParticles:true
	echo ofPotionParticles:true
	echo ofDrippingWaterLava:true
	echo ofAnimatedTerrain:true
	echo ofAnimatedTextures:true
	echo ofAnimatedItems:true
	echo ofRainSplash:false
	echo ofLagometer:false
	echo ofShowFps:false
	echo ofAutoSaveTicks:28800
	echo ofBetterGrass:3
	echo ofConnectedTextures:3
	echo ofWeather:false
	echo ofSky:false
	echo ofStars:false
	echo ofSunMoon:true
	echo ofVignette:1
	echo ofChunkUpdates:1
	echo ofChunkLoading:0
	echo ofChunkUpdatesDynamic:false
	echo ofTime:0
	echo ofClearWater:true
	echo ofDepthFog:false
	echo ofAaLevel:0
	echo ofProfiler:false
	echo ofBetterSnow:false
	echo ofSwampColors:false
	echo ofRandomMobs:false
	echo ofSmoothBiomes:false
	echo ofCustomFonts:false
	echo ofCustomColors:false
	echo ofCustomSky:false
	echo ofShowCapes:true
	echo ofNaturalTextures:false
	echo ofLazyChunkLoading:true
	echo ofDynamicFov:false
	echo ofDynamicLights:3
	echo ofFullscreenMode:Default
	echo ofFastMath:true
	echo ofFastRender:true
	echo ofTranslucentBlocks:1
) > optionsof.txt
goto MinecraftConfirmation

:1.8.9
cd %APPDATA%\.minecraft\
(
	echo ofFogType:3
	echo ofFogStart:0.6
	echo ofMipmapType:0
	echo ofOcclusionFancy:false
	echo ofSmoothFps:false
	echo ofSmoothWorld:false
	echo ofAoLevel:0.0
	echo ofClouds:3
	echo ofCloudsHeight:0.0
	echo ofTrees:1
	echo ofDroppedItems:1
	echo ofRain:3
	echo ofAnimatedWater:0
	echo ofAnimatedLava:0
	echo ofAnimatedFire:true
	echo ofAnimatedPortal:true
	echo ofAnimatedRedstone:false
	echo ofAnimatedExplosion:true
	echo ofAnimatedFlame:true
	echo ofAnimatedSmoke:true
	echo ofVoidParticles:false
	echo ofWaterParticles:true
	echo ofPortalParticles:true
	echo ofPotionParticles:true
	echo ofFireworkParticles:true
	echo ofDrippingWaterLava:true
	echo ofAnimatedTerrain:true
	echo ofAnimatedTextures:true
	echo ofRainSplash:false
	echo ofLagometer:false
	echo ofShowFps:false
	echo ofAutoSaveTicks:28800
	echo ofBetterGrass:3
	echo ofConnectedTextures:3
	echo ofWeather:false
	echo ofSky:false
	echo ofStars:false
	echo ofSunMoon:true
	echo ofVignette:1
	echo ofChunkUpdates:1
	echo ofChunkUpdatesDynamic:false
	echo ofTime:0
	echo ofClearWater:false
	echo ofAaLevel:0
	echo ofAfLevel:1
	echo ofProfiler:false
	echo ofBetterSnow:false
	echo ofSwampColors:false
	echo ofRandomEntities:false
	echo ofSmoothBiomes:false
	echo ofCustomFonts:false
	echo ofCustomColors:false
	echo ofCustomItems:false
	echo ofCustomSky:true
	echo ofShowCapes:true
	echo ofNaturalTextures:false
	echo ofEmissiveTextures:false
	echo ofLazyChunkLoading:true
	echo ofRenderRegions:true
	echo ofSmartAnimations:true
	echo ofDynamicFov:false
	echo ofAlternateBlocks:false
	echo ofDynamicLights:3
	echo ofScreenshotSize:1
	echo ofCustomEntityModels:false
	echo ofCustomGuis:false
	echo ofShowGlErrors:false
	echo ofFullscreenMode:Default
	echo ofFastMath:true
	echo ofFastRender:true
	echo ofTranslucentBlocks:1
	echo key_of.key.zoom:29
) > optionsof.txt
goto MinecraftConfirmation

:1.19.3
cd %APPDATA%\.minecraft\
(
	echo ofFogType:3
	echo ofFogStart:0.6
	echo ofMipmapType:0
	echo ofOcclusionFancy:false
	echo ofSmoothFps:false
	echo ofSmoothWorld:false
	echo ofAoLevel:0.0
	echo ofClouds:3
	echo ofCloudsHeight:0.0
	echo ofTrees:1
	echo ofDroppedItems:1
	echo ofRain:3
	echo ofAnimatedWater:0
	echo ofAnimatedLava:0
	echo ofAnimatedFire:true
	echo ofAnimatedPortal:true
	echo ofAnimatedRedstone:false
	echo ofAnimatedExplosion:true
	echo ofAnimatedFlame:true
	echo ofAnimatedSmoke:true
	echo ofVoidParticles:false
	echo ofWaterParticles:true
	echo ofPortalParticles:true
	echo ofPotionParticles:true
	echo ofFireworkParticles:true
	echo ofDrippingWaterLava:true
	echo ofAnimatedTerrain:true
	echo ofAnimatedTextures:true
	echo ofRainSplash:false
	echo ofLagometer:false
	echo ofShowFps:false
	echo ofAutoSaveTicks:28800
	echo ofBetterGrass:3
	echo ofConnectedTextures:3
	echo ofWeather:false
	echo ofSky:false
	echo ofStars:fale
	echo ofSunMoon:true
	echo ofVignette:1
	echo ofChunkUpdates:1
	echo ofChunkUpdatesDynamic:false
	echo ofTime:0
	echo ofAaLevel:0
	echo ofAfLevel:1
	echo ofProfiler:false
	echo ofBetterSnow:false
	echo ofSwampColors:false
	echo ofRandomEntities:false
	echo ofCustomFonts:false
	echo ofCustomColors:false
	echo ofCustomItems:false
	echo ofCustomSky:true
	echo ofShowCapes:true
	echo ofNaturalTextures:false
	echo ofEmissiveTextures:false
	echo ofLazyChunkLoading:true
	echo ofRenderRegions:true
	echo ofSmartAnimations:true
	echo ofDynamicFov:false
	echo ofAlternateBlocks:false
	echo ofDynamicLights:3
	echo ofScreenshotSize:1
	echo ofCustomEntityModels:false
	echo ofCustomGuis:false
	echo ofShowGlErrors:false
	echo ofFastMath:true
	echo ofFastRender:true
	echo ofTranslucentBlocks:0
	echo ofChatBackground:3
	echo ofChatShadow:false
	echo ofTelemetry:2
	echo key_of.key.zoom:key.keyboard.left.control
) > optionsof.txt
goto MinecraftConfirmation

:MinecraftConfirmation
cls
echo.
echo.
echo.
echo.
echo                                                                            %COL%[33m.
echo                                                                         +N.
echo                                                                //        oMMs
echo                                                               +Nm`    ``yMMm-
echo                                                            ``dMMsoyhh-hMMd.
echo                                                            `yy/MMMMNh:dMMh`
echo                                                           .hMM.sso++:oMMs`
echo                                                          -mMMy:osyyys.No
echo                                                         :NMMs-oo+/syy:-
echo                                                        /NMN+ ``   :ys.
echo                                                       `NMN:        +.
echo                                                       om-
echo                                                        `.
echo.
echo.
echo.
echo.
echo.
echo                                                   %COL%[37m Settings have been applied
echo.
echo.
echo.
echo.
echo                                                          %COL%[90m[ B for back ]%COL%[37m
echo.
%SYSTEMROOT%\System32\choice.exe /c:B /n /m "%DEL%                                                               >:"
goto GameSettings

:HoneRenders
REM Detect encoder for obs, blur, and ffmpeg settings
for /F "tokens=*" %%n in ('WMIC path Win32_VideoController get Name ^| findstr "NVIDIA"') do set GPU_NAME=%%n
echo %GPU_NAME% | find "NVIDIA" && set encoder=NVENC
if not defined encoder goto next
if %encoder% == NVENC goto done
:next
for /F "tokens=*" %%n in ('WMIC path Win32_VideoController get Name ^| findstr "AMD"') do set GPU_NAME=%%n
echo %GPU_NAME% | find "AMD" && set encoder=AMF
if not defined encoder goto next2
if %encoder% == AMF goto done
:next2
set encoder=CPU
goto done
:done
cls
echo.
echo.
echo                                       %COL%[33m+N.
echo                            //        oMMs
echo                           +Nm`    ``yMMm-     ::::::::     ::::    :::    ::::::::::
echo                        ``dMMsoyhh-hMMd.     :+:    :+:    :+:+:   :+:    :+:
echo                        `yy/MMMMNh:dMMh`    +:+    +:+    :+:+:+  +:+    +:+                 +::+:+::      +::+:+::
echo                       .hMM.sso++:oMMs`    +#+    +:+    +#+ +:+ +#+    +#++:++#           ++:    #++    ++:    #++
echo                      -mMMy:osyyys.No     +#+    +#+    +#+  +#+#+#    +#+                +#+    +#+    +#+    +#+
echo                     :NMMs-oo+/syy:-     #+#    #+#    #+#   #+#+#    #+#          %COL%[37m#+#%COL%[33m    +#+   #+#     #+#   #+#
echo                    /NMN+ ``   :ys.      ########     ###    ####    ##########   %COL%[37m###%COL%[33m       ######        ######
echo                   `NMN:        +.                                                      ##    ###     ##    ###
echo                   om-                                                                   #######       #######
echo                    `.                                     %COL%[34m%COL%[1mOBS Settings%COL%[0m
echo.
echo              %COL%[33m[ %COL%[37m1 %COL%[33m]%COL%[37m Install/Update OBS             %COL%[33m[ %COL%[37m2 %COL%[33m]%COL%[37m Recording                      %COL%[33m[ %COL%[37m3 %COL%[33m]%COL%[37m Streaming
echo              %COL%[90mAutomatically install or update      %COL%[90mAutomated recording settings for     %COL%[90mAutomated streaming settings for
echo              %COL%[90mOBS using the official link          %COL%[90mOBS based on your preference         %COL%[90mOBS based on your preference
echo.
echo.
echo                                                           %COL%[34m%COL%[1mFFmpeg Settings%COL%[0m
echo.
echo              %COL%[33m[ %COL%[37m4 %COL%[33m]%COL%[37m Upscale                        %COL%[33m[ %COL%[37m5 %COL%[33m]%COL%[37m Compress                       %COL%[33m[ %COL%[37m6 %COL%[33m]%COL%[37m Preview Lag
echo              %COL%[90mModify the scale of a video          %COL%[90mMake a clips size smaller for        %COL%[90mAdjust a clips quality
echo              %COL%[90mfor higher bitrate on YouTube        %COL%[90msharing by compressing the file      %COL%[90mto play well with vegas preview
echo.
echo.
echo                                                           %COL%[34m%COL%[1mBlur Settings%COL%[0m
echo.
echo              %COL%[33m[ %COL%[37m7 %COL%[33m]%COL%[37m Install/Update Blur            %COL%[33m[ %COL%[37m8 %COL%[33m]%COL%[37m FPS Games                      %COL%[33m[ %COL%[37m9 %COL%[33m]%COL%[37m Minecraft
echo              %COL%[90mAutomatically install or update      %COL%[90mAutomated Blur settings for          %COL%[90mBlur settings for games
echo              %COL%[90mBlur using the official link         %COL%[90mfirst person shooter games           %COL%[90mrecorded in extremely high fps
echo.
echo.
echo                                                           %COL%[34m%COL%[1mVideo Editor Settings%COL%[0m
echo.
echo              %COL%[33m[ %COL%[37m10 %COL%[33m]%COL%[37m Install A Video Editor (NLE)  %COL%[33m[ %COL%[37m11 %COL%[33m]%COL%[37m Project Settings              %COL%[33m[ %COL%[37m12 %COL%[33m]%COL%[37m Renders
echo              %COL%[90mDownload ^& install a		  %COL%[90mAutomated Project settings	       %COL%[90mAutomated render settings
echo		     %COL%[90mNon-Linear editing software	  %COL%[90mfor Vegas pro                        %COL%[90mfor Vegas pro
echo.
echo                                                 %COL%[90m[ B for back ]         %COL%[31m[ X to close ]
echo.
set /p choice="%DEL%                                        %COL%[37mSelect a corresponding number to the options above > "
if /i "%choice%"=="1" call:OBSInstall
if /i "%choice%"=="2" goto Recording
if /i "%choice%"=="3" goto Streaming
if /i "%choice%"=="4" goto Upscale
if /i "%choice%"=="5" goto Compress
if /i "%choice%"=="6" goto PreviewLag
if /i "%choice%"=="7" call:Blurinstall
if /i "%choice%"=="8" goto FPSGames
if /i "%choice%"=="9" goto MinecraftBlur
if /i "%choice%"=="10" goto NLEInstall
if /i "%choice%"=="11" goto ProjectSettings
if /i "%choice%"=="12" goto RenderSettings
if /i "%choice%"=="B" goto MainMenu
if /i "%choice%"=="X" exit /b
goto HoneRenders

:OBSInstall
REM Delete old OBS
if exist "%SYSTEMDRIVE%\Program Files\obs-studio\uninstall.exe" start /w "" "%SYSTEMDRIVE%\Program Files\obs-studio\uninstall.exe" /S >nul 2>&1
rmdir /s /q "%APPDATA%\obs-studio" >nul 2>&1
REM get url to OBS
for /f "skip=150 tokens=2" %%I in ('curl -s https://obsproject.com/') do set "OBS=%%I" & goto end
:end
REM Install OBS Silently
curl -g -L -# -o "%TEMP%\OBS.exe" "%OBS:~6,-1%"
start "" /D "%TEMP%" OBS -s
goto :eof


:Recording
cls
echo.
echo.
call :HoneTitle
echo.
echo              %COL%[33m[ %COL%[37m1 %COL%[33m]%COL%[37m Quality                        %COL%[33m[ %COL%[37m2 %COL%[33m]%COL%[37m Optimal                        %COL%[33m[ %COL%[37m3 %COL%[33m]%COL%[37m Performance
echo              %COL%[90mSettings for the best                %COL%[90mThe best for performance             %COL%[90mSettings for the best
echo              %COL%[90mquality in OBS                       %COL%[90mwithout losing much quality          %COL%[90mperformance in OBS
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                                 %COL%[90m[ B for back ]         %COL%[31m[ X to close ]
echo.
set /p choice="%DEL%                                        %COL%[37mSelect a corresponding number to the options above > "
if /i "%choice%"=="1" goto Quality
if /i "%choice%"=="2" goto Optimal
if /i "%choice%"=="3" goto Performance
if /i "%choice%"=="B" goto HoneRenders
if /i "%choice%"=="X" goto exit /b
goto recording

:Quality
if not exist "%SYSTEMDRIVE%\Program Files\obs-studio\bin\64bit" call:OBSInstall
	cd "%SYSTEMDRIVE%\Program Files\obs-studio\bin\64bit"
	taskkill /f /im obs64.exe >nul 2>&1
	Reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "%SYSTEMDRIVE%\Program Files\obs-studio\bin\64bit\obs64.exe" /t Reg_SZ /d "~ RUNASADMIN" /f >nul 2>&1
	REM get monitor resolution
	powershell -Command "((Get-CimInstance Win32_VideoController).VideoModeDescription.Split(' x ') | Where-Object {$_ -ne ''} | Select-Object -First 1)" > "%TEMP%\width.txt"
	powershell -Command "((Get-CimInstance Win32_VideoController).VideoModeDescription.Split(' x ') | Where-Object {$_ -ne ''} | Select-Object -First 1 -Skip 1)" > "%TEMP%\height.txt"
	set /p width=<"%TEMP%\width.txt"
	set /p height=<"%TEMP%\height.txt"
	cls & set /p FPS="What FPS would you like to record in? >: "
	if %FPS% gtr 120 echo Warning: Recording at high FPS with the Quality preset can cause lag on weaker systems. && timeout 8 /nobreak
if %encoder% == NVENC (
	(for %%i in (
		"[AdvOut]"
		"RecEncoder=jim_nvenc"
		"RecRB=true"
		"TrackIndex=1"
		"RecType=Standard"
		"RecFormat=mp4"
		"RecTracks=1"
		"FLVTrack=1"
		"FFOutputToFile=true"
		"FFFormat="
		"FFFormatMimeType="
		"FFVEncoderId=0"
		"FFVEncoder="
		"FFAEncoderId=0"
		"FFAEncoder="
		"FFAudioMixes=1"
		"VodTrackIndex=2"
		.
		"[General]"
		"Name=Untitled"
		.
		"[Video]"
		"BaseCX=!width!"
		"BaseCY=!height!"
		"OutputCX=!width!"
		"OutputCY=!height!"
		"FPSDen=1"
		"FPSType=2"
		"ScaleType=bilinear"
		"FPSNum=!FPS!"
		"ColorSpace=sRGB"
		"ColorRange=Full"
		.
		"[Output]"
		"RecType=Standard"
		"Mode=Advanced"
	) do echo.%%~i)>"%TEMP%\Basic.ini"
	echo.{"bf":2,"cqp":17,"keyint_sec":0,"lookahead":"false","multipass":"disabled","preset2":"p1","profile":"baseline","rate_control":"CQP"} >"%TEMP%\RecordEncoder.json"
)

if %encoder% == AMF (
	(for %%i in (
		"[AdvOut]"
		"RecEncoder=h264_texture_amf"
		"RecRB=true"
		"TrackIndex=1"
		"RecType=Standard"
		"RecFormat=mp4"
		"RecTracks=1"
		"FLVTrack=1"
		"FFOutputToFile=true"
		"FFFormat="
		"FFFormatMimeType="
		"FFVEncoderId=0"
		"FFVEncoder="
		"FFAEncoderId=0"
		"FFAEncoder="
		"FFAudioMixes=1"
		"VodTrackIndex=2"
		.
		"[General]"
		"Name=Untitled"
		.
		"[Video]"
		"BaseCX=!width!"
		"BaseCY=!height!"
		"OutputCX=!width!"
		"OutputCY=!height!"
		"FPSDen=1"
		"FPSType=2"
		"ScaleType=bilinear"
		"FPSNum=!FPS!"
		"ColorSpace=sRGB"
		"ColorRange=Full"
		.
		"[Output]"
		"RecType=Standard"
		"Mode=Advanced"
	) do echo.%%~i)>"%TEMP%\Basic.ini"
	echo.{"cqp":18,"preset":"speed","profile":"baseline","rate_control":"CQP"} >"%TEMP%\RecordEncoder.json"
)

if %encoder% == CPU (
	(for %%i in (
		"[AdvOut]"
		"RecEncoder=obs_x264"
		"RecRB=true"
		"TrackIndex=1"
		"RecType=Standard"
		"RecFormat=mp4"
		"RecTracks=1"
		"FLVTrack=1"
		"FFOutputToFile=true"
		"FFFormat="
		"FFFormatMimeType="
		"FFVEncoderId=0"
		"FFVEncoder="
		"FFAEncoderId=0"
		"FFAEncoder="
		"FFAudioMixes=1"
		"VodTrackIndex=2"
		.
		"[General]"
		"Name=Untitled"
		.
		"[Video]"
		"BaseCX=!width!"
		"BaseCY=!height!"
		"OutputCX=!width!"
		"OutputCY=!height!"
		"FPSDen=1"
		"FPSType=2"
		"ScaleType=bilinear"
		"FPSNum=!FPS!"
		"ColorSpace=sRGB"
		"ColorRange=Full"
		.
		"[Output]"
		"RecType=Standard"
		"Mode=Advanced"
	) do echo.%%~i)>"%TEMP%\Basic.ini"
	echo.{"bitrate":40000,"preset":"faster","profile":"baseline","tune":"film"} >"%TEMP%\RecordEncoder.json"
)
move /Y "%TEMP%\basic.ini" "%APPDATA%\obs-studio\basic\profiles\Untitled\" >nul 2>&1
move /Y "%TEMP%\RecordEncoder.json" "%APPDATA%\obs-studio\basic\profiles\Untitled\" >nul 2>&1
goto HoneRenders

:Optimal
if not exist "%SYSTEMDRIVE%\Program Files\obs-studio\bin\64bit" call:OBSInstall
	cd "%SYSTEMDRIVE%\Program Files\obs-studio\bin\64bit"
	taskkill /f /im obs64.exe >nul 2>&1
	Reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "%SYSTEMDRIVE%\Program Files\obs-studio\bin\64bit\obs64.exe" /t Reg_SZ /d "~ RUNASADMIN" /f >nul 2>&1
	REM get monitor resolution
	powershell -Command "((Get-CimInstance Win32_VideoController).VideoModeDescription.Split(' x ') | Where-Object {$_ -ne ''} | Select-Object -First 1)" > "%TEMP%\width.txt"
	powershell -Command "((Get-CimInstance Win32_VideoController).VideoModeDescription.Split(' x ') | Where-Object {$_ -ne ''} | Select-Object -First 1 -Skip 1)" > "%TEMP%\height.txt"
	set /p width=<"%TEMP%\width.txt"
	set /p height=<"%TEMP%\height.txt"
	cls & set /p FPS="What FPS would you like to record in? >: "
if %encoder% == NVENC (
	(for %%i in (
		"[AdvOut]"
		"RecEncoder=jim_nvenc"
		"RecRB=true"
		"TrackIndex=1"
		"RecType=Standard"
		"RecFormat=mp4"
		"RecTracks=1"
		"FLVTrack=1"
		"FFOutputToFile=true"
		"FFFormat="
		"FFFormatMimeType="
		"FFVEncoderId=0"
		"FFVEncoder="
		"FFAEncoderId=0"
		"FFAEncoder="
		"FFAudioMixes=1"
		"VodTrackIndex=2"
		.
		"[General]"
		"Name=Untitled"
		.
		"[Video]"
		"BaseCX=!width!"
		"BaseCY=!height!"
		"OutputCX=!width!"
		"OutputCY=!height!"
		"FPSDen=1"
		"FPSType=2"
		"ScaleType=bilinear"
		"FPSNum=!FPS!"
		"ColorSpace=sRGB"
		"ColorRange=Partial"
		.
		"[Output]"
		"RecType=Standard"
		"Mode=Advanced"
	) do echo.%%~i)>"%TEMP%\Basic.ini"
	echo.{"bf":0,"cqp":18,"keyint_sec":0,"lookahead":"false","multipass":"disabled","preset2":"p1","profile":"baseline","psycho_aq":"false","rate_control":"CQP"} >"%TEMP%\RecordEncoder.json"
)

if %encoder% == AMF (
	(for %%i in (
		"[AdvOut]"
		"RecEncoder=h264_texture_amf"
		"RecRB=true"
		"TrackIndex=1"
		"RecType=Standard"
		"RecFormat=mp4"
		"RecTracks=1"
		"FLVTrack=1"
		"FFOutputToFile=true"
		"FFFormat="
		"FFFormatMimeType="
		"FFVEncoderId=0"
		"FFVEncoder="
		"FFAEncoderId=0"
		"FFAEncoder="
		"FFAudioMixes=1"
		"VodTrackIndex=2"
		.
		"[General]"
		"Name=Untitled"
		.
		"[Video]"
		"BaseCX=!width!"
		"BaseCY=!height!"
		"OutputCX=!width!"
		"OutputCY=!height!"
		"FPSDen=1"
		"FPSType=2"
		"ScaleType=bilinear"
		"FPSNum=!FPS!"
		"ColorSpace=sRGB"
		"ColorRange=Partial"
		.
		"[Output]"
		"RecType=Standard"
		"Mode=Advanced"
	) do echo.%%~i)>"%TEMP%\Basic.ini"
	echo.{"cqp":18,"preset":"speed","profile":"baseline","rate_control":"CQP"} >"%TEMP%\RecordEncoder.json"
)

if %encoder% == CPU (
	(for %%i in (
		"[AdvOut]"
		"RecEncoder=obs_x264"
		"RecRB=true"
		"TrackIndex=1"
		"RecType=Standard"
		"RecFormat=mp4"
		"RecTracks=1"
		"FLVTrack=1"
		"FFOutputToFile=true"
		"FFFormat="
		"FFFormatMimeType="
		"FFVEncoderId=0"
		"FFVEncoder="
		"FFAEncoderId=0"
		"FFAEncoder="
		"FFAudioMixes=1"
		"VodTrackIndex=2"
		.
		"[General]"
		"Name=Untitled"
		.
		"[Video]"
		"BaseCX=!width!"
		"BaseCY=!height!"
		"OutputCX=!width!"
		"OutputCY=!height!"
		"FPSDen=1"
		"FPSType=2"
		"ScaleType=bilinear"
		"FPSNum=!FPS!"
		"ColorSpace=sRGB"
		"ColorRange=Partial"
		.
		"[Output]"
		"RecType=Standard"
		"Mode=Advanced"
	) do echo.%%~i)>"%TEMP%\Basic.ini"
	echo.{"bitrate":30000,"preset":"veryfast","profile":"baseline","tune":"film"} >"%TEMP%\RecordEncoder.json"
)
move /Y "%TEMP%\basic.ini" "%APPDATA%\obs-studio\basic\profiles\Untitled\" >nul 2>&1
move /Y "%TEMP%\RecordEncoder.json" "%APPDATA%\obs-studio\basic\profiles\Untitled\" >nul 2>&1
goto HoneRenders

:Performance
if not exist "%SYSTEMDRIVE%\Program Files\obs-studio\bin\64bit" call:OBSInstall
	cd "%SYSTEMDRIVE%\Program Files\obs-studio\bin\64bit"
	taskkill /f /im obs64.exe >nul 2>&1
	Reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "%SYSTEMDRIVE%\Program Files\obs-studio\bin\64bit\obs64.exe" /t Reg_SZ /d "~ RUNASADMIN" /f >nul 2>&1
	REM get monitor resolution
	powershell -Command "((Get-CimInstance Win32_VideoController).VideoModeDescription.Split(' x ') | Where-Object {$_ -ne ''} | Select-Object -First 1)" > "%TEMP%\width.txt"
	powershell -Command "((Get-CimInstance Win32_VideoController).VideoModeDescription.Split(' x ') | Where-Object {$_ -ne ''} | Select-Object -First 1 -Skip 1)" > "%TEMP%\height.txt"
	set /p width=<"%TEMP%\width.txt"
	set /p height=<"%TEMP%\height.txt"
	cls & set /p FPS="What FPS would you like to record in? >: "
if %encoder% == NVENC (
	(for %%i in (
		"[AdvOut]"
		"RecEncoder=jim_nvenc"
		"RecRB=true"
		"TrackIndex=1"
		"RecType=Standard"
		"RecFormat=mp4"
		"RecTracks=1"
		"FLVTrack=1"
		"FFOutputToFile=true"
		"FFFormat="
		"FFFormatMimeType="
		"FFVEncoderId=0"
		"FFVEncoder="
		"FFAEncoderId=0"
		"FFAEncoder="
		"FFAudioMixes=1"
		"VodTrackIndex=2"
		.
		"[General]"
		"Name=Untitled"
		.
		"[Video]"
		"BaseCX=!width!"
		"BaseCY=!height!"
		"OutputCX=1280"
		"OutputCY=720"
		"FPSDen=1"
		"FPSType=2"
		"ScaleType=bicubic"
		"FPSNum=!FPS!"
		"ColorSpace=sRGB"
		"ColorRange=Partial"
		.
		"[Output]"
		"RecType=Standard"
		"Mode=Advanced"
	) do echo.%%~i)>"%TEMP%\Basic.ini"
	echo.{"bf":0,"cqp":19,"keyint_sec":0,"lookahead":"false","multipass":"disabled","preset2":"p1","profile":"baseline","psycho_aq":"false","rate_control":"CQP"} >"%TEMP%\RecordEncoder.json"
)

if %encoder% == AMF (
	(for %%i in (
		"[AdvOut]"
		"RecEncoder=h264_texture_amf"
		"RecRB=true"
		"TrackIndex=1"
		"RecType=Standard"
		"RecFormat=mp4"
		"RecTracks=1"
		"FLVTrack=1"
		"FFOutputToFile=true"
		"FFFormat="
		"FFFormatMimeType="
		"FFVEncoderId=0"
		"FFVEncoder="
		"FFAEncoderId=0"
		"FFAEncoder="
		"FFAudioMixes=1"
		"VodTrackIndex=2"
		.
		"[General]"
		"Name=Untitled"
		.
		"[Video]"
		"BaseCX=!width!"
		"BaseCY=!height!"
		"OutputCX=1280"
		"OutputCY=720"
		"FPSDen=1"
		"FPSType=2"
		"ScaleType=bicubic"
		"FPSNum=!FPS!"
		"ColorSpace=sRGB"
		"ColorRange=Partial"
		.
		"[Output]"
		"RecType=Standard"
		"Mode=Advanced"
	) do echo.%%~i)>"%TEMP%\Basic.ini"
	echo.{"cqp":18,"preset":"speed","profile":"baseline","rate_control":"CQP"} >"%TEMP%\RecordEncoder.json"
)

if %encoder% == CPU (
	(for %%i in (
		"[AdvOut]"
		"RecEncoder=obs_x264"
		"RecRB=true"
		"TrackIndex=1"
		"RecType=Standard"
		"RecFormat=mp4"
		"RecTracks=1"
		"FLVTrack=1"
		"FFOutputToFile=true"
		"FFFormat="
		"FFFormatMimeType="
		"FFVEncoderId=0"
		"FFVEncoder="
		"FFAEncoderId=0"
		"FFAEncoder="
		"FFAudioMixes=1"
		"VodTrackIndex=2"
		.
		"[General]"
		"Name=Untitled"
		.
		"[Video]"
		"BaseCX=!width!"
		"BaseCY=!height!"
		"OutputCX=1280"
		"OutputCY=720"
		"FPSDen=1"
		"FPSType=2"
		"ScaleType=bicubic"
		"FPSNum=!FPS!"
		"ColorSpace=sRGB"
		"ColorRange=Partial"
		.
		"[Output]"
		"RecType=Standard"
		"Mode=Advanced"
	) do echo.%%~i)>"%TEMP%\Basic.ini"
	echo.{"bitrate":25000,"preset":"ultrafast","profile":"baseline","tune":"fastdecode"} >"%TEMP%\RecordEncoder.json"
)
move /Y "%TEMP%\basic.ini" "%APPDATA%\obs-studio\basic\profiles\Untitled\" >nul 2>&1
move /Y "%TEMP%\RecordEncoder.json" "%APPDATA%\obs-studio\basic\profiles\Untitled\" >nul 2>&1
goto HoneRenders


:Streaming
cls
echo.
echo.
call :HoneTitle
echo.
echo                              %COL%[33m[ %COL%[37m1 %COL%[33m]%COL%[37m Quality                                        %COL%[33m[ %COL%[37m2 %COL%[33m]%COL%[37m Performance
echo                              %COL%[90mSettings for the best                                %COL%[90mSettings for the best
echo                              %COL%[90mquality in OBS                                       %COL%[90mperformance in OBS
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                                 %COL%[90m[ B for back ]         %COL%[31m[ X to close ]
echo.
set /p choice="%DEL%                                        %COL%[37mSelect a corresponding number to the options above > "
if /i "%choice%"=="1" goto Quality
if /i "%choice%"=="2" goto Performance
if /i "%choice%"=="B" goto HoneRenders
if /i "%choice%"=="X" goto exit /b
goto Streaming

:Quality
if not exist "%SYSTEMDRIVE%\Program Files\obs-studio\bin\64bit" call:OBSInstall
cd "%SYSTEMDRIVE%\Program Files\obs-studio\bin\64bit"
taskkill /f /im obs64.exe >nul 2>&1
Reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "%SYSTEMDRIVE%\Program Files\obs-studio\bin\64bit\obs64.exe" /t Reg_SZ /d "~ RUNASADMIN" /f >nul 2>&1
powershell -Command "((Get-CimInstance Win32_VideoController).VideoModeDescription.Split(' x ') | Where-Object {$_ -ne ''} | Select-Object -First 1)" > "%TEMP%\width.txt"
powershell -Command "((Get-CimInstance Win32_VideoController).VideoModeDescription.Split(' x ') | Where-Object {$_ -ne ''} | Select-Object -First 1 -Skip 1)" > "%TEMP%\height.txt"
set /p width=<"%TEMP%\width.txt"
set /p height=<"%TEMP%\height.txt"
cls & set /p FPS="What FPS would you like to record in? >: "
if %encoder% == NVENC (
	(for %%i in (
		"[AdvOut]"
		"RecEncoder=jim_nvenc"
		"RecRB=true"
		"TrackIndex=1"
		"RecType=Standard"
		"RecFormat=mp4"
		"RecTracks=1"
		"FLVTrack=1"
		"FFOutputToFile=true"
		"FFFormat="
		"FFFormatMimeType="
		"FFVEncoderId=0"
		"FFVEncoder="
		"FFAEncoderId=0"
		"FFAEncoder="
		"FFAudioMixes=1"
		"VodTrackIndex=2"
		"Encoder=jim_nvenc"
		.
		"[General]"
		"Name=Untitled"
		.
		"[Video]"
		"BaseCX=!width!"
		"BaseCY=!height!"
		"OutputCX=!width!"
		"OutputCY=!height!"
		"FPSDen=1"
		"FPSType=2"
		"ScaleType=bilinear"
		"FPSNum=!FPS!"
		"ColorSpace=sRGB"
		"ColorRange=Full"
		.
		"[Output]"
		"RecType=Standard"
		"Mode=Advanced"
	) do echo.%%~i)>"%TEMP%\Basic.ini"
	echo.{"bitrate":6000,"multipass":"disabled","preset2":"p1","profile":"baseline"} >"%TEMP%\StreamEncoder.json"
)

if %encoder% == AMF (
	(for %%i in (
		"[AdvOut]"
		"Encoder=h264_texture_amf"
		"RecEncoder=h264_texture_amf"
		"RecRB=true"
		"TrackIndex=1"
		"RecType=Standard"
		"RecFormat=mp4"
		"RecTracks=1"
		"FLVTrack=1"
		"FFOutputToFile=true"
		"FFFormat="
		"FFFormatMimeType="
		"FFVEncoderId=0"
		"FFVEncoder="
		"FFAEncoderId=0"
		"FFAEncoder="
		"FFAudioMixes=1"
		"VodTrackIndex=2"
		.
		"[General]"
		"Name=Untitled"
		.
		"[Video]"
		"BaseCX=!width!"
		"BaseCY=!height!"
		"OutputCX=!width!"
		"OutputCY=!height!"
		"FPSDen=1"
		"FPSType=2"
		"ScaleType=bilinear"
		"FPSNum=!FPS!"
		"ColorSpace=sRGB"
		"ColorRange=Full"
		.
		"[Output]"
		"RecType=Standard"
		"Mode=Advanced"
	) do echo.%%~i)>"%TEMP%\Basic.ini"
	echo.{"cqp":18,"preset":"speed","profile":"baseline","rate_control":"CQP"} >"%TEMP%\RecordEncoder.json"
)

if %encoder% == CPU (
	(for %%i in (
		"[AdvOut]"
		"RecEncoder=obs_x264"
		"RecRB=true"
		"TrackIndex=1"
		"RecType=Standard"
		"RecFormat=mp4"
		"RecTracks=1"
		"FLVTrack=1"
		"FFOutputToFile=true"
		"FFFormat="
		"FFFormatMimeType="
		"FFVEncoderId=0"
		"FFVEncoder="
		"FFAEncoderId=0"
		"FFAEncoder="
		"FFAudioMixes=1"
		"VodTrackIndex=2"
		"Encoder=obs_x264"
		.
		"[General]"
		"Name=Untitled"
		.
		"[Video]"
		"BaseCX=!width!"
		"BaseCY=!height!"
		"OutputCX=!width!"
		"OutputCY=!height!"
		"FPSDen=1"
		"FPSType=2"
		"ScaleType=bilinear"
		"FPSNum=!FPS!"
		"ColorSpace=sRGB"
		"ColorRange=Full"
		.
		"[Output]"
		"RecType=Standard"
		"Mode=Advanced"
	) do echo.%%~i)>"%TEMP%\Basic.ini"
	echo.{"bitrate":4000,"preset":"faster","profile":"baseline","tune":"film"} >"%TEMP%\StreamEncoder.json"
)
move /Y "%TEMP%\basic.ini" "%APPDATA%\obs-studio\basic\profiles\Untitled\" >nul 2>&1
move /Y "%TEMP%\StreamEncoder.json" "%APPDATA%\obs-studio\basic\profiles\Untitled\" >nul 2>&1
goto HoneRenders


:Performance
if not exist "%SYSTEMDRIVE%\Program Files\obs-studio\bin\64bit" call:OBSInstall
cd "%SYSTEMDRIVE%\Program Files\obs-studio\bin\64bit"
taskkill /f /im obs64.exe >nul 2>&1
Reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "%SYSTEMDRIVE%\Program Files\obs-studio\bin\64bit\obs64.exe" /t Reg_SZ /d "~ RUNASADMIN" /f >nul 2>&1
powershell -Command "((Get-CimInstance Win32_VideoController).VideoModeDescription.Split(' x ') | Where-Object {$_ -ne ''} | Select-Object -First 1)" > "%TEMP%\width.txt"
powershell -Command "((Get-CimInstance Win32_VideoController).VideoModeDescription.Split(' x ') | Where-Object {$_ -ne ''} | Select-Object -First 1 -Skip 1)" > "%TEMP%\height.txt"
set /p width=<"%TEMP%\width.txt"
set /p height=<"%TEMP%\height.txt"
cls & set /p FPS="What FPS would you like to record in? >: "
if %encoder% == NVENC (
	(for %%i in (
		"[AdvOut]"
		"RecEncoder=jim_nvenc"
		"RecRB=true"
		"TrackIndex=1"
		"RecType=Standard"
		"RecFormat=mp4"
		"RecTracks=1"
		"FLVTrack=1"
		"FFOutputToFile=true"
		"FFFormat="
		"FFFormatMimeType="
		"FFVEncoderId=0"
		"FFVEncoder="
		"FFAEncoderId=0"
		"FFAEncoder="
		"FFAudioMixes=1"
		"VodTrackIndex=2"
		"Encoder=jim_nvenc"
		.
		"[General]"
		"Name=Untitled"
		.
		"[Video]"
		"BaseCX=!width!"
		"BaseCY=!height!"
		"OutputCX=1280"
		"OutputCY=720"
		"FPSDen=1"
		"FPSType=2"
		"ScaleType=bicubic"
		"FPSNum=!FPS!"
		"ColorSpace=sRGB"
		"ColorRange=Partial"
		.
		"[Output]"
		"RecType=Standard"
		"Mode=Advanced"
	) do echo.%%~i)>"%TEMP%\Basic.ini"
	echo.{"bf":0,"bitrate":4500,"multipass":"disabled","preset2":"p1","profile":"baseline","psycho_aq":false} >"%TEMP%\StreamEncoder.json"
)

if %encoder% == AMF (
	(for %%i in (
		"[AdvOut]"
		"Encoder=h264_texture_amf"
		"RecEncoder=h264_texture_amf"
		"RecRB=true"
		"TrackIndex=1"
		"RecType=Standard"
		"RecFormat=mp4"
		"RecTracks=1"
		"FLVTrack=1"
		"FFOutputToFile=true"
		"FFFormat="
		"FFFormatMimeType="
		"FFVEncoderId=0"
		"FFVEncoder="
		"FFAEncoderId=0"
		"FFAEncoder="
		"FFAudioMixes=1"
		"VodTrackIndex=2"
		.
		"[General]"
		"Name=Untitled"
		.
		"[Video]"
		"BaseCX=!width!"
		"BaseCY=!height!"
		"OutputCX=1280"
		"OutputCY=720"
		"FPSDen=1"
		"FPSType=2"
		"ScaleType=bicubic"
		"FPSNum=!FPS!"
		"ColorSpace=sRGB"
		"ColorRange=Partial"
		.
		"[Output]"
		"RecType=Standard"
		"Mode=Advanced"
	) do echo.%%~i)>"%TEMP%\Basic.ini"
	echo.{"cqp":18,"preset":"speed","profile":"baseline","rate_control":"CQP"} >"%TEMP%\RecordEncoder.json"
)

if %encoder% == CPU (
	(for %%i in (
		"[AdvOut]"
		"RecEncoder=obs_x264"
		"RecRB=true"
		"TrackIndex=1"
		"RecType=Standard"
		"RecFormat=mp4"
		"RecTracks=1"
		"FLVTrack=1"
		"FFOutputToFile=true"
		"FFFormat="
		"FFFormatMimeType="
		"FFVEncoderId=0"
		"FFVEncoder="
		"FFAEncoderId=0"
		"FFAEncoder="
		"FFAudioMixes=1"
		"VodTrackIndex=2"
		"Encoder=obs_x264"
		.
		"[General]"
		"Name=Untitled"
		.
		"[Video]"
		"BaseCX=!width!"
		"BaseCY=!height!"
		"OutputCX=1280"
		"OutputCY=720"
		"FPSDen=1"
		"FPSType=2"
		"ScaleType=bicubic"
		"FPSNum=!FPS!"
		"ColorSpace=sRGB"
		"ColorRange=Partial"
		.
		"[Output]"
		"RecType=Standard"
		"Mode=Advanced"
	) do echo.%%~i)>"%TEMP%\Basic.ini"
	echo.{"bitrate":4000,"preset":"ultrafast","profile":"baseline","tune":"fastdecode"} >"%TEMP%\StreamEncoder.json"
)
move /Y "%TEMP%\basic.ini" "%APPDATA%\obs-studio\basic\profiles\Untitled\" >nul 2>&1
move /Y "%TEMP%\StreamEncoder.json" "%APPDATA%\obs-studio\basic\profiles\Untitled\" >nul 2>&1
goto HoneRenders


:upscale
where /q ffmpeg.exe || if not exist %SYSTEMDRIVE%\ffmpeg call :ffmpeginstall
cls
echo.
echo.
call :HoneTitle
echo.
echo                            %COL%[33m[ %COL%[37m1 %COL%[33m]%COL%[37m 4k                                             %COL%[33m[ %COL%[37m2 %COL%[33m]%COL%[37m 8k
echo                            %COL%[90mModify the scale of a video                          %COL%[90mModify the scale of a video
echo                            %COL%[90mto turn it to 4k                                     %COL%[90mto turn it to 8k
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                                 %COL%[90m[ B for back ]         %COL%[31m[ X to close ]
echo.
set /p choice="%DEL%                                        %COL%[37mSelect a corresponding number to the options above > "
if /i "%choice%"=="1" goto 4k
if /i "%choice%"=="2" goto 8k
if /i "%choice%"=="B" goto HoneRenders
if /i "%choice%"=="X" exit /b
goto upscale

:4k
cls
echo The path needs to be in between " " and have a simple name.
echo.
set /p "file= Print the path of the file you want to upscale or drag it in >> "
rem where /q ffmpeg.exe with the double ampersand/pipe is used to check if ffmpeg is already in the path, since it might be installed in a directory other than the default
if %encoder% == NVENC (
where /q ffmpeg.exe && (
		ffmpeg -i "%file%" -vf scale=3840:2160 -c:v h264_nvenc -preset slow -rc vbr -b:v 250M -cq 20 "%PUBLIC%\Desktop\4k.mp4" -y
	) || (
		%SYSTEMDRIVE%\ffmpeg\bin\ffmpeg.exe -i "%file%" -vf scale=3840:2160 -c:v h264_nvenc -preset slow -rc vbr -b:v 250M -cq 20 "%PUBLIC%\Desktop\4k.mp4" -y
	)
)

if %encoder% == AMF (
	where /q ffmpeg.exe && (
		ffmpeg -i "%file%" -vf scale=3840:2160 -c:v hevc_amf -quality quality -qp_i 18 -qp_p 20 -qp_b 24 "%PUBLIC%\Desktop\4k.mp4" -y
	) || (
		%SYSTEMDRIVE%\ffmpeg\bin\ffmpeg.exe -i "%file%" -vf scale=3840:2160 -c:v hevc_amf -quality quality -qp_i 18 -qp_p 20 -qp_b 24 "%PUBLIC%\Desktop\4k.mp4" -y
	)
)

if %encoder% == CPU (
	where /q ffmpeg.exe && (

		ffmpeg -i %file% -vf scale=3840:2160 -c:v libx264 -preset slow -crf 18 "%PUBLIC%\Desktop\4k.mp4" -y
	) || (
		%SYSTEMDRIVE%\ffmpeg\bin\ffmpeg -i %file% -vf scale=3840:2160 -c:v libx264 -preset slow -crf 18 "%PUBLIC%\Desktop\4k.mp4" -y
	)
)
goto upscale

:8k
cls
echo The path needs to be in between " " and have a simple name.
echo.
set /p "file= Print the path of the file you want to upscale or drag it in >> "
rem where /q ffmpeg.exe with the double ampersand/pipe is used to check if ffmpeg is already in the path, since it might be installed in a directory other than the default
if %encoder% == NVENC (
where /q ffmpeg.exe && (
		ffmpeg.exe -i "%file%" -vf scale=7680:4320 -c:v hevc_nvenc -preset slow -rc vbr -b:v 250M -cq 20 "%PUBLIC%\Desktop\8k.mp4" -y
	) || (
		%SYSTEMDRIVE%\ffmpeg\bin\ffmpeg.exe -i "%file%" -vf scale=7680:4320 -c:v hevc_nvenc -preset slow -rc vbr -b:v 250M -cq 20 "%PUBLIC%\Desktop\8k.mp4" -y
	)
)

if %encoder% == AMF (
	where /q ffmpeg.exe && (
		ffmpeg -i "%file%" -vf scale=7680:4320 -c:v hevc_amf -quality quality -qp_i 18 -qp_p 20 -qp_b 24 "%PUBLIC%\Desktop\8k.mp4" -y
	) || (
		%SYSTEMDRIVE%\ffmpeg\bin\ffmpeg.exe -i "%file%" -vf scale=7680:4320 -c:v hevc_amf -quality quality -qp_i 18 -qp_p 20 -qp_b 24 "%PUBLIC%\Desktop\8k.mp4" -y
	)
)

if %encoder% == CPU (
	where /q ffmpeg.exe && (
		ffmpeg.exe -i "%file%" -vf scale=7680:4320 -c:v libx264 -preset slow -crf 18 "%PUBLIC%\Desktop\8k.mp4" -y
	) || (
		%SYSTEMDRIVE%\ffmpeg\bin\ffmpeg.exe -i "%file%" -vf scale=7680:4320 -c:v libx264 -preset slow -crf 18 "%PUBLIC%\Desktop\8k.mp4" -y
	)
)
goto upscale

:compress
rem check if ffmpeg is in path, if it isn't, check if it's in the default installation path, and if it isn't, install it
where /q ffmpeg.exe || if not exist %SYSTEMDRIVE%\ffmpeg call :ffmpeginstall
cls
echo.
echo.
call :HoneTitle
echo.
echo                         %COL%[33m[ %COL%[37m1 %COL%[33m]%COL%[37m Heavy                                          %COL%[33m[ %COL%[37m2 %COL%[33m]%COL%[37m Light
echo                         %COL%[90mCompress a video                     	 	     %COL%[90mCompress a video
echo                         %COL%[90mto make it take up much less space                   %COL%[90mto make it take up less space
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                                 %COL%[90m[ B for back ]         %COL%[31m[ X to close ]
echo.
set /p choice="%DEL%                                        %COL%[37mSelect a corresponding number to the options above > "
if /i "%choice%"=="1" goto heavy
if /i "%choice%"=="2" goto light
if /i "%choice%"=="B" goto HoneRenders
if /i "%choice%"=="X" exit /b
goto compress

:heavy
cls
echo The path needs to be in between " " and have a simple name.
echo.
set /p "file= Print the path of the file you want to compress or drag it in >> "
	where /q ffmpeg.exe && (
		ffmpeg -i "%file%" -vf "scale=-2:trunc(ih*0.75/2)*2" -c:v libx264 -preset slower -crf 23 -aq-mode 3 -c:a aac -b:a 128k "%PUBLIC%\Desktop\heavycompress.mp4" -y
	) || (
		%SYSTEMDRIVE%\ffmpeg\bin\ffmpeg.exe -i "%file%" -vf "scale=-2:trunc(ih*0.75/2)*2" -c:v libx264 -preset slower -crf 23 -aq-mode 3 -c:a aac -b:a 128k "%PUBLIC%\Desktop\heavycompress.mp4" -y
	)
goto compress

:Light
cls
echo The path needs to be in between " " and have a simple name.
echo.
set /p "file= Print the path of the file you want to compress or drag it in >> "
	where /q ffmpeg.exe && (
		ffmpeg -i "%file%" -c:v libx264 -preset slow -crf 18 -aq-mode 3 -c:a aac -b:a 256k "%PUBLIC%\Desktop\lightcompress.mp4" -y
	) || (
		%SYSTEMDRIVE%\ffmpeg\bin\ffmpeg.exe -i "%file%" -c:v libx264 -preset slow -crf 18 -aq-mode 3 -c:a aac -b:a 256k "%PUBLIC%\Desktop\lightcompress.mp4" -y
	)
goto compress

:PreviewLag
if not exist %SYSTEMDRIVE%\ffmpeg ( call:ffmpeginstall )
cls
echo The path needs to be in between " " and have a simple name.
echo.
set /p "file= Print the path of the file you want use in vegas or drag it in (remember you need to replace it with the original file afterwards) >> "
	where /q ffmpeg.exe && (
		ffmpeg -i "%file%" -c:v libx264 -preset superfast -crf 23 -tune fastdecode -c:a copy "%PUBLIC%\Desktop\previewlag.mp4" -y
	) || (
		%SYSTEMDRIVE%\ffmpeg\bin\ffmpeg.exe -i "%file%" -c:v libx264 -preset superfast -crf 23 -tune fastdecode -c:a copy "%PUBLIC%\Desktop\previewlag.mp4" -y
	)
goto HoneRenders

:ffmpeginstall
cls
curl -g -L -# -o "%TEMP%\ffmpeg.zip" "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip"
powershell -Command "Expand-Archive -Path %TEMP%\ffmpeg.zip -DestinationPath %SYSTEMDRIVE%\ffmpeg"
powershell -Command "Convert-Path '%SYSTEMDRIVE%\ffmpeg\ffmpeg-*-essentials_build\*' | ForEach-Object {Move-Item $_ '%SYSTEMDRIVE%\ffmpeg'}"
powershell -Command "Convert-Path '%SYSTEMDRIVE%\ffmpeg\ffmpeg-*-essentials_build\' | Remove-Item"
goto:eof

:blurinstall
rem delete old blur
rmdir /s /q "%SYSTEMDRIVE%\program files (x86)\blur"
cls
curl -g -L -# -o "%TEMP%\blur.exe" "https://github.com/f0e/blur/releases/latest/download/blur-installer.exe"
"%TEMP%\blur.exe" /SP /VERYSILENT /SUPPRESSMSGBOXES /NOCANCEL /NORESTART /ALLUSERS
goto :eof

:FPSGames
cls
echo.
echo.
call :HoneTitle
echo.
echo                    	     %COL%[33m[ %COL%[37m1 %COL%[33m]%COL%[37m Accurate                                   %COL%[33m[ %COL%[37m2 %COL%[33m]%COL%[37m Smooth
echo                     	     %COL%[90mAutomated Blur settings                          %COL%[90mAutomated Blur settings
echo                     	     %COL%[90mfor the most precise results             	      %COL%[90mfor the smoothest results
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                                 %COL%[90m[ B for back ]         %COL%[31m[ X to close ]
echo.
set /p choice="%DEL%                                        %COL%[37mSelect a corresponding number to the options above > "
if /i "%choice%"=="1" goto Accurate
if /i "%choice%"=="2" goto Smooth
if /i "%choice%"=="B" goto HoneRenders
if /i "%choice%"=="X" exit /b
goto FPSGames

:Accurate
cls
echo.
echo.
call :HoneTitle
echo.
echo					%COL%[33m[ %COL%[37m1 %COL%[33m]%COL%[37m 60-120FPS                                   %COL%[33m[ %COL%[37m2 %COL%[33m]%COL%[37m 240FPS+
echo					%COL%[90mAutomated Blur settings				  %COL%[90mAutomated Blur settings
echo					%COL%[90mfor 60-120FPS clips				  %COL%[90mfor 240FPS+ clips
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                                 %COL%[90m[ B for back ]         %COL%[31m[ X to close ]
echo.
set /p choice="%DEL%                                        %COL%[37mSelect a corresponding number to the options above > "
if /i "%choice%"=="1" goto Accurate60120
if /i "%choice%"=="2" goto Accurate240
if /i "%choice%"=="B" goto FPSGames
if /i "%choice%"=="X" exit /b
goto Accurate

:Accurate60120
if not exist "%SYSTEMDRIVE%\Program Files (x86)\blur" call:blurinstall
if %encoder% == NVENC (
if not exist "%SYSTEMDRIVE%\Hone\Renders\FPSAccurate60Nvidia.cfg" ( 
curl -g -k -L -# -o "%SYSTEMDRIVE%\Hone\Renders\FPSAccurate60Nvidia.cfg" "https://raw.githubusercontent.com/auraside/HoneCtrl/main/Files/FPS/Accurate/60-120/Nvidia/FPSAccurate60Nvidia.cfg"
) else (
set config=FPSAccurate60Nvidia.cfg
goto skip
)
)

if %encoder% == AMF (
if not exist "%SYSTEMDRIVE%\Hone\Renders\FPSAccurate60AMD.cfg" ( 
curl -g -k -L -# -o "%SYSTEMDRIVE%\Hone\Renders\FPSAccurate60AMD.cfg" "https://raw.githubusercontent.com/auraside/HoneCtrl/main/Files/FPS/Accurate/60-120/Amd/FPSAccurate60AMD.cfg"
) else (
set config=FPSAccurate60AMD.cfg
goto skip
)
)

if %encoder% == CPU (
if not exist "%SYSTEMDRIVE%\Hone\Renders\FPSAccurate60Intel.cfg" ( 
curl -g -k -L -# -o "%SYSTEMDRIVE%\Hone\Renders\FPSAccurate60Intel.cfg" "https://raw.githubusercontent.com/auraside/HoneCtrl/main/Files/FPS/Accurate/60-120/Intel/FPSAccurate60Intel.cfg"
) else (
set config=FPSAccurate60Intel.cfg
goto skip
)
)

:Accurate240
if not exist "%SYSTEMDRIVE%\Program Files (x86)\blur" call:blurinstall
if %encoder% == NVENC (
if not exist "%SYSTEMDRIVE%\Hone\Renders\FPSAccurate240Nvidia.cfg" ( 
curl -g -k -L -# -o "%SYSTEMDRIVE%\Hone\Renders\FPSAccurate240Nvidia.cfg" "https://raw.githubusercontent.com/auraside/HoneCtrl/main/Files/FPS/Accurate/240/Nvidia/FPSAccurate240Nvidia.cfg"
) else (
set config=FPSAccurate240Nvidia.cfg
goto skip
)
)

if %encoder% == AMF (
if not exist "%SYSTEMDRIVE%\Hone\Renders\FPSAccurate240AMD.cfg" ( 
curl -g -k -L -# -o "%SYSTEMDRIVE%\Hone\Renders\FPSAccurate240AMD.cfg" "https://raw.githubusercontent.com/auraside/HoneCtrl/main/Files/FPS/Accurate/240/Amd/FPSAccurate240AMD.cfg"
) else (
set config=FPSAccurate240AMD.cfg
goto skip
)
)

if %encoder% == CPU (
if not exist "%SYSTEMDRIVE%\Hone\Renders\FPSAccurate240Intel.cfg" ( 
curl -g -k -L -# -o "%SYSTEMDRIVE%\Hone\Renders\FPSAccurate240Intel.cfg" "https://raw.githubusercontent.com/auraside/HoneCtrl/main/Files/FPS/Accurate/240/Intel/FPSAccurate240Intel.cfg"
) else (
set config=FPSAccurate240Intel.cfg
goto skip
)
)

:Smooth
if not exist "%SYSTEMDRIVE%\Program Files (x86)\blur" call:blurinstall
if %encoder% == NVENC (
if not exist "%SYSTEMDRIVE%\Hone\Renders\FPSSmoothNvidia.cfg" ( 
curl -g -k -L -# -o "%SYSTEMDRIVE%\Hone\Renders\FPSSmoothNvidia.cfg" "https://raw.githubusercontent.com/auraside/HoneCtrl/main/Files/FPS/Smooth/Nvidia/FPSSmoothNvidia.cfg"
) else (
set config=FPSSmoothNvidia.cfg
goto skip
)
)

if %encoder% == AMF (
if not exist "%SYSTEMDRIVE%\Hone\Renders\FPSSmoothAmd.cfg.cfg" ( 
curl -g -k -L -# -o "%SYSTEMDRIVE%\Hone\Renders\FPSSmoothAmd.cfg" "https://raw.githubusercontent.com/auraside/HoneCtrl/main/Files/FPS/Smooth/Amd/FPSSmoothAmd.cfg"
) else (
set config=FPSSmoothAmd.cfg.cfg
goto skip
)
)

if %encoder% == CPU (
if not exist "%SYSTEMDRIVE%\Hone\Renders\FPSSmoothIntel.cfg" ( 
curl -g -k -L -# -o "%SYSTEMDRIVE%\Hone\Renders\FPSSmoothIntel.cfg" "https://raw.githubusercontent.com/auraside/HoneCtrl/main/Files/FPS/Smooth/Intel/FPSSmoothIntel.cfg"
) else (
set config=FPSSmoothIntel.cfg
goto skip
)
)

:MinecraftBlur
cls
echo.
echo.
call :HoneTitle
echo.
echo.
echo.
echo            	   %COL%[33m[%COL%[37m 1 %COL%[33m]%COL%[37m Any			%COL%[33m[%COL%[37m 2 %COL%[33m]%COL%[37m 240-360FPS			%COL%[33m[%COL%[37m 3 %COL%[33m]%COL%[37m 480FPS+
echo			   %COL%[90mAutomated Blur settings      %COL%[90mAutomated Blur settings    	 	%COL%[90mAutomated Blur settings
echo			   %COL%[90mfor any clips        	%COL%[90mfor 240-360FPS clips            	%COL%[90mfor 480FPS+ clips
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                                 %COL%[90m[ B for back ]         %COL%[31m[ X to close ]
echo.
set /p choice="%DEL%                                        %COL%[37mSelect a corresponding number to the options above > "
if /i "%choice%"=="1" goto MinecraftAny
if /i "%choice%"=="2" goto Minecraft240360
if /i "%choice%"=="B" goto Minecraft480
if /i "%choice%"=="X" exit /b
goto MinecraftBlur

:MinecraftAny
if not exist "%SYSTEMDRIVE%\Program Files (x86)\blur" call:blurinstall
if %encoder% == NVENC (
if not exist "%SYSTEMDRIVE%\Hone\Renders\MinecraftAnyNvidia.cfg" ( 
curl -g -k -L -# -o "%SYSTEMDRIVE%\Hone\Renders\MinecraftAnyNvidia.cfg" "https://raw.githubusercontent.com/auraside/HoneCtrl/main/Files/Minecraft/Any/Nvidia/MinecraftAnyNvidia.cfg"
) else (
set config=MinecraftAnyNvidia.cfg
goto skip
)
)

if %encoder% == AMF (
if not exist "%SYSTEMDRIVE%\Hone\Renders\MinecraftAnyAmd.cfg" ( 
curl -g -k -L -# -o "%SYSTEMDRIVE%\Hone\Renders\MinecraftAnyAmd.cfg" "https://raw.githubusercontent.com/auraside/HoneCtrl/main/Files/Minecraft/Any/Amd/MinecraftAnyAmd.cfg"
) else (
set config=MinecraftAnyAmd.cfg
goto skip
)
)

if %encoder% == CPU (
if not exist "%SYSTEMDRIVE%\Hone\Renders\MinecraftAnyIntel.cfg" ( 
curl -g -k -L -# -o "%SYSTEMDRIVE%\Hone\Renders\MinecraftAnyIntel.cfg" "https://raw.githubusercontent.com/auraside/HoneCtrl/main/Files/Minecraft/Any/Intel/MinecraftAnyIntel.cfg"
) else (
set config=MinecraftAnyIntel.cfg
goto skip
)
)

:Minecraft240360
if not exist "%SYSTEMDRIVE%\Program Files (x86)\blur" call:blurinstall
if %encoder% == NVENC (
if not exist "%SYSTEMDRIVE%\Hone\Renders\Minecraft240Nvidia.cfg" ( 
curl -g -k -L -# -o "%SYSTEMDRIVE%\Hone\Renders\Minecraft240Nvidia.cfg" "https://raw.githubusercontent.com/auraside/HoneCtrl/main/Files/Minecraft/240-360/Nvidia/Minecraft240Nvidia.cfg"
) else (
set config=Minecraft240Nvidia.cfg
goto skip
)
)

if %encoder% == AMF (
if not exist "%SYSTEMDRIVE%\Hone\Renders\Minecraft240Amd.cfg" ( 
curl -g -k -L -# -o "%SYSTEMDRIVE%\Hone\Renders\Minecraft240Amd.cfg" "https://raw.githubusercontent.com/auraside/HoneCtrl/main/Files/Minecraft/240-360/Amd/Minecraft240Amd.cfg"
) else (
set config=Minecraft240Amd.cfg
goto skip
)
)

if %encoder% == CPU (
if not exist "%SYSTEMDRIVE%\Hone\Renders\Minecraft240Intel.cfg" ( 
curl -g -k -L -# -o "%SYSTEMDRIVE%\Hone\Renders\Minecraft240Intel.cfg" "https://raw.githubusercontent.com/auraside/HoneCtrl/main/Files/Minecraft/240-360/Intel/Minecraft240Intel.cfg"
) else (
set config=Minecraft240Intel.cfg
goto skip
)
)

:Minecraft480
if not exist "%SYSTEMDRIVE%\Program Files (x86)\blur" call:blurinstall
if %encoder% == NVENC (
if not exist "%SYSTEMDRIVE%\Hone\Renders\Minecraft480Nvidia.cfg" ( 
curl -g -k -L -# -o "%SYSTEMDRIVE%\Hone\Renders\Minecraft480Nvidia.cfg" "https://raw.githubusercontent.com/auraside/HoneCtrl/main/Files/Minecraft/480+/Nvidia/Minecraft480Nvidia.cfg"
) else (
set config=Minecraft480Nvidia.cfg
goto skip
)
)

if %encoder% == AMF (
if not exist "%SYSTEMDRIVE%\Hone\Renders\Minecraft480Amd.cfg" ( 
curl -g -k -L -# -o "%SYSTEMDRIVE%\Hone\Renders\Minecraft480Amd.cfg" "https://raw.githubusercontent.com/auraside/HoneCtrl/main/Files/Minecraft/480+/Amd/Minecraft480Amd.cfg"
) else (
set config=Minecraft480Amd.cfg
goto skip
)
)

if %encoder% == CPU (
if not exist "%SYSTEMDRIVE%\Hone\Renders\Minecraft480Intel.cfg" ( 
curl -g -k -L -# -o "%SYSTEMDRIVE%\Hone\Renders\Minecraft480Intel.cfg" "https://raw.githubusercontent.com/auraside/HoneCtrl/main/Files/Minecraft/480+/Intel/Minecraft480Intel.cfg"
) else (
set config=Minecraft480Intel.cfg
goto skip
)
)

:skip
cls
echo The path needs to be in between " " and have a simple name.
echo.
set /p "file= Print the path of the file you want blurred into this window or drag it in >> "
"%SYSTEMDRIVE%\program files (x86)\blur\blur.exe" -i %file% -c "%SYSTEMDRIVE%\Hone\Renders\%config%" -n -p -v
goto HoneRenders

:NLEInstall
cls
echo.
echo.
call :HoneTitle
echo                       %COL%[90mUnfortunately, Hone cannot supply unofficial distributions of software. If you
echo                       %COL%[90mcannot buy Vegas Pro, an alternative that we recommend is a freemium video editing software
echo                       %COL%[90mcalled 'DaVinci Resolve' (note: this program does not contain render settings)^^!
echo.
echo.
echo                           %COL%[33m[ %COL%[37m1 %COL%[33m]%COL%[37m Vegas Pro website                        %COL%[33m[ %COL%[37m2 %COL%[33m]%COL%[37m DaVinci Resolve website
echo                           %COL%[90mPaid with supported renders                    %COL%[90mFree but unsupported renders
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                                 %COL%[90m[ B for back ]         %COL%[31m[ X to close ]
echo.
set /p choice="%DEL%                                        %COL%[37mSelect a corresponding number to the options above > "
if /i "%choice%"=="1" start https://www.vegascreativesoftware.com/us/vegas-pro/
if /i "%choice%"=="2" start https://www.blackmagicdesign.com/products/davinciresolve
if /i "%choice%"=="B" goto HoneRenders
if /i "%choice%"=="X" exit /b
goto NLEInstall

:ProjectSettings
cls
if exist "%SYSTEMDRIVE%\Program Files\VEGAS\VEGAS Pro 17.0" (
	curl -g -k -L -# -o "%TEMP%\project.reg" "https://raw.githubusercontent.com/auraside/HoneCtrl/main/Files/Settings/ProjectProperties17.reg"
) >nul 2>&1 else if exist "%SYSTEMDRIVE%\Program Files\VEGAS\VEGAS Pro 17" (
	curl -g -k -L -# -o "%TEMP%\project.reg" "https://raw.githubusercontent.com/auraside/HoneCtrl/main/Files/Settings/ProjectProperties17.reg"
) >nul 2>&1 else if exist "%SYSTEMDRIVE%\Program Files\VEGAS\VEGAS Pro 18" (
	curl -g -k -L -# -o "%TEMP%\project.reg" "https://raw.githubusercontent.com/auraside/HoneCtrl/main/Files/Settings/ProjectProperties18.reg"
) >nul 2>&1 else if exist "%SYSTEMDRIVE%\Program Files\VEGAS\VEGAS Pro 18.0" (
	curl -g -k -L -# -o "%TEMP%\project.reg" "https://raw.githubusercontent.com/auraside/HoneCtrl/main/Files/Settings/ProjectProperties18.reg"
) >nul 2>&1 else if exist "%SYSTEMDRIVE%\Program Files\VEGAS\VEGAS Pro 19.0" (
	curl -g -k -L -# -o "%TEMP%\project.reg" "https://raw.githubusercontent.com/auraside/HoneCtrl/main/Files/Settings/ProjectProperties18.reg"
) >nul 2>&1 else if exist "%SYSTEMDRIVE%\Program Files\VEGAS\VEGAS Pro 19" (
	curl -g -k -L -# -o "%TEMP%\project.reg" "https://raw.githubusercontent.com/auraside/HoneCtrl/main/Files/Settings/ProjectProperties18.reg"
) >nul 2>&1 else echo Vegas Pro 17-19 isn't installed... & pause & goto HoneRenders
taskkill /f /im Vegas170.exe >nul 2>&1
taskkill /f /im Vegas180.exe >nul 2>&1
taskkill /f /im Vegas190.exe >nul 2>&1
curl -g -k -L -# -o "%TEMP%\Hone.veg" "https://github.com/auraside/HoneCtrl/raw/main/Files/Settings/Hone.veg"
reg import "%TEMP%\project.reg" >nul 2>&1
start "" /D "%TEMP%\Hone.veg" >nul 2>&1
goto HoneRenders

:RenderSettings
cls
if not exist "%SYSTEMDRIVE%\Program Files\VEGAS\VEGAS Pro 17.0" goto NoVegas
if not exist "%SYSTEMDRIVE%\Program Files\VEGAS\VEGAS Pro 18.0" goto NoVegas
if not exist "%SYSTEMDRIVE%\Program Files\VEGAS\VEGAS Pro 19.0" goto NoVegas
taskkill /f /im Vegas170.exe >nul 2>&1
taskkill /f /im Vegas180.exe >nul 2>&1
taskkill /f /im Vegas190.exe >nul 2>&1
mkdir "%APPDATA%\VEGAS\Render Templates\avc" >nul 2>&1
curl -g -k -L -# -o "%APPDATA%\VEGAS\Render Templates\avc\Hone.sft2" "https://cdn.discordapp.com/attachments/934698794933702666/987166340714471514/Hone.sft2"
goto HoneRenders
:NoVegas
echo Vegas Pro 17-19 isn't installed...
pause
goto HoneRenders

:Disclaimer2
reg query "HKCU\Software\Hone" /v "Disclaimer2" >nul 2>&1 && goto Advanced
cls
echo.
echo.
call :HoneTitle
echo.
echo                                        %COL%[90m HoneCtrl is a free and open-source desktop utility
echo                                        %COL%[90m    made to improve your day-to-day productivity
echo.
echo.
echo.
echo %COL%[91m  WARNING:
echo.
echo     %COL%[33m1.%COL%[37m These Tweaks are HIGHLY experimental, we do %COL%[91mnot%COL%[37m recommend proceeding if you do not know what you're doing!
echo.
echo     %COL%[33m1.%COL%[37m Everything is "use at your own risk", we are %COL%[91mNOT LIABLE%COL%[37m if you damage your system in any way.
echo.
echo     %COL%[33m1.%COL%[37m Even though we have an automatic restore point feature, we %COL%[91mHighly%COL%[37m recommend making a manual restore point before running.
echo.
echo     Please enter "I agree" (without quotes) to continue:
echo.
echo                                                        %COL%[90m[ B for back ]
echo.
set /p "input=%DEL%                                                            >: %COL%[92m"
if /i "!input!"=="B" goto TweaksPG3
if /i "!input!" neq "i agree" goto Disclaimer2
reg add "HKCU\Software\Hone" /v "Disclaimer2" /f >nul 2>&1

:Advanced
REM for /f "tokens=2 delims==" %%a in ('wmic path Win32_Battery Get BatteryStatus /value ^| findstr "BatteryStatus"') do set status=%%a
REM if %status% == 1 ( set Battery=DC ) else ( set Battery=AC )
set "choice="
for %%i in (DSCOF AUTOF DRIOF BCDOF NONOF CS0OF TOFOF PS0OF IDLOF CONG DPSOF) do (set "%%i=%COL%[92mON ") >nul 2>&1
(
	rem Disable Idle
	powercfg /qh scheme_current sub_processor IDLEDISABLE | find "AC Power Setting Index: 0x00000000" && set "IDLOF=%COL%[91mOFF"
	rem powercfg /qh scheme_current sub_processor IDLEDISABLE | find "Current %Battery% Power Setting Index: 0x00000000" && set "IDLOF=%COL%[91mOFF"
	rem DSCP Tweaks
	reg query "HKLM\Software\Policies\Microsoft\Windows\QoS\javaw" || set "DSCOF=%COL%[91mOFF"
	rem AutoTuning Tweak
	reg query "HKCU\Software\Hone" /v "TuningTweak" || set "AUTOF=%COL%[91mOFF"
	rem Congestion Provider Tweak
	reg query "HKCU\Software\Hone" /v "CongestionAdvancedON" || set "CONG=%COL%[91mOFF"
	rem Disable USB Powersavings
	reg query "HKCU\Software\Hone" /v "DUSBPowerSavings" || set "DPSOF=%COL%[91mOFF"
	rem Nvidia Drivers
	cd "%SYSTEMDRIVE%\Program Files\NVIDIA Corporation\NVSMI"
	for /f "tokens=1 skip=1" %%a in ('nvidia-smi --query-gpu^=driver_version --format^=csv') do if "%%a" neq "528.24" set "DRIOF=%COL%[91mOFF"
	rem BCDEDIT
	reg query "HKCU\Software\Hone" /v "BcdEditTweaks" || set "BCDOF=%COL%[91mOFF"
	rem NonBestEffortLimit Tweak
	reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "NonBestEffortLimit" | find "0xa" || set "NONOF=%COL%[91mOFF"
	rem CS0 Tweak
	reg query "HKLM\SYSTEM\ControlSet001\Control\Class\{4D36E968-E325-11CE-BFC1-08002BE10318}\0000" /v "AllowDeepCStates" | find "0x0" || set "CS0OF=%COL%[91mOFF"
	rem Task Offloading
	reg query "HKLM\SYSTEM\CurrentControlSet\Services\TCPIP\Parameters" /v "DisableTaskOffload" | find "0x1" || set "TOFOF=%COL%[91mOFF"
	rem PStates0
	For /F "tokens=*" %%i in ('reg query "HKLM\SYSTEM\ControlSet001\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /t REG_SZ /s /e /f "NVIDIA" ^| findstr "HK"') do (reg query "%%i" /v "DisableDynamicPstate" | find "0x1" || set "PS0OF=%COL%[91mOFF")
	rem Check If Applicable For PC
	rem GPU
	for /f "tokens=2 delims==" %%a in ('wmic path Win32_VideoController get VideoProcessor /value') do (
		for %%n in (GeForce NVIDIA RTX GTX) do echo %%a | find "%%n" >nul && set "NVIDIAGPU=Found"
		for %%n in (AMD Ryzen) do echo %%a | find "%%n" >nul && set "AMDGPU=Found"
		for %%n in (Intel UHD) do echo %%a | find "%%n" >nul && set "INTELGPU=Found"
	)
	if "!NVIDIAGPU!" neq "Found" for %%g in (PS0OF DRIOF) do set "%%g=%COL%[93mN/A"
) >nul 2>&1
cls
echo.
echo.
call :HoneTitle
echo                                                           %COL%[1;4;34mNetwork Tweaks%COL%[0m
echo.
echo              %COL%[33m[%COL%[37m 1 %COL%[33m]%COL%[37m Disable Task Offloading %TOFOF%    %COL%[33m[%COL%[37m 2 %COL%[33m]%COL%[37m NonBestEffortLimit %NONOF%         %COL%[33m[%COL%[37m 3 %COL%[33m]%COL%[37m AutoTuning %AUTOF%
echo              %COL%[90mTask Offloading assigns the          %COL%[90mAllocate more bandwidth to apps      %COL%[90mCan reduce bufferbloat,
echo              %COL%[90mCPU to handle the NIC load           %COL%[90mUse only on fast connections         %COL%[90mbut lower your Network speed
echo.
echo                           %COL%[33m[%COL%[37m 4 %COL%[33m]%COL%[37m DSCP Value %DSCOF%                      %COL%[33m[%COL%[37m 5 %COL%[33m]%COL%[37m Wi-fi Congestion Provider %CONG%
echo                           %COL%[90mSet the priority of your network          %COL%[91mTurn ON only, if you have Wi-Fi.
echo                           %COL%[90mtraffic to expedited forwarding           %COL%[90mChanges the algorithm on how data is processed.
echo.
echo.
echo                                                            %COL%[1;4;34mPower Tweaks%COL%[0m
echo.
echo              %COL%[33m[%COL%[37m 6 %COL%[33m]%COL%[37m Disable C-States %CS0OF%           %COL%[33m[%COL%[37m 7 %COL%[33m]%COL%[37m PStates 0 %PS0OF%                  %COL%[33m[%COL%[37m 8 %COL%[33m]%COL%[37m Disable Idle %IDLOF%
echo              %COL%[90mKeep CPU at C0 stopping throttling   %COL%[90mRun graphics card at its highest     %COL%[90mForce CPU to always be running
echo              %COL%[90mwill make PC generate more heat      %COL%[90mdefined frequencies                  %COL%[90mat highest CPU state
echo.
echo.
echo                                                            %COL%[1;4;34mOther Tweaks%COL%[0m
echo.
echo              %COL%[33m[%COL%[37m 9 %COL%[33m]%COL%[37m Nvidia Driver %DRIOF%              %COL%[33m[%COL%[37m 10 %COL%[33m]%COL%[37m BCDEdit %BCDOF%                   %COL%[33m[%COL%[37m 11 %COL%[33m]%COL%[37m Disable USB Power Savings %DPSOF%
echo              %COL%[90mInstall the best tweaked nvidia      %COL%[90mTweaks your windows boot config      %COL%[90mDisable USB power savings that
echo              %COL%[90mdriver for latency and fps           %COL%[90mdata to optimized settings           %COL%[90maffect latency
echo.
echo.
echo.
echo                                                 %COL%[90m[ B for back ]         %COL%[31m[ X to close ]%COL%[37m
echo.
set /p choice="%DEL%                                        %COL%[37mSelect a corresponding number to the options above > "
if /i "%choice%"=="1" goto TaskOffloading
if /i "%choice%"=="2" goto NonBestEffortLimit
if /i "%choice%"=="3" goto Autotuning
if /i "%choice%"=="4" goto DSCPValue
if /i "%choice%"=="5" goto Congestion
if /i "%choice%"=="6" goto cstates
if /i "%choice%"=="7" goto pstates0
if /i "%choice%"=="8" goto DisableIdle
if /i "%choice%"=="9" goto Driver
if /i "%choice%"=="10" goto BCDEdit
if /i "%choice%"=="11" goto DUSBPowerSavings
if /i "%choice%"=="X" exit /b
if /i "%choice%"=="B" goto MainMenu
goto Advanced

:TaskOffloading
if "%TOFOF%" == "%COL%[91mOFF" (
	netsh int ip set global taskoffload=disabled >nul 2>&1
	reg add HKLM\SYSTEM\CurrentControlSet\Services\TCPIP\Parameters /v DisableTaskOffload /t REG_DWORD /d 1 /f
) >nul 2>&1 else (
	netsh int ip set global taskoffload=enabled >nul 2>&1
	reg add HKLM\SYSTEM\CurrentControlSet\Services\TCPIP\Parameters /v DisableTaskOffload /t REG_DWORD /d 0 /f
) >nul 2>&1
goto Advanced

:NonBestEffortLimit
if "%NONOF%" == "%COL%[91mOFF" (
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "NonBestEffortLimit" /t REG_DWORD /d "10" /f
) >nul 2>&1 else (
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "NonBestEffortLimit" /f
) >nul 2>&1
goto Advanced


:Autotuning
if "%AUTOF%" == "%COL%[91mOFF" (
	reg add "HKCU\Software\Hone" /v TuningTweak /f
	netsh int tcp set global autotuninglevel=disabled
	netsh winsock set autotuning off
) >nul 2>&1 else (
	reg delete "HKCU\Software\Hone" /v TuningTweak /f
	netsh int tcp set global autotuninglevel=normal
	netsh winsock set autotuning on
) >nul 2>&1
goto Advanced

:DSCPValue
if "%DSCOF%" == "%COL%[91mOFF" (
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Psched" /v "Start" /t Reg_DWORD /d "1" /f
	sc start Psched
	for %%i in (csgo VALORANT-Win64-Shipping javaw FortniteClient-Win64-Shipping ModernWarfare r5apex) do (
		reg query "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" || (
			reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Application Name" /t Reg_SZ /d "%%i.exe" /f
			reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Version" /t Reg_SZ /d "1.0" /f
			reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Protocol" /t Reg_SZ /d "*" /f
			reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Local Port" /t Reg_SZ /d "*" /f
			reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Local IP" /t Reg_SZ /d "*" /f
			reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Local IP Prefix Length" /t Reg_SZ /d "*" /f
			reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Remote Port" /t Reg_SZ /d "*" /f
			reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Remote IP" /t Reg_SZ /d "*" /f
			reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Remote IP Prefix Length" /t Reg_SZ /d "*" /f
			reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "DSCP Value" /t Reg_SZ /d "46" /f
			reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Throttle Rate" /t Reg_SZ /d "-1" /f
		)
	)
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\DiffservByteMappingConforming" /v "ServiceTypeGuaranteed" /t REG_DWORD /d "46" /f
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\DiffservByteMappingConforming" /v "ServiceTypeNetworkControl" /t REG_DWORD /d "56" /f
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\DiffservByteMappingNonConforming" /v "ServiceTypeGuaranteed" /t REG_DWORD /d "46" /f
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\DiffservByteMappingNonConforming" /v "ServiceTypeNetworkControl" /t REG_DWORD /d "56" /f
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\UserPriorityMapping" /v "ServiceTypeGuaranteed" /t REG_DWORD /d "5" /f
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\UserPriorityMapping" /v "ServiceTypeNetworkControl" /t REG_DWORD /d "7" /f
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "MaxOutstandingSends" /t REG_DWORD /d "65000" /f
) >nul 2>&1 else (
	for %%i in (csgo VALORANT-Win64-Shipping javaw FortniteClient-Win64-Shipping ModernWarfare r5apex) do (
		reg delete "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /f
	)
	reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\DiffservByteMappingConforming" /v "ServiceTypeGuaranteed" /f
	reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\DiffservByteMappingConforming" /v "ServiceTypeNetworkControl" /f
	reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\DiffservByteMappingNonConforming" /v "ServiceTypeGuaranteed" /f
	reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\DiffservByteMappingNonConforming" /v "ServiceTypeNetworkControl" /f
	reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\UserPriorityMapping" /v "ServiceTypeGuaranteed" /f
	reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\UserPriorityMapping" /v "ServiceTypeNetworkControl" /f
	reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "MaxOutstandingSends" /f
) >nul 2>&1
goto Advanced

:Congestion
Reg query "HKCU\Software\Hone" /v "WifiDisclaimer3" >nul 2>&1 && goto Congestion2
cls
echo.
echo.
call :HoneTitle
echo.
echo                                        %COL%[90m HoneCtrl is a free and open-source desktop utility
echo                                        %COL%[90m    made to improve your day-to-day productivity
echo.
echo.
echo.
echo %COL%[91m  WARNING:
echo %COL%[91m  This tweak is for Wi-Fi users only, if you're on Ethernet, do not run this tweak.
echo.
echo   %COL%[37mFor any questions and/or concerns, please join our discord: discord.gg/hone
echo.
echo   %COL%[37mPlease enter "I understand" without quotes to continue:
echo.
echo.
echo.
set /p "input=%DEL%                                                            >: %COL%[92m"
if /i "!input!" neq "i understand" goto Tweaks
Reg add "HKCU\Software\Hone" /v "WifiDisclaimer3" /f >nul 2>&1
:Congestion2
if "%CONG%" == "%COL%[91mOFF" (
	reg add "HKCU\Software\Hone" /v CongestionAdvancedON /f
	netsh int tcp set supplemental Internet congestionprovider=newreno
) >nul 2>&1 else (
	reg delete "HKCU\Software\Hone" /v CongestionAdvancedON /f
	netsh int tcp set supplemental Internet congestionprovider=default
) >nul 2>&1
goto Advanced

:cstates
if "%CS0OF%" == "%COL%[91mOFF" (
	reg add "HKLM\SYSTEM\ControlSet001\Control\Class\{4D36E968-E325-11CE-BFC1-08002BE10318}\0000" /v "AllowDeepCStates" /t REG_DWORD /d "0" /f
) >nul 2>&1 else (
	reg add "HKLM\SYSTEM\ControlSet001\Control\Class\{4D36E968-E325-11CE-BFC1-08002BE10318}\0000" /v "AllowDeepCStates" /t REG_DWORD /d "1" /f
) >nul 2>&1
call :HoneCtrlRestart "CStates" "%CS0OF%"
Mode 130,45
goto Advanced

:PStates0
if "%PS0OF%" == "%COL%[91mOFF" (
	for /f %%i in ('reg query "HKLM\System\ControlSet001\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /t REG_SZ /s /e /f "NVIDIA" ^| findstr "HKEY"') do (
		reg add "%%i" /v "DisableDynamicPstate" /t REG_DWORD /d "1" /f
	)
) >nul 2>&1 else  (
	for /f %%i in ('reg query "HKLM\System\ControlSet001\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /t REG_SZ /s /e /f "NVIDIA" ^| findstr "HKEY"') do (
		reg delete "%%i" /v "DisableDynamicPstate" /f
	)
) >nul 2>&1
call :HoneCtrlRestart "PStates 0" "%PS0OF%"
Mode 130,45
goto Advanced

:DisableIdle
if "%IDLOF%" == "%COL%[91mOFF" (
powercfg /setacvalueindex scheme_current sub_processor IDLEDISABLE 1
REM	if %battery% == AC (
REM		powercfg /setacvalueindex scheme_current sub_processor IDLEDISABLE 1
REM	) else (
REM		powercfg /setdcvalueindex scheme_current sub_processor IDLEDISABLE 1
REM	)
) else (
powercfg -setacvalueindex scheme_current sub_processor IDLEDISABLE 0
REM	if %battery% == AC (
REM		powercfg -setacvalueindex scheme_current sub_processor IDLEDISABLE 0
REM	) else (
REM		powercfg -setdcvalueindex scheme_current sub_processor IDLEDISABLE 0
REM	)
)
goto Advanced

:Driver
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\DevicePath" /v "NoAutoUpdate" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\DriverSearching" /v "DriverUpdateWizardWuSearchEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "ExcludeWUDriversInQualityUpdate" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AUCustom" /v "TurnOffWindowsUpdateDeviceDriverSearching" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching" /v "SearchOrderConfig" /t REG_DWORD /d 0 /f >nul 2>&1
cls
echo This will uninstall your current graphics driver. The optimized driver will be installed after you reboot.
echo Please be patient and wait until the script finishes.
echo.
echo Would you like to install?
%SYSTEMROOT%\System32\choice.exe /c:YN /n /m "[Y] Yes  [N] No"
if %errorlevel% == 2 goto Advanced
cd "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
curl -LJ https://github.com/auraside/HoneCtrl/blob/main/Files/Driverinstall.bat?raw=true -o Driverinstall.bat 
title Executing DDU...
curl -g -L -# -o "%SYSTEMDRIVE%\Hone\Resources\DDU.zip" "https://github.com/auraside/HoneCtrl/raw/main/Files/DDU.zip"
powershell -NoProfile Expand-Archive '%SYSTEMDRIVE%\Hone\Resources\DDU.zip' -DestinationPath '%SYSTEMDRIVE%\Hone\Resources\DDU\' >nul 2>&1
del "%SYSTEMDRIVE%\Hone\Resources\DDU.zip"
cd %SYSTEMDRIVE%\Hone\Resources\DDU
DDU.exe -silent -cleannvidia
title Restart Confirmation
cls
echo Your PC NEEDS to restart before downloading and installing the driver!
echo.
echo Other Nvidia tweaks will not be available until you restart.
echo.
echo Drivers will be installed upon PC startup.
echo.
:restartchoice
set /p choice=Would you like to continue and restart your PC? Y or N?: 
if /i "%choice%" == "y" (
	shutdown /r /f /d p:0:0
) else if /i "%choice%" == "n" (
	goto Advanced
) else (
	goto restartchoice
)

:BCDEdit
if "%BCDOF%" == "%COL%[91mOFF" (
	reg add "HKCU\Software\Hone" /v BcdEditTweaks /f
	rem tscsyncpolicy
	bcdedit /set tscsyncpolicy enhanced
	rem Quick Boot
	rem if "%dualboot%" == "no" (bcdedit /timeout 3)
	bcdedit /set bootux disabled
	bcdedit /set bootmenupolicy standard
	rem bcdedit /set hypervisorlaunchtype off
	rem bcdedit /set tpmbootentropy ForceDisable
	bcdedit /set quietboot yes
	rem Windows 8 Boot (windows 8.1)
	rem for /f "tokens=4-9 delims=. " %%i in ('ver') do set winversion=%%i.%%j
	rem if "!winversion!" == "6.3.9600" (
	rem 	bcdedit /set {globalsettings} custom:16000067 true
	rem 	bcdedit /set {globalsettings} custom:16000068 true
	rem )
	rem nx
	echo %PROCESSOR_IDENTIFIER% ^| find "Intel" >nul && bcdedit /set nx optout || bcdedit /set nx alwaysoff
	rem Disable some of the kernel memory mitigations
	rem Forcing Intel SGX and setting isolatedcontext to No will cause a black screen
	rem bcdedit /set isolatedcontext No
	bcdedit /set allowedinmemorysettings 0x0
	rem Disable DMA memory protection and cores isolation
	bcdedit /set vsmlaunchtype Off
	bcdedit /set vm No
	reg add "HKLM\Software\Policies\Microsoft\FVE" /v "DisableExternalDMAUnderLock" /t Reg_DWORD /d "0" /f
	reg add "HKLM\Software\Policies\Microsoft\Windows\DeviceGuard" /v "EnableVirtualizationBasedSecurity" /t Reg_DWORD /d "0" /f
	reg add "HKLM\Software\Policies\Microsoft\Windows\DeviceGuard" /v "HVCIMATRequired" /t Reg_DWORD /d "0" /f
	rem Avoid using uncontiguous low-memory. Boosts memory performance & microstuttering.
	rem Can freeze the system on unstable memory OC
	rem bcdedit /set firstmegabytepolicy UseAll
	rem bcdedit /set avoidlowmemory 0x8000000
	rem bcdedit /set nolowmem Yes
	rem Enable X2Apic and enable Memory Mapping for PCI-E devices
	bcdedit /set x2apicpolicy Enable
	bcdedit /set uselegacyapicmode No
	bcdedit /set configaccesspolicy Default
	bcdedit /set usephysicaldestination No
	bcdedit /set usefirmwarepcisettings No 
) >nul 2>&1 else (
	reg delete "HKCU\Software\Hone" /v "BcdEditTweaks" /f
	rem Better Input
	bcdedit /deletevalue tscsyncpolicy
	rem Quick Boot
	rem if "%dualboot%" == "no" (bcdedit /timeout 0)
	bcdedit /deletevalue bootux
	bcdedit /set bootmenupolicy standard
	bcdedit /set hypervisorlaunchtype Auto
	bcdedit /deletevalue tpmbootentropy
	bcdedit /deletevalue quietboot
	rem Windows 8 Boot Stuff (windows 8.1)
	rem for /f "tokens=4-9 delims=. " %%i in ('ver') do set winversion=%%i.%%j
	rem if "!winversion!" == "6.3.9600" (
	rem	bcdedit /set {globalsettings} custom:16000067 false
	rem	bcdedit /set {globalsettings} custom:16000069 false
	rem	bcdedit /set {globalsettings} custom:16000068 false
	rem )
	rem nx
	bcdedit /set nx optin
	rem Disable some of the kernel memory mitigations
	bcdedit /set allowedinmemorysettings 0x17000077
	bcdedit /set isolatedcontext Yes
	rem Disable DMA memory protection and cores isolation
	bcdedit /deletevalue vsmlaunchtype
	bcdedit /deletevalue vm
	reg delete "HKLM\Software\Policies\Microsoft\FVE" /v "DisableExternalDMAUnderLock" /f
	reg delete "HKLM\Software\Policies\Microsoft\Windows\DeviceGuard" /v "EnableVirtualizationBasedSecurity" /f
	reg delete "HKLM\Software\Policies\Microsoft\Windows\DeviceGuard" /v "HVCIMATRequired" /f
	bcdedit /deletevalue firstmegabytepolicy
	bcdedit /deletevalue avoidlowmemory
	bcdedit /deletevalue nolowmem
	bcdedit /deletevalue configaccesspolicy
	bcdedit /deletevalue x2apicpolicy
	bcdedit /deletevalue usephysicaldestination
	bcdedit /deletevalue usefirmwarepcisettings
	bcdedit /deletevalue uselegacyapicmode
) >nul 2>&1
goto Advanced

:DUSBPowerSavings
if "%DPSOF%" == "%COL%[91mOFF" (
	reg add "HKCU\Software\Hone" /v DUSBPowerSavings /f
	for /f "tokens=*" %%i in ('reg query "HKLM\SYSTEM\CurrentControlSet\Enum" /s /f "StorPort" ^| findstr "StorPort"') do reg add "%%i" /v "EnableIdlePowerManagement" /t REG_DWORD /d "0" /f
	for /f "tokens=*" %%i in ('wmic PATH Win32_PnPEntity GET DeviceID ^| findstr "USB\VID_"') do (
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "EnhancedPowerManagementEnabled" /t REG_DWORD /d "0" /f
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "AllowIdleIrpInD3" /t REG_DWORD /d "0" /f
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "EnableSelectiveSuspend" /t REG_DWORD /d "0" /f
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "DeviceSelectiveSuspended" /t REG_DWORD /d "0" /f
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "SelectiveSuspendEnabled" /t REG_DWORD /d "0" /f
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "SelectiveSuspendOn" /t REG_DWORD /d "0" /f
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "D3ColdSupported" /t REG_DWORD /d "0" /f
	)
) >nul 2>&1 else (
	reg delete "HKCU\Software\Hone" /v DUSBPowerSavings /f
	for /f "tokens=*" %%i in ('reg query "HKLM\SYSTEM\CurrentControlSet\Enum" /s /f "StorPort" ^| findstr "StorPort"') do reg delete "%%i" /v "EnableIdlePowerManagement" /f
	for /f "tokens=*" %%i in ('wmic PATH Win32_PnPEntity GET DeviceID ^| findstr "USB\VID_"') do (
	reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "EnhancedPowerManagementEnabled" /f
	reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "AllowIdleIrpInD3" /f
	reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "EnableSelectiveSuspend" /f
	reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "DeviceSelectiveSuspended" /f
	reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "SelectiveSuspendEnabled" /f
	reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "SelectiveSuspendOn" /f
	reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "D3ColdSupported" /f
	)
) >nul 2>&1
goto Advanced

:dog
cls
echo.
echo.
echo.
echo.
echo.
echo.
echo             @@@    @@@@@@@@@@@@@@   @@@
echo         %@@@   @@@@              @@@   @@@@
echo         %@@@   @@@@              @@@   @@@@
echo         %@@@                           @@@@
echo         %@@@                               @@@                     @@@
echo      @@@,      @@@@       @@@                 @@@@              @@@   @@@@
echo      @@@,      @@@@       @@@                 @@@@              @@@   @@@@
echo      @@@,                                         @@@@@@@       @@@   @@@@
echo      @@@,          @@@@@@@                               @@@@@@@@@@   @@@@
echo      @@@,          @@@@@@@                               @@@@@@@@@@   @@@@
echo      @@@,   @@@    @@@       @@@@                                     @@@@
echo      @@@,      @@@@@@@@@@@@@@                                         @@@@
echo      @@@,                                                             @@@@
echo      @@@,                                                             @@@@
echo      @@@,                                                             @@@@
echo      @@@,                                                             @@@@
echo      @@@,                                                             @@@@
echo      @@@,                                                             @@@@
echo      @@@,                                                          @@@
echo         %@@@                                                       @@@
echo         %@@@                                                       @@@
echo         %@@@       @@@@@@@       @@@@@@@@@@@@@       @@@@@@@       @@@
echo         %@@@       @@@@@@@       @@@       @@@       @@@@@@@       @@@
echo         %@@@   @@@@   @@@@   @@@@          @@@    @@@    @@@    @@@
echo         %@@@   @@@@   @@@@   @@@@          @@@    @@@    @@@    @@@
echo             @@@           @@@                 @@@@          @@@@
echo					      hi
echo.
echo.
echo                  		  X to close
echo.
%SYSTEMROOT%\System32\choice.exe /c:XD /n /m "%DEL% ..."
set choice=%errorlevel%
if "%choice%"=="1" exit /b
if "%choice%"=="2" goto Dog2
goto dog

:dog2
cls
echo So you want more dog?
timeout /t 3 >nul 2>&1
cls
echo I don't have more dogs for you sorry
timeout /t 3 >nul 2>&1
cls
echo Maybe come back at another time? I'll get some for ya
timeout /t 3 >nul 2>&1
cls
echo bye
timeout /t 2  >nul 2>&1
exit /b

:More
cls
echo.
echo.
echo.
echo.
echo                                                                            %COL%[33m.
echo                                                                           +N.
echo                                                                //        oMMs
echo                                                               +Nm`    ``yMMm-
echo                                                            ``dMMsoyhh-hMMd.
echo                                                            `yy/MMMMNh:dMMh`
echo                                                           .hMM.sso++:oMMs`
echo                                                          -mMMy:osyyys.No
echo                                                         :NMMs-oo+/syy:-
echo                                                        /NMN+ ``   :ys.
echo                                                       `NMN:        +.
echo                                                       om-
echo                                                        `.
echo.
echo.
echo.
echo                  %COL%[33m[ %COL%[37m1 %COL%[33m] %COL%[37mAbout                                                   %COL%[33m[ %COL%[37m2 %COL%[33m] %COL%[37mDisclaimer
echo.
echo.
echo                  %COL%[33m[ %COL%[37m3 %COL%[33m] %COL%[37mBackup                                                  %COL%[33m[ %COL%[37m4 %COL%[33m] %COL%[37mDiscord
echo                  %COL%[90mBackup your current registry ^& create a
echo                  %COL%[90mrestore point used to revert tweaks applied.
echo.
echo.
echo                  %COL%[33m[ %COL%[37m5 %COL%[33m] %COL%[37mCredits
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                                 %COL%[90m[ B for back ]         %COL%[31m[ X to close ]%COL%[37m
echo.
%SYSTEMROOT%\System32\choice.exe /c:12345BX /n /m "%DEL%                                        Select a corresponding number to the options above >"
set choice=%errorlevel%
if "%choice%"=="1" goto About
if "%choice%"=="2" goto ViewDisclaimer
if "%choice%"=="3" call:Backup
if "%choice%"=="4" goto Discord
if "%choice%"=="5" goto Credits
if /i "%choice%"=="6" goto MainMenu
if /i "%choice%"=="7" exit /b
goto More

:About
cls
echo About
echo Owned by AuraSide, Inc. Copyright Claimed.
echo This is a GUI for the Hone Manual Tweaks.
echo.
call :ColorText 8 "                                                      [ press X to go back ]"
echo.
echo.
echo.
%SYSTEMROOT%\System32\choice.exe /c:X /n /m "%DEL%                                                               >:"
set choice=%errorlevel%
if "%choice%"=="1" goto More

:ViewDisclaimer
cls
echo.
echo.
call :HoneTitle
echo.
echo                                        %COL%[90m HoneCtrl is a free and open-source desktop utility
echo                                        %COL%[90m    made to improve your day-to-day productivity
echo.
echo.
echo.
echo %COL%[91m  WARNING:
echo %COL%[37m  Please note that we cannot guarantee an FPS boost from applying our optimizations, every system + configuration is different.
echo.
echo     %COL%[33m1.%COL%[37m Everything is "use at your own risk", we are %COL%[91mNOT LIABLE%COL%[37m if you damage your system in any way
echo        (ex. not following the disclaimers carefully).
echo.
echo     %COL%[33m2.%COL%[37m If you don't know what a tweak is, do not use it and contact our support team to receive more assistance.
echo.
echo     %COL%[33m3.%COL%[37m Even though we have an automatic restore point feature, we highly recommend making a manual restore point before running.
echo.
echo   For any questions and/or concerns, please join our discord: discord.gg/hone
echo.
echo   Please enter "I agree" without quotes to continue:
echo.
echo.
echo.
echo                                                         [ press X to go back ]
echo.
%SYSTEMROOT%\System32\choice.exe /c:X /n /m "%DEL%                                                                 >:"
set choice=%errorlevel%
if "%choice%"=="1" goto More

:Credits
cls
echo.
echo.
echo.
echo %COL%[90m                                                         Product Lead
echo %COL%[97m                                                       Ryan A. - Ryan
echo.
echo.
echo.
echo %COL%[90m                                                   Product Development Lead
echo %COL%[97m                                                  Christina A. - UnLovedCookie
echo.
echo.
echo.
echo %COL%[90m                                                      Product Development
echo %COL%[97m                                                   Jonathan H. - Jonathan
echo %COL%[97m                                                     Dexter K. - Drevoes
echo %COL%[97m                                                     Arthur C. - Yaamruo
echo %COL%[97m                                                    Valeria D. - Melody
echo.
echo.
echo.
echo %COL%[90m                                                     Network Optimizations
echo %COL%[97m                                                      Krzysiek - VVASD
echo %COL%[97m                                                      Filip G. - Curtal
echo.
echo.
echo.
echo %COL%[90m                                                        Render Settings
echo %COL%[97m                                                       Eesa H. - mmunk
echo.
echo.
echo.
echo %COL%[90m                                                          Credits to
echo %COL%[97m                                                       mbk1969 - (Timer Resolution)
echo %COL%[97m                                                       W1zzard - (Nvcleanstall)
echo %COL%[97m                                                       M2-Team - (Nsudo)
echo %COL%[97m                                                       ToastyX - (Restart64)
echo %COL%[97m                                                          wj32 - (Purgestandby)
echo %COL%[97m                                                     mini)(ant - (REAL)
echo %COL%[97m                                                          nssm - (Iain Patterson)
echo.
echo.
echo.
call :ColorText 8 "                                                     [ press B to go back ]"
echo.
%SYSTEMROOT%\System32\choice.exe /c:B /n /m "%DEL%                                                               >:"
set choice=%errorlevel%
if "%choice%"=="1" goto More

:Backup
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\SystemRestore" /v "SystemRestorePointCreationFrequency" /t REG_DWORD /d 0 /f >nul 2>&1
powershell Enable-ComputerRestore -Drive 'C:\', 'D:\', 'E:\', 'F:\', 'G:\' >nul 2>&1
powershell Checkpoint-Computer -Description 'Hone Restore Point' >nul 2>&1
for /F "tokens=2" %%i in ('date /t') do set date=%%i  >nul 2>&1
set date1=%date:/=.%  >nul 2>&1
md %SYSTEMDRIVE%\Hone\HoneRevert\%date1%  >nul 2>&1
reg export HKCU %SYSTEMDRIVE%\Hone\HoneRevert\%date1%\HKLM.reg /y & reg export HKCU %SYSTEMDRIVE%\Hone\HoneRevert\%date1%\HKCU.reg /y >nul 2>&1
cls
goto :eof

:Discord
start http://discord.gg/hone
goto More

echo       :::    :::     ::::::::     ::::    :::    ::::::::::
echo      :+:    :+:    :+:    :+:    :+:+:   :+:    :+:
echo     +:+    +:+    +:+    +:+    :+:+:+  +:+    +:+                 +::+:+::      +::+:+::
echo    +#++:++#++    +#+    +:+    +#+ +:+ +#+    +#++:++#           ++:    #++    ++:    #++
echo   +#+    +#+    +#+    +#+    +#+  +#+#+#    +#+                +#+    +#+    +#+    +#+
echo  #+#    #+#    #+#    #+#    #+#   #+#+#    #+#          #+#   #+#    #+#    #+#    #+#
echo ###    ###     ########     ###    ####    ##########   ###     ########      ########
echo                                                                     ###           ###
echo                                                             ##     ###    ##     ###
echo                                                              ########      ########

echo                                           %COL%[33m+N.
echo                                //        oMMs
echo                               +Nm`    ``yMMm-      ::::::::     ::::    :::    ::::::::::
echo                            ``dMMsoyhh-hMMd.      :+:    :+:    :+:+:   :+:    :+:
echo                            `yy/MMMMNh:dMMh`     +:+    +:+    :+:+:+  +:+    +:+                 +::+:+::      +::+:+::
echo                           .hMM.sso++:oMMs`     +#+    +:+    +#+ +:+ +#+    +#++:++#           ++:    #++    ++:    #++
echo                          -mMMy:osyyys.No      +#+    +#+    +#+  +#+#+#    +#+                +#+    +#+    +#+    +#+
echo                         :NMMs-oo+/syy:-      #+#    #+#    #+#   #+#+#    #+#          #+#   #+#    #+#    #+#    #+#
echo                        /NMN+ ``   :ys.       ########     ###    ####    ##########   ###     ########      ########
echo                       `NMN:        +.                                                             ###           ###
echo                       om-                                                                 ##     ###    ##     ###
echo                        `.                                                                  ########      ########

echo                                           %COL%[33m+N.
echo                                //        oMMs
echo                               +Nm`    ``yMMm-               :::    :::     ::::::::     ::::    :::    ::::::::::
echo                            ``dMMsoyhh-hMMd.                :+:    :+:    :+:    :+:    :+:+:   :+:    :+:
echo                            `yy/MMMMNh:dMMh`               +:+    +:+    +:+    +:+    :+:+:+  +:+    +:+
echo                           .hMM.sso++:oMMs`               +#++:++#++    +#+    +:+    +#+ +:+ +#+    +#++:++#
echo                          -mMMy:osyyys.No                +#+    +#+    +#+    +#+    +#+  +#+#+#    +#+
echo                         :NMMs-oo+/syy:-                #+#    #+#    #+#    #+#    #+#   #+#+#    #+#
echo                        /NMN+ ``   :ys.                ###    ###     ########     ###    ####    ##########
echo                       `NMN:        +.
echo                       om-
echo                        `.

:ColorText
echo off
<nul set /p ".=%DEL%" > "%~2"
findstr /v /a:%1 /R "^$" "%~2" nul
del "%~2" > nul
goto :eof

:HoneCtrlError
cls
color 06
echo.
echo  --------------------------------------------------------------
echo                   This tweak is not applicable
echo  --------------------------------------------------------------
echo.
echo      You aren't able to use this optimization
echo.
echo      %~1
echo.
echo.
echo.
echo.
echo      [X] Close
echo.
%SYSTEMROOT%\System32\choice.exe /c:X /n /m "%DEL%                                >:"
goto :eof





:HoneCtrlRestart
setlocal DisableDelayedExpansion
if "%~2" == "%COL%[91mOFF" (set "ed=enable") else (set "ed=disable")
start "Restart" cmd /V:ON /C @echo off
Mode 65,16
color 06
echo.
echo  --------------------------------------------------------------
echo                       Restart to fully apply
echo  --------------------------------------------------------------
echo.
echo      To %ed% %~1 you must restart, would
echo      you like to restart now?
echo.
echo.
echo.
echo.
echo      [Y] Yes
echo      [N] No
echo.
:restartchoice
set /p choice=Would you like to continue and restart your PC? Y or N?: 
if /i "%choice%" == "y" (
	shutdown /r /f /d p:0:0
) else if /i "%choice%" == "n" (
	exit /b
) else (
	goto restartchoice
)

:Aesthetics
cls
echo.
echo.
call :HoneTitle
echo.
echo              %COL%[33m[%COL%[37m 1 %COL%[33m]%COL%[37m AUTO                 %COL%[33m[%COL%[37m 2 %COL%[33m]%COL%[37m MANUAL      %COL%[33m[%COL%[37m 3 %COL%[33m]%COL%[37m RESET
echo              %COL%[90mApply all recommended         %COL%[90mCustomize your experience      %COL%[90mReset all Aesthetics
echo              %COL%[90msettings automatically        %COL%[90mto your liking             %COL%[90mSettings to original
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                                 %COL%[90m[ B for back ]         %COL%[31m[ X to close ]
echo.
set /p choice="%DEL%                                        %COL%[37mSelect a corresponding number to the options above > "
if /i "%choice%"=="1" goto Auto
if /i "%choice%"=="2" goto Manual
if /i "%choice%"=="3" goto Reset
if /i "%choice%"=="B" goto MainMenu
if /i "%choice%"=="X" exit /b
goto Aesthetics

:Auto
cls
echo.
call :HoneTitle
echo                                                               %COL%[1;4;34mAesthetics Manual%COL%[0m
echo.
echo              %COL%[33m[%COL%[37m 1 %COL%[33m]%COL%[37m Auto Transparency
echo              %COL%[90mApply recommended
echo              %COL%[90mtransparency settings
echo.
echo.
echo.
echo.
echo                                                 %COL%[90m[ B for back ]         %COL%[31m[ X to close ]
echo.
set /p choice="%DEL%                                        %COL%[37mSelect a corresponding number to the options above > "
if /i "%choice%"=="1" goto TransparencyAuto
if /i "%choice%"=="X" exit /b
if /i "%choice%"=="B" goto Aesthetics
goto Auto

:TransparencyAuto
if exist "%USERPROFILE%\Documents\systemtransparency.ini" del /Q "%USERPROFILE%\Documents\systemtransparency.ini" >nul 2>&1
if exist "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\Clear.exe" ( goto TransparencyAuto1 ) else ( goto TransparencyAuto11 ) >nul 2>&1
:TransparencyAuto11
cd "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
curl -g -LJ -# "https://github.com/auraside/HoneCtrl/raw/main/Files/Aesthetics/Clear.exe" -o "Clear.exe"
:TransparencyAuto1
cd %USERPROFILE%\documents
(
	echo [Settings]
	echo trans=230
	echo rclick=1
	echo tbar=1
	echo smenu=1
	echo tool=1
	echo explorer=1
	echo notes=0
	echo desktop=0
	echo wmp=0
	echo thumbs=0
	echo op=
	echo firefox=0
	echo chrome=0
	echo ie=0
	echo deskbutton=0
	echo mouseclock=0
	echo alttabber=0
) > systemtransparency.ini
cd "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
start Clear.exe
taskkill /f /im explorer.exe
cd %SYSTEMROOT%
start explorer.exe
cls
echo.
echo.
echo.
echo.
echo                                                                            %COL%[33m.
echo                                                                         +N.
echo                                                                //        oMMs
echo                                                               +Nm`    ``yMMm-
echo                                                            ``dMMsoyhh-hMMd.
echo                                                            `yy/MMMMNh:dMMh`
echo                                                           .hMM.sso++:oMMs`
echo                                                          -mMMy:osyyys.No
echo                                                         :NMMs-oo+/syy:-
echo                                                        /NMN+ ``   :ys.
echo                                                       `NMN:        +.
echo                                                       om-
echo                                                        `.
echo.
echo.
echo.
echo.
echo.
echo                                                   %COL%[37m Settings have been applied
echo.
echo.
echo.
echo.
echo                                                          %COL%[90m[ B for back ]%COL%[37m
echo.
%SYSTEMROOT%\System32\choice.exe /c:B /n /m "%DEL%                                                               >:"
goto Auto

:Manual
cls
echo.
call :HoneTitle
echo                                                               %COL%[1;4;34mAesthetics Manual%COL%[0m
echo.
echo              %COL%[33m[%COL%[37m 1 %COL%[33m]%COL%[37m Transparency
echo              %COL%[90mCustomize what you want
echo              %COL%[90mto be transparent
echo.
echo.
echo.
echo.
echo                                                 %COL%[90m[ B for back ]         %COL%[31m[ X to close ]
echo.
set /p choice="%DEL%                                        %COL%[37mSelect a corresponding number to the options above > "
if /i "%choice%"=="1" goto TransparencySetup
if /i "%choice%"=="X" exit /b
if /i "%choice%"=="B" goto Aesthetics
goto Manual

:TransparencySetup
if exist "%USERPROFILE%\Documents\systemtransparency.ini" del /Q "%USERPROFILE%\Documents\systemtransparency.ini" >nul 2>&1
if exist "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\Clear.exe" ( goto TransparencySetup1 ) else ( goto TransparencySetup11 ) >nul 2>&1
:TransparencySetup11
cd "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
curl -g -LJ -# "https://github.com/auraside/HoneCtrl/raw/main/Files/Aesthetics/Clear.exe" -o "Clear.exe"
:TransparencySetup1
cls
echo.
call :HoneTitle
echo.
echo Please select a transparency level, we recommend 200 or above (Lower = more transparent)
echo.
echo.
echo %COL%[36m[ 100 ]         %COL%[36m[ 150 ]         %COL%[36m[ 200 ]         %COL%[36m[ 220 ]
echo 	%COL%[36m[ 230 ]         %COL%[36m[ 240 ]         %COL%[36m[ 250 ]   
echo. 
echo 		     %COL%[90m[ B for back ]
set /p choice="%DEL% "
if /i "%choice%"=="100" set trans=100 & goto TransparencySetup2
if /i "%choice%"=="150" set trans=150 & goto TransparencySetup2
if /i "%choice%"=="200" set trans=200 & goto TransparencySetup2
if /i "%choice%"=="220" set trans=220 & goto TransparencySetup2
if /i "%choice%"=="230" set trans=230 & goto TransparencySetup2
if /i "%choice%"=="240" set trans=240 & goto TransparencySetup2
if /i "%choice%"=="250" set trans=250 & goto TransparencySetup2
if /i "%choice%"=="B" goto Aesthetics
goto TransparencySetup1

:TransparencySetup2
cls
echo.
call :HoneTitle
echo.
echo Do you want the right click menu to be transparent?
echo.
echo.
echo %COL%[36m[ Y ]         %COL%[36m[ N ]         %COL%[90m[ B for back ]
set "choice="
%SYSTEMROOT%\System32\choice.exe /c:ynb /n /m "%DEL% > "
set choice=%errorlevel%
if "%choice%"=="1" set rclick=1 & goto TransparencySetup3
if "%choice%"=="2" set rclick=0 & goto TransparencySetup3
if /i "%choice%"=="3" goto Aesthetics
goto TransparencySetup2


:TransparencySetup3
cls
echo.
call :HoneTitle
echo.
echo Do you want the Taskbar to be transparent?
echo.
echo.
echo %COL%[36m[ Y ]         %COL%[36m[ N ]         %COL%[90m[ B for back ]
set "choice="
%SYSTEMROOT%\System32\choice.exe /c:ynb /n /m "%DEL% > "
set choice=%errorlevel%
if "%choice%"=="1" set tbar=1 & goto TransparencySetup4
if "%choice%"=="2" set tbar=0 & goto TransparencySetup4
if /i "%choice%"=="3" goto Aesthetics
goto TransparencySetup3

:TransparencySetup4
cls
echo.
call :HoneTitle
echo.
echo Do you want the Start Menu to be transparent?
echo.
echo.
echo %COL%[36m[ Y ]         %COL%[36m[ N ]         %COL%[90m[ B for back ]
set "choice="
%SYSTEMROOT%\System32\choice.exe /c:ynb /n /m "%DEL% > "
set choice=%errorlevel%
if "%choice%"=="1" set smenu=1 & goto TransparencySetup5
if "%choice%"=="2" set smenu=0 & goto TransparencySetup5
if /i "%choice%"=="3" goto Aesthetics
goto TransparencySetup4

:TransparencySetup5
cls
echo.
call :HoneTitle
echo.
echo Do you want Explorer to be transparent?
echo.
echo.
echo %COL%[36m[ Y ]         %COL%[36m[ N ]         %COL%[90m[ B for back ]
set "choice="
%SYSTEMROOT%\System32\choice.exe /c:ynb /n /m "%DEL% > "
set choice=%errorlevel%
if "%choice%"=="1" set explorer=1 & goto TransparencySetup6
if "%choice%"=="2" set explorer=0 & goto TransparencySetup6
if /i "%choice%"=="3" goto Aesthetics
goto TransparencySetup5

:TransparencySetup6
cls
echo.
call :HoneTitle
echo.
echo Do you want Firefox to be transparent?
echo.
echo.
echo %COL%[36m[ Y ]         %COL%[36m[ N ]         %COL%[90m[ B for back ]
set "choice="
%SYSTEMROOT%\System32\choice.exe /c:ynb /n /m "%DEL% > "
set choice=%errorlevel%
if "%choice%"=="1" set firefox=1 & goto TransparencySetup7
if "%choice%"=="2" set firefox=0 & goto TransparencySetup7
if /i "%choice%"=="3" goto Aesthetics
goto TransparencySetup6

:TransparencySetup7
cls
echo.
call :HoneTitle
echo.
echo Do you want Google Chrome to be transparent?
echo.
echo.
echo %COL%[36m[ Y ]         %COL%[36m[ N ]         %COL%[90m[ B for back ]
set "choice="
%SYSTEMROOT%\System32\choice.exe /c:ynb /n /m "%DEL% > "
set choice=%errorlevel%
if "%choice%"=="1" set chrome=1 & goto TransparencySetup8
if "%choice%"=="2" set chrome=0 & goto TransparencySetup8
if /i "%choice%"=="3" goto Aesthetics
goto TransparencySetup7

:TransparencySetup8
cd %USERPROFILE%\documents
(
	echo [Settings]
	echo trans=%trans%
	echo rclick=%rclick%
	echo tbar=%tbar%
	echo smenu=%smenu%
	echo tool=%rclick%
	echo explorer=%explorer%
	echo notes=0
	echo desktop=0
	echo wmp=0
	echo thumbs=0
	echo op=
	echo firefox=%firefox%
	echo chrome=%chrome%
	echo ie=0
	echo deskbutton=0
	echo mouseclock=0
	echo alttabber=0
) > systemtransparency.ini
cd "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
start Clear.exe
taskkill /f /im explorer.exe
cd %SYSTEMROOT%
start explorer.exe
cls
echo.
echo.
echo.
echo.
echo                                                                            %COL%[33m.
echo                                                                         +N.
echo                                                                //        oMMs
echo                                                               +Nm`    ``yMMm-
echo                                                            ``dMMsoyhh-hMMd.
echo                                                            `yy/MMMMNh:dMMh`
echo                                                           .hMM.sso++:oMMs`
echo                                                          -mMMy:osyyys.No
echo                                                         :NMMs-oo+/syy:-
echo                                                        /NMN+ ``   :ys.
echo                                                       `NMN:        +.
echo                                                       om-
echo                                                        `.
echo.
echo.
echo.
echo.
echo.
echo                                                   %COL%[37m Settings have been applied
echo.
echo.
echo.
echo.
echo                                                          %COL%[90m[ B for back ]%COL%[37m
echo.
%SYSTEMROOT%\System32\choice.exe /c:B /n /m "%DEL%                                                               >:"
goto Manual

:Reset
if exist "%USERPROFILE%\Documents\systemtransparency.ini" del /Q "%USERPROFILE%\Documents\systemtransparency.ini" >nul 2>&1
if exist "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\Clear.exe" ( goto Reset1 ) else ( goto Reset2 ) >nul 2>&1
:Reset1
cd "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
taskkill /IM Clear.exe /F >nul 2>&1
Del /Q Clear.exe >nul 2>&1
:Reset2
taskkill /f /im explorer.exe >nul 2>&1
cd %SYSTEMROOT% >nul 2>&1
start explorer.exe >nul 2>&1
goto Aesthetics

goto :eof
