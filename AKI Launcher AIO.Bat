@echo off
set serverEXE="%~dp0\Aki.Server.exe"
set launcherEXE="%~dp0\Aki.Launcher.exe"
set autoPlay=false
set closeOnLaunch=false


if not exist "%~dp0\ModManager\" mkdir "%~dp0\ModManager"
if not exist "%~dp0\ModManager\DisabledMods" mkdir "%~dp0\ModManager\DisabledMods"
if not exist "%~dp0\ModManager\DisabledPlugins" mkdir "%~dp0\ModManager\DisabledPlugins"
if not exist "%~dp0\ModManager\PluginCopies" mkdir "%~dp0\ModManager\PluginCopies"
if not exist "%~dp0\ModManager\defaultprofile.txt" GOTO SETUPPROFILE

if  %autoPlay% equ true (
	start "" /MIN %serverEXE%
	ECHO Server launched and minimized! Running client...
	timeout /t 1
	for /F "delims=" %%x in (%~dp0\ModManager\defaultprofile.txt) do (
	start "" "%~dp0\EscapeFromTarkov.exe" -force-gfx-jobs native -token=%%x -config={"BackendUrl":"http://127.0.0.1:6969","Version":"live"}
)
	
	if %closeOnLaunch% equ true (
	ECHO Closing launcher...
	timeout /t 1
	exit
	)
	
)

:MENU
cd "%~dp0"
CLS
ECHO ...............................................
ECHO              SPT-AKI Launcher AIO
ECHO ...............................................
ECHO.
ECHO 1 - Server
ECHO 2 - Client
ECHO 3 - AKI Launcher
ECHO 4 - Mod Folder
ECHO 5 - Profiles Folder
ECHO 6 - Change Default Profile
ECHO 7 - Root SPT-AKI Directory
ECHO 8 - Mod Manager
ECHO 9 - Exit AIO (Close all SPT-AKI windows)
ECHO.
choice /c 123456789 /m "Select a choice: "
IF ERRORLEVEL ==9 GOTO EXITAIO
IF ERRORLEVEL ==8 GOTO MODMANAGER
IF ERRORLEVEL ==7 GOTO ROOT
IF ERRORLEVEL ==6 GOTO SETUPPROFILE
IF ERRORLEVEL ==5 GOTO PROFILES
IF ERRORLEVEL ==4 GOTO MODS
IF ERRORLEVEL ==3 GOTO LAUNCHER
IF ERRORLEVEL ==2 GOTO RESTARTCLIENT
IF ERRORLEVEL ==1 GOTO RESTART

:SETUPPROFILE
CLS
ECHO Setting up profile for the first time! It will load all profiles for SPT-AKI. Please choose the one that you're currently playing. (HINT: Press TAB to cycle through your choices or copy and paste it.)
ECHO.
pause
CLS
cd "%~dp0\user\profiles"
dir "%~dp0\user\profiles\*.json" /B /A-D
ECHO.
SET /P M=Please select your default profile: 
for /f "tokens=1,2 delims=." %%a in ("%M%") do (
  set jsonName=%%a
)
ECHO %jsonName% > "%~dp0\ModManager\defaultprofile.txt"
GOTO MENU

:RESTART
taskkill /im "Aki.Server.exe"
timeout /t 1
start "" %serverEXE%
GOTO MENU

