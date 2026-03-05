---
date: 2026-03-05
layout: post
tags:
- fidelity
- gnucash
- excel
- powerquery
- accounting
title: An Excel power query for Fidelity csv exports
---

## Overview

This workbook provides an automated workflow for transforming **Fidelity
transaction history CSV exports** into structured data suitable for
**GnuCash import or further processing**.

The workbook uses:

-   **Excel Power Query**
-   A **table-driven rules engine**
-   A configurable **Transfer Account mapping**
-   A CSV export pipeline that can feed accounting systems.

The workbook is available here:

[Download the workbook](/assets/Fidelity Activity Export.xlsx)

------------------------------------------------------------------------

## What the Workbook Does

The workbook:

1.  Loads a Fidelity **transaction history CSV**
2.  Normalizes the **Action** field
3.  Applies classification rules from a rules table
4.  Assigns:

-   Group
-   GroupDetail
-   Transfer Account

5.  Produces structured output suitable for:

-   GnuCash CSV import
-   auditing brokerage activity
-   automation scripts

------------------------------------------------------------------------

## Workbook Structure

The workbook contains several important components.

### File Path Table

Table name:

    pq_file_path

Columns:

  Column
  --------
  Path

Example value:

    C:\Users\Preston\Downloads\2021 Accounts_History.csv

Power Query reads this path to load the Fidelity CSV.

To process a different file, simply change the value in this cell.

------------------------------------------------------------------------

### Classification Rules Table

Table name:

    pq_rules

Columns:

  Column            Purpose
  ----------------- --------------------------------------------
  Priority          rule evaluation order
  MatchType         EQUALS or CONTAINS
  Pattern           text to match against the Action field
  Group             high-level classification
  GroupDetail       detailed classification
  TransferAccount   suggested opposite account for bookkeeping

Rules are evaluated **top-to-bottom by Priority**.

The first matching rule is applied.

This allows rules to be modified without changing Power Query code.

------------------------------------------------------------------------

## Transaction Classification

Each transaction is assigned:

  Column             Meaning
  ------------------ -----------------------------
  Group              main transaction category
  GroupDetail        finer classification
  Transfer Account   suggested balancing account

Examples:

  ----------------------------------------------------------------------------------
  Action                  Group                   Transfer Account
  ----------------------- ----------------------- ----------------------------------
  Dividend Received       INCOME_DIVIDEND         Income:Investment Income:Dividends

  Reinvest Dividend       REINVEST_DIVIDEND       Income:Investment Income:Dividends

  You Bought              BUY                     Assets:Investments:Fidelity:Cash

  You Sold                SELL                    Assets:Investments:Fidelity:Cash

  Transfer Of Assets ACAT ACAT_IN                 Assets:Investments:Other Brokerage
  Receive                                         

  Fee                     FEE                     Expenses:Investment Expenses:Fees
  ----------------------------------------------------------------------------------

------------------------------------------------------------------------

## How to Use the Workbook

### Step 1 --- Export Fidelity History

Export the **Account History CSV** from Fidelity.

Typical file name:

    2021 Accounts_History.csv

------------------------------------------------------------------------

### Step 2 --- Update File Path

Open the workbook.

In the `pq_file_path` table, paste the full path to the CSV file.

------------------------------------------------------------------------

### Step 3 --- Refresh the Query

Use:

    Data → Refresh All

Power Query will:

-   load the CSV
-   classify transactions
-   output structured rows

------------------------------------------------------------------------

### Step 4 --- Review Results

Check the output table for:

-   `Group`
-   `GroupDetail`
-   `Transfer Account`

If a row shows:

    UNKNOWN

add a rule to the `pq_rules` table.

------------------------------------------------------------------------

## Editing Classification Rules

The rules table allows easy customization.

To add a rule:

1.  Insert a new row
2.  Set a **Priority**
3.  Choose **CONTAINS** or **EQUALS**
4.  Enter the **Pattern**
5.  Define the resulting Group and TransferAccount

Example:

  ------------------------------------------------------------------------------------
  Priority       MatchType      Pattern        Group               TransferAccount
  -------------- -------------- -------------- ------------------- -------------------
  20             CONTAINS       REINVEST       REINVEST_DIVIDEND   Income:Investment
                                                                   Income:Dividends

  ------------------------------------------------------------------------------------

------------------------------------------------------------------------

## Accounting Model

The rules assume a **brokerage cash hub model**.

Example accounts:

    Assets:Investments:Fidelity:Cash
    Income:Investment Income:Dividends
    Income:Investment Income:Interest
    Income:Investment Income:Capital Gains
    Expenses:Investment Expenses:Fees
    Assets:Checking
    Assets:Investments:Other Brokerage

This structure works well with **GnuCash investment accounting**.

------------------------------------------------------------------------

## Extending the System

The workbook can be expanded to include:

-   Symbol-based classification rules
-   automatic GnuCash import CSV generation
-   price extraction
-   dividend reporting
-   portfolio summaries

Because the system is **table-driven**, most customization requires **no
Power Query edits**.

------------------------------------------------------------------------

## Why This Approach Works

Advantages:

-   consistent classification
-   reusable rules engine
-   editable logic without code
-   reliable import into accounting systems

This makes the workbook a practical bridge between **brokerage exports
and double-entry accounting systems**.
