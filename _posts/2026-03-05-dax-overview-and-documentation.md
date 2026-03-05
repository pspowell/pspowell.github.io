---
layout: post
title: "DAX Explained (Data Analysis Expressions)"
date: 2026-03-05
tags: [excel, powerpivot, dax, powerbi, data-model]
---

## What DAX Is {#what-is-dax}

**DAX (Data Analysis Expressions)** is the formula language used in the **Excel Data Model / Power Pivot** and in Microsoft Power BI.

It is designed for **analyzing tabular data** stored in the **Excel Data Model**.

You can think of DAX as a hybrid of:

- Excel formulas
- SQL-style aggregation
- Database calculations

But it is **column-based and context-aware**, which makes it extremely powerful for analytics.

---

## Where DAX Is Used {#where-dax-is-used}

DAX is used in:

- **Microsoft Excel** (Power Pivot / Data Model)
- **Microsoft Power BI**
- **SQL Server Analysis Services (Tabular mode)**

If you check **“Add this data to the Data Model”** in Excel, you can start using **DAX measures and calculated columns**.

---

## The Two Main Things You Write in DAX {#two-main-dax-objects}

### 1. Measures (Most Important) {#dax-measures}

Measures are **dynamic calculations used in PivotTables**.

Example:

```DAX
Total Amount := SUM(Transactions[Amount])
```

If placed in a PivotTable:

| Account | Total Amount |
|--------|-------------|
IRA | $52,000 |
Investment | $141,000 |

The result **changes automatically depending on filters**.

Example filtered by symbol:

| Symbol | Total Amount |
|--------|-------------|
AAPL | $10,000 |
NVDA | $5,200 |

The **same measure** recalculates automatically.

---

### 2. Calculated Columns {#calculated-columns}

These compute **values row-by-row**, similar to Excel formulas.

Example:

```DAX
Year := YEAR(Transactions[Date])
```

Resulting table:

| Date | Year |
|-----|-----|
1/4/2023 | 2023 |

---

## Example DAX You Might Use (Fidelity Workbook) {#dax-fidelity-examples}

### Total Dividends

```DAX
Total Dividends :=
CALCULATE(
    SUM(Transactions[Amount]),
    Transactions[Category] = "Dividend"
)
```

---

### Total Deposits

```DAX
Total Deposits :=
CALCULATE(
    SUM(Transactions[Amount]),
    Transactions[Category] = "Deposit"
)
```

---

### Net Cash Flow

```DAX
Net Cash Flow :=
SUM(Transactions[Amount])
```

---

## Why DAX Is Powerful {#why-dax-is-powerful}

Unlike Excel formulas, DAX understands **filter context**.

Example Pivot:

| Year | Dividends |
|-----|-----------|
2022 | $1,230 |
2023 | $1,640 |

The same measure automatically recalculates when filtered by:

- year
- symbol
- account
- sector
- transaction type

No separate formulas needed.

---

## Key Concepts in DAX {#dax-key-concepts}

### Filter Context {#filter-context}

Filter context represents **what rows are currently visible to the calculation**.

Example:

Pivot filter:

```
Symbol = NVDA
```

DAX only calculates from NVDA rows.

---

### Row Context {#row-context}

Used for **calculated columns**, where formulas run row-by-row.

---

### Relationships {#relationships}

DAX can combine tables through relationships:

```
Transactions → Securities
Transactions → Accounts
```

This is why the **Data Model** is powerful.

---

## Official Microsoft Documentation {#official-docs}

**DAX Overview**

https://learn.microsoft.com/en-us/dax/dax-overview

**DAX Function Reference**

https://learn.microsoft.com/en-us/dax/dax-function-reference

---

## Best Learning Reference Site {#dax-guide}

A widely used professional reference:

https://dax.guide

This site lists **every DAX function with examples**.

---

## Common DAX Functions {#common-dax-functions}

| Function | Purpose |
|--------|--------|
SUM | Add values |
CALCULATE | Modify filters |
FILTER | Create filtered tables |
RELATED | Pull data from related tables |
COUNTROWS | Count rows |
YEAR | Extract year |

---

## Important Insight for Investment Tracking {#investment-insight}

For many investment workflows, you may **not even need DAX initially**.

A strong workflow often uses:

- **Power Query for transformation**
- **Excel PivotTables for reporting**

DAX becomes useful when you want:

- portfolio dashboards
- time intelligence
- rolling performance
- advanced financial metrics

