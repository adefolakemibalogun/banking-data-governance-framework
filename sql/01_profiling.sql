-- =====================================================================
-- Profiling: understand the data before writing rules.
-- Run each query and record the observations in the CDE register and issue log.
-- =====================================================================

-- Row counts, distinct keys and null keys per table
SELECT 'customer_account' AS tbl, COUNT(*) AS rows_, COUNT(DISTINCT customer_id) AS distinct_customers,
       COUNT(DISTINCT account_id) AS distinct_accounts, SUM(account_id IS NULL) AS rows_without_account
FROM customer_account;

SELECT 'transactions' AS tbl, COUNT(*) AS rows_, COUNT(DISTINCT transaction_id) AS distinct_ids,
       SUM(transaction_date IS NULL) AS null_dates, MIN(transaction_date) AS first_date, MAX(transaction_date) AS last_date
FROM transactions;

SELECT 'loans' AS tbl, COUNT(*) AS rows_, COUNT(DISTINCT loan_id) AS distinct_ids,
       SUM(start_date IS NULL) AS null_start_dates
FROM loans;

-- Value ranges for numeric fields
SELECT MIN(account_balance), MAX(account_balance), SUM(account_balance < 0) AS negative_balances
FROM customer_account;
SELECT MIN(amount), MAX(amount) FROM transactions;
SELECT MIN(principal_amount), MAX(principal_amount), MIN(interest_rate), MAX(interest_rate) FROM loans;

-- Domain values for coded fields
SELECT account_status, COUNT(*) FROM customer_account GROUP BY account_status;
SELECT transaction_type, COUNT(*) FROM transactions GROUP BY transaction_type;
SELECT loan_status, COUNT(*) FROM loans GROUP BY loan_status;

-- Volume by year: shows the complete 2020-2023 window and sparse later records
SELECT transaction_year, COUNT(*) AS transactions, ROUND(SUM(amount), 2) AS value
FROM transactions GROUP BY transaction_year ORDER BY transaction_year;

-- Physical type of identifiers in each table (reveals the text/integer mismatch)
SELECT typeof(account_id), typeof(customer_id), COUNT(*) FROM loans GROUP BY 1, 2;
SELECT typeof(account_id), typeof(customer_id), COUNT(*) FROM customer_account
WHERE account_id IS NOT NULL GROUP BY 1, 2;

-- Reconciliation to the published case study totals
SELECT COUNT(DISTINCT customer_id) AS customers, COUNT(account_id) AS accounts,
       ROUND(SUM(account_balance), 2) AS total_balance
FROM customer_account;   -- expect 1,100 / 1,651 / 81,036,977.59
SELECT ROUND(SUM(principal_amount), 2) AS loan_portfolio FROM loans;   -- expect 17,087,413.80
