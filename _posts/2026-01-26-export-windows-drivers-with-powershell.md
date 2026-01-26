---
layout: post
title: "Export and backup Windows drivers with PowerShell (and how to restore them)"
date: 2026-01-26 00:00:00 -0500
tags: [windows-11, windows-10, powershell, drivers, backup, winpe]
---

If you’re about to reinstall Windows, move to new hardware, or build a WinPE recovery USB, it’s handy to grab a copy of your *installed* third‑party drivers first. Windows has built-in tooling for this—no third‑party “driver backup” apps required.

This post shows three reliable ways to export drivers:

- **PowerShell (DISM module):** `Export-WindowsDriver` (best all-around)  
- **DISM (command line):** `dism /online /export-driver` (same idea, different interface)  
- **PnPUtil:** `pnputil /export-driver` (exports from the driver store)

> **Note:** `Export-WindowsDriver` exports **third-party drivers** from the image, not Microsoft in-box drivers.

---

## What you’ll get (and what you won’t) {#what-youll-get}

An export is typically a folder tree containing `.inf` files plus their associated binaries (like `.sys`, `.dll`, catalogs, etc.). This is perfect for:

- Reinstalling drivers after a clean install (especially offline)
- Injecting drivers into an offline Windows image / WinPE workflow
- Keeping a “known good” driver set for a specific PC model

What you generally **won’t** get:

- Drivers that only ship as **vendor installers** (`.exe` / `.msi`) without a standard INF-based package
- Full OEM utilities/control panels that come with some device bundles

---

## Method 1: Export drivers from the running Windows install (recommended) {#method-1-online-export}

This is the simplest and most reliable approach for backing up drivers from your current system:

```powershell
# Pick a destination folder (external drive recommended)
$Dest = "D:\DriverBackup"

# Create it if it doesn't exist
New-Item -ItemType Directory -Path $Dest -Force | Out-Null

# Export third-party drivers from the running OS
Export-WindowsDriver -Online -Destination $Dest
```

### Quick verification {#quick-verification}

```powershell
Get-ChildItem -Path $Dest -Recurse -Filter *.inf |
  Select-Object -First 20 FullName
```

If you see many `.inf` files, your export worked.

---

## Method 2: Export drivers from an offline Windows image (WinPE-friendly) {#method-2-offline-export}

If you’re booted into **WinPE/WinRE**, or you’ve mounted an offline Windows image, you can export drivers from that offline path:

```powershell
$OfflinePath = "C:\offline-image"   # path where the offline Windows is mounted
$Dest        = "D:\DriverBackup"

New-Item -ItemType Directory -Path $Dest -Force | Out-Null
Export-WindowsDriver -Path $OfflinePath -Destination $Dest
```

This is ideal for recovery disks, offline servicing, and WinPE automation workflows.

---

## Method 3: Export drivers from the Driver Store with PnPUtil {#method-3-pnputil}

Windows also includes **PnPUtil**, which can export driver packages directly from the driver store:

```powershell
$Dest = "D:\DriverBackup"
New-Item -ItemType Directory -Path $Dest -Force | Out-Null

pnputil /export-driver * $Dest
```

To list what’s currently in the driver store:

```powershell
pnputil /enum-drivers
```

---

## Restoring drivers after reinstall {#restoring-drivers}

### Option A: Install all exported drivers automatically {#restore-pnputil}

```powershell
pnputil /add-driver "D:\DriverBackup\*.inf" /subdirs /install
```

### Option B: Manual install via Device Manager {#restore-device-manager}

1. Open **Device Manager**
2. Right-click the device → **Update driver**
3. Select **Browse my computer for drivers**
4. Point it at your driver backup folder

---

## Tips and gotchas {#tips-and-gotchas}

- Always run PowerShell **as Administrator**
- Store backups on an **external drive or separate partition**
- Keep a **consistent folder path** for automation scripts
- Exports include **third-party drivers only**
- Vendor installer-only drivers (`.exe` / `.msi`) will not export

---

## References {#references}

- Microsoft Docs – Export-WindowsDriver (DISM PowerShell Module)  
  https://learn.microsoft.com/en-us/powershell/module/dism/export-windowsdriver

- Microsoft Docs – PnPUtil Command Syntax  
  https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/pnputil-command-syntax

- The Windows Club – Export and Backup Device Drivers using PowerShell  
  https://www.thewindowsclub.com/export-and-backup-device-drivers-in-windows-10-using-powershell
