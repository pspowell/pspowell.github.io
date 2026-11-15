---
layout: post
title: "Link Shell Extension on Windows 11: Install, Use, and Troubleshoot Junctions and Links"
date: 2026-11-14 19:55:00 -0500
tags: [windows, filesystem, junctions, symlinks, hardlinks, tools]
last_modified_at: 2026-11-14
redirect_from:
  - /2025/11/24/How-to-Install-and-Use-Link-Shell-Extension-on-Windows.html
  - /2025/11/19/How-to-Install-and-Use-Link-Shell-Extension-on-Windows.html
  - /2025/11/23/Link-Shell-Extension-Install-and-Troubleshooting.html
  - /2025/11/19/Link-Shell-Extension-Install-and-Troubleshooting.html
---
## Why this post {#why}

**Link Shell Extension** (LSE), by Hermann Schinagl, adds right-click commands to Windows Explorer for making **junctions**, **hardlinks** and **symbolic links**. It's free, and it's still the easiest way to do this in Explorer. Nothing built into Windows does the same job.

Is it still current? The latest stable release is **3.9.3.5**. The author's page lists a version 4.0 as in progress, but there's been no new stable release in a few years. The old version still installs and works on Windows 11. You just have to know where Windows 11 hides its menu items, which is covered below.

This post replaces my two earlier LSE posts (the install guide and the troubleshooting guide) with one updated version.

---

## The three link types {#types}

| | Junction | Symbolic link | Hardlink |
|---|---|---|---|
| Works on | Folders only | Files or folders | Files only |
| Across drives | Yes, local drives only | Yes, including network shares | No, same drive only |
| Needs admin | No | Yes, unless Developer Mode is on | No |
| If the target is deleted | Link breaks | Link breaks | File survives (it's the same file) |
| Typical use | Move a big folder to another drive and leave a "pointer" behind | Same as junction, plus files and network paths | Same file in two places with no extra disk space |

**Rule of thumb:** to move a folder like `C:\Users\You\Games` to `D:\` without breaking programs, use a **junction**.

All three need **NTFS**. They don't work on FAT32 or exFAT drives, which most USB sticks use.

---

## Install {#install}

1. **Download** from the official page:
   <https://schinagl.priv.at/nt/hardlinkshellext/linkshellextension.html>
   Pick the installer for your PC. On almost every Windows 11 PC that's the 64-bit one (`HardLinkShellExt_X64.exe`). Use the ARM64 build on Snapdragon or ARM laptops.

   Or install with winget:

   ```powershell
   winget install -e --id HermannSchinagl.LinkShellExtension
   ```

2. **Run it from a local folder** like Downloads, not from OneDrive, a network share, or a synced folder.
3. If Windows blocks it, right-click > **Properties** > check **Unblock** > OK.
4. **Run the installer.** It checks for the Microsoft Visual C++ runtime and installs it if it's missing.
5. The installer **restarts Explorer**, so your taskbar and open Explorer windows will blink. That's normal.

---

## Make a junction with LSE {#use}

1. Right-click the **target folder** (the real folder, e.g. `D:\Games`) and choose **Pick Link Source**.
2. Go to where you want the link (e.g. `C:\Users\You`), right-click an empty spot, and choose **Drop As** > **Junction**.

On **Windows 11**, these commands aren't on the short right-click menu. Click **Show more options** at the bottom, or hold **Shift** while you right-click.

Other choices under **Drop As**:

- **Hardlink**: files only, same drive only
- **Symbolic Link**: files or folders, any drive
- **Smart Copy / Smart Mirror / Clone**: copies a folder tree and keeps any links inside it intact

### Check that it worked {#verify}

- A junction or link shows a small **chain** icon on the folder.
- Right-click it > **Properties** > **Link Properties** tab shows the target, with an **Explore Target** button.
- A broken junction (target deleted or drive missing) may not show the Link Properties tab at all.

---

## Moving a folder to another drive {#move}

This is the most common reason to use a junction.

1. Close any program that uses the folder.
2. Move the folder: `C:\Users\You\Games` to `D:\Games`.
3. Right-click `D:\Games` > **Pick Link Source**.
4. Right-click in `C:\Users\You` > **Drop As** > **Junction**.

Programs still see `C:\Users\You\Games`, but the files live on `D:`.

---

## Built-in commands (no install needed) {#commands}

For a one-off link or a script, Windows can do it without LSE.

**Command Prompt:**

```bat
mklink /J "C:\Users\You\Games" "D:\Games"
```

Use `/D` instead of `/J` for a folder symlink, `/H` for a hardlink, or no switch for a file symlink.

**PowerShell:**

```powershell
New-Item -ItemType Junction -Path "C:\Users\You\Games" -Target "D:\Games"
```

**List junctions and links** in a folder and its subfolders:

```bat
dir /AL /S C:\Users\You
```

### Removing a junction safely {#remove}

Removing a junction should only remove the link, not the files in the target. Use one of these:

```bat
rmdir "C:\Users\You\Games"
```

```powershell
(Get-Item "C:\Users\You\Games").Delete()
```

**Don't** use `Remove-Item -Recurse` or `del /s` on a junction. Some versions of Windows and PowerShell follow the link and delete the files in the **target**.

---

## Symlinks without admin: Developer Mode {#devmode}

Junctions and hardlinks don't need admin rights. Symbolic links do, unless you turn on Developer Mode:

**Settings > System > Advanced > For developers > Developer Mode: On**

On older Windows 11 builds it's under **Settings > Privacy & security > For developers**.

With Developer Mode on, LSE and `mklink /D` make symlinks without a UAC prompt. You don't need this for junctions.

---

## Troubleshooting {#troubleshooting}

| Problem | Fix |
|---|---|
| No LSE items on the right-click menu | Click **Show more options**, or Shift + right-click |
| Still no items after installing | Restart Explorer: Task Manager > **Windows Explorer** > **Restart**, or sign out and back in |
| Menu never appears | Wrong build installed. Uninstall it and install the x64 one (ARM64 on ARM PCs) |
| Installer won't run or does nothing | Copy it to a local folder (not OneDrive), **Unblock** it in Properties, and check whether antivirus quarantined it |
| Upgrade fails or acts strangely | Uninstall the old version in **Settings > Apps > Installed apps**, restart, then reinstall |
| **Drop As** options greyed out | The drive isn't NTFS (FAT32/exFAT), or you're trying to hardlink across drives. LSE's `ln --probefs X:` shows a drive's file system |
| Symlink fails with "privilege not held" | Run as admin, or turn on Developer Mode |
| Junction to a network share fails | Junctions only work with local drives. Use a symbolic link instead |

---

## Which to use {#summary}

- **LSE**: occasional work in Explorer, and the chain icons show which folders are links.
- **`mklink` or PowerShell**: one-off jobs on a PC without LSE, or anything you'll script or repeat.
- **Junction** for folders on local drives, **symlink** for files or network paths, **hardlink** for one file in two places on the same drive.
