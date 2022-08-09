@echo off
set serverEXE="%~dp0\Aki.Server.exe"
set launcherEXE="%~dp0\Aki.Launcher.exe"
set autoPlay=false
set closeOnLaunch=false
set profileTXT=akilauncheraio_defaultprofile.txt

if  %autoPlay% equ true (
	start "" /MIN %serverEXE%
	ECHO Server launched and minimized! Running client...
	timeout /t 5
	for /f "tokens=* delims=" %%x in (%profileTXT%) do (
	start "" "%~dp0\EscapeFromTarkov.exe" -force-gfx-jobs native -token=%%x -config={"BackendUrl":"http://127.0.0.1:6969","Version":"live"}
	)
	
	if %closeOnLaunch% equ true (
	ECHO Closing launcher...
	timeout /t 5
	exit
	)
	
)
:MENU
CLS
ECHO.
ECHO ...............................................
ECHO              SPT-AKI Launcher AIO
ECHO ...............................................
ECHO.
ECHO 1 - Restart Server
ECHO 2 - Restart Client
ECHO 3 - Launcher
ECHO 4 - Mod Folder
ECHO 5 - Profiles Folder
ECHO 6 - Root SPT-AKI Directory
ECHO 7 - Exit AIO (Close all SPT-AKI windows)
ECHO.
SET /P M=Select a choice and press ENTER: 
IF %M%==1 GOTO RESTART
IF %M%==2 GOTO RESTARTCLIENT
IF %M%==3 GOTO LAUNCHER
IF %M%==4 GOTO MODS
IF %M%==5 GOTO PROFILES
IF %M%==6 GOTO ROOT
IF %M%==7 GOTO EXITAIO
:RESTART
taskkill /im "Aki.Server.exe"
timeout /t 5
start "" %serverEXE%
GOTO MENU
:RESTARTCLIENT
taskkill /im EscapeFromTarkov.exe
timeout /t 10
for /f "tokens=* delims=" %%x in (%profileTXT%) do (
start "" "%~dp0\EscapeFromTarkov.exe" -force-gfx-jobs native -token=%%x -config={"BackendUrl":"http://127.0.0.1:6969","Version":"live"}
)
GOTO MENU
:LAUNCHER
start "" %launcherEXE%
GOTO MENU
:MODS
start "" "%~dp0\user\mods"
GOTO MENU
:PROFILES
start "" "%~dp0\user\profiles"
GOTO MENU
:ROOT
start "" %~dp0
GOTO MENU
:EXITAIO
taskkill /im "Aki.Server.exe"
taskkill /im "EscapeFromTarkov.exe"
taskkill /im "Aki.Launcher.exe"