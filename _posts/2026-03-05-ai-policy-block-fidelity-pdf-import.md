---
date: 2026-03-05
layout: post
tags:
- ai
- policy-blocks
- fidelity
- gnucash
- python
- uv
title: AI Policy Block -- Fidelity PDF Import Pipeline
---

## Overview

This policy block documents the **rules, assumptions, and workflow**
used to convert Fidelity investment statements (PDF format) into a
**macro‑level GnuCash ledger**.

The goal of the pipeline is:

-   Parse Fidelity statements **directly from PDF**
-   Capture **cash activity, dividends, transfers, and fees**
-   Capture **ACAT security transfers**
-   Compute **market change**
-   Ensure **month‑end balances match the Fidelity statement exactly**

This policy block allows future AI conversations to **reproduce the same
import behavior consistently**.

------------------------------------------------------------------------

## Environment Policy

The Python execution environment must follow the user's preferred setup:

-   Python managed via **uv**
-   Dependencies declared **inline in script metadata**
-   Windows 11 environment
-   Project files stored in **OneDrive**
-   Scripts executed via:

```{=html}
<!-- -->
```
    uv run script_name.py

Dependencies typically include:

    pdfplumber
    pandas

------------------------------------------------------------------------

## Input Data Policy

### Source Documents

The importer operates exclusively on:

-   Fidelity **monthly account statement PDFs**

These may include layouts such as:

-   *Account Statement*
-   *Investment Report*

The importer must support both layouts.

### Required Information

The script must extract:

-   Statement period
-   Account number
-   Beginning account value
-   Ending account value
-   Deposits
-   Withdrawals
-   Contributions
-   Dividends
-   Fees
-   Securities transferred in/out

------------------------------------------------------------------------

## Parsing Policy

### Account Identification

Each account block begins with:

    Account # XXXXXXXX

Statements may contain multiple accounts.

### Statement Period

Extracted from text patterns such as:

    January 1, 2026 - January 31, 2026

The **period end date** determines the reconciliation entry date.

------------------------------------------------------------------------

## Cash Activity Rules

The following sections represent **cash activity affecting the Cash
account**:

  Statement Section    Ledger Destination
  -------------------- ----------------------
  Deposits             Equity:Contributions
  Withdrawals          Equity:Withdrawals
  Contributions        Equity:Contributions
  Dividends            Income:Dividends
  Other Activity In    Various
  Other Activity Out   Various

Transactions are posted to:

    Assets:Investments:Fidelity:<AccountType>:<AccountNumber>:Cash

------------------------------------------------------------------------

## ACAT Securities Policy {#acat-policy}

ACAT transfers represent **securities moving between brokers**.

These appear in statement summaries as:

    Securities Transferred In
    Securities Transferred Out

The importer must calculate:

    net_acat = transferred_in - transferred_out

Ledger entry:

    Assets:...:Securities   +net_acat
    Equity:ACAT Shares      -net_acat

Only **one ACAT entry per statement period per account** is permitted.

------------------------------------------------------------------------

## Market Change Policy

Because the importer does **not track individual securities**, price
movement must be represented as **Market Change**.

Formula:

    market_change =
    ending_account_value
    - beginning_account_value
    - net_cash_activity
    - net_acat_posted

Ledger entry:

    Assets:...:Securities   +market_change
    Income:Market Change    -market_change

This ensures the GnuCash balance equals the statement.

------------------------------------------------------------------------

## Chart of Accounts Policy

Accounts must be structured as:

    Assets
     └ Investments
        └ Fidelity
           ├ Brokerage
           │  └ <acct>
           │     ├ Cash
           │     └ Securities
           ├ IRA
           │  └ <acct>
           │     ├ Cash
           │     └ Securities
           └ Cash Management
              └ <acct>
                 ├ Cash
                 └ Securities

Other accounts:

    Equity:Contributions
    Equity:Withdrawals
    Equity:ACAT Shares
    Income:Dividends
    Income:Market Change
    Expenses:Investment Fees

Important rule:

    Securities accounts MUST NOT be placeholders.

They must allow posting of reconciliation entries.

------------------------------------------------------------------------

## Reconciliation Policy

For every statement period and account:

    beginning_value
    + net_cash_activity
    + net_acat
    + market_change
    -----------------
    ending_value

The reconciliation report must contain:

  field                 description
  --------------------- ---------------------------
  period_end            statement end date
  acct                  account number
  begin_value           beginning statement value
  net_cash_activity     total cash flows
  net_acat_posted       ACAT securities
  market_change_added   reconciliation entry
  end_value             statement ending value
  delta_after           reconciliation difference

Valid result:

    delta_after ≈ 0.00

------------------------------------------------------------------------

