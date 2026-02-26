---
layout: page
title: "Social Security Early-Claim Workbook (Before FRA)"
date: 2026-02-26
---

This page documents the Excel workbook used to analyze whether to **claim Social Security before full retirement age (FRA)** versus **claiming at FRA** or **delaying (typically to age 70)**.

**Download:** [Social Security Early-Claim Workbook (Excel)](/assets/social-security-early-claim-workbook.xlsx)

> Place the workbook file at: `assets/social-security-early-claim-workbook.xlsx` in your Jekyll site so the link above works.

## Why this workbook exists (the rationale) {#rationale}

Deciding when to claim is a tradeoff between:

- **Earlier cashflow vs. a permanently reduced monthly benefit** if you start before FRA.  
- **Larger lifetime checks (especially if you live longer)** if you delay, thanks to delayed retirement credits (up to age 70).
- **Opportunity cost:** if you claim earlier, you may invest/spend those checks sooner—so a present value comparison (NPV) matters.
- **Work + earnings test timing:** if you claim before FRA and keep working, the earnings test can withhold payments temporarily.
- **Household planning:** spousal and survivor considerations can dominate the “best” choice for a couple.

This workbook is built to make those tradeoffs explicit and comparable in one place, using transparent formulas you can audit.

## What’s inside (tabs) {#tabs}

- **README** — quick instructions, color key, and official reference links.
- **Inputs** — all editable assumptions (blue text on yellow cells).
- **Benefits** — computes monthly benefit under three strategies:
  - **A: Early** (default 62)
  - **B: FRA**
  - **C: Delayed** (default 70)
- **Cashflows** — annual benefit cashflows by age with COLA, optional simplified withholding, PV, and cumulative PV.
- **BreakEven** — break-even ages using *cumulative PV of net benefits*.
- **Taxes** — *rough planning* estimate of taxable benefits based on provisional income thresholds (not a tax worksheet).
- **SpouseSurvivor** — quick reference calculations and reminders (high-level only).
- **Dashboard** — summary view (monthly benefits, PV to life expectancy, break-even ages).

## How to use it (step-by-step) {#how-to-use}

### 1) Fill in Inputs {#fill-inputs}

Go to **Inputs** and update the blue/yellow cells:

- **FRA** and **PIA** (your SSA statement values)
- Claim ages you want to compare (A/B/C)
- COLA and discount rate (your planning assumptions)
- If you will work while claiming before FRA, set **Working while claiming before FRA?** to **Yes** and enter earnings + exempt amount.

### 2) Check your monthly benefits {#monthly-benefits}

Go to **Benefits** and confirm:
- The early-claim reduction looks reasonable for your months early.
- The delayed-credit assumption matches your cohort (update the delayed credit rate if needed).

### 3) Interpret lifetime value & NPV {#npv}

Go to:
- **Cashflows** for the year-by-year “money in the door,” the PV of each year’s check, and cumulative PV totals.
- **Dashboard** for a quick PV-to-life-expectancy comparison.

**Rule of thumb:**  
If one strategy has a higher **Cum PV(Net) to LifeExp**, it’s “better” under *your* discount rate and life expectancy assumption.

### 4) Read break-even ages {#break-even}

On **BreakEven**, you’ll see:
- **Early vs FRA:** the first age where Early’s cumulative PV ≥ FRA’s cumulative PV
- **FRA vs Delayed:** the first age where FRA’s cumulative PV ≥ Delayed’s cumulative PV

If the sheet shows “No BE,” it means the cross-over doesn’t happen within the modeled age range.

## Modeling choices & limitations (read this) {#limitations}

- **Earnings test is simplified**: it models withholding as a cashflow reduction before FRA, and does *not* model SSA’s post-FRA recomputation that can increase benefits to reflect months withheld.
- **Delayed credit rate varies by birth year**: the input is editable because the correct credit depends on your cohort.
- **Tax tab is a rough estimator**: it uses basic threshold logic and does not replicate the full IRS worksheet.
- **This is planning software**: verify final decisions with official SSA tools and/or a qualified professional.

## Official references used {#sources}

- SSA early retirement reduction formula (5/9 of 1% then 5/12 of 1%): https://www.ssa.gov/oact/quickcalc/earlyretire.html  
- SSA exempt amounts / earnings test overview: https://www.ssa.gov/oact/cola/rtea.html  
- SSA “Receiving benefits while working” (includes current-year limits): https://www.ssa.gov/benefits/retirement/planner/whileworking.html  
- SSA delayed retirement credits (increase stops at age 70): https://www.ssa.gov/benefits/retirement/planner/delayret.html  
- IRS overview of Social Security benefit taxation: https://www.irs.gov/newsroom/irs-reminds-taxpayers-their-social-security-benefits-may-be-taxable  
