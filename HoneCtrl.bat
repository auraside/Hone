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
set PG=TweaksPG1

::Make Directories
mkdir C:\Hone >nul 2>&1
mkdir C:\Hone\Resources >nul 2>&1
mkdir C:\Hone\HoneRevert >nul 2>&1
mkdir C:\Hone\Drivers >nul 2>&1
cd C:\Hone

::Run as Admin
Reg.exe add HKLM /F >nul 2>&1
if %errorlevel% neq 0 start "" /wait /I /min powershell -NoProfile -Command start -verb runas "'%~s0'" && exit /b

::Blank/Color Character
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (set "DEL=%%a" & set "COL=%%b")

::Restart Checks
set firstlaunch=1
set justrestarted=0
if exist c:\hone\driverinstall.bat call driverinstall.bat
if %justrestarted% equ 1 (
cd C:\Hone\Drivers
set justrestarted=0
if exist C:\Hone\driverinstall.bat (del /Q C:\Hone\driverinstall.bat)
start NvidiaHone.exe
)

::Check for updates
set local=2.0
set localtwo=%local%
if exist "%temp%\Updater.bat" DEL /S /Q /F "%temp%\Updater.bat" >nul 2>&1
curl -o "%temp%\Updater.bat" https://pastebin.com/raw/HNwj139c >nul 2>&1
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
		start "C:\Users\%username%\Documents\HoneCtrl.bat"
		del %0
		exit /b
	)
	Mode 130,45
)

>nul 2>&1 call "C:\Hone\HoneRevert\firstlaunch.bat"
if %firstlaunch%==0 (goto Tweaks)

::Restore Point
powershell -ExecutionPolicy Unrestricted -NoProfile Enable-ComputerRestore -Drive 'C:\', 'D:\', 'E:\', 'F:\', 'G:\' >nul 2>&1
powershell -ExecutionPolicy Unrestricted -NoProfile Checkpoint-Computer -Description 'Hone Restore Point' >nul 2>&1

::HKCU & HKLM backup
for /F "tokens=2" %%i in ('date /t') do set date=%%i
set date1=%date:/=.%
>nul 2>&1 md C:\Hone\HoneRevert\%date1%
reg export HKCU C:\Hone\HoneRevert\%date1%\HKLM.reg /y >nul 2>&1
reg export HKCU C:\Hone\HoneRevert\%date1%\HKCU.reg /y >nul 2>&1
echo set firstlaunch=0 > C:\Hone\HoneRevert\firstlaunch.bat

:Tweaks
Mode 130,45
TITLE Hone Control Panel %localtwo%
set "BLANK=   "
::Check Values
for %%i in (PWROF MEMOF DRIOF TMROF MSIOF NETOF AFFOF MOUOF KBOOF BCDOF AFTOF PS0OF NICOF DSSOF SERVOF DEBOF MITOF DSCOF ME2OF NAGOF NPIOF CS0OF NVIOF) do (set "%%i=%COL%[92mON ") >nul 2>&1
(
	::Nvidia Drivers
	cd "%SystemDrive%\Program Files\NVIDIA Corporation\NVSMI"
	for /f "tokens=1 skip=1" %%a in ('nvidia-smi --query-gpu^=driver_version --format^=csv') do if "%%a" neq "497.09" set "DRIOF=%COL%[91mOFF
	::MSI Mode
	for /f %%g in ('wmic path win32_VideoController get PNPDeviceID ^| findstr /L "VEN_"') do (Reg query "HKLM\System\CurrentControlSet\Enum\%%g\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" | find "0x3" || set "MSIOF=%COL%[91mOFF")
	::MSI AfterBurner
	if not exist "C:\Program Files (x86)\MSI Afterburner\Skins\Hone.usf" set "AFTOF=%COL%[91mOFF"
	::PStates0
	For /F "tokens=*" %%i in ('reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /t REG_SZ /s /e /f "NVIDIA" ^| findstr "HK"') do (Reg query "%%i" /v "DisableDynamicPstate" | find "0x1" || set "PS0OF=%COL%[91mOFF")
	::Services Optimization
	for /f "tokens=2 delims==" %%i in ('wmic os get TotalVisibleMemorySize /value') do (set /a mem=%%i + 1024000)
	for /f "tokens=3" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control" /v "SvcHostSplitThresholdInKB"') do (set /a currentmem=%%a)
	if "!currentmem!" neq "!mem!" set "MEMOF=%COL%[91mOFF"
	::Power Plan
	powercfg /GetActiveScheme | find "Hone" || set "PWROF=%COL%[91mOFF"
	::Timer Res
	sc query STR | find "RUNNING" || set "TMROF=%COL%[91mOFF"
	::Profile Inspector Tweaks
	Reg query "HKCU\Software\Hone" /v "NpiTweaks" || set "NPIOF=%COL%[91mOFF"
	::Nvidia Tweaks
	Reg query "HKCU\Software\Hone" /v "NvidiaTweaks" || set "NVIOF=%COL%[91mOFF"
	::Memory Optimization
	Reg query "HKCU\Software\Hone" /v "MemoryTweaks" || set "ME2OF=%COL%[91mOFF"
	::Network Internet Tweaks
	Reg query "HKCU\Software\Hone" /v "InternetTweaks" || set "NETOF=%COL%[91mOFF"
	::Services Tweaks
	Reg query "HKCU\Software\Hone" /v "ServicesTweaks" || set "SERVOF=%COL%[91mOFF"
	::Nagle Tweaks
	Reg query "HKLM\Software\Microsoft\MSMQ\Parameters" /v "TCPNoDelay" | find "0x1" || set "NAGOF=%COL%[91mOFF"
	::Debloat Tweaks
	Reg query "HKCU\Software\Hone" /v "DebloatTweaks" || set "DEBOF=%COL%[91mOFF"
	::Mitigations Tweaks
	Reg query "HKCU\Software\Hone" /v "MitigationsTweaks" || set "MITOF=%COL%[91mOFF"
	::Affinities
	Reg query "HKCU\Software\Hone" /v "AffinityTweaks" || set "AFFOF=%COL%[91mOFF"
	::Mouse Fix
	Reg query "HKCU\Control Panel\Mouse" /v "SmoothMouseYCurve" | find "0000000000000000000038000000000000007000000000000000A800000000000000E00000000000" || set "MOUOF=%COL%[91mOFF"
	::KBoost
	for /f %%a in ('reg query "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Class" /v "VgaCompatible" /s ^| findstr "HKEY"') do (Reg query "%%a" /v "PowerMizerLevel" | find "0x1" || set "KBOOF=%COL%[91mOFF")
	::BCDEDIT
	Reg query "HKCU\Software\Hone" /v "BcdEditTweaks" || set "BCDOF=%COL%[91mOFF"
	::NIC
	if not exist "%SystemDrive%\Hone\HoneRevert\ognic.reg" set "NICOF=%COL%[91mOFF"
	::Intel iGPU
	Reg query "HKLM\SOFTWARE\Intel\GMM" /v "DedicatedSegmentSize" | find "0x400" || set "DSSOF=%COL%[91mOFF"
	::DSCP Tweaks
	Reg query "HKLM\Software\Policies\Microsoft\Windows\QoS\javaw" || set "DSCOF=%COL%[91mOFF"
	::CS0 Tweak
	Reg query "HKLM\SYSTEM\ControlSet002\Control\Class\{4D36E968-E325-11CE-BFC1-08002BE10318}\0000" /v "AllowDeepCStates" | find "0x0" || set "CS0OF=%COL%[91mOFF"
::Check If Applicable For PC
	::Laptop
	wmic path Win32_Battery Get BatteryStatus | find "1" && set "PWROF=%COL%[93mN/A"
	::GPU
	for /f "tokens=2 delims==" %%n in ('wmic path Win32_VideoController get VideoProcessor /value') do set GPU_NAME=%%n
	for %%n in (GeForce NVIDIA RTX GTX) do echo !GPU_NAME! | find "%%n" >nul && (
		for %%g in (DSSOF AMDOF) do set "%%g=%COL%[93mN/A"
		goto GPUFound
	)
	for %%n in (AMD Ryzen) do echo !GPU_NAME! | find "%%n" >nul && (
		for %%g in (KBOOF AFTOF NPIOF DRIOF NVIOF PS0OF DSSOF) do set "%%g=%COL%[93mN/A"
		goto GPUFound
	)
	for %%n in (Intel UHD) do echo !GPU_NAME! | find "%%n" >nul && (
		for %%g in (KBOOF AFTOF NPIOF DRIOF NVIOF PS0OF AMDOF) do set "%%g=%COL%[93mN/A"
		goto GPUFound
	)
) >nul 2>&1
:GPUFound

