---
layout: post
title: "How to Install and Use Link Shell Extension on Windows"
date: 2025-11-19
tags: [windows, filesystems, symlinks, tools]
---

# Link Shell Extension (LSE): Installation & Usage Guide

**Link Shell Extension** (LSE) is a Windows shell add-on that makes it easy to create symbolic links, hard links, junction points, and directory symbolic links using right-click menus.  
This tool is extremely handy for developers, power users, and anyone managing files across drives.

---

## ✓ What Link Shell Extension Can Do

LSE allows you to create:

- **Hard Links** – File-level links on the same NTFS volume  
- **Symbolic Links (Symlinks)** – File or folder redirects (NTFS, works across volumes)  
- **Junctions** – Directory-only links  
- **Smart Copies / Smart Mirror** – Copies that maintain NTFS hard links  
- **Clone / Move** links  
- **Splice / Drop commands** via context menus  

---

# 1. Installing Link Shell Extension

### Step 1 — Download LSE
Download the latest version from the official site:

**https://schinagl.priv.at/nt/hardlinkshellext/hardlinkshellext.html**

Look for the installer that matches your system:

- **LSE x64** (most common)
- **LSE ARM64** (Surface / ARM devices)
- **LSE x86** (rare)

### Step 2 — Install the Prerequisite: VC++ Runtime
LSE requires the **Microsoft Visual C++ Runtime**.  
The installer will prompt you if it’s missing.

If needed, download from Microsoft:

