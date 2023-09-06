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

REM Blank/Color Character
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (set "DEL=%%a" & set "COL=%%b")

:CheckForUpdates
set local=2.8
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

:MainMenu
Mode 130,45
TITLE Hone Control Panel %localtwo%
set "choice="
cls
echo.
echo.
call :HoneTitle
echo.
echo                                        %COL%[90m HONECTRL IS DEPRECATED AND HAS BEEN REPLACE BY 
echo                                        %COL%[90m    		THE NEW HONE APP
echo.
echo.
echo.
echo %COL%[37m                For your safety, HoneCtrl cannot be used anymore, as the tweaks are no longer safe or updated.
echo.
echo.
echo                                                          %COL%[31m[ X to close ]%COL%[37m
%SYSTEMROOT%\System32\choice.exe /c:X /n /m "%DEL%
set choice=%errorlevel%
if "%choice%"=="1" goto end

goto MainMenu

:end
start https://hone.gg/
exit /b

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