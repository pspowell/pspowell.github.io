---
layout: post
title: "Fidelity Import Classification Table (Machine-Friendly)"
date: 2026-03-05
tags: [finance, fidelity, gnucash, imports, python, mapping]
---

## Purpose {#purpose}

This document provides a **machine-friendly mapping table** of common Fidelity activity/action strings to import handling groups for your Python → GnuCash pipeline.

It is designed to be:

- copy/pasteable into code
- easy to extend
- resilient to minor wording differences via normalization rules

---

## Normalization Rules {#normalization-rules}

Before matching, the importer should:

1. Trim whitespace
2. Convert to uppercase
3. Collapse internal whitespace to single spaces
4. Optionally remove punctuation (commas, periods) when matching
5. Match by:
   - exact key
   - then keyword/regex fallbacks

Pseudo:

```python
def norm(s: str) -> str:
    s = (s or "").strip().upper()
    s = " ".join(s.split())
    return s
```

---

## Policy Groups {#policy-groups}

Each action maps to a group plus metadata that tells the importer what to do.

- `INCOME_DIVIDEND`
- `INCOME_INTEREST`
- `INCOME_CAPGAIN_DIST`
- `REINVEST_DIVIDEND`
- `REINVEST_CAPGAIN`
- `BUY`
- `SELL`
- `TRANSFER_INTERNAL`
- `TRANSFER_EXTERNAL_IN`
- `TRANSFER_EXTERNAL_OUT`
- `ACAT_IN`
- `ACAT_OUT`
- `FEE`
- `TAX_WITHHOLDING`
- `CORP_SPLIT`
- `CORP_MERGER`
- `CORP_SPINOFF`
- `ADJUSTMENT`
- `UNKNOWN`

---

## Machine-Friendly Mapping (Python dict) {#machine-friendly-mapping-python-dict}

Use this as your first-pass classifier (exact/normalized matches).

