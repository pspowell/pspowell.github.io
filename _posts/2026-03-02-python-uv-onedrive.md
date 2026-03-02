---
layout: post
title: "Python + uv + OneDrive: full install & setup (Windows 11)"
date: 2026-03-02 00:00:00 -0500
tags: [python, uv, onedrive, windows, dev-environment]
---

## Goals {#goals}

You want:

- Your **project files** (code, `pyproject.toml`, docs) in **OneDrive** for sync/backup.
- Your **virtual environment** and **caches** *outside* OneDrive (to avoid sync thrash, file-locking, long paths, and “sync pending” headaches).
- A repeatable workflow where `uv` manages Python versions and dependencies.

This guide assumes **Windows 11 + PowerShell**.

---

## Recommended folder layout {#recommended-folder-layout}

Keep the *project* in OneDrive, but keep the *venv + caches* in a local, non-synced location.

Example:

- **Project (synced):**
  - `C:\Users\<you>\OneDrive\Projects\myapp\`
- **Virtualenv root (NOT synced):**
  - `C:\Dev\venvs\`
- **uv cache (NOT synced):**
  - `C:\Dev\uv-cache\`
- **uv managed Python installs (NOT synced):**
  - `C:\Dev\uv-python\`

Why this matters:

- OneDrive has filename/path rules and can choke on certain temporary / tool-generated files, invalid characters, or excessive path lengths. It also explicitly warns that it does not support syncing via symbolic links or junction points.  
  (See Microsoft’s OneDrive restrictions doc.)

---

## Step 1 — Install uv {#step-1-install-uv}

### Option A: Install uv with WinGet (recommended) {#option-a-install-uv-with-winget}

In PowerShell:

```powershell
winget install --id=astral-sh.uv -e
```

### Option B: Install uv with Astral’s PowerShell installer {#option-b-install-uv-with-astrals-powershell-installer}

```powershell
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

Verify:

```powershell
uv --version
uvx --version
```

---

## Step 2 — Choose how Python will be installed {#step-2-choose-python}

You have two sane paths:

### Path A (simple): Let uv manage Python {#path-a-uv-managed-python}

uv can automatically download and use Python as needed, and you can also explicitly install versions.

Create a directory for uv-managed Pythons (optional but recommended):

```powershell
New-Item -ItemType Directory -Force C:\Dev\uv-python | Out-Null
```

Then install the version(s) you want:

```powershell
uv python install 3.12
uv python install 3.11
uv python list
```

> Note: uv can also auto-download Python versions when needed, but explicitly installing keeps things predictable.

### Path B: Use an existing Python install {#path-b-system-python}

If you already have Python installed, uv will usually discover and use it automatically. You can also force “no managed python” behavior per command (see uv docs).

---

## Step 3 — Set uv paths so OneDrive doesn’t touch venv/caches {#step-3-set-uv-paths}

You want *global* defaults that keep heavy churn off OneDrive.

### 3.1 Create the directories {#create-dirs}

```powershell
New-Item -ItemType Directory -Force C:\Dev\venvs | Out-Null
New-Item -ItemType Directory -Force C:\Dev\uv-cache | Out-Null
New-Item -ItemType Directory -Force C:\Dev\uv-python | Out-Null
```

### 3.2 Set environment variables (User scope) {#set-env-vars-user}

Run once in PowerShell:

```powershell
[Environment]::SetEnvironmentVariable("UV_CACHE_DIR",         "C:\Dev\uv-cache",  "User")
[Environment]::SetEnvironmentVariable("UV_PYTHON_INSTALL_DIR", "C:\Dev\uv-python", "User")
```

Now **restart PowerShell** so it picks up the new variables.

> `UV_CACHE_DIR` is the big one for OneDrive sanity: it stops uv from sprinkling caches around synced folders.

---

## Step 4 — Create a OneDrive project and bind it to an external venv {#step-4-create-project}

Assume your OneDrive project folder is:

`C:\Users\<you>\OneDrive\Projects\myapp`

### 4.1 Create/init the project {#init-project}

```powershell
cd "C:\Users\<you>\OneDrive\Projects\myapp"
uv init
```

This generates (at minimum) a `pyproject.toml`.

### 4.2 Put the venv outside OneDrive {#external-venv}

