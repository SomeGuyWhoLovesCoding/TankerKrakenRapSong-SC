@echo off

:root
cls
Title Tanker Kraken
echo Welcome to the Tanker Kraken App!
timeout /t 2 /nobreak >Nul
echo.
echo 1. Launch The Game...
echo 2. Launch Tanker Kraken Window Enabler...
echo 3. Go to The Basement...
echo 4. Go to The Warehouse
echo 5. Exit...
echo.

SET choice=
SET /p choice=.\Input:  
IF /i '%choice%'=='1' GOTO game
IF /i '%choice%'=='2' GOTO tkwindowenabler
IF /i '%choice%'=='3' GOTO basement
IF /i '%choice%'=='4' GOTO warehouse
IF /i '%choice%'=='5' GOTO exit
IF /i '%choice%'=='die' GOTO die
IF /i '%choice%'=='' GOTO ok

:game
cls
Title Tanker Kraken
TKRapSong.exe -tankerkraken
GOTO root

:tkwindowenabler
Title Setup - Tanker Kraken Window Enabler
cls
echo Welcome to The Tanker Kraken Window Enabler Setup!
echo.
echo Would you like to enable The Tanker Kraken Window in Options?
SET choice=
SET /p choice=This might not work at some times unless you restart or shutdown your PC. [Y/N]: 
IF /i '%choice%'=='Y' GOTO yes
IF /i '%choice%'=='y' GOTO yes
IF /i '%choice%'=='N' GOTO back
IF /i '%choice%'=='n' GOTO back
IF /i '%choice%'=='' GOTO input

:input
echo.
echo Please Input.
timeout /t 2 /nobreak >Nul
cls
GOTO tkwindowenabler

:yes
cls
echo Initializing...
timeout /t 9 /nobreak >Nul
cls
echo Working on it...
timeout /t 11 /nobreak >Nul
cls
echo Almost done...
timeout /t 6 /nobreak >Nul
cls
set wallpaper=%userprofile%\Tanker Kraken Wallpaper.jpg
cls
reg add "HKCU\Control Panel\Desktop" /v Wallpaper /t REG_SZ /d %wallpaper% /f
cls
RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters
cls
echo Success! Let's test the game now!
pause >Nul
cls
Title Tanker Kraken
TKRapSong.exe -EnableTankerKrakenWindow
cls
echo Thanks for Trying it out! Closing...
timeout /t 4 /nobreak >Nul
exit

:basement
Title Tanker Kraken's Basement
cls
echo Welcome to Tanker Kraken's Old ass Basement.
echo.
echo Nothing here. Sorry.
pause >Nul
GOTO back

:warehouse
cls
Title Tanker Kraken's Warehouse
echo Welcome to Tanker Kraken's Warehouse.
echo How can I help you?
echo.
echo 1. Give me a secret code.
echo 2. Back.
SET choice=
SET /p choice=.\Input:  
IF /i '%choice%'=='1' GOTO code
IF /i '%choice%'=='2' GOTO back
IF /i '%choice%'=='' GOTO back

:code
cls
echo Here's The Secret Code for a random song: %random%
SET choice=
SET /p choice= Is this right? [Y/N]:  
IF /i '%choice%'=='y' GOTO game
IF /i '%choice%'=='Y' GOTO game
IF /i '%choice%'=='n' GOTO code
IF /i '%choice%'=='N' GOTO code

:die
cls
echo YOU HAVE NOW, RUINED MY LIFE. TIME TO DIE.
pause >Nul
exit

:back
cls
echo Teleporting back...
timeout /t 2 /nobreak >Nul
GOTO root
exit

:exit
cls
echo Shutting Down...
timeout /t 2 /nobreak >Nul
exit

:ok
echo.
echo No Choice? Ok!
echo.
timeout /t 3 /nobreak >Nul
GOTO game

:cheats
random = %random%%random%
tankerkraken = *522579295