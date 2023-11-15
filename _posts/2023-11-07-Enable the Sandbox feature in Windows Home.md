---
layout: post
title:  "Enable the Sandbox feature in Windows Home"
date:   2023-11-07 00:44:25 -0700
categories: tech
---
## Enable the Sandbox feature in Windows 10 or 11 Home Edition

>_**CAUTION**_ This post does not currently work, sandbox can no longer be enabled in Home Edition until this is fixed.  Instead, I've written a post on [How to Install and Use Winget on Windows](https://pspowell.github.io/tech/2023/11/10/How-to-Install-and-Use-Winget-on-Windows.html) which covers the use of Winget to install applicatons and uses the alternative Sandboxie-Plus as an example.

The Windows Sandbox is a new feature starting with [Windows 10
1903](https://www.deskmodder.de/blog/2019/03/21/windows-10-18362-iso-esd-deutsch-english/).  However, this new feature is not provided by default in Windows 10 Home so  these instructions provide a method to easily install the feature in Win 10/11 Home edition so that it is available as in the Pro edition.

### Prerequisites for the Windows Sandbox

- At least 4 GB of RAM (8 GB is better) should be installed.  
- There should be 1 GB of free space.
- The CPU must have at least 2 cores (4 cores + hyperthreading are
  better, of course)
- Virtualization must be enabled in the BIOS (VT-x)
- The CPU must have the SLAT (Second Level Address Translation)
  function
- Hyper-V is **not** necessary.

These must be present, otherwise the sandbox can be installed but not
activated. The fact that you can retrofit this function in the Home
edition is because the files for it are all already available.

All you have to do is [download and unzip the bat file](https://pspowell.github.io/tech/2023/11/08/Windows-Tech-Helper-files.html) and start it by
right-clicking and selecting "Run as Administrator. The Sandbox
Installer.bat first checks whether administrative rights exist and then
starts. All packages are then loaded and after a restart the sandbox can
be activated in the Control Panel -\> Programs and Features -\> \"Enable
Windows Features\". After that, it will appear in the Start menu under
Windows Sandbox.

If you wish, you may copy and paste the following into an "install sandbox feature.bat" file in lieu of downloading the batch file.

```
@echo off

echo Checking for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

echo Permission check result: %errorlevel%

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
echo Requesting administrative privileges...
goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"

echo Running created temporary "%temp%\getadmin.vbs"
timeout /T 2
"%temp%\getadmin.vbs"
exit /B

:gotAdmin
if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
pushd "%CD%"
CD /D "%~dp0" 

echo Batch was successfully started with admin privileges
echo .
cls
GOTO:menu
:menu
Title Sandbox Installer
echo Backup is highly recommended for SAFETY, and
echo to remove the feature without a trace if needed.
echo --------------------------------------------------
echo Please select an option:
echo 1 Install
echo 2 Uninstall
echo 3 Exit
set /p uni= Enter option number:
if %uni% ==1 goto :in
if %uni% ==2 goto :un
if %uni% ==3 goto :ex

:in
cls
Title Install Sandbox

pushd "%~dp0"

dir /b %SystemRoot%\servicing\Packages\*Containers*.mum >sandbox.txt

for /f %%i in ('findstr /i . sandbox.txt 2^>nul') do dism /online /norestart /add-package:"%SystemRoot%\servicing\Packages\%%i"

del sandbox.txt

Dism /online /enable-feature /featurename:Containers-DisposableClientVM /LimitAccess /ALL /NoRestart

goto :remenu

:un
cls
Title Uninstall Sandbox

pushd "%~dp0"

Dism /online /disable-feature /featurename:Containers-DisposableClientVM /NoRestart

dir /b %SystemRoot%\servicing\Packages\*Containers*.mum >sandbox.txt

for /f %%i in ('findstr /i . sandbox.txt 2^>nul') do dism /online /norestart /remove-package:"%SystemRoot%\servicing\Packages\%%i"

del sandbox.txt

goto :remenu

:remenu
cls
echo Do you want to restart your computer now?
echo 1 Yes
echo 2 No
set /p uni= Enter option number:
if %uni% ==1 goto :re
if %uni% ==2 goto :ex

:re
shutdown /r /t 0 /f
goto :ex

:ex
exit
```
