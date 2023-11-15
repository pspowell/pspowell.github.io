---
layout: post
title:  "How to Install and Use Winget on Windows"
date:   2023-11-10 
categories: tech
---

## How to Install and Use Winget on Windows**

Winget, also known as the Windows Package Manager, is a free and
open-source package manager designed for Windows. It allows users to
automate the process of installing, upgrading, configuring, and removing
applications.
Here’s a step-by-step guide on how to install and use Winget on Windows.

### Step 1: Check if Winget is Already Installed

Winget comes pre-installed on some versions of Windows. To check if it’s
already installed on your system, open the Command Prompt or PowerShell
and type winget. If it’s installed, you should see the program
version, syntax, and available options.

### Step 2: Install Winget

If Winget is not already installed on your system, there are two ways to
install it:

#### Option 1: Install Winget via Microsoft Store

1. Open the Windows Start menu, type store, and press Enter to open the Microsoft Store app.
2. In the search bar, type winget and press Enter. In the results, click the App Installer application.
3. On the App Installer page, click Get to install the app. Wait for the installation to finish.
4. Verify the installation by invoking winget in Windows PowerShell or the Command Prompt.

#### Option 2: Install Winget via GitHub

1. Navigate to the Winget GitHub page [HERE](https://github.com/microsoft/winget-cli).
2. Under the Releases section, click the latest available release.
3. On the Version page, scroll down to the Assets section and click the .msixbundle file to start the download.
4. Run the downloaded file and click Update. Wait for the installation process to finish.
5. Verify the installation by running winget in PowerShell or Command Prompt.

### Step 3: Use Winget

Once Winget is installed, you can use it to manage packages on your system. Here are some basic commands, executed from the Powershell command prompt:

- winget help: This bring up some help text
- winget install \<package-name\>: This command installs a package.
- winget upgrade \<package-name\>: This command upgrades a package.
- winget uninstall \<package-name\>: This command uninstalls a package.
- winget list: This command lists all installed packages.
- winget search <package name>: This command searchs the repositories and lists available packages

For example, to install Visual Studio Code, you would use the command winget install vscode.

### Example of using Winget to install Sandboxie

[Sandboxie Plus](https://sandboxie-plus.com/Sandboxie/) is a third party application similar to Windows Sandbox that runs your programs in an isolated space which prevents them from making permanent changes to other programs and data in your computer.

Let's see if Winget can find this app by using Winget search:

```text

PS C:\WINDOWS\system32> winget search sandboxie

Name           Id                Version Match              Source
------------------------------------------------------------------

Sandboxie      Sandboxie.Classic 5.66.4                     winget
Sandboxie-Plus Sandboxie.Plus    1.11.4  Moniker: sandboxie winget
```

OK,  now let's install Sandboxie-Plus

```
PS C:\WINDOWS\system32> winget install Sandboxie-Plus
Found Sandboxie-Plus [Sandboxie.Plus] Version 1.11.4
This application is licensed to you by its owner.
Microsoft is not responsible for, nor does it grant any licenses to, third-party packages.
Downloading https://github.com/sandboxie-plus/Sandboxie/releases/download/v1.11.4/Sandboxie-Plus-x64-v1.11.4.exe
  ██████████████████████████████  19.8 MB / 19.8 MB
Successfully verified installer hash
Starting package install...
Successfully installed
```

We're done!!