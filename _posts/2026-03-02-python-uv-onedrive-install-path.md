---
layout: post
title: "Python + uv + OneDrive: full install & setup (Windows 11)"
date: 2026-03-02 00:00:00 -0500
tags: [python, uv, onedrive, windows, dev-environment]
last_modified_at: 2026-10-29
---

> **Updated 2026-10-29** (checked against uv 0.12.x): fixed the PowerShell `where` checks, clarified which shims uv installs, dropped a redundant `uv venv`, and and added sections on workflows (quick script vs. maintained tool), upgrading, and a reset script.

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

- `C:\Dev\uv-python\cpython-3.13.<patch>-windows-x86_64-none\python.exe`

You'll also see a `cpython-3.13-windows-x86_64-none` folder. That is a junction uv maintains that points at the newest installed 3.13 patch, so venvs built from it pick up patch upgrades automatically (see [Upgrading](#upgrading)).

---

## Step 4 — Update PATH so python shims work everywhere {#step-4-update-path}

`uv python install` puts a **versioned** executable (e.g., `python3.13.exe`) into:

- `C:\Users\<you>\.local\bin`

If that directory isn’t on PATH, uv will warn.

Plain `python` / `python3` shims are only installed if you add the still-experimental `--default` flag (`uv python install 3.13 --default`). Without it, `python` resolves to whatever else is on PATH (often the Microsoft Store alias). Inside projects this doesn't matter — use `uv run python`.

### 4.1 Add uv shims to PATH automatically {#update-shell}

Run once:

```powershell
uv python update-shell
```

Then **close PowerShell and open a new one**.

Verify (in PowerShell, plain `where` is an alias for `Where-Object`, so use `where.exe` or `Get-Command`):

```powershell
where.exe python3.13
python3.13 --version
Get-Command python -All   # only uv's if you used --default
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

Set `UV_PROJECT_ENVIRONMENT` per project, in the session:

```powershell
$env:UV_PROJECT_ENVIRONMENT = "C:\Dev\venvs\myapp"
uv sync
```

`uv sync` creates the venv if it doesn't exist, so a separate `uv venv` isn't needed.

> **Don't** set `UV_PROJECT_ENVIRONMENT` at User scope. An absolute path is used as-is for *every* project, so each project's `uv sync` would overwrite the same venv (and remove the other projects' packages). Keep it one path per project, set per session.

---

## Workflows {#workflows}

Two kinds of sessions cover most work: a **quick script** you write once (or occasionally rerun), and a **maintained tool** you keep improving and use day to day.

### Quick script session {#quick-script}

For a single `.py` file there's no project and no venv to manage. uv stores the script's dependencies in the file itself (inline metadata, PEP 723) and builds a throwaway environment in the uv cache (`C:\Dev\uv-cache`), so nothing lands in OneDrive except the script.

```powershell
cd "C:\Users\<you>\OneDrive\Projects\scripts"

uv init --script tidy_photos.py --python 3.13   # creates the file with a metadata header
uv add --script tidy_photos.py pillow rich      # records dependencies in that header
uv run tidy_photos.py                           # runs it (builds/reuses the cached env)
```

The top of the file now looks like this:

```python
# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "pillow>=<latest>",
#     "rich>=<latest>",
# ]
# ///
```

Useful extras:

- **One-off dependency without editing the file:** `uv run --with requests tidy_photos.py`
- **Pin exact versions for later reruns:** `uv lock --script tidy_photos.py` (writes `tidy_photos.py.lock` next to it)
- **Edit in VS Code:** run `uv sync --script tidy_photos.py` to build the env, then `uv python find --script tidy_photos.py` and paste that path into *Python: Select Interpreter*

When a script grows a second file, tests, or a settings file, promote it to a tool (below).

### Maintained tool session {#maintained-tool}

For something you'll keep using and changing, make it a real package with a command-line entry point, a lockfile, and dev tools. The source stays in OneDrive; the venv goes in `C:\Dev\venvs`.

**One-time setup:**

```powershell
cd "C:\Users\<you>\OneDrive\Projects"
uv init --package mytool --python 3.13   # src\mytool\ layout + [project.scripts] entry point
cd mytool

