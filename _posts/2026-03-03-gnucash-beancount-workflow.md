---
layout: post
title: "GnuCash → Beancount + Fava Workflow (uv + Windows 11)"
date: 2026-03-03 00:00:00 -0500
tags: [gnucash, beancount, fava, uv, windows]
---

## Overview {#overview}

This document describes the complete workflow for:

- Exporting a **GnuCash SQLite (.gnucash)** file
- Converting it to **Beancount**
- Viewing it in **Fava**
- Using **uv-managed Python**
- Keeping virtual environments outside OneDrive

This setup assumes:

- Windows 11
- uv-managed Python (installed in `C:\Dev\uv-python`)
- Virtual environments in `C:\Dev\venvs`
- Project folder inside OneDrive

---

## Project Location {#project-location}

Project folder:

```text
C:\Users\Preston\OneDrive\Projects\gnucash-beancount
```

Recommended structure:

```text
gnucash-beancount\
  tools\
  data\
  out\
  README.md
```

Create it:

```powershell
mkdir "C:\Users\Preston\OneDrive\Projects\gnucash-beancount"
cd "C:\Users\Preston\OneDrive\Projects\gnucash-beancount"
mkdir tools, data, out | Out-Null
```

---

## Initialize uv Project {#initialize-uv-project}

From project root:

```powershell
uv init
```

Bind project to an external venv (outside OneDrive):

```powershell
$env:UV_PROJECT_ENVIRONMENT = "C:\Dev\venvs\gnucash-beancount"
uv venv --python 3.13
```

---

## Install Dependencies {#install-dependencies}

Install required packages:

```powershell
uv add piecash sqlalchemy beancount fava
uv sync
```

Verify:

```powershell
uv run python -c "import piecash, sqlalchemy, beancount; print('OK')"
uv run fava --version
```

---

## Add Export Script {#add-export-script}

Place your exporter script in:

```text
tools\export_gnucash_to_bean.py
```

---

## Add GnuCash File {#add-gnucash-file}

Place your `.gnucash` SQLite file in:

```text
data\mybook.gnucash
```

Example:

```powershell
copy "D:\path\to\yourbook.gnucash" ".\data\mybook.gnucash"
```

---

## Export to Beancount {#export-to-beancount}

From project root:

```powershell
uv run python .\tools\export_gnucash_to_bean.py .\data\mybook.gnucash > .\out\main.bean
```

Confirm output exists:

```powershell
Get-Item .\out\main.bean
```

Optional validation:

```powershell
uv run python -c "from beancount.loader import load_file; e,err,_=load_file(r'out\main.bean'); print('errors:', len(err))"
```

---

## Launch Fava {#launch-fava}

```powershell
uv run fava .\out\main.bean
```

Open the URL shown (typically http://127.0.0.1:5000).

---

## Daily Workflow {#daily-workflow}

Open project:

```powershell
cd "C:\Users\Preston\OneDrive\Projects\gnucash-beancount"
```

Set venv:

```powershell
$env:UV_PROJECT_ENVIRONMENT = "C:\Dev\venvs\gnucash-beancount"
```

Sync dependencies (if needed):

```powershell
uv sync
```

Export:

```powershell
uv run python .\tools\export_gnucash_to_bean.py .\data\mybook.gnucash > .\out\main.bean
```

Launch UI:

```powershell
uv run fava .\out\main.bean
```

---

## OneDrive Notes {#onedrive-notes}

- Project folder is safe inside OneDrive.
- Virtual environments stay outside OneDrive (`C:\Dev\venvs`).
- uv-managed Python stays outside OneDrive (`C:\Dev\uv-python`).
- Beancount output (`.bean`) is text and sync-friendly.
- Large `.gnucash` files may sync slowly; optionally store them outside OneDrive and reference by full path.

---

## Environment Locations Summary {#environment-locations-summary}

| Component | Location |
|-----------|----------|
| uv Python installs | C:\Dev\uv-python |
| uv cache | C:\Dev\uv-cache |
| Project venv | C:\Dev\venvs\gnucash-beancount |
| Project code | OneDrive |
| Beancount output | OneDrive |

---

## End State {#end-state}

You now have:

- Deterministic uv-managed Python
- Clean external virtual environment
- GnuCash → Beancount conversion workflow
- Fava UI for inspection
- OneDrive-safe layout
