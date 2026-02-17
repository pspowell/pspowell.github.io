---
layout: post
title: "How to Freeze pip Modules Before Upgrading Python"
date: 2026-02-17
tags: [python, pip, virtualenv, windows]
---

## Overview {#overview}

If you are upgrading Python and want to reinstall all your previously installed modules, you can use `pip freeze` to capture your current environment and restore it later.

These examples assume Windows PowerShell.

---

## Step 1 – Freeze Your Current Environment {#step-1-freeze}

```powershell
python -m pip freeze > requirements.txt
```

If multiple versions are installed:

```powershell
py -3.12 -m pip freeze > requirements.txt
```

---

## Step 2 – Install or Upgrade Python {#step-2-upgrade}

```powershell
py -3.13 --version
```

---

## Step 3 – Reinstall All Modules {#step-3-reinstall}

```powershell
py -3.13 -m pip install -r requirements.txt
```

---

## Recommended: Use a Virtual Environment {#virtual-environment}

```powershell
python -m venv .venv
\.venv\Scripts\Activate.ps1
pip freeze > requirements.txt
```

Recreate after upgrade:

```powershell
py -3.13 -m venv .venv
\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

---

## Final Recommendation {#final-recommendation}

- Always use virtual environments
- Commit requirements.txt to version control
- Recreate environments instead of copying site-packages
