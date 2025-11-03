---
layout: post
title: "Toggle Windows Start Full-Screen Mode with PowerShell"
date: 2025-11-03
tags: [Windows, PowerShell, StartMenu, Explorer, Registry, Scripts]
---

If your Windows Start menu opens briefly and then closes—or you just want to switch between **full-screen** and **compact** Start layouts—you can use this PowerShell script to toggle the setting instantly.

---

## 🔧 What It Does

This script changes the registry value:

```
HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Start_ShowFullScreen
```

- `0` → Start menu **off** (normal mode)  
- `1` → Start menu **on** (full-screen mode)

After toggling, it optionally restarts **Explorer** so the change takes effect right away.

---

## 🧰 PowerShell Script

```powershell
# Toggle Start full-screen mode (Windows 10/11)
# Author: ChatGPT
# Date: 2025-11-03

$RegPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
$ValueName = "Start_ShowFullScreen"

try {
    # Read current value
    $current = Get-ItemProperty -Path $RegPath -Name $ValueName -ErrorAction Stop | Select-Object -ExpandProperty $ValueName
} catch {
    # Create key/value if missing
    if (-not (Test-Path $RegPath)) { New-Item -Path $RegPath -Force | Out-Null }
    New-ItemProperty -Path $RegPath -Name $ValueName -Value 0 -PropertyType DWord -Force | Out-Null
    $current = 0
}

# Toggle value: 1 = Full-screen ON, 0 = OFF
$new = if ($current -eq 1) { 0 } else { 1 }
Set-ItemProperty -Path $RegPath -Name $ValueName -Value $new

Write-Host "Start full-screen mode is now" -NoNewline
if ($new -eq 1) { Write-Host " ENABLED." -ForegroundColor Green } else { Write-Host " DISABLED." -ForegroundColor Yellow }

# Optionally restart Explorer to apply immediately
$response = Read-Host "Restart Explorer to apply now? (Y/N)"
if ($response -match '^[Yy]') {
    Stop-Process -Name explorer -Force
    Start-Process explorer.exe
}
```

---

## 💾 Download

You can download the ready-to-run PowerShell file here:

👉 [Toggle-Start-FullScreen.ps1](../assets/scripts/Toggle-Start-FullScreen.ps1)



---

## ⚙️ Usage

1. Right-click **Toggle-Start-FullScreen.ps1** → **Run with PowerShell**  
2. Approve the prompt to restart Explorer (optional).  
3. The console will display whether full-screen mode is now **enabled** or **disabled**.

---

## 🧩 Notes

- Works on Windows 10 and Windows 11.  
- Changes apply per-user (not system-wide).  
- Explorer restart or sign-out/in required for the change to appear.

---

© 2025 Preston Powell — released under MIT License.
