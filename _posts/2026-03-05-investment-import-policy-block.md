---
layout: post
title: "Investment Accounting and Fidelity Import Policy Block"
date: 2026-03-05
tags: [finance, gnucash, fidelity, imports, accounting]
---

## Purpose {#purpose}

Define a **consistent accounting policy and automated import classification system**
for handling brokerage transactions from Fidelity into **GnuCash**.

This policy supports:

- automated CSV imports
- macro‑level investment accounting
- correct handling of dividends, reinvestments, transfers, and fees
- compatibility with Python import scripts

---

## Core Ledger Structure {#core-ledger-structure}

Primary investment structure:

Assets
:  Investments  
:    Fidelity  
:      Cash  
:      Brokerage  
:        AAPL  
:        NVDA  
:        VTI  
:      IRA

Income
:  Investment Income  
:    Dividends  
:    Interest  
:    Capital Gains

Expenses
:  Investment Expenses  
:    Fees  
:    Commissions

Equity
:  Opening Balances

---

## Brokerage Cash Policy {#brokerage-cash-policy}

All brokerage activity flows through:

```
Assets:Investments:Fidelity:Cash
```

Typical transaction flow:

security buy  
cash → security

security sale  
security → cash

dividend  
income → cash

---

## Dividend Handling Policy {#dividend-handling-policy}

Dividends are recorded as income when received.

Example:

Assets:Investments:Fidelity:Cash  +50  
Income:Investment Income:Dividends  -50

---

## Dividend Reinvestment Policy {#dividend-reinvestment-policy}

DRIP events are treated as two logical operations.

1. Dividend income
2. Share purchase

Example:

Dividend received

Assets:Investments:Fidelity:Cash +50  
Income:Investment Income:Dividends -50

Purchase

Assets:Investments:Fidelity:Brokerage:NVDA +50  
Assets:Investments:Fidelity:Cash -50

---

## Buy Transaction Policy {#buy-transaction-policy}

Security purchases move funds from cash to the security.

Example:

Assets:Investments:Fidelity:Brokerage:NVDA +5000  
Assets:Investments:Fidelity:Cash -5000

---

## Sale Transaction Policy {#sale-transaction-policy}

Security sales generate cash and may generate capital gains.

Example:

Assets:Investments:Fidelity:Cash +520  
Assets:Investments:Fidelity:Brokerage:NVDA -500  
Income:Investment Income:Capital Gains -20

---

## ACAT Transfer Policy {#acat-transfer-policy}

ACAT = Automated Customer Account Transfer.

ACAT transfers are:

- not income
- not sales
- cost basis preserved

Example:

Assets:Investments:Schwab:NVDA  -75 shares  
Assets:Investments:Fidelity:NVDA  +75 shares

---

## Fee Policy {#fee-policy}

Brokerage fees are recorded as:

Expenses:Investment Expenses:Fees

Example:

Expenses:Investment Expenses:Fees +5  
Assets:Investments:Fidelity:Cash -5

---

# Fidelity Import Policy Block {#fidelity-import-policy-block}

The Python importer must classify Fidelity activity codes according to the following rules.

## Income Transactions {#income-transactions}

DIVIDEND  
DIVIDEND RECEIVED  
ORDINARY DIVIDEND  
QUALIFIED DIVIDEND  
LONG TERM CAPITAL GAIN DISTRIBUTION  
SHORT TERM CAPITAL GAIN DISTRIBUTION  
INTEREST  
MONEY MARKET INTEREST

→ record as income

Destination account:

Income:Investment Income

Subcategory determined by type.

---

## Reinvestment Transactions {#reinvestment-transactions}

REINVEST DIVIDEND  
REINVESTMENT  
DIVIDEND REINVESTMENT  
CAPITAL GAIN REINVESTMENT

Importer logic:

1 dividend income  
2 purchase shares

---

## Buy Transactions {#buy-transactions}

BUY  
YOU BOUGHT  
PURCHASE  
OPENING TRANSACTION BUY

Importer logic:

Assets:Security increases  
Cash decreases

---

## Sell Transactions {#sell-transactions}

SELL  
YOU SOLD  
REDEMPTION  
CLOSE POSITION

Importer logic:

Cash increases  
Security decreases  
Capital gain calculated when basis available

---

## Transfer Transactions {#transfer-transactions}

TRANSFER IN  
TRANSFER OUT  
JOURNAL  
INTERNAL TRANSFER

Importer logic:

asset transfer between accounts

No income recognized.

---

## ACAT Transactions {#acat-transactions}

ACAT RECEIVE  
ACAT DELIVER  
TRANSFER OF ASSETS ACAT RECEIVE  
TRANSFER OF ASSETS ACAT DELIVER

Importer logic:

security transfer between broker accounts

No gain/loss.

---

## Cash Movement Transactions {#cash-movement-transactions}

DEPOSIT  
CASH RECEIVED  
CONTRIBUTION

WITHDRAWAL  
CASH DISBURSEMENT  
DISTRIBUTION

Importer logic:

transfer between brokerage and external account.

---

## Fee Transactions {#fee-transactions}

FEE  
SERVICE FEE  
ACCOUNT FEE  
COMMISSION  
REGULATORY FEE

Importer logic:

Expenses:Investment Expenses:Fees

---

## Corporate Action Transactions {#corporate-actions}

STOCK SPLIT  
REVERSE SPLIT  
MERGER  
SPINOFF

Importer logic:

adjust share quantities without income.

---

## Import Script Design Rules {#import-script-design-rules}

The Python importer should:

1 Normalize action text to uppercase.
2 Use keyword pattern matching.
3 Map activity types to policy groups.
4 Generate balanced GnuCash transactions.
5 Preserve share quantities.
6 Log unknown transaction types.

Unknown activity types should be written to an **exception report** for manual classification.

---

## Import Philosophy {#import-philosophy}

GnuCash is used for:

- account balances
- investment income reporting
- tax preparation support

Detailed portfolio analytics remain within Fidelity.