goto %PG%
:TweaksPG1
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
echo                                                               %COL%[34m%COL%[1mTweaks%COL%[0m
echo.
echo              %COL%[33m[%COL%[37m 1 %COL%[33m]%COL%[37m Power Plan %PWROF%                 %COL%[33m[%COL%[37m 2 %COL%[33m]%COL%[37m SvcHostSplitThreshold %MEMOF%      %COL%[33m[%COL%[37m 3 %COL%[33m]%COL%[37m BCDEdit %BCDOF%
echo              %COL%[90mDesktop Power Plan, not good         %COL%[90mChanges the split threshold for      %COL%[90mTweaks your windows boot config
echo              %COL%[90mto use with a laptop battery.        %COL%[90mservice host to your RAM             %COL%[90mdata to optimized settings
echo.
echo              %COL%[33m[%COL%[37m 4 %COL%[33m]%COL%[37m Timer Resolution %TMROF%           %COL%[33m[%COL%[37m 5 %COL%[33m]%COL%[37m MSI Mode %MSIOF%                   %COL%[33m[%COL%[37m 6 %COL%[33m]%COL%[37m Affinity %AFFOF%
echo              %COL%[90mThis tweak changes how fast          %COL%[90mEnable MSI Mode for gpu and          %COL%[90mThis tweak will spread devices
echo              %COL%[90myour cpu refreshes                   %COL%[90mmnetwork adapters                    %COL%[90mon multiple cpu cores
echo.
echo              %COL%[33m[%COL%[37m 7 %COL%[33m]%COL%[37m W32 Priority Seperation %BLANK%    %COL%[33m[%COL%[37m 8 %COL%[33m]%COL%[37m Memory Optimization %ME2OF%        %COL%[33m[%COL%[37m 9 %COL%[33m]%COL%[37m Mouse Fix %MOUOF%
echo              %COL%[90mOptimizes the usage priority of      %COL%[90mOptimizes your fsutil, win           %COL%[90mThis removes acceleration which
echo              %COL%[90myour running services                %COL%[90mstartup settings and more            %COL%[90mmakes your aim unconsistent
echo.
echo.
echo                                                            %COL%[34m%COL%[1mNvidia Tweaks%COL%[0m
echo.
echo              %COL%[33m[%COL%[37m 10 %COL%[33m]%COL%[37m KBoost %KBOOF%                    %COL%[33m[%COL%[37m 11 %COL%[33m]%COL%[37m MSI AfterBurner %AFTOF%           %COL%[33m[%COL%[37m 12 %COL%[33m]%COL%[37m ProfileInspector %NPIOF%
echo              %COL%[90mLock your gpu at its boost clock     %COL%[90mThis will install MSI Afterburner    %COL%[90mwill edit your Nvidia control panel
echo              %COL%[90mfor lower latency and higher fps     %COL%[90malong with the Hone skin             %COL%[90mand add various tweaks
echo.
echo              %COL%[33m[%COL%[37m 13 %COL%[33m]%COL%[37m Nvidia Drivers %DRIOF%            %COL%[33m[%COL%[37m 14 %COL%[33m]%COL%[37m Nvidia Tweaks %NVIOF%             %COL%[33m[%COL%[37m 15 %COL%[33m]%COL%[37m PStates 0 %PS0OF%
echo              %COL%[90mInstall the best tweaked nvidia      %COL%[90mVarious essential tweaks for         %COL%[90mRun graphics card at its highest
echo              %COL%[90mdriver for latency and fps           %COL%[90mNvidia graphics cards                %COL%[90mdefined frequencies
echo.
echo.
echo                                     %COL%[31m[ X to close ]         %COL%[90m[ M for more ]         %COL%[36m[ N next page ]
echo.
set /p choice="%DEL%                                         %COL%[37mSelect a corresponding number to what you'd like > "
if /i "%choice%"=="1" goto PowerPlan
if /i "%choice%"=="2" goto ServicesOptimization
if /i "%choice%"=="3" goto BCDEdit
if /i "%choice%"=="4" goto TimerRes
if /i "%choice%"=="5" goto MSI
if /i "%choice%"=="6" goto Affinity
if /i "%choice%"=="7" goto W32PrioSep
if /i "%choice%"=="8" goto MemOptimization
if /i "%choice%"=="9" goto Mouse
echo %NPIOF% | find "N/A" >nul && if "%choice%" geq "10" if "%choice%" leq "15" call :HoneCtrlError "You don't have an NVIDIA GPU" && goto Tweaks
if /i "%choice%"=="10" goto KBoost
if /i "%choice%"=="11" goto MSIAfterBurner
if /i "%choice%"=="12" goto ProfileInspector
if /i "%choice%"=="13" goto Drivers
if /i "%choice%"=="14" goto NvidiaTweaks
if /i "%choice%"=="15" goto PStates0
if /i "%choice%"=="R" call:Revert
if /i "%choice%"=="X" exit /b
if /i "%choice%"=="M" call:More
if /i "%choice%"=="N" (set "PG=TweaksPG2") & goto TweaksPG2
goto Tweaks

:TweaksPG2
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
echo                                                               %COL%[34m%COL%[1mBloat%COL%[0m
echo.
echo              %COL%[33m[%COL%[37m 1 %COL%[33m]%COL%[37m Disable Services %SERVOF%           %COL%[33m[%COL%[37m 2 %COL%[33m]%COL%[37m Debloat %DEBOF%                    %COL%[33m[%COL%[37m 3 %COL%[33m]%COL%[37m Disable Mitigations %MITOF%
echo              %COL%[90mDisables services and lowers memory  %COL%[90mThis tweak will debloat your         %COL%[90mDisable protections against memory
echo              %COL%[90mDon't use if you are using Wi-Fi     %COL%[90msystem and disable telemetry         %COL%[90mbased attacks that consume perf
echo.
echo.
echo                                                           %COL%[34m%COL%[1mNetwork Tweaks%COL%[0m
echo.
echo              %COL%[33m[%COL%[37m 4 %COL%[33m]%COL%[37m Optimize TCP/IP %BLANK%            %COL%[33m[%COL%[37m 5 %COL%[33m]%COL%[37m Optimize NIC %NICOF%               %COL%[33m[%COL%[37m 6 %COL%[33m]%COL%[37m Optimize Netsh %NETOF%
echo              %COL%[90mTweaks your Internet Protocol        %COL%[90mOptimize your Network Card settings  %COL%[90mThis tweak will optimize your
echo              %COL%[90mDon't use if you are using Wi-Fi     %COL%[90mDon't use if you are using Wi-Fi     %COL%[90mcomputer network configuration
echo.
echo                           %COL%[33m[ %COL%[37m7 %COL%[33m]%COL%[37m Disable Nagles Algorithm %NAGOF%          %COL%[33m[ %COL%[37m8 %COL%[33m]%COL%[37m DSCP Value %DSCOF%
echo                           %COL%[90mThis tweak will disable Nagle an            %COL%[90mSet the priority of your network
echo                           %COL%[90mremove delays on internet speed             %COL%[90mtraffic to expedited forwarding
echo.
echo.
echo                                                             %COL%[34m%COL%[1mGPU ^& CPU%COL%[0m
echo.
echo              %COL%[33m[%COL%[37m 9 %COL%[33m]%COL%[37m Disable C-States %CS0OF%           %COL%[33m[%COL%[37m 10 %COL%[33m]%COL%[37m Optimize Intel iGPU %DSSOF%       %COL%[33m[%COL%[37m 11 %COL%[33m]%COL%[37m AMD GPU Tweaks %AMDOF%
echo              %COL%[90mKeep CPU at C0 stopping throttling,  %COL%[90mIncrease dedicated video vram on     %COL%[90mConfigure AMD GPU to optimized
echo              %COL%[90mwill make PC generate more heat      %COL%[90ma intel iGPU                         %COL%[90msettings
echo.
echo.
echo.
echo                                     %COL%[31m[ X to close ]         %COL%[90m[ M for more ]         %COL%[36m[ N next page ]
echo.
set /p choice="%DEL%                                         %COL%[37mSelect a corresponding number to what you'd like > "
if /i "%choice%"=="1" goto Service
if /i "%choice%"=="2" goto Debloat
if /i "%choice%"=="3" goto Mitigations
if /i "%choice%"=="4" goto TCPIP
if /i "%choice%"=="5" goto NIC
if /i "%choice%"=="6" goto Netsh
if /i "%choice%"=="7" goto DisableNagle
if /i "%choice%"=="8" goto DSCValue
if /i "%choice%"=="9" goto cstates
if /i "%choice%"=="10" goto Intel
if /i "%choice%"=="11" goto AMD
if /i "%choice%"=="R" call:Revert
if /i "%choice%"=="X" exit /b
if /i "%choice%"=="M" call:More
if /i "%choice%"=="N" (set "PG=TweaksPG1") & goto TweaksPG1
goto TweaksPG2

:PowerPlan
echo %PWROF% | find "N/A" >nul && call :HoneCtrlError "You are on AC power, this power plan isn't recommended." && goto Tweaks
curl -o "C:\Hone\Resources\HoneV2.pow" "https://github.com/auraside/HoneCtrl/raw/main/Files/HoneV2.pow" >nul 2>&1
powercfg /d 44444444-4444-4444-4444-444444444449 >nul 2>&1
powercfg -import "C:\Hone\Resources\HoneV2.pow" 44444444-4444-4444-4444-444444444449 >nul 2>&1
powercfg /changename 44444444-4444-4444-4444-444444444449 "Hone Ultimate Power Plan V2" "The Ultimate Power Plan to increase FPS, improve latency and reduce input lag." >nul 2>&1

::Enable Idle on Hyper-Threading
set THREADS=%NUMBER_OF_PROCESSORS%
for /f "tokens=2 delims==" %%n in ('wmic cpu get numberOfCores /value') do set CORES=%%n
IF "%CORES%" EQU "%NUMBER_OF_PROCESSORS%" (
	powercfg -setacvalueindex 44444444-4444-4444-4444-444444444449 sub_processor 5d76a2ca-e8c0-402f-a133-2158492d58ad 1
)
	powercfg -setacvalueindex 44444444-4444-4444-4444-444444444449 sub_processor 5d76a2ca-e8c0-402f-a133-2158492d58ad 0
)

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
	::Better Input
	bcdedit /set tscsyncpolicy legacy
	::Quick Boot
	if "%duelboot%" equ "no" (bcdedit /timeout 3)
	bcdedit /set bootux disabled
	bcdedit /set bootmenupolicy standard
	bcdedit /set hypervisorlaunchtype off
	bcdedit /set tpmbootentropy ForceDisable
	bcdedit /set quietboot yes
	::Windows 8 Boot Stuff (windows 8.1)
	for /f "tokens=4-9 delims=. " %%i in ('ver') do set winversion=%%i.%%j
	if "!winversion!" == "6.3.9600" (
	bcdedit /set {globalsettings} custom:16000067 true
	bcdedit /set {globalsettings} custom:16000069 true
	bcdedit /set {globalsettings} custom:16000068 true
	)
	::nx
	set CPU_NAME=%PROCESSOR_IDENTIFIER%
	if not "!CPU_NAME:AMD=!" == "!CPU_NAME!" (
	bcdedit /set nx optout
	) else (
	bcdedit /set nx alwaysoff
	)
	::Linear Address 57
	bcdedit /set linearaddress57 OptOut
	bcdedit /set increaseuserva 268435328
	::Disable some of the kernel memory mitigations
	bcdedit /set allowedinmemorysettings 0x0
	bcdedit /set isolatedcontext No
	::Disable DMA memory protection and cores isolation
	bcdedit /set vsmlaunchtype Off
	bcdedit /set vm No
	Reg add "HKLM\Software\Policies\Microsoft\FVE" /v "DisableExternalDMAUnderLock" /t Reg_DWORD /d "0" /f
	Reg add "HKLM\Software\Policies\Microsoft\Windows\DeviceGuard" /v "EnableVirtualizationBasedSecurity" /t Reg_DWORD /d "0" /f
	Reg add "HKLM\Software\Policies\Microsoft\Windows\DeviceGuard" /v "HVCIMATRequired" /t Reg_DWORD /d "0" /f
	::Avoid using uncontiguous low-memory. Boosts memory performance & microstuttering.
	bcdedit /set firstmegabytepolicy UseAll
	bcdedit /set avoidlowmemory 0x8000000
	bcdedit /set nolowmem Yes
	::Enable X2Apic and enable Memory Mapping for PCI-E devices
	bcdedit /set x2apicpolicy Enable
	bcdedit /set configaccesspolicy Default
	bcdedit /set MSI Default
	bcdedit /set usephysicaldestination No
	bcdedit /set usefirmwarepcisettings No
	bcdedit /set uselegacyapicmode yes
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
	bcdedit /deletevalue linearaddress57
	bcdedit /deletevalue increaseuserva
	::Disable some of the kernel memory mitigations
	bcdedit /set allowedinmemorysettings 0x17000077
	bcdedit /set isolatedcontext Yes
	::Disable DMA memory protection and cores isolation
	bcdedit /deletevalue vsmlaunchtype
	bcdedit /deletevalue vm
	Reg add "HKLM\Software\Policies\Microsoft\FVE" /v "DisableExternalDMAUnderLock" /t Reg_DWORD /d "0" /f
	Reg add "HKLM\Software\Policies\Microsoft\Windows\DeviceGuard" /v "EnableVirtualizationBasedSecurity" /t Reg_DWORD /d "0" /f
	Reg add "HKLM\Software\Policies\Microsoft\Windows\DeviceGuard" /v "HVCIMATRequired" /t Reg_DWORD /d "0" /f
	bcdedit /deletevalue firstmegabytepolicy
	bcdedit /deletevalue avoidlowmemory
	bcdedit /deletevalue nolowmem
	bcdedit /deletevalue configaccesspolicy
	bcdedit /deletevalue MSI
	bcdedit /deletevalue x2apicpolicy
	bcdedit /deletevalue usephysicaldestination
	bcdedit /deletevalue usefirmwarepcisettings
	bcdedit /deletevalue uselegacyapicmode
) >nul 2>&1
goto Tweaks

:TimerRes
cd C:\Hone
if "%TMROF%" equ "%COL%[91mOFF" (
	if not exist SetTimerResolutionService.exe (
		::https://forums.guru3d.com/threads/windows-timer-resolution-tool-in-form-of-system-service.376458/
		curl -o "C:\Hone\SetTimerResolutionService.exe" "https://github.com/auraside/HoneCtrl/raw/main/Files/SetTimerResolutionService.exe" >nul 2>&1
		%windir%\Microsoft.NET\Framework\v4.0.30319\InstallUtil.exe /i SetTimerResolutionService.exe >nul 2>&1
	)
	sc config "STR" start=auto >nul 2>&1
	start /b net start STR >nul 2>&1
	bcdedit /set useplatformtick yes >nul 2>&1
	bcdedit /set disabledynamictick yes >nul 2>&1
) else (
	sc config "STR" start=disabled >nul 2>&1
	start /b net stop STR >nul 2>&1
	bcdedit /deletevalue useplatformclock >nul 2>&1
	bcdedit /deletevalue useplatformtick >nul 2>&1
	bcdedit /deletevalue disabledynamictick >nul 2>&1
)
goto tweaks

:KBoost
if "%KBOOF%" equ "%COL%[91mOFF" (
	for /f %%a in ('reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class" /v "VgaCompatible" /s ^| findstr "HKEY"') do (
		Reg add "%%a" /v "PowerMizerEnable" /t REG_DWORD /d "1" /f >nul 2>&1
		Reg add "%%a" /v "PowerMizerLevel" /t REG_DWORD /d "1" /f >nul 2>&1
		Reg add "%%a" /v "PowerMizerLevelAC" /t REG_DWORD /d "1" /f >nul 2>&1
		Reg add "%%a" /v "PerfLevelSrc" /t REG_DWORD /d "8738" /f >nul 2>&1
	)
) else (
	for /f %%a in ('reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class" /v "VgaCompatible" /s ^| findstr "HKEY"') do (
		Reg delete "%%a" /v "PowerMizerEnable" /f >nul 2>&1
		Reg delete "%%a" /v "PowerMizerLevel" /f >nul 2>&1
		Reg delete "%%a" /v "PowerMizerLevelAC" /f >nul 2>&1
		Reg delete "%%a" /v "PerfLevelSrc" /f >nul 2>&1
	)
)
cls
echo Your PC needs to restart to apply these changes
echo.
echo Would you like to restart now?
choice /c:YN /n /m "[Y] Yes  [N] No"
if %errorlevel% equ 2 goto Tweaks
copy "%~f0" "C:\Users\%username%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\HoneCtrl.bat"
shutdown /s /t 60 /c "KBoost requires a restart, we'll do that now" /f /d p:0:0
timeout 5 >nul 2>&1
shutdown -a
shutdown /r /t 7 /c "Restarting automatically..." /f /d p:0:0
pause & exit /b

:MSI
if "%MSIOF%" equ "%COL%[91mOFF" (
	for /f %%g in ('wmic path win32_VideoController get PNPDeviceID ^| findstr /L "VEN_"') do Reg add "HKLM\SYSTEM\CurrentControlSet\Enum\%%g\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /t REG_DWORD /d "1" /f >nul 2>&1
	for /f %%g in ('wmic path win32_VideoController get PNPDeviceID ^| findstr /L "VEN_"') do Reg add "HKLM\System\CurrentControlSet\Enum\%%g\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" /t REG_DWORD /d "3" /f >nul 2>&1
	for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID ^| findstr /L "VEN_"') do Reg add "HKLM\SYSTEM\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /t REG_DWORD /d "1" /f >nul 2>&1
	for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID ^| findstr /L "VEN_"') do Reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority " /t REG_DWORD /d "3" /f >nul 2>&1
) else (
	for /f %%g in ('wmic path win32_VideoController get PNPDeviceID ^| findstr /L "VEN_"') do Reg delete "HKLM\SYSTEM\CurrentControlSet\Enum\%%g\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /f >nul 2>&1
	for /f %%g in ('wmic path win32_VideoController get PNPDeviceID ^| findstr /L "VEN_"') do Reg delete "HKLM\System\CurrentControlSet\Enum\%%g\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" /f >nul 2>&1
	for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID ^| findstr /L "VEN_"') do Reg delete "HKLM\SYSTEM\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /f >nul 2>&1
	for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID ^| findstr /L "VEN_"') do Reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority " /f >nul 2>&1
)
goto Tweaks

:TCPIP
cls
Reg add "HKLM\Software\Policies\Microsoft\Windows\OneDrive" /v "DisableFileSyncNGSC" /t Reg_DWORD /d "1" /f
Reg add "HKLM\System\CurrentControlSet\Control\Nsi\{eb004a03-9b1a-11d4-9123-0050047759bc}\0" /v "0200" /t Reg_BINARY /d "0000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000ff000000000000000000000000000000000000000000ff000000000000000000000000000000" /f 
Reg add "HKLM\System\CurrentControlSet\Control\Nsi\{eb004a03-9b1a-11d4-9123-0050047759bc}\0" /v "1700" /t Reg_BINARY /d "0000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000ff000000000000000000000000000000000000000000ff000000000000000000000000000000" /f 
Reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v "MaxConnectionsPerServer" /t Reg_DWORD /d "16" /f 
Reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v "MaxConnectionsPer1_0Server" /t Reg_DWORD /d "16" /f 
Reg add "HKLM\Software\Policies\Microsoft\Windows\Psched" /v "NonBestEffortLimit" /t Reg_DWORD /d "0" /f
Reg add "HKLM\Software\Policies\Microsoft\Windows\Psched" /v MaxOutstandingSends /t Reg_DWORD /d 0 /f
Reg add "HKLM\Software\Policies\Microsoft\Windows\Psched" /v "TimerResolution" /t Reg_DWORD /d "1" /f
Reg add "HKLM\System\CurrentControlSet\Services\Tcpip\QoS" /v "Do not use NLA" /t Reg_DWORD /d "1" /f
Reg add "HKLM\System\CurrentControlSet\Services\AFD\Parameters" /v "DoNotHoldNicBuffers" /t Reg_DWORD /d "1" /f
Reg add "HKLM\Software\Policies\Microsoft\Windows NT\DNSClient" /v "EnableMulticast" /t Reg_DWORD /d "0" /f
Reg add "HKLM\System\CurrentControlSet\Services\Tcpip\ServiceProvider" /v "LocalPriority" /t Reg_DWORD /d "4" /f
Reg add "HKLM\System\CurrentControlSet\Services\Tcpip\ServiceProvider" /v "HostsPriority" /t Reg_DWORD /d "5" /f
Reg add "HKLM\System\CurrentControlSet\Services\Tcpip\ServiceProvider" /v "DnsPriority" /t Reg_DWORD /d "6" /f
Reg add "HKLM\System\CurrentControlSet\Services\Tcpip\ServiceProvider" /v "NetbtPriority" /t Reg_DWORD /d "7" /f
Reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Settings" /v "DownloadMode" /t Reg_DWORD /d "0" /f
Reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t Reg_DWORD /d "10" /f
Reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t Reg_DWORD /d "0" /f
Reg add HKLM\System\CurrentControlSet\Services\Tcpip\Parameters /v "MaxUserPort" /t Reg_DWORD /d "65534" /f 
Reg add HKLM\System\CurrentControlSet\Services\Tcpip\Parameters /v "TcpTimedWaitDelay" /t Reg_DWORD /d "30" /f 
Reg add HKLM\System\CurrentControlSet\Services\Tcpip\Parameters /v "EnableWsd" /t Reg_DWORD /d "0" /f 
Reg add HKLM\System\CurrentControlSet\Services\Tcpip\Parameters /v "DisableDynamicDiscovery" /t Reg_DWORD /d 0 /f
Reg add HKLM\System\CurrentControlSet\Services\Tcpip\Parameters /v "Tcp1323Opts" /t Reg_DWORD /d "1" /f  
Reg add HKLM\System\CurrentControlSet\Services\Tcpip\Parameters /v "TCPCongestionControl" /t Reg_DWORD /d "1" /f 
Reg add HKLM\System\CurrentControlSet\Services\Tcpip\Parameters /v "DisableTaskOffload" /t Reg_DWORD /d "0" /f
Reg add HKLM\System\CurrentControlSet\Services\Tcpip\Parameters /v TcpMaxDupAcks /t Reg_DWORD /d 2 /f
Reg add HKLM\System\CurrentControlSet\Services\Tcpip\Parameters /v DefaultTTL /t Reg_DWORD /d 64 /f
Reg add HKLM\System\CurrentControlSet\Services\Tcpip\Parameters /v EnablePMTUDiscovery /t Reg_DWORD /d 1 /f
Reg add HKLM\System\CurrentControlSet\Services\Tcpip\Parameters /v EnablePMTUBDetect /t Reg_DWORD /d 0 /f
Reg add HKLM\System\CurrentControlSet\Services\Tcpip\Parameters /v SackOpts /t Reg_DWORD /d 1 /f
Reg add HKLM\System\CurrentControlSet\Services\Tcpip\Parameters /v "MaxFreeTcbs" /t Reg_DWORD /d "65535" /f
Reg add HKLM\System\CurrentControlSet\Services\Tcpip\Parameters /v "EnableConnectionRateLimiting" /t Reg_DWORD /d "0" /f
Reg add HKLM\System\CurrentControlSet\Services\Tcpip\Parameters /v "EnableDCA" /t Reg_DWORD /d "1" /f
Reg add HKLM\System\CurrentControlSet\Services\Tcpip\Parameters /v "EnableICMPRedirect" /t Reg_DWORD /d "0" /f
Reg add HKLM\System\CurrentControlSet\Services\Tcpip\Parameters /v "EnableIPAutoConfigurationLimits" /t Reg_DWORD /d "1" /f
Reg add HKLM\System\CurrentControlSet\Services\Tcpip\Parameters /v "EnablePMTUBHDetect" /t Reg_DWORD /d "0" /f
Reg add HKLM\System\CurrentControlSet\Services\Tcpip\Parameters /v "EnableRSS" /t Reg_DWORD /d "0" /f
Reg add HKLM\System\CurrentControlSet\Services\Tcpip\Parameters /v "EnableTCPA" /t Reg_DWORD /d "0" /f
Reg add HKLM\System\CurrentControlSet\Services\Tcpip\Parameters /v "EnableTCPChimney" /t Reg_DWORD /d "0" /f
Reg add HKLM\System\CurrentControlSet\Services\Tcpip\Parameters /v "TcpMaxConnectResponseRetransmissions" /t Reg_DWORD /d "2" /f
Reg add HKLM\System\CurrentControlSet\Services\Tcpip\Parameters /v "SynAttackProtect" /t Reg_DWORD /d "1" /f
Reg add HKLM\System\CurrentControlSet\Services\Tcpip\Parameters /v "MaxHashTableSize" /t Reg_DWORD /d "65536" /f
Reg add HKLM\System\CurrentControlSet\Services\Tcpip\Parameters /v "NoNameReleaseOnDemand" /t Reg_DWORD /d "1" /f
Reg add HKLM\System\CurrentControlSet\Services\Tcpip\Parameters /v "NumTcbTablePartitions" /t Reg_DWORD /d "0" /f
Reg add HKLM\System\CurrentControlSet\Services\Tcpip\Parameters /v "TcpMaxDataRetransmissions" /t Reg_DWORD /d "5" /f
Reg add HKLM\System\CurrentControlSet\Services\Tcpip\Parameters /v "QualifyingDestinationThreshold" /t Reg_DWORD /d "3" /f
Reg add HKLM\System\CurrentControlSet\Services\Tcpip\Parameters /v "StrictTimeWaitSeqCheck" /t Reg_DWORD /d "1" /f
Reg add HKLM\System\CurrentControlSet\Services\Tcpip\Parameters /v "TcpCreateAndConnectTcbRateLimitDepth" /t Reg_DWORD /d "0" /f
Reg add HKLM\System\CurrentControlSet\Services\Tcpip\Parameters /v "TcpFinWait1Delay" /t Reg_DWORD /d "30" /f
Reg add HKLM\System\CurrentControlSet\Services\Tcpip\Parameters /v "TcpMaxConnectRetransmissions" /t Reg_DWORD /d "2" /f
Reg add HKLM\System\CurrentControlSet\Services\Tcpip\Parameters /v "TcpMaxDataRetransmissions" /t Reg_DWORD /d "3" /f
Reg add HKLM\System\CurrentControlSet\Services\Tcpip\Parameters /v "TcpNumConnections" /t Reg_DWORD /d "65534" /f
Reg add HKLM\System\CurrentControlSet\Services\Tcpip\Parameters /v "TcpMaxSendFree" /t Reg_DWORD /d "65535" /f
Reg add HKLM\System\CurrentControlSet\Services\Tcpip\Parameters /v "UseDomainNameDevolution" /t Reg_DWORD /d "1" /f
for /f "tokens=3*" %%i in ('Reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkCards" /f "ServiceName" /s ^|findstr /i /l "ServiceName"') do (
Reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%s" /v "UseZeroBroadcast" /t Reg_DWORD /d "1" /f
Reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%s" /v "TcpInitialRTT" /t Reg_DWORD /d "3000" /f
Reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%s" /v "PerformRouterDiscovery" /t Reg_DWORD /d "1" /f
)
Reg add "HKLM\Software\Software\Policies\Microsoft\Windows\BITS" /v "EnableBITSMaxBandwidth" /t Reg_DWORD /d "1" /f
Reg add "HKLM\Software\Software\Policies\Microsoft\Windows\BITS" /v "MaxBandwidthValidFrom" /t Reg_DWORD /d "8" /f
Reg add "HKLM\Software\Software\Policies\Microsoft\Windows\BITS" /v "MaxBandwidthValidTo" /t Reg_DWORD /d "14" /f
Reg add "HKLM\Software\Software\Policies\Microsoft\Windows\BITS" /v "MaxTransferRateOffSchedule" /t Reg_DWORD /d "11" /f
Reg add "HKLM\Software\Software\Policies\Microsoft\Windows\BITS" /v "MaxTransferRateOnSchedule" /t Reg_DWORD /d "10" /f
Reg add "HKLM\Software\Software\Policies\Microsoft\Windows\BITS" /v "UseSystemMaximum" /t Reg_DWORD /d "1" /f
Reg add "HKLM\System\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v "SizReqBuf" /t Reg_DWORD /d "17424" /f
Reg add "HKLM\System\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v "IRPStackSize" /t Reg_DWORD /d "32" /f
Reg add "HKLM\System\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v "autodisconnect" /t Reg_DWORD /d "4294967295" /f
Reg add "HKLM\System\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v "AutoShareWks" /t Reg_DWORD /d "0" /f
Reg add "HKLM\System\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v "DisableBandwidthThrottling" /t Reg_DWORD /d "1" /f
Reg add "HKLM\System\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v "DisableDos" /t Reg_DWORD /d "0" /f
Reg add "HKLM\System\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v "DisableLargeMtu" /t Reg_DWORD /d "0" /f
Reg add "HKLM\System\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v "DisableStrictNameChecking" /t Reg_DWORD /d "1" /f
Reg add "HKLM\System\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v "EnableOplocks" /t Reg_DWORD /d "0" /f
Reg add "HKLM\System\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v "KeepConn" /t Reg_DWORD /d "15180" /f
Reg add "HKLM\System\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v "MaxCmds" /t Reg_DWORD /d "40" /f
Reg add "HKLM\System\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v "MaxCollectionCount" /t Reg_DWORD /d "20" /f
Reg add "HKLM\System\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v "MaxFreeConnections" /t Reg_DWORD /d "64" /f
Reg add "HKLM\System\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v "MinFreeConnections" /t Reg_DWORD /d "20" /f
Reg add "HKLM\System\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v "MaxMpxCt" /t Reg_DWORD /d "800" /f
Reg add "HKLM\System\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v "MaxRawWorkItems" /t Reg_DWORD /d "200" /f
Reg add "HKLM\System\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v "MaxThreads" /t Reg_DWORD /d "40" /f
Reg add "HKLM\System\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v "MaxWorkItems" /t Reg_DWORD /d "2000" /f
Reg add "HKLM\System\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v "SBM2" /t Reg_DWORD /d "0" /f
Reg add "HKLM\System\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v "SharingViolationDelay" /t Reg_DWORD /d "0" /f
Reg add "HKLM\System\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v "SharingViolationRetries" /t Reg_DWORD /d "0" /f
Reg add "HKLM\System\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v "Size" /t Reg_DWORD /d "3" /f
goto Tweaks

:NIC
cd %SystemDrive%\Hone\HoneRevert
if "%NICOF%" neq "%COL%[91mOFF" (
	reg import ognic.reg >nul 2>&1
	del ognic.reg
	goto Tweaks
)
for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID ^| findstr /L "PCI\VEN_"') do for /f "tokens=3" %%a in ('reg query "HKLM\SYSTEM\ControlSet001\Enum\%%i" /v "Driver" ^| findstr /L "{"') do (
reg export "HKLM\SYSTEM\ControlSet001\Control\Class\%%a" "C:\Hone\HoneRevert\ognic.reg" /y
::Disable Keys w "*"
Reg add "HKLM\SYSTEM\ControlSet001\Control\Class\%%a" /v "*WakeOnMagicPacket" /t REG_SZ /d "0" /f
Reg add "HKLM\SYSTEM\ControlSet001\Control\Class\%%a" /v "*WakeOnPattern" /t REG_SZ /d "0" /f
Reg add "HKLM\SYSTEM\ControlSet001\Control\Class\%%a" /v "*FlowControl" /t REG_SZ /d "0" /f
Reg add "HKLM\SYSTEM\ControlSet001\Control\Class\%%a" /v "*EEE" /t REG_SZ /d "0" /f
::Disable Keys wo "*"
Reg add "HKLM\SYSTEM\ControlSet001\Control\Class\%%a" /v "EnablePME" /t REG_SZ /d "0" /f
Reg add "HKLM\SYSTEM\ControlSet001\Control\Class\%%a" /v "WakeOnLink" /t REG_SZ /d "0" /f
Reg add "HKLM\SYSTEM\ControlSet001\Control\Class\%%a" /v "EEELinkAdvertisement" /t REG_SZ /d "0" /f
Reg add "HKLM\SYSTEM\ControlSet001\Control\Class\%%a" /v "ReduceSpeedOnPowerDown" /t REG_SZ /d "0" /f
Reg add "HKLM\SYSTEM\ControlSet001\Control\Class\%%a" /v "PowerSavingMode" /t REG_SZ /d "0" /f
Reg add "HKLM\SYSTEM\ControlSet001\Control\Class\%%a" /v "EnableGreenEthernet" /t REG_SZ /d "0" /f
Reg add "HKLM\SYSTEM\ControlSet001\Control\Class\%%a" /v "S5WakeOnLan" /t REG_SZ /d "0" /f
Reg add "HKLM\SYSTEM\ControlSet001\Control\Class\%%a" /v "ULPMode" /t REG_SZ /d "0" /f
Reg add "HKLM\SYSTEM\ControlSet001\Control\Class\%%a" /v "GigaLite" /t REG_SZ /d "0" /f
Reg add "HKLM\SYSTEM\ControlSet001\Control\Class\%%a" /v "EnableSavePowerNow" /t REG_SZ /d "0" /f
Reg add "HKLM\SYSTEM\ControlSet001\Control\Class\%%a" /v "EnablePowerManagement" /t REG_SZ /d "0" /f
Reg add "HKLM\SYSTEM\ControlSet001\Control\Class\%%a" /v "EnableDynamicPowerGating" /t REG_SZ /d "0" /f
Reg add "HKLM\SYSTEM\ControlSet001\Control\Class\%%a" /v "EnableConnectedPowerGating" /t REG_SZ /d "0" /f
Reg add "HKLM\SYSTEM\ControlSet001\Control\Class\%%a" /v "AutoPowerSaveModeEnabled" /t REG_SZ /d "0" /f
Reg add "HKLM\SYSTEM\ControlSet001\Control\Class\%%a" /v "AutoDisableGigabit" /t REG_SZ /d "0" /f
Reg add "HKLM\SYSTEM\ControlSet001\Control\Class\%%a" /v "AdvancedEEE" /t REG_SZ /d "0" /f
Reg add "HKLM\SYSTEM\ControlSet001\Control\Class\%%a" /v "PowerDownPll" /t REG_SZ /d "0" /f
Reg add "HKLM\SYSTEM\ControlSet001\Control\Class\%%a" /v "S5NicKeepOverrideMacAddrV2" /t REG_SZ /d "0" /f
::Disable JumboPacket
Reg add "HKLM\SYSTEM\ControlSet001\Control\Class\%%a" /v "JumboPacket" /t REG_SZ /d "0" /f
::Disable LargeSendOffloads
Reg add "HKLM\SYSTEM\ControlSet001\Control\Class\%%a" /v "LsoV2IPv4" /t REG_SZ /d "0" /f
Reg add "HKLM\SYSTEM\ControlSet001\Control\Class\%%a" /v "LsoV2IPv6" /t REG_SZ /d "0" /f
::Enable RSS
Reg add "HKLM\SYSTEM\ControlSet001\Control\Class\%%a" /v "RSS" /t REG_SZ /d "1" /f
::Interrupt Moderation Adaptive (Default)
Reg add "HKLM\SYSTEM\ControlSet001\Control\Class\%%a" /v "ITR" /t REG_SZ /d "125" /f
::Receive/Transmit Buffers
Reg add "HKLM\SYSTEM\ControlSet001\Control\Class\%%a" /v "ReceiveBuffers" /t REG_SZ /d "266" /f
Reg add "HKLM\SYSTEM\ControlSet001\Control\Class\%%a" /v "TransmitBuffers" /t REG_SZ /d "266" /f
::Disable Wake Features
Reg add "HKLM\SYSTEM\ControlSet001\Control\Class\%%a" /v "WolShutdownLinkSpeed" /t REG_SZ /d "2" /f
::Disable Offloads
Reg add "HKLM\SYSTEM\ControlSet001\Control\Class\%%a" /v "UDPChecksumOffloadIPv6" /t REG_SZ /d "0" /f
Reg add "HKLM\SYSTEM\ControlSet001\Control\Class\%%a" /v "IPChecksumOffloadIPv4" /t REG_SZ /d "0" /f
Reg add "HKLM\SYSTEM\ControlSet001\Control\Class\%%a" /v "UDPChecksumOffloadIPv4" /t REG_SZ /d "0" /f
Reg add "HKLM\SYSTEM\ControlSet001\Control\Class\%%a" /v "PMARPOffload" /t REG_SZ /d "0" /f
Reg add "HKLM\SYSTEM\ControlSet001\Control\Class\%%a" /v "PMNSOffload" /t REG_SZ /d "0" /f
Reg add "HKLM\SYSTEM\ControlSet001\Control\Class\%%a" /v "TCPChecksumOffloadIPv4" /t REG_SZ /d "0" /f
Reg add "HKLM\SYSTEM\ControlSet001\Control\Class\%%a" /v "TCPChecksumOffloadIPv6" /t REG_SZ /d "0" /f
) >nul 2>&1
goto Tweaks

:Netsh
if "%NETOF%" equ "%COL%[91mOFF" (
	Reg add "HKCU\Software\Hone" /v InternetTweaks /f
	netsh winsock reset catalog  
	netsh int ip reset c:resetlog.txt  
	netsh int ip reset C:\tcplog.txt  
	netsh int tcp set supplemental Internet congestionprovider=ctcp  
	netsh int tcp set heuristics disabled   
	netsh int tcp set global autotuninglevel=normal  
	netsh int tcp set global rsc=disabled  
	netsh int tcp set global chimney=disabled  
	netsh int tcp set global dca=enabled  
	netsh int tcp set global netdma=disabled  
	netsh int tcp set global ecncapability=enabled  
	netsh int tcp set global timestamps=disabled  
	netsh int tcp set global nonsackrttresiliency=disabled  
	netsh int tcp set global rss=enabled  
	netsh int tcp set global MaxSynRetransmissions=2 
) >nul 2>&1 else (
	Reg delete "HKCU\Software\Hone" /v InternetTweaks /f
	netsh winsock reset catalog
	netsh int ip reset c:resetlog.txt
	netsh int ip reset C:\tcplog.txt	
	netsh int tcp set heuristics default
	netsh int tcp set supplemental Internet congestionprovider=default
	netsh int tcp set global initialRto=3000
	netsh int tcp set global MaxSynRetransmissions=2
	netsh int tcp set global autotuninglevel=default
	netsh int tcp set global rss=default
	netsh int tcp set global rsc=default
	netsh int tcp set global chimney=default
	netsh int tcp set global dca=default
	netsh int tcp set global netdma=default
	netsh int tcp set global ecncapability=default
	netsh int tcp set global timestamps=default
	netsh int tcp set global nonsackrttresiliency=default
) >nul 2>&1
goto Tweaks

:DisableNagle
if "%NAGOF%" equ "%COL%[91mOFF" (
	Reg add "HKLM\Software\Microsoft\MSMQ\Parameters" /v "TCPNoDelay" /t REG_DWORD /d "1" /f >nul 2>&1  
	for /f "tokens=3*" %%i in ('Reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkCards" /f "ServiceName" /s ^|findstr /i /l "ServiceName"') do (
		Reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%s" /v "TCPNoDelay" /t Reg_DWORD /d "1" /f
		Reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%s" /v "TcpAckFrequency" /t Reg_DWORD /d "1" /f
		Reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%s" /v "TcpDelAckTicks" /t Reg_DWORD /d "0" /f
	) >nul 2>&1 
) else (
	Reg delete "HKLM\Software\Microsoft\MSMQ\Parameters" /v "TCPNoDelay" /f >nul 2>&1  
	for /f "tokens=3*" %%i in ('Reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkCards" /f "ServiceName" /s ^|findstr /i /l "ServiceName"') do (
		Reg delete "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%s" /v "TCPNoDelay" /f
		Reg delete "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%s" /v "TcpAckFrequency" /f
		Reg delete "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%s" /v "TcpDelAckTicks" /f
	) >nul 2>&1 
)
goto Tweaks

:DSCValue
if "%DSCOF%" equ "%COL%[91mOFF" (
	Reg add "HKLM\SYSTEM\CurrentControlSet\Services\Psched" /v "Start" /t Reg_DWORD /d "1" /f >nul 2>&1  
	sc start Psched >nul 2>&1  
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
	) >nul 2>&1  
) else (
	for %%i in (csgo VALORANT-Win64-Shipping javaw FortniteClient-Win64-Shipping ModernWarfare r5apex) do (
	    Reg delete "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /f
	) >nul 2>&1  
)
goto Tweaks

:cstates
if "%CS0OF%" equ "%COL%[91mOFF" (
	Reg add "HKLM\SYSTEM\ControlSet002\Control\Class\{4D36E968-E325-11CE-BFC1-08002BE10318}\0000" /v "AllowDeepCStates" /t REG_DWORD /d "0" /f >nul 2>&1
) else (
	Reg add "HKLM\SYSTEM\ControlSet002\Control\Class\{4D36E968-E325-11CE-BFC1-08002BE10318}\0000" /v "AllowDeepCStates" /t REG_DWORD /d "1" /f >nul 2>&1
)
goto Tweaks

:AMD
echo %AMDOF% | find "N/A" >nul && call :HoneCtrlError "You don't have an AMD GPU" && goto Tweaks
cls
::Disable Gamemode
Reg add "HKCU\Software\Microsoft\GameBar" /v "AllowAutoGameMode" /t Reg_DWORD /d "0" /f
Reg add "HKCU\Software\Microsoft\GameBar" /v "AutoGameModeEnabled" /t Reg_DWORD /d "0" /f
::AMD Tweaks
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "3D_Refresh_Rate_Override_DEF" /t Reg_DWORD /d "0" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "3to2Pulldown_NA" /t Reg_DWORD /d "0" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "AAF_NA" /t Reg_DWORD /d "0" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "Adaptive De-interlacing" /t Reg_DWORD /d "1" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "AllowRSOverlay" /t Reg_SZ /d "false" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "AllowSkins" /t Reg_SZ /d "false" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "AllowSnapshot" /t Reg_DWORD /d "0" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "AllowSubscription" /t Reg_DWORD /d "0" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "AntiAlias_NA" /t Reg_SZ /d "0" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "AreaAniso_NA" /t Reg_SZ /d "0" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "ASTT_NA" /t Reg_SZ /d "0" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "AutoColorDepthReduction_NA" /t Reg_DWORD /d "0" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "DisableSAMUPowerGating" /t Reg_DWORD /d "1" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "DisableUVDPowerGatingDynamic" /t Reg_DWORD /d "1" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "DisableVCEPowerGating" /t Reg_DWORD /d "1" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "EnableAspmL0s" /t Reg_DWORD /d "0" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "EnableAspmL1" /t Reg_DWORD /d "0" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "EnableUlps" /t Reg_DWORD /d "0" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "EnableUlps_NA" /t Reg_SZ /d "0" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "KMD_DeLagEnabled" /t Reg_DWORD /d "1" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "KMD_FRTEnabled" /t Reg_DWORD /d "0" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "DisableDMACopy" /t Reg_DWORD /d "1" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "DisableBlockWrite" /t Reg_DWORD /d "0" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "StutterMode" /t Reg_DWORD /d "0" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "EnableUlps" /t Reg_DWORD /d "0" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "PP_SclkDeepSleepDisable" /t Reg_DWORD /d "1" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "PP_ThermalAutoThrottlingEnable" /t Reg_DWORD /d "0" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "DisableDrmdmaPowerGating" /t Reg_DWORD /d "1" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "KMD_EnableComputePreemption" /t Reg_DWORD /d "0" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000\UMD" /v "Main3D_DEF" /t Reg_SZ /d "1" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000\UMD" /v "Main3D" /t Reg_BINARY /d "3100" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000\UMD" /v "FlipQueueSize" /t Reg_BINARY /d "3100" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000\UMD" /v "ShaderCache" /t Reg_BINARY /d "3200" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000\UMD" /v "Tessellation_OPTION" /t Reg_BINARY /d "3200" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000\UMD" /v "Tessellation" /t Reg_BINARY /d "3100" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000\UMD" /v "VSyncControl" /t Reg_BINARY /d "3000" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000\UMD" /v "TFQ" /t Reg_BINARY /d "3200" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000\DAL2_DATA__2_0\DisplayPath_4\EDID_D109_78E9\Option" /v "ProtectionControl" /t Reg_BINARY /d "0100000001000000" /f
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
    Reg.exe delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "Allow Telemetry" /t REG_DWORD /d "0" /f >nul 2>&1
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
    Reg.exe delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization"" /f >nul 2>&1
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
	Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "KernelSEHOPEnabled" /t Reg_DWORD /d "0" /f
	::Disable ASLR
	Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "MoveImages" /t Reg_DWORD /d "0" /f
	::Disable Spectre And Meltdown
	Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v FeatureSettings /t Reg_DWORD /d "0" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v FeatureSettingsOverride /t Reg_DWORD /d "3" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v FeatureSettingsOverrideMask /t Reg_DWORD /d "3" /f
	::Disable CFG Lock
	Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "EnableCfg" /t Reg_DWORD /d "0" /f
	::Disable NTFS/ReFS and FS Mitigations
	Reg add "HKLM\System\CurrentControlSet\Control\Session Manager" /v "ProtectionMode" /t Reg_DWORD /d "0" /f
) >nul 2>&1 else (
	Reg delete "HKCU\Software\Hone" /v MitigationsTweaks /f
	::Turn Core Isolation Memory Integrity ON
	Reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v "Enabled" /t REG_DWORD /d "1" /f
	::Enable SEHOP
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "DisableExceptionChainValidation" /f
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "KernelSEHOPEnabled" /f
	::Enable ASLR
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "MoveImages" /f
	::Enable Spectre And Meltdown
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v FeatureSettings /f
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v FeatureSettingsOverride /f
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v FeatureSettingsOverrideMask /f
	::Enable CFG Lock
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "EnableCfg" /f
	::Enable NTFS/ReFS and FS Mitigations
	Reg delete "HKLM\System\CurrentControlSet\Control\Session Manager" /v "ProtectionMode" /f
) >nul 2>&1
goto Tweaks

:Mouse
rem echo what is your display scaling? 
rem echo go to settings , system , display , then type the scale percentage like 100 , 125
rem set /p choice=" Scale >  "
	Reg add "HKEY_USERS\.DEFAULT\Control Panel\Mouse" /v "MouseSpeed" /t REG_SZ /d "0" /f >nul 2>&1
	Reg add "HKEY_USERS\.DEFAULT\Control Panel\Mouse" /v "MouseThreshold1" /t REG_SZ /d "0" /f >nul 2>&1
	Reg add "HKEY_USERS\.DEFAULT\Control Panel\Mouse" /v "MouseThreshold2" /t REG_SZ /d "0" /f >nul 2>&1
	Reg add "HKEY_CURRENT_USER\Control Panel\Mouse" /v "MouseSensitivity" /t REG_SZ /d "10" /f >nul 2>&1
	Reg add "HKEY_CURRENT_USER\Control Panel\Mouse" /v "SmoothMouseYCurve" /t REG_BINARY /d "0000000000000000000038000000000000007000000000000000A800000000000000E00000000000" /f >nul 2>&1
	Reg add "HKCU\Control Panel\Mouse" /v "SmoothMouseXCurve" /t REG_BINARY /d "0000000000000000C0CC0C0000000000809919000000000040662600000000000033330000000000" /f >nul 2>&1
if /i "%choice%"=="100" Reg add "HKCU\Control Panel\Mouse" /v "SmoothMouseXCurve" /t REG_BINARY /d "0000000000000000C0CC0C0000000000809919000000000040662600000000000033330000000000" /f >nul 2>&1
if /i "%choice%"=="125" Reg add "HKCU\Control Panel\Mouse" /v "SmoothMouseXCurve" /t REG_BINARY /d "00000000000000000000100000000000000020000000000000003000000000000000400000000000" /f >nul 2>&1
if /i "%choice%"=="150" Reg add "HKCU\Control Panel\Mouse" /v "SmoothMouseXCurve" /t REG_BINARY /d "0000000000000000303313000000000060662600000000009099390000000000C0CC4C0000000000" /f >nul 2>&1
if "%MOUOF%" neq "%COL%[91mOFF" (
	Reg add "HKEY_CURRENT_USER\Control Panel\Mouse" /v "SmoothMouseXCurve" /t REG_BINARY /d "0000000000000000156e000000000000004001000000000029dc0300000000000000280000000000" /f >nul 2>&1
	Reg add "HKEY_CURRENT_USER\Control Panel\Mouse" /v "SmoothMouseYCurve" /t REG_BINARY /d "0000000000000000fd11010000000000002404000000000000fc12000000000000c0bb0100000000" /f >nul 2>&1
)
goto tweaks

:MSIAfterBurner
if "%AFTOF%" neq "%COL%[91mOFF" (del /S /Q /F "%SystemDrive%\Program Files (x86)\MSI Afterburner\Skins\Hone.usf" >nul 2>&1) & goto Tweaks
if not exist "%SystemDrive%\Program Files (x86)\MSI Afterburner\MSIAfterburner.exe" goto downloadMSIafterburner
curl -o "C:\Program Files (x86)\MSI Afterburner\Skins\Hone.usf" "https://github.com/auraside/HoneCtrl/raw/main/Files/Hone.usf" >nul 2>&1
goto Tweaks
:downloadMSIafterburner
echo Downloading MSIAfterBurner
curl -o "C:\Hone\Resources\MSI_Afterburner_1.zip" "https://github.com/auraside/HoneCtrl/releases/download/2.0/MSI.Afterburner_2.zip" >nul 2>&1
%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe Expand-Archive 'C:\Hone\Resources\MSI_Afterburner_1.zip' -DestinationPath 'C:\Program Files (x86)'
%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe "$s=(New-Object -COM WScript.Shell).CreateShortcut('%userprofile%\Desktop\MSI Afterburner.lnk');$s.TargetPath='C:\Program Files (x86)\MSI Afterburner\MSIAfterburner.exe';$s.Save()"
del /Q /F "%SystemDrive%\Hone\Resources\MSI_Afterburner_1.zip" >nul 2>&1
goto MSIAfterBurner

:ProfileInspector
if "%NPIOF%" equ "%COL%[91mOFF" (
	Reg add "HKCU\Software\Hone" /v NpiTweaks /f
	rmdir /S /Q "C:\Hone\Resources\nvidiaProfileInspector\"
	curl -g -L -o C:\Hone\Resources\nvidiaProfileInspector.zip "https://github.com/Orbmu2k/nvidiaProfileInspector/releases/latest/download/nvidiaProfileInspector.zip"
	powershell -NoProfile Expand-Archive 'C:\Hone\Resources\nvidiaProfileInspector.zip' -DestinationPath 'C:\Hone\Resources\nvidiaProfileInspector\'
	del /F /Q "C:\Hone\Resources\nvidiaProfileInspector.zip"
	curl -o "C:\Hone\Resources\nvidiaProfileInspector\Latency_and_Performances_Settings_by_Hone_Team2.nip" "https://raw.githubusercontent.com/auraside/HoneCtrl/main/Files/Latency_and_Performances_Settings_by_Hone_Team2.nip"
	cd "C:\Hone\Resources\nvidiaProfileInspector\"
	nvidiaProfileInspector.exe "Latency_and_Performances_Settings_by_Hone_Team2.nip" 
) >nul 2>&1 else (
::https://github.com/Orbmu2k/nvidiaProfileInspector/releases/latest/download/nvidiaProfileInspector.zip
	Reg delete "HKCU\Software\Hone" /v NpiTweaks /f
	rmdir /S /Q "C:\Hone\Resources\nvidiaProfileInspector\"
	curl -g -L -o C:\Hone\Resources\nvidiaProfileInspector.zip "https://github.com/Orbmu2k/nvidiaProfileInspector/releases/latest/download/nvidiaProfileInspector.zip"
	powershell -NoProfile Expand-Archive 'C:\Hone\Resources\nvidiaProfileInspector.zip' -DestinationPath 'C:\Hone\Resources\nvidiaProfileInspector\'
	del /F /Q "C:\Hone\Resources\nvidiaProfileInspector.zip"
	curl -o "C:\Hone\Resources\nvidiaProfileInspector\Base_Profile.nip" "https://raw.githubusercontent.com/auraside/HoneCtrl/main/Files/Base_Profile.nip"
	cd "C:\Hone\Resources\nvidiaProfileInspector\"
	nvidiaProfileInspector.exe "Base_Profile.nip"
) >nul 2>&1
goto Tweaks

:Drivers
cls

echo The drivers are 732Mb and 1Gb so this will take a moment to download. (768,102,400 or 1,073,691,829 bytes)
echo.
echo Would you like to install?
choice /c:YN /n /m "[Y] Yes  [N] No"
if %errorlevel% equ 2 goto Tweaks

cls
TITLE Downloading Nvidia driver...
echo Do you need shadowplay and other components of the driver? Y or N?
choice /c:YN /n /m "[Y] Yes  [N] No"
if %errorlevel% equ 1 (
curl -L -o "C:\Hone\Drivers\NvidiaHone.exe" "https://github.com/auraside/HoneCtrl/releases/download/1.3/497.09.Hone.Default.exe"
) || (
curl -L -o "C:\Hone\Drivers\NvidiaHone.exe" "https://github.com/auraside/HoneCtrl/releases/download/1.3/497.09.Hone.Tweaked.exe"
)

TITLE Executing DDU...
curl -g -L -o "C:\Hone\Resources\DDU.zip" "https://github.com/auraside/HoneCtrl/raw/main/Files/DDU.zip"
powershell -NoProfile Expand-Archive 'C:\Hone\Resources\DDU.zip' -DestinationPath 'C:\Hone\Resources\DDU\' >nul 2>&1
del "C:\Hone\Resources\DDU.zip"
cd C:\Hone\Resources\DDU
DDU.exe -silent -cleannvidia

title Restart Confirmation
cls
echo Your PC NEEDS to restart before installing the driver!
echo AFTER RESTARTING, PLEASE REOPEN THE HONE CONTROL PANEL
echo.
echo Would you like to restart now?
choice /c:YN /n /m "[Y] Yes  [N] No"
if %errorlevel% equ 1 (
	copy "%~f0" "C:\Users\%username%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\HoneCtrl.bat"
	cd C:\Hone
	echo set justrestarted=1 >> driverinstall.bat
	shutdown /s /t 60 /c "A restart is required, we'll do that now" /f /d p:0:0
	timeout 5 
	shutdown -a
	shutdown /r /t 7 /c "Restarting automatically..." /f /d p:0:0
	pause && exit /b
) else (
	copy "%~f0" "C:\Users\%username%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\HoneCtrl.bat"
	cd C:\Hone
	echo set justrestarted=1 >> driverinstall.bat
	goto tweaks
)

:NvidiaTweaks
if "%NVIOF%" equ "%COL%[91mOFF" (
cls
Reg add "HKCU\Software\Hone" /v "NvidiaTweaks" /f
::Enable Hardware Accelerated Scheduling
reg query "HKLM\System\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" >nul 2>&1
if "%errorlevel%" equ "0" Reg add "HKLM\System\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t Reg_DWORD /d "2" /f
::Enable gdi hardware acceleration
for /f %%a in ('Reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class" /v "VgaCompatible" /s ^| findstr "HKEY"') do ( 
reg query "%%a" /v "KMD_EnableGDIAcceleration" >nul 2>&1
if "!errorlevel!" equ "0" Reg add "%%a" /v "KMD_EnableGDIAcceleration" /t Reg_DWORD /d "1" /f
)
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
::Nvidia Reg
for /f %%a in ('Reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class" /v "VgaCompatible" /s ^| findstr "HKEY"') do ( Reg add "%%a" /v "TCCSupported" /t REG_DWORD /d "0" /f
)
Reg add "HKCU\Software\NVIDIA Corporation\Global\NVTweak\Devices\509901423-0\Color" /v "NvCplUseColorCorrection" /t Reg_DWORD /d "0" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "PlatformSupportMiracast" /t Reg_DWORD /d "0" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global\NVTweak" /v "DisplayPowerSaving" /t Reg_DWORD /d "0" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisableWriteCombining" /t Reg_DWORD /d "1" /f
::Unrestricted Clocks
cd "%SystemDrive%\Program Files\NVIDIA Corporation\NVSMI\" >nul 2>&1
start "" /I /WAIT /B "nvidia-smi" -acp 0 >nul 2>&1
::Opt out of nvidia telemetry
reg add "HKLM\SOFTWARE\NVIDIA Corporation\NvControlPanel2\Client" /v "OptInOrOutPreference" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID44231" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID64640" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID66610" /t REG_DWORD /d 0 /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\FTS" /v "EnableRID61684" /t Reg_DWORD /d "1" /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "NvBackend" /f >nul 2>&1
::Disable GpuEnergyDrv
Reg add "HKLM\SYSTEM\CurrentControlSet\Services\GpuEnergyDrv" /v "Start" /t Reg_DWORD /d "4" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Services\GpuEnergyDr" /v "Start" /t Reg_DWORD /d "4" /f
::Disable Tiled Display
Reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "EnableTiledDisplay" /t Reg_DWORD /d "0" /f
if exist "%windir%\system32\wbem\WMIC.exe" for /f %%i in ('wmic path Win32_VideoController get PNPDeviceID') do (
set "str=%%i" & if "!str:PCI\VEN_=!" neq "!str!" for /f "tokens=3" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Enum\%%i" /v "Driver"') do Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\%%a" /v "EnableTiledDisplay" /t REG_DWORD /d "0" /f
)
::Disable Preemption
Reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisablePreemption" /t Reg_DWORD /d "1" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisableCudaContextPreemption" /t Reg_DWORD /d "1" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Scheduler" /v "EnablePreemption" /t Reg_DWORD /d "0" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "EnableCEPreemption" /t Reg_DWORD /d "0" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisablePreemptionOnS3S4" /t Reg_DWORD /d "1" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "ComputePreemption" /t Reg_DWORD /d "0" /f
::Disable HDCP
for /f %%a in ('Reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class" /v "VgaCompatible" /s ^| findstr "HKEY"') do ( Reg add "%%a" /v "RMHdcpKeyglobZero" /t REG_DWORD /d "1" /f 
)
)>nul 2>&1 else (
Reg delete "HKCU\Software\Hone" /v "NvidiaTweaks" /f
::Enable Hardware Accelerated Scheduling
reg query "HKLM\System\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode"
if "%errorlevel%" equ "0" Reg add "HKLM\System\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t Reg_DWORD /d "1" /f
::Disable gdi hardware acceleration
for /f %%a in ('Reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class" /v "VgaCompatible" /s ^| findstr "HKEY"') do ( 
reg query "%%a" /v "KMD_EnableGDIAcceleration" >nul 2>&1
if "!errorlevel!" equ "0" Reg delete "%%a" /v "KMD_EnableGDIAcceleration" /f
)
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
::Nvidia Reg
for /f %%a in ('Reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class" /v "VgaCompatible" /s ^| findstr "HKEY"') do ( Reg add "%%a" /v "TCCSupported" /t REG_DWORD /d "0" /f 
)
Reg delete "HKCU\Software\NVIDIA Corporation\Global\NVTweak\Devices\509901423-0\Color" /v "NvCplUseColorCorrection" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "PlatformSupportMiracast" /t Reg_DWORD /d "1" /f
Reg delete "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global\NVTweak" /v "DisplayPowerSaving" /f
Reg delete "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisableWriteCombining" /f
::Opt out of nvidia telemetry
reg add "HKLM\SOFTWARE\NVIDIA Corporation\NvControlPanel2\Client" /v "OptInOrOutPreference" /t REG_DWORD /d 1 /f
reg delete "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID44231" /f
reg delete "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID64640" /f
reg delete "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID66610" /f
Reg delete "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\FTS" /v "EnableRID61684" /f
::Disable GpuEnergyDrv
Reg add "HKLM\SYSTEM\CurrentControlSet\Services\GpuEnergyDrv" /v "Start" /t Reg_DWORD /d "2" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Services\GpuEnergyDr" /v "Start" /t Reg_DWORD /d "2" /f
::Disable Tiled Display
Reg delete "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "EnableTiledDisplay" /f
if exist "%windir%\system32\wbem\WMIC.exe" for /f %%i in ('wmic path Win32_VideoController get PNPDeviceID') do (
set "str=%%i" & if "!str:PCI\VEN_=!" neq "!str!" for /f "tokens=3" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Enum\%%i" /v "Driver"') do Reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Class\%%a" /v "EnableTiledDisplay" /f
)
::Disable Preemption
Reg delete "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisablePreemption" /f
Reg delete "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisableCudaContextPreemption" /f
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Scheduler" /v "EnablePreemption" /t Reg_DWORD /d "1" /f
Reg delete "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "EnableCEPreemption" /f
Reg delete "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisablePreemptionOnS3S4" /f
Reg delete "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "ComputePreemption" /f
::Disable HDCP
if exist "%windir%\system32\wbem\WMIC.exe" for /f %%i in ('wmic path Win32_VideoController get PNPDeviceID') do (
for /f %%a in ('Reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class" /v "VgaCompatible" /s ^| findstr "HKEY"') do Reg add "%%a" /v "RMHdcpKeyglobZero" /t REG_DWORD /d "0" /f
)
)>nul 2>&1
goto Tweaks

:PStates0
if "%PS0OF%" equ "%COL%[91mOFF" (
	For /F "tokens=*" %%i in ('reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /t REG_SZ /s /e /f "NVIDIA" ^| findstr "HK"') do (
		Reg add "%%i" /v "DisableDynamicPstate" /t REG_DWORD /d "1" /f >nul 2>&1
	)
) else (
	For /F "tokens=*" %%i in ('reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /t REG_SZ /s /e /f "NVIDIA" ^| findstr "HK"') do (
		Reg delete "%%i" /v "DisableDynamicPstate" /f >nul 2>&1
	)
)
goto Tweaks

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
		Reg.exe delete "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /f >nul 2>&1
		Reg.exe delete "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /f >nul 2>&1
	)
	for /f %%i in ('wmic path Win32_VideoController get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
		Reg.exe delete "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /f >nul 2>&1
		Reg.exe delete "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /f >nul 2>&1
	)
	for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
		Reg.exe delete "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /f >nul 2>&1
		Reg.exe delete "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /f >nul 2>&1
	)
goto Tweaks
)

Reg add "HKCU\Software\Hone" /v AffinityTweaks /f >nul 2>&1
for /f "tokens=*" %%f in ('wmic cpu get NumberOfCores /value ^| find "="') do set %%f
for /f "tokens=*" %%f in ('wmic cpu get NumberOfLogicalProcessors /value ^| find "="') do set %%f
if "%NumberOfCores%"=="2" (
cls
echo you have 2 cores, affinity won't work!!!!!
pause
goto Tweaks
)

if %NumberOfCores% gtr 4 (
	for /f %%i in ('wmic path Win32_VideoController get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
		Reg.exe add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /t REG_DWORD /d "3" /f >nul 2>&1
		Reg.exe delete "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /f >nul 2>&1
	)
	for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
		Reg.exe add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /t REG_DWORD /d "5" /f >nul 2>&1
		Reg.exe delete "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /f >nul 2>&1
	)
	goto Tweaks
)

if %NumberOfLogicalProcessors% gtr %NumberOfCores% (
::You have HyperThreading Enabled!
	for /f %%i in ('wmic path Win32_USBController get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
		Reg.exe add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /t REG_DWORD /d "4" /f >nul 2>&1
		Reg.exe add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /t REG_BINARY /d "C0" >nul 2>&1
	)
	for /f %%i in ('wmic path Win32_VideoController get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
		Reg.exe add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /t REG_DWORD /d "4" /f >nul 2>&1
		Reg.exe add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /t REG_BINARY /d "C0" /f >nul 2>&1
	)
	for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
		Reg.exe add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /t REG_DWORD /d "4" /f >nul 2>&1
		Reg.exe add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /t REG_BINARY /d "30" /f >nul 2>&1
	)
) ELSE (
::echo You have HyperThreading Disabled!
	for /f %%i in ('wmic path Win32_USBController get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
		Reg.exe add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /t REG_DWORD /d "4" /f >nul 2>&1
		Reg.exe add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /t REG_BINARY /d "08" /f >nul 2>&1
	)
	for /f %%i in ('wmic path Win32_VideoController get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
		Reg.exe add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /t REG_DWORD /d "4" /f >nul 2>&1
		Reg.exe add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /t REG_BINARY /d "02" /f >nul 2>&1
	)
	for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
		Reg.exe add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /t REG_DWORD /d "4" /f >nul 2>&1
		Reg.exe add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /t REG_BINARY /d "04" /f >nul 2>&1
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
	::Disable Paging Combining
	Reg add "HKLM\SYSTEM\currentcontrolset\control\session manager\Memory Management" /v "DisablePagingCombining" /t Reg_DWORD /d "1" /f
	::Use Large System Cache to improve microstuttering
	Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "LargeSystemCache" /t Reg_DWORD /d "1" /f
	::Unload .dll to Free Memory
	Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "AlwaysUnloadDLL" /t REG_DWORD /d "1" /f
	::Free unused ram
	Reg add "HKLM\System\CurrentControlSet\Control\Session Manager" /v "HeapDeCommitFreeBlockThreshold" /t REG_DWORD /d "262144" /f
	::Auto restart Powershell on error
	Reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "AutoRestartShell" /t REG_DWORD /d "1" /f
	::Optimize NTFS
	Reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "NTFSDisable8dot3NameCreation" /t Reg_DWORD /d "1" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "NTFSDisableLastAccessUpdate" /t Reg_DWORD /d "1" /f
	::Disk Optimizations
	Reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "DontVerifyRandomDrivers" /t REG_DWORD /d "1" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "LongPathsEnabled" /t REG_DWORD /d "0" /f
	::Remove memory compression
	Reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Superfetch" /v "StartedComponents" /t Reg_DWORD /d "513347" /f
	Reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Superfetch" /v "AdminDisable" /t Reg_DWORD /d "8704" /f
	Reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Superfetch" /v "AdminEnable" /t Reg_DWORD /d "0" /f
	::Disable Prefetch
	Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "EnableSuperfetch" /t REG_DWORD /d "0" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "EnablePrefetcher" /t REG_DWORD /d "0" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /t Reg_DWORD /d "0" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableSuperfetch" /t Reg_DWORD /d "0" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableBoottrace" /t Reg_DWORD /d "0" /f
	::Speedup Startup
	Reg add "HKEY_CURRENT_USER\AppEvents\Schemes" /f
	Reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "DelayedDesktopSwitchTimeout" /t Reg_DWORD /d "0" /f
	Reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" /v "StartupDelayInMSec" /t Reg_DWORD /d "0" /f
	::Background Apps
	Reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v "GlobalUserDisabled" /t Reg_DWORD /d "1" /f
	Reg add "HKLM\Software\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsRunInBackground" /t Reg_DWORD /d "2" /f
	Reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "BackgroundAppGlobalToggle" /t Reg_DWORD /d "0" /f
	::Disable Hibernation + Fast Boot
	powercfg /h off
	Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d "0" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "HibernateEnabledDefault" /t REG_DWORD /d "0" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "HibernateEnabled" /t REG_DWORD /d "0" /f
	::Wait time to kill app during shutdown
	Reg add "HKCU\Control Panel\Desktop" /v "WaitToKillAppTimeout" /t Reg_SZ /d "1000" /f
	::Wait to end service at shutdown
	Reg add "HKLM\System\CurrentControlSet\Control" /v "WaitToKillServiceTimeout" /t Reg_SZ /d "1000" /f
	::Wait to kill non-responding app
	Reg add "HKCU\Control Panel\Desktop" /v "HungAppTimeout" /t Reg_SZ /d "1000" /f
	::Disable memory compression
	powershell -NoProfile -Command "Disable-MMAgent -mc"
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
	Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t Reg_DWORD /d "0" /f
	::Disable Paging Combining
	Reg add "HKLM\SYSTEM\currentcontrolset\control\session manager\Memory Management" /v "DisablePagingCombining" /t Reg_DWORD /d "0" /f
	::Use Large System Cache to improve microstuttering
	Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "LargeSystemCache" /t Reg_DWORD /d "0" /f
	::Unload .dll to Free Memory
	Reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "AlwaysUnloadDLL" /t REG_DWORD /d "1" /f
	::Don't free unused ram
	Reg delete "HKLM\System\CurrentControlSet\Control\Session Manager" /v "HeapDeCommitFreeBlockThreshold" /f
	::Don't restart Powershell on error
	Reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "AutoRestartShell" /t REG_DWORD /d "0" /f
	::Optimize NTFS
	Reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "NTFSDisable8dot3NameCreation" /t Reg_DWORD /d "2" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "NTFSDisableLastAccessUpdate" /t Reg_DWORD /d "2" /f
	::Disk Optimizations
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "DontVerifyRandomDrivers" /f
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "LongPathsEnabled" /f
	Reg delete "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Superfetch" /v "StartedComponents" /f
	::Disable Prefetch
	Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "EnableSuperfetch" /t REG_DWORD /d "3" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "EnablePrefetcher" /t REG_DWORD /d "3" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /t Reg_DWORD /d "3" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableSuperfetch" /t Reg_DWORD /d "3" /f
	Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableBoottrace" /t Reg_DWORD /d "1" /f
	::Speedup Startup
	Reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "DelayedDesktopSwitchTimeout" /t Reg_DWORDdel "0" /f
	Reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" /v "StartupDelayInMSec" /t Reg_DWORD /d "0" /f
	::Background Apps
	Reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v "GlobalUserDisabled" /t Reg_DWORD /d "0" /f
	Reg delete "HKLM\Software\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsRunInBackground" /f
	Reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "BackgroundAppGlobalToggle" /t Reg_DWORD /d "1" /f
	::Disable Hibernation + Fast Boot
	powercfg /h on
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "HiberbootEnabled" /f
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "HibernateEnabledDefault" /f
	Reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "HibernateEnabled" /f
	::Wait time to kill app during shutdown
	Reg add "HKCU\Control Panel\Desktop" /v "WaitToKillAppTimeout" /t Reg_SZ /d "20000" /f
	::Wait to end service at shutdown
	Reg add "HKLM\System\CurrentControlSet\Control" /v "WaitToKillServiceTimeout" /t Reg_SZ /d "20000" /f
	::Wait to kill non-responding app
	Reg add "HKCU\Control Panel\Desktop" /v "HungAppTimeout" /t Reg_SZ /d "5000" /f
	::Enable memory compression
	powershell -NoProfile -Command "Enable-MMAgent -mc"
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
goto Tweaks

::Disable FTH
Reg add "HKLM\Software\Microsoft\FTH\State" /f >>"%temp%\EchoLog.txt" 2>>"%temp%\EchoError.txt"
Reg delete "HKLM\Software\Microsoft\FTH\State" /f >>"%temp%\EchoLog.txt" 2>>"%temp%\EchoError.txt"
Reg add "HKLM\Software\Microsoft\FTH" /v "Enabled" /t Reg_DWORD /d "0" /f >>"%temp%\EchoLog.txt" 2>>"%temp%\EchoError.txt"

::System responsiveness, PanTeR Said to use 14 (20 hexa)
Reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t Reg_DWORD /d "20" /f >>"%temp%\EchoLog.txt" 2>>"%temp%\EchoError.txt"

::Disable Power Throttling
Reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /f >>"%temp%\EchoLog.txt" 2>>"%temp%\EchoError.txt"
::Enable Power Throttling If Laptop
for /f "tokens=2 delims={}" %%n in ('wmic path Win32_SystemEnclosure get ChassisTypes /value') do set /a ChassisTypes=%%n
if defined ChassisTypes if %ChassisTypes% GEQ 8 if %ChassisTypes% LSS 12 (
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /t Reg_DWORD /d "1" /f >>"%temp%\EchoLog.txt" 2>>"%temp%\EchoError.txt"
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /f >>"%temp%\EchoLog.txt" 2>>"%temp%\EchoError.txt"
)

::::::::::::::::::::::
::GPU  Optimizations::
::::::::::::::::::::::

::Reliable Timestamp
Reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Reliability" /v "TimeStampInterval" /t Reg_DWORD /d "1" /f >>"%temp%\EchoLog.txt" 2>>"%temp%\EchoError.txt"
Reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Reliability" /v "IoPriority" /t Reg_DWORD /d "3" /f >>"%temp%\EchoLog.txt" 2>>"%temp%\EchoError.txt"

::::::::::::::::::::::
::Late Optimizations::
::::::::::::::::::::::

::MMCSS
Reg add "HKLM\SYSTEM\CurrentControlSet\Services\MMCSS" /v "Start" /t Reg_DWORD /d "4" /f >>"%temp%\EchoLog.txt" 2>>"%temp%\EchoError.txt"
Reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t Reg_DWORD /d "8" /f >>"%temp%\EchoLog.txt" 2>>"%temp%\EchoError.txt"
Reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t Reg_DWORD /d "6" /f >>"%temp%\EchoLog.txt" 2>>"%temp%\EchoError.txt"
Reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t Reg_SZ /d "High" /f >>"%temp%\EchoLog.txt" 2>>"%temp%\EchoError.txt"
Reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "SFIO Priority" /t Reg_SZ /d "High" /f >>"%temp%\EchoLog.txt" 2>>"%temp%\EchoError.txt"

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
echo                  %COL%[33m[ %COL%[37m1 %COL%[33m] %COL%[37mAbout                                                   %COL%[33m[ %COL%[37m2 %COL%[33m] %COL%[37mPolicies
echo.
echo.
echo                  %COL%[33m[ %COL%[37m3 %COL%[33m] %COL%[37mCredits                                                 %COL%[33m[ %COL%[37m4 %COL%[33m] %COL%[37mChangelog
echo.
echo.
echo                  %COL%[33m[ %COL%[37m5 %COL%[33m] %COL%[37mCleaner                                                 %COL%[33m[ %COL%[37m6 %COL%[33m] %COL%[37mBackup
echo                  %COL%[90mClear adware, unused devices, and                             %COL%[90mMake a restore point and a backup
echo                  %COL%[90mtemp files. EMPTIES RECYCLE BIN                               %COL%[90mof your registry HKCU and HKLM
echo.
echo.
echo                  %COL%[33m[ %COL%[37m7 %COL%[33m] %COL%[37mGame-Booster                                            %COL%[33m[ %COL%[37m8 %COL%[33m] %COL%[37mSoft Restart
echo                  %COL%[90mSets game GPU and CPU to high performance                     %COL%[90mIf your PC has been running a while
echo                  %COL%[90mand disables fullscreen optimizations                         %COL%[90muse this to receive a quick boost%COL%[37m
echo.
echo.
echo.
echo.
echo.
echo.
echo                                                        %COL%[90m[ press X to go back ]%COL%[37m
echo.
choice /c:12345678X /n /m "%DEL%                                         Select a corresponding number to what you'd like >"
set choice=%errorlevel%
if "%choice%"=="1" goto About
if "%choice%"=="2" goto policies
if "%choice%"=="3" goto Credits
if "%choice%"=="4" goto Changelog
if "%choice%"=="5" goto Cleaner
if "%choice%"=="6" goto Backup
if "%choice%"=="7" call:gameBooster
if "%choice%"=="8" call:softRestart
if "%choice%"=="9" goto:eof
goto More

:About
cls
echo About
echo Owned by AuraSide, This is a GUI for the Hone Manual Tweaks.
echo.
call :ColorText 8 "                                                      [ press X to go back ]"
echo.
echo.
echo.
choice /c:X /n /m "%DEL%                                                               >:"
set choice=%errorlevel%
if "%choice%"=="1" goto More

:Changelog
cls
echo Version 1.0
echo - Hone tweaks have all been compiled into the following GUI and new batch program.
echo.
echo Version 1.1
echo - Fixed Nvpi not reverting
echo - Fixed FULL Nvidia driver not launching
echo.
echo Version 1.2
echo - Fixed W7 not working
echo - Fixed a weird bug where some tools wouldn't download
echo.
echo Version 1.3
echo - Added a different UI to the nvidia drivers
echo - The clean driver has been heavily tweaked and modified
echo - The driver has been changed to 497.09 for better latency and performance
echo - NVIDIA Profile Inspector and Tweaks now disable HDCP for better latency.
echo - The NVIDIA Profile Inspector tweak is now NVIDIA Profile Inspector and tweaks
echo - Downloads now using the curl command, increasing download speed
echo - X To Close the Control Panel deletes the Ressource and Driver folder to up free space
echo - The bloated driver is now the default official driver from the nvidia website
echo - Fixed a bug regarding AdwCleaner not running
echo - Fixed a bug regarding the new power plan not being applied properly if choosing "delete"
echo.
echo Version 2.0
echo - Redesigned UI
echo - Made tweaks toggleable
echo - Added Game-Booster
echo - Added Soft-Restart
echo - Added Tweaks:
echo %COL%[92m    PStates 0
echo     Nvidia Tweaks
echo     Memory optimizations
echo     W32 Priority Seperation
echo     BCDEdit
echo     Disable Mitigations
echo     Optimize TCP/IP
echo     Optimize NIC
echo     Optimize Netsh
echo     DSCP Value
echo     Disable Nagles Algorithm
echo     Optimize Intel iGPU
echo     AMD GPU Tweaks
echo     Disable C-States %COL%[37m
echo - Removed:
echo %COL%[91m    Revert %COL%[37m
echo                                                       [ press X to go back ]
echo.
choice /c:X /n /m "%DEL%                                                               >:"
set choice=%errorlevel%
if "%choice%"=="1" goto More

:Policies
cls
echo Owned By AuraSide, Copyright Claimed. 
echo.
echo.
call :ColorText 8 "                                                      [ press X to go back ]"
echo.
echo.
echo.
choice /c:X /n /m "%DEL%                                                               >:"
set choice=%errorlevel%
if "%choice%"=="1" goto More

:Credits
cls
echo.
echo.
echo.
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
echo %COL%[97m                                                     Dexter K. 
echo %COL%[97m                                                     Arthur C. - Yaamruo
echo.
echo.
echo.
echo %COL%[90m                                                       Special thanks to
echo %COL%[97m                                                       mbk1969 - Timer Resolution
echo %COL%[97m                                                       W1zzard - Nvcleanstall
echo %COL%[97m                                                       M2-Team - Nsudo
echo %COL%[97m                                                       ToastyX - Restart64
echo %COL%[97m                                                          wj32 - Purgestandby
echo.
echo.
echo.
echo.
echo.
echo.
echo.
call :ColorText 8 "                                                     [ press X to go back ]"
echo.
echo.
choice /c:X /n /m "%DEL%                                                               >:"
set choice=%errorlevel%
if "%choice%"=="1" goto More

:Cleaner
cls
rmdir /S /Q "C:\Hone\Resources\DeviceCleanupCmd\"
del /F /Q "C:\Hone\Resources\AdwCleaner.exe"
curl -g -L -o "C:\Hone\Resources\DeviceCleanupCmd.zip" "https://www.uwe-sieber.de/files/DeviceCleanupCmd.zip"
curl -g -L -o "C:\Hone\Resources\AdwCleaner.exe" "https://adwcleaner.malwarebytes.com/adwcleaner?channel=release"
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
cd "C:\Hone\Resources\DeviceCleanupCmd\x64"
DeviceCleanupCmd.exe *
goto tweaks

:Backup
%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe Enable-ComputerRestore -Drive 'C:\', 'D:\', 'E:\', 'F:\', 'G:\' >nul 2>&1
%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe Checkpoint-Computer -Description 'Hone Restore Point' >nul 2>&1
for /F "tokens=2" %%i in ('date /t') do set date=%%i
set date1=%date:/=.%
md C:\Hone\HoneRevert\%date1%
reg export HKCU C:\Hone\HoneRevert\%date1%\HKLM.reg /y & reg export HKCU C:\Hone\HoneRevert\%date1%\HKCU.reg /y >nul 2>&1
cls
goto More

:gameBooster
cls & echo Select the game location
set dialog="about:<input type=file id=FILE><script>FILE.click();new ActiveXObject
set dialog=%dialog%('Scripting.FileSystemObject').GetStandardStream(1).WriteLine(FILE.value);
set dialog=%dialog%close();resizeTo(0,0);</script>"
for /f "tokens=* delims=" %%p in ('mshta.exe %dialog%') do set "file=%%p"
if "%file%"=="" goto:eof

for %%F in ("%file%") do (cls
::GPU High Performance
Reg add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "%%F" /t Reg_SZ /d "GpuPreference=2;" /f >>"%temp%\EchoLog.txt" 2>>"%temp%\EchoError.txt"
echo GPU High Performance

::Disable Fullscreen Optimizations
Reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "%%F" /t Reg_SZ /d "~ DISABLEDXMAXIMIZEDWINDOWEDMODE" /f >>"%temp%\EchoLog.txt" 2>>"%temp%\EchoError.txt"
echo Disable Fullscreen Optimizations

::High CPU Class
Reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%%~nxF\PerfOptions" /v "CpuPriorityClass" /t Reg_DWORD /d "3" /f >>"%temp%\EchoLog.txt" 2>>"%temp%\EchoError.txt"
echo CPU High Class 
)
echo.
choice /c:"CQ" /n /m "%BS%               [C] Continue  [Q] Quit" & if !errorlevel! equ 2 exit /b
goto:eof

:softRestart
cls
Mode 65,16
color 06
cd %temp%
echo Downloading NSudo [...]
if not exist "%temp%\NSudo.exe" curl -o "%temp%\NSudo.exe" "https://github.com/auraside/HoneCtrl/raw/main/Files/NSudo.exe"
NSudo.exe -U:S -ShowWindowMode:Hide cmd /c "Reg add "HKLM\SYSTEM\CurrentControlSet\Services\TrustedInstaller" /v "Start" /t Reg_DWORD /d "3" /f"
NSudo.exe -U:S -ShowWindowMode:Hide cmd /c "sc start "TrustedInstaller"
echo Downloading Restart64 [...]
if not exist "%temp%\restart64.exe" curl -o "%temp%\Restart64.exe" "https://github.com/auraside/HoneCtrl/raw/main/Files/restart64.exe"
echo Downloading EmptyStandbyList [...]
if not exist "%temp%\EmptyStandbyList.exe" curl -g -L -o "%temp%\EmptyStandbyList.exe" "https://wj32.org/wp/download/1455/"
cls

::Restart Explorer/DWM
echo Restarting Explorer [...]
>nul 2>&1 taskkill /f /im explorer.exe && explorer.exe

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
start "" echo off ^& ^
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
