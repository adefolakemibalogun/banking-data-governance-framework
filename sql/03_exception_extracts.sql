-- =====================================================================
-- Record-level exception extracts for failed rules.
-- Each query returns: record_id, detail. Used by scripts/extract_exceptions.py
-- to build the work queue that data stewards remediate.
-- =====================================================================

-- DQ02 | transactions missing a date
SELECT transaction_id AS record_id, 'amount=' || amount || ', type=' || transaction_type AS detail
FROM transactions WHERE transaction_date IS NULL;

-- DQ04 | transactions outside the governed reporting window
SELECT transaction_id, 'date=' || transaction_date
FROM transactions WHERE transaction_date NOT BETWEEN '2020-01-01' AND '2023-12-31';

-- DQ07 | accounts with no opening date
SELECT account_id, 'status=' || account_status || ', balance=' || account_balance
FROM customer_account WHERE account_id IS NOT NULL AND opening_date IS NULL;

-- DQ08 | accounts with a negative balance
SELECT account_id, 'status=' || account_status || ', balance=' || account_balance
FROM customer_account WHERE account_balance < 0;

-- DQ09 | closed accounts still holding a balance
SELECT account_id, 'balance=' || account_balance
FROM customer_account WHERE account_status = 'Closed' AND account_balance <> 0;

-- DQ14 | loans with no start date
SELECT loan_id, 'status=' || loan_status || ', principal=' || principal_amount
FROM loans WHERE start_date IS NULL;

-- DQ15 | loans that end before they start
SELECT loan_id, 'start=' || start_date || ', end=' || estimated_end_date
FROM loans WHERE start_date IS NOT NULL AND estimated_end_date <= start_date;

-- DQ16 | loans that start before the account was opened
SELECT l.loan_id, 'loan_start=' || l.start_date || ', account_opened=' || a.opening_date
FROM loans l JOIN customer_account a ON a.account_id = CAST(l.account_id AS INTEGER)
WHERE l.start_date < a.opening_date;

-- DQ17 | active or overdue loans on closed accounts
SELECT l.loan_id, 'loan_status=' || l.loan_status || ', account_id=' || a.account_id
FROM loans l JOIN customer_account a ON a.account_id = CAST(l.account_id AS INTEGER)
WHERE l.loan_status IN ('Active', 'Overdue') AND a.account_status = 'Closed';

-- DQ18 | active loans past their estimated end date at 2023-12-31
SELECT loan_id, 'end=' || estimated_end_date || ', principal=' || principal_amount
FROM loans WHERE loan_status = 'Active' AND estimated_end_date < '2023-12-31';
