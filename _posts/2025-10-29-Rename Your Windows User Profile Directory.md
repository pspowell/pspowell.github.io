---

layout: post

title: Rename Your Windows User Profile Directory

date: 2025-10-29

tags: \[Windows, PowerShell, Profile, Rename, Script]

---



Renaming the default Windows user profile folder (e.g., `C:\\Users\\John` → `C:\\Users\\JohnDoe`) requires care. This guide provides \*\*step-by-step instructions\*\* and a \*\*PowerShell script\*\* that automates the registry update and folder rename safely.



---



\## 🧭 Overview



Windows ties each user account to a unique SID and folder path under `C:\\Users`. Simply renaming that folder breaks logins and causes OneDrive and app failures.  

This guide explains how to:



1\. Detect whether you’re logged into the profile being changed  

2\. Create a temporary local admin helper account if needed  

3\. Rename the profile folder safely  

4\. Update the registry and fix permissions automatically  



---



\## ⚙️ Download the Script



You can get the PowerShell script directly here:



➡️ \[\*\*Download Rename-UserProfile.ps1\*\*](https://github.com/pspowell/pspowell.github.io/blob/main/assets/images/Rename-UserProfile.ps1)



\*(Right-click → “Save link as…” if your browser shows the code instead of downloading it.)\*



---



\## 🪟 How to Use



\### 1. Run as Administrator



Open \*\*Windows Terminal (Admin)\*\* or \*\*PowerShell (Admin)\*\*, then run:



```powershell

powershell -ExecutionPolicy Bypass -File "$HOME\\Downloads\\Rename-UserProfile.ps1"



