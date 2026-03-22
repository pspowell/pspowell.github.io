---
layout: post
title: "Improving the PowerShell Autocomplete Experience"
date: 2026-03-22
tags: [powershell, productivity, cli, psreadline, automation]
---

## Why Customize PowerShell Autocomplete?

Out of the box, PowerShell’s command-line experience is functional—but not optimized for speed or flow. Most users rely on basic tab completion or arrow-key suggestions, which can be limiting and inefficient for frequent CLI work.

By tuning PSReadLine, you can transform PowerShell into a modern, highly responsive shell with:

- Intelligent, ranked suggestions
- Searchable command history
- Faster command acceptance (full or partial)
- Menu-style completions (similar to VS Code or zsh)
- Persistent, deduplicated history across sessions

---

## Upgrade PowerShell via Winget

What this does:
Upgrade PowerShell if managed by winget.

```powershell
winget upgrade --id Microsoft.PowerShell --source winget
```

Force reinstall:

```powershell
winget upgrade --id Microsoft.PowerShell --source winget --force
```

Check version:

```powershell
pwsh --version
```

---

## Fix "No installed package found"

What this does:
Handles non-winget installs.

```powershell
$PSVersionTable
```

```powershell
winget install --id Microsoft.PowerShell --source winget
```

```powershell
winget list powershell
```

---

## Accept Suggestions Alternatives

Accept full suggestion:

```text
Tab
```

Accept next word:

```text
Ctrl + RightArrow
```

History search:

```text
F8
```

Menu completion:

```text
Ctrl + Space
```

---

## Enable Better Predictions

```powershell
Set-PSReadLineOption -PredictionViewStyle ListView
```

```powershell
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
```

---

## Persistent Keybinding Example

```powershell
notepad $PROFILE
```

Add:

```powershell
Set-PSReadLineKeyHandler -Key Ctrl+f -Function AcceptSuggestion
```

Reload:

```powershell
. $PROFILE
```

---

## Full Profile Snippet

```powershell
Import-Module PSReadLine

Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView

try {
    Set-PSReadLineOption -PredictionSource HistoryAndPlugin
} catch {}

Set-PSReadLineOption -MaximumHistoryCount 10000
Set-PSReadLineOption -HistoryNoDuplicates:$true
Set-PSReadLineOption -HistorySaveStyle SaveIncrementally

Set-PSReadLineKeyHandler -Key Ctrl+f -Function AcceptSuggestion
Set-PSReadLineKeyHandler -Key Ctrl+RightArrow -Function AcceptNextSuggestionWord
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Ctrl+Spacebar -Function MenuComplete

Set-PSReadLineOption -BellStyle None
```

---

## Install Prediction Plugin

```powershell
Install-Module -Name Az.Tools.Predictor -Scope CurrentUser
```

---

## Final Thoughts

These tweaks significantly improve speed, recall, and usability in PowerShell.
