---
layout: post
title: Rename Your Windows User Profile Directory
date: 2025-10-29
tags: [Windows, PowerShell, Profile, Rename, Script]
---

Renaming the default Windows user profile folder (e.g., `C:\Users\John` → `C:\Users\JohnDoe`) requires care. This guide provides **step-by-step instructions** and a **PowerShell script** that automates the registry update and folder rename safely.

---

## 🧭 Overview

Windows ties each user account to a unique SID and folder path under `C:\Users`. Simply renaming that folder breaks logins and causes OneDrive and app failures.  
This guide explains how to:

1. Detect whether you’re logged into the profile being changed  
2. Create a temporary local admin helper account if needed  
3. Rename the profile folder safely  
4. Update the registry and fix permissions automatically  

---

## ⚙️ Download the Script

You can get the PowerShell script directly here:

➡️ [**Download Rename-UserProfile.ps1**](https://github.com/pspowell/pspowell.github.io/blob/main/assets/images/Rename-UserProfile.ps1)

*(Right-click → “Save link as…” if your browser shows the code instead of downloading it.)*

---

## 🪟 How to Use

### 1. Run as Administrator

Open **Windows Terminal (Admin)** or **PowerShell (Admin)**, then run:

```powershell
powershell -ExecutionPolicy Bypass -File "$HOME\Downloads\Rename-UserProfile.ps1"
```

### 2. Enter Names

When prompted:

- **Current name:** the existing folder under `C:\Users`
- **New name:** your desired folder name

### 3. If You’re in the Profile to Be Renamed

If the script detects you’re logged into that profile, it will offer to:

- Create a helper admin (e.g., `Admin-Rename-Helper`)
- Copy the script to `C:\Users\Public`
- Instruct you to log out and run it from that new admin account

### 4. Complete the Rename

Once run from another admin:

1. The script updates the registry (`ProfileImagePath`)
2. Renames the folder
3. Repairs file ownership and ACL permissions

You’ll see messages confirming each step.

---

## 🔁 After the Rename

1. **Reboot** the PC.  
2. **Sign into your renamed account** and verify the folder path:
   ```powershell
   echo $env:USERPROFILE
   ```
   Should show: `C:\Users\NewName`

3. **Re-link OneDrive** (if used):  
   Open OneDrive → Settings → Account → *Unlink this PC* → Sign in again.

---

## 🧯 Rollback (If Needed)

If anything seems off:

1. Log in to another admin account.  
2. Rename the folder back to its original name.  
3. In Registry Editor, restore the original path under:

```
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\<UserSID>
  ProfileImagePath = C:\Users\OldName
```

---

## ✅ Tips

- Always **create a restore point** before renaming.  
- Ensure the target account is **signed out**.  
- **Do not** rename profiles for system or service accounts.  
- This method works for both **local** and **Microsoft** accounts.

---

**Author:** Preston Powell  
**Script Source:** [Rename-UserProfile.ps1 on GitHub](https://github.com/pspowell/pspowell.github.io/blob/main/assets/images/Rename-UserProfile.ps1)
