---
layout: post
title: "Installing Windows 11 on Unsupported Hardware (TPM 2.0 / CPU Bypass)"
date: 2026-10-02
tags: [windows-11, tpm, bypass, registry, rufus, upgrade, how-to]
---

When Windows 11 Setup reports **"This PC doesn't currently meet Windows 11 system requirements"**, the usual causes are:

- The PC must support TPM 2.0.
- The processor isn't supported for this version of Windows.

The four methods below get around those checks. Choose based on whether you want to **keep your files and apps** (in-place upgrade) or **start fresh** (clean install).

## Quick Comparison

| Method | Type | Needs TPM 1.2? | Tools Needed |
|---|---|---|---|
| 1. MoSetup registry key | In-place upgrade | Yes | Windows 11 ISO |
| 2. `setupprep.exe /product server` | In-place upgrade | No | Windows 11 ISO |
| 3. Rufus USB | Clean install or upgrade | No | Rufus + ISO + USB drive |
| 4. LabConfig registry keys | Clean install | No | Windows 11 USB |

## Method 1 — Registry Key (Microsoft's Own Workaround)

Save the following as `AllowUnsupportedUpgrade.reg`:

```
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SYSTEM\Setup\MoSetup]
"AllowUpgradesWithUnsupportedTPMOrCPU"=dword:00000001
```

Steps:

1. Double-click the `.reg` file and accept the prompts.
2. Reboot.
3. Mount the Windows 11 ISO and run `setup.exe` from it.

**Notes:**

- The Windows 11 Installation Assistant ignores this key. You must run `setup.exe` from the ISO.
- This method still needs **at least TPM 1.2**. With no TPM at all, use Method 2 or 3.

## Method 2 — "Server" Setup Trick (No TPM Required)

1. Mount the Windows 11 ISO.
2. Open a Command Prompt as Administrator.
3. Run the following, replacing `D:` with your mounted drive letter:

```
D:\sources\setupprep.exe /product server
```

Setup will say "Windows Server", but it installs normal Windows 11 and skips the hardware checks. Your files and apps are kept.

## Method 3 — Rufus USB (Easiest)

1. Download Rufus from [rufus.ie](https://rufus.ie).
2. Select the Windows 11 ISO and write it to a USB drive.
3. When prompted, check **"Remove requirement for 4GB+ RAM, Secure Boot and TPM 2.0."**
4. Then do one of the following:
   - **Clean install:** boot from the USB.
   - **Upgrade:** run `setup.exe` from the USB while in Windows.

## Method 4 — Clean-Install Registry Bypass (No Rufus)

1. Boot from a standard Windows 11 USB.
2. At the first setup screen, press **Shift+F10** to open a command prompt.
3. Run `regedit`.
4. Go to `HKEY_LOCAL_MACHINE\SYSTEM\Setup` and create a new key named `LabConfig`.
5. Inside `LabConfig`, create these DWORD (32-bit) values, each set to `1`:
   - `BypassTPMCheck`
   - `BypassSecureBootCheck`
   - `BypassCPUCheck`
6. Close regedit and the command prompt, then continue setup.

## Hard Limit: CPU Instruction Support

Windows 11 **24H2 and later** need a CPU that supports **SSE4.2 and POPCNT**. That covers roughly:

- Intel Core 2nd gen (Sandy Bridge) and newer
- AMD processors from about 2011 onward

On older CPUs, **none of these bypasses work**. Windows 11 will either refuse to install or fail to boot.

## Downsides of Running Unsupported

- **Updates:** Microsoft doesn't guarantee updates on unsupported hardware. In practice monthly updates have kept arriving, but each annual feature update usually means repeating the bypass.
- **Watermark:** Settings may show a "System requirements not met" notice. It's cosmetic and doesn't affect anything.
- **Backups:** Back up first, especially before an in-place upgrade.
