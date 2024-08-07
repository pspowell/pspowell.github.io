---
layout: post
title:  "**Windows Tech Helper files**"
date:   2023-11-08
categories: tech
---

## Windows Tech Helper files

I've put an archive of helpful files on my GitHub which simplify tasks or add features such as creating a Windows Image backup under special conditions and adding new options to the right-click menu.

### Setup
1. download the zip file from [HERE](https://github.com/pspowell/Windows-tech-helper-files/archive/refs/heads/main.zip). 
1. Once downloaded, go to your download directory then right-click and select Properties, select the Unblock checkbox and click OK. (This indicates to Windows that the batch files are OK to run on your system.)
1. Right-click the zip file again and select  \*\*Extract All\*\* 

I'll maintain a list of all files here along with a brief description.  Further information will be referenced where available.

>**_IMPORTANT!!_**
Make a current backup!

### Windows Image Backup

- **Image_Backup.bat**  
      Copy this file to the external backup drive, then right-click and select \*\*Run As Administrator\*\*.  Will not work on a flash drive.  This creates a full Windows Image Backup on the drive.  Usage is discussed [HERE](https://pspowell.github.io/tech/2023/11/15/Backup-your-system-with-Image-Backup.html)
- **Image Backup to flash.bat**  
      Same as above, but this defeats the windows limitation of not working on a flash drive by mapping the drive as a network drive first.  Expect 8-10 hours or
      overnight for the backup to complete.
- **Image Backup to VHDX.bat**  
      **Image Backup to VHDX.ps1**  
      If you have less than half of the C drive used, either of these will:
       1. Create a virtual hard disk on the C drive.
       2. Mount the VHD and perform the backup to it, then dismount. 
             - The VHD can then be copied to OneDrive, flash drive, etc.  
             - Useful as another way of taking a snapshot of the system before making risky changes when you don't have external storage available
             - Since the virtual drive is located on the system disk, it will be lost as well if the system disk fails.  The `C:\backup.vhdx` should be copied to external storage so you'll still have a backup in the event of a catatrophic failure.

### Registry Tweaks

- **Add new .ps1 to right_click.ps1**  
      **Remove_ps1_from_New_context_menu.reg**  
      Add/remove "new Powershell Script" to the right-click context menu.
- **Add new markdown to right_click.reg**  
      Adds "new README.md" to the right-click context menu.  Useful if you work with GitHub/Markdown a lot.
- **Add Take Ownership to Context menu.reg  
      Remove Take Ownership from Context Menu**  
      Add/remove "Take Ownership"  to the right-click context menu.  Useful if you frequently need to access locked files/dirs.
- **Add VSCode to context menu.reg**  
      Adds "Edit with VSCode"  to the right-click context menu, although the preferred way is to select this option during VSCode installation.  
- **Add_Open_PowerShell_window_here_as_administrator_context_menu.reg
Remove_Open_PowerShell_window_here_as_administrator_context_menu.reg**  
      Adds "Open Powershell Window here as Administrator" to the right-click context menu.  Useful to get an elevated command prompt in a directory from the File Explorer.
- **localaccounttokenfilterpolicy.reg**  
      allows you to access drives as C$, D$, etc. on computers you can reach on your network

###  Other

- **Enable Sandbox on Windows Home.bat**  
      Adds Sandox to Windows Home Edition.  See the [BLOG](https://pspowell.github.io/tech/2023/11/07/Enable-the-Sandbox-feature-in-Windows-Home.html) on this item.
- **Flush SoftwareDistribution folder.bat**  
      Flushes the SoftwareDistribution folder.  Make a backup first.
- **Get Computername of VHD file.ps1**  
      If you have a VHD file of a disk but forgot what computer it came from.
- **reset permissions.bat**  
      Run from a CMD prompt as \*\*reset permissions \<path\>\*\*. Takes ownership and resets permissions for things like WindowsImageBackkup directories.
- **unpin all items in start menu.bat**  
      Unpins everything from the start menu
