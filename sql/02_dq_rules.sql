-- =====================================================================
-- Banking Data Governance Framework: data-quality rules
-- Each rule returns one row: records_tested, records_failed.
-- Reporting date for status checks: 2023-12-31 (end of the governed
-- 2020-2023 reporting window). Written for SQLite; portable to MySQL
-- with minor date-function changes.
-- Rule metadata (dimension, CDE, threshold, owner) is in docs/dq_rules.csv.
-- =====================================================================

-- DQ01 | Uniqueness | transactions.transaction_id is unique
SELECT COUNT(*) AS records_tested,
       COUNT(*) - COUNT(DISTINCT transaction_id) AS records_failed
FROM transactions;

-- DQ02 | Completeness | transactions.transaction_date is populated
SELECT COUNT(*) AS records_tested,
       SUM(transaction_date IS NULL) AS records_failed
FROM transactions;

-- DQ03 | Validity | transactions.amount is greater than zero
SELECT COUNT(*) AS records_tested,
       SUM(amount IS NULL OR amount <= 0) AS records_failed
FROM transactions;

-- DQ04 | Timeliness | dated transactions fall inside the governed 2020-2023 reporting window
SELECT COUNT(*) AS records_tested,
       SUM(transaction_date NOT BETWEEN '2020-01-01' AND '2023-12-31') AS records_failed
FROM transactions
WHERE transaction_date IS NOT NULL;

-- DQ05 | Consistency | derived year and month agree with transaction_date
SELECT COUNT(*) AS records_tested,
       SUM(CAST(substr(transaction_date, 1, 4) AS INTEGER) <> transaction_year
           OR CAST(substr(transaction_date, 6, 2) AS INTEGER) <> transaction_month) AS records_failed
FROM transactions
WHERE transaction_date IS NOT NULL;

-- DQ06 | Uniqueness | account_id appears once in the account master
SELECT COUNT(*) AS records_tested,
       COUNT(*) - COUNT(DISTINCT account_id) AS records_failed
FROM customer_account
WHERE account_id IS NOT NULL;

-- DQ07 | Completeness | every account has an opening_date
SELECT COUNT(*) AS records_tested,
       SUM(opening_date IS NULL) AS records_failed
FROM customer_account
WHERE account_id IS NOT NULL;

-- DQ08 | Validity | account_balance is not negative
SELECT COUNT(*) AS records_tested,
       SUM(account_balance < 0) AS records_failed
FROM customer_account
WHERE account_id IS NOT NULL;

-- DQ09 | Consistency | closed accounts carry a zero balance
SELECT COUNT(*) AS records_tested,
       SUM(account_balance <> 0) AS records_failed
FROM customer_account
WHERE account_status = 'Closed';

-- DQ10 | Completeness | every customer holds at least one account (monitored, not an error)
SELECT COUNT(DISTINCT customer_id) AS records_tested,
       COUNT(DISTINCT CASE WHEN account_id IS NULL THEN customer_id END) AS records_failed
FROM customer_account;

-- DQ11 | Consistency | each customer has a single customer_type
SELECT COUNT(*) AS records_tested,
       SUM(n_types > 1) AS records_failed
FROM (SELECT customer_id, COUNT(DISTINCT customer_type) AS n_types
      FROM customer_account GROUP BY customer_id);

-- DQ12 | Referential integrity | every loan links to an account in the account master
SELECT COUNT(*) AS records_tested,
       SUM(a.account_id IS NULL) AS records_failed
FROM loans l
LEFT JOIN customer_account a ON a.account_id = CAST(l.account_id AS INTEGER);

-- DQ13 | Consistency | loan customer matches the account owner
SELECT COUNT(*) AS records_tested,
       SUM(a.customer_id <> CAST(l.customer_id AS INTEGER)) AS records_failed
FROM loans l
JOIN customer_account a ON a.account_id = CAST(l.account_id AS INTEGER);

-- DQ14 | Completeness | loan start_date is populated
SELECT COUNT(*) AS records_tested,
       SUM(start_date IS NULL) AS records_failed
FROM loans;

-- DQ15 | Validity | estimated_end_date is after start_date
SELECT COUNT(*) AS records_tested,
       SUM(estimated_end_date <= start_date) AS records_failed
FROM loans
WHERE start_date IS NOT NULL;

-- DQ16 | Consistency | loan starts on or after the account opening date
SELECT COUNT(*) AS records_tested,
       SUM(l.start_date < a.opening_date) AS records_failed
FROM loans l
JOIN customer_account a ON a.account_id = CAST(l.account_id AS INTEGER)
WHERE l.start_date IS NOT NULL AND a.opening_date IS NOT NULL;

-- DQ17 | Consistency | no active or overdue loans sit on closed accounts
SELECT COUNT(*) AS records_tested,
       SUM(a.account_status = 'Closed') AS records_failed
FROM loans l
JOIN customer_account a ON a.account_id = CAST(l.account_id AS INTEGER)
WHERE l.loan_status IN ('Active', 'Overdue');

-- DQ18 | Timeliness | active loans are not past their estimated end date at 2023-12-31
SELECT COUNT(*) AS records_tested,
       SUM(estimated_end_date < '2023-12-31') AS records_failed
FROM loans
WHERE loan_status = 'Active';

-- DQ19 | Conformity | loan identifiers use the same numeric type as the account master
SELECT COUNT(*) AS records_tested,
       SUM(typeof(account_id) <> 'integer' OR typeof(customer_id) <> 'integer') AS records_failed
FROM loans;

-- DQ20 | Validity | interest_rate is within the approved 1%-25% range
SELECT COUNT(*) AS records_tested,
       SUM(interest_rate NOT BETWEEN 0.01 AND 0.25) AS records_failed
FROM loans;
