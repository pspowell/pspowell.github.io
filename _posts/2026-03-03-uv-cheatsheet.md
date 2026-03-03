---
layout: post
title: "UV Cheatsheet"
date: 2026-03-03
tags: [python, uv, virtualenv, packaging, windows]
---

## Download {#download}

- **Printable one-sheet (double-sided) PDF:** **[Download UV Cheatsheet PDF](/assets/2026-03-03-uv-cheatsheet.pdf)**


---

## What uv replaces {#what-uv-replaces}

This cheatsheet is organized by what `uv` can replace (pyenv, venv, poetry, pip/pipx) and the most common commands.

---

## Python versions {#python-versions}

| Purpose | Command |
|---|---|
| Install a Python | `uv python install <version>` |
| List versions | `uv python list` |
| Use a version in project | `uv python use <version>` |
| Auto-install required version | `uv run --python <version> script.py` |
| Pin version | `uv python pin <version>` |

---

## Virtual environment {#virtual-environment}

| Purpose | Command |
|---|---|
| Create venv | `uv venv` |
| Create venv w/ specific Python | `uv venv --python <version>` |
| Activate (Windows) | `.venv\Scripts\activate` |
| Activate (Linux/macOS) | `source .venv/bin/activate` |
| Reinstall deps | `uv sync --reinstall` |

---

## Project and locking {#project-and-locking}

| Purpose | Command |
|---|---|
| Init project | `uv init <project-name>` |
| Add dependency | `uv add <package-name>` |
| Add dev dependency | `uv add --dev <package-name>` |
| Remove package | `uv remove <package-name>` |
| Lock deps | `uv lock` |
| Upgrade lock (all) | `uv lock --upgrade` |
| Upgrade lock (one) | `uv lock --upgrade-package <package-name>` |

---

## Install, export, upgrade {#install-export-upgrade}

| Purpose | Command |
|---|---|
| Install from pyproject | `uv sync` |
| Exclude groups | `uv sync --no-group dev --no-group lint` |
| Install requirements.txt | `uv pip install -r requirements.txt` |
| Freeze requirements.txt | `uv pip freeze > requirements.txt` |
| Export from uv.lock | `uv export --format requirements-txt > requirements.txt` |
| Upgrade & apply (all) | `uv sync --upgrade` |
| Upgrade & apply (one) | `uv sync --upgrade-package <package-name>` |

---

## Tools and running {#tools-and-running}

| Purpose | Command |
|---|---|
| Install tool globally | `uv tool install <tool-name>` |
| List tools | `uv tool list` |
| Uninstall tool | `uv tool uninstall <tool-name>` |
| Upgrade one tool | `uv tool upgrade <tool-name>` |
| Upgrade all tools | `uv tool upgrade --all` |
| Run script in venv | `uv run <script.py>` |
| Run command in venv | `uv run -- <command>` |
| Run with temp dep | `uv run --with <package> python script.py` |
| One-time CLI tool | `uvx <tool-name> --version` |
| Bash completion | `eval "$(uv generate-shell-completion bash)"` |
