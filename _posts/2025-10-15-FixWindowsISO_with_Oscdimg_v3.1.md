---
layout: page
title: "Fix Windows ISO Script (v3.1)"
description: "Automated PowerShell tool for rebuilding Windows ISOs with TPM check removed and oscdimg integration."
permalink: /fix-windows-iso/
---

# 🧰 FixWindowsISO_with_Oscdimg_v3.1.ps1

## Overview
`FixWindowsISO_with_Oscdimg_v3.1.ps1` automates the process of rebuilding a Windows installation ISO to **bypass TPM and Secure Boot checks**, while ensuring that **`oscdimg.exe`** is automatically installed, copied into the system, and safely cleaned up afterward.

It performs the following tasks:

1. Ensures administrative privileges.  
2. Locates or installs Microsoft’s **OSCDIMG** utility (from the ADK Deployment Tools).  
3. Automatically copies `oscdimg.exe` into `C:\Windows\System32`.  
4. **Uninstalls the ADK immediately after extracting** (Option A cleanup).  
5. Prompts for or accepts an existing Windows ISO.  
6. Mounts and copies ISO contents to a working directory.  
7. Removes the TPM enforcement component (`sources\appraiserres.dll`).  
8. Rebuilds the ISO with proper boot sectors for BIOS/UEFI.  
9. Cleans up all temporary files and logs build attempts.

---

## ⚙️ Key Features

| Feature | Description |
|----------|-------------|
| **Automatic Elevation** | Script re-launches itself with Administrator privileges if needed. |
| **Winget-Based ADK Install** | Uses Winget to install `Microsoft.WindowsADK` and optionally `Microsoft.WindowsADK.PEAddon`. |
| **Automatic Cleanup** | Removes ADK tools right after copying `oscdimg.exe`. |
| **TPM Bypass** | Deletes `appraiserres.dll` from the ISO source tree. |
| **Smart Boot Strategy** | Automatically selects BIOS/UEFI boot images found in the ISO (`etfsboot.com`, `efisys.bin`, etc.). |
| **Robust Logging** | Each `oscdimg` build attempt logs stdout/stderr to `%TEMP%\Oscdimg-Logs-<GUID>`. |
| **Failsafe Cleanup** | Always removes temporary work directories, even after errors. |

---

## 🪟 Requirements

- **Windows 10/11** (x64 recommended)
- **PowerShell 5.1 or higher**  
- **Administrator rights**
- Optional: Internet access for Winget-based ADK install

---

## 🧩 Script Flow Summary

### 1. `Assert-Admin`
Ensures the script is running elevated. If not, it relaunches itself as Administrator.

### 2. `Ensure-Oscdimg`
- Searches for `oscdimg.exe` in PATH, System32, and known ADK locations.  
- If not found:
  - Installs the Windows ADK via `winget install -e --id Microsoft.WindowsADK`.  
  - Copies `oscdimg.exe` to System32.  
  - Immediately uninstalls the ADK via `winget uninstall`.  
- Fallback: instructs the user to install ADK manually.

### 3. `Select-IsoIfNeeded`
Prompts the user with a file dialog to select a `.iso` if not provided as a parameter.

### 4. `Expand-Iso`
Mounts the ISO, copies its contents via `robocopy`, and dismounts it.

### 5. `Remove-AppraiserRes`
Deletes `sources\appraiserres.dll` (the TPM enforcement file).

### 6. `Build-Iso`
Rebuilds the ISO using `oscdimg.exe` with multiple strategies and logs all attempts.

### 7. `Cleanup`
Removes temporary directories and retains logs for review.

---

## 🧾 Usage

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\FixWindowsISO_with_Oscdimg_v3.1.ps1
```

With parameters:

```powershell
.\FixWindowsISO_with_Oscdimg_v3.1.ps1 -IsoPath "C:\ISOs\Win11_25H2_English_x64.iso" -OutputIsoPath "C:\ISOs\Win11_NoTPM.iso"
```

---

## 📁 Outputs

| Path | Description |
|------|--------------|
| `%TEMP%\WinISO-Fix-<GUID>` | Temporary expanded ISO contents. |
| `%TEMP%\Oscdimg-Logs-<GUID>` | All oscdimg logs. |
| `<OriginalDir>\Win11_XXXX_NoTPM.iso` | The rebuilt ISO. |

---

## ⚠️ Common Issues

| Error | Cause | Solution |
|-------|--------|-----------|
| `Access is denied` | ISO output file in use | Close any ISO viewers or Explorer windows. |
| `Could not open boot sector file etfsboot.com` | Missing BIOS boot file | Build will fall back to UEFI-only. |
| `oscdimg.exe not available` | ADK install failed | Run manually: `winget install -e --id Microsoft.WindowsADK`. |
| `Mount-DiskImage` fails | ISO already mounted | Dismount manually, then retry. |

---

## 🧠 Design Notes

- **Winget-first install** ensures correct platform version.  
- **No bootstrapper downloads** — avoids platform mismatch errors.  
- **Silent uninstall** keeps the system clean.  
- Works on **PowerShell 5.1 and 7.x**.

---

## 🧩 Licensing

Includes `oscdimg.exe` (© Microsoft) from the Windows ADK, used under its redistribution terms.

---

## 🪙 Author

**Script + Documentation:** Adapted with ChatGPT GPT‑5 for **Preston S. Powell**, October 2025.
