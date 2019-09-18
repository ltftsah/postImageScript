@echo off
title Post Image Script
pushd \\server\install_script

:: Program installs
:: Specify as many as needed, but they must be sequential from 1 with no gaps
:: List the program names
set "App[1]=GoverLan"
set "App[2]=DisplayLink"
set "App[3]=AdobeReader"
set "App[4]=CUCILync"
set "App[5]=Plantronics"
set "App[6]=7Zip"
set "App[7]=TeamViewer"
set "App[8]=All Apps"

:: Display the Menu
:: Display message only if invalid input entered
set "Message="
:Menu
cls
echo.%Message%
echo.
echo.  ==== Apps you can install ====
echo.
set "x=0"
:MenuLoop
set /a "x+=1"
if defined App[%x%] (
    call echo   %x%. %%App[%x%]%%
    goto MenuLoop
)
echo.

:: Prompt User for Choice
:Prompt
set "Input="
set /p "Input=Select apps to install(Enter corresponding number with a space between numbers):"

:: Validate Input [Remove Special Characters]
if not defined Input goto Prompt
set "Input=%Input:"=%"
set "Input=%Input:^=%"
set "Input=%Input:<=%"
set "Input=%Input:>=%"
set "Input=%Input:&=%"
set "Input=%Input:|=%"
set "Input=%Input:(=%"
set "Input=%Input:)=%"
:: Equals are not allowed in variable names
set "Input=%Input:^==%"
call :Validate %Input%

:: Process Input
call :Process %Input%
goto End


:Validate
set "Next=%2"
if not defined App[%1] (
    set "Message=Invalid Input: %1"
    goto Menu
)
if defined Next shift & goto Validate
goto :eof


:Process
set "Next=%2"
call set "App=%%App[%1]%%"

:: Run Installations
:: Specify all of the installations for each app.
:: Step 2. Match on the application names and perform the installation for each
if "%App%" EQU "GoverLan" start /WAIT Goverlan_client_Agents_v8.exe /s /w
if "%App%" EQU "DisplayLink" start /WAIT DisplayLink_v8.exe /s /w
if "%App%" EQU "AdobeReader" start /WAIT AdbeRdr1012_en_US.exe /s /w
if "%App%" EQU "CUCILync" start /WAIT CUCILyncSetup.msi /passive
if "%App%" EQU "Plantronics" start /WAIT PlantronicsHubInstaller_x64.msi /passive
if "%App%" EQU "7Zip" start /WAIT 7z920-x64.msi /passive
if "%App%" EQU "TeamViewer" start /WAIT TeamViewer_Host_Setup.exe /s /w
if "%App%" EQU "All Apps" (
    start /WAIT Goverlan_client_Agents_v8.exe /s /w
    start /WAIT DisplayLink_v8.exe /s /w
    start /WAIT AdbeRdr1012_en_US.exe /s /w
    start /WAIT CUCILyncSetup.msi /passive
    start /WAIT PlantronicsHubInstaller_x64.msi /passive
    start /WAIT 7z920-x64.msi /passive
    start /WAIT TeamViewer_Host_Setup.exe /s /w
)

:: Prevent the command from being processed twice if listed twice.
set "App[%1]="
if defined Next shift & goto Process
goto :eof

:End

echo ==== gpupdate ====
pause
gpupdate /force
echo.

echo === Create Shortcut===
pause
xcopy "Homepage.url" "C:\Users\Public\Desktop" /Y
echo.

echo ==== Delete VPN Profile files ====
::important to be careful if changing these file paths
popd
cd C:\ProgramData\Cisco\Cisco AnyConnect Secure Mobility Client\Profile
del *.*
pushd \\server\install_script
echo.

echo ==== Move correct VPN files ====
pause
xcopy "VPN profile\profile.xsd" "%USERPROFILE%\Desktop" /Y
xcopy "VPN profile\users.xml" "%USERPROFILE%\Desktop" /Y

xcopy "%USERPROFILE%\Desktop\AnyConnectProfile.xsd" "C:\ProgramData\Cisco\Cisco AnyConnect Secure Mobility Client\Profile" /Y
xcopy "%USERPROFILE%\Desktop\dublinusers.xml" "C:\ProgramData\Cisco\Cisco AnyConnect Secure Mobility Client\Profile" /Y

del "%USERPROFILE%\Desktop\AnyConnectProfile.xsd"
del "%USERPROFILE%\Desktop\dublinusers.xml"
echo.

echo ==== Check if Trend is installed ====
if exist "C:\Program Files (x86)\Trend Micro" (
	echo Trend already installed
) else (
	echo !!Trend not installed!!
)
pause

echo ==== Change UAC level ====
pause
SwitchUACLevel.vbs
echo.

echo ==== Set laptop to "Do nothing" when lid is closed ====
pause
powercfg -setdcvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0
powercfg -setacvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0
powercfg -SetActive SCHEME_CURRENT
echo.

popd
shutdown -r -t 60 -c "Windows will restart within 60sec. Please save any important work."
