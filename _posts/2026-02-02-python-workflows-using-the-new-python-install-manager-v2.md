---
layout: post
title: "Python workflows using the new Python Install Manager"
date: 2026-02-02
tags: [python, windows, tooling, pip, workflows]
---

## Introduction {#introduction}

Recent Python releases (3.12+) on Windows introduced a **much cleaner, first-class workflow** centered around the *Python Launcher* (`py`) and improved packaging tools. This post documents a **modern, low-friction Python workflow** that works cleanly with Python 3.14+ and scales forward.

This is not about experimental tooling — it reflects **officially supported behavior** from Python.org and Microsoft.

---

## Wiping Old Python Installations (Recommended) {#wipe-old-installations}

If you have experimented with Python over the years, your system may contain **multiple abandoned installs**, broken PATH entries, or orphaned `pip --user` packages.

Before adopting the modern workflow, it is often best to start clean.

I provide a PowerShell script that **completely removes legacy Python installations**, including:

- Old python.org installs
- Microsoft Store Python
- Orphaned `pip --user` packages
- Leftover registry entries
- Stale PATH references

[nuke_python.ps1](/assets/nuke_python.ps1)

Run it from an elevated PowerShell session, reboot, then install Python fresh from python.org.

---

## The Python Install Manager on Windows {#python-install-manager}

On Windows, Python is no longer managed by juggling `python.exe` paths.

Instead, the **Python Launcher (`py`)** acts as the install manager and version selector.

Key characteristics:

- Installed automatically by the python.org installer
- Knows about *all* installed Python versions
- Selects the correct interpreter without PATH hacks
- Future-proof across Python upgrades

```powershell
py list
py -3.14
```

---

## Installing and Updating pip, setuptools, and wheel {#tooling-setup}

```powershell
py -3.14 -m pip install -U pip setuptools wheel
```

This command updates the **entire Python packaging toolchain** for the selected interpreter.

---

## Scripts, Entry Points, and Where Commands Come From {#scripts-and-entrypoints}

When a package installs a command-line tool, it is placed in the `Scripts` directory of the active environment.

Virtual environments keep these tools isolated per project.

---

## Example: Installing and Using pdf2docx {#example-pdf2docx}

```powershell
py -3.14 -m venv .venv
.venv\Scripts\Activate.ps1
python -m pip install pdf2docx
pdf2docx input.pdf output.docx
```

---

## Recommended Windows Python Workflow (2026) {#recommended-workflow}

1. Wipe legacy installs (optional but recommended)
2. Install Python from python.org
3. Use `py` to select versions
4. Use venvs per project
5. Install dependencies only inside the venv

---

## Closing Thoughts {#closing}

Python on Windows has finally converged on a **boring, reliable workflow** — and that is a good thing.
