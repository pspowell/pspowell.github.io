---
layout: post
title: "Imperial VBA Module: Use as a Macro-Enabled Workbook or Excel Add-in"
date: 2025-10-05
tags: [excel, vba, add-in, macros, measurement, woodworking]
---

## Overview

This post shows two supported ways to use my **Imperial** VBA module in Microsoft Excel:

1. **Option A** — Use it directly inside a **macro-enabled workbook (`.xlsm`)**  
2. **Option B** — Package it as a reusable **Excel Add-in (`.xlam`)**

Both approaches give you the same user-defined functions (UDFs) for formatting, parsing, snapping, and converting imperial/metric lengths (feet-inches-fractions). A concise function summary and installation tips are included below.

**Download the module:**  
- [`Imperial.bas`](https://github.com/pspowell/Windows-tech-helper-files/raw/refs/heads/main/Other/Imperial.bas)
---

## What the Module Provides (quick tour)

The module exposes worksheet functions like:

- `FmtInches(inches, [denom], [useUnicode], [fractionOnlyIfSubInch], [hyphenBetween], [showFeet])`  
  Format a decimal inches value into mixed fraction text (e.g., `38.9375` → `3'-2 15/16"` with customizable options).

- `FmtInchesAuto(inches, [maxDenom], …)`  
  Automatically chooses the “best” denominator up to `maxDenom`.

- `FmtInchesWithTol(inches, [denom], [tolDenom])`  
  Adds a tolerance string (e.g., `3" ± 1/32"`).

- `FmtFeetInches(inches, [denom])` / `PrettyInches(...)`  
  Convenience wrappers for common formatting variants.

- `MetersToInchesText(m)`, `CentimetersToInchesText(cm)`, `MillimetersToInchesText(mm)`  
  Convert metric to formatted imperial strings.

- `ParseLengthToInches(text)`  
  Parse text like `5' 7-3/16"` or `2m 5cm` into **numeric inches**.

- `ParseAndFormat(text, [denom], [useFeet])`  
  One-shot parse + format.

- `SnapToDenom(inches, denom)`  
  Snap/round inches to the nearest fraction (e.g., 1/16).

- `InchesToFeetInchesArray(inches, [denom])`  
  Returns `{feet, wholeInches, num, den, sign}` as an array.

**Notes:** Denominators are typically 2, 4, 8, 16, 32, 64; negative numbers are supported; you can enable typographic primes (′ ″) if desired.

---

## Option A — Use in a Macro-Enabled Workbook (`.xlsm`)

This is ideal when the functions are specific to a single workbook (e.g., a project calculator or price sheet) and you’ll share the workbook itself.

### Steps

1. **Open Excel → Visual Basic Editor**  
   Press `Alt+F11` (Windows) or `Tools → Macro → Visual Basic Editor` (Mac).

2. **Import the module**  
   In the VB Editor: `File → Import File…` and select `Imperial.bas`.

3. **Save as macro-enabled**  
   Back in Excel: `File → Save As` → **Excel Macro-Enabled Workbook (`.xlsm`)**.

4. **Enable macros at first open**  
   If you see a security banner, click **Enable Content** (or add the folder to a **Trusted Location**; see “Security & Trust” below).

5. **Test a few formulas**  
   In any cell:
   ```excel
   =FmtInches(38.9375,16,TRUE,TRUE,TRUE,TRUE)
   =SnapToDenom(2.01,16)
   =ParseAndFormat("2m 5cm 4mm",16,TRUE)
   ```
   You should get nicely formatted strings and snapped values.

### Updating the module later

If you modify `Imperial.bas` and want to refresh it in this workbook:
- Open the VB Editor, remove the old `Module` (right-click → **Remove**; choose **No** when asked to export).
- `File → Import File…` and pick the updated `Imperial.bas`.
- Save the workbook again as `.xlsm`.

### Distributing to others

Share the `.xlsm` file. Recipients must **enable macros** (or place it in a **Trusted Location**). No separate installation is required.

---

## Option B — Package as an Excel Add-in (`.xlam`)

Choose this when you want the functions available in **any workbook** on your machine (and easily shareable as a single file to install).

### Create the add-in

1. **Start a clean workbook**  
   `File → New` → Blank workbook.

2. **Open the VB Editor → Import the module**  
   `Alt+F11` → `File → Import File…` → select `Imperial.bas`.

3. **Save as Add-in**  
   `File → Save As` → **Excel Add-In (`.xlam`)**.  
   - Recommended name: `Imperial.xlam` (or `ImperialPlusPlus.xlam` if you prefer).  
   - Save to Excel’s default Add-ins folder (Excel will suggest it), or choose a known folder you’ll keep stable.

### Install (load) the add-in

1. **Windows**: `File → Options → Add-ins` → at the bottom choose **Excel Add-ins** and click **Go…**  
   **Mac**: `Tools → Excel Add-ins…`

2. Click **Browse…**, select your `Imperial.xlam`, and ensure it’s **checked** in the Add-Ins list. Click **OK**.

3. **Verify**  
   In any workbook, try:
   ```excel
   =FmtFeetInches(125.125,16)
   =FmtInchesWithTol(10/3,16,32)
   =ParseLengthToInches("5' 7-3/16""")
   ```

> **Tip (versioning):** Keep a version number in the add-in file name (e.g., `Imperial_v1_3.xlam`). When you update, uncheck the old one in **Add-Ins**, remove it, then **Browse…** to the new file and check it.

### Uninstalling / disabling

- Go back to the Add-Ins dialog and **uncheck** it.  
- To fully remove, uncheck it, close Excel, then delete the `.xlam` file from disk.

---

## Security & Trust (recommended settings)

If Excel shows a yellow “Security Warning” bar:

- **Enable Content** at open _or_  
- Add your folder to a **Trusted Location**:
  - **Windows**: `File → Options → Trust Center → Trust Center Settings… → Trusted Locations → Add new location…`
  - **Mac**: `Excel → Preferences → Security & Privacy` (set macro settings appropriately)

If your organization restricts macros, you may need admin approval or a signed add-in.

---

## Frequently Used Examples

```excel
' Format 38.9375" as feet-inches-fraction (1/16) with typographic primes:
=FmtInches(38.9375,16,TRUE,TRUE,TRUE,TRUE)

' Auto-denominator up to 1/64":
=FmtInchesAuto(12.3333,64)

' Show tolerance:
=FmtInchesWithTol(10/3,16,32)   ' -> 3" ± 1/32" (example)

' Convert metric to imperial text:
=MetersToInchesText(1.2,16,TRUE)
=MillimetersToInchesText(18,16,TRUE)

' Parse text to numeric inches, then format:
=ParseLengthToInches("5' 7-3/16""")
=ParseAndFormat("2m 5cm 4mm",16,TRUE)

' Snap to nearest 1/16":
=SnapToDenom(2.01,16)
```

---

## Maintenance Notes

- Keep a master copy of `Imperial.bas` under version control (e.g., Git).  
- When you improve functions, **export** the updated module and either:
  - Re-import it into your `.xlsm` project(s), or
  - Build a new versioned `.xlam` and re-install it.

If you manage change logs, add a `CHANGELOG.md` to track function updates and bug fixes.

---

## Troubleshooting

- **`#NAME?` in cells** → The add-in isn’t loaded or macros aren’t enabled. Load the add-in (Option B) or open the `.xlsm` with macros enabled (Option A).  
- **Security warning every time** → Add a **Trusted Location** for the folder containing your `.xlsm` or `.xlam`.  
- **Functions appear but return unexpected text** → Check your `denom` and `useFeet/useUnicode` parameters; confirm cell values are in **inches** when required.  
- **Sharing with others** → For `.xlam`, each user must install/enable the add-in. For `.xlsm`, users must enable macros on open.

---

## Credits & License

Module and documentation by **Preston S. Powell**. 
