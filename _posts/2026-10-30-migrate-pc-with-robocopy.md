---
layout: post
title: "Moving to a new PC with robocopy (now that PC-to-PC Migration is gone)"
date: 2026-10-30 00:00:00 -0400
tags: [windows, robocopy, migration, backup, powershell]
last_modified_at: 2026-10-30
---
## Why this post {#why}

Windows 11 had a short-lived **PC-to-PC Migration** feature in the Windows Backup app. It copied files and settings straight from the old PC to the new one over Wi-Fi or a network cable during setup. Microsoft removed it in the September 2026 preview update, and it's gone for everyone with the October 13, 2026 update (KB5127648). Microsoft now points people to **Windows Backup** instead.

Windows Backup works, but it sends everything through **OneDrive and your Microsoft account**. The free OneDrive plan holds 5 GB, so most people's Pictures folder alone won't fit. It also needs internet on both PCs and a Microsoft account sign-in.

`robocopy` is built into every copy of Windows. It copies straight to a USB drive or across your home network, it skips files that are already copied, it retries locked files, and it can be stopped and restarted. This post wraps it in one script so you don't have to remember the switches.

---

## What moves and what doesn't {#scope}

| Moves | Doesn't move |
|---|---|
| Desktop, Documents, Downloads, Pictures, Music, Videos, Favorites | Installed programs (reinstall them) |
| Any extra folders you name (e.g. `C:\Dev`) | Program settings in `AppData` |
| File dates and attributes | Software licenses and activations |
| Folders you've moved to another drive (the script follows them) | Wi-Fi passwords, printers, Windows settings |

Folders that already live **inside OneDrive** are skipped by default, since OneDrive will bring those down on the new PC by itself.

---

## Before you start {#before}

1. **Make a list of your programs.** On the old PC, run this and keep the file:

   ```powershell
   winget export -o "$env:USERPROFILE\Desktop\apps.json"
   ```

   On the new PC, `winget import -i apps.json` reinstalls most of them.
2. **Save license keys** for paid software (Office, Macrium, etc.) and deactivate anything that limits installs.
3. **Close Outlook** if you use a `.pst` file (it lives in `Documents\Outlook Files`). Open files get retried, then skipped.
4. **Get the script:** [Migrate-UserData.ps1](/assets/Migrate-UserData.ps1). If Windows blocks it, right-click > **Properties** > check **Unblock**, or run:

   ```powershell
   Unblock-File .\Migrate-UserData.ps1
   ```

---

## Route 1: through a USB drive (simplest) {#usb}

Best when the PCs aren't on the same network, or you want a copy to keep. Use a drive formatted **NTFS** or **exFAT** (FAT32 can't hold files over 4 GB).

**On the old PC** (USB drive is `E:` in this example):

```powershell
cd $env:USERPROFILE\Downloads
.\Migrate-UserData.ps1 -Destination E:\Migration -Preview   # see what would copy
.\Migrate-UserData.ps1 -Destination E:\Migration            # copy it
```

This creates `E:\Migration\<your user name>\Desktop`, `...\Documents`, and so on.

**On the new PC** (sign in as your user first):

```powershell
.\Migrate-UserData.ps1 -Source E:\Migration\Preston
```

Replace `Preston` with the folder name the first step created.

---

## Route 2: straight across the network {#lan}

Best for large amounts of data when both PCs are on the same home network. A network cable is much faster than Wi-Fi.

**On the old PC, share your user folder:**

1. In File Explorer, go to `C:\Users`, right-click your user folder > **Properties** > **Sharing** > **Advanced Sharing**.
2. Check **Share this folder**, give it a share name (e.g. `Preston`), click **Permissions**, and give your account **Read**.
3. Note the PC's name: **Settings > System > About > Device name**.

**On the new PC:**

```powershell
.\Migrate-UserData.ps1 -Source \\OLDPC\Preston -Preview
.\Migrate-UserData.ps1 -Source \\OLDPC\Preston -Threads 8
```

When Windows asks for credentials, use the **old PC's** user name and password (as `OLDPC\username` for a local account, or your Microsoft account email).

Over Wi-Fi, use `-Threads 4` or less. Many parallel copies over Wi-Fi can be slower than a few.

When you're done, turn the share off on the old PC.

> If you've moved Documents or Pictures to another drive on the old PC (e.g. `D:\Documents`), they're not under the shared user folder. Share that folder too, or use the USB route, which follows moved folders automatically.

---

## Extra folders {#extra}

Add any other folders with `-Extra`. They're stored under `_Extra` on the drive and put back at the same path on the new PC:

```powershell
# old PC
.\Migrate-UserData.ps1 -Destination E:\Migration -Extra C:\Dev, D:\Photos
# new PC
.\Migrate-UserData.ps1 -Source E:\Migration\Preston -Extra C:\Dev, D:\Photos
```

To copy only certain folders, use `-Folders`:

```powershell
.\Migrate-UserData.ps1 -Destination E:\Migration -Folders Documents, Pictures
```

---

## What the script actually runs {#switches}

For each folder, it calls `robocopy` with these switches:

| Switch | What it does |
|---|---|
| `/E` | Copy all subfolders, including empty ones |
| `/COPY:DAT` `/DCOPY:DAT` | Copy data, attributes and timestamps, but not owners/permissions (the new PC's user is a different account, so old permissions would just get in the way) |
| `/XJ` | Skip junctions, avoiding the `My Music` loops inside old Documents folders |
| `/R:2 /W:5` | Retry a locked file twice, 5 seconds apart, then move on (robocopy's default is a million retries) |
| `/MT:16` | Copy 16 files at a time (change with `-Threads`) |
| `/FFT` | Allow 2-second timestamp differences, needed for exFAT/FAT USB drives |
| `/XA:ST` and `/XF ...` | Skip system and temp files, `desktop.ini`, `thumbs.db`, Office `~$` lock files |
| `/L` | Only with `-Preview`: list, don't copy |

It **never uses `/MIR` or `/PURGE`**, so nothing at the destination is ever deleted. Running it twice just copies what changed.

If you'd rather run robocopy by hand for one folder, this is the core of it:

```powershell
robocopy "C:\Users\Preston\Documents" "E:\Migration\Preston\Documents" /E /COPY:DAT /DCOPY:DAT /XJ /R:2 /W:5 /MT:16 /FFT /NP /LOG+:"$env:TEMP\copy.log"
```

---

## Reading the results {#results}

At the end, the script prints a table:

- **Copied:** files were copied.
- **Up to date:** everything was already there.
- **Not found:** that folder doesn't exist on the source (normal for Favorites on many PCs).
- **FAILED - see log:** at least one file couldn't be copied.

The full log is in your TEMP folder (the script prints the path). Search it for `ERROR`. Almost every failure is a file that was open in some program. Close it and run the same command again. Only the missing files get copied.

Robocopy's own exit code is a set of flags, not a pass/fail: **0-7 means success**, **8 or higher means something failed**. The script translates that for you.

---

## After the copy {#after}

1. Open a few files from each folder on the new PC to spot-check.
2. Reinstall programs (`winget import -i apps.json`, then anything winget missed).
3. Re-sign in to browsers to bring back bookmarks and passwords (Edge, Chrome and Firefox all sync through their accounts).
4. Keep the old PC, or the USB copy, untouched for a couple of weeks before wiping it.
