---
layout: post
title: "Export and backup Windows drivers with PowerShell (and how to restore them)"
date: 2026-01-26 00:00:00 -0500
tags: [windows-11, windows-10, powershell, drivers, backup, winpe]
---

If you’re about to reinstall Windows, move to new hardware, or build a WinPE recovery USB, it’s handy to grab a copy of your *installed* third‑party drivers first. Windows has built-in tooling for this—no third‑party “driver backup” apps required.

This post shows three reliable ways to export drivers:

- **PowerShell (DISM module):** `Export-WindowsDriver` (best all-around) citeturn0search0turn1view0  
- **DISM (command line):** `dism /online /export-driver` (same idea, different interface)
- **PnPUtil:** `pnputil /export-driver` (exports from the driver store) citeturn0search5turn0search1

> Note: `Export-WindowsDriver` exports **third-party drivers** from the image, not Microsoft in-box drivers. citeturn0search0

## What you’ll get (and what you won’t) {#what-youll-get}

An export is typically a folder tree containing `.inf` files plus their associated binaries (like `.sys`, `.dll`, catalogs, etc.). This is perfect for:

- Reinstalling drivers after a clean install (especially offline)
- Injecting drivers into an offline Windows image / WinPE workflow
- Keeping a “known good” driver set for a specific PC model

What you generally **won’t** get:

- Drivers that only ship as **vendor installers** (`.exe` / `.msi`) without a standard INF-based package
- Full OEM utilities/control panels that come with some device bundles

## Method 1: Export drivers from the running Windows install (recommended) {#method-1-online-export}

This is the straightforward “backup my current machine” approach using `Export-WindowsDriver -Online`. The Windows Club demonstrates the basic command exactly like this: citeturn1view0

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

## Method 2: Export drivers from an offline Windows image (WinPE-friendly) {#method-2-offline-export}

If you’re booted into **WinPE/WinRE**, or you’ve mounted an offline Windows image, you can export drivers from that offline path. The Windows Club shows this pattern for an offline image mounted at `c:\offline-image`: citeturn1view0

```powershell
$OfflinePath = "C:\offline-image"   # path where the offline Windows is mounted
$Dest        = "D:\DriverBackup"

New-Item -ItemType Directory -Path $Dest -Force | Out-Null
Export-WindowsDriver -Path $OfflinePath -Destination $Dest
```

If you’re working with a Windows folder on another drive (for example, the offline OS is on `E:`), you can point at the image root you mounted or captured. This is especially useful when you’re building your “Integrate with PE boot disk” workflow and need drivers available before Windows boots.

## Method 3: Export drivers from the Driver Store with PnPUtil {#method-3-pnputil}

Windows also includes **PnPUtil**, which can export driver packages from the driver store:

```powershell
$Dest = "D:\DriverBackup"
New-Item -ItemType Directory -Path $Dest -Force | Out-Null

pnputil /export-driver * $Dest
```

PnPUtil’s `/export-driver` supports exporting a specific `oem#.inf` or `*` for all packages. citeturn0search5turn0search1

To list what’s in the driver store (useful if you want *specific* packages):

```powershell
pnputil /enum-drivers
```

## Restoring drivers after reinstall (two practical options) {#restoring-drivers}

### Option A: Install all exported INF drivers recursively with PnPUtil {#restore-pnputil-add-driver}

After a clean install, copy your exported folder back to the machine, then run:

```powershell
pnputil /add-driver "D:\DriverBackup\*.inf" /subdirs /install
```

This searches subfolders for INF files and installs what applies.

### Option B: Point Device Manager at the folder {#restore-device-manager}

For one-off devices:

1. Open **Device Manager**
2. Right-click the device → **Update driver**
3. Choose **Browse my computer** and select your backup folder

## Tips and gotchas {#tips-and-gotchas}

- **Run elevated when in doubt.** Many driver-management tasks require Administrator rights; the Windows Club explicitly uses an elevated PowerShell prompt for export. citeturn1view0
- **Use an external drive** (or a separate partition) so your driver backup survives a wipe.
- **Keep the folder name stable** if you’re scripting WinPE restore flows.
- **Third-party only:** If you’re troubleshooting a missing in-box driver, exporting won’t help—Windows will provide those via the OS image/Windows Update. citeturn0search0

## References {#references}

- The Windows Club: “Export and Backup Device Drivers using PowerShell in Windows 11/10” citeturn1view0  
- Microsoft: `Export-WindowsDriver` (DISM PowerShell module) citeturn0search0  
- Microsoft: PnPUtil command syntax/examples citeturn0search5turn0search1  
