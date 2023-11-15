---
layout: post
title:  "Install Windows 11 on Unsupported PC (no TPM or Secure Boot)"
date:   2023-11-14 
categories: software
---
## Install Windows 11 on Unsupported PC (no TPM or Secure Boot)

I'm currently running Windows 11 on a 2016 era PC, with satisfactory results.  Here is my recommendation and process to install Windows 11 on a PC which doesn't have TPM installed.

> NOTE:  TPM is a hardware security feature that was not utilized on windows 10.  Windows 11 default install fails if the hardware feature is not available, but bypassing the TPM requirement does not make the system less secure than Windows 10

### Minimum Hardware

- 8Gb Ram
- x64 dual-core processor or better
- 256Gb SSD drive or better recommended

### Process

1. Download [windows installation media](https://www.microsoft.com/en-us/software-download/windows11/) ISO
2. Download [Rufus-4.3p.exe](https://github.com/pbatard/rufus/releases/download/v4.3/rufus-4.3p.exe)
3. Refer to web article [*Install Windows 11 23H2 on Unsupported PC (no TPM or Secure Boot)*](https://itstechbased.com/install-windows-11-23h2-on-unsupported-pc-no-tpm-or-secure-boot/), and follow the _**Bootable USB**_ method in part 2.
4. When window is installed, I recommend you google "Debloat Windows 11" to review options to eliminate unneeded software that slows down the system. Make a backup first!  One more advanced option is [debloat](https://github.com/LeDragoX/Win-Debloat-Tools). 