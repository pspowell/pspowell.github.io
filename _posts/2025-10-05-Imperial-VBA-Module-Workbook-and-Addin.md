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

Both approaches give you the same user-defined functions (UDFs) for formatting, parsing, snapping, and converting imperial/metric lengths (feet-inches-fractions). A concise function summary and installation tips are included below. :contentReference[oaicite:0]{index=0}

**Download the module:**  
- [`Imperial.bas`](https://github.com/pspowell/Windows-tech-helper-files/blob/main/Other/Imperial.bas)  
- (Reference doc) [`Imperial.docx`](https://github.com/pspowell/Windows-tech-helper-files/blob/main/Other/Imperial.docx)

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

**Notes:** Denominators are typically 2, 4, 8, 16, 32, 64; negative numbers are supported; you can enable typographic primes (′ ″) if desired. :contentReference[oaicite:1]{index=1}

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
