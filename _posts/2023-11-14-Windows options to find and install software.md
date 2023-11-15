---
layout: post
title:  "Windows options to find and install software"
date:   2023-11-14 
categories: software
---

This blog describes several different ways to install software on a Windows PC.  With the exception of a direct download, all provide an assurance that the software is coming from a reputable source.  Links are provided where helpful.

### Download installer from company websites

- You get the latest version directly from the source
- Doesn't stay up to date unless the software updates itself or you go through the process of updating it
- Open to downloading malware if you download from a bad source
- Possible to get virtually any software you want this way

### [winget](https://learn.microsoft.com/en-us/windows/package-manager/winget/)

- Managed repository greatly reduces chance of downloading malware
- Requires learning commands
- Installs may not be as up to date
- Easily /auto update software
- May not have all programs, have to find and add additional repositories
- Reliant on Microsoft proprietary tooling

### [chocolatey](https://docs.chocolatey.org/en-us/)

- Mostly the same as winget list, except it is open source and has a larger community / more support
  
### Windows Store

- Managed repository reduces chance of downloading malware
- GUI interface, easier to use than learning command line tools
- Easily / auto update software
- Reliant on Microsoft proprietary tooling
- Limited number of applications.

### [PatchMyPC](https://patchmypc.com/home-updater)

- Third-party solution
- Large selection of software not found in other options
- ability to save install configurations for one-click installs

### ChrisTitus Toolbox

This is invoked by running the command `irm christitus.com/win|iex` from an administrative Powershell command prompt (`<Win>, "Powershell", <right-click>,<Run as Administrator>`).  It then downloads and executes a script that automates the WinGet install/update of many common packages, as well as providing an automated execution of the most useful/popular Windows tweaks

- Third-party solution
- "One stop shop" - my personal choice for initial setup of a new install, including debloating, many initial software installs, and other windows tweaks.

