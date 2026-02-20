---
date: 2026-02-20
layout: post
tags:
- gnucash
- sqlite
- db-browser
- accounting
- sql
title: GnuCash SQLite Master SQL Template (Safe Bulk Editing Guide)
---

# GnuCash SQLite Master SQL Template {#top}

A reusable, **GnuCash-safe SQL workflow** for DB Browser for SQLite.

This guide follows a strict safety pattern:

1.  Preview\
2.  Count\
3.  BEGIN TRANSACTION\
4.  Update\
5.  Verify\
6.  COMMIT (or ROLLBACK)

------------------------------------------------------------------------

# Safety Rules

-   Always back up your `.gnucash` file first.
-   Prefer moving splits (`splits.account_guid`) over editing amounts.
-   Never update without previewing the exact candidate set.
-   If anything looks wrong → `ROLLBACK;`

------------------------------------------------------------------------

# Find Accounts (With Full Path) {#find-accounts}

``` sql
WITH RECURSIVE acct_tree AS (
  SELECT guid, name, parent_guid, name AS full_name
  FROM accounts
  WHERE parent_guid IS NULL OR parent_guid = ''
  UNION ALL
  SELECT a.guid, a.name, a.parent_guid,
         (t.full_name || ':' || a.name) AS full_name
  FROM accounts a
  JOIN acct_tree t ON a.parent_guid = t.guid
)
SELECT full_name, guid, account_type
FROM acct_tree
ORDER BY full_name;
```

------------------------------------------------------------------------

# Preview Candidate Transactions {#preview-transactions}

``` sql
SELECT
  t.guid,
  datetime(t.post_date, 'unixepoch', 'localtime') AS post_date,
  t.description,
  t.num
FROM transactions t
WHERE lower(t.description) LIKE lower('%YOUR_MATCH_TEXT%')
ORDER BY t.post_date DESC
LIMIT 200;
```

------------------------------------------------------------------------

# Preview Splits That Would Move {#preview-splits}

``` sql
SELECT
  t.guid        AS txn_guid,
  datetime(t.post_date, 'unixepoch', 'localtime') AS post_date,
  t.description,
  s.guid        AS split_guid,
  a.name        AS current_account,
  s.memo,
  s.reconcile_state,
  s.value_num, s.value_denom
FROM transactions t
JOIN splits s   ON s.tx_guid = t.guid
JOIN accounts a ON a.guid = s.account_guid
WHERE t.description LIKE '%YOUR_MATCH_TEXT%'
  AND s.account_guid = 'FROM_ACCT_GUID'
ORDER BY t.post_date DESC
LIMIT 500;
```

------------------------------------------------------------------------

# Count Before Updating {#count-before}

``` sql
SELECT COUNT(*) AS splits_to_move
FROM splits s
JOIN transactions t ON t.guid = s.tx_guid
WHERE t.description LIKE '%YOUR_MATCH_TEXT%'
  AND s.account_guid = 'FROM_ACCT_GUID';
```

------------------------------------------------------------------------

# Safe Update Template {#safe-update}

``` sql
BEGIN TRANSACTION;

DROP TABLE IF EXISTS temp_splits_to_move;

CREATE TEMP TABLE temp_splits_to_move AS
SELECT s.guid AS split_guid
FROM splits s
JOIN transactions t ON t.guid = s.tx_guid
WHERE t.description LIKE '%YOUR_MATCH_TEXT%'
  AND s.account_guid = 'FROM_ACCT_GUID';

UPDATE splits
SET account_guid = 'TO_ACCT_GUID'
WHERE guid IN (SELECT split_guid FROM temp_splits_to_move);

SELECT changes() AS splits_updated;

/* Verify before committing */
SELECT COUNT(*) AS remaining_in_from
FROM splits s
JOIN transactions t ON t.guid = s.tx_guid
WHERE t.description LIKE '%YOUR_MATCH_TEXT%'
  AND s.account_guid = 'FROM_ACCT_GUID';

-- COMMIT;
-- ROLLBACK;
```

------------------------------------------------------------------------

# Bulk Description Cleanup {#bulk-description}

``` sql
BEGIN TRANSACTION;

UPDATE transactions
SET description = replace(description,
    'OFX ext. info: |Trans type:Generic debit', '')
WHERE description LIKE '%OFX ext. info: |Trans type:Generic debit%';

SELECT changes();

-- COMMIT;
-- ROLLBACK;
```

------------------------------------------------------------------------

# Date Range Filter Example {#date-range}

``` sql
WHERE t.post_date >= strftime('%s','2025-01-01')
  AND t.post_date <  strftime('%s','2026-01-01')
```

------------------------------------------------------------------------

# Reconciliation Safety Filter {#reconcile-filter}

``` sql
AND (s.reconcile_state IS NULL OR s.reconcile_state IN ('n','c'))
```

------------------------------------------------------------------------

# Integrity Checks

``` sql
SELECT COUNT(*) AS splits_missing_tx
FROM splits s
LEFT JOIN transactions t ON t.guid = s.tx_guid
WHERE t.guid IS NULL;

SELECT COUNT(*) AS splits_missing_account
FROM splits s
LEFT JOIN accounts a ON a.guid = s.account_guid
WHERE a.guid IS NULL;
```

------------------------------------------------------------------------

# Final Reminder

Preview first.\
Count second.\
Transaction wrap everything.\
Verify like a paranoid accountant.\
Then --- and only then --- `COMMIT;`