:RESTARTCLIENT
taskkill /im EscapeFromTarkov.exe
timeout /t 2
for /F "delims=" %%x in (%~dp0\ModManager\defaultprofile.txt) do (
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
:MODMANAGER
cd "%~dp0"
CLS
ECHO ...............................................
ECHO              SPT-AKI Mod Manager
ECHO ...............................................
ECHO.
ECHO ENABLED MODS
ECHO =============
dir "%~dp0\user\mods" /a:d /b
ECHO.
ECHO DISABLED MODS
ECHO =============
dir "%~dp0\ModManager\DisabledMods" /a:d /b
ECHO.
ECHO ENABLED BEPINEX PLUGINS
ECHO =============
dir "%~dp0\BepInEx\plugins\*.dll" /B /A-D | findstr /v /i "aki-core.dll$ aki-custom.dll$ aki-debugging.dll$ aki-singleplayer.dll$ ConfigurationManager.dll$" > "%~dp0\ModManager\plugins.txt"

for /F "delims=" %%x in (%~dp0\ModManager\plugins.txt) do (
	echo %%x
)
ECHO.
ECHO DISABLED BEPINEX PLUGINS
ECHO =============
dir "%~dp0ModManager\DisabledPlugins\*.dll " /B /A-D| findstr /v /i "aki-core.dll$ aki-custom.dll$ aki-debugging.dll$ aki-singleplayer.dll$ ConfigurationManager.dll$" > "%~dp0\ModManager\disabledPlugins.txt"

for /F "delims=" %%x in (%~dp0\ModManager\disabledPlugins.txt) do (echo %%x)
ECHO.
choice /c 12345 /m "1) Enable Mod, 2) Disable Mod 3) Enable Plugin 4) Disable Plugin 5) Return"
IF ERRORLEVEL ==5 GOTO MENU
IF ERRORLEVEL ==4 GOTO DISABLEPLUGIN
IF ERRORLEVEL ==3 GOTO ENABLEPLUGIN
IF ERRORLEVEL ==2 GOTO DISABLEMOD
IF ERRORLEVEL ==1 GOTO ENABLEMOD

:ENABLEPLUGIN
cd "%~dp0ModManager\DisabledPlugins"
ECHO.
ECHO DISABLED PLUGINS
ECHO =============
dir "%~dp0ModManager\DisabledPlugins\*.dll" /B /A-D | findstr /v /i "aki-core.dll$ aki-custom.dll$ aki-debugging.dll$ aki-singleplayer.dll$ ConfigurationManager.dll$" > "%~dp0\ModManager\disabledPlugins.txt"

for /F "delims=" %%x in (%~dp0\ModManager\disabledPlugins.txt) do (echo %%x)
ECHO.
SET /P enableP=Please enter name of plugin or type "all" to enable all disabled plugins: 
IF /i %enableP%==all (for /F "delims=" %%x in (%~dp0\ModManager\disabledPlugins.txt) do (move "%~dp0ModManager\DisabledPlugins\%%x" "%~dp0\BepInEx\plugins")) else (move "%~dp0ModManager\DisabledPlugins\%enableP%" "%~dp0\BepInEx\plugins")
ECHO %enableP% has been activated!
timeout /t 5
GOTO MODMANAGER

:DISABLEPLUGIN
cd "%~dp0\ModManager\PluginCopies"
ECHO.
ECHO ENABLED PLUGINS
ECHO =============
dir "%~dp0BepInEx\plugins\*.dll" /B /A-D | findstr /v /i "aki-core.dll$ aki-custom.dll$ aki-debugging.dll$ aki-singleplayer.dll$ ConfigurationManager.dll$" > "%~dp0\ModManager\plugins.txt"

for /F "delims=" %%x in (%~dp0\ModManager\plugins.txt) do (
	echo %%x
	XCOPY "%~dp0\BepInEx\plugins\%%x" "%~dp0\ModManager\PluginCopies" /D >nul
)
ECHO.
SET /P disableP=Please enter name of plugin or type "all" to disable plugins: 
IF /i %disableP%==all (for /F "delims=" %%x in (%~dp0\ModManager\plugins.txt) do (move "%~dp0BepInEx\plugins\%%x" "%~dp0ModManager\DisabledPlugins")) else (move "%~dp0BepInEx\plugins\%disableP%" "%~dp0\ModManager\DisabledPlugins")
ECHO %disableP% has been deactivated!
DEL "%~dp0\ModManager\PluginCopies\*.dll"
timeout /t 5
GOTO MODMANAGER

:ENABLEMOD
ECHO.
ECHO DISABLED MODS
ECHO =============
dir "%~dp0\ModManager\DisabledMods" /a:d /b
ECHO.
cd "%~dp0\ModManager\DisabledMods"
SET /P enableM=Please enter name of mod or type "all" to enable all disabled mods: 
IF /i %enableM%==all (robocopy "%~dp0ModManager\DisabledMods" "%~dp0\user\mods" /MOVE /e) else (robocopy "%~dp0\ModManager\DisabledMods\%enableM%" "%~dp0\user\mods\%enableM%" /MOVE /e)
ECHO %enableM% has been activated!
timeout /t 5
GOTO MODMANAGER

:DISABLEMOD
ECHO.
ECHO ENABLED MODS
ECHO =============
dir "%~dp0\user\mods" /a:d /b
ECHO.
cd "%~dp0\user\mods"
SET /P disableM=Please enter name of mod or type "all" to disable all mods: 
IF /i %disableM%==all (robocopy "%~dp0user\mods" "%~dp0\ModManager\DisabledMods" /MOVE /e) else (robocopy "%~dp0\user\mods\%disableM%" "%~dp0\ModManager\DisabledMods\%disableM%" /MOVE /e)
ECHO %disableM% has been deactivated!
timeout /t 5
GOTO MODMANAGER

:EXITAIO
taskkill /im "Aki.Server.exe"
taskkill /im "EscapeFromTarkov.exe"
taskkill /im "Aki.Launcher.exe"