## Output Files

The importer generates three CSV files:

### Account Setup

    fidelity_account_setup.csv

Used to import the chart of accounts into GnuCash.

### Transaction Rollup

    fidelity_transaction_rollup.csv

Contains all ledger transactions.

### Reconciliation Report

    fidelity_monthly_reconcile.csv

Used to verify statement matching.

------------------------------------------------------------------------

## Design Philosophy

This system intentionally tracks investments at a **macro accounting
level**.

It does **not** track:

-   individual securities
-   tax lots
-   realized vs unrealized gains

Instead it captures **portfolio‑level financial activity** suitable for
personal accounting.

Advantages:

-   Simple ledger
-   Fast imports
-   Exact statement reconciliation

------------------------------------------------------------------------

## Policy Block Purpose {#purpose}

A **policy block** is a structured document that allows an AI assistant
to:

-   preserve rules discovered during a conversation
-   ensure future scripts behave consistently
-   prevent regression when improving code

When referenced in future chats, the AI should:

1.  follow these rules exactly
2.  maintain ledger compatibility
3.  ensure Fidelity statement reconciliation remains accurate
---

## Import Policy Block {#import-policy-block}

This section defines a **formal, deterministic rule set** for classifying Fidelity transaction “action codes” (or equivalent text labels) into GnuCash-friendly postings.

The objective is **consistent, repeatable classification** across future runs, even if statement layouts vary, and even if additional export formats (CSV/OFX) are used later.

**Primary design choice (macro accounting):**
- Track **cash** and **statement reconciliation**; do not track lots.
- Post security-related valuation effects into **Income:Market Change** via reconciliation entries.
- When an action represents a **cash flow**, post to the account’s `:Cash` subaccount.
- When an action represents a **non-cash security movement**, post to the account’s `:Securities` subaccount (macro holding).

### Canonical Posting Destinations {#canonical-posting-destinations}

- Cash side:
  - `Assets:Investments:Fidelity:<Group>:<Account>:Cash`
- Securities side:
  - `Assets:Investments:Fidelity:<Group>:<Account>:Securities`
- Buckets:
  - `Equity:Contributions`
  - `Equity:Withdrawals`
  - `Equity:ACAT Shares`
  - `Income:Dividends`
  - `Income:Interest`
  - `Income:Market Change`
  - `Expenses:Investment Fees`
  - `Expenses:Taxes` (optional; see withholding rules)

### Normalization Rules {#normalization-rules}

**Normalize** raw “action” strings before classification:

- Trim whitespace; uppercase.
- Collapse multiple spaces to one.
- Remove punctuation that does not change meaning.
- Keep the original text in `Description` and/or `Notes` for audit.

**Examples:**
- `"DIVIDEND RECEIVED"` → `DIVIDEND`
- `"REINVESTMENT"` → `REINVEST`
- `"TRANSFER OF ASSETS ACAT RECEIVE"` → `ACAT RECEIVE`
- `"YOU BOUGHT FIDELITY GOVERNMENT MONEY MARKET"` → `CORE SWEEP BUY` (and filtered as noise)

### Core/Sweep Noise Filter {#core-sweep-noise-filter}

Ignore (do not import) Fidelity auto-sweep/core position “trades” that simply move cash into/out of the money market core position and do not represent meaningful external activity.

**Drop** when `Description` contains:
- `YOU BOUGHT` or `YOU SOLD` **and**
- `MONEY MARKET` (including `GOVERNMENT MONEY MARKET`) **and**
- appears as part of core sweep activity.

### Action Code Classification Table {#action-code-classification-table}

The following table is the **authoritative mapping** for the importer.

**Interpretation:**
- “Post To” means which side receives the signed Amount.
- “Offset Account” is the other leg of the split.
- “Sign” indicates how to treat the cash amount provided by Fidelity:
  - `+` increases the “Post To” account balance
  - `-` decreases the “Post To” account balance
- If a row is marked “(non-cash)”, the import may set Amount to `0.00` and rely on statement reconciliation, **unless** a statement-provided value exists (e.g., ACAT totals).

