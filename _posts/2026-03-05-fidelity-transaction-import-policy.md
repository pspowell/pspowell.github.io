---
date: 2026-03-05
layout: post
tags:
- fidelity
- gnucash
- accounting
- automation
title: Fidelity Transaction Import Policy (Rollup Model)
---

# Fidelity Transaction Import Policy (Rollup Model) {#overview}

## Scope

This policy defines how **Fidelity transaction exports (CSV/XLS/XLSX)**
should be interpreted when generating **monthly rollups for GnuCash**.

The goal is to produce **clean macro-level accounting entries** while
ignoring internal trade activity.

The system assumes the **statements (PDF)** define the authoritative
portfolio value.\
Transaction exports are used only to identify **true cash flows**.

------------------------------------------------------------------------

# 1. Trades MUST be ignored {#trades-ignore}

Most rows in Fidelity exports represent the **cash leg of a trade**, not
an actual movement of money.

These must **never be treated as deposits, withdrawals, or fees**.

Ignore rows where the action or description contains:

    YOU BOUGHT
    YOU SOLD
    REINVEST
    REINVESTMENT
    DIVIDEND REINVEST
    DIV REINV
    DISTRIBUTION (when tied to a security name)
    SPLIT
    SPIN-OFF
    MERGER
    TENDER
    CALL
    ASSIGNMENT
    EXCHANGE

Examples:

    YOU SOLD NVIDIA CORPORATION COM
    YOU BOUGHT FIDELITY GOVERNMENT MONEY MARKET
    DIVIDEND REINVESTMENT

Reason:

These are internal portfolio transactions already embedded in the
**begin/end portfolio values**.

------------------------------------------------------------------------

# 2. Money market sweeps MUST be ignored {#money-market-sweeps}

Fidelity frequently sweeps cash into and out of the money market.

Examples:

    YOU BOUGHT FIDELITY GOVERNMENT MONEY MARKET
    YOU SOLD FIDELITY GOVERNMENT MONEY MARKET
    CASH YOU BOUGHT

These are **not deposits, withdrawals, or fees** and must be ignored.

------------------------------------------------------------------------

# 3. ACAT transfers are not income or contributions {#acat-transfers}

Rows containing:

    ACAT
    TRANSFER OF ASSETS
    ACAT RECEIVE
    ACAT DELIVER

represent a **transfer of securities between brokers**.

These should **not create income, expense, or equity entries**.

If the external broker is not tracked in GnuCash, **ignore ACAT rows
entirely**.

------------------------------------------------------------------------

# 4. Only three transaction categories are allowed {#transaction-categories}

All remaining rows must map into exactly one of these categories.

## 4.1 External Deposits {#deposits}

Map to:

    Equity:Contributions

Examples:

    CONTRIBUTION
    DEPOSIT
    TRANSFER IN
    DIRECT DEPOSIT
    ROLLOVER CONTRIBUTION
    EFT RECEIVED

These represent **real money entering Fidelity from outside**.

------------------------------------------------------------------------

## 4.2 External Withdrawals {#withdrawals}

Map to:

    Equity:Withdrawals

Examples:

    WITHDRAWAL
    TRANSFER OUT
    CHECK
    DEBIT
    PAYMENT
    EFT PAID
    ELECTRONIC FUNDS TRANSFER PAID

These represent **money leaving Fidelity**.

------------------------------------------------------------------------

## 4.3 Fees

Map to:

    Expenses:Investment Fees

Examples:

    ADVISORY FEE
    MANAGEMENT FEE
    ACCOUNT SERVICE FEE
    WIRE FEE
    MARGIN INTEREST

Fees should generally be **small relative to account value**.

------------------------------------------------------------------------

# 5. Dividends and Interest {#dividends-interest}

Dividends and interest are typically more reliable in **statements**,
but when detected in transaction exports:

Map to:

    Income:Dividends
    Income:Interest

------------------------------------------------------------------------

# 6. Market Change must be calculated from balances {#market-change}

Investment performance must **never be inferred from trade cash flows**.

Instead compute:

    MarketChange =
      EndingValue
    - BeginningValue
    - Deposits
    - Withdrawals
    - Dividends
    - Interest
    + Fees
    + Taxes

Where **BeginningValue and EndingValue come from statements**.

------------------------------------------------------------------------

# 7. Sanity checks (critical) {#sanity-checks}

Any automated system must flag these anomalies.

## Fee sanity

Monthly fees greater than:

    $10,000

are almost certainly misclassified trades.

------------------------------------------------------------------------

## Deposit / withdrawal sanity

Large deposits or withdrawals that correspond to:

    YOU SOLD
    YOU BOUGHT

indicate trade cash was incorrectly classified.

------------------------------------------------------------------------

## Market change sanity

If:

    MarketChange ≈ Portfolio Value

then the script likely parsed:

    BeginningBalance = 0

incorrectly.

------------------------------------------------------------------------

# 8. Priority order of data sources {#data-priority}

When generating accounting rollups:

1.  **Statement PDFs (authoritative)**
    -   Beginning value\
    -   Ending value\
    -   Change in investment value
2.  **Transaction exports**\
    Used only to identify:
    -   deposits
    -   withdrawals
    -   fees
3.  **Trades**\
    Ignored.

------------------------------------------------------------------------

# 9. Expected result

Correct implementation should produce:

-   Clean monthly journal entries
-   No million-dollar "fees"
-   Market change matching statement performance
-   Assets matching Fidelity statement totals