```python
FIDELITY_ACTION_MAP = {
    # --- Income: Dividends / Distributions ---
    "DIVIDEND": {"group": "INCOME_DIVIDEND", "income_account": "Income:Investment Income:Dividends"},
    "DIVIDEND RECEIVED": {"group": "INCOME_DIVIDEND", "income_account": "Income:Investment Income:Dividends"},
    "ORDINARY DIVIDEND": {"group": "INCOME_DIVIDEND", "income_account": "Income:Investment Income:Dividends"},
    "QUALIFIED DIVIDEND": {"group": "INCOME_DIVIDEND", "income_account": "Income:Investment Income:Dividends"},
    "NON-QUALIFIED DIVIDEND": {"group": "INCOME_DIVIDEND", "income_account": "Income:Investment Income:Dividends"},
    "DIVIDEND (ORDINARY)": {"group": "INCOME_DIVIDEND", "income_account": "Income:Investment Income:Dividends"},
    "DIVIDEND (QUALIFIED)": {"group": "INCOME_DIVIDEND", "income_account": "Income:Investment Income:Dividends"},

    # Capital gain distributions (funds/ETFs)
    "LONG TERM CAPITAL GAIN DISTRIBUTION": {"group": "INCOME_CAPGAIN_DIST", "income_account": "Income:Investment Income:Capital Gains"},
    "SHORT TERM CAPITAL GAIN DISTRIBUTION": {"group": "INCOME_CAPGAIN_DIST", "income_account": "Income:Investment Income:Capital Gains"},
    "CAPITAL GAIN DISTRIBUTION": {"group": "INCOME_CAPGAIN_DIST", "income_account": "Income:Investment Income:Capital Gains"},
    "LT CAP GAIN DISTRIBUTION": {"group": "INCOME_CAPGAIN_DIST", "income_account": "Income:Investment Income:Capital Gains"},
    "ST CAP GAIN DISTRIBUTION": {"group": "INCOME_CAPGAIN_DIST", "income_account": "Income:Investment Income:Capital Gains"},

    # --- Income: Interest ---
    "INTEREST": {"group": "INCOME_INTEREST", "income_account": "Income:Investment Income:Interest"},
    "MONEY MARKET INTEREST": {"group": "INCOME_INTEREST", "income_account": "Income:Investment Income:Interest"},
    "CREDIT INTEREST": {"group": "INCOME_INTEREST", "income_account": "Income:Investment Income:Interest"},

    # --- Reinvestment ---
    "REINVEST DIVIDEND": {"group": "REINVEST_DIVIDEND"},
    "DIVIDEND REINVESTMENT": {"group": "REINVEST_DIVIDEND"},
    "REINVESTMENT": {"group": "REINVEST_DIVIDEND"},  # generic, often dividend
    "REINVEST": {"group": "REINVEST_DIVIDEND"},

    "CAPITAL GAIN REINVESTMENT": {"group": "REINVEST_CAPGAIN"},
    "REINVEST CAPITAL GAIN": {"group": "REINVEST_CAPGAIN"},

    # --- Buys / Sells ---
    "BUY": {"group": "BUY"},
    "YOU BOUGHT": {"group": "BUY"},
    "PURCHASE": {"group": "BUY"},
    "AUTOMATIC INVESTMENT": {"group": "BUY"},
    "OPENING TRANSACTION BUY": {"group": "BUY"},

    "SELL": {"group": "SELL"},
    "YOU SOLD": {"group": "SELL"},
    "REDEMPTION": {"group": "SELL"},
    "CLOSE POSITION": {"group": "SELL"},

    # --- Fees ---
    "FEE": {"group": "FEE", "expense_account": "Expenses:Investment Expenses:Fees"},
    "SERVICE FEE": {"group": "FEE", "expense_account": "Expenses:Investment Expenses:Fees"},
    "ACCOUNT FEE": {"group": "FEE", "expense_account": "Expenses:Investment Expenses:Fees"},
    "COMMISSION": {"group": "FEE", "expense_account": "Expenses:Investment Expenses:Commissions"},
    "REGULATORY FEE": {"group": "FEE", "expense_account": "Expenses:Investment Expenses:Fees"},

    # --- Taxes / Withholding (often for dividends in taxable accounts) ---
    "TAX WITHHOLDING": {"group": "TAX_WITHHOLDING"},
    "FEDERAL TAX WITHHELD": {"group": "TAX_WITHHOLDING"},
    "STATE TAX WITHHELD": {"group": "TAX_WITHHOLDING"},
    "BACKUP WITHHOLDING": {"group": "TAX_WITHHOLDING"},

    # --- Internal transfers (journal between Fidelity sub-accounts) ---
    "JOURNAL": {"group": "TRANSFER_INTERNAL"},
    "INTERNAL TRANSFER": {"group": "TRANSFER_INTERNAL"},
    "TRANSFER": {"group": "TRANSFER_INTERNAL"},

    # --- External cash movements (bank ↔ brokerage) ---
    "DEPOSIT": {"group": "TRANSFER_EXTERNAL_IN"},
    "CASH RECEIVED": {"group": "TRANSFER_EXTERNAL_IN"},
    "CONTRIBUTION": {"group": "TRANSFER_EXTERNAL_IN"},  # may be IRA contribution depending on account type

    "WITHDRAWAL": {"group": "TRANSFER_EXTERNAL_OUT"},
    "CASH DISBURSEMENT": {"group": "TRANSFER_EXTERNAL_OUT"},
    "DISTRIBUTION": {"group": "TRANSFER_EXTERNAL_OUT"},  # may be IRA distribution depending on account type

    # --- ACAT / TOA (Transfers of Assets) ---
    "ACAT RECEIVE": {"group": "ACAT_IN"},
    "TRANSFER OF ASSETS ACAT RECEIVE": {"group": "ACAT_IN"},
    "TOA ACAT RECEIVE": {"group": "ACAT_IN"},

    "ACAT DELIVER": {"group": "ACAT_OUT"},
    "TRANSFER OF ASSETS ACAT DELIVER": {"group": "ACAT_OUT"},
    "TOA ACAT DELIVER": {"group": "ACAT_OUT"},

    # --- Corporate actions ---
    "STOCK SPLIT": {"group": "CORP_SPLIT"},
    "REVERSE SPLIT": {"group": "CORP_SPLIT"},
    "MERGER": {"group": "CORP_MERGER"},
    "SPINOFF": {"group": "CORP_SPINOFF"},

    # --- Adjustments / catch-alls ---
    "ADJUSTMENT": {"group": "ADJUSTMENT"},
    "CASH ADJUSTMENT": {"group": "ADJUSTMENT"},
    "MISCELLANEOUS": {"group": "ADJUSTMENT"},
}
```

