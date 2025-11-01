---
layout: post
title: "PowerShell + VS Code Starter Repos with Git, Debug, and Linting"
date: 2025-11-01
tags: [PowerShell, VSCode, Git, Pester, ScriptAnalyzer]
---

## Overview

Here are two **ready-to-clone PowerShell development starters** for Windows 11 and VS Code.  
Both include Git integration, PSScriptAnalyzer, Pester, and pre-wired debugging configurations.

| Type | Download | Description |
|------|-----------|-------------|
| **Module Scaffold** | [PowerShellModuleStarter-PrestonPowell.zip](/assets/PowerShellModuleStarter-PrestonPowell.zip) | Full PowerShell module structure with manifest (`.psd1`, `.psm1`), `public/` and `private/` folders, and tests. |
| **Scripts-Only Scaffold** | [PowerShellScriptsStarter-PrestonPowell.zip](/assets/PowerShellScriptsStarter-PrestonPowell.zip) | Lightweight script workspace — no module manifest, perfect for utilities and admin scripts. |

---

## ⚙️ VS Code + PowerShell Setup

### Install the essentials
```powershell
# PowerShell 7
winget install --id Microsoft.Powershell --source winget

# Git for Windows
winget install --id Git.Git --source winget

# VS Code
winget install --id Microsoft.VisualStudioCode --source winget
```

### Recommended VS Code extensions
- **PowerShell** (Microsoft) – language service, IntelliSense, debugger  
- **GitLens** – blame annotations, hovers, CodeLens, and repo history  
- **Pester Test Explorer** – test runner integration  
- *(Optional)* **Markdown All in One** and **EditorConfig**

---

## 🧠 Git Configuration
```bash
git config --global user.name  "Preston Powell"
git config --global user.email "you@example.com"
git config --global init.defaultBranch main
git config --global core.autocrlf true
```

Generate an SSH key for GitHub:
```bash
ssh-keygen -t ed25519 -C "you@example.com"
type $env:USERPROFILE\.ssh\id_ed25519.pub
```
Add the printed key under **GitHub → Settings → SSH and GPG keys**.

---

## 🧩 PowerShell Developer Modules
```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned -Force
Install-Module PSScriptAnalyzer -Scope CurrentUser -Force
Install-Module Pester -Scope CurrentUser -Force
Install-Module PSReadLine -Scope CurrentUser -Force
```

---

## 🧱 Project Structure (Module Version)

```
MyPowerShellProject/
├─ .vscode/
│  ├─ launch.json
│  └─ tasks.json
├─ src/
│  ├─ MyModule.psd1
│  ├─ MyModule.psm1
│  ├─ public/
│  │  └─ Get-Greeting.ps1
│  └─ private/
├─ tests/
│  └─ MyModule.Tests.ps1
├─ PSScriptAnalyzerSettings.psd1
├─ .editorconfig
├─ .gitattributes
├─ .gitignore
└─ README.md
```

Run tests:
```powershell
Invoke-Pester -Path tests -Output Detailed
```

---

## 🧭 In-Editor Intelligence

**Blame annotations (GitLens)**  
→ See who changed each line and when (`Ctrl+Shift+P → GitLens: Toggle Line Blame`).

**Hover tooltips**  
→ Hover a symbol for PowerShell docs, or a line for Git commit info.

**CodeLens**  
→ Inline annotations above functions showing references, tests, and authorship.

**Inline diff / history**  
→ `Alt+L` shows line history; `Alt+D` shows diff with previous revision.

---

## 🧰 Key VS Code Settings
```json
{
  "powershell.powerShellDefaultVersion": "PowerShell",
  "powershell.codeLens.enable": true,
  "powershell.scriptAnalysis.enable": true,
  "gitlens.currentLine.enabled": true,
  "gitlens.lineBlame.annotations.enabled": true,
  "editor.formatOnSave": true,
  "editor.renderLineHighlight": "gutter",
  "files.eol": "\r\n"
}
```

---

## 🚀 Quick Start

1. **Download** a ZIP from `/assets/` and extract it.
2. **Open in VS Code** (`code .`).  
3. Run:
   ```powershell
   pwsh -NoProfile -Command "Install-Module PSScriptAnalyzer,Pester -Scope CurrentUser -Force"
   ```
4. Run tests:
   ```powershell
   Invoke-Pester -Path tests -Output Detailed
   ```
5. Optionally initialize Git:
   ```powershell
   .\bootstrap.ps1 -UserName "Preston Powell" -UserEmail "you@example.com"
   ```

---

## 🪪 Signing Commits (Optional)

Generate a GPG key:
```powershell
gpg --full-generate-key
gpg --list-secret-keys --keyid-format LONG
git config --global user.signingkey <KEYID>
git config --global commit.gpgsign true
```
Export public key for GitHub:
```powershell
gpg --armor --export you@example.com
```

---

## ✅ Daily Workflow

| Task | Command | Shortcut |
|------|----------|-----------|
| Run current script | F5 | Debug start |
| Toggle blame | Ctrl + Shift + P → GitLens | |
| Run tests | Ctrl + Shift +B | |
| Format code | Ctrl + S (auto) or “Format task” | |
| Commit & push | Source Control panel | |

---

## 📦 Download Links

- [Module Starter ZIP](/assets/PowerShellModuleStarter-PrestonPowell.zip)  
- [Scripts-Only Starter ZIP](/assets/PowerShellScriptsStarter-PrestonPowell.zip)

---

*Created November 2025 by Preston Powell — a complete PowerShell + VS Code development foundation.*
