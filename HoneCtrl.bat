::    Copyright (C) 2022 Auraside
::
::    This program is free software: you can redistribute it and/or modify
::    it under the terms of the GNU Affero General Public License as published
::    by the Free Software Foundation, either version 3 of the License, or
::    (at your option) any later version.
::
::    This program is distributed in the hope that it will be useful,
::    but WITHOUT ANY WARRANTY; without even the implied warranty of
::    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
::    GNU Affero General Public License for more details.
::
::    You should have received a copy of the GNU Affero General Public License
::    along with this program.  If not, see <https://www.gnu.org/licenses/>.

@echo off
title Preparing...
color 06
Mode 130,45
setlocal EnableDelayedExpansion

::Make Directories
mkdir C:\Hone >nul 2>&1
mkdir C:\Hone\Resources >nul 2>&1
mkdir C:\Hone\HoneRevert >nul 2>&1
mkdir C:\Hone\Drivers >nul 2>&1
cd C:\Hone

::Run as Admin
Reg.exe add HKLM /F >nul 2>&1
if %errorlevel% neq 0 start "" /wait /I /min powershell -NoProfile -Command start -verb runas "'%~s0'" && exit /b

::Show Detailed BSoD 
Reg add "HKLM\System\CurrentControlSet\Control\CrashControl" /v "DisplayParameters" /t REG_DWORD /d "1" /f >nul 2>&1

::Blank/Color Character
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (set "DEL=%%a" & set "COL=%%b")