$env:UV_PROJECT_ENVIRONMENT = "C:\Dev\venvs\mytool"   # or run the uvenv helper below
uv add httpx typer                   # runtime dependencies
uv add --dev pytest ruff             # dev-only tools
uv sync
git init; git add .; git commit -m "Initial mytool"
```

Commit `pyproject.toml`, `uv.lock` and `.python-version`. There's no `.venv` folder to ignore, because it lives outside the project.

**Each work session:**

```powershell
cd "C:\Users\<you>\OneDrive\Projects\mytool"
$env:UV_PROJECT_ENVIRONMENT = "C:\Dev\venvs\mytool"   # or: uvenv
uv sync                    # bring the venv in line with uv.lock
uv run mytool --help       # run the tool from source
uv run pytest              # test
uv run ruff check --fix .  # lint
```

**Put it on your PATH for everyday use:**

```powershell
uv tool install --editable .   # 'mytool' now works from any folder
```

`--editable` means code changes take effect immediately, without reinstalling. Add `--force` to reinstall after changing dependencies or entry points. The tool gets its own venv under `%APPDATA%\uv\tools` (outside OneDrive). To keep it with the rest of the layout, set `UV_TOOL_DIR` to `C:\Dev\uv-tools` at User scope.

**Maintenance:**

```powershell
uv lock --upgrade      # move all dependencies to their newest allowed versions
uv sync
uv run pytest          # confirm nothing broke, then commit uv.lock
uv build               # optional: wheel + sdist in .\dist for sharing
```

### Optional: set the venv path automatically from the folder name {#profile-helper}

Add this to your PowerShell profile (`notepad $PROFILE`). Run `uvenv` from any project folder and it points uv at `C:\Dev\venvs\<folder-name>`:

```powershell
function uvenv {
    $name = Split-Path -Leaf (Get-Location)
    $env:UV_PROJECT_ENVIRONMENT = "C:\Dev\venvs\$name"
    Write-Host "UV_PROJECT_ENVIRONMENT = $env:UV_PROJECT_ENVIRONMENT"
}
```

---

## Upgrading {#upgrading}

### Python patch releases {#upgrade-python}

```powershell
uv python upgrade 3.13   # or just: uv python upgrade
```

This moves to the newest 3.13.x (it never jumps minor versions). Existing venvs built from the 3.13 junction follow the upgrade; the old patch is kept for anything still pinned to it.

### uv itself {#upgrade-uv}

```powershell
uv self update                    # if installed with Astral's installer
winget upgrade --id=astral-sh.uv  # if installed with WinGet
```

---

## Resetting your current install {#reset}

If your machine already has Python from several sources (python.org installers, the Microsoft Store, an older uv setup in AppData, stray PATH entries), it's often faster to wipe it all and start clean than to untangle it.

**Script:** [Reset-UvPython.ps1](/assets/Reset-UvPython.ps1)

It removes every Python it can find, then sets up the layout from this article:

1. **Inventory:** lists python.org installs and the `py` launcher, Store/MSIX Python packages, uv-managed Pythons, shims in `.local\bin`, leftover folders, and Python entries on PATH.
2. **Remove:** runs each installer's own uninstaller, removes Store packages, runs `uv python uninstall --all`, deletes leftover folders (`%LOCALAPPDATA%\Programs\Python`, `%APPDATA%\Python`, the pip cache, uv's AppData Python folder), empties `C:\Dev\venvs`, and cleans PATH. It also clears `PYTHONHOME` and `PYTHONPATH` if they're set.
3. **Install:** installs uv if needed, sets `UV_PYTHON_INSTALL_DIR` and `UV_CACHE_DIR`, then runs `uv python install 3.13` and `uv python update-shell`.

It does **not** touch your project folders, Anaconda/Miniconda (it only reports them), or Python that's bundled inside other apps.

### Run it {#run-reset}

Download the script to `C:\Dev`, then from PowerShell. Use **Run as administrator** if any Python was installed "for all users":

```powershell
cd C:\Dev
Unblock-File .\Reset-UvPython.ps1                       # clears the "downloaded from internet" flag
powershell -ExecutionPolicy Bypass -File .\Reset-UvPython.ps1 -DryRun   # preview only
powershell -ExecutionPolicy Bypass -File .\Reset-UvPython.ps1           # do it (asks you to type YES)
```

Options:

| Parameter | Default | What it does |
|---|---|---|
| `-Version` | `3.13` | Python version to install afterward |
| `-DevRoot` | `C:\Dev` | Root for `uv-python`, `uv-cache`, `venvs` |
| `-KeepVenvs` | off | Don't empty `C:\Dev\venvs` |
| `-DryRun` | off | Show what would happen, change nothing |
| `-Force` | off | Skip the YES prompt |

### After it finishes {#after-reset}

1. Open a **new** PowerShell window and check `where.exe python3.13` and `python3.13 --version`.
2. In **Settings > Apps > Advanced app settings > App execution aliases**, turn off `python.exe` and `python3.exe` (App Installer) so typing `python` doesn't open the Microsoft Store.
3. Rebuild each project's venv: set `UV_PROJECT_ENVIRONMENT`, then run `uv sync`.
4. If you use uv tools, rebuild them: `uv tool upgrade --all --reinstall`.

> Always run `-DryRun` first. If an uninstaller fails, the script says so. Remove that entry from **Settings > Apps** and re-run.

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
where.exe python3.13
```

### `where python` prints nothing {#where-prints-nothing}

In PowerShell `where` is `Where-Object`, not the Windows `where` command. Use `where.exe` or `Get-Command`.

---

## References {#references}

- [uv installation](https://docs.astral.sh/uv/getting-started/installation/)
- [uv Python versions (install, upgrade, executables)](https://docs.astral.sh/uv/concepts/python-versions/)
- [uv project environment configuration (`UV_PROJECT_ENVIRONMENT`)](https://docs.astral.sh/uv/concepts/projects/config/)
- [uv releases](https://github.com/astral-sh/uv/releases)
- [Microsoft OneDrive restrictions and limitations](https://support.microsoft.com/en-us/office/restrictions-and-limitations-in-onedrive-and-sharepoint-64883a5d-228e-48f5-b3d2-eb39e07630fa)
