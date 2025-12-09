---
layout: post
title: "Python Migration & Cleanup Kit for Windows"
date: 2025-12-09
tags: [python, windows, scripting, migration]
---

Upgrading Python on Windows doesn’t have to mean starting from scratch.  
This post walks through a **safe side-by-side upgrade**, a **full cleanup option**, and provides a downloadable **PowerShell kit** you can drop into your toolbox.

Download the kit here:

- [Python Migration & Cleanup Kit (ZIP)](../assets/python-migrate-kit.zip)

---

## Why use a migration script instead of in-place upgrade? {#why-migration-script}

Windows installs of Python aren’t designed for true in-place upgrades. Different versions can break binary packages, scripts are tied to specific interpreters, and some apps bundle their own Python that you *shouldn’t* touch.

The safer pattern is:

1. Install the new Python version side-by-side.
2. Reinstall your packages into the new interpreter.
3. Move or recreate any helper scripts / entry points you rely on.
4. Update PATH and file associations.
5. Uninstall the old version once everything checks out.

The migration kit automates most of steps 2–3 and gives you a repeatable process for future upgrades.

---

## What’s in the Python Migration & Cleanup Kit? {#whats-in-kit}

The ZIP contains these files:

- `migrate-python.ps1` – one-stop helper that:
  - Exports packages from the old Python
  - Installs them into the new Python
  - Optionally copies your custom `.py` / `.cmd` scripts from the old `Scripts` folder

- `export-requirements.ps1` – exports a list of packages from your old Python into a `requirements.txt`-style file.

- `install-requirements.ps1` – installs packages from a requirements-style text file into the new Python.

- `copy-custom-scripts.ps1` – copies your own helper scripts from the old `Scripts` folder to the new one.

- `Remove-All-Python.ps1` – **aggressive cleanup script** that:
  - Optionally runs uninstallers for python.org installs
  - Deletes common Python directories
  - Backs up and cleans PATH
  - Optionally removes Microsoft Store Python and the Python Launcher (`py.exe`)

- `README.txt` – usage overview and sample commands.

All scripts are written for **Windows PowerShell** and assume standard python.org installs (e.g., `C:\\Users\\<you>\\AppData\\Local\\Programs\\Python\\Python311\\python.exe`).

---

## Option A: Migrate to a new Python version {#option-a-migrate}

1. **Install the new Python version** from python.org and note both paths, e.g.:  
   - Old: `C:\\Users\\<you>\\AppData\\Local\\Programs\\Python\\Python311\\python.exe`  
   - New: `C:\\Users\\<you>\\AppData\\Local\\Programs\\Python\\Python313\\python.exe`

2. **Open PowerShell** in the folder where you extracted the ZIP.

3. **Allow script execution for this session only:**

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

4. **Run the migration helper:**

```powershell
.\migrate-python.ps1 `
    -OldPython "C:\\Users\\<you>\\AppData\\Local\\Programs\\Python\\Python311\\python.exe" `
    -NewPython "C:\\\Users\\<you>\\AppData\\Local\\Programs\\Python\\Python313\\python.exe" `
    -CopyCustomScripts
```

This will:

- Export your packages from the old Python  
- Upgrade `pip` on the new Python  
- Reinstall the exported packages into the new Python  
- Copy your `.py` and `.cmd` helper scripts from the old `Scripts` directory into the new one (if `-CopyCustomScripts` is used)

---

## Option B: Nuke Python and start clean {#option-b-clean-wipe}

If your Python installs are tangled beyond patience, or you explicitly want a clean slate, use **`Remove-All-Python.ps1`**.

> ⚠ **Warning:** This can break applications that bundle or rely on a specific Python.  
> Make a backup or restore point first.

Run it from an **elevated PowerShell** (Run as Administrator):

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

.\Remove-All-Python.ps1 `
    -RunUninstallers `
    -RemoveStorePython `
    -RemovePyLauncher
```

What it does:

- Searches for python.org uninstallers and runs them (with `-RunUninstallers`)
- Removes common Python directories, including:
  - `%LOCALAPPDATA%\\Programs\\Python`
  - `%APPDATA%\\Python`
  - Common `Program Files\\Python*` locations
- Backs up your **user and machine PATH** to text files on your Desktop
- Removes Python-related PATH segments
- Optionally removes:
  - Microsoft Store Python (`-RemoveStorePython`)
  - Python Launcher (`py.exe`) (`-RemovePyLauncher`)

After it finishes:

1. **Reboot.**
2. Install a fresh Python from python.org.
3. Rebuild environments or use migration tools again to repopulate packages.

---

## Verifying the new installation {#verifying-install}

After using the migration path or reinstalling after a wipe:

1. **Check which Python you’re getting on the command line:**

```powershell
where python
python --version

where py
py -0p
```

2. **Fix your PATH if needed** so that only the new Python’s `python.exe` and `Scripts` directory are referenced.

3. **Open a project** and run your usual commands (e.g., `python -m pip list`, `pytest`) to confirm everything behaves as expected.

---

## Where to put the ZIP in your Jekyll site {#jekyll-placement}

For a typical GitHub Pages / Jekyll setup, you’d:

1. Copy `python-migrate-kit.zip` into your repository’s `assets/` folder.
2. Commit and push that change.
3. Make sure your Markdown link points to:

```markdown
[Python Migration & Cleanup Kit (ZIP)](../assets/python-migrate-kit.zip)
```

Adjust the relative path if your posts live in a different directory depth.

---

## Reusing this kit for future Python upgrades {#reuse-kit}

The nice part of this approach is that it’s reusable:

- Update the `-OldPython` and `-NewPython` paths for whatever versions you’re moving between.
- Run `migrate-python.ps1` again for normal upgrades.
- Use `Remove-All-Python.ps1` only when you truly need a clean slate.

This gives you a consistent, low-drama way to keep Python current on Windows — or start over clean — without losing the tools you rely on every day.