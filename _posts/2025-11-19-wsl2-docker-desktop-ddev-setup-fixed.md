---
layout: post
title: "WSL2 + Docker Desktop + DDEV Setup Guide"
date: 2025-11-19
tags: [windows, wsl2, docker, ddev, php]
---

# WSL2 + Docker Desktop + DDEV Setup Guide  
*A complete walkthrough for Windows 11 users*

## Overview

This guide walks you through setting up a full WSL2 + Docker Desktop + DDEV environment on Windows 11.  
When finished, you'll have:

- WSL2 installed and working  
- A Linux distro of your choice  
- Docker Desktop (supporting both **Windows and Linux containers**)  
- DDEV configured to use Docker Desktop  
- A working PHP “Hello World” development site at `https://php-hello.ddev.site`

This is ideal for PHP, Drupal, WordPress, Laravel, or general web development using containerized environments.

---

## 1. Install Prerequisites

### Install Chocolatey (if not already installed)

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

### Install Winget (if missing)

```powershell
choco install winget -y
```

---

## 2. Install and Test WSL2

Enable WSL features:

```powershell
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```

Install WSL2 base components (no distro):

```powershell
wsl --install --no-distribution
```

Set WSL2 as default:

```powershell
wsl --set-default-version 2
```

Check status:

```powershell
wsl --status
```

Reboot if required.

---

## 3. Choose and Install a Linux Distro

List available distros:

```powershell
wsl --list --online
```

Install one by NAME:

```powershell
wsl --install -d Ubuntu-24.04
```

Launch it once from the Start menu to finish initialization.

---

## 4. **Start Docker Desktop BEFORE Installing DDEV**

This step prevents the error:

```
Cannot connect to the Docker daemon at unix:///var/run/docker.sock
```

### Install Docker Desktop

```powershell
winget install -e --id Docker.DockerDesktop --accept-package-agreements --accept-source-agreements
```

### Start Docker Desktop now

1. Open **Docker Desktop**  
2. Wait until it shows **Running**

### Enable WSL Integration

Docker Desktop → **Settings**:

- **General**  
  ✔ Enable *“Use the WSL 2 based engine”*
- **Resources → WSL Integration**  
  ✔ Turn on  
  ✔ Check **Ubuntu-24.04**

Click **Apply & Restart**.

### Test Docker inside WSL

```bash
docker version
```

You must see **both Client and Server**.

---

## 5. Install DDEV (AFTER Docker Desktop is running)

Install using Chocolatey:

```powershell
choco install ddev -y
```

Test in PowerShell:

```powershell
ddev version
```

Test in Ubuntu:

```bash
ddev version
```

If not found inside WSL, install it there:

```bash
curl -LO https://raw.githubusercontent.com/ddev/ddev/main/scripts/install_ddev.sh
chmod +x install_ddev.sh
./install_ddev.sh
```

---

## 6. Create a PHP “Hello World” App Using DDEV

Create project folder:

```powershell
mkdir "$env:USERPROFILE\Documents\DDEV\php-hello"
cd "$env:USERPROFILE\Documents\DDEV\php-hello"
```

Initialize project:

```powershell
ddev config --project-type=php --project-name=php-hello --docroot=. --php-version=8.2
```

Create index.php:

```powershell
@'
<?php
echo "<h1>Hello from DDEV + Docker + PHP!</h1>";
echo "<p>Your development environment is working!</p>";
?>
'@ | Out-File -FilePath "index.php" -Encoding utf8
```

Start:

```powershell
ddev start
```

Open:

```
https://php-hello.ddev.site
```

---

## 7. Common Commands

```powershell
ddev stop
ddev restart
ddev list
ddev delete -O
```

---

## Conclusion

You now have:

- WSL2 installed  
- Linux distro configured  
- Docker Desktop running with WSL2 integration  
- DDEV installed **after** Docker Desktop was running  
- A functional PHP development environment

This avoids Docker socket errors and provides a stable workflow.
