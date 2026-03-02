---
layout: post
title: "Best practices: using uv with a project in OneDrive (Windows 11) while keeping the venv outside OneDrive"
date: 2026-03-02
tags: [python, uv, windows, onedrive, venv, dev-environment]
---

If your repo lives under OneDrive, the single best way to avoid pain is:

- Keep the **project folder** in OneDrive (fine)
- Keep the **virtual environment (venv)** *outside* OneDrive (recommended)
- Keep **uv’s cache** *outside* OneDrive (recommended)
- Let uv target that external venv explicitly (so you never “accidentally” create `.venv` inside OneDrive)

## Why OneDrive and `.venv` don’t mix {#why-onedrive-and-venv-dont-mix}

A Python venv contains **lots** of small files, executable shims, compiled extensions, and fast-changing metadata. OneDrive’s syncing, scanning, and file locking can interfere—leading to slow installs, file-in-use errors, or occasional corruption.

The cure is simple: don’t sync the venv.

## Install uv on Windows {#install-uv-on-windows}

Use Astral’s official installation guidance for Windows from the uv docs and keep uv itself installed normally (system-wide). Then rely on per-project environments for dependencies.

Once installed, verify:

```powershell
uv --version
uv python --version
```

## The recommended layout {#recommended-layout}

Example (adjust names/paths to your machine):

- Project (in OneDrive):  
  `C:\Users\Preston\OneDrive\Projects\myapp`
- Venv (outside OneDrive):  
  `C:\venvs\myapp`
- uv cache (outside OneDrive):  
  `C:\uv-cache`

This keeps OneDrive syncing your code and config files, but not the thousands of venv artifacts.

## Tell uv to put the project environment outside OneDrive {#tell-uv-project-env-outside-onedrive}

uv’s **project environment path** can be configured via the `UV_PROJECT_ENVIRONMENT` environment variable. It defaults to `.venv`, but you can point it to an absolute path outside OneDrive. citeturn0search7turn0search0

### One-time per-shell (quick start) {#one-time-per-shell}

From your project folder:

```powershell
cd "C:\Users\Preston\OneDrive\Projects\myapp"

$env:UV_PROJECT_ENVIRONMENT = "C:\venvs\myapp"
uv sync
```

Notes:

- If the environment doesn’t exist yet at that path, uv will create it. citeturn0search7
- After syncing, run commands inside the project environment:

```powershell
uv run python -V
uv run python -m pip -V
uv run python -m pytest
```

### Make it permanent for the project (recommended) {#make-it-permanent}

Put a small helper script in the repo (so teammates can use the same pattern).

Create `dev.ps1` in the project root:

```powershell
# dev.ps1
$ErrorActionPreference = "Stop"

# Point uv's project environment outside OneDrive
$env:UV_PROJECT_ENVIRONMENT = "C:\venvs\myapp"

# Optional: keep uv cache outside OneDrive too
$env:UV_CACHE_DIR = "C:\uv-cache"

uv sync
uv run python -m your_module
```

Run it:

```powershell
.\dev.ps1
```

This avoids “it worked yesterday” problems when a terminal session forgets the env var.

## Also move uv’s cache outside OneDrive {#move-uv-cache-outside-onedrive}

uv uses a cache to speed up dependency installs. Put it somewhere local and stable:

```powershell
setx UV_CACHE_DIR "C:\uv-cache"
```

Then open a new terminal. (This reduces churn in any synced folders and keeps installs fast.)

The uv docs list supported environment variables and their meanings. citeturn0search0

## Alternative: target an existing venv via VIRTUAL_ENV {#alternative-virtual-env}

uv can install into arbitrary virtual environments by setting `VIRTUAL_ENV` (as long as it’s a compliant venv). citeturn0search1

Example:

```powershell
cd "C:\Users\Preston\OneDrive\Projects\myapp"

$env:VIRTUAL_ENV = "C:\venvs\myapp"
$env:PATH = "$env:VIRTUAL_ENV\Scripts;$env:PATH"

uv pip install -r requirements.txt
```

That said, for uv **Projects** workflows (`uv sync`, lockfiles, etc.), prefer `UV_PROJECT_ENVIRONMENT` so uv consistently treats the external directory as *the* project environment path. citeturn0search7turn0search0

## What should live in OneDrive vs outside {#what-lives-in-onedrive-vs-outside}

Keep in OneDrive (good):

- Source code (`src/`, `app/`, etc.)
- `pyproject.toml`
- `uv.lock` (if you use uv’s locking)
- `README.md`, docs, scripts (`dev.ps1`, etc.)
- `.vscode/settings.json` (optional)

Keep out of OneDrive (recommended):

- The virtual environment directory (e.g., `C:\venvs\myapp`)
- uv cache directory (e.g., `C:\uv-cache`)

## Git ignore recommendations {#git-ignore-recommendations}

Even if you’re not creating `.venv` in the repo, it’s still worth ignoring common artifacts:

```gitignore
.venv/
__pycache__/
*.pyc
.pytest_cache/
.mypy_cache/
.ruff_cache/
```

## VS Code: point to the external interpreter {#vscode-external-interpreter}

Because the venv is outside the repo, VS Code may not auto-detect it.

Create (or edit) `.vscode/settings.json`:

```json
{
  "python.defaultInterpreterPath": "C:\\venvs\\myapp\\Scripts\\python.exe"
}
```

Now “Run Python File”, linting, and test discovery will use the correct interpreter.

## Troubleshooting checklist {#troubleshooting-checklist}

### uv created `.venv` inside OneDrive anyway {#uv-created-dotvenv-anyway}

- Delete that `.venv` folder
- Set `UV_PROJECT_ENVIRONMENT` to your external path
- Run `uv sync` again

The env var overrides the default `.venv` behavior. citeturn0search7turn0search0

### Random “Access denied” / file-in-use errors {#access-denied}

Common causes on Windows include file locking by AV/sync tools and attempting to replace executables while they’re in use. If you see errors during installs, make sure:

- OneDrive is **not** syncing the venv directory
- You’re not running Python from that venv in another terminal/editor
- Your cache is outside OneDrive
- Try closing VS Code (it can hold locks) and rerun

(These issues are widely reported in Windows tooling scenarios, including uv-specific threads. citeturn0search8)

## Suggested “standard operating procedure” {#sop}

1. Keep repos under OneDrive if you want cloud-backed code.
2. Put all venvs in `C:\venvs\<project>` (not synced).
3. Set `UV_PROJECT_ENVIRONMENT` per-project (via `dev.ps1`).
4. Set `UV_CACHE_DIR` globally to a non-synced local folder.
5. Use `uv sync` and `uv run ...` for repeatable, clean workflows.

---

### Sources {#sources}

- uv docs: Project environment configuration (`UV_PROJECT_ENVIRONMENT`). citeturn0search7  
- uv docs: Installing into arbitrary environments via `VIRTUAL_ENV`. citeturn0search1  
- uv docs: Environment variables reference (includes `UV_PROJECT_ENVIRONMENT`, `UV_CACHE_DIR`, etc.). citeturn0search0