:Disclaimer
Reg query "HKCU\Software\Hone" /v "Disclaimer" >nul 2>&1 && goto CheckForUpdates
cls
echo.
echo.
echo.                                      %COL%[33m+N.
echo.                           //        oMMs         
echo.                          +Nm`    ``yMMm-     ::::::::     ::::    :::    :::::::::: 
echo.                       ``dMMsoyhh-hMMd.     :+:    :+:    :+:+:   :+:    :+:  
echo.                       `yy/MMMMNh:dMMh`    +:+    +:+    :+:+:+  +:+    +:+                 +::+:+::      +::+:+::
echo.                      .hMM.sso++:oMMs`    +#+    +:+    +#+ +:+ +#+    +#++:++#           ++:    #++    ++:    #++
echo.                     -mMMy:osyyys.No     +#+    +#+    +#+  +#+#+#    +#+                +#+    +#+    +#+    +#+
echo.                    :NMMs-oo+/syy:-     #+#    #+#    #+#   #+#+#    #+#          %COL%[37m#+#%COL%[33m    +#+   #+#     #+#   #+#
echo.                   /NMN+ ``   :ys.      ########     ###    ####    ##########   %COL%[37m###%COL%[33m       ######        ######
echo.                  `NMN:        +.                                                      ##    ###     ##    ###
echo.                  om-                                                                   #######       #######
echo.                   `.
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
Reg add "HKCU\Software\Hone" /v "Disclaimer" /f >nul 2>&1

::Restart Checks
if exist "%userprofile%\Desktop\NvidiaHone.exe" %userprofile%\Desktop\NvidiaHone.exe >nul 2>&1
if exist "%userprofile%\Desktop\NvidiaHone.exe" del /Q "%userprofile%\Desktop\NvidiaHone.exe" >nul 2>&1
if "%~f0" equ "%appdata%\Microsoft\Windows\Start Menu\Programs\Startup\HoneCtrl.bat" (
del /Q "C:\Users\%username%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\HoneCtrl.bat" >nul 2>&1
)

:CheckForUpdates
set local=2.5
set localtwo=%local%
if exist "%temp%\Updater.bat" DEL /S /Q /F "%temp%\Updater.bat" >nul 2>&1
curl -g -L -# -o "%temp%\Updater.bat" "https://raw.githubusercontent.com/auraside/HoneCtrl/main/Files/HoneCtrlVer" >nul 2>&1
call "%temp%\Updater.bat"
IF "%local%" gtr "%localtwo%" (
	cls
	Mode 65,16
	echo.
	echo  --------------------------------------------------------------
	echo                           Update found
	echo  --------------------------------------------------------------
	echo.
	echo                    Your current version: %localtwo%
	echo.
	echo                          New version: %local%
	echo.
	echo.
	echo.
	echo      [Y] Yes, Update
	echo      [N] No
	echo.
	choice /c:YN /n /m "%DEL%                                >:"
	set choice=!errorlevel!
	if !choice! equ 1 (
		curl -L -o "C:\Users\%username%\Documents\HoneCtrl.bat" "https://github.com/auraside/HoneCtrl/releases/latest/download/HoneCtrl.Bat"
		start "HoneCtrl" "C:\Users\%username%\Documents\HoneCtrl.bat"
		del %0
		exit /b
	)
	Mode 130,45
)

::Check If First Launch
set firstlaunch=1
>nul 2>&1 call "C:\Hone\HoneRevert\firstlaunch.bat"
if "%firstlaunch%" equ "0" (goto MainMenu)

::Restore Point
powershell -ExecutionPolicy Unrestricted -NoProfile Enable-ComputerRestore -Drive 'C:\', 'D:\', 'E:\', 'F:\', 'G:\' >nul 2>&1
powershell -ExecutionPolicy Unrestricted -NoProfile Checkpoint-Computer -Description 'Hone Restore Point' >nul 2>&1

::HKCU & HKLM backup
for /F "tokens=2" %%i in ('date /t') do set date=%%i
set date1=%date:/=.%
>nul 2>&1 md C:\Hone\HoneRevert\%date1%
reg export HKCU C:\Hone\HoneRevert\%date1%\HKLM.reg /y >nul 2>&1
reg export HKCU C:\Hone\HoneRevert\%date1%\HKCU.reg /y >nul 2>&1
echo set "firstlaunch=0" > C:\Hone\HoneRevert\firstlaunch.bat

:MainMenu
Mode 130,45
TITLE Hone Control Panel %localtwo%
set "choice="
cls
echo.
echo.
echo.                                      %COL%[33m+N.
echo.                           //        oMMs         
echo.                          +Nm`    ``yMMm-     ::::::::     ::::    :::    :::::::::: 
echo.                       ``dMMsoyhh-hMMd.     :+:    :+:    :+:+:   :+:    :+:  
echo.                       `yy/MMMMNh:dMMh`    +:+    +:+    :+:+:+  +:+    +:+                 +::+:+::      +::+:+::
echo.                      .hMM.sso++:oMMs`    +#+    +:+    +#+ +:+ +#+    +#++:++#           ++:    #++    ++:    #++
echo.                     -mMMy:osyyys.No     +#+    +#+    +#+  +#+#+#    +#+                +#+    +#+    +#+    +#+
echo.                    :NMMs-oo+/syy:-     #+#    #+#    #+#   #+#+#    #+#          %COL%[37m#+#%COL%[33m    +#+   #+#     #+#   #+#
echo.                   /NMN+ ``   :ys.      ########     ###    ####    ##########   %COL%[37m###%COL%[33m       ######        ######
echo.                  `NMN:        +.                                                      ##    ###     ##    ###
echo.                  om-                                                                   #######       #######
echo.                   `.
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
choice /c:1234567X /n /m "%DEL%                                        Select a corresponding number to the options above > "
set choice=%errorlevel%
if "%choice%"=="1" set PG=TweaksPG1 & goto Tweaks
if "%choice%"=="2" goto GameSettings
if "%choice%"=="3" goto HoneRenders
if "%choice%"=="4" call:Comingsoon
if "%choice%"=="5" call:Comingsoon
if "%choice%"=="6" goto disclaimer2
if "%choice%"=="7" goto More
if "%choice%"=="8" exit /b
if "%choice%"=="9" goto Disclaimer2
goto MainMenu

:Comingsoon
cls
echo.
echo.
echo.                                      %COL%[33m+N.
echo.                           //        oMMs         
echo.                          +Nm`    ``yMMm-     ::::::::     ::::    :::    :::::::::: 
echo.                       ``dMMsoyhh-hMMd.     :+:    :+:    :+:+:   :+:    :+:  
echo.                       `yy/MMMMNh:dMMh`    +:+    +:+    :+:+:+  +:+    +:+                 +::+:+::      +::+:+::
echo.                      .hMM.sso++:oMMs`    +#+    +:+    +#+ +:+ +#+    +#++:++#           ++:    #++    ++:    #++
echo.                     -mMMy:osyyys.No     +#+    +#+    +#+  +#+#+#    +#+                +#+    +#+    +#+    +#+
echo.                    :NMMs-oo+/syy:-     #+#    #+#    #+#   #+#+#    #+#          %COL%[37m#+#%COL%[33m    +#+   #+#     #+#   #+#
echo.                   /NMN+ ``   :ys.      ########     ###    ####    ##########   %COL%[37m###%COL%[33m       ######        ######
echo.                  `NMN:        +.                                                      ##    ###     ##    ###
echo.                  om-                                                                   #######       #######
echo.                   `.
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
goto:eof

:Tweaks
Mode 130,45
TITLE Hone Control Panel %localtwo%
set "choice="
set "BLANK=   "
::Check Values
for %%i in (PWROF MEMOF TMROF NETOF AFFOF MOUOF AFTOF NICOF DSSOF SERVOF DEBOF MITOF ME2OF NPIOF NVIOF NVTOF HDCOF CMAOF ALLOF MSIOF TCPOF DWCOF CRSOF) do (set "%%i=%COL%[92mON ") >nul 2>&1
(
	::MSI Mode
	for /f %%g in ('wmic path win32_VideoController get PNPDeviceID ^| findstr /L "VEN_"') do (
	Reg query "HKLM\SYSTEM\CurrentControlSet\Enum\%%g\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" | find "0x1" || set "MSIOF=%COL%[91mOFF"
	Reg query "HKLM\System\CurrentControlSet\Enum\%%g\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" && set "MSIOF=%COL%[91mOFF"
	)
	for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID ^| findstr /L "VEN_"') do (
	Reg query "HKLM\SYSTEM\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" | find "0x1" || set "MSIOF=%COL%[91mOFF"
	Reg query "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" && set "MSIOF=%COL%[91mOFF"
	)
	::Services Optimization
	for /f "tokens=2 delims==" %%i in ('wmic os get TotalVisibleMemorySize /value') do (set /a mem=%%i + 1024000)
	for /f "tokens=3" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control" /v "SvcHostSplitThresholdInKB"') do (set /a currentmem=%%a)
	if "!currentmem!" neq "!mem!" set "MEMOF=%COL%[91mOFF"
	::Nvidia Telemetry
	Reg query "HKCU\Software\Hone" /v "NVTTweaks" || set "NVTOF=%COL%[91mOFF"
	::Nvidia HDCP
	for /f %%a in ('Reg query "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /t REG_SZ /s /e /f "NVIDIA" ^| findstr "HKEY"') do Reg query "%%a" /v "RMHdcpKeyglobZero" | find "0x1" || set "HDCOF=%COL%[91mOFF"
	::Disable Preemption
	Reg query "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisablePreemption" | find "0x1" || set "CMAOF=%COL%[91mOFF"
	Reg query "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisableCudaContextPreemption" | find "0x1" || set "CMAOF=%COL%[91mOFF"
	Reg query "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "EnableCEPreemption" | find "0x0" || set "CMAOF=%COL%[91mOFF"
	Reg query "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisablePreemptionOnS3S4" | find "0x1" || set "CMAOF=%COL%[91mOFF"
	Reg query "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "ComputePreemption" | find "0x0" || set "CMAOF=%COL%[91mOFF"
	::CSRSS
	Reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\csrss.exe\PerfOptions" /v CpuPriorityClass | find "0x4" || set "CRSOF=%COL%[91mOFF"
	Reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\csrss.exe\PerfOptions" /v IoPriority | find "0x3" || set "CRSOF=%COL%[91mOFF"
	::Power Plan
	powercfg /GetActiveScheme | find "Hone" || set "PWROF=%COL%[91mOFF"
	::All GPU Tweaks
	Reg query "HKCU\Software\Hone" /v "AllGPUTweaks" || set "ALLOF=%COL%[91mOFF"
	::Profile Inspector Tweaks
	Reg query "HKCU\Software\Hone" /v "NpiTweaks" || set "NPIOF=%COL%[91mOFF"
	::TCPIP
	Reg query "HKCU\Software\Hone" /v "TCPIP" || set "TCPOF=%COL%[91mOFF"
	::Nvidia Tweaks
	Reg query "HKCU\Software\Hone" /v "NvidiaTweaks" || set "NVIOF=%COL%[91mOFF"
	::Memory Optimization
	Reg query "HKCU\Software\Hone" /v "MemoryTweaks" || set "ME2OF=%COL%[91mOFF"
	::Network Internet Tweaks
	Reg query "HKCU\Software\Hone" /v "InternetTweaks" || set "NETOF=%COL%[91mOFF"
	::Services Tweaks
	Reg query "HKCU\Software\Hone" /v "ServicesTweaks" || set "SERVOF=%COL%[91mOFF"
	::Debloat Tweaks
	Reg query "HKCU\Software\Hone" /v "DebloatTweaks" || set "DEBOF=%COL%[91mOFF"
	::Mitigations Tweaks
	Reg query "HKCU\Software\Hone" /v "MitigationsTweaks" || set "MITOF=%COL%[91mOFF"
	::Affinities
	Reg query "HKCU\Software\Hone" /v "AffinityTweaks" || set "AFFOF=%COL%[91mOFF"
	::DisableWriteCombining
	Reg query "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisableWriteCombining" || set "DWCOF=%COL%[91mOFF"
	::Mouse Fix
	Reg query "HKCU\Control Panel\Mouse" /v "SmoothMouseYCurve" | find "0000000000000000000038000000000000007000000000000000A800000000000000E00000000000" || set "MOUOF=%COL%[91mOFF"
	::NIC
	if not exist "%SystemDrive%\Hone\HoneRevert\ognic.reg" set "NICOF=%COL%[91mOFF"
	::Intel iGPU
	Reg query "HKLM\SOFTWARE\Intel\GMM" /v "DedicatedSegmentSize" | find "0x400" || set "DSSOF=%COL%[91mOFF"
	::Timer Res
	sc query STR | find "RUNNING" || set "TMROF=%COL%[91mOFF"
::Check If Applicable For PC
	::Laptop
	wmic path Win32_Battery Get BatteryStatus | find "1" && set "PWROF=%COL%[93mN/A"
	::GPU
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
echo.                                      %COL%[33m+N.
echo.                           //        oMMs         
echo.                          +Nm`    ``yMMm-     ::::::::     ::::    :::    :::::::::: 
echo.                       ``dMMsoyhh-hMMd.     :+:    :+:    :+:+:   :+:    :+:  
echo.                       `yy/MMMMNh:dMMh`    +:+    +:+    :+:+:+  +:+    +:+                 +::+:+::      +::+:+::
echo.                      .hMM.sso++:oMMs`    +#+    +:+    +#+ +:+ +#+    +#++:++#           ++:    #++    ++:    #++
echo.                     -mMMy:osyyys.No     +#+    +#+    +#+  +#+#+#    +#+                +#+    +#+    +#+    +#+
echo.                    :NMMs-oo+/syy:-     #+#    #+#    #+#   #+#+#    #+#          %COL%[37m#+#%COL%[33m    +#+   #+#     #+#   #+#
echo.                   /NMN+ ``   :ys.      ########     ###    ####    ##########   %COL%[37m###%COL%[33m       ######        ######
echo.                  `NMN:        +.                                                      ##    ###     ##    ###
echo.                  om-                                                                   #######       #######
echo.                   `.
echo                                                               %COL%[1;4;34mTweaks%COL%[0m
echo.
echo              %COL%[33m[%COL%[37m 1 %COL%[33m]%COL%[37m Power Plan %PWROF%                 %COL%[33m[%COL%[37m 2 %COL%[33m]%COL%[37m SvcHostSplitThreshold %MEMOF%      %COL%[33m[%COL%[37m 3 %COL%[33m]%COL%[37m CSRSS high priority %CRSOF%
echo              %COL%[90mDesktop Power Plan, not good         %COL%[90mChanges the split threshold for      %COL%[90mCSRSS is responsible for mouse input
echo              %COL%[90mto use with a laptop battery.        %COL%[90mservice host to your RAM             %COL%[90mset to high to improve input latency
echo.
echo              %COL%[33m[%COL%[37m 4 %COL%[33m]%COL%[37m Timer Resolution %TMROF%           %COL%[33m[%COL%[37m 5 %COL%[33m]%COL%[37m MSI Mode %MSIOF%                   %COL%[33m[%COL%[37m 6 %COL%[33m]%COL%[37m Affinity %AFFOF%
echo              %COL%[90mThis tweak changes how fast          %COL%[90mEnable MSI Mode for gpu and          %COL%[90mThis tweak will spread devices
echo              %COL%[90myour cpu refreshes                   %COL%[90mnetwork adapters                     %COL%[90mon multiple cpu cores
echo.
echo              %COL%[33m[%COL%[37m 7 %COL%[33m]%COL%[37m W32 Priority Seperation %BLANK%    %COL%[33m[%COL%[37m 8 %COL%[33m]%COL%[37m Memory Optimization %ME2OF%        %COL%[33m[%COL%[37m 9 %COL%[33m]%COL%[37m Mouse Fix %MOUOF%
echo              %COL%[90mOptimizes the usage priority of      %COL%[90mOptimizes your fsutil, win           %COL%[90mThis removes acceleration which
echo              %COL%[90myour running services                %COL%[90mstartup settings and more            %COL%[90mmakes your aim unconsistent
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
echo.                                      %COL%[33m+N.
echo.                           //        oMMs         
echo.                          +Nm`    ``yMMm-     ::::::::     ::::    :::    :::::::::: 
echo.                       ``dMMsoyhh-hMMd.     :+:    :+:    :+:+:   :+:    :+:  
echo.                       `yy/MMMMNh:dMMh`    +:+    +:+    :+:+:+  +:+    +:+                 +::+:+::      +::+:+::
echo.                      .hMM.sso++:oMMs`    +#+    +:+    +#+ +:+ +#+    +#++:++#           ++:    #++    ++:    #++
echo.                     -mMMy:osyyys.No     +#+    +#+    +#+  +#+#+#    +#+                +#+    +#+    +#+    +#+
echo.                    :NMMs-oo+/syy:-     #+#    #+#    #+#   #+#+#    #+#          %COL%[37m#+#%COL%[33m    +#+   #+#     #+#   #+#
echo.                   /NMN+ ``   :ys.      ########     ###    ####    ##########   %COL%[37m###%COL%[33m       ######        ######
echo.                  `NMN:        +.                                                      ##    ###     ##    ###
echo.                  om-                                                                   #######       #######
echo.                   `.
echo                                                               %COL%[1;4;34mBloat%COL%[0m
echo.
echo              %COL%[33m[%COL%[37m 1 %COL%[33m]%COL%[37m Disable Services %COL%[93mN/A           %COL%[33m[%COL%[37m 2 %COL%[33m]%COL%[37m Debloat %COL%[93mN/A                    %COL%[33m[%COL%[37m 3 %COL%[33m]%COL%[37m Disable Mitigations %MITOF%
echo              %COL%[90mDisables services and lowers memory  %COL%[90mThis tweak will debloat your         %COL%[90mDisable protections against memory
echo              %COL%[90mDon't use if you are using Wi-Fi     %COL%[90msystem and disable telemetry         %COL%[90mbased attacks that consume perf
echo.
echo                                                           %COL%[1;4;34mNetwork Tweaks%COL%[0m
echo.
echo              %COL%[33m[%COL%[37m 4 %COL%[33m]%COL%[37m Optimize TCP/IP %TCPOF%            %COL%[33m[%COL%[37m 5 %COL%[33m]%COL%[37m Optimize NIC %NICOF%               %COL%[33m[%COL%[37m 6 %COL%[33m]%COL%[37m Optimize Netsh %NETOF%
echo              %COL%[90mTweaks your Internet Protocol        %COL%[90mOptimize your Network Card settings  %COL%[90mThis tweak will optimize your
echo              %COL%[90mDon't use if you are using Wi-Fi     %COL%[90mDon't use if you are using Wi-Fi     %COL%[90mcomputer network configuration
echo.
echo                                                             %COL%[1;4;34mGPU ^& CPU%COL%[0m
echo.
echo              %COL%[33m[%COL%[37m 7 %COL%[33m]%COL%[37m All GPU Tweaks %ALLOF%             %COL%[33m[%COL%[37m 8 %COL%[33m]%COL%[37m Optimize Intel iGPU %DSSOF%        %COL%[33m[%COL%[37m 9 %COL%[33m]%COL%[37m AMD GPU Tweaks %AMDOF%
echo              %COL%[90mVarious essential tweaks for all     %COL%[90mIncrease dedicated video vram on     %COL%[90mConfigure AMD GPU to optimized
echo              %COL%[90mGPU brands and manufacturers         %COL%[90ma intel iGPU                         %COL%[90msettings
echo.
echo                                                        %COL%[1;4;34mMiscellaneous Tweaks%COL%[0m
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
if /i "%choice%"=="1" call:Comingsoon
if /i "%choice%"=="2" call:Comingsoon
if /i "%choice%"=="3" goto Mitigations
if /i "%choice%"=="4" goto TCPIP
if /i "%choice%"=="5" goto NIC
if /i "%choice%"=="6" goto Netsh
if /i "%choice%"=="7" goto AllGPUTweaks
if /i "%choice%"=="8" goto Intel
if /i "%choice%"=="9" goto AMD
if /i "%choice%"=="10" call:Cleaner
if /i "%choice%"=="11" call:gameBooster
if /i "%choice%"=="12" call:softRestart

if /i "%choice%"=="X" exit /b
if /i "%choice%"=="B" goto MainMenu
if /i "%choice%"=="N" (set "PG=TweaksPG1") & goto TweaksPG1
goto TweaksPG2

:TweaksPG3
cls
echo.
echo.
echo.                                      %COL%[33m+N.
echo.                           //        oMMs         
echo.                          +Nm`    ``yMMm-     ::::::::     ::::    :::    :::::::::: 
echo.                       ``dMMsoyhh-hMMd.     :+:    :+:    :+:+:   :+:    :+:  
echo.                       `yy/MMMMNh:dMMh`    +:+    +:+    :+:+:+  +:+    +:+                 +::+:+::      +::+:+::
echo.                      .hMM.sso++:oMMs`    +#+    +:+    +#+ +:+ +#+    +#++:++#           ++:    #++    ++:    #++
echo.                     -mMMy:osyyys.No     +#+    +#+    +#+  +#+#+#    +#+                +#+    +#+    +#+    +#+
echo.                    :NMMs-oo+/syy:-     #+#    #+#    #+#   #+#+#    #+#          %COL%[37m#+#%COL%[33m    +#+   #+#     #+#   #+#
echo.                   /NMN+ ``   :ys.      ########     ###    ####    ##########   %COL%[37m###%COL%[33m       ######        ######
echo.                  `NMN:        +.                                                      ##    ###     ##    ###
echo.                  om-                                                                   #######       #######
echo.                   `.
rem echo                                                           %COL%[1;4;34mLatency Tweaks%COL%[0m
rem echo.
rem echo              %COL%[33m[%COL%[37m 3 %COL%[33m]%COL%[37m Disable USB Power Savings %BLANK%  %COL%[33m[%COL%[37m 4 %COL%[33m]%COL%[37m CSRSS high priority %BLANK%        %COL%[33m[%COL%[37m 5 %COL%[33m]%COL%[37m Disable HPET %BLANK%
rem echo              %COL%[90mTweaks your Internet Protocol        %COL%[90mCSRSS is for mouse input, setting    %COL%[90mCSRSS is responsible for mouse input
rem echo              %COL%[90mDon't use if you are using Wi-Fi     %COL%[90mhigh priority may improve latency    %COL%[90mset to high to improve input latency
echo                                                        %COL%[1;4;34mMiscellaneous Tweaks%COL%[0m
echo.
echo              %COL%[33m[%COL%[37m 1 %COL%[33m]%COL%[37m Cleaner %BLANK%                    %COL%[33m[%COL%[37m 2 %COL%[33m]%COL%[37m Game-Booster %BLANK%               %COL%[33m[%COL%[37m 3 %COL%[33m]%COL%[37m Soft Restart %BLANK%
echo              %COL%[90mRemove adware, unused devices, and   %COL%[90mSets GPU ^& CPU to high performance   %COL%[90mIf your PC has been running a while
echo              %COL%[90mtemp files. Empties recycle bin.     %COL%[90mDisables fullscreen optimizations    %COL%[90muse this to receive a quick boost
echo.
echo.
echo.                                                     	  %COL%[1;4;31mAdvanced Tweaks%COL%[0m
echo.
echo.			 			     %COL%[33m[%COL%[37m Press A to go to page %COL%[33m]
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
echo                                     %COL%[90m[ B for back ]         %COL%[31m[ X to close ]         %COL%[36m[ N page one ]
echo.
set /p choice="%DEL%                                        %COL%[37mSelect a corresponding number to the options above > "
if /i "%choice%"=="1" call:Cleaner
if /i "%choice%"=="2" call:gameBooster
if /i "%choice%"=="3" call:softRestart
if /i "%choice%"=="A" goto disclaimer2
if /i "%choice%"=="X" exit /b
if /i "%choice%"=="B" goto MainMenu
if /i "%choice%"=="N" (set "PG=TweaksPG1") & goto TweaksPG1
goto TweaksPG3

:PowerPlan
echo %PWROF% | find "N/A" >nul && call :HoneCtrlError "You are on AC power, this power plan isn't recommended." && goto Tweaks
curl -g -k -L -# -o "C:\Hone\Resources\HoneV2.pow" "https://github.com/auraside/HoneCtrl/raw/main/Files/HoneV2.pow" >nul 2>&1
powercfg /d 44444444-4444-4444-4444-444444444449 >nul 2>&1
powercfg -import "C:\Hone\Resources\HoneV2.pow" 44444444-4444-4444-4444-444444444449 >nul 2>&1
powercfg /changename 44444444-4444-4444-4444-444444444449 "Hone Ultimate Power Plan V2" "The Ultimate Power Plan to increase FPS, improve latency and reduce input lag." >nul 2>&1

::Enable Idle on Hyper-Threading
set THREADS=%NUMBER_OF_PROCESSORS%
for /f "tokens=2 delims==" %%n in ('wmic cpu get numberOfCores /value') do set CORES=%%n
IF "%CORES%" EQU "%NUMBER_OF_PROCESSORS%" (
	powercfg -setacvalueindex 44444444-4444-4444-4444-444444444449 sub_processor IDLEDISABLE 1
) else (
	powercfg -setacvalueindex 44444444-4444-4444-4444-444444444449 sub_processor IDLEDISABLE 0
)

::Advanced
powercfg -setacvalueindex 44444444-4444-4444-4444-444444444449 sub_processor IDLEDISABLE 0

::Reduce the amount of times than the cpu enters/exits idle states
rem Reg add "HKLM\System\CurrentControlSet\Control\Session Manager\Power" /v "CoalescingTimerInterval" /t REG_DWORD /d "0" /f

powercfg -setactive "44444444-4444-4444-4444-444444444449" >nul 2>&1
if "%PWROF%" equ "%COL%[92mON " (powercfg -restoredefaultschemes) >nul 2>&1
goto tweaks

:ServicesOptimization
for /f "tokens=2 delims==" %%i in ('wmic os get TotalVisibleMemorySize /value') do set /a mem=%%i + 1024000
Reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control" /v "SvcHostSplitThresholdInKB" /t REG_DWORD /d %mem% /f >nul 2>&1
if "%MEMOF%" equ "%COL%[92mON " (Reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control" /v "SvcHostSplitThresholdInKB" /t REG_DWORD /d 3670016 /f) >nul 2>&1
goto tweaks

:BCDEdit
if "%BCDOF%" equ "%COL%[91mOFF" (
	Reg add "HKCU\Software\Hone" /v BcdEditTweaks /f
	::tscsyncpolicy
	bcdedit /set tscsyncpolicy enhanced
	::Quick Boot
	if "%duelboot%" equ "no" (bcdedit /timeout 3)
	bcdedit /set bootux disabled
	bcdedit /set bootmenupolicy standard
	rem bcdedit /set hypervisorlaunchtype off
	rem bcdedit /set tpmbootentropy ForceDisable
	bcdedit /set quietboot yes
	::Windows 8 Boot (windows 8.1)
	for /f "tokens=4-9 delims=. " %%i in ('ver') do set winversion=%%i.%%j
	if "!winversion!" == "6.3.9600" (
	bcdedit /set {globalsettings} custom:16000067 true
	bcdedit /set {globalsettings} custom:16000069 true
	bcdedit /set {globalsettings} custom:16000068 true
	)
	::nx
	echo %PROCESSOR_IDENTIFIER% ^| find "Intel" >nul && bcdedit /set nx optout || bcdedit /set nx alwaysoff
	::Disable some of the kernel memory mitigations
	rem Forcing Intel SGX and setting isolatedcontext to No will cause a black screen
	rem bcdedit /set isolatedcontext No
	bcdedit /set allowedinmemorysettings 0x0
	::Disable DMA memory protection and cores isolation
	bcdedit /set vsmlaunchtype Off
	bcdedit /set vm No
	Reg add "HKLM\Software\Policies\Microsoft\FVE" /v "DisableExternalDMAUnderLock" /t Reg_DWORD /d "0" /f
	Reg add "HKLM\Software\Policies\Microsoft\Windows\DeviceGuard" /v "EnableVirtualizationBasedSecurity" /t Reg_DWORD /d "0" /f
	Reg add "HKLM\Software\Policies\Microsoft\Windows\DeviceGuard" /v "HVCIMATRequired" /t Reg_DWORD /d "0" /f
	::Avoid using uncontiguous low-memory. Boosts memory performance & microstuttering.
	rem Can freeze the system on unstable memory OC
	rem bcdedit /set firstmegabytepolicy UseAll
	rem bcdedit /set avoidlowmemory 0x8000000
	rem bcdedit /set nolowmem Yes
	::Enable X2Apic and enable Memory Mapping for PCI-E devices
	bcdedit /set x2apicpolicy Enable
	bcdedit /set uselegacyapicmode No
	bcdedit /set configaccesspolicy Default
	bcdedit /set usephysicaldestination No
	bcdedit /set usefirmwarepcisettings No
) >nul 2>&1 else (
	Reg delete "HKCU\Software\Hone" /v "BcdEditTweaks" /f
	::Better Input
	bcdedit /deletevalue tscsyncpolicy
	::Quick Boot
	if "%duelboot%" equ "no" (bcdedit /timeout 0)
	bcdedit /deletevalue bootux
	bcdedit /set bootmenupolicy standard
	bcdedit /set hypervisorlaunchtype Auto
	bcdedit /deletevalue tpmbootentropy
	bcdedit /deletevalue quietboot
	::Windows 8 Boot Stuff (windows 8.1)
	for /f "tokens=4-9 delims=. " %%i in ('ver') do set winversion=%%i.%%j
	if "!winversion!" == "6.3.9600" (
	bcdedit /set {globalsettings} custom:16000067 false
	bcdedit /set {globalsettings} custom:16000069 false
	bcdedit /set {globalsettings} custom:16000068 false
	)
	::nx
	bcdedit /set nx optin
	::Disable some of the kernel memory mitigations
	bcdedit /set allowedinmemorysettings 0x17000077
	bcdedit /set isolatedcontext Yes
	::Disable DMA memory protection and cores isolation
	bcdedit /deletevalue vsmlaunchtype
	bcdedit /deletevalue vm
	Reg delete "HKLM\Software\Policies\Microsoft\FVE" /v "DisableExternalDMAUnderLock" /f
	Reg delete "HKLM\Software\Policies\Microsoft\Windows\DeviceGuard" /v "EnableVirtualizationBasedSecurity" /f
	Reg delete "HKLM\Software\Policies\Microsoft\Windows\DeviceGuard" /v "HVCIMATRequired" /f
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

:TimerRes
cd C:\Hone\Resources
if "%TMROF%" equ "%COL%[91mOFF" (
	if not exist SetTimerResolutionService.exe (
		::https://forums.guru3d.com/threads/windows-timer-resolution-tool-in-form-of-system-service.376458/
		curl -g -L -# -o "C:\Hone\Resources\SetTimerResolutionService.exe" "https://github.com/auraside/HoneCtrl/raw/main/Files/SetTimerResolutionService.exe" >nul 2>&1
		%windir%\Microsoft.NET\Framework\v4.0.30319\InstallUtil.exe /i SetTimerResolutionService.exe >nul 2>&1
	)
	sc config "STR" start=auto >nul 2>&1
	start /b net start STR >nul 2>&1
	bcdedit /set useplatformtick true >nul 2>&1
	bcdedit /set disabledynamictick yes >nul 2>&1
) else (
	sc config "STR" start=disabled >nul 2>&1
	start /b net stop STR >nul 2>&1
	bcdedit /deletevalue useplatformclock >nul 2>&1
	bcdedit /deletevalue useplatformtick >nul 2>&1
	bcdedit /deletevalue disabledynamictick >nul 2>&1
)
goto tweaks

rem DEPRICATED
:KBoost
if "%KBOOF%" equ "%COL%[91mOFF" (
	for /f %%i in ('Reg query "HKLM\System\ControlSet001\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /t REG_SZ /s /e /f "NVIDIA" ^| findstr "HKEY"') do (
		Reg add "%%a" /v "PowerMizerEnable" /t REG_DWORD /d "1" /f >nul 2>&1
		Reg add "%%a" /v "PowerMizerLevel" /t REG_DWORD /d "1" /f >nul 2>&1
		Reg add "%%a" /v "PowerMizerLevelAC" /t REG_DWORD /d "1" /f >nul 2>&1
		Reg add "%%a" /v "PerfLevelSrc" /t REG_DWORD /d "8738" /f >nul 2>&1
	)
) else (
	for /f %%i in ('Reg query "HKLM\System\ControlSet001\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /t REG_SZ /s /e /f "NVIDIA" ^| findstr "HKEY"') do (
		Reg delete "%%a" /v "PowerMizerEnable" /f >nul 2>&1
		Reg delete "%%a" /v "PowerMizerLevel" /f >nul 2>&1
		Reg delete "%%a" /v "PowerMizerLevelAC" /f >nul 2>&1
		Reg delete "%%a" /v "PerfLevelSrc" /f >nul 2>&1
	)
)
call :HoneCtrlRestart "KBoost" "%KBOOF%" && goto Tweaks

:MSI
if "%MSIOF%" equ "%COL%[91mOFF" (
	Reg add "HKCU\Software\Hone" /v "MSIModeTweaks" /f >nul 2>&1
	for /f %%g in ('wmic path win32_VideoController get PNPDeviceID ^| findstr /L "VEN_"') do Reg add "HKLM\SYSTEM\CurrentControlSet\Enum\%%g\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /t REG_DWORD /d "1" /f >nul 2>&1
	for /f %%g in ('wmic path win32_VideoController get PNPDeviceID ^| findstr /L "VEN_"') do Reg delete "HKLM\System\CurrentControlSet\Enum\%%g\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" /f >nul 2>&1
	for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID ^| findstr /L "VEN_"') do Reg add "HKLM\SYSTEM\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /t REG_DWORD /d "1" /f >nul 2>&1
	for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID ^| findstr /L "VEN_"') do Reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" /f >nul 2>&1
) else (
	Reg delete "HKCU\Software\Hone" /v "MSIModeTweaks" /f >nul 2>&1
	for /f %%g in ('wmic path win32_VideoController get PNPDeviceID ^| findstr /L "VEN_"') do Reg delete "HKLM\SYSTEM\CurrentControlSet\Enum\%%g\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /f >nul 2>&1
	for /f %%g in ('wmic path win32_VideoController get PNPDeviceID ^| findstr /L "VEN_"') do Reg delete "HKLM\System\CurrentControlSet\Enum\%%g\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" /f >nul 2>&1
	for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID ^| findstr /L "VEN_"') do Reg delete "HKLM\SYSTEM\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /f >nul 2>&1
	for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID ^| findstr /L "VEN_"') do Reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority " /f >nul 2>&1
)
goto Tweaks

:TCPIP
cls
if "%TCPOF%" equ "%COL%[91mOFF" (
	Reg add "HKCU\Software\Hone" /v "TCPIP" /f
	PowerShell -NoProfile -NonInteractive -Command ^
	Set-NetIPInterface -RetransmitTimeMs 0 -Forwarding Disabled -EcnMarking Disabled -AdvertiseDefaultRoute Disabled;^
	Set-NetOffloadGlobalSetting -PacketCoalescingFilter Disabled;^
	Enable-NetAdapterQos -Name "*";^
	Set-NetOffloadGlobalSetting -Chimney Disabled;^
	Disable-NetAdapterPowerManagement -Name "*";^
	Set-NetTCPSetting -SettingName "InternetCustom" -MemoryPressureProtection Disabled;^
	Set-NetTCPSetting -SettingName "DatacenterCustom" -MemoryPressureProtection Disabled;^
	Set-NetTCPSetting -SettingName "Datacenter" -MemoryPressureProtection Disabled;^
	Set-NetTCPSetting -SettingName "Internet" -MemoryPressureProtection Disabled;^
	Set-NetTCPSetting -SettingName "Compat" -MemoryPressureProtection Disabled;^
	Disable-NetAdapterIPsecOffload -Name "*" -ErrorAction SilentlyContinue
	Reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "EnablePMTUDiscovery" /t REG_DWORD /d "1" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "EnableICMPRedirect" /t REG_DWORD /d "1" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "EnablePMTUBHDetect" /t REG_DWORD /d "1" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpMaxConnectRetransmissions" /t REG_DWORD /d "1" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Tcp1323Opts" /t REG_DWORD /d "1" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpTimedWaitDelay" /t REG_DWORD /d "32" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "DelayedAckFrequency" /t REG_DWORD /d "1" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "DelayedAckTicks" /t REG_DWORD /d "1" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "CongestionAlgorithm" /t REG_DWORD /d "1" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "MultihopSets" /t REG_DWORD /d "0" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "EnableICMPRedirect" /t REG_DWORD /d "1" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\services\Tcpip\Parameters" /v "DnsQueryTimeouts" /t REG_MULTI_SZ /d "1 1 2 2 4 0" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "IRPStackSize" /t REG_DWORD /d "50" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "SizReqBuf" /t REG_DWORD /d "17424" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "Size" /t REG_DWORD /d "3" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider" /v "DnsPriority" /t REG_DWORD /d "6" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider" /v "HostsPriority" /t REG_DWORD /d "5" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider" /v "LocalPriority" /t REG_DWORD /d "4" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider" /v "NetbtPriority" /t REG_DWORD /d "7" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d "1" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "LargeSystemCache" /t REG_DWORD /d "0" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Winsock" /v "UseDelayedAcceptance" /t REG_DWORD /d "0" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Winsock" /v "MaxSockAddrLength" /t REG_DWORD /d "16" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Winsock" /v "MinSockAddrLength" /t REG_DWORD /d "16" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\QoS" /v "Do not use NLA" /t REG_SZ /d "1" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "NegativeCacheTime" /t REG_DWORD /d "0" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "NegativeSOACacheTime" /t REG_DWORD /d "0" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "NetFailureCacheTime" /t REG_DWORD /d "0" /f
	Reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f
	Reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "DoNotShowFeedbackNotifications" /t REG_DWORD /d "1" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "EnableAutoDoh" /t REG_DWORD /d "2" /f
	Reg add "HKLM\SYSTEM\CurrDisableNagleentControlSet\Services\AFD\Parameters" /v "DoNotHoldNicBuffers" /t REG_DWORD /d "1" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "DisableRawSecurity" /t REG_DWORD /d "1" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "NonBlockingSendSpecialBuffering" /t REG_DWORD /d "1" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "IgnorePushBitOnReceives" /t REG_DWORD /d "1" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "DynamicSendBufferDisable" /t REG_DWORD /d "0" /f
	Reg add "HKLM\Software\Microsoft\MSMQ\Parameters" /v "TCPNoDelay" /t REG_DWORD /d "1" /f
	for /f "tokens=3*" %%i in ('Reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkCards" /f "ServiceName" /s ^|findstr /i /l "ServiceName"') do (
		Reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "TCPNoDelay" /t Reg_DWORD /d "1" /f
		Reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "TcpAckFrequency" /t Reg_DWORD /d "1" /f
		Reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "TcpDelAckTicks" /t Reg_DWORD /d "0" /f
		Reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "TcpInitialRTT" /d "300" /t REG_DWORD /f
        Reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "UseZeroBroadcast" /d "0" /t REG_DWORD /f
        Reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "DeadGWDetectDefault" /d "1" /t REG_DWORD /f
	) 
) >nul 2>&1 else (
	Reg delete "HKCU\Software\Hone" /v "TCPIP" /f
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "EnablePMTUDiscovery" /f
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "EnableICMPRedirect" /f
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "EnablePMTUBHDetect" /f
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpMaxConnectRetransmissions" /f
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Tcp1323Opts" /f
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpTimedWaitDelay" /f
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "DelayedAckFrequency" /f
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "DelayedAckTicks" /f
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "CongestionAlgorithm" /f
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "MultihopSets" /f
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "EnableICMPRedirect" /f
	Reg delete "HKLM\SYSTEM\CurrentControlSet\services\Tcpip\Parameters" /v "DnsQueryTimeouts" /f
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "IRPStackSize" /f
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "SizReqBuf" /f
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "Size" /f
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider" /v "DnsPriority" /f
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider" /v "HostsPriority" /f
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider" /v "LocalPriority" /f
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider" /v "NetbtPriority" /f
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /f
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "LargeSystemCache" /f
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Winsock" /v "UseDelayedAcceptance" /f
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Winsock" /v "MaxSockAddrLength" /f
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Winsock" /v "MinSockAddrLength" /f
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\QoS" /v "Do not use NLA" /f
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "NegativeCacheTime" /f
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "NegativeSOACacheTime" /f
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "NetFailureCacheTime" /f
	Reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /f
	Reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "DoNotShowFeedbackNotifications" /f
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "EnableAutoDoh" /f
	Reg delete "HKLM\SYSTEM\CurrDisableNagleentControlSet\Services\AFD\Parameters" /v "DoNotHoldNicBuffers" /f
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "DisableRawSecurity" /f
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "NonBlockingSendSpecialBuffering" /f
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "IgnorePushBitOnReceives" /f
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "DynamicSendBufferDisable" /f
	Reg delete "HKLM\Software\Microsoft\MSMQ\Parameters" /v "TCPNoDelay" /f
	for /f "tokens=3*" %%i in ('Reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkCards" /f "ServiceName" /s ^|findstr /i /l "ServiceName"') do (
		Reg delete "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "TCPNoDelay" /f
		Reg delete "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "TcpAckFrequency" /f
		Reg delete "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "TcpDelAckTicks" /f
		Reg delete "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "TcpInitialRTT" /f
        Reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "UseZeroBroadcast" /f
        Reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "DeadGWDetectDefault" /f
	)
) >nul 2>&1
start /B cmd /c "ipconfig /release & ipconfig /renew" >nul 2>&1
goto Tweaks

:NIC
cd %SystemDrive%\Hone\HoneRevert
if "%NICOF%" neq "%COL%[91mOFF" (
	reg import ognic.reg >nul 2>&1
	del ognic.reg
	goto Tweaks
)
for /f "tokens=*" %%f in ('wmic cpu get NumberOfCores /value ^| find "="') do set %%f
for /f "tokens=3*" %%a in ('Reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion\NetworkCards" /k /v /f "Description" /s /e ^| findstr /ri "REG_SZ"') do (
for /f %%g in ('Reg query "HKLM\System\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}" /s /f "%%b" /d ^| findstr /C:"HKEY"') do (
Reg export "%%g" "%SystemDrive%\Hone\HoneRevert\ognic.reg" /y
Reg add "%%g" /v "MIMOPowerSaveMode" /t REG_SZ /d "3" /f
Reg add "%%g" /v "PowerSavingMode" /t REG_SZ /d "0" /f
Reg add "%%g" /v "EnableGreenEthernet" /t REG_SZ /d "0" /f
Reg add "%%g" /v "*EEE" /t REG_SZ /d "0" /f
Reg add "%%g" /v "*IPSecOffloadV1IPv4" /t REG_SZ /d "0" /f
Reg add "%%g" /v "*IPSecOffloadV2IPv4" /t REG_SZ /d "0" /f
Reg add "%%g" /v "*IPSecOffloadV2" /t REG_SZ /d "0" /f
Reg add "%%g" /v "*RscIPv4" /t REG_SZ /d "0" /f
Reg add "%%g" /v "*RscIPv6" /t REG_SZ /d "0" /f
Reg add "%%g" /v "*PMNSOffload" /t REG_SZ /d "0" /f
Reg add "%%g" /v "*PMARPOffload" /t REG_SZ /d "0" /f
Reg add "%%g" /v "*JumboPacket" /t REG_SZ /d "0" /f
Reg add "%%g" /v "EnableConnectedPowerGating" /t REG_SZ /d "0" /f
Reg add "%%g" /v "EnableDynamicPowerGating" /t REG_SZ /d "0" /f
Reg add "%%g" /v "EnableSavePowerNow" /t REG_SZ /d "0" /f
Reg add "%%g" /v "*FlowControl" /t REG_SZ /d "0" /f
rem RSS
Reg add "%%g" /v "*NumRssQueues" /t REG_SZ /d "2" /f
if %NumberOfCores% geq 6 (
Reg add "%%g" /v "*RssBaseProcNumber" /t REG_SZ /d "4" /f
Reg add "%%g" /v "*RssMaxProcNumber" /t REG_SZ /d "5" /f
) else if %NumberOfCores% geq 4 (
Reg add "%%g" /v "*RssBaseProcNumber" /t REG_SZ /d "2" /f
Reg add "%%g" /v "*RssMaxProcNumber" /t REG_SZ /d "3" /f
) else (
Reg delete "%%g" /v "*RssBaseProcNumber" /f
Reg delete "%%g" /v "*RssMaxProcNumber" /f
)
) >nul 2>&1
)
start /B cmd /c "ipconfig /release & ipconfig /renew" >nul 2>&1
goto Tweaks

:Netsh
if "%NETOF%" equ "%COL%[91mOFF" (
	Reg add "HKCU\Software\Hone" /v InternetTweaks /f
	netsh int tcp set global dca=enabled
	netsh int tcp set global netdma=enabled
	netsh interface isatap set state disabled
	netsh int tcp set global timestamps=disabled
	netsh int tcp set supplemental Internet congestionprovider=ctcp
	netsh int tcp set global rss=enabled
	netsh int tcp set global nonsackrttresiliency=disabled
	netsh int tcp set global initialRto=2000
	netsh int udp set global uro=enabled
	netsh int tcp set supplemental template=custom icw=10
	netsh interface teredo set state disable
	netsh int tcp set global hystart=disabled
	netsh interface tcp set heuristics wsh=enabled
	netsh int tcp set heuristics forcews=enabled
	netsh interface ip set interface Ethernet weakhostsend=enabled store=persistent
	netsh interface ip set interface Ethernet weakhostreceive=enabled store=persistent
        netsh int tcp set security mpp=disabled profiles=disabled
        netsh interface ipv6 set global icmpredirects=dis
        netsh interface ip set interface Ethernet otherstateful=disabled store=persistent
        netsh interface ip set interface ethernet currenthoplimit=128
        netsh int ipv4 set subinterface "Ethernet" mtu=1500 store=persistent
        netsh int ipv4 set subinterface "Ethernet 2" mtu=1500 store=persistent
        netsh int ipv4 set dynamicportrange protocol=tcp startport=1025 numberofports=64510 store=persistent
        netsh interface ip set global mediasenseeventlog=disabled
        netsh int ip set global sourceroutingbehavior=drop
        netsh int ip set global neighborcachelimit=4096
        netsh int ip set global routecachelimit=4096
        netsh int ipv4 set dynamicport udp start=1025 num=64511
) >nul 2>&1 else (
	Reg delete "HKCU\Software\Hone" /v InternetTweaks /f
	netsh int tcp set supplemental Internet congestionprovider=default
	netsh int tcp set global initialRto=3000
	netsh int tcp set global rss=default
	netsh int tcp set global chimney=default
	netsh int tcp set global dca=default
	netsh int tcp set global netdma=default
	netsh int tcp set global ecncapability=default
	netsh int tcp set global timestamps=default
	netsh int tcp set global nonsackrttresiliency=default
	netsh interface teredo set state default
	netsh int udp set global uro=dis
	netsh int tcp set global hystart=enabled
	netsh interface isatap set state default
	netsh interface tcp set heuristics wsh=default
	netsh int tcp set heuristics forcews=default
	netsh interface ip set interface Ethernet weakhostsend=disabled store=persistent
	netsh interface ip set interface Ethernet weakhostreceive=disabled store=persistent
        netsh int tcp set security mpp=default
        netsh interface ipv6 set global icmpredirects=en
        netsh interface ip set interface Ethernet otherstateful=en store=persistent
        netsh interface ip set interface ethernet currenthoplimit=64
        netsh int ipv4 set subinterface "Ethernet" mtu=1500 store=persistent
        netsh int ipv4 set subinterface "Ethernet 2" mtu=1500 store=persistent
        netsh int ipv4 set dynamicportrange protocol=tcp startport=49152 numberofports=16384 store=persistent
        netsh interface ip set global mediasenseeventlog=en
        netsh int ip set global sourceroutingbehavior=dontforward
        netsh int ip set global neighborcachelimit=256
        netsh int ip set global routecachelimit=128
        netsh int ipv4 set dynamicport udp start=49152 num=16384
) >nul 2>&1
goto Tweaks

:AllGPUTweaks
if "%ALLOF%" equ "%COL%[91mOFF" (
cls
Reg add "HKCU\Software\Hone" /v "AllGPUTweaks" /f
::Enable Hardware Accelerated Scheduling
Reg query "HKLM\System\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" && Reg add "HKLM\System\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t Reg_DWORD /d "2" /f
::Enable gdi hardware acceleration
for /f %%a in ('Reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class" /v "VgaCompatible" /s ^| findstr "HKEY"') do Reg add "%%a" /v "KMD_EnableGDIAcceleration" /t Reg_DWORD /d "1" /f
::Enable GameMode
Reg add "HKCU\Software\Microsoft\GameBar" /v "AllowAutoGameMode" /t Reg_DWORD /d "1" /f
Reg add "HKCU\Software\Microsoft\GameBar" /v "AutoGameModeEnabled" /t Reg_DWORD /d "1" /f
::FSO
reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d "0" /f
reg add "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehaviorMode" /t REG_DWORD /d "2" /f
reg add "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehavior" /t REG_DWORD /d "2" /f
reg add "HKCU\System\GameConfigStore" /v "GameDVR_HonorUserFSEBehaviorMode" /t REG_DWORD /d "1" /f
reg add "HKCU\System\GameConfigStore" /v "GameDVR_DXGIHonorFSEWindowsCompatible" /t REG_DWORD /d "1" /f
reg add "HKCU\System\GameConfigStore" /v "GameDVR_EFSEFeatureFlags" /t REG_DWORD /d "0" /f
reg add "HKCU\System\GameConfigStore" /v "GameDVR_DSEBehavior" /t REG_DWORD /d "2" /f
::Disable GpuEnergyDrv
Reg add "HKLM\SYSTEM\CurrentControlSet\Services\GpuEnergyDrv" /v "Start" /t Reg_DWORD /d "4" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Services\GpuEnergyDr" /v "Start" /t Reg_DWORD /d "4" /f
::Disable Preemption
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Scheduler" /v "EnablePreemption" /t Reg_DWORD /d "0" /f
)>nul 2>&1 else (
Reg delete "HKCU\Software\Hone" /v "AllGPUTweaks" /f
::Enable Hardware Accelerated Scheduling
reg query "HKLM\System\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" && Reg add "HKLM\System\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t Reg_DWORD /d "1" /f
::Disable gdi hardware acceleration
for /f %%a in ('Reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class" /v "VgaCompatible" /s ^| findstr "HKEY"') do Reg delete "%%a" /v "KMD_EnableGDIAcceleration" /f
::Enable GameMode
Reg add "HKCU\Software\Microsoft\GameBar" /v "AllowAutoGameMode" /t Reg_DWORD /d "1" /f
Reg add "HKCU\Software\Microsoft\GameBar" /v "AutoGameModeEnabled" /t Reg_DWORD /d "1" /f
::FSO
reg delete "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /f
reg delete "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehaviorMode" /f
reg delete "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehavior" /f
reg delete "HKCU\System\GameConfigStore" /v "GameDVR_HonorUserFSEBehaviorMode" /f
reg delete "HKCU\System\GameConfigStore" /v "GameDVR_DXGIHonorFSEWindowsCompatible" /f
reg delete "HKCU\System\GameConfigStore" /v "GameDVR_EFSEFeatureFlags" /f
reg delete "HKCU\System\GameConfigStore" /v "GameDVR_DSEBehavior" /f
::Disable GpuEnergyDrv
Reg add "HKLM\SYSTEM\CurrentControlSet\Services\GpuEnergyDrv" /v "Start" /t Reg_DWORD /d "2" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Services\GpuEnergyDr" /v "Start" /t Reg_DWORD /d "2" /f
::Disable Preemption
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Scheduler" /v "EnablePreemption" /t Reg_DWORD /d "1" /f
)>nul 2>&1
goto Tweaks

:AMD
echo %AMDOF% | find "N/A" >nul && call :HoneCtrlError "You don't have an AMD GPU" && goto Tweaks
::AMD Registry Location
for /f %%i in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /s /v "DriverDesc"^| findstr "HKEY AMD ATI"') do if /i "%%i" neq "DriverDesc" (set "REGPATH_AMD=%%i")
::AMD Tweaks
Reg add "%REGPATH_AMD%" /v "3D_Refresh_Rate_Override_DEF" /t Reg_DWORD /d "0" /f >nul 2>&1
Reg add "%REGPATH_AMD%" /v "3to2Pulldown_NA" /t Reg_DWORD /d "0" /f >nul 2>&1
Reg add "%REGPATH_AMD%" /v "AAF_NA" /t Reg_DWORD /d "0" /f >nul 2>&1
Reg add "%REGPATH_AMD%" /v "Adaptive De-interlacing" /t Reg_DWORD /d "1" /f >nul 2>&1
Reg add "%REGPATH_AMD%" /v "AllowRSOverlay" /t Reg_SZ /d "false" /f >nul 2>&1
Reg add "%REGPATH_AMD%" /v "AllowSkins" /t Reg_SZ /d "false" /f >nul 2>&1
Reg add "%REGPATH_AMD%" /v "AllowSnapshot" /t Reg_DWORD /d "0" /f >nul 2>&1
Reg add "%REGPATH_AMD%" /v "AllowSubscription" /t Reg_DWORD /d "0" /f >nul 2>&1
Reg add "%REGPATH_AMD%" /v "AntiAlias_NA" /t Reg_SZ /d "0" /f >nul 2>&1
Reg add "%REGPATH_AMD%" /v "AreaAniso_NA" /t Reg_SZ /d "0" /f >nul 2>&1
Reg add "%REGPATH_AMD%" /v "ASTT_NA" /t Reg_SZ /d "0" /f >nul 2>&1
Reg add "%REGPATH_AMD%" /v "AutoColorDepthReduction_NA" /t Reg_DWORD /d "0" /f >nul 2>&1
Reg add "%REGPATH_AMD%" /v "DisableSAMUPowerGating" /t Reg_DWORD /d "1" /f >nul 2>&1
Reg add "%REGPATH_AMD%" /v "DisableUVDPowerGatingDynamic" /t Reg_DWORD /d "1" /f >nul 2>&1
Reg add "%REGPATH_AMD%" /v "DisableVCEPowerGating" /t Reg_DWORD /d "1" /f >nul 2>&1
Reg add "%REGPATH_AMD%" /v "EnableAspmL0s" /t Reg_DWORD /d "0" /f >nul 2>&1
Reg add "%REGPATH_AMD%" /v "EnableAspmL1" /t Reg_DWORD /d "0" /f >nul 2>&1
Reg add "%REGPATH_AMD%" /v "EnableUlps" /t Reg_DWORD /d "0" /f >nul 2>&1
Reg add "%REGPATH_AMD%" /v "EnableUlps_NA" /t Reg_SZ /d "0" /f >nul 2>&1
Reg add "%REGPATH_AMD%" /v "KMD_DeLagEnabled" /t Reg_DWORD /d "1" /f >nul 2>&1
Reg add "%REGPATH_AMD%" /v "KMD_FRTEnabled" /t Reg_DWORD /d "0" /f >nul 2>&1
Reg add "%REGPATH_AMD%" /v "DisableDMACopy" /t Reg_DWORD /d "1" /f >nul 2>&1
Reg add "%REGPATH_AMD%" /v "DisableBlockWrite" /t Reg_DWORD /d "0" /f >nul 2>&1
Reg add "%REGPATH_AMD%" /v "StutterMode" /t Reg_DWORD /d "0" /f >nul 2>&1
Reg add "%REGPATH_AMD%" /v "EnableUlps" /t Reg_DWORD /d "0" /f >nul 2>&1
Reg add "%REGPATH_AMD%" /v "PP_SclkDeepSleepDisable" /t Reg_DWORD /d "1" /f >nul 2>&1
Reg add "%REGPATH_AMD%" /v "PP_ThermalAutoThrottlingEnable" /t Reg_DWORD /d "0" /f >nul 2>&1
Reg add "%REGPATH_AMD%" /v "DisableDrmdmaPowerGating" /t Reg_DWORD /d "1" /f >nul 2>&1
Reg add "%REGPATH_AMD%" /v "KMD_EnableComputePreemption" /t Reg_DWORD /d "0" /f >nul 2>&1
Reg add "%REGPATH_AMD%\UMD" /v "Main3D_DEF" /t Reg_SZ /d "1" /f >nul 2>&1
Reg add "%REGPATH_AMD%\UMD" /v "Main3D" /t Reg_BINARY /d "3100" /f >nul 2>&1
Reg add "%REGPATH_AMD%\UMD" /v "FlipQueueSize" /t Reg_BINARY /d "3100" /f >nul 2>&1
Reg add "%REGPATH_AMD%\UMD" /v "ShaderCache" /t Reg_BINARY /d "3200" /f >nul 2>&1
Reg add "%REGPATH_AMD%\UMD" /v "Tessellation_OPTION" /t Reg_BINARY /d "3200" /f >nul 2>&1
Reg add "%REGPATH_AMD%\UMD" /v "Tessellation" /t Reg_BINARY /d "3100" /f >nul 2>&1
Reg add "%REGPATH_AMD%\UMD" /v "VSyncControl" /t Reg_BINARY /d "3000" /f >nul 2>&1
Reg add "%REGPATH_AMD%\UMD" /v "TFQ" /t Reg_BINARY /d "3200" /f >nul 2>&1
Reg add "%REGPATH_AMD%\DAL2_DATA__2_0\DisplayPath_4\EDID_D109_78E9\Option" /v "ProtectionControl" /t Reg_BINARY /d "0100000001000000" /f >nul 2>&1
goto Tweaks

:Intel
echo %DSSOF% | find "N/A" >nul && call :HoneCtrlError "You don't have an intel GPU" && goto Tweaks
::DedicatedSegmentSize in Intel iGPU
if "%DSSOF%" equ "%COL%[91mOFF" (
	reg add "HKLM\SOFTWARE\Intel\GMM" /v "DedicatedSegmentSize" /t REG_DWORD /d "1024" /f >nul 2>&1
) else (
	reg delete "HKLM\SOFTWARE\Intel\GMM" /v "DedicatedSegmentSize" /f >nul 2>&1
)
goto Tweaks

:Debloat
if "%DEBOF%" equ "%COL%[91mOFF" (
    Reg add "HKCU\Software\Hone" /v DebloatTweaks /f
	schtasks /Change /TN "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /Disable 
	Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\AutoLogger-Diagtrack-Listener" /v "Start" /t REG_DWORD /d "0" /f  
	Reg.exe add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility" /v "DiagnosticErrorText" /t REG_DWORD /d "0" /f  
	Reg.exe add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Strings" /v "DiagnosticErrorText" /t REG_SZ /d "" /f  
	Reg.exe add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Strings" /v "DiagnosticLinkText" /t REG_SZ /d "" /f  
	Reg.exe add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\PhishingFilter" /v "EnabledV9" /t REG_DWORD /d "0" /f  
	Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\TabletPC" /v "PreventHandwritingDataSharing" /t REG_DWORD /d "1" /f  
	Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\HandwritingErrorReports" /v "PreventHandwritingErrorReports" /t REG_DWORD /d "1" /f  
	Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "DisableInventory" /t REG_DWORD /d "1" /f  
	Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "DisableUAR" /t REG_DWORD /d "1" /f  
	Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Personalization" /v "NoLockScreenCamera" /t REG_DWORD /d "1" /f  
	Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d "0" /f  
	Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d "0" /f  
	Reg.exe add "HKCU\Software\Microsoft\Input\TIPC" /v "Enabled" /t REG_DWORD /d "0" /f  
	Reg.exe add "HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\System" /v "AllowExperimentation" /t REG_DWORD /d "0" /f  
	Reg.exe add "HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Bluetooth" /v "AllowAdvertising" /t REG_DWORD /d "0" /f  
	Reg.exe add "HKLM\SOFTWARE\Microsoft\SQMClient\Windows" /v "CEIPEnable" /t REG_DWORD /d "0" /f  
	Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Messaging" /v "AllowMessageSync" /t REG_DWORD /d "0" /f  
	Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Biometrics" /v "Enabled" /t REG_DWORD /d "0" /f  
	Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\PushNotifications" /v "ToastEnabled" /t REG_DWORD /d "0" /f  
	Reg.exe add "HKCU\Control Panel\International\User Profile" /v "HttpAcceptLanguageOptOut" /t REG_DWORD /d "1" /f  
	Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\AppHost" /v "EnableWebContentEvaluation" /t REG_DWORD /d "0" /f  
	Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{C1D23ACC-752B-43E5-8448-8D0E519CD6D6}" /v "Value" /t REG_SZ /d "Deny" /f  
	Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_TrackProgs" /t REG_DWORD /d "0" /f  
	Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSyncProviderNotifications" /t REG_DWORD /d "0" /f  
	Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{2297E4E2-5DBE-466D-A12B-0F8286F0D9CA}" /v "Value" /t REG_SZ /d "Deny" /f  
	Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{E5323777-F976-4f5b-9B55-B94699C46E44}" /v "Value" /t REG_SZ /d "Deny" /f  
	Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{2EEF81BE-33FA-4800-9670-1CD474972C3F}" /v "Value" /t REG_SZ /d "Deny" /f  
	Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{52079E78-A92B-413F-B213-E8FE35712E72}" /v "Value" /t REG_SZ /d "Deny" /f   
	Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{7D7E8402-7C54-4821-A34E-AEEFD62DED93}" /v "Value" /t REG_SZ /d "Deny" /f  
	Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{D89823BA-7180-4B81-B50C-7E471E6121A3}" /v "Value" /t REG_SZ /d "Deny" /f  
	Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{8BC668CF-7728-45BD-93F8-CF2B3B41D7AB}" /v "Value" /t REG_SZ /d "Deny" /f  
	Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{9231CB4C-BF57-4AF3-8C55-FDA7BFCC04C5}" /v "Value" /t REG_SZ /d "Deny" /f  
	Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{E390DF20-07DF-446D-B962-F5C953062741}" /v "Value" /t REG_SZ /d "Deny" /f  
	Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{992AFA70-6F47-4148-B3E9-3003349C1548}" /v "Value" /t REG_SZ /d "Deny" /f  
	Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v "GlobalUserDisabled" /t REG_DWORD /d "1" /f  
	Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\DiagTrack" /v "Start" /t REG_DWORD /d "4" /f  
	Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\dmwappushservice" /v "Start" /t REG_DWORD /d "4" /f  
	Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\AutoLogger-Diagtrack-Listener" /v "Start" /t REG_DWORD /d "0" /f  
	Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\WMDRM" /v "DisableOnline" /t REG_DWORD /d "1" /f  
	Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{A8804298-2D5F-42E3-9531-9C8C39EB29CE}" /v "Value" /t REG_SZ /d "Deny" /f  
	Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\LooselyCoupled" /v "Value" /t REG_SZ /d "Deny" /f  
	Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CredUI" /v "DisablePasswordReveal" /t REG_DWORD /d "1" /f  
	Reg.exe add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Main" /v "DoNotTrack" /t REG_DWORD /d "1" /f  
	Reg.exe add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Main" /v "OptimizeWindowsSearchResultsForScreenReaders" /t REG_DWORD /d "0" /f  
	Reg.exe add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\FlipAhead" /v "FPEnabled" /t REG_DWORD /d "0" /f   
	Reg.exe add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\User\Default\SearchScopes" /v "ShowSearchSuggestionsGlobal" /t REG_DWORD /d "0" /f  
	Reg.exe add "HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Browser" /v "AllowAddressBarDropdown" /t REG_DWORD /d "0" /f  
	Reg.exe add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Privacy" /v "EnableEncryptedMediaExtensions" /t REG_DWORD /d "0" /f  
	Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync" /v "SyncPolicy" /t REG_DWORD /d "5" /f  
	Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Personalization" /v "Enabled" /t REG_DWORD /d "0" /f  
	Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\BrowserSettings" /v "Enabled" /t REG_DWORD /d "0" /f  
	Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Credentials" /v "Enabled" /t REG_DWORD /d "0" /f  
	Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Language" /v "Enabled" /t REG_DWORD /d "0" /f  
	Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Accessibility" /v "Enabled" /t REG_DWORD /d "0" /f  
	Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Windows" /v "Enabled" /t REG_DWORD /d "0" /f  
	Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCloudSearch" /t REG_DWORD /d "0" /f  
	Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "ConnectedSearchUseWeb" /t REG_DWORD /d "0" /f  
	Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "DisableWebSearch" /t REG_DWORD /d "1" /f  
	Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowSearchToUseLocation" /t REG_DWORD /d "0" /f  
	Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortana" /t REG_DWORD /d "0" /f  
	Reg.exe add "HKLM\SOFTWARE\Microsoft\Speech_OneCore\Preferences" /v "ModelDownloadAllowed" /t REG_DWORD /d "0" /f  
	Reg.exe add "HKCU\Software\Microsoft\InputPersonalization\TrainedDataStore" /v "HarvestContacts" /t REG_DWORD /d "0" /f  
	Reg.exe add "HKCU\Software\Microsoft\InputPersonalization" /v "RestrictImplicitTextCollection" /t REG_DWORD /d "1" /f  
	Reg.exe add "HKCU\Software\Microsoft\InputPersonalization" /v "RestrictImplicitInkCollection" /t REG_DWORD /d "1" /f  
	Reg.exe add "HKCU\Software\Microsoft\Personalization\Settings" /v "AcceptedPrivacyPolicy" /t REG_DWORD /d "0" /f  
	Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableWindowsLocationProvider" /t REG_DWORD /d "1" /f  
	Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableLocationScripting" /t REG_DWORD /d "1" /f  
	Reg.exe add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Sensor\Permissions\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" /v "SensorPermissionState" /t REG_DWORD /d "0" /f  
	Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f  
	Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "DoNotShowFeedbackNotifications" /t REG_DWORD /d "1" /f  
	Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f  
	Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v "DODownloadMode" /t REG_DWORD /d "0" /f  
	Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization" /v "SystemSettingsDownloadMode" /t REG_DWORD /d "0" /f  
	Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Speech" /v "AllowSpeechModelUpdate" /t REG_DWORD /d "0" /f  
	Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DeferUpgrade" /t REG_DWORD /d "1" /f  
	Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DeferUpgradePeriod" /t REG_DWORD /d "1" /f  
	Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DeferUpdatePeriod" /t REG_DWORD /d "0" /f  
	Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" /v "PreventDeviceMetadataFromNetwork" /t REG_DWORD /d "1" /f  	
	Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsStore\WindowsUpdate" /v "AutoDownload" /t REG_DWORD /d "2" /f  
	Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoUpdate" /t REG_DWORD /d "1" /f  
	Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\wuauserv" /v "Start" /t REG_DWORD /d "3" /f  
	Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Services\7971f918-a847-4430-9279-4a52d1efe18d" /v "RegisteredWithAU" /t REG_DWORD /d "0" /f  
	Reg.exe add "HKLM\SOFTWARE\Microsoft\OneDrive" /v "PreventNetworkTrafficPreUserSignIn" /t REG_DWORD /d "1" /f  
	Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "SpyNetReporting" /t REG_DWORD /d "0" /f  
	Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "SubmitSamplesConsent" /t REG_DWORD /d "2" /f  
	Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\MRT" /v "DontReportInfectionInformation" /t REG_DWORD /d "1" /f  
	Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d "1" /f  
	Reg.exe add "HKCU\Software\Microsoft\Siuf\Rules" /v "NumberOfSIUFInPeriod" /t REG_DWORD /d "0" /f  
	Reg.exe add "HKCU\Software\Microsoft\Siuf\Rules" /v "PeriodInNanoSeconds" /t REG_DWORD /d "0" /f  
	Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled" /t REG_DWORD /d "0" /f  
	Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SilentInstalledAppsEnabled" /t REG_DWORD /d "0" /f  
	Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SoftLandingEnabled" /t REG_DWORD /d "0" /f
)>nul 2>&1 else (
    Reg delete "HKCU\Software\Hone" /v DebloatTweaks /f
    schtasks /Change /TN "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /Enable >nul 2>&1
    Reg.exe delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "Allow Telemetry" /f >nul 2>&1
    Reg.exe delete "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\AutoLogger-Diagtrack-Listener" /f >nul 2>&1
    Reg.exe delete "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility" /v "DiagnosticErrorText" /f >nul 2>&1
    Reg.exe delete "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Strings" /f >nul 2>&1
    Reg.exe delete "HKCU\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge" /f >nul 2>&1
    Reg.exe delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\TabletPC" /f >nul 2>&1
    Reg.exe delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\HandwritingErrorReports" /f >nul 2>&1
    Reg.exe delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /f >nul 2>&1
    Reg.exe delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Personalization" /f >nul 2>&1
    Reg.exe delete "HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Bluetooth" /f >nul 2>&1
    Reg.exe delete "HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\System" /f >nul 2>&1
    Reg.exe delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Messaging" /f >nul 2>&1
    Reg.exe delete "HKLM\SOFTWARE\Policies\Microsoft\Biometrics" /f >nul 2>&1
    Reg.exe delete "HKCU\Software\Microsoft\Windows\CurrentVersion\PushNotifications" /v "ToastEnabled" /f >nul 2>&1
    Reg.exe delete "HKCU\Control Panel\International\User Profile" /v "HttpAcceptLanguageOptOut" /f >nul 2>&1
    Reg.exe delete "HKCU\Software\Microsoft\Windows\CurrentVersion\AppHost" /v "EnableWebContentEvaluation" /f >nul 2>&1
    Reg.exe delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSyncProviderNotifications" /f >nul 2>&1
    Reg.exe delete "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v "GlobalUserDisabled" /f >nul 2>&1
    Reg.exe delete "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync" /v "SyncPolicy" /f >nul 2>&1
    Reg.exe delete "HKCU\Software\Microsoft\Windows\CurrentVersion\DeviceAccess" /f >nul 2>&1
    Reg.exe delete "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\AutoLogger-Diagtrack-Listener" /f >nul 2>&1
    Reg.exe delete "HKLM\SOFTWARE\Policies\Microsoft\WMDRM" /f >nul 2>&1
    Reg.exe delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\CredUI" /f >nul 2>&1
    Reg.exe delete "HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Browser" /f >nul 2>&1
    Reg.exe delete "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\BrowserSettings" /f >nul 2>&1
    Reg.exe delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /f >nul 2>&1
    Reg.exe delete "HKLM\SOFTWARE\Microsoft\Speech_OneCore\Preferences" /v "ModelDownloadAllowed" /f >nul 2>&1
    Reg.exe delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /f >nul 2>&1
    Reg.exe delete "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Sensor" /f >nul 2>&1
    Reg.exe delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /f >nul 2>&1
    Reg.exe delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "DoNotShowFeedbackNotifications" /f >nul 2>&1
    Reg.exe delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /f >nul 2>&1
    Reg.exe delete "HKCU\Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization" /f >nul 2>&1
    Reg.exe delete "HKLM\SOFTWARE\Policies\Microsoft\Speech" /f >nul 2>&1
    Reg.exe delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /f >nul 2>&1
    Reg.exe delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsStore" /f >nul 2>&1
    Reg.exe delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /f >nul 2>&1
    Reg.exe delete "HKLM\SOFTWARE\Microsoft\OneDrive" /f >nul 2>&1
    Reg.exe delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /f >nul 2>&1
    Reg.exe delete "HKLM\SOFTWARE\Policies\Microsoft\MRT" /f >nul 2>&1
    Reg.exe delete "HKCU\Software\Microsoft\Siuf" /f >nul 2>&1
    Reg.exe delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled" /f >nul 2>&1
    Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SilentInstalledAppsEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
    Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SoftLandingEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
    Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
    Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
    Reg.exe add "HKCU\Software\Microsoft\Input\TIPC" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
    Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\wuauserv" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
    Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Services\7971f918-a847-4430-9279-4a52d1efe18d" /v "RegisteredWithAU" /t REG_DWORD /d "0" /f >nul 2>&1
    Reg.exe add "HKCU\Software\Microsoft\Personalization\Settings" /v "AcceptedPrivacyPolicy" /t REG_DWORD /d "1" /f >nul 2>&1
    Reg.exe add "HKCU\Software\Microsoft\InputPersonalization" /v "RestrictImplicitTextCollection" /t REG_DWORD /d "0" /f >nul 2>&1
    Reg.exe add "HKCU\Software\Microsoft\InputPersonalization" /v "RestrictImplicitInkCollection" /t REG_DWORD /d "0" /f >nul 2>&1
    Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" /v "PreventDeviceMetadataFromNetwork" /t REG_DWORD /d "0" /f >nul 2>&1
    Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "1" /f >nul 2>&1
    Reg.exe add "HKLM\SOFTWARE\Microsoft\SQMClient\Windows" /v "CEIPEnable" /t REG_DWORD /d "0" /f >nul 2>&1
    Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_TrackProgs" /t REG_DWORD /d "0" /f >nul 2>&1
    Reg.exe add "HKCU\Software\Microsoft\InputPersonalization\TrainedDataStore" /v "HarvestContacts" /t REG_DWORD /d "1" /f >nul 2>&1
    Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\dmwappushservice" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
    Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\DiagTrack" /v "Start" /t REG_DWORD /d "2" /f >nul 2>&1
    Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Credentials" /v "Enabled" /t REG_DWORD /d "1" /f >nul 2>&1
    Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Language" /v "Enabled" /t REG_DWORD /d "1" /f >nul 2>&1
    Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Accessibility" /v "Enabled" /t REG_DWORD /d "1" /f >nul 2>&1
    Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Windows" /v "Enabled" /t REG_DWORD /d "1" /f >nul 2>&1
    Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Personalization" /v "Enabled" /t REG_DWORD /d "1" /f  
) >nul 2>&1
goto Tweaks

:Mitigations
if "%MITOF%" equ "%COL%[91mOFF" (
	Reg add "HKCU\Software\Hone" /v MitigationsTweaks /f
	::Turn Core Isolation Memory Integrity OFF
	Reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v "Enabled" /t REG_DWORD /d "0" /f
	::Disable SEHOP
	Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "DisableExceptionChainValidation" /t Reg_DWORD /d "1" /f
	::Disable Spectre And Meltdown
    Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettings" /t REG_DWORD /d "1" /f
    Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverride" /t REG_DWORD /d "3" /f
    Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverrideMask" /t REG_DWORD /d "3" /f
	cd %temp%
	if not exist "%temp%\NSudo.exe" curl -g -L -# -o "%temp%\NSudo.exe" "https://github.com/auraside/HoneCtrl/raw/main/Files/NSudo.exe"
	NSudo -U:S -ShowWindowMode:Hide -wait cmd /c "Reg add "HKLM\SYSTEM\CurrentControlSet\Services\TrustedInstaller" /v "Start" /t Reg_DWORD /d "3" /f"
	NSudo -U:S -ShowWindowMode:Hide -wait cmd /c "sc start "TrustedInstaller"
	NSudo -U:T -P:E -M:S -ShowWindowMode:Hide -wait cmd /c "ren %WinDir%\System32\mcupdate_GenuineIntel.dll mcupdate_GenuineIntel.old"
	NSudo -U:T -P:E -M:S -ShowWindowMode:Hide -wait cmd /c "ren %WinDir%\System32\mcupdate_AuthenticAMD.dll mcupdate_AuthenticAMD.old"
	::Disable CFG Lock
	Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "EnableCfg" /t Reg_DWORD /d "0" /f
	::Disable NTFS/ReFS and FS Mitigations
	Reg add "HKLM\System\CurrentControlSet\Control\Session Manager" /v "ProtectionMode" /t Reg_DWORD /d "0" /f
	::Disable System Mitigations
    for /f "tokens=3 skip=2" %%i in ('reg query "HKLM\System\CurrentControlSet\Control\Session Manager\kernel" /v "MitigationAuditOptions"') do set mitigation_mask=%%i
    for /l %%i in (0,1,9) do set mitigation_mask=!mitigation_mask:%%i=2!
    Reg add "HKLM\System\CurrentControlSet\Control\Session Manager\kernel" /v "MitigationOptions" /t REG_BINARY /d "!mitigation_mask!" /f
    Reg add "HKLM\System\CurrentControlSet\Control\Session Manager\kernel" /v "MitigationAuditOptions" /t REG_BINARY /d "!mitigation_mask!" /f
) >nul 2>&1 else (
	Reg delete "HKCU\Software\Hone" /v MitigationsTweaks /f
	::Turn Core Isolation Memory Integrity ON
	Reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v "Enabled" /t REG_DWORD /d "1" /f
	::Enable SEHOP
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "DisableExceptionChainValidation" /f
	::Enable Spectre And Meltdown
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v FeatureSettings /f
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v FeatureSettingsOverride /f
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v FeatureSettingsOverrideMask /f
	cd %temp%
	if not exist "%temp%\NSudo.exe" curl -g -L -# -o "%temp%\NSudo.exe" "https://github.com/auraside/HoneCtrl/raw/main/Files/NSudo.exe"
	NSudo -U:S -ShowWindowMode:Hide -wait cmd /c "Reg add "HKLM\SYSTEM\CurrentControlSet\Services\TrustedInstaller" /v "Start" /t Reg_DWORD /d "3" /f"
	NSudo -U:S -ShowWindowMode:Hide -wait cmd /c "sc start "TrustedInstaller"
	NSudo -U:T -P:E -M:S -ShowWindowMode:Hide -wait cmd /c "ren %WinDir%\System32\mcupdate_GenuineIntel.old mcupdate_GenuineIntel.dll"
	NSudo -U:T -P:E -M:S -ShowWindowMode:Hide -wait cmd /c "ren %WinDir%\System32\mcupdate_AuthenticAMD.old mcupdate_AuthenticAMD.dll"
	::Enable CFG Lock
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "EnableCfg" /f
	::Enable NTFS/ReFS and FS Mitigations
	Reg delete "HKLM\System\CurrentControlSet\Control\Session Manager" /v "ProtectionMode" /f
	::Disable System Mitigations
    Reg delete "HKLM\System\CurrentControlSet\Control\Session Manager\kernel" /v "MitigationOptions" /f
    Reg delete "HKLM\System\CurrentControlSet\Control\Session Manager\kernel" /v "MitigationAuditOptions" /f
) >nul 2>&1
goto Tweaks

:Mouse
cls
if "%MOUOF%" neq "%COL%[91mOFF" (
	Reg add "HKEY_CURRENT_USER\Control Panel\Mouse" /v "SmoothMouseXCurve" /t REG_BINARY /d "0000000000000000156e000000000000004001000000000029dc0300000000000000280000000000" /f >nul 2>&1
	Reg add "HKEY_CURRENT_USER\Control Panel\Mouse" /v "SmoothMouseYCurve" /t REG_BINARY /d "0000000000000000fd11010000000000002404000000000000fc12000000000000c0bb0100000000" /f >nul 2>&1
	goto Tweaks
)
echo what is your display scaling? 
echo go to settings , system , display , then type the scale percentage like 100, 125, 150
set /p choice=" Scale >  "
Reg add "HKCU\Control Panel\Mouse" /v "MouseSpeed" /t REG_SZ /d "0" /f >nul 2>&1
Reg add "HKCU\Control Panel\Mouse" /v "MouseThreshold1" /t REG_SZ /d "0" /f >nul 2>&1
Reg add "HKCU\Control Panel\Mouse" /v "MouseThreshold2" /t REG_SZ /d "0" /f >nul 2>&1
Reg add "HKCU\Control Panel\Mouse" /v "MouseSensitivity" /t REG_SZ /d "10" /f >nul 2>&1
Reg add "HKCU\Control Panel\Mouse" /v "SmoothMouseYCurve" /t REG_BINARY /d "0000000000000000000038000000000000007000000000000000A800000000000000E00000000000" /f >nul 2>&1
if /i "%choice%"=="100" Reg add "HKCU\Control Panel\Mouse" /v "SmoothMouseXCurve" /t REG_BINARY /d "0000000000000000C0CC0C0000000000809919000000000040662600000000000033330000000000" /f >nul 2>&1
if /i "%choice%"=="125" Reg add "HKCU\Control Panel\Mouse" /v "SmoothMouseXCurve" /t REG_BINARY /d "00000000000000000000100000000000000020000000000000003000000000000000400000000000" /f >nul 2>&1
if /i "%choice%"=="150" Reg add "HKCU\Control Panel\Mouse" /v "SmoothMouseXCurve" /t REG_BINARY /d "0000000000000000303313000000000060662600000000009099390000000000C0CC4C0000000000" /f >nul 2>&1
goto tweaks

:DisableHDCP
for /f %%a in ('Reg query "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /t REG_SZ /s /e /f "NVIDIA" ^| findstr "HKEY"') do (
if "%HDCOF%" equ "%COL%[91mOFF" (
	Reg add "HKCU\Software\Hone" /v HDCTweaks /f
	Reg add "%%a" /v "RMHdcpKeyglobZero" /t REG_DWORD /d "1" /f
) >nul 2>&1 else (
	Reg delete "HKCU\Software\Hone" /v HDCTweaks /f
	Reg add "%%a" /v "RMHdcpKeyglobZero" /t REG_DWORD /d "0" /f
) >nul 2>&1
)
goto Tweaks

:DisablePreemtion
if "%CMAOF%" equ "%COL%[91mOFF" (
	Reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisablePreemption" /t Reg_DWORD /d "1" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisableCudaContextPreemption" /t Reg_DWORD /d "1" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "EnableCEPreemption" /t Reg_DWORD /d "0" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisablePreemptionOnS3S4" /t Reg_DWORD /d "1" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "ComputePreemption" /t Reg_DWORD /d "0" /f
) >nul 2>&1 else (
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisablePreemption" /f
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisableCudaContextPreemption" /f
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "EnableCEPreemption" /f
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisablePreemptionOnS3S4" /f
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "ComputePreemption" /f
) >nul 2>&1
goto Tweaks

:ProfileInspector
if "%NPIOF%" equ "%COL%[91mOFF" (
	Reg add "HKCU\Software\Hone" /v NpiTweaks /f
	rmdir /S /Q "C:\Hone\Resources\nvidiaProfileInspector\"
	curl -g -L -# -o C:\Hone\Resources\nvidiaProfileInspector.zip "https://github.com/Orbmu2k/nvidiaProfileInspector/releases/latest/download/nvidiaProfileInspector.zip"
	powershell -NoProfile Expand-Archive 'C:\Hone\Resources\nvidiaProfileInspector.zip' -DestinationPath 'C:\Hone\Resources\nvidiaProfileInspector\'
	del /F /Q "C:\Hone\Resources\nvidiaProfileInspector.zip"
	curl -g -L -# -o "C:\Hone\Resources\nvidiaProfileInspector\Latency_and_Performances_Settings_by_Hone_Team2.nip" "https://raw.githubusercontent.com/auraside/HoneCtrl/main/Files/Latency_and_Performances_Settings_by_Hone_Team2.nip"
	cd "C:\Hone\Resources\nvidiaProfileInspector\"
	nvidiaProfileInspector.exe "Latency_and_Performances_Settings_by_Hone_Team2.nip" 
) >nul 2>&1 else (
::https://github.com/Orbmu2k/nvidiaProfileInspector/releases/latest/download/nvidiaProfileInspector.zip
	Reg delete "HKCU\Software\Hone" /v NpiTweaks /f
	rmdir /S /Q "C:\Hone\Resources\nvidiaProfileInspector\"
	curl -g -L -# -o C:\Hone\Resources\nvidiaProfileInspector.zip "https://github.com/Orbmu2k/nvidiaProfileInspector/releases/latest/download/nvidiaProfileInspector.zip"
	powershell -NoProfile Expand-Archive 'C:\Hone\Resources\nvidiaProfileInspector.zip' -DestinationPath 'C:\Hone\Resources\nvidiaProfileInspector\'
	del /F /Q "C:\Hone\Resources\nvidiaProfileInspector.zip"
	curl -g -L -# -o "C:\Hone\Resources\nvidiaProfileInspector\Base_Profile.nip" "https://raw.githubusercontent.com/auraside/HoneCtrl/main/Files/Base_Profile.nip"
	cd "C:\Hone\Resources\nvidiaProfileInspector\"
	nvidiaProfileInspector.exe "Base_Profile.nip"
) >nul 2>&1
goto Tweaks

:NVTelemetry
if "%NVTOF%" equ "%COL%[91mOFF" (
	Reg add "HKCU\Software\Hone" /v NVTTweaks /f
	Reg add "HKLM\SOFTWARE\NVIDIA Corporation\NvControlPanel2\Client" /v "OptInOrOutPreference" /t REG_DWORD /d 0 /f >nul 2>&1
	Reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID44231" /t REG_DWORD /d 0 /f >nul 2>&1
	Reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID64640" /t REG_DWORD /d 0 /f >nul 2>&1
	Reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID66610" /t REG_DWORD /d 0 /f >nul 2>&1
	Reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "NvBackend" /f >nul 2>&1
	schtasks /change /disable /tn "NvTmRep_CrashReport1_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" >nul 2>&1
	schtasks /change /disable /tn "NvTmRep_CrashReport2_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" >nul 2>&1
	schtasks /change /disable /tn "NvTmRep_CrashReport3_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" >nul 2>&1
	schtasks /change /disable /tn "NvTmRep_CrashReport4_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" >nul 2>&1
) >nul 2>&1 else (
	Reg delete "HKCU\Software\Hone" /f
	Reg delete "HKLM\SOFTWARE\NVIDIA Corporation\NvControlPanel2\Client" /v "OptInOrOutPreference" /f >nul 2>&1
	Reg delete "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID44231" /f >nul 2>&1
	Reg delete "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID64640" /f >nul 2>&1
	Reg delete "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID66610" /f >nul 2>&1
	schtasks /change /enable /tn "NvTmRep_CrashReport1_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" >nul 2>&1
	schtasks /change /enable /tn "NvTmRep_CrashReport2_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" >nul 2>&1
	schtasks /change /enable /tn "NvTmRep_CrashReport3_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" >nul 2>&1
	schtasks /change /enable /tn "NvTmRep_CrashReport4_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" >nul 2>&1
) >nul 2>&1
goto tweaks

:NvidiaTweaks
if "%NVIOF%" equ "%COL%[91mOFF" (
Reg add "HKCU\Software\Hone" /v "NvidiaTweaks" /f
::Nvidia Reg
Reg add "HKCU\Software\NVIDIA Corporation\Global\NVTweak\Devices\509901423-0\Color" /v "NvCplUseColorCorrection" /t Reg_DWORD /d "0" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "PlatformSupportMiracast" /t Reg_DWORD /d "0" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global\NVTweak" /v "DisplayPowerSaving" /t Reg_DWORD /d "0" /f
::Unrestricted Clocks
cd "%SystemDrive%\Program Files\NVIDIA Corporation\NVSMI\"
nvidia-smi -acp UNRESTRICTED >nul 2>&1
nvidia-smi -acp DEFAULT >nul 2>&1
::Nvidia Registry Key
for /f %%a in ('Reg query "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /t REG_SZ /s /e /f "NVIDIA" ^| findstr "HKEY"') do (
::Disalbe Tiled Display
Reg add "%%a" /v "EnableTiledDisplay" /t REG_DWORD /d "0" /f
::Disable TCC
Reg add "%%a" /v "TCCSupported" /t REG_DWORD /d "0" /f
)
::Silk Smoothness Option
Reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\FTS" /v "EnableRID61684" /t REG_DWORD /d "1" /f
) >nul 2>&1 else (
Reg delete "HKCU\Software\Hone" /v "NvidiaTweaks" /f
::Nvidia Reg
Reg delete "HKCU\Software\NVIDIA Corporation\Global\NVTweak\Devices\509901423-0\Color" /v "NvCplUseColorCorrection" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "PlatformSupportMiracast" /t Reg_DWORD /d "1" /f
Reg delete "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global\NVTweak" /v "DisplayPowerSaving" /f
::Nvidia Registry Key
for /f %%a in ('Reg query "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /t REG_SZ /s /e /f "NVIDIA" ^| findstr "HKEY"') do (
::Reset Tiled Display
Reg delete "%%a" /v "EnableTiledDisplay" /f
::Reset TCC
Reg delete "%%a" /v "TCCSupported" /f
) >nul 2>&1
) >nul 2>&1
goto Tweaks

:DisableWriteCombining
if "%DWCOF%" equ "%COL%[91mOFF" (
Reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisableWriteCombining" /t Reg_DWORD /d "1" /f
) >nul 2>&1 else (
Reg delete "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisableWriteCombining" /f
) >nul 2>&1

:Service
if "%SERVOF%" equ "%COL%[91mOFF" (
    Reg add "HKCU\Software\Hone" /v ServicesTweaks /f
	Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\xbgm" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
	Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\XboxGipSvc" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
	Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WaaSMedicSvc" /v "Start" /t REG_DWORD /d "4" /f 
	Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time" /v "Start" /t REG_DWORD /d "4" /f  
	Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\spectrum" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
	Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\wcncsvc" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
	Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WebClient" /v "Start" /t REG_DWORD /d "4" /f 
	Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SysMain" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
	Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NcaSvc" /v "Start" /t REG_DWORD /d "4" /f  
	Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\diagsvc" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
	Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\UserDataSvc" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
	Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\stisvc" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
	Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\AdobeFlashPlayerUpdateSvc" /v "Start" /t REG_DWORD /d "4" /f 
	Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\TrkWks" /v "Start" /t REG_DWORD /d "4" /f 
	Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\dmwappushservice" /v "Start" /t REG_DWORD /d "4" /f   
	Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\PimIndexMaintenanceSvc" /v "Start" /t REG_DWORD /d "4" /f   
	Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\DiagTrack" /v "Start" /t REG_DWORD /d "4" /f 
	Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\GoogleChromeElevationService" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
	Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\OneSyncSvc" /v "Start" /t REG_DWORD /d "4" /f 
	Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\ibtsiva" /v "Start" /t REG_DWORD /d "4" /f  
	Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SNMPTRAP" /v "Start" /t REG_DWORD /d "4" /f   	
	Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\pla" /v "Start" /t REG_DWORD /d "4" /f 
	Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\ssh-agent" /v "Start" /t REG_DWORD /d "4" /f   
	Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\sshd" /v "Start" /t REG_DWORD /d "4" /f  
	Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\DoSvc" /v "Start" /t REG_DWORD /d "4" /f    
	Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WbioSrvc" /v "Start" /t REG_DWORD /d "4" /f  
	Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\PcaSvc" /v "Start" /t REG_DWORD /d "4" /f  
	Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NetTcpPortSharing" /v "Start" /t REG_DWORD /d "4" /f  
	Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\wersvc" /v "Start" /t REG_DWORD /d "4" /f   
	Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\gupdate" /v "Start" /t REG_DWORD /d "4" /f   
	Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\gupdatem" /v "Start" /t REG_DWORD /d "4" /f  
	Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\MSiSCSI" /v "Start" /t REG_DWORD /d "4" /f  
	Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WMPNetworkSvc" /v "Start" /t REG_DWORD /d "4" /f  
	Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\CDPUserSvc" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
	Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanWorkstation" /v "Start" /t REG_DWORD /d "4" /f   
	Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\UnistoreSvc" /v "Start" /t REG_DWORD /d "4" /f 
	Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\MapsBroker" /v "Start" /t REG_DWORD /d "4" /f  
	Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\debugregsvc" /v "Start" /t REG_DWORD /d "4" /f  
	Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Ndu" /v "Start" /d "2" /t REG_DWORD /f  
	Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\TimeBrokerSvc" /v "Start" /d "3" /t REG_DWORD /f 
	Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\VaultSvc" /v "Start" /t REG_DWORD /d "3" /f 
	Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\wuauserv" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
	Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\CertPropSvc" /v "Start" /t REG_DWORD /d "3" /f   
	)>nul 2>&1 else (
    Reg delete "HKCU\Software\Hone" /v ServicesTweaks /f   
    Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\xbgm" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
    Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\XboxGipSvc" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
    Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WaaSMedicSvc" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
    Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\wuauserv" /v "Start" /t REG_DWORD /d "3" /f 
    Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time" /v "Start" /t REG_DWORD /d "3" /f  
    Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\spectrum" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
    Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\wcncsvc" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
    Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WebClient" /v "Start" /t REG_DWORD /d "3" /f 
    Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SysMain" /v "Start" /t REG_DWORD /d "2" /f >nul 2>&1
    Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NcaSvc" /v "Start" /t REG_DWORD /d "3" /f  
    Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\AdobeFlashPlayerUpdateSvc" /v "Start" /t REG_DWORD /d "3" /f 
    Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\GoogleChromeElevationService" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
    Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\TrkWks" /v "Start" /t REG_DWORD /d "3" /f 
    Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\ibtsiva" /v "Start" /t REG_DWORD /d "3" /f  
    Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\sshd" /v "Start" /t REG_DWORD /d "3" /f 
    Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\gupdate" /v "Start" /t REG_DWORD /d "2" /f   
    Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\gupdatem" /v "Start" /t REG_DWORD /d "3" /f  
    Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\PimIndexMaintenanceSvc" /v "Start" /t REG_DWORD /d "3" /f  
    Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\diagsvc" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
    Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\UserDataSvc" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
    Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\stisvc" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
    Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\dmwappushservice" /v "Start" /t REG_DWORD /d "3" /f   
    Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\DiagTrack" /v "Start" /t REG_DWORD /d "2" /f 
    Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\VaultSvc" /v "Start" /t REG_DWORD /d "3" /f  
    Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\OneSyncSvc" /v "Start" /t REG_DWORD /d "2" /f 
    Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SNMPTRAP" /v "Start" /t REG_DWORD /d "3" /f   
    Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\pla" /v "Start" /t REG_DWORD /d "3" /f 
    Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\ssh-agent" /v "Start" /t REG_DWORD /d "3" /f   
    Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\DoSvc" /v "Start" /t REG_DWORD /d "2" /f   
    Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\CertPropSvc" /v "Start" /t REG_DWORD /d "3" /f   
    Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WbioSrvc" /v "Start" /t REG_DWORD /d "3" /f  
    Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\PcaSvc" /v "Start" /t REG_DWORD /d "2" /f  
    Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NetTcpPortSharing" /v "Start" /t REG_DWORD /d "4" /f  
    Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\wersvc" /v "Start" /t REG_DWORD /d "3" /f   
    Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\MSiSCSI" /v "Start" /t REG_DWORD /d "3" /f  
    Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WMPNetworkSvc" /v "Start" /t REG_DWORD /d "3" /f  
    Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\CDPUserSvc" /v "Start" /t REG_DWORD /d "2" /f >nul 2>&1
    Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WpnUserService" /v "Start" /t REG_DWORD /d "2" /f 
    Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanWorkstation" /v "Start" /t REG_DWORD /d "2" /f   
    Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\UnistoreSvc" /v "Start" /t REG_DWORD /d "3" /f 
    Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\MapsBroker" /v "Start" /t REG_DWORD /d "2" /f  
    Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\debugregsvc" /v "Start" /t REG_DWORD /d "3" /f  
    Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Ndu" /v "Start" /d "2" /t REG_DWORD /f  
    Reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\TimeBrokerSvc" /v "Start" /d "3" /t REG_DWORD /f 
)>nul 2>&1	
goto tweaks

:Affinity
if "%AFFOF%" neq "%COL%[91mOFF" (
	Reg delete "HKCU\Software\Hone" /v AffinityTweaks /f >nul 2>&1
	for /f %%i in ('wmic path Win32_USBController get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
		Reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /f >nul 2>&1
		Reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /f >nul 2>&1
	)
	for /f %%i in ('wmic path Win32_VideoController get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
		Reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /f >nul 2>&1
		Reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /f >nul 2>&1
	)
	for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
		Reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /f >nul 2>&1
		Reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /f >nul 2>&1
	)
goto Tweaks
)

Reg add "HKCU\Software\Hone" /v AffinityTweaks /f >nul 2>&1
for /f "tokens=*" %%f in ('wmic cpu get NumberOfCores /value ^| find "="') do set %%f
for /f "tokens=*" %%f in ('wmic cpu get NumberOfLogicalProcessors /value ^| find "="') do set %%f

if "%NumberOfCores%"=="2" (cls
	echo you have 2 cores, affinity won't work!
	pause && goto Tweaks
)

if %NumberOfCores% gtr 4 (
	for /f %%i in ('wmic path Win32_VideoController get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
		Reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /t REG_DWORD /d "3" /f >nul 2>&1
		Reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /f >nul 2>&1
	)
	for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
		Reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /t REG_DWORD /d "5" /f >nul 2>&1
		Reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /f >nul 2>&1
	)
	goto Tweaks
)

if %NumberOfLogicalProcessors% gtr %NumberOfCores% (
::HyperThreading Enabled
	for /f %%i in ('wmic path Win32_USBController get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
		Reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /t REG_DWORD /d "4" /f >nul 2>&1
		Reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /t REG_BINARY /d "C0" >nul 2>&1
	)
	for /f %%i in ('wmic path Win32_VideoController get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
		Reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /t REG_DWORD /d "4" /f >nul 2>&1
		Reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /t REG_BINARY /d "C0" /f >nul 2>&1
	)
	for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
		Reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /t REG_DWORD /d "4" /f >nul 2>&1
		Reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /t REG_BINARY /d "30" /f >nul 2>&1
	)
) else (
::HyperThreading Disabled
	for /f %%i in ('wmic path Win32_USBController get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
		Reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /t REG_DWORD /d "4" /f >nul 2>&1
		Reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /t REG_BINARY /d "08" /f >nul 2>&1
	)
	for /f %%i in ('wmic path Win32_VideoController get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
		Reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /t REG_DWORD /d "4" /f >nul 2>&1
		Reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /t REG_BINARY /d "02" /f >nul 2>&1
	)
	for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
		Reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /t REG_DWORD /d "4" /f >nul 2>&1
		Reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /t REG_BINARY /d "04" /f >nul 2>&1
	)
)
goto Tweaks

:W32PrioSep
cls
echo.
echo.
echo.
echo.
echo.                                                                          %COL%[33m.  
echo.                                                                       +N. 
echo.                                                              //        oMMs 
echo.                                                             +Nm`    ``yMMm- 
echo.                                                          ``dMMsoyhh-hMMd.  
echo.                                                          `yy/MMMMNh:dMMh`   
echo.                                                         .hMM.sso++:oMMs`    
echo.                                                        -mMMy:osyyys.No      
echo.                                                       :NMMs-oo+/syy:-       
echo.                                                      /NMN+ ``   :ys.        
echo.                                                     `NMN:        +.         
echo.                                                     om-                    
echo.                                                      `.                                            
echo. 
echo. 
echo. 
echo.
echo.
echo.
echo.
echo.
echo                    %COL%[33m[ %COL%[37m1 %COL%[33m] %COL%[37m16 Hex                                                  %COL%[33m[ %COL%[37m2 %COL%[33m] %COL%[37m28 Hex
echo                    %COL%[90mBest FPS                                                      %COL%[90mBest 1%% lows
echo                    %COL%[90mLong, Variable, High foreground boost.                        %COL%[90mShort, Fixed, No foreground boost.
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
choice /c:12X /n /m "%DEL%                                                               >:"
if %errorlevel% equ 3 goto Tweaks
if %errorlevel% equ 1 reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d "22" /f >nul 2>&1
if %errorlevel% equ 2 reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d "40" /f >nul 2>&1
goto Tweaks

:MemOptimization
if "%ME2OF%" equ "%COL%[91mOFF" (
	Reg add "HKCU\Software\Hone" /v "MemoryTweaks" /f
	::Disable Background apps
	Reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v "GlobalUserDisabled" /t Reg_DWORD /d "1" /f
	Reg add "HKLM\Software\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsRunInBackground" /t Reg_DWORD /d "2" /f
	Reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "BackgroundAppGlobalToggle" /t Reg_DWORD /d "0" /f
	::Disallow drivers to get paged into virtual memory
	Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t Reg_DWORD /d "1" /f
	::Disable Page Combining and Memory Compression
	powershell -NoProfile -Command "Disable-MMAgent -PagingCombining -mc"
	::Use Large System Cache to improve microstuttering
	Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "LargeSystemCache" /t Reg_DWORD /d "1" /f
	::Free unused ram
	Reg add "HKLM\System\CurrentControlSet\Control\Session Manager" /v "HeapDeCommitFreeBlockThreshold" /t REG_DWORD /d "262144" /f
	::Auto restart Powershell on error
	Reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "AutoRestartShell" /t REG_DWORD /d "1" /f
	::Disk Optimizations
	Reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "DontVerifyRandomDrivers" /t REG_DWORD /d "1" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "LongPathsEnabled" /t REG_DWORD /d "0" /f
	::Disable Prefetch and Superfetch
	Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /t Reg_DWORD /d "0" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableSuperfetch" /t Reg_DWORD /d "0" /f
	::Disable Hibernation + Fast Startup
	Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d "0" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "HibernateEnabledDefault" /t REG_DWORD /d "0" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "HibernateEnabled" /t REG_DWORD /d "0" /f
	::Wait time to kill app during shutdown
	Reg add "HKCU\Control Panel\Desktop" /v "WaitToKillAppTimeout" /t Reg_SZ /d "1000" /f
	::Wait to end service at shutdown
	Reg add "HKLM\System\CurrentControlSet\Control" /v "WaitToKillServiceTimeout" /t Reg_SZ /d "1000" /f
	::Wait to kill non-responding app
	Reg add "HKCU\Control Panel\Desktop" /v "HungAppTimeout" /t Reg_SZ /d "1000" /f
	::fsutil
	if exist "%windir%\System32\fsutil.exe" (
		::Raise the limit of paged pool memory
		fsutil behavior set memoryusage 2
		::https://www.serverbrain.org/solutions-2003/the-mft-zone-can-be-optimized.html
		fsutil behavior set mftzone 2
		::Disable Last Access information on directories, performance/privacy
		fsutil behavior set disablelastaccess 1
		::Disable Virtual Memory Pagefile Encryption
		fsutil behavior set encryptpagingfile 0
		::Disables the creation of legacy 8.3 character-length file names on FAT- and NTFS-formatted volumes.
		fsutil behavior set disable8dot3 1
		::Disable NTFS compression
		fsutil behavior set disablecompression 1
		::Enable Trim
		fsutil behavior set disabledeletenotify 0
	)
) >nul 2>&1 else (
	Reg delete "HKCU\Software\Hone" /v MemoryTweaks /f
	::Enable Background apps
	Reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v "GlobalUserDisabled" /f
	Reg delete "HKLM\Software\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsRunInBackground" /f
	Reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "BackgroundAppGlobalToggle" /f
	::Disallow drivers to get paged into virtual memory
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /f
	::Enable Page Combining and memory compression
	powershell -NoProfile -Command "Enable-MMAgent -PagingCombining -mc"
	::Use Large System Cache to improve microstuttering
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "LargeSystemCache" /f
	::Don't free unused ram
	Reg delete "HKLM\System\CurrentControlSet\Control\Session Manager" /v "HeapDeCommitFreeBlockThreshold" /f
	::Don't restart Powershell on error
	Reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "AutoRestartShell" /t REG_DWORD /d "0" /f
	::Disk Optimizations
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "DontVerifyRandomDrivers" /f
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "LongPathsEnabled" /f
	::Enable Prefetch
	Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /t Reg_DWORD /d "3" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableSuperfetch" /t Reg_DWORD /d "3" /f
	::Background Apps
	Reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v "GlobalUserDisabled" /t Reg_DWORD /d "0" /f
	Reg delete "HKLM\Software\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsRunInBackground" /f
	Reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "BackgroundAppGlobalToggle" /t Reg_DWORD /d "1" /f
	::Hibernation + Fast Startup
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "HiberbootEnabled" /f
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "HibernateEnabledDefault" /f
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "HibernateEnabled" /f
	::Wait time to kill app during shutdown
	Reg add "HKCU\Control Panel\Desktop" /v "WaitToKillAppTimeout" /t Reg_SZ /d "20000" /f
	::Wait to end service at shutdown
	Reg add "HKLM\System\CurrentControlSet\Control" /v "WaitToKillServiceTimeout" /t Reg_SZ /d "20000" /f
	::Wait to kill non-responding app
	Reg add "HKCU\Control Panel\Desktop" /v "HungAppTimeout" /t Reg_SZ /d "5000" /f
	::fsutil
	if exist "%windir%\System32\fsutil.exe" (
		::Set default limit of paged pool memory
		fsutil behavior set memoryusage 1
		::https://www.serverbrain.org/solutions-2003/the-mft-zone-can-be-optimized.html
		fsutil behavior set mftzone 1
		::Default Last Access information on directories, performance/privacy value
		fsutil behavior set disablelastaccess 2
		::Default Virtual Memory Pagefile Encryption value
		fsutil behavior set encryptpagingfile 0
		::Default creation of legacy 8.3 character-length file names on FAT- and NTFS-formatted volumes value
		fsutil behavior set disable8dot3 1
		::Default NTFS compression
		fsutil behavior set disablecompression 0
		::Enable Trim
		fsutil behavior set disabledeletenotify 0
	)
) >nul 2>&1
call :HoneCtrlRestart "Memory Optimization" "%ME2OF%"
goto Tweaks

:CSRSS
if "%CRSOF%" equ "%COL%[91mOFF" (
	Reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\csrss.exe\PerfOptions" /v CpuPriorityClass /t Reg_DWORD /d "4" /f
	Reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\csrss.exe\PerfOptions" /v IoPriority /t Reg_DWORD /d "3" /f
	Reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NoLazyMode" /t REG_DWORD /d "1" /f
	Reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "AlwaysOn" /t REG_DWORD /d "1" /f
	Reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d "10" /f
	Reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d "10" /f
) >nul 2>&1 else (
	Reg delete "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\csrss.exe\PerfOptions" /v CpuPriorityClass /f
	Reg delete "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\csrss.exe\PerfOptions" /v IoPriority /f
	Reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NoLazyMode" /f
	Reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "AlwaysOn" /f
	Reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /f
	Reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /f
) >nul 2>&1
goto Tweaks

::Disable FTH
Reg add "HKLM\Software\Microsoft\FTH\State" /f 
Reg delete "HKLM\Software\Microsoft\FTH\State" /f 
Reg add "HKLM\Software\Microsoft\FTH" /v "Enabled" /t Reg_DWORD /d "0" /f 

::System responsiveness, PanTeR Said to use 14 (20 hexa)
Reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t Reg_DWORD /d "20" /f 

::Disable Power Throttling
Reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /f 
::Enable Power Throttling If Laptop
for /f "tokens=2 delims={}" %%n in ('wmic path Win32_SystemEnclosure get ChassisTypes /value') do set /a ChassisTypes=%%n
if defined ChassisTypes if %ChassisTypes% GEQ 8 if %ChassisTypes% LSS 12 (
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /t Reg_DWORD /d "1" /f 
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /f 
)

::::::::::::::::::::::
::GPU  Optimizations::
::::::::::::::::::::::

::Reliable Timestamp
Reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Reliability" /v "TimeStampInterval" /t Reg_DWORD /d "1" /f 
Reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Reliability" /v "IoPriority" /t Reg_DWORD /d "3" /f 

:MMCSS
Reg add "HKLM\SYSTEM\CurrentControlSet\Services\MMCSS" /v "Start" /t Reg_DWORD /d "4" /f >nul 2>&1
::Old MMCSS
::Reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t Reg_DWORD /d "8" /f
::Reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t Reg_DWORD /d "6" /f
::Reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t Reg_SZ /d "High" /f
::Reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "SFIO Priority" /t Reg_SZ /d "High" /f

:HoneRenders
::Detect encoder for obs, blur, and ffmpeg settings
for /F "tokens=* skip=1" %%n in ('WMIC path Win32_VideoController get Name ^| findstr "."') do set GPU_NAME=%%n
echo %GPU_NAME% | find "NVIDIA" && set encoder=NVENC >nul 2>&1
echo %GPU_NAME% | find "AMD" && set encoder=AMF >nul 2>&1
if not defined GPU_NAME set encoder=CPU

cls
color 06
echo.
echo.
echo.                                      %COL%[33m+N.
echo.                           //        oMMs         
echo.                          +Nm`    ``yMMm-     ::::::::     ::::    :::    :::::::::: 
echo.                       ``dMMsoyhh-hMMd.     :+:    :+:    :+:+:   :+:    :+:  
echo.                       `yy/MMMMNh:dMMh`    +:+    +:+    :+:+:+  +:+    +:+                 +::+:+::      +::+:+::
echo.                      .hMM.sso++:oMMs`    +#+    +:+    +#+ +:+ +#+    +#++:++#           ++:    #++    ++:    #++
echo.                     -mMMy:osyyys.No     +#+    +#+    +#+  +#+#+#    +#+                +#+    +#+    +#+    +#+
echo.                    :NMMs-oo+/syy:-     #+#    #+#    #+#   #+#+#    #+#          %COL%[37m#+#%COL%[33m    +#+   #+#     #+#   #+#
echo.                   /NMN+ ``   :ys.      ########     ###    ####    ##########   %COL%[37m###%COL%[33m       ######        ######
echo.                  `NMN:        +.                                                      ##    ###     ##    ###
echo.                  om-                                                                   #######       #######
echo.                   `.                                      %COL%[34m%COL%[1mOBS Settings%COL%[0m
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
echo                                                            %COL%[34m%COL%[1mBlur Settings%COL%[0m
echo.
echo              %COL%[33m[ %COL%[37m7 %COL%[33m]%COL%[37m Install/Update Blur            %COL%[33m[ %COL%[37m8 %COL%[33m]%COL%[37m FPS Games                      %COL%[33m[ %COL%[37m9 %COL%[33m]%COL%[37m Minecraft
echo              %COL%[90mAutomatically install or update      %COL%[90mAutomated Blur settings for          %COL%[90mBlur settings for games
echo              %COL%[90mBlur using the official link         %COL%[90mfirst person shooter games           %COL%[90mrecorded in extremely high fps
echo.
echo.
echo                                                            %COL%[34m%COL%[1mVegas Settings%COL%[0m
echo.
echo              %COL%[33m[ %COL%[37m10 %COL%[33m]%COL%[37m Project Settings              %COL%[33m[ %COL%[37m11 %COL%[33m]%COL%[37m Renders                       %COL%[33m[ %COL%[37m12 %COL%[33m]%COL%[37m Install Vegas
echo              %COL%[90mBest project settings for Vegas      %COL%[90mAuto render settings for Vegas       %COL%[90mDownload ^& Install Vegas Pro
echo.
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
if /i "%choice%"=="10" goto ProjectSettings
if /i "%choice%"=="11" goto RenderSettings
if /i "%choice%"=="12" goto VegasInstall
if /i "%choice%"=="B" goto MainMenu
if /i "%choice%"=="X" exit /b
goto HoneRenders

:OBSInstall
:: Delete old OBS
if exist "%SystemDrive%\Program Files\obs-studio\uninstall.exe" start /w "" "%SystemDrive%\Program Files\obs-studio\uninstall.exe" /S >nul 2>&1
rmdir /s /q "%appdata%\obs-studio" >nul 2>&1

:: get url to OBS
for /f "skip=147 tokens=2" %%I in ('curl -s https://obsproject.com/') do set "OBS=%%I" & goto end
:end
:: Install OBS Silently
curl -g -L -# -o "%temp%\OBS.exe" "%OBS:~6,84%"
start "" /D "%temp%" OBS -s
goto:eof

:Recording
cls
color 06
echo.
echo.
echo.                                      %COL%[33m+N.
echo.                           //        oMMs         
echo.                          +Nm`    ``yMMm-     ::::::::     ::::    :::    :::::::::: 
echo.                       ``dMMsoyhh-hMMd.     :+:    :+:    :+:+:   :+:    :+:  
echo.                       `yy/MMMMNh:dMMh`    +:+    +:+    :+:+:+  +:+    +:+                 +::+:+::      +::+:+::
echo.                      .hMM.sso++:oMMs`    +#+    +:+    +#+ +:+ +#+    +#++:++#           ++:    #++    ++:    #++
echo.                     -mMMy:osyyys.No     +#+    +#+    +#+  +#+#+#    +#+                +#+    +#+    +#+    +#+
echo.                    :NMMs-oo+/syy:-     #+#    #+#    #+#   #+#+#    #+#          %COL%[37m#+#%COL%[33m    +#+   #+#     #+#   #+#
echo.                   /NMN+ ``   :ys.      ########     ###    ####    ##########   %COL%[37m###%COL%[33m       ######        ######
echo.                  `NMN:        +.                                                      ##    ###     ##    ###
echo.                  om-                                                                   #######       #######
echo.                   `.
echo.
echo              %COL%[33m[ %COL%[37m1 %COL%[33m]%COL%[37m Quality                        %COL%[33m[ %COL%[37m2 %COL%[33m]%COL%[37m Optimal                        %COL%[33m[ %COL%[37m3 %COL%[33m]%COL%[37m Performance
echo              %COL%[90mSettings for the best                %COL%[90mThe best for performance             %COL%[90mSettings for the best
echo              %COL%[90mquality in OBS                       %COL%[90mwithout losing any quality           %COL%[90mperformance in OBS
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
if not exist "%SystemDrive%\Program Files\obs-studio\bin\64bit" call:OBSInstall
IF %encoder% equ NVENC (
	cd "%SystemDrive%\Program Files\obs-studio\bin\64bit"
	if not exist "%appdata%\obs-studio\basic\profiles\Untitled\basic.ini" start obs64.exe
	taskkill /f /im obs64.exe >nul 2>&1
	Reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "%SystemDrive%\Program Files\obs-studio\bin\64bit\obs64.exe" /t Reg_SZ /d "~ RUNASADMIN" /f >nul 2>&1
	cls & set /p FPS="What FPS would you like to record in? >: "
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
		"BaseCX=1920"
		"BaseCY=1080"
		"OutputCX=1920"
		"OutputCY=1080"
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
	) do echo.%%~i)>"%temp%\Basic.ini"
	echo.{"bf":0,"cqp":17,"keyint_sec":0,"lookahead":"false","preset":"hp","profile":"baseline","psycho_aq":"false","rate_control":"CQP"} >"%temp%\RecordEncoder.json"
	move /Y "%temp%\basic.ini" "%appdata%\obs-studio\basic\profiles\Untitled\" 
	move /Y "%temp%\RecordEncoder.json" "%appdata%\obs-studio\basic\profiles\Untitled\"
	goto Recording
) ELSE (
	echo amd settings are not yet made!
	timeout 3 /nobreak
	goto Recording
)

:Optimal
if not exist "%SystemDrive%\Program Files\obs-studio\bin\64bit" call:OBSInstall
IF %encoder% equ NVENC (
	cd "%SystemDrive%\Program Files\obs-studio\bin\64bit"
	taskkill /f /im obs64.exe >nul 2>&1
	Reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "%SystemDrive%\Program Files\obs-studio\bin\64bit\obs64.exe" /t Reg_SZ /d "~ RUNASADMIN" /f >nul 2>&1
	cls & set /p FPS="What FPS would you like to record in? >: "
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
		"BaseCX=1920"
		"BaseCY=1080"
		"OutputCX=1920"
		"OutputCY=1080"
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

	) do echo.%%~i)> "%temp%\Basic.ini"
	echo.{"bf":0,"cqp":18,"keyint_sec":0,"lookahead":"false","preset":"hp","profile":"baseline","psycho_aq":"false","rate_control":"CQP"} >"%temp%\RecordEncoder.json"
	move /Y "%temp%\basic.ini" "%appdata%\obs-studio\basic\profiles\Untitled\" 
	move /Y "%temp%\RecordEncoder.json" "%appdata%\obs-studio\basic\profiles\Untitled\"
	goto Recording
) ELSE (
	echo amd settings are not yet made!
	timeout 3 /nobreak
	goto recording
)

:Performance
if not exist "%SystemDrive%\Program Files\obs-studio\bin\64bit" call:OBSInstall
IF %encoder% equ NVENC (
	cd "%SystemDrive%\Program Files\obs-studio\bin\64bit"
	taskkill /f /im obs64.exe >nul 2>&1
	Reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "%SystemDrive%\Program Files\obs-studio\bin\64bit\obs64.exe" /t Reg_SZ /d "~ RUNASADMIN" /f >nul 2>&1
	cls & set /p FPS="What FPS would you like to record in? >: "
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
		"BaseCX=1920"
		"BaseCY=1080"
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

	) do echo.%%~i)> "%temp%\Basic.ini"
	echo.{"bf":0,"cqp":18,"keyint_sec":0,"lookahead":"false","preset":"hp","profile":"baseline","psycho_aq":"false","rate_control":"CQP"} >"%temp%\RecordEncoder.json"
	move /Y "%temp%\basic.ini" "%appdata%\obs-studio\basic\profiles\Untitled\" 
	move /Y "%temp%\RecordEncoder.json" "%appdata%\obs-studio\basic\profiles\Untitled\"
	goto Recording
) ELSE (
	echo amd settings are not yet made!
	timeout 3 /nobreak
	goto recording
)


:Streaming
cls
color 06
echo.
echo.
echo.                                      %COL%[33m+N.
echo.                           //        oMMs         
echo.                          +Nm`    ``yMMm-     ::::::::     ::::    :::    :::::::::: 
echo.                       ``dMMsoyhh-hMMd.     :+:    :+:    :+:+:   :+:    :+:  
echo.                       `yy/MMMMNh:dMMh`    +:+    +:+    :+:+:+  +:+    +:+                 +::+:+::      +::+:+::
echo.                      .hMM.sso++:oMMs`    +#+    +:+    +#+ +:+ +#+    +#++:++#           ++:    #++    ++:    #++
echo.                     -mMMy:osyyys.No     +#+    +#+    +#+  +#+#+#    +#+                +#+    +#+    +#+    +#+
echo.                    :NMMs-oo+/syy:-     #+#    #+#    #+#   #+#+#    #+#          %COL%[37m#+#%COL%[33m    +#+   #+#     #+#   #+#
echo.                   /NMN+ ``   :ys.      ########     ###    ####    ##########   %COL%[37m###%COL%[33m       ######        ######
echo.                  `NMN:        +.                                                      ##    ###     ##    ###
echo.                  om-                                                                   #######       #######
echo.                   `.
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
if not exist "%SystemDrive%\Program Files\obs-studio\bin\64bit" call:OBSInstall
IF %encoder% equ NVENC (
	cd "%SystemDrive%\Program Files\obs-studio\bin\64bit"
	taskkill /f /im obs64.exe >nul 2>&1
	Reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "%SystemDrive%\Program Files\obs-studio\bin\64bit\obs64.exe" /t Reg_SZ /d "~ RUNASADMIN" /f >nul 2>&1
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
		"BaseCX=1920"
		"BaseCY=1080"
		"OutputCX=1920"
		"OutputCY=1080"
		"FPSDen=1"
		"FPSType=2"
		"ScaleType=bilinear"
		"FPSNum=60"
		"ColorSpace=sRGB"
		"ColorRange=Full"
		.
		"[Output]"
		"RecType=Standard"
		"Mode=Advanced"
	) do echo.%%~i)> "%temp%\Basic.ini"
	echo.{"bitrate":6000,"preset":"hp","profile":"baseline","rate_control":"CBR"} >"%temp%\StreamEncoder.json"
	move /Y "%temp%\basic.ini" "%appdata%\obs-studio\basic\profiles\Untitled\" 
	move /Y "%temp%\StreamEncoder.json" "%appdata%\obs-studio\basic\profiles\Untitled\"
	goto Streaming
) ELSE (
	echo amd settings are not yet made!
	timeout 3 /nobreak
	goto Streaming
)

:Performance
if not exist "%SystemDrive%\Program Files\obs-studio\bin\64bit" call:OBSInstall
IF %encoder% equ NVENC (
	cd "%SystemDrive%\Program Files\obs-studio\bin\64bit"
	taskkill /f /im obs64.exe >nul 2>&1
	Reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "%SystemDrive%\Program Files\obs-studio\bin\64bit\obs64.exe" /t Reg_SZ /d "~ RUNASADMIN" /f >nul 2>&1
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
		"BaseCX=1920"
		"BaseCY=1080"
		"OutputCX=1920"
		"OutputCY=1080"
		"FPSDen=1"
		"FPSType=2"
		"ScaleType=bilinear"
		"FPSNum=60"
		"ColorSpace=sRGB"
		"ColorRange=Partial"
		.
		"[Output]"
		"RecType=Standard"
		"Mode=Advanced"
	) do echo.%%~i)> "%temp%\Basic.ini"
	echo.{"bitrate":4500,"preset":"hp","profile":"baseline","rate_control":"CBR"} >"%temp%\StreamEncoder.json"
	move /Y "%temp%\basic.ini" "%appdata%\obs-studio\basic\profiles\Untitled\" 
	move /Y "%temp%\StreamEncoder.json" "%appdata%\obs-studio\basic\profiles\Untitled\"
	goto Streaming
) ELSE (
	echo amd settings are not yet made!
	timeout 3 /nobreak
	goto streaming
)

:upscale
if not exist %SystemDrive%\ffmpeg ( call:ffmpeginstall )
cls
color 06
echo.
echo.
echo.                                      %COL%[33m+N.
echo.                           //        oMMs         
echo.                          +Nm`    ``yMMm-     ::::::::     ::::    :::    :::::::::: 
echo.                       ``dMMsoyhh-hMMd.     :+:    :+:    :+:+:   :+:    :+:  
echo.                       `yy/MMMMNh:dMMh`    +:+    +:+    :+:+:+  +:+    +:+                 +::+:+::      +::+:+::
echo.                      .hMM.sso++:oMMs`    +#+    +:+    +#+ +:+ +#+    +#++:++#           ++:    #++    ++:    #++
echo.                     -mMMy:osyyys.No     +#+    +#+    +#+  +#+#+#    +#+                +#+    +#+    +#+    +#+
echo.                    :NMMs-oo+/syy:-     #+#    #+#    #+#   #+#+#    #+#          %COL%[37m#+#%COL%[33m    +#+   #+#     #+#   #+#
echo.                   /NMN+ ``   :ys.      ########     ###    ####    ##########   %COL%[37m###%COL%[33m       ######        ######
echo.                  `NMN:        +.                                                      ##    ###     ##    ###
echo.                  om-                                                                   #######       #######
echo.                   `.
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
set /p "file= Drag the video into this window to upscale >> "
IF %encoder% equ NVENC (
%SystemDrive%\ffmpeg\bin\ffmpeg.exe -i %file% -vf scale=3840:2160:flags=neighbor -r 60 -vcodec h264_nvenc -profile:v high -preset fast -rc constqp -qp 14 "%SystemDrive%\users\%username%\desktop\4k.mp4" -y
) else (
%SystemDrive%\ffmpeg\bin\ffmpeg.exe -i %file% -vf scale=3840:2160:flags=neighbor -r 60 -vcodec h264_amf -profile:v high -preset fast -qmin 13 -qmax 13 "%SystemDrive%\users\%username%\desktop\4k.mp4" 
)
goto upscale

:8k
cls
set /p "file= Drag the video into this window to upscale >> "
%SystemDrive%\ffmpeg\bin\ffmpeg.exe -i %file% -vf scale=7680:4320:flags=neighbor -r 60 -vcodec libx264 -profile:v high -preset fast -qmin 19 -qmax 19 "%SystemDrive%\users\%username%\desktop\8k.mp4" 
goto upscale


:compress
if not exist %SystemDrive%\ffmpeg ( call:ffmpeginstall )
cls
color 06
echo.
echo.
echo.                                      %COL%[33m+N.
echo.                           //        oMMs         
echo.                          +Nm`    ``yMMm-     ::::::::     ::::    :::    :::::::::: 
echo.                       ``dMMsoyhh-hMMd.     :+:    :+:    :+:+:   :+:    :+:  
echo.                       `yy/MMMMNh:dMMh`    +:+    +:+    :+:+:+  +:+    +:+                 +::+:+::      +::+:+::
echo.                      .hMM.sso++:oMMs`    +#+    +:+    +#+ +:+ +#+    +#++:++#           ++:    #++    ++:    #++
echo.                     -mMMy:osyyys.No     +#+    +#+    +#+  +#+#+#    +#+                +#+    +#+    +#+    +#+
echo.                    :NMMs-oo+/syy:-     #+#    #+#    #+#   #+#+#    #+#          %COL%[37m#+#%COL%[33m    +#+   #+#     #+#   #+#
echo.                   /NMN+ ``   :ys.      ########     ###    ####    ##########   %COL%[37m###%COL%[33m       ######        ######
echo.                  `NMN:        +.                                                      ##    ###     ##    ###
echo.                  om-                                                                   #######       #######
echo.                   `.
echo.
echo                         %COL%[33m[ %COL%[37m1 %COL%[33m]%COL%[37m Heavy                                          %COL%[33m[ %COL%[37m2 %COL%[33m]%COL%[37m Light
echo                         %COL%[90mLower the scale ^& fps of a video                     %COL%[90mLower only the scale of a video
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
set /p "file= Drag the video into this window to upscale >> "
IF %encoder% equ NVENC (
%SystemDrive%\ffmpeg\bin\ffmpeg.exe -i %file% -vf scale=800:600:flags=neighbor -r 48 -vcodec h264_nvenc -profile:v high -preset fast -rc constqp -qp 14 "%SystemDrive%\users\%username%\desktop\heavycompress.mp4" -y
) else (
%SystemDrive%\ffmpeg\bin\ffmpeg.exe -i %file% -vf scale=800:600:flags=neighbor -r 48 -vcodec h264_amf -profile:v high -preset fast -qmin 13 -qmax 13 "%SystemDrive%\users\%username%\desktop\heavycompress.mp4" 
)
goto compress

:Light
cls
set /p "file= Drag the video into this window to upscale >> "
IF %encoder% equ NVENC (
%SystemDrive%\ffmpeg\bin\ffmpeg.exe -i %file% -vf scale=1280:720:flags=neighbor -r 60 -vcodec h264_nvenc -profile:v high -preset fast -rc constqp -qp 14 "%SystemDrive%\users\%username%\desktop\lightcompress.mp4" -y
) else (
%SystemDrive%\ffmpeg\bin\ffmpeg.exe -i %file% -vf scale=1280:720:flags=neighbor -r 60 -vcodec h264_amf -profile:v high -preset fast -qmin 13 -qmax 13 "%SystemDrive%\users\%username%\desktop\lightcompress.mp4" 
)
goto compress

:PreviewLag
if not exist %SystemDrive%\ffmpeg ( call:ffmpeginstall )
cls
set /p "file= Drag the file you want to use in vegas (remember you need to replace it with the original file afterwards) >> "
IF %encoder% equ NVENC (
%SystemDrive%\ffmpeg\bin\ffmpeg.exe -i "%file%" -vf scale=1920:1080:flags=neighbor -r 60 -vcodec h264_nvenc -profile:v high -preset fast -qmin 24 -qmax 24 "%SystemDrive%\users\%username%\desktop\previewlag.mp4" -y
) else (
%SystemDrive%\ffmpeg\bin\ffmpeg.exe -i "%file%" -vf scale=1920:1080:flags=neighbor -r 60 -vcodec h264_amf -profile:v high -preset fast -qmin 24 -qmax 24 "%SystemDrive%\users\%username%\desktop\previewlag.mp4"
)
goto HoneRenders

:ffmpeginstall
cls
echo FFmpeg not found... Installing...
curl -g -L -# -o "%temp%\ffmpeg.exe" "https://cdn.discordapp.com/attachments/798652558351794196/809493909704015892/ffmpeg-4.2-setup.exe"
"%temp%\ffmpeg.exe" /SP /VERYSILENT /SUPPRESSMSGBOXES /NOCANCEL /NORESTART /ALLUSERS
goto:eof
 
:blurinstall
:: delete old blur
rmdir /s /q "%SystemDrive%\program files (x86)\blur"
cls
curl -g -L -# -o "%temp%\blur.exe" "https://github.com/f0e/blur/releases/latest/download/blur-installer.exe"
"%temp%\blur.exe" /SP /VERYSILENT /SUPPRESSMSGBOXES /NOCANCEL /NORESTART /ALLUSERS
goto:eof

:FPSGames
cls
color 06
echo.
echo.
echo.                                      %COL%[33m+N.
echo.                           //        oMMs         
echo.                          +Nm`    ``yMMm-     ::::::::     ::::    :::    :::::::::: 
echo.                       ``dMMsoyhh-hMMd.     :+:    :+:    :+:+:   :+:    :+:  
echo.                       `yy/MMMMNh:dMMh`    +:+    +:+    :+:+:+  +:+    +:+                 +::+:+::      +::+:+::
echo.                      .hMM.sso++:oMMs`    +#+    +:+    +#+ +:+ +#+    +#++:++#           ++:    #++    ++:    #++
echo.                     -mMMy:osyyys.No     +#+    +#+    +#+  +#+#+#    +#+                +#+    +#+    +#+    +#+
echo.                    :NMMs-oo+/syy:-     #+#    #+#    #+#   #+#+#    #+#          %COL%[37m#+#%COL%[33m    +#+   #+#     #+#   #+#
echo.                   /NMN+ ``   :ys.      ########     ###    ####    ##########   %COL%[37m###%COL%[33m       ######        ######
echo.                  `NMN:        +.                                                      ##    ###     ##    ###
echo.                  om-                                                                   #######       #######
echo.                   `.
echo.
echo                       %COL%[33m[ %COL%[37m1 %COL%[33m]%COL%[37m 60 - 120 FPS                                   %COL%[33m[ %COL%[37m2 %COL%[33m]%COL%[37m 240+ FPS
echo                       %COL%[90mAutomated Blur settings                              %COL%[90mAutomated Blur settings
echo                       %COL%[90mfor FPS games recorded in 60 to 120 FPS              %COL%[90mfor FPS games recorded in above 240 FPS
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
if /i "%choice%"=="1" goto 60120
if /i "%choice%"=="2" goto 240
if /i "%choice%"=="B" goto HoneRenders
if /i "%choice%"=="X" exit /b
goto FPSGames

:60120
if not exist "%SystemDrive%\Program Files (x86)\blur" call:blurinstall
if exist "%SystemDrive%\users\%username%\documents\HoneFPS60-120.cfg" goto skip
if %encoder% equ NVENC (
	(for %%i in (
		"- blur"
		"blur: true"
		"blur amount: 1.4"
		"blur output fps: 60"
		"blur weighting: equal"
		.
		"- interpolation"
		"interpolate: true"
		"interpolated fps: 720"
		.
		"- rendering"
		"quality: 15"
		"preview: true"
		"detailed filenames: false"
		.
		"- timescale"
		"input timescale: 1"
		"output timescale: 1"
		"adjust timescaled audio pitch: false"
		.
		"- filters"
		"brightness: 1"
		"saturation: 1"
		"contrast: 1"
		.
		"- advanced rendering"
		"gpu: true"
		"gpu type (nvidia/amd/intel): nvidia"
		"deduplicate: false"
		"custom ffmpeg filters:" 
		.
		"- advanced blur"
		"blur weighting gaussian std dev: 2"
		"blur weighting triangle reverse: false"
		"blur weighting bound: [0,1]"
		.
		"- advanced interpolation"
		"interpolation program (svp/rife/rife-ncnn): svp"
		"interpolation speed: medium"
		"interpolation tuning: film"
		"interpolation algorithm: 13"
	) do echo.%%~i)> "%SystemDrive%\users\%username%\Documents\HoneFPS60-120.cfg"
)

if %encoder% equ AMF (
	(for %%i in (
		"- blur"
		"blur: true"
		"blur amount: 1.4"
		"blur output fps: 60"
		"blur weighting: equal"
		.
		"- interpolation"
		"interpolate: true"
		"interpolated fps: 720"
		.
		"- rendering"
		"quality: 15"
		"preview: true"
		"detailed filenames: false"
		.
		"- timescale"
		"input timescale: 1"
		"output timescale: 1"
		"adjust timescaled audio pitch: false"
		.
		"- filters"
		"brightness: 1"
		"saturation: 1"
		"contrast: 1"
		.
		"- advanced rendering"
		"gpu: true"
		"gpu type (nvidia/amd/intel): amd"
		"deduplicate: false"
		"custom ffmpeg filters:" 
		.
		"- advanced blur"
		"blur weighting gaussian std dev: 2"
		"blur weighting triangle reverse: false"
		"blur weighting bound: [0,1]"
		.
		"- advanced interpolation"
		"interpolation program (svp/rife/rife-ncnn): svp"
		"interpolation speed: medium"
		"interpolation tuning: film"
		"interpolation algorithm: 13"
	) do echo.%%~i)> "%SystemDrive%\users\%username%\Documents\HoneFPS60-120.cfg"
)

if %encoder% equ CPU (
	(for %%i in (
		"- blur"
		"blur: true"
		"blur amount: 1.4"
		"blur output fps: 60"
		"blur weighting: equal"
		.
		"- interpolation"
		"interpolate: true"
		"interpolated fps: 720"
		.
		"- rendering"
		"quality: 15"
		"preview: true"
		"detailed filenames: false"
		.
		"- timescale"
		"input timescale: 1"
		"output timescale: 1"
		"adjust timescaled audio pitch: false"
		.
		"- filters"
		"brightness: 1"
		"saturation: 1"
		"contrast: 1"
		.
		"- advanced rendering"
		"gpu: true"
		"gpu type (nvidia/amd/intel): intel"
		"deduplicate: false"
		"custom ffmpeg filters:" 
		.
		"- advanced blur"
		"blur weighting gaussian std dev: 2"
		"blur weighting triangle reverse: false"
		"blur weighting bound: [0,1]"
		.
		"- advanced interpolation"
		"interpolation program (svp/rife/rife-ncnn): svp"
		"interpolation speed: medium"
		"interpolation tuning: film"
		"interpolation algorithm: 13"
	) do echo.%%~i)> "%SystemDrive%\users\%username%\Documents\HoneFPS60-120.cfg"
)

:skip
cls
set /p "file= Drag the file you want blurred into this window >> "
"%SystemDrive%\program files (x86)\blur\blur.exe" -i %file% -c "%SystemDrive%\users\%username%\Documents\HoneFPS60-120.cfg" -n -p -v
goto HoneRenders


:240
if not exist "%SystemDrive%\Program Files (x86)\blur\" call:blurinstall
if exist "%SystemDrive%\users\%username%\documents\HoneFPS240+.cfg" goto skip
if %encoder% equ NVENC (
	(for %%i in (
		"- blur"
		"blur: true"
		"blur amount: 1.4"
		"blur output fps: 60"
		"blur weighting: equal"
		.
		"- interpolation"
		"interpolate: true"
		"interpolated fps: 960"
		.
		"- rendering"
		"quality: 15"
		"preview: true"
		"detailed filenames: false"
		.
		"- timescale"
		"input timescale: 1"
		"output timescale: 1"
		"adjust timescaled audio pitch: false"
		.
		"- filters"
		"brightness: 1"
		"saturation: 1"
		"contrast: 1"
		.
		"- advanced rendering"
		"gpu: true"
		"gpu type (nvidia/amd/intel): nvidia"
		"deduplicate: false"
		"custom ffmpeg filters:"
		.
		"- advanced blur"
		"blur weighting gaussian std dev: 2"
		"blur weighting triangle reverse: false"
		"blur weighting bound: [0,1]"
		.
		"- advanced interpolation"
		"interpolation program (svp/rife/rife-ncnn): svp"
		"interpolation speed: medium"
		"interpolation tuning: weak"
		"interpolation algorithm: 13"
	) do echo.%%~i)> "%SystemDrive%\users\%username%\Documents\HoneFPS240+.cfg"
)

if %encoder% equ AMF (
	(for %%i in (
		"- blur"
		"blur: true"
		"blur amount: 1.4"
		"blur output fps: 60"
		"blur weighting: equal"
		.
		"- interpolation"
		"interpolate: true"
		"interpolated fps: 960"
		.
		"- rendering"
		"quality: 15"
		"preview: true"
		"detailed filenames: false"
		.
		"- timescale"
		"input timescale: 1"
		"output timescale: 1"
		"adjust timescaled audio pitch: false"
		.
		"- filters"
		"brightness: 1"
		"saturation: 1"
		"contrast: 1"
		.
		"- advanced rendering"
		"gpu: true"
		"gpu type (nvidia/amd/intel): amd"
		"deduplicate: false"
		"custom ffmpeg filters:"
		.
		"- advanced blur"
		"blur weighting gaussian std dev: 2"
		"blur weighting triangle reverse: false"
		"blur weighting bound: [0,1]"
		.
		"- advanced interpolation"
		"interpolation program (svp/rife/rife-ncnn): svp"
		"interpolation speed: medium"
		"interpolation tuning: weak"
		"interpolation algorithm: 13"
	) do echo.%%~i)> "%SystemDrive%\users\%username%\Documents\HoneFPS240+.cfg"
) 

if %encoder% equ CPU (
	(for %%i in (
		"- blur"
		"blur: true"
		"blur amount: 1.4"
		"blur output fps: 60"
		"blur weighting: equal"
		.
		"- interpolation"
		"interpolate: true"
		"interpolated fps: 960"
		.
		"- rendering"
		"quality: 15"
		"preview: true"
		"detailed filenames: false"
		.
		"- timescale"
		"input timescale: 1"
		"output timescale: 1"
		"adjust timescaled audio pitch: false"
		.
		"- filters"
		"brightness: 1"
		"saturation: 1"
		"contrast: 1"
		.
		"- advanced rendering"
		"gpu: true"
		"gpu type (nvidia/amd/intel): intel"
		"deduplicate: false"
		"custom ffmpeg filters:"
		.
		"- advanced blur"
		"blur weighting gaussian std dev: 2"
		"blur weighting triangle reverse: false"
		"blur weighting bound: [0,1]"
		.
		"- advanced interpolation"
		"interpolation program (svp/rife/rife-ncnn): svp"
		"interpolation speed: medium"
		"interpolation tuning: weak"
		"interpolation algorithm: 13"
	) do echo.%%~i)> "%SystemDrive%\users\%username%\Documents\HoneFPS240+.cfg"
)

:skip
cls
set /p "file= Drag the file you want blurred into this window >> "
"%SystemDrive%\program files (x86)\blur\blur.exe" -i %file% -c "%SystemDrive%\users\%username%\Documents\HoneFPS240+.cfg" -n -p -v
goto HoneRenders

:MinecraftBlur
cls
color 06
echo.
echo.
echo.                                      %COL%[33m+N.
echo.                           //        oMMs         
echo.                          +Nm`    ``yMMm-     ::::::::     ::::    :::    :::::::::: 
echo.                       ``dMMsoyhh-hMMd.     :+:    :+:    :+:+:   :+:    :+:  
echo.                       `yy/MMMMNh:dMMh`    +:+    +:+    :+:+:+  +:+    +:+                 +::+:+::      +::+:+::
echo.                      .hMM.sso++:oMMs`    +#+    +:+    +#+ +:+ +#+    +#++:++#           ++:    #++    ++:    #++
echo.                     -mMMy:osyyys.No     +#+    +#+    +#+  +#+#+#    +#+                +#+    +#+    +#+    +#+
echo.                    :NMMs-oo+/syy:-     #+#    #+#    #+#   #+#+#    #+#          %COL%[37m#+#%COL%[33m    +#+   #+#     #+#   #+#
echo.                   /NMN+ ``   :ys.      ########     ###    ####    ##########   %COL%[37m###%COL%[33m       ######        ######
echo.                  `NMN:        +.                                                      ##    ###     ##    ###
echo.                  om-                                                                   #######       #######
echo.                   `.
echo.
echo         %COL%[33m[ %COL%[37m1 %COL%[33m]%COL%[37m 180 - 360 FPS                       %COL%[33m[ %COL%[37m2 %COL%[33m]%COL%[37m 480+ FPS                        %COL%[33m[ %COL%[37m3 %COL%[33m]%COL%[37m Any FPS (30 FPS Renders)
echo         %COL%[90mAutomated Blur settings                   %COL%[90mAutomated Blur settings               %COL%[90mAutomated Blur settings
echo         %COL%[90mfor clips recorded in 240 - 360 FPS       %COL%[90mfor clips recorded above 480 FPS      %COL%[90mfor clips to be rendered in 30 FPS
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
if /i "%choice%"=="1" goto 180360
if /i "%choice%"=="2" goto 480
if /i "%choice%"=="3" goto Any
if /i "%choice%"=="B" goto HoneRenders
if /i "%choice%"=="X" exit /b
goto MinecraftBlur

:180360
if not exist "%SystemDrive%\Program Files (x86)\blur\" call:blurinstall
if exist "%SystemDrive%\users\%username%\documents\HoneFPS180-360FPS.cfg" goto skip
if %encoder% equ NVENC (
	(for %%i in (
		"- blur"
		"blur: true"
		"blur amount: 1.6"
		"blur output fps: 60"
		"blur weighting: gaussian_sym"

		"- interpolation"
		"interpolate: true"
		"interpolated fps: 1920"

		"- rendering"
		"quality: 15"
		"preview: true"
		"detailed filenames: false"

		"- timescale"
		"input timescale: 1"
		"output timescale: 1"
		"adjust timescaled audio pitch: false"

		"- filters"
		"brightness: 1"
		"saturation: 1"
		"contrast: 1"

		"- advanced rendering"
		"gpu: true"
		"gpu type (nvidia/amd/intel): nvidia"
		"deduplicate: true"
		"custom ffmpeg filters: "

		"- advanced blur"
		"blur weighting gaussian std dev: 1"
		"blur weighting triangle reverse: false"
		"blur weighting bound: [0,1]"

		"- advanced interpolation"
		"interpolation program (svp/rife/rife-ncnn): svp"
		"interpolation speed: medium"
		"interpolation tuning: weak"
		"interpolation algorithm: 13"
	) do echo.%%~i)> "%SystemDrive%\users\%username%\Documents\HoneFPS180-360FPS.cfg"
)

if %encoder% equ AMF (
	(for %%i in (
		"- blur"
		"blur: true"
		"blur amount: 1.6"
		"blur output fps: 60"
		"blur weighting: gaussian_sym"

		"- interpolation"
		"interpolate: true"
		"interpolated fps: 1920"

		"- rendering"
		"quality: 15"
		"preview: true"
		"detailed filenames: false"

		"- timescale"
		"input timescale: 1"
		"output timescale: 1"
		"adjust timescaled audio pitch: false"

		"- filters"
		"brightness: 1"
		"saturation: 1"
		"contrast: 1"

		"- advanced rendering"
		"gpu: true"
		"gpu type (nvidia/amd/intel): amd"
		"deduplicate: true"
		"custom ffmpeg filters: "

		"- advanced blur"
		"blur weighting gaussian std dev: 1"
		"blur weighting triangle reverse: false"
		"blur weighting bound: [0,1]"

		"- advanced interpolation"
		"interpolation program (svp/rife/rife-ncnn): svp"
		"interpolation speed: medium"
		"interpolation tuning: weak"
		"interpolation algorithm: 13"
	) do echo.%%~i)> "%SystemDrive%\users\%username%\Documents\HoneFPS180-360FPS.cfg"
) 

if %encoder% equ CPU (
	(for %%i in (
		"- blur"
		"blur: true"
		"blur amount: 1.6"
		"blur output fps: 60"
		"blur weighting: gaussian_sym"

		"- interpolation"
		"interpolate: true"
		"interpolated fps: 1920"

		"- rendering"
		"quality: 15"
		"preview: true"
		"detailed filenames: false"

		"- timescale"
		"input timescale: 1"
		"output timescale: 1"
		"adjust timescaled audio pitch: false"

		"- filters"
		"brightness: 1"
		"saturation: 1"
		"contrast: 1"

		"- advanced rendering"
		"gpu: true"
		"gpu type (nvidia/amd/intel): intel"
		"deduplicate: true"
		"custom ffmpeg filters: "

		"- advanced blur"
		"blur weighting gaussian std dev: 1"
		"blur weighting triangle reverse: false"
		"blur weighting bound: [0,1]"

		"- advanced interpolation"
		"interpolation program (svp/rife/rife-ncnn): svp"
		"interpolation speed: medium"
		"interpolation tuning: weak"
		"interpolation algorithm: 13"
	) do echo.%%~i)> "%SystemDrive%\users\%username%\Documents\HoneFPS180-360FPS.cfg"
)

:skip
cls
set /p "file= Drag the file you want blurred into this window >> "
"%SystemDrive%\program files (x86)\blur\blur.exe" -i %file% -c "%SystemDrive%\users\%username%\Documents\HoneFPS180-360FPS.cfg" -n -p -v
goto HoneRenders

:480
if not exist "%SystemDrive%\Program Files (x86)\blur\" cls & echo blur isn't installed... & timeout 3 & goto HoneRenders
if exist "%SystemDrive%\users\%username%\documents\HoneFPS480FPS.cfg" goto skip
if %encoder% equ NVENC (
	(for %%i in (
		"- blur"
		"blur: true"
		"blur amount: 2.22"
		"blur output fps: 60"
		"blur weighting: gaussian_sym"
		.
		"- interpolation"
		"interpolate: true"
		"interpolated fps: 1920"
		.
		"- rendering"
		"quality: 15"
		"preview: true"
		"detailed filenames: false"
		.
		"- timescale"
		"input timescale: 1"
		"output timescale: 1"
		"adjust timescaled audio pitch: false"
		.
		"- filters"
		"brightness: 1"
		"saturation: 1"
		"contrast: 1"
		.
		"- advanced rendering"
		"gpu: true"
		"gpu type (nvidia/amd/intel): nvidia"
		"deduplicate: false"
		"custom ffmpeg filters:" 
		.
		"- advanced blur"
		"blur weighting gaussian std dev: 1"
		"blur weighting triangle reverse: false"
		"blur weighting bound: [0,2]"
		.
		"- advanced interpolation"
		"interpolation program (svp/rife/rife-ncnn): svp"
		"interpolation speed: faster"
		"interpolation tuning: weak"
		"interpolation algorithm: 2"
	) do echo.%%~i)> "%SystemDrive%\users\%username%\Documents\HoneFPS480FPS.cfg"
)

if %encoder% equ AMF (
	(for %%i in (
		"- blur"
		"blur: true"
		"blur amount: 2.22"
		"blur output fps: 60"
		"blur weighting: gaussian_sym"
		.
		"- interpolation"
		"interpolate: true"
		"interpolated fps: 1920"
		.
		"- rendering"
		"quality: 15"
		"preview: true"
		"detailed filenames: false"
		.
		"- timescale"
		"input timescale: 1"
		"output timescale: 1"
		"adjust timescaled audio pitch: false"
		.
		"- filters"
		"brightness: 1"
		"saturation: 1"
		"contrast: 1"
		.
		"- advanced rendering"
		"gpu: true"
		"gpu type (nvidia/amd/intel): amd"
		"deduplicate: false"
		"custom ffmpeg filters:" 
		.
		"- advanced blur"
		"blur weighting gaussian std dev: 1"
		"blur weighting triangle reverse: false"
		"blur weighting bound: [0,2]"
		.
		"- advanced interpolation"
		"interpolation program (svp/rife/rife-ncnn): svp"
		"interpolation speed: faster"
		"interpolation tuning: weak"
		"interpolation algorithm: 2"
	) do echo.%%~i)> "%SystemDrive%\users\%username%\Documents\HoneFPS480FPS.cfg"
) 

if %encoder% equ CPU (
	(for %%i in (
		"- blur"
		"blur: true"
		"blur amount: 2.22"
		"blur output fps: 60"
		"blur weighting: gaussian_sym"
		.
		"- interpolation"
		"interpolate: true"
		"interpolated fps: 1920"
		.
		"- rendering"
		"quality: 15"
		"preview: true"
		"detailed filenames: false"
		.
		"- timescale"
		"input timescale: 1"
		"output timescale: 1"
		"adjust timescaled audio pitch: false"
		.
		"- filters"
		"brightness: 1"
		"saturation: 1"
		"contrast: 1"
		.
		"- advanced rendering"
		"gpu: true"
		"gpu type (nvidia/amd/intel): intel"
		"deduplicate: false"
		"custom ffmpeg filters:" 
		.
		"- advanced blur"
		"blur weighting gaussian std dev: 1"
		"blur weighting triangle reverse: false"
		"blur weighting bound: [0,2]"
		.
		"- advanced interpolation"
		"interpolation program (svp/rife/rife-ncnn): svp"
		"interpolation speed: faster"
		"interpolation tuning: weak"
		"interpolation algorithm: 2"
	) do echo.%%~i)> "%SystemDrive%\users\%username%\Documents\HoneFPS480FPS.cfg"
)

:skip
cls
set /p "file= Drag the file you want blurred into this window >> "
"%SystemDrive%\program files (x86)\blur\blur.exe" -i %file% -c "%SystemDrive%\users\%username%\Documents\HoneFPS480FPS.cfg" -n -p -v
goto HoneRenders

:Any
if not exist "%SystemDrive%\Program Files (x86)\blur\" cls & echo blur isn't installed... & timeout 3 & goto HoneRenders
if exist "%SystemDrive%\users\%username%\documents\HoneAnyFPS.cfg" goto skip
if %encoder% equ NVENC (
	(for %%i in (
		"- blur"
		"blur: true"
		"blur amount: 1.1"
		"blur output fps: 30"
		"blur weighting: equal"
		.
		"- interpolation"
		"interpolate: true"
		"interpolated fps: 1920"
		.
		"- rendering"
		"quality: 15"
		"preview: true"
		"detailed filenames: false"
		.
		"- timescale"
		"input timescale: 1"
		"output timescale: 1"
		"adjust timescaled audio pitch: false"
		.
		"- filters"
		"brightness: 1"
		"saturation: 1"
		"contrast: 1"
		.
		"- advanced rendering"
		"gpu: true"
		"gpu type (nvidia/amd/intel): nvidia"
		"deduplicate: true"
		"custom ffmpeg filters: "
		.
		"- advanced blur"
		"blur weighting gaussian std dev: 1"
		"blur weighting triangle reverse: false"
		"blur weighting bound: [0,1,1,1,1,0]"
		.
		"- advanced interpolation"
		"interpolation program (svp/rife/rife-ncnn): svp"
		"interpolation speed: medium"
		"interpolation tuning: weak"
		"interpolation algorithm: 23"
	) do echo.%%~i)> "%SystemDrive%\users\%username%\Documents\HoneAnyFPS.cfg"
)

if %encoder% equ AMF (
	(for %%i in (
		"- blur"
		"blur: true"
		"blur amount: 1.1"
		"blur output fps: 30"
		"blur weighting: equal"
		.
		"- interpolation"
		"interpolate: true"
		"interpolated fps: 1920"
		.
		"- rendering"
		"quality: 15"
		"preview: true"
		"detailed filenames: false"
		.
		"- timescale"
		"input timescale: 1"
		"output timescale: 1"
		"adjust timescaled audio pitch: false"
		.
		"- filters"
		"brightness: 1"
		"saturation: 1"
		"contrast: 1"
		.
		"- advanced rendering"
		"gpu: true"
		"gpu type (nvidia/amd/intel): amd"
		"deduplicate: true"
		"custom ffmpeg filters: "
		.
		"- advanced blur"
		"blur weighting gaussian std dev: 1"
		"blur weighting triangle reverse: false"
		"blur weighting bound: [0,1,1,1,1,0]"
		.
		"- advanced interpolation"
		"interpolation program (svp/rife/rife-ncnn): svp"
		"interpolation speed: medium"
		"interpolation tuning: weak"
		"interpolation algorithm: 23"
	) do echo.%%~i)> "%SystemDrive%\users\%username%\Documents\HoneAnyFPS.cfg"
) 

if %encoder% equ CPU (
	(for %%i in (
		"- blur"
		"blur: true"
		"blur amount: 1.1"
		"blur output fps: 30"
		"blur weighting: equal"
		.
		"- interpolation"
		"interpolate: true"
		"interpolated fps: 1920"
		.
		"- rendering"
		"quality: 15"
		"preview: true"
		"detailed filenames: false"
		.
		"- timescale"
		"input timescale: 1"
		"output timescale: 1"
		"adjust timescaled audio pitch: false"
		.
		"- filters"
		"brightness: 1"
		"saturation: 1"
		"contrast: 1"
		.
		"- advanced rendering"
		"gpu: true"
		"gpu type (nvidia/amd/intel): intel"
		"deduplicate: true"
		"custom ffmpeg filters: "
		.
		"- advanced blur"
		"blur weighting gaussian std dev: 1"
		"blur weighting triangle reverse: false"
		"blur weighting bound: [0,1,1,1,1,0]"
		.
		"- advanced interpolation"
		"interpolation program (svp/rife/rife-ncnn): svp"
		"interpolation speed: medium"
		"interpolation tuning: weak"
		"interpolation algorithm: 23"
	) do echo.%%~i)> "%SystemDrive%\users\%username%\Documents\HoneAnyFPS.cfg"
)

:skip
cls
set /p "file= Drag the file you want blurred into this window >> "
"%SystemDrive%\program files (x86)\blur\blur.exe" -i %file% -c "%SystemDrive%\users\%username%\Documents\HoneAnyFPS.cfg" -n -p -v
goto HoneRenders

:VegasInstall
cls
color 06
echo.
echo.
echo.                                      %COL%[33m+N.
echo.                           //        oMMs         
echo.                          +Nm`    ``yMMm-     ::::::::     ::::    :::    :::::::::: 
echo.                       ``dMMsoyhh-hMMd.     :+:    :+:    :+:+:   :+:    :+:  
echo.                       `yy/MMMMNh:dMMh`    +:+    +:+    :+:+:+  +:+    +:+                 +::+:+::      +::+:+::
echo.                      .hMM.sso++:oMMs`    +#+    +:+    +#+ +:+ +#+    +#++:++#           ++:    #++    ++:    #++
echo.                     -mMMy:osyyys.No     +#+    +#+    +#+  +#+#+#    +#+                +#+    +#+    +#+    +#+
echo.                    :NMMs-oo+/syy:-     #+#    #+#    #+#   #+#+#    #+#          %COL%[37m#+#%COL%[33m    +#+   #+#     #+#   #+#
echo.                   /NMN+ ``   :ys.      ########     ###    ####    ##########   %COL%[37m###%COL%[33m       ######        ######
echo.                  `NMN:        +.                                                      ##    ###     ##    ###
echo.                  om-                                                                   #######       #######
echo.                   `.
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
goto VegasInstall

:ProjectSettings
cls
if exist "%SystemDrive%\Program Files\VEGAS\VEGAS Pro 17.0" (
curl -g -k -L -# -o "%temp%\project.reg" "https://raw.githubusercontent.com/auraside/HoneCtrl/main/Files/Settings/ProjectProperties17.reg"
Reg query "HKCU\SOFTWARE\Sony Creative Software\VEGAS Pro\17.0\Metrics\Application" >nul 2>&1 || start Vegas170.exe >nul 2>&1
) else if exist "%SystemDrive%\Program Files\VEGAS\VEGAS Pro 17" (
curl -g -k -L -# -o "%temp%\project.reg" "https://raw.githubusercontent.com/auraside/HoneCtrl/main/Files/Settings/ProjectProperties17.reg"
Reg query "HKCU\SOFTWARE\Sony Creative Software\VEGAS Pro\17.0\Metrics\Application" >nul 2>&1 || start Vegas170.exe >nul 2>&1
) else if exist "%SystemDrive%\Program Files\VEGAS\VEGAS Pro 18" (
curl -g -k -L -# -o "%temp%\project.reg" "https://raw.githubusercontent.com/auraside/HoneCtrl/main/Files/Settings/ProjectProperties18.reg"
Reg query "HKCU\SOFTWARE\Sony Creative Software\VEGAS Pro\18.0\Metrics\Application" >nul 2>&1 || start Vegas180.exe >nul 2>&1
) else if exist "%SystemDrive%\Program Files\VEGAS\VEGAS Pro 18.0" (
curl -g -k -L -# -o "%temp%\project.reg" "https://raw.githubusercontent.com/auraside/HoneCtrl/main/Files/Settings/ProjectProperties18.reg"
Reg query "HKCU\SOFTWARE\Sony Creative Software\VEGAS Pro\18.0\Metrics\Application" >nul 2>&1 || start Vegas180.exe >nul 2>&1
) else echo Sony Vegas Pro 17-18 isn't installed... & pause & goto HoneRenders
taskkill /f /im Vegas170.exe >nul 2>&1
taskkill /f /im Vegas180.exe >nul 2>&1
curl -g -k -L -# -o "%temp%\Hone.veg" "https://github.com/auraside/HoneCtrl/raw/main/Files/Settings/Hone.veg"
Reg import "%temp%\project.reg" >nul 2>&1
start "" /D "%temp%" Hone.veg
goto HoneRenders

:RenderSettings
cls
if not exist "%SystemDrive%\Program Files\VEGAS\VEGAS Pro 17.0" ^
if not exist "%SystemDrive%\Program Files\VEGAS\VEGAS Pro 18.0" ^
echo Sony Vegas Pro 17-18 isn't installed... & pause & goto HoneRenders
taskkill /f /im Vegas170.exe >nul 2>&1
taskkill /f /im Vegas180.exe >nul 2>&1
mkdir "%appdata%\VEGAS\Render Templates\avc" >nul 2>&1
curl -g -k -L -# -o "%appdata%\VEGAS\Render Templates\avc\Hone.sft2" "https://cdn.discordapp.com/attachments/934698794933702666/987166340714471514/Hone.sft2"
goto HoneRenders

:Disclaimer2
Reg query "HKCU\Software\Hone" /v "Disclaimer2" >nul 2>&1 && goto Advanced
cls
echo.
echo.
echo.                                      %COL%[33m+N.
echo.                           //        oMMs         
echo.                          +Nm`    ``yMMm-     ::::::::     ::::    :::    :::::::::: 
echo.                       ``dMMsoyhh-hMMd.     :+:    :+:    :+:+:   :+:    :+:  
echo.                       `yy/MMMMNh:dMMh`    +:+    +:+    :+:+:+  +:+    +:+                 +::+:+::      +::+:+::
echo.                      .hMM.sso++:oMMs`    +#+    +:+    +#+ +:+ +#+    +#++:++#           ++:    #++    ++:    #++
echo.                     -mMMy:osyyys.No     +#+    +#+    +#+  +#+#+#    +#+                +#+    +#+    +#+    +#+
echo.                    :NMMs-oo+/syy:-     #+#    #+#    #+#   #+#+#    #+#          %COL%[37m#+#%COL%[33m    +#+   #+#     #+#   #+#
echo.                   /NMN+ ``   :ys.      ########     ###    ####    ##########   %COL%[37m###%COL%[33m       ######        ######
echo.                  `NMN:        +.                                                      ##    ###     ##    ###
echo.                  om-                                                                   #######       #######
echo.                   `.
echo.
echo                                        %COL%[90m HoneCtrl is a free and open-source desktop utility
echo                                        %COL%[90m    made to improve your day-to-day productivity
echo.
echo.
echo.
echo %COL%[91m  WARNING:
echo.
echo.    %COL%[33m1.%COL%[37m These Tweaks are HIGHLY experimental, we do %COL%[91mnot%COL%[37m recommend proceeding if you do not know what you're doing!
echo.
echo     %COL%[33m1.%COL%[37m Everything is "use at your own risk", we are %COL%[91mNOT LIABLE%COL%[37m if you damage your system in any way.
echo.
echo.    %COL%[33m1.%COL%[37m Even though we have an automatic restore point feature, we %COL%[91mHighly%COL%[37m recommend making a manual restore point before running.
echo.
echo     Please enter "I agree" (without quotes) to continue:
echo.
echo                                     %COL%[90m[ B for back ]
echo.
set /p "input=%DEL%                                                            >: %COL%[92m"
if /i "!input!"=="B" goto TweaksPG3
if /i "!input!" neq "i agree" goto Disclaimer2
Reg add "HKCU\Software\Hone" /v "Disclaimer2" /f >nul 2>&1

:Advanced
for %%i in (DSCOF AUTOF DRIOF BCDOF NONOF CS0OF TOFOF PS0OF IDLOF CONG) do (set "%%i=%COL%[92mON ") >nul 2>&1
(
	::Disable Idle
	powercfg /qh scheme_current sub_processor IDLEDISABLE | find "Current AC Power Setting Index: 0x00000000" && set "IDLOF=%COL%[91mOFF"
	::DSCP Tweaks
	Reg query "HKLM\Software\Policies\Microsoft\Windows\QoS\javaw" || set "DSCOF=%COL%[91mOFF"
    ::AutoTuning Tweak
    Reg query "HKCU\Software\Hone" /v "TuningTweak" || set "AUTOF=%COL%[91mOFF"
    ::Congestion Provider Tweak
    Reg query "HKCU\Software\Hone" /v "TuningTweak1" || set "CONG=%COL%[91mOFF"
	::Nvidia Drivers
	cd "%SystemDrive%\Program Files\NVIDIA Corporation\NVSMI"
	for /f "tokens=1 skip=1" %%a in ('nvidia-smi --query-gpu^=driver_version --format^=csv') do if "%%a" neq "497.09" set "DRIOF=%COL%[91mOFF
	::BCDEDIT
	Reg query "HKCU\Software\Hone" /v "BcdEditTweaks" || set "BCDOF=%COL%[91mOFF"
	::NonBestEffortLimit Tweak
	Reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "NonBestEffortLimit" | find "0xa" || set "NONOF=%COL%[91mOFF"
	::CS0 Tweak
	Reg query "HKLM\SYSTEM\ControlSet001\Control\Class\{4D36E968-E325-11CE-BFC1-08002BE10318}\0000" /v "AllowDeepCStates" | find "0x0" || set "CS0OF=%COL%[91mOFF"
	::Task Offloading
	Reg query "HKLM\SYSTEM\CurrentControlSet\Services\TCPIP\Parameters" /v "DisableTaskOffload" | find "0x1" || set "TOFOF=%COL%[91mOFF"
	::PStates0
	For /F "tokens=*" %%i in ('reg query "HKLM\SYSTEM\ControlSet001\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /t REG_SZ /s /e /f "NVIDIA" ^| findstr "HK"') do (Reg query "%%i" /v "DisableDynamicPstate" | find "0x1" || set "PS0OF=%COL%[91mOFF")
::Check If Applicable For PC
	::GPU
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
echo.                                      %COL%[33m+N.
echo.                           //        oMMs         
echo.                          +Nm`    ``yMMm-     ::::::::     ::::    :::    :::::::::: 
echo.                       ``dMMsoyhh-hMMd.     :+:    :+:    :+:+:   :+:    :+:  
echo.                       `yy/MMMMNh:dMMh`    +:+    +:+    :+:+:+  +:+    +:+                 +::+:+::      +::+:+::
echo.                      .hMM.sso++:oMMs`    +#+    +:+    +#+ +:+ +#+    +#++:++#           ++:    #++    ++:    #++
echo.                     -mMMy:osyyys.No     +#+    +#+    +#+  +#+#+#    +#+                +#+    +#+    +#+    +#+
echo.                    :NMMs-oo+/syy:-     #+#    #+#    #+#   #+#+#    #+#          %COL%[37m#+#%COL%[33m    +#+   #+#     #+#   #+#
echo.                   /NMN+ ``   :ys.      ########     ###    ####    ##########   %COL%[37m###%COL%[33m       ######        ######
echo.                  `NMN:        +.                                                      ##    ###     ##    ###
echo.                  om-                                                                   #######       #######
echo.                   `.
echo                                                           %COL%[1;4;34mNetwork Tweaks%COL%[0m
echo.
echo              %COL%[33m[%COL%[37m 1 %COL%[33m]%COL%[37m Disable Task Offloading %TOFOF%    %COL%[33m[%COL%[37m 2 %COL%[33m]%COL%[37m NonBestEffortLimit %NONOF%         %COL%[33m[%COL%[37m 3 %COL%[33m]%COL%[37m AutoTuning %AUTOF%
echo              %COL%[90mTask Offloading assigns the          %COL%[90mAllocate more bandwidth to apps      %COL%[90mCan reduce bufferbloat, 
echo              %COL%[90mCPU to handle the NIC load           %COL%[90mUse only on fast connections         %COL%[90mbut lower your Network speed
echo.
echo                           %COL%[33m[%COL%[37m 4 %COL%[33m]%COL%[37m DSCP Value %DSCOF%                     %COL%[33m[%COL%[37m 5 %COL%[33m]%COL%[37m Congestion Provider %CONG% 
echo                           %COL%[90mSet the priority of your network         %COL%[90mTurn ON only, if you have WIFI. 
echo                           %COL%[90mtraffic to expedited forwarding          %COL%[90mChanges the algorithm on how data is processed.
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
echo                              %COL%[33m[%COL%[37m 9 %COL%[33m]%COL%[37m Nvidia Driver %DRIOF%                      %COL%[33m[%COL%[37m 10 %COL%[33m]%COL%[37m BCDEdit %BCDOF%
echo                              %COL%[90mInstall the best tweaked nvidia              %COL%[90mTweaks your windows boot config
echo                              %COL%[90mdriver for latency and fps                   %COL%[90mdata to optimized settings
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
if /i "%choice%"=="X" exit /b
if /i "%choice%"=="B" goto MainMenu
goto Advanced

:TaskOffloading
if "%TOFOF%" equ "%COL%[91mOFF" (
netsh int ip set global taskoffload=disabled >nul 2>&1
Reg add HKLM\SYSTEM\CurrentControlSet\Services\TCPIP\Parameters /v DisableTaskOffload /t REG_DWORD /d 1 /f >nul 2>&1
) else (
netsh int ip set global taskoffload=enabled >nul 2>&1
Reg add HKLM\SYSTEM\CurrentControlSet\Services\TCPIP\Parameters /v DisableTaskOffload /t REG_DWORD /d 0 /f >nul 2>&1
)
goto Advanced

:NonBestEffortLimit
if "%NONOF%" equ "%COL%[91mOFF" (
	Reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "NonBestEffortLimit" /t REG_DWORD /d "10" /f
) >nul 2>&1 else (
	Reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "NonBestEffortLimit" /f
) >nul 2>&1
goto Advanced

:Autotuning
if "%AUTOF%" equ "%COL%[91mOFF" (
Reg add "HKCU\Software\Hone" /v TuningTweak /f
    netsh int tcp set global autotuninglevel=disabled >nul 2>&1
) else (
Reg delete "HKCU\Software\Hone" /v TuningTweak /f
    netsh int tcp set global autotuninglevel=normal >nul 2>&1
)
goto Advanced

:Congestion
if "%CONG%" equ "%COL%[91mOFF" (
Reg add "HKCU\Software\Hone" /v TuningTweak1 /f
    netsh int tcp set supplemental Internet congestionprovider=newreno >nul 2>&1
) else (
Reg delete "HKCU\Software\Hone" /v TuningTweak1 /f
     netsh int tcp set supplemental Internet congestionprovider=ctcp >nul 2>&1
)
goto Advanced

:DSCPValue
if "%DSCOF%" equ "%COL%[91mOFF" (
	Reg add "HKLM\SYSTEM\CurrentControlSet\Services\Psched" /v "Start" /t Reg_DWORD /d "1" /f  
	sc start Psched
	for %%i in (csgo VALORANT-Win64-Shipping javaw FortniteClient-Win64-Shipping ModernWarfare r5apex) do (
		Reg query "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" || (
			Reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Application Name" /t Reg_SZ /d "%%i.exe" /f
			Reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Version" /t Reg_SZ /d "1.0" /f
			Reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Protocol" /t Reg_SZ /d "*" /f
			Reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Local Port" /t Reg_SZ /d "*" /f
			Reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Local IP" /t Reg_SZ /d "*" /f
			Reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Local IP Prefix Length" /t Reg_SZ /d "*" /f
			Reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Remote Port" /t Reg_SZ /d "*" /f
			Reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Remote IP" /t Reg_SZ /d "*" /f
			Reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Remote IP Prefix Length" /t Reg_SZ /d "*" /f
			Reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "DSCP Value" /t Reg_SZ /d "46" /f
			Reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Throttle Rate" /t Reg_SZ /d "-1" /f
		)
	)
	Reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\DiffservByteMappingConforming" /v "ServiceTypeGuaranteed" /t REG_DWORD /d "46" /f
	Reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\DiffservByteMappingConforming" /v "ServiceTypeNetworkControl" /t REG_DWORD /d "56" /f
	Reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\DiffservByteMappingNonConforming" /v "ServiceTypeGuaranteed" /t REG_DWORD /d "46" /f
	Reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\DiffservByteMappingNonConforming" /v "ServiceTypeNetworkControl" /t REG_DWORD /d "56" /f
	Reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\UserPriorityMapping" /v "ServiceTypeGuaranteed" /t REG_DWORD /d "5" /f
	Reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\UserPriorityMapping" /v "ServiceTypeNetworkControl" /t REG_DWORD /d "7" /f
	Reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "MaxOutstandingSends" /t REG_DWORD /d "65000" /f
) >nul 2>&1 else (
	for %%i in (csgo VALORANT-Win64-Shipping javaw FortniteClient-Win64-Shipping ModernWarfare r5apex) do (
	    Reg delete "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /f
	) >nul 2>&1
	Reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\DiffservByteMappingConforming" /v "ServiceTypeGuaranteed" /f
	Reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\DiffservByteMappingConforming" /v "ServiceTypeNetworkControl" /f
	Reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\DiffservByteMappingNonConforming" /v "ServiceTypeGuaranteed" /f
	Reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\DiffservByteMappingNonConforming" /v "ServiceTypeNetworkControl" /f
	Reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\UserPriorityMapping" /v "ServiceTypeGuaranteed" /f
	Reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\UserPriorityMapping" /v "ServiceTypeNetworkControl" /f
	Reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "MaxOutstandingSends" /f
) >nul 2>&1
goto Advanced

:PStates0
if "%PS0OF%" equ "%COL%[91mOFF" (
	for /f %%i in ('Reg query "HKLM\System\ControlSet001\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /t REG_SZ /s /e /f "NVIDIA" ^| findstr "HKEY"') do (
		Reg add "%%i" /v "DisableDynamicPstate" /t REG_DWORD /d "1" /f >nul 2>&1
	)
) else (
	for /f %%i in ('Reg query "HKLM\System\ControlSet001\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /t REG_SZ /s /e /f "NVIDIA" ^| findstr "HKEY"') do (
		Reg delete "%%i" /v "DisableDynamicPstate" /f >nul 2>&1
	)
)
call :HoneCtrlRestart "PStates 0" "%PS0OF%" && goto Advanced

:cstates
if "%CS0OF%" equ "%COL%[91mOFF" (
	Reg add "HKLM\SYSTEM\ControlSet001\Control\Class\{4D36E968-E325-11CE-BFC1-08002BE10318}\0000" /v "AllowDeepCStates" /t REG_DWORD /d "0" /f >nul 2>&1
) else (
	Reg add "HKLM\SYSTEM\ControlSet001\Control\Class\{4D36E968-E325-11CE-BFC1-08002BE10318}\0000" /v "AllowDeepCStates" /t REG_DWORD /d "1" /f >nul 2>&1
)
call :HoneCtrlRestart "CStates" "%CS0OF%" && goto Advanced

:DisableIdle
if "%IDLOF%" equ "%COL%[91mOFF" (
	powercfg /setacvalueindex scheme_current sub_processor IDLEDISABLE 1
) >nul 2>&1 else (
	powercfg -setacvalueindex scheme_current sub_processor IDLEDISABLE 0
) >nul 2>&1
goto Advanced

:Drivers
cls
echo The drivers are 732Mb to 1Gb, so this will take a moment to download. (768,102,400 or 1,073,691,829 bytes)
echo.
echo Would you like to install?
choice /c:YN /n /m "[Y] Yes  [N] No"
if %errorlevel% equ 2 goto Advanced

cls
title Downloading Nvidia driver...
echo Do you need shadowplay and other components of the driver? Y or N?
choice /c:YN /n /m "[Y] Yes  [N] No"
if %errorlevel% equ 1 (
curl -g -L -# -o "%userprofile%\Desktop\NvidiaHone.exe" "https://github.com/auraside/HoneCtrl/releases/download/1.3/497.09.Hone.Default.exe"
) else (
curl -g -L -# -o "%userprofile%\Desktop\NvidiaHone.exe" "https://github.com/auraside/HoneCtrl/releases/download/1.3/497.09.Hone.Tweaked.exe"
)

title Executing DDU...
curl -g -L -# -o "C:\Hone\Resources\DDU.zip" "https://github.com/auraside/HoneCtrl/raw/main/Files/DDU.zip"
powershell -NoProfile Expand-Archive 'C:\Hone\Resources\DDU.zip' -DestinationPath 'C:\Hone\Resources\DDU\' >nul 2>&1
del "C:\Hone\Resources\DDU.zip"
cd C:\Hone\Resources\DDU
DDU.exe -silent -cleannvidia

title Restart Confirmation
cls
echo Your PC NEEDS to restart before installing the driver!
echo.
echo Other Nvidia tweaks will not be available until you restart.
echo.
echo AFTER RESTARTING, PLEASE REOPEN THE HONE CONTROL PANEL
echo.
echo Would you like to restart now?
choice /c:YN /n /m "[Y] Yes  [N] No"
copy "%~f0" "C:\Users\%username%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\HoneCtrl.bat"
if %errorlevel% equ 1 (
    shutdown /s /t 60 /c "A restart is required, we'll do that now" /f /d p:0:0
    timeout 5
    shutdown -a
    shutdown /r /t 7 /c "Restarting automatically..." /f /d p:0:0
)
goto Advanced





:GameSettings
cls
echo.
echo.
echo.                                      %COL%[33m+N.
echo.                           //        oMMs         
echo.                          +Nm`    ``yMMm-     ::::::::     ::::    :::    :::::::::: 
echo.                       ``dMMsoyhh-hMMd.     :+:    :+:    :+:+:   :+:    :+:  
echo.                       `yy/MMMMNh:dMMh`    +:+    +:+    :+:+:+  +:+    +:+                 +::+:+::      +::+:+::
echo.                      .hMM.sso++:oMMs`    +#+    +:+    +#+ +:+ +#+    +#++:++#           ++:    #++    ++:    #++
echo.                     -mMMy:osyyys.No     +#+    +#+    +#+  +#+#+#    +#+                +#+    +#+    +#+    +#+
echo.                    :NMMs-oo+/syy:-     #+#    #+#    #+#   #+#+#    #+#          %COL%[37m#+#%COL%[33m    +#+   #+#     #+#   #+#
echo.                   /NMN+ ``   :ys.      ########     ###    ####    ##########   %COL%[37m###%COL%[33m       ######        ######
echo.                  `NMN:        +.                                                      ##    ###     ##    ###
echo.                  om-                                                                   #######       #######
echo.                   `.
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
choice /c:1BX /n /m "%DEL%                                        Select a corresponding number to the options above >"
set choice=%errorlevel%
if "%choice%"=="1" goto Minecraft
if "%choice%"=="2" goto MainMenu
if "%choice%"=="3" exit /b

:Minecraft
if not exist "%appdata%\.minecraft\" call:HoneCtrlError "Can't find your Minecraft installation." & goto GameSettings

cls
echo.
echo.
echo.
echo.
echo.                                                                           %COL%[33m.  
echo.                                                                        +N. 
echo.                                                               //        oMMs 
echo.                                                              +Nm`    ``yMMm- 
echo.                                                           ``dMMsoyhh-hMMd.  
echo.                                                           `yy/MMMMNh:dMMh`   
echo.                                                          .hMM.sso++:oMMs`    
echo.                                                         -mMMy:osyyys.No      
echo.                                                        :NMMs-oo+/syy:-       
echo.                                                       /NMN+ ``   :ys.        
echo.                                                      `NMN:        +.         
echo.                                                      om-                    
echo.                                                       `.                                            
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
echo                       %COL%[33m[ %COL%[37m1 %COL%[33m]%COL%[37m 1.7.10                         %COL%[33m[ %COL%[37m2 %COL%[33m]%COL%[37m 1.8.9                          %COL%[33m[ %COL%[37m3 %COL%[33m] %COL%[37m 1.18.2
rem echo                %COL%[33m[ %COL%[37m1 %COL%[33m]%COL%[37m 1.7.10                         %COL%[33m[ %COL%[37m2 %COL%[33m]%COL%[37m 1.8.9                          %COL%[33m[ %COL%[37m3 %COL%[33m] %COL%[37m 1.18.2
rem echo                %COL%[90mLower End Specs.                     %COL%[90mLower End Specs.                     %COL%[90mMid/High End Specs.
rem echo                %COL%[90mEnabled by default.                  %COL%[90mEnabled by default.                  %COL%[90mCan decrease network latency.
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
choice /c:123BX /n /m "%DEL%                                        Select a corresponding number to the options above >"
set choice=%errorlevel%
if %choice% equ 1 goto 1.7.10
if %choice% equ 2 goto 1.8.9
if %choice% equ 3 goto 1.18.2
if %choice% equ 4 goto GameSettings
if %choice% equ 5 exit /b


:1.7.10
cd %appdata%\.minecraft\
(echo ofRenderDistanceChunks:4) > optionsof.txt
(echo ofFogType:3) >> optionsof.txt
(echo ofFogStart:0.6) >> optionsof.txt
(echo ofMipmapType:0) >> optionsof.txt
(echo ofLoadFar:false) >> optionsof.txt
(echo ofPreloadedChunks:0) >> optionsof.txt
(echo ofOcclusionFancy:false) >> optionsof.txt
(echo ofSmoothFps:false) >> optionsof.txt
(echo ofSmoothWorld:false) >> optionsof.txt
(echo ofAoLevel:0.0) >> optionsof.txt
(echo ofClouds:3) >> optionsof.txt
(echo ofCloudsHeight:0.0) >> optionsof.txt
(echo ofTrees:1) >> optionsof.txt
(echo ofGrass:0) >> optionsof.txt
(echo ofDroppedItems:1) >> optionsof.txt
(echo ofRain:3) >> optionsof.txt
(echo ofWater:0) >> optionsof.txt
(echo ofAnimatedWater:0) >> optionsof.txt
(echo ofAnimatedLava:0) >> optionsof.txt
(echo ofAnimatedFire:true) >> optionsof.txt
(echo ofAnimatedPortal:true) >> optionsof.txt
(echo ofAnimatedRedstone:false) >> optionsof.txt
(echo ofAnimatedExplosion:true) >> optionsof.txt
(echo ofAnimatedFlame:true) >> optionsof.txt
(echo ofAnimatedSmoke:true) >> optionsof.txt
(echo ofVoidParticles:false) >> optionsof.txt
(echo ofWaterParticles:true) >> optionsof.txt
(echo ofPortalParticles:true) >> optionsof.txt
(echo ofPotionParticles:true) >> optionsof.txt
(echo ofDrippingWaterLava:true) >> optionsof.txt
(echo ofAnimatedTerrain:true) >> optionsof.txt
(echo ofAnimatedTextures:true) >> optionsof.txt
(echo ofAnimatedItems:true) >> optionsof.txt
(echo ofRainSplash:false) >> optionsof.txt
(echo ofLagometer:false) >> optionsof.txt
(echo ofShowFps:false) >> optionsof.txt
(echo ofAutoSaveTicks:28800) >> optionsof.txt
(echo ofBetterGrass:3) >> optionsof.txt
(echo ofConnectedTextures:3) >> optionsof.txt
(echo ofWeather:false) >> optionsof.txt
(echo ofSky:false) >> optionsof.txt
(echo ofStars:false) >> optionsof.txt
(echo ofSunMoon:true) >> optionsof.txt
(echo ofVignette:1) >> optionsof.txt
(echo ofChunkUpdates:1) >> optionsof.txt
(echo ofChunkLoading:0) >> optionsof.txt
(echo ofChunkUpdatesDynamic:false) >> optionsof.txt
(echo ofTime:0) >> optionsof.txt
(echo ofClearWater:true) >> optionsof.txt
(echo ofDepthFog:false) >> optionsof.txt
(echo ofAaLevel:0) >> optionsof.txt
(echo ofProfiler:false) >> optionsof.txt
(echo ofBetterSnow:false) >> optionsof.txt
(echo ofSwampColors:false) >> optionsof.txt
(echo ofRandomMobs:false) >> optionsof.txt
(echo ofSmoothBiomes:false) >> optionsof.txt
(echo ofCustomFonts:false) >> optionsof.txt
(echo ofCustomColors:false) >> optionsof.txt
(echo ofCustomSky:false) >> optionsof.txt
(echo ofShowCapes:true) >> optionsof.txt
(echo ofNaturalTextures:false) >> optionsof.txt
(echo ofLazyChunkLoading:true) >> optionsof.txt
(echo ofDynamicFov:false) >> optionsof.txt
(echo ofDynamicLights:3) >> optionsof.txt
(echo ofFullscreenMode:Default) >> optionsof.txt
(echo ofFastMath:true) >> optionsof.txt
(echo ofFastRender:true) >> optionsof.txt
(echo ofTranslucentBlocks:1) >> optionsof.txt
goto GameSettings

:1.8.9
cd %appdata%\.minecraft\
(echo ofFogType:3) > optionsof.txt
(echo ofFogStart:0.6) >> optionsof.txt
(echo ofMipmapType:0) >> optionsof.txt
(echo ofOcclusionFancy:false) >> optionsof.txt
(echo ofSmoothFps:false) >> optionsof.txt
(echo ofSmoothWorld:false) >> optionsof.txt
(echo ofAoLevel:0.0) >> optionsof.txt
(echo ofClouds:3) >> optionsof.txt
(echo ofCloudsHeight:0.0) >> optionsof.txt
(echo ofTrees:1) >> optionsof.txt
(echo ofDroppedItems:1) >> optionsof.txt
(echo ofRain:3) >> optionsof.txt
(echo ofAnimatedWater:0) >> optionsof.txt
(echo ofAnimatedLava:0) >> optionsof.txt
(echo ofAnimatedFire:true) >> optionsof.txt
(echo ofAnimatedPortal:true) >> optionsof.txt
(echo ofAnimatedRedstone:false) >> optionsof.txt
(echo ofAnimatedExplosion:true) >> optionsof.txt
(echo ofAnimatedFlame:true) >> optionsof.txt
(echo ofAnimatedSmoke:true) >> optionsof.txt
(echo ofVoidParticles:false) >> optionsof.txt
(echo ofWaterParticles:true) >> optionsof.txt
(echo ofPortalParticles:true) >> optionsof.txt
(echo ofPotionParticles:true) >> optionsof.txt
(echo ofFireworkParticles:true) >> optionsof.txt
(echo ofDrippingWaterLava:true) >> optionsof.txt
(echo ofAnimatedTerrain:true) >> optionsof.txt
(echo ofAnimatedTextures:true) >> optionsof.txt
(echo ofRainSplash:false) >> optionsof.txt
(echo ofLagometer:false) >> optionsof.txt
(echo ofShowFps:false) >> optionsof.txt
(echo ofAutoSaveTicks:28800) >> optionsof.txt
(echo ofBetterGrass:3) >> optionsof.txt
(echo ofConnectedTextures:3) >> optionsof.txt
(echo ofWeather:false) >> optionsof.txt
(echo ofSky:false) >> optionsof.txt
(echo ofStars:false) >> optionsof.txt
(echo ofSunMoon:true) >> optionsof.txt
(echo ofVignette:1) >> optionsof.txt
(echo ofChunkUpdates:1) >> optionsof.txt
(echo ofChunkUpdatesDynamic:false) >> optionsof.txt
(echo ofTime:0) >> optionsof.txt
(echo ofClearWater:false) >> optionsof.txt
(echo ofAaLevel:0) >> optionsof.txt
(echo ofAfLevel:1) >> optionsof.txt
(echo ofProfiler:false) >> optionsof.txt
(echo ofBetterSnow:false) >> optionsof.txt
(echo ofSwampColors:false) >> optionsof.txt
(echo ofRandomEntities:false) >> optionsof.txt
(echo ofSmoothBiomes:false) >> optionsof.txt
(echo ofCustomFonts:false) >> optionsof.txt
(echo ofCustomColors:false) >> optionsof.txt
(echo ofCustomItems:false) >> optionsof.txt
(echo ofCustomSky:true) >> optionsof.txt
(echo ofShowCapes:true) >> optionsof.txt
(echo ofNaturalTextures:false) >> optionsof.txt
(echo ofEmissiveTextures:false) >> optionsof.txt
(echo ofLazyChunkLoading:true) >> optionsof.txt
(echo ofRenderRegions:true) >> optionsof.txt
(echo ofSmartAnimations:true) >> optionsof.txt
(echo ofDynamicFov:false) >> optionsof.txt
(echo ofAlternateBlocks:false) >> optionsof.txt
(echo ofDynamicLights:3) >> optionsof.txt
(echo ofScreenshotSize:1) >> optionsof.txt
(echo ofCustomEntityModels:false) >> optionsof.txt
(echo ofCustomGuis:false) >> optionsof.txt
(echo ofShowGlErrors:false) >> optionsof.txt
(echo ofFullscreenMode:Default) >> optionsof.txt
(echo ofFastMath:true) >> optionsof.txt
(echo ofFastRender:true) >> optionsof.txt
(echo ofTranslucentBlocks:1) >> optionsof.txt
(echo key_of.key.zoom:29) >> optionsof.txt
goto GameSettings

:1.18.2
cd %appdata%\.minecraft\
(echo ofFogType:3) > optionsof.txt
(echo ofFogStart:0.6) >> optionsof.txt
(echo ofMipmapType:0) >> optionsof.txt
(echo ofOcclusionFancy:false) >> optionsof.txt
(echo ofSmoothFps:false) >> optionsof.txt
(echo ofSmoothWorld:false) >> optionsof.txt
(echo ofAoLevel:0.0) >> optionsof.txt
(echo ofClouds:3) >> optionsof.txt
(echo ofCloudsHeight:0.0) >> optionsof.txt
(echo ofTrees:1) >> optionsof.txt
(echo ofDroppedItems:1) >> optionsof.txt
(echo ofRain:3) >> optionsof.txt
(echo ofAnimatedWater:0) >> optionsof.txt
(echo ofAnimatedLava:0) >> optionsof.txt
(echo ofAnimatedFire:true) >> optionsof.txt
(echo ofAnimatedPortal:true) >> optionsof.txt
(echo ofAnimatedRedstone:false) >> optionsof.txt
(echo ofAnimatedExplosion:true) >> optionsof.txt
(echo ofAnimatedFlame:true) >> optionsof.txt
(echo ofAnimatedSmoke:true) >> optionsof.txt
(echo ofVoidParticles:false) >> optionsof.txt
(echo ofWaterParticles:true) >> optionsof.txt
(echo ofPortalParticles:true) >> optionsof.txt
(echo ofPotionParticles:true) >> optionsof.txt
(echo ofFireworkParticles:true) >> optionsof.txt
(echo ofDrippingWaterLava:true) >> optionsof.txt
(echo ofAnimatedTerrain:true) >> optionsof.txt
(echo ofAnimatedTextures:true) >> optionsof.txt
(echo ofRainSplash:false) >> optionsof.txt
(echo ofLagometer:false) >> optionsof.txt
(echo ofShowFps:false) >> optionsof.txt
(echo ofAutoSaveTicks:28800) >> optionsof.txt
(echo ofBetterGrass:3) >> optionsof.txt
(echo ofConnectedTextures:3) >> optionsof.txt
(echo ofWeather:false) >> optionsof.txt
(echo ofSky:false) >> optionsof.txt
(echo ofStars:fale) >> optionsof.txt
(echo ofSunMoon:true) >> optionsof.txt
(echo ofVignette:1) >> optionsof.txt
(echo ofChunkUpdates:1) >> optionsof.txt
(echo ofChunkUpdatesDynamic:false) >> optionsof.txt
(echo ofTime:0) >> optionsof.txt
(echo ofAaLevel:0) >> optionsof.txt
(echo ofAfLevel:1) >> optionsof.txt
(echo ofProfiler:false) >> optionsof.txt
(echo ofBetterSnow:false) >> optionsof.txt
(echo ofSwampColors:false) >> optionsof.txt
(echo ofRandomEntities:false) >> optionsof.txt
(echo ofCustomFonts:false) >> optionsof.txt
(echo ofCustomColors:false) >> optionsof.txt
(echo ofCustomItems:false) >> optionsof.txt
(echo ofCustomSky:true) >> optionsof.txt
(echo ofShowCapes:true) >> optionsof.txt
(echo ofNaturalTextures:false) >> optionsof.txt
(echo ofEmissiveTextures:false) >> optionsof.txt
(echo ofLazyChunkLoading:true) >> optionsof.txt
(echo ofRenderRegions:true) >> optionsof.txt
(echo ofSmartAnimations:true) >> optionsof.txt
(echo ofDynamicFov:false) >> optionsof.txt
(echo ofAlternateBlocks:false) >> optionsof.txt
(echo ofDynamicLights:3) >> optionsof.txt
(echo ofScreenshotSize:1) >> optionsof.txt
(echo ofCustomEntityModels:false) >> optionsof.txt
(echo ofCustomGuis:false) >> optionsof.txt
(echo ofShowGlErrors:false) >> optionsof.txt
(echo ofFastMath:true) >> optionsof.txt
(echo ofFastRender:true) >> optionsof.txt
(echo ofTranslucentBlocks:0) >> optionsof.txt
(echo ofChatBackground:3) >> optionsof.txt
(echo ofChatShadow:false) >> optionsof.txt
(echo ofTelemetry:2) >> optionsof.txt
(echo key_of.key.zoom:key.keyboard.left.control) >> optionsof.txt
goto GameSettings

goto MainMenu

:More
cls
echo.
echo.
echo.
echo.
echo.                                                                           %COL%[33m.  
echo.                                                                          +N. 
echo.                                                               //        oMMs 
echo.                                                              +Nm`    ``yMMm- 
echo.                                                           ``dMMsoyhh-hMMd.  
echo.                                                           `yy/MMMMNh:dMMh`   
echo.                                                          .hMM.sso++:oMMs`    
echo.                                                         -mMMy:osyyys.No      
echo.                                                        :NMMs-oo+/syy:-       
echo.                                                       /NMN+ ``   :ys.        
echo.                                                      `NMN:        +.         
echo.                                                      om-                    
echo.                                                       `.                                            
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
choice /c:12345BX /n /m "%DEL%                                        Select a corresponding number to the options above >"
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
echo Owned by AuraSide Inc. Copyright Claimed.
echo This is a GUI for the Hone Manual Tweaks.
echo.
call :ColorText 8 "                                                      [ press X to go back ]"
echo.
echo.
echo.
choice /c:X /n /m "%DEL%                                                               >:"
set choice=%errorlevel%
if "%choice%"=="1" goto More

:ViewDisclaimer
cls
echo.
echo.
echo.                                      %COL%[33m+N.
echo.                           //        oMMs         
echo.                          +Nm`    ``yMMm-     ::::::::     ::::    :::    :::::::::: 
echo.                       ``dMMsoyhh-hMMd.     :+:    :+:    :+:+:   :+:    :+:  
echo.                       `yy/MMMMNh:dMMh`    +:+    +:+    :+:+:+  +:+    +:+                 +::+:+::      +::+:+::
echo.                      .hMM.sso++:oMMs`    +#+    +:+    +#+ +:+ +#+    +#++:++#           ++:    #++    ++:    #++
echo.                     -mMMy:osyyys.No     +#+    +#+    +#+  +#+#+#    +#+                +#+    +#+    +#+    +#+
echo.                    :NMMs-oo+/syy:-     #+#    #+#    #+#   #+#+#    #+#          %COL%[37m#+#%COL%[33m    +#+   #+#     #+#   #+#
echo.                   /NMN+ ``   :ys.      ########     ###    ####    ##########   %COL%[37m###%COL%[33m       ######        ######
echo.                  `NMN:        +.                                                      ##    ###     ##    ###
echo.                  om-                                                                   #######       #######
echo.                   `.
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
choice /c:X /n /m "%DEL%                                                                 >:"
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
echo %COL%[97m                                                       Vojt R. - Vojtass
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
echo.
echo.
echo.
call :ColorText 8 "                                                     [ press B to go back ]"
echo.
choice /c:B /n /m "%DEL%                                                               >:"
set choice=%errorlevel%
if "%choice%"=="1" goto More

:Cleaner
cls
rmdir /S /Q "C:\Hone\Resources\DeviceCleanupCmd\"
del /F /Q "C:\Hone\Resources\AdwCleaner.exe"
del /F /Q "C:\Hone\Resources\EmptyStandbyList.exe"
curl -g -L -# -o "C:\Hone\Resources\EmptyStandbyList.exe" "https://wj32.org/wp/download/1455/"
curl -g -L -# -o "C:\Hone\Resources\DeviceCleanupCmd.zip" "https://www.uwe-sieber.de/files/DeviceCleanupCmd.zip"
curl -g -L -# -o "C:\Hone\Resources\AdwCleaner.exe" "https://adwcleaner.malwarebytes.com/adwcleaner?channel=release"
powershell -NoProfile Expand-Archive 'C:\Hone\Resources\DeviceCleanupCmd.zip' -DestinationPath 'C:\Hone\Resources\DeviceCleanupCmd\'
del /F /Q "C:\Hone\Resources\DeviceCleanupCmd.zip"
del /Q C:\Users\%username%\AppData\Local\Microsoft\Windows\INetCache\IE\*.*
del /Q C:\Windows\Downloaded Program Files\*.*
rd /s /q %SYSTEMDRIVE%\$Recycle.bin
del /Q C:\Users\%username%\AppData\Local\Temp\*.*
del /Q C:\Windows\Temp\*.*
del /Q C:\Windows\Prefetch\*.*
cd C:\Hone\Resources
AdwCleaner.exe /eula /clean /noreboot
for %%g in (workingsets modifiedpagelist standbylist priority0standbylist) do EmptyStandbyList.exe %%g
cd "C:\Hone\Resources\DeviceCleanupCmd\x64"
DeviceCleanupCmd.exe *
goto tweaks

:Backup
powershell Enable-ComputerRestore -Drive 'C:\', 'D:\', 'E:\', 'F:\', 'G:\' >nul 2>&1
powershell Checkpoint-Computer -Description 'Hone Restore Point' >nul 2>&1
for /F "tokens=2" %%i in ('date /t') do set date=%%i
set date1=%date:/=.%
md C:\Hone\HoneRevert\%date1%
reg export HKCU C:\Hone\HoneRevert\%date1%\HKLM.reg /y & reg export HKCU C:\Hone\HoneRevert\%date1%\HKCU.reg /y >nul 2>&1
cls
goto:eof

:Discord
start http://discord.gg/hone
goto More

:gameBooster
cls & echo Select the game location
set dialog="about:<input type=file id=FILE><script>FILE.click();new ActiveXObject
set dialog=%dialog%('Scripting.FileSystemObject').GetStandardStream(1).WriteLine(FILE.value);
set dialog=%dialog%close();resizeTo(0,0);</script>"
for /f "tokens=* delims=" %%p in ('mshta.exe %dialog%') do set "file=%%p"
if "%file%"=="" goto:eof
cls

for %%F in ("%file%") do Reg query "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "%file%" >nul 2>&1 && (
	Reg delete "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "%file%" /f
	Reg delete "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "%file%" /f
	Reg delete "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%%~nxF\PerfOptions" /v "CpuPriorityClass" /f
	echo Undo Game Optimizations
) || (
	Reg add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "%file%" /t Reg_SZ /d "GpuPreference=2;" /f
	Reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "%file%" /t Reg_SZ /d "~ DISABLEDXMAXIMIZEDWINDOWEDMODE" /f
	Reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%%~nxF\PerfOptions" /v "CpuPriorityClass" /t Reg_DWORD /d "3" /f
	echo GPU High Performance
	echo Disable Fullscreen Optimizations
	echo CPU High Class
) >nul 2>&1
echo.
choice /c:"CQ" /n /m "%BS%               [C] Continue  [Q] Quit" & if !errorlevel! equ 2 exit /b
goto:eof

:softRestart
cls
Mode 65,16
color 06
cd %temp%
echo Downloading NSudo [...]
if not exist "%temp%\NSudo.exe" curl -g -L -# -o "%temp%\NSudo.exe" "https://github.com/auraside/HoneCtrl/raw/main/Files/NSudo.exe"
NSudo.exe -U:S -ShowWindowMode:Hide cmd /c "Reg add "HKLM\SYSTEM\CurrentControlSet\Services\TrustedInstaller" /v "Start" /t Reg_DWORD /d "3" /f"
NSudo.exe -U:S -ShowWindowMode:Hide cmd /c "sc start "TrustedInstaller"
echo Downloading Restart64 [...]
if not exist "%temp%\restart64.exe" curl -g -L -# -o "%temp%\Restart64.exe" "https://github.com/auraside/HoneCtrl/raw/main/Files/restart64.exe"
echo Downloading EmptyStandbyList [...]
if not exist "%temp%\EmptyStandbyList.exe" curl -g -L -# -o "%temp%\EmptyStandbyList.exe" "https://wj32.org/wp/download/1455/"
cls

::Restart Explorer/DWM
echo Restarting Explorer [...]
rem taskkill /f /im explorer.exe >nul 2>&1
rem explorer.exe >nul 2>&1

::Refresh Internet
echo Refreshing Internet [...]
::Reset Firewall
echo netsh advfirewall reset >RefreshNet.bat
::Release the current IP address obtains a new one.
echo ipconfig /release >>RefreshNet.bat
echo ipconfig /renew >>RefreshNet.bat
::Delete and reacquire the hostname.
echo arp -d * >>RefreshNet.bat
::Purge and reload the remote cache name table.
echo nbtstat -R >>RefreshNet.bat
::Sends Name Release packets to WINS and then refreshes.
echo nbtstat -RR >>RefreshNet.bat
::Flush the DNS and Begin manual dynamic registration for DNS names and IP addresses.
echo ipconfig /flushdns >>RefreshNet.bat
echo ipconfig /registerdns >>RefreshNet.bat
NSudo -U:T -P:E -M:S -ShowWindowMode:Hide -wait cmd /c "%temp%\RefreshNet.bat"

::Restart Graphics Driver
echo Restarting Graphics Driver [...]
Restart64.exe

::Clean Standby List
echo Cleaning Standby List [...]
EmptyStandbyList.exe standbylist

::Finished
echo.
echo.
echo  --------------------------------------------------------------
echo                      Soft Restart Completed
echo  --------------------------------------------------------------
echo.
echo.
echo                             [X] Close
echo.
choice /c:X /n /m "%DEL%                                >:"
Mode 130,45
goto:eof



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

echo.                                          %COL%[33m+N.
echo.                               //        oMMs         
echo.                              +Nm`    ``yMMm-      ::::::::     ::::    :::    :::::::::: 
echo.                           ``dMMsoyhh-hMMd.      :+:    :+:    :+:+:   :+:    :+:  
echo.                           `yy/MMMMNh:dMMh`     +:+    +:+    :+:+:+  +:+    +:+                 +::+:+::      +::+:+::
echo.                          .hMM.sso++:oMMs`     +#+    +:+    +#+ +:+ +#+    +#++:++#           ++:    #++    ++:    #++
echo.                         -mMMy:osyyys.No      +#+    +#+    +#+  +#+#+#    +#+                +#+    +#+    +#+    +#+
echo.                        :NMMs-oo+/syy:-      #+#    #+#    #+#   #+#+#    #+#          #+#   #+#    #+#    #+#    #+#
echo.                       /NMN+ ``   :ys.       ########     ###    ####    ##########   ###     ########      ########
echo.                      `NMN:        +.                                                             ###           ###
echo.                      om-                                                                 ##     ###    ##     ###
echo.                       `.                                                                  ########      ########

echo.                                          %COL%[33m+N.
echo.                               //        oMMs         
echo.                              +Nm`    ``yMMm-               :::    :::     ::::::::     ::::    :::    :::::::::: 
echo.                           ``dMMsoyhh-hMMd.                :+:    :+:    :+:    :+:    :+:+:   :+:    :+:  
echo.                           `yy/MMMMNh:dMMh`               +:+    +:+    +:+    +:+    :+:+:+  +:+    +:+    
echo.                          .hMM.sso++:oMMs`               +#++:++#++    +#+    +:+    +#+ +:+ +#+    +#++:++#    
echo.                         -mMMy:osyyys.No                +#+    +#+    +#+    +#+    +#+  +#+#+#    +#+   
echo.                        :NMMs-oo+/syy:-                #+#    #+#    #+#    #+#    #+#   #+#+#    #+#   
echo.                       /NMN+ ``   :ys.                ###    ###     ########     ###    ####    ##########
echo.                      `NMN:        +.                
echo.                      om-                            
echo.                       `.                            

:ColorText
echo off
<nul set /p ".=%DEL%" > "%~2"
findstr /v /a:%1 /R "^$" "%~2" nul
del "%~2" > nul  
goto :eof

:HoneCtrlError
start "Warning" echo off ^& ^
Mode 65,16 ^& ^
color 06 ^& ^
echo. ^& ^
echo  -------------------------------------------------------------- ^& ^
echo                   This tweak is not applicable ^& ^
echo  -------------------------------------------------------------- ^& ^
echo. ^& ^
echo      You aren't able to use this optimization ^& ^
echo. ^& ^
echo      %~1 ^& ^
echo. ^& ^
echo. ^& ^
echo. ^& ^
echo. ^& ^
echo      [X] Close ^& ^
echo. ^& ^
choice /c:X /n /m "%DEL%                                >:" ^& ^
exit /b
goto:eof

:HoneCtrlRestart
setlocal DisableDelayedExpansion
if "%~2" equ "%COL%[91mOFF" (set "ed=enable") else (set "ed=disable")
start "Restart" cmd /V:ON /C @echo off ^& ^
Mode 65,16 ^& ^
color 06 ^& ^
echo. ^& ^
echo  -------------------------------------------------------------- ^& ^
echo                       Restart to fully apply ^& ^
echo  -------------------------------------------------------------- ^& ^
echo. ^& ^
echo      To %ed% %~1 you must restart, would ^& ^
echo      you like to restart now? ^& ^
echo. ^& ^
echo. ^& ^
echo. ^& ^
echo. ^& ^
echo      [Y] Yes ^& ^
echo      [N] No ^& ^
echo. ^& ^
choice /c:YNX /n /m "%DEL%                                >:" ^& ^
if !errorlevel! equ 1 ( ^
	shutdown /s /t 60 /c "A restart is required, we'll do that now" /f /d p:0:0 ^& ^
	timeout 5 ^& ^
	shutdown -a ^& ^
	shutdown /r /t 7 /c "Restarting automatically..." /f /d p:0:0 ^
) ^& ^
exit /b
setlocal EnableDelayedExpansion
goto:eof