---

## Keyword / Regex Fallbacks {#keyword-regex-fallbacks}

After the dict match, apply fallbacks. This helps when Fidelity wording varies.

```python
FALLBACK_RULES = [
    # order matters
    (r"\bACAT\b.*\bRECEIVE\b", "ACAT_IN"),
    (r"\bACAT\b.*\bDELIVER\b", "ACAT_OUT"),
    (r"\bTRANSFER OF ASSETS\b.*\bRECEIVE\b", "ACAT_IN"),
    (r"\bTRANSFER OF ASSETS\b.*\bDELIVER\b", "ACAT_OUT"),

    (r"\bDIVIDEND\b", "INCOME_DIVIDEND"),
    (r"\bINTEREST\b", "INCOME_INTEREST"),
    (r"\bCAPITAL GAIN\b.*\bDISTRIBUTION\b", "INCOME_CAPGAIN_DIST"),
    (r"\bREINVEST\b", "REINVEST_DIVIDEND"),

    (r"\bYOU BOUGHT\b|\bBUY\b|\bPURCHASE\b", "BUY"),
    (r"\bYOU SOLD\b|\bSELL\b|\bREDEMPTION\b", "SELL"),

    (r"\bFEE\b|\bCOMMISSION\b|\bREGULATORY\b", "FEE"),
    (r"\bTAX\b.*\bWITHHOLD\b|\bBACKUP WITHHOLD\b", "TAX_WITHHOLDING"),

    (r"\bDEPOSIT\b|\bCASH RECEIVED\b|\bCONTRIBUTION\b", "TRANSFER_EXTERNAL_IN"),
    (r"\bWITHDRAW\b|\bDISTRIBUTION\b|\bDISBURSEMENT\b", "TRANSFER_EXTERNAL_OUT"),

    (r"\bSPLIT\b", "CORP_SPLIT"),
    (r"\bMERGER\b", "CORP_MERGER"),
    (r"\bSPINOFF\b|\bSPIN-OFF\b", "CORP_SPINOFF"),
]
```

---

## How the Importer Should Use the Group {#how-the-importer-should-use-the-group}

Recommended handling by group:

- `INCOME_*`  
  Credit income, debit brokerage cash (or directly to security if statement shows immediate reinvestment).

- `REINVEST_*`  
  Create (a) income leg and (b) buy leg. If you only have one line item, synthesize the missing leg.

- `BUY` / `SELL`  
  Use cash account as the counter-account, and record shares in the security account.

- `ACAT_*`  
  Record as asset transfer between brokerages/accounts. **No income. No gain/loss.** Preserve basis when available.

- `TRANSFER_EXTERNAL_*`  
  Record movement between brokerage cash and external account (Bank/Checking, etc.).

- `FEE`  
  Debit expense account, credit brokerage cash.

- `TAX_WITHHOLDING`  
  Treat as expense (or tax) reducing cash; link to the related dividend when possible.

- `CORP_*`  
  Share quantity adjustments. No income. Often requires custom logic (ratio, new CUSIP, etc.).

---

## Extension Points {#extension-points}

1. Add new strings observed in your exports into `FIDELITY_ACTION_MAP`.
2. Add broker-specific variants into fallback rules.
3. Emit an `unknown_actions.csv` report when no rule matches so you can iteratively improve coverage.

