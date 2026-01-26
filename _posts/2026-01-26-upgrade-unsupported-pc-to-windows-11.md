---
layout: post
title: "Upgrade an Unsupported PC to Windows 11 (In‑Place Upgrade Guide)"
date: 2026-01-26 00:00:00 -0500
tags: [windows, windows-11, windows-10, upgrade, troubleshooting]
---

> **Important note about support:** Microsoft does **not** recommend installing Windows 11 on devices that don’t meet minimum system requirements, and notes that such devices may be **unsupported** and **not guaranteed to receive updates (including security updates)**. If you already installed Windows 11 on ineligible hardware, Microsoft recommends rolling back to Windows 10. citeturn3view0

## Overview {#overview}

This post summarizes one practical, ISO-based **in-place upgrade** approach (keep apps + files) for moving from **Windows 10 22H2** to **Windows 11 25H2** on hardware that fails Windows 11 checks (TPM/CPU/UEFI). The workflow follows Windows OS Hub’s guide and uses Microsoft’s documented registry switch where applicable. citeturn1view0turn2view0

## Before you start {#before-you-start}

### 1) Make a full backup {#make-a-full-backup}

An in-place upgrade is usually safe, but you’re intentionally bypassing compatibility gates. Do at least one of these first:

- Image backup (recommended)
- File backup to external drive/cloud
- Confirm you can boot recovery media and have your BitLocker recovery key (if applicable)

### 2) Confirm Windows 10 is on 22H2 {#confirm-windows-10-22h2}

1. Press `Win + R`
2. Run:

```text
winver
```

Windows OS Hub specifically calls out confirming you’re on Windows 10 **22H2** before upgrading. citeturn1view0

### 3) Download the official Windows 11 ISO {#download-windows-11-iso}

Get the Windows 11 ISO (or create it via the Media Creation Tool) from Microsoft’s Windows 11 download page. citeturn1view0

## Mount the ISO and run Setup {#mount-iso-and-run-setup}

1. Double-click the Windows 11 ISO to **mount** it (it appears as a virtual DVD drive, often `D:`). citeturn1view0
2. From the mounted drive, run:

```text
setup.exe
```

If the PC is unsupported, Windows Setup will typically stop with a “doesn’t meet Windows 11 system requirements” message. citeturn1view0

## Optional: Run a compatibility scan only {#compat-scan-only}

To run setup’s compatibility scan without upgrading, open an elevated Command Prompt, switch to the mounted ISO drive (example `D:`), and run:

```text
cd /d D:.\setup.exe /auto upgrade /noreboot /DynamicUpdate disable /Compat ScanOnly
```

Windows OS Hub describes this as a “compatibility check without performing an upgrade.” citeturn1view0

## Bypass checks (two paths) {#bypass-checks}

### Path A: Microsoft-documented registry switch (still needs TPM 1.2) {#path-a-microsoft-registry}

Microsoft documents a registry value that allows skipping **TPM 2.0** and **CPU** checks during upgrade: `AllowUpgradesWithUnsupportedTPMOrCPU`. citeturn1view0turn2view0

Run in an elevated Command Prompt:

```bat
reg add HKLM\SYSTEM\Setup\MoSetup /f /v AllowUpgradesWithUnsupportedTPMorCPU /d 1 /t reg_dword
```

**Important:** Windows OS Hub notes this still requires **TPM 1.2** (it won’t help if TPM is missing entirely). citeturn1view0

To check TPM status with PowerShell:

```powershell
Get-TPM
```

Windows OS Hub calls out checking for `TpmPresent`. citeturn1view0

### Path B: “No TPM present” workaround (unofficial) {#path-b-no-tpm-workaround}

If `Get-TPM` indicates the TPM is missing, Windows OS Hub provides a registry-based workaround intended to make Setup believe the device passed requirements. Microsoft explicitly does **not** officially support this method. citeturn1view0turn3view0

Run these commands in an **elevated** Command Prompt:

```bat
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\CompatMarkers" /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Shared" /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\TargetVersionUpgradeExperienceIndicators" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\HwReqChk" /v "HwReqChkVars" /t REG_MULTI_SZ /s "," /d "SQ_SecureBootCapable=TRUE,SQ_SecureBootEnabled=TRUE,SQ_TpmVersion=2,SQ_RamMB=8192" /f
reg add "HKLM\SYSTEM\Setup\MoSetup" /v "AllowUpgradesWithUnsupportedTPMOrCPU" /t REG_DWORD /d 1 /f
```

Windows OS Hub explains:
- the first three `reg delete` lines clear prior compatibility markers
- the `HwReqChkVars` entry is used to “seem like the computer passed” the checks citeturn1view0

## Run the upgrade (keep apps + files) {#run-the-upgrade}

After applying **Path A** or **Path B**, run `setup.exe` again from the mounted ISO and choose:

- **Keep personal files and apps** (in-place upgrade) citeturn1view0

## Alternative bypass: setup.exe /product server {#product-server}

Windows OS Hub also lists a method that starts Setup in a mode that bypasses CPU/TPM checks by specifying a “Server” product argument. citeturn1view0

From the mounted ISO drive (example `D:`):

```text
.\setup.exe /product server
```

They note that even though you invoke Setup with a “Server” argument, the installed edition remains your desktop Windows edition after the upgrade. citeturn1view0

## After the upgrade: verify version/build {#verify-version-build}

Windows OS Hub suggests confirming the resulting Windows 11 version/build via the registry:

```powershell
Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' |
  Select-Object ProductName, DisplayVersion, CurrentBuild
```

citeturn1view0

## Optional: a silent upgrade command line {#silent-upgrade}

Windows OS Hub includes an example for a quieter, scripted in-place upgrade:

```bat
start /wait d:\setup.exe /Auto Upgrade /Quiet /DynamicUpdate disable /showoobe None /Telemetry Disable /compat IgnoreWarning /NoReboot
```

citeturn1view0

## Optional: disable “Safeguard holds” blocks {#disable-safeguard-holds}

If feature upgrades are being blocked, Windows OS Hub mentions disabling “Safeguard Holds” via registry:

```bat
reg add HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate /f /v DisableWUfBSafeguards /d 1 /t reg_dword
```

They also map this to the Group Policy setting **Disable safeguards for Feature Updates** under Windows Update policies. citeturn1view0

## Risks and rollback plan {#risks-and-rollback-plan}

- Unsupported devices may be **unsupported by Microsoft** and **not guaranteed to receive updates**, including security updates. citeturn3view0
- Microsoft states unsupported installs can show a desktop watermark and recommends going back to Windows 10 if issues occur; the “Go back” option is only available for **10 days** after upgrading (after which rollback files are removed). citeturn3view0

## Sources {#sources}

- Windows OS Hub: “Upgrading to Windows 11 on Unsupported Hardware” (Oct 31, 2025). citeturn1view0
- Microsoft Support: “Ways to install Windows 11” (updated Feb 4, 2025). citeturn2view0
- Microsoft Support: “Windows 11 on devices that don't meet minimum system requirements” (updated Dec 12, 2024). citeturn3view0
