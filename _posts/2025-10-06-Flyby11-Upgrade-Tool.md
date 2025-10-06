---
layout: post
title: "Flyby11 – Upgrade Unsupported PCs to Windows 11"
date: 2025-10-06
tags: [Windows 11, Flyby11, Flyoobe, Upgrade Tools, System Utilities]
---

## What is Flyby11?

**Flyby11** is an open-source tool designed to let you upgrade a Windows 10 (or older) system to Windows 11 — even if your hardware doesn’t meet Microsoft’s official requirements.  
It bypasses checks for **TPM**, **Secure Boot**, and certain unsupported **CPUs**, making it possible to install Windows 11 on otherwise blocked devices.

The project is maintained by **Builtbybel** on GitHub:  
➡️ [https://github.com/builtbybel/Flyby11](https://github.com/builtbybel/Flyby11)

Flyby11 has since evolved into a broader tool called **Flyoobe**, which includes Flyby11’s bypass logic plus post-install features like OOBE customization, debloating, and personalization:  
➡️ [https://github.com/builtbybel/Flyoobe](https://github.com/builtbybel/Flyoobe)

> ⚠️ Note: Some newer Windows 11 versions (like 24H2) include hardware checks that can’t always be bypassed, such as the POPCNT instruction requirement.

---

## How to Get Flyby11 (or Flyoobe)

### 1. Download from GitHub
The official builds are published on GitHub:

- **Flyby11 Classic:**  
  [https://github.com/builtbybel/Flyby11/releases](https://github.com/builtbybel/Flyby11/releases)

- **Flyoobe (Next Generation):**  
  [https://github.com/builtbybel/Flyoobe/releases](https://github.com/builtbybel/Flyoobe/releases)

### 2. Choose the Right Version
- *Classic Flyby11* → Focused on performing the in-place upgrade bypass.  
- *Flyoobe Toolkit* → Includes Flyby11 plus additional tools for customizing the Out-Of-Box-Experience and system cleanup.

### 3. Verify and Whitelist
Verify the download source and checksum.  
Windows Defender may flag it as a “hack tool” or “PUA” (Potentially Unwanted App). If so, review your **Protection History** and allow the file manually.

---

## How to Use Flyby11 / Flyoobe

### Before You Begin
- Back up your data or create a full system image.  
- Ensure you have at least 20–40 GB of free disk space.  
- Keep your current Windows up-to-date for the smoothest upgrade.  
- Expect some trial-and-error on older hardware.

---

### Step-by-Step Upgrade

1. **Run the executable**  
   Launch `Flyby11.exe` or `Flyoobe.exe`. The tool will detect your OS and system configuration.

2. **Select or provide a Windows 11 ISO**  
   - Drag and drop an ISO file into the window.  
   - Or let the app download a current ISO via built-in Media Creation Tool or Fido script.

3. **Patch the installer**  
   The app applies internal registry and setup modifications to skip TPM, Secure Boot, and CPU checks.

4. **Start the upgrade**  
   Flyby11 launches the Windows Setup process.  
   Choose “Keep files and apps” if you want an in-place upgrade.  
   The setup uses a patched “Server setup” variant to skip hardware validation.

5. **Let installation complete**  
   The system will reboot several times.  
   After finishing, you’ll boot into Windows 11 with your files and apps intact.

---

## After the Upgrade

- **Driver check:** Update or install missing drivers via Device Manager.  
- **Windows Update:** You might need to fetch updates manually using the [Microsoft Update Catalog](https://www.catalog.update.microsoft.com).  
- **Disk cleanup:** Optionally remove `Windows.old` to reclaim space.  
- **Flyoobe features:** Use Flyoobe for further personalization and post-setup cleanup.

---

## Example Results

Users have reported success upgrading older PCs — even those with 3rd- or 4th-gen Intel CPUs — using Flyby11.  
One Reddit user noted:

> “I found this app called Flyby11, which lets you dodge Windows 11 system requirements … upgrade your PC to Windows 11.”

Community discussions:  
- [MSFN Forum Thread](https://msfn.org/board/topic/186517-flyby-11-upgrade-to-windows-11-on-unsupported-pcs/)  
- [HardForum Post](https://hardforum.com/threads/flyby11-is-actually-pretty-nice-to-upgrade-an-unsupported-machine-to-win11.2041888/)  
- [MiniTool Walkthrough](https://www.minitool.com/news/bypass-windows-11-system-requirements-with-flyby11.html)

---

## Risks and Warnings

- This is **not officially supported** by Microsoft.  
- Future Windows releases may render bypasses ineffective.  
- Some security or feature updates may be withheld.  
- Your antivirus may quarantine the executable.  
- Proceed only if you understand and accept the risks.

---

## Summary

**Flyby11** is a streamlined way to upgrade an unsupported PC to Windows 11 by bypassing TPM, Secure Boot, and CPU checks.  
Its successor, **Flyoobe**, integrates Flyby11’s logic into a more flexible setup-and-customization toolkit.

**In short:**  
1. Download from GitHub.  
2. Run the app and supply a Windows 11 ISO.  
3. Let it patch and start the upgrade.  
4. Reboot and enjoy Windows 11 — unsupported hardware and all.

---

*References:*  
- [Flyby11 on GitHub](https://github.com/builtbybel/Flyby11)  
- [Flyoobe on GitHub](https://github.com/builtbybel/Flyoobe)  
- [MiniTool Article](https://www.minitool.com/news/bypass-windows-11-system-requirements-with-flyby11.html)  
- [Ghacks.net Coverage](https://www.ghacks.net/2025/07/17/windows-10-to-11-upgrader-flyby11-gets-a-convenient-option-for-downloading-the-windows-11-iso/)