uv projects default to `.venv` inside the project. That’s exactly what we *don’t* want.

Instead, set `UV_PROJECT_ENVIRONMENT` **for this project** to an absolute path outside OneDrive, e.g.:

`C:\Dev\venvs\myapp`

**One-time per project, in your PowerShell session:**
```powershell
$env:UV_PROJECT_ENVIRONMENT = "C:\Dev\venvs\myapp"
```

Now create the environment and sync deps:

```powershell
uv venv
uv sync
```

What this does:
- `uv venv` creates the environment at `C:\Dev\venvs\myapp`.
- `uv sync` installs whatever your `pyproject.toml` (and lockfile, if present) declares.

> Tip: If you want this binding to be “automatic” every time you open the project, add the environment variable to a per-project PowerShell helper script (example below).

---

## Step 5 — Daily workflow {#step-5-daily-workflow}

From the OneDrive project directory:

### Add a dependency {#add-dep}
```powershell
$env:UV_PROJECT_ENVIRONMENT="C:\Dev\venvs\myapp"
uv add requests
```

### Sync to exactly what’s declared {#sync}
```powershell
$env:UV_PROJECT_ENVIRONMENT="C:\Dev\venvs\myapp"
uv sync
```

### Run your app using the project environment {#run}
```powershell
$env:UV_PROJECT_ENVIRONMENT="C:\Dev\venvs\myapp"
uv run python -m myapp
```

### Activate the venv (optional) {#activate-optional}

If you want classic activation:

```powershell
C:\Dev\venvs\myapp\Scripts\Activate.ps1
python --version
```

(You can also stay “activation-free” and just use `uv run ...`.)

---

## Step 6 — Make it painless: add a per-project helper script {#step-6-helper-script}

Create a file in your project root (OneDrive), for example:

`tools\enter-dev.ps1`

Contents:

```powershell
# tools/enter-dev.ps1
$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot

$env:UV_PROJECT_ENVIRONMENT = "C:\Dev\venvs\myapp"
$env:UV_CACHE_DIR           = "C:\Dev\uv-cache"
$env:UV_PYTHON_INSTALL_DIR  = "C:\Dev\uv-python"

Write-Host "Project: $projectRoot"
Write-Host "UV_PROJECT_ENVIRONMENT=$env:UV_PROJECT_ENVIRONMENT"
Write-Host "Ready. Try: uv sync; uv run python -m myapp"
```

Then, whenever you open a new terminal:

```powershell
.\tools\enter-dev.ps1
```

---

## OneDrive-specific best practices {#onedrive-best-practices}

- **Keep `.venv/` out of OneDrive**. If you insist on `.venv`, mark it “Always keep on this device” and consider excluding it from sync… but realistically, external venv is the cleanest approach.
- **Avoid symlink/junction tricks** to “fake” an external venv inside OneDrive. Microsoft explicitly warns OneDrive doesn’t support syncing using symbolic links or junction points.
- **Watch your paths**: deep folder nesting in OneDrive + long package paths can exceed Windows/OneDrive path expectations.
- **Avoid invalid filename characters** in generated artifacts inside OneDrive (some tools create weird temporary names). Microsoft documents disallowed characters like `* : < > ? / \ |` and other rules.

---

## Troubleshooting checklist {#troubleshooting}

### “uv created .venv anyway” {#uv-created-dotvenv-anyway}
- Confirm `UV_PROJECT_ENVIRONMENT` is set in the same shell **before** running `uv venv` / `uv sync`.
- Print it:
  ```powershell
  echo $env:UV_PROJECT_ENVIRONMENT
  ```

### OneDrive shows “Sync pending” constantly {#sync-pending}
- Move venv/caches out of OneDrive (this guide’s layout).
- Ensure the project folder isn’t full of transient build artifacts.

### I want multiple projects to share one venv {#share-venv}
Don’t. `uv sync` is designed to converge an environment to exactly what a project declares, and sharing one env across projects becomes fragile.

---

## References {#references}

- uv installation methods (WinGet, installer)  
- uv-managed Python installs (`uv python install`, discovery behavior)  
- `UV_PROJECT_ENVIRONMENT` behavior and what it does  
- Microsoft OneDrive restrictions and limitations (invalid characters, symlink/junction limitations)
