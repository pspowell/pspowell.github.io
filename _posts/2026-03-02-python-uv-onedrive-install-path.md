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
- `uv` to manage **Python installs** and **dependencies**, with installs landing in `C:\Dev\uv-python`.

This guide assumes **Windows 11 + PowerShell**.

---

## Recommended folder layout {#recommended-folder-layout}

Keep the *project* in OneDrive, but keep the *venv + caches + Python installs* in a local, non-synced location.

Example:

- **Project (synced):**
  - `C:\Users\<you>\OneDrive\Projects\myapp\`
- **Virtualenv root (NOT synced):**
  - `C:\Dev\venvs\`
- **uv cache (NOT synced):**
  - `C:\Dev\uv-cache\`
- **uv managed Python installs (NOT synced):**
  - `C:\Dev\uv-python\`

---

## Step 1 — Install uv {#step-1-install-uv}

### Option A: Install uv with WinGet {#option-a-install-uv-with-winget}

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

## Step 2 — Configure uv to install Python in C:\Dev\uv-python {#step-2-configure-uv-python-install-dir}

**Do this BEFORE running `uv python install ...`.**

### 2.1 Create the directories {#create-directories}

```powershell
New-Item -ItemType Directory -Force C:\Dev\uv-python | Out-Null
New-Item -ItemType Directory -Force C:\Dev\uv-cache  | Out-Null
New-Item -ItemType Directory -Force C:\Dev\venvs     | Out-Null
```

### 2.2 Set persistent env vars (User scope) {#set-persistent-env-vars}

```powershell
[Environment]::SetEnvironmentVariable("UV_PYTHON_INSTALL_DIR", "C:\Dev\uv-python", "User")
[Environment]::SetEnvironmentVariable("UV_CACHE_DIR",          "C:\Dev\uv-cache",  "User")
```

Then **close PowerShell and open a new window** so the variables are loaded.

### 2.3 Confirm they’re loaded {#confirm-env-vars}

```powershell
echo $env:UV_PYTHON_INSTALL_DIR
echo $env:UV_CACHE_DIR
```

You should see:

- `C:\Dev\uv-python`
- `C:\Dev\uv-cache`

> If you’re in the middle of a session and don’t want to restart, set session vars too:
>
> ```powershell
> $env:UV_PYTHON_INSTALL_DIR = "C:\Dev\uv-python"
> $env:UV_CACHE_DIR          = "C:\Dev\uv-cache"
> ```

---

## Step 3 — Install Python with uv (and verify the path) {#step-3-install-python-with-uv}

Install (example):

```powershell
uv python install 3.13
```

Verify it landed in `C:\Dev\uv-python`:

```powershell
uv python list
```

You should see a line with a path like:

- `C:\Dev\uv-python\cpython-3.13.12-windows-x86_64-none\python.exe`

---

## Step 4 — Update PATH so python shims work everywhere {#step-4-update-path}

uv often places “shim” executables (e.g., `python3.13.exe`) into:

- `C:\Users\<you>\.local\bin`

If that directory isn’t on PATH, uv will warn.

### 4.1 Add uv shims to PATH automatically {#update-shell}

Run once:

```powershell
uv python update-shell
```

Then **close PowerShell and open a new one**.

Verify:

```powershell
where python
where python3.13
python --version
python3.13 --version
```

### 4.2 If you get “Executable already exists … not managed by uv” {#force-replace-shim}

If `C:\Users\<you>\.local\bin\python3.13.exe` already exists and uv refuses to overwrite it, force replace:

```powershell
uv python install 3.13 --force
```

---

## Step 5 — OneDrive project with an external venv {#step-5-onedrive-project-external-venv}

Assume your OneDrive project folder is:

`C:\Users\<you>\OneDrive\Projects\myapp`

### 5.1 Init the project {#init-project}

```powershell
cd "C:\Users\<you>\OneDrive\Projects\myapp"
uv init
```

### 5.2 Put the venv outside OneDrive {#external-venv}

Set `UV_PROJECT_ENVIRONMENT` per project (recommended):

```powershell
$env:UV_PROJECT_ENVIRONMENT = "C:\Dev\venvs\myapp"
uv venv
uv sync
```

---

## Daily workflow {#daily-workflow}

```powershell
$env:UV_PROJECT_ENVIRONMENT="C:\Dev\venvs\myapp"
uv sync
uv run python -V
```

---

## Troubleshooting {#troubleshooting}

### Python installed into AppData instead of C:\Dev\uv-python {#python-installed-into-appdata}

That means `UV_PYTHON_INSTALL_DIR` wasn’t set in the shell at install time.

Check:

```powershell
echo $env:UV_PYTHON_INSTALL_DIR
```

If it’s blank, set it for this session and reinstall:

```powershell
$env:UV_PYTHON_INSTALL_DIR = "C:\Dev\uv-python"
uv python install 3.13
```

### .local\bin warning persists {#local-bin-warning-persists}

Run:

```powershell
uv python update-shell
```

Then restart PowerShell and re-check:

```powershell
where python3.13
```

---

## References {#references}

- uv installation
- uv Python installation & management
- uv project environment configuration (`UV_PROJECT_ENVIRONMENT`)
- Microsoft OneDrive restrictions and limitations