| Fidelity Action (normalized) | Post To | Offset Account | Sign | Notes |
|---|---|---|---|---|
| CONTRIBUTION | :Cash | Equity:Contributions | + | Includes IRA contributions, employer contributions, etc. |
| DEPOSIT | :Cash | Equity:Contributions | + | External cash moving into Fidelity. |
| TRANSFER IN | :Cash | Equity:Contributions | + | If truly cash-in; otherwise treat as ACAT when securities. |
| WITHDRAWAL | :Cash | Equity:Withdrawals | - | External cash leaving Fidelity. |
| TRANSFER OUT | :Cash | Equity:Withdrawals | - | If truly cash-out; otherwise treat as ACAT when securities. |
| FEE | :Cash | Expenses:Investment Fees | - | Advisory, account, wire, service fees. |
| COMMISSION | :Cash | Expenses:Investment Fees | - | If present in cash activity. |
| DIVIDEND | :Cash | Income:Dividends | + | Cash dividend received. |
| DIVIDEND RECEIVED | :Cash | Income:Dividends | + | Alias of DIVIDEND. |
| QUALIFIED DIVIDEND | :Cash | Income:Dividends | + | Keep in Notes if desired. |
| REINVEST DIVIDEND | :Securities | Income:Dividends | + | Non-cash; increases securities. Amount typically equals dividend. |
| INTEREST | :Cash | Income:Interest | + | Money market / cash interest. |
| INTEREST RECEIVED | :Cash | Income:Interest | + | Alias. |
| TAX WITHHELD | :Cash | Expenses:Taxes | - | Optional bucket; if you don’t want Expenses:Taxes, use Imbalance. |
| FOREIGN TAX PAID | :Cash | Expenses:Taxes | - | Optional. |
| ACAT RECEIVE | :Securities | Equity:ACAT Shares | + | Prefer statement summary “Securities Transferred In/Out” totals. |
| ACAT DELIVER | :Securities | Equity:ACAT Shares | - | Prefer statement summary totals. |
| SECURITIES TRANSFERRED IN | :Securities | Equity:ACAT Shares | + | Use statement-provided totals if available; else marker. |
| SECURITIES TRANSFERRED OUT | :Securities | Equity:ACAT Shares | - | Use statement-provided totals if available; else marker. |
| TRANSFER OF ASSETS | :Securities | Equity:ACAT Shares | +/- | Normalize to ACAT RECEIVE/DELIVER based on wording. |
| BUY | (ignored) | (ignored) | n/a | In macro method, trades are not imported; valuation handled by Market Change. |
| SELL | (ignored) | (ignored) | n/a | Same as BUY. |
| EXCHANGE | (ignored) | (ignored) | n/a | Treat as non-cash security change; rely on reconciliation. |
| MERGER | :Securities | Income:Market Change | 0 | Non-cash; use Notes; reconciliation will carry valuation effect. |
| SPINOFF | :Securities | Income:Market Change | 0 | Non-cash; reconciliation carries effect. |
| STOCK SPLIT | :Securities | Income:Market Change | 0 | Non-cash; reconciliation carries effect. |
| DIVIDEND (SHARES) | :Securities | Income:Dividends | + | If statement provides a value; else treat as marker. |
| OPTIONS ASSIGN | (ignored) | (ignored) | n/a | If you trade options, expand this table (future enhancement). |
| OPTIONS EXPIRE | (ignored) | (ignored) | n/a | Future enhancement. |
| JOURNAL | :Cash | Imbalance-USD | +/- | Catch-all; keep description; refine later. |
| ADJUSTMENT | :Cash | Imbalance-USD | +/- | Catch-all; reconcile via Market Change if needed. |

**Important:** If an action can be both “cash” and “security” depending on context (e.g., TRANSFER), use keyword checks:
- If the line contains `ACAT`, `SECURITIES`, `TRANSFER OF ASSETS`, treat as **Securities** movement.
- Otherwise treat as **Cash** movement.

### Valued ACAT Rule {#valued-acat-rule}

When statements provide net ACAT totals on an account summary page (preferred):

- `net_acat = Securities Transferred In - Securities Transferred Out`
- Post a **single valued** entry per `(acct, period_end)`:

- Post To: `...:Securities`
- Offset: `Equity:ACAT Shares`
- Amount: `net_acat`

This prevents double-counting individual per-security “ACAT RECEIVE” lines, which may show `-` in the Amount column.

### Reconciliation Priority Rule {#reconciliation-priority-rule}

When both detailed activity and summary totals exist, prioritize in this order:

1. **Account Summary begin/end values** for reconciliation
2. **Account Summary ACAT totals** for valued ACAT posting
3. **Cash activity tables** for deposits/withdrawals/dividends/fees
4. Everything else becomes either:
   - a marker (Amount 0.00), or
   - filtered (core sweep), or
   - ignored (BUY/SELL) under macro accounting

### Determinism Guarantees {#determinism-guarantees}

A compliant importer must ensure:

- Each `(acct, statement_end_date)` produces at most:
  - one valued ACAT entry, and
  - one Market Change reconcile entry
- `delta_after` in the reconcile report is approximately `0.00` for every account and statement period.
- Securities accounts are **postable** (not placeholders) so ACAT and Market Change entries are accepted by GnuCash.
