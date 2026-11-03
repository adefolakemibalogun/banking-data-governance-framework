# Data-Quality Issue Log

Issues raised from the failed rules in [`results/dq_scorecard.csv`](../results/dq_scorecard.csv). Every issue has an accountable owner, a likely cause and a remediation action. Because the dataset is synthetic, the likely causes are hypotheses to confirm with the owner, not established facts.

Reporting date for status checks: **31 December 2023**.

| ID | Rule | What was found | Impact | Likely cause | Owner | Remediation | Priority |
|---|---|---|---|---|---|---|---|
| ISS-01 | DQ09 | All **74 closed accounts** still hold a balance, totalling **£4.29M**. | Closed balances can inflate live-balance KPIs, and unswept customer funds are a conduct risk. | The closure process changes status without sweeping or transferring the balance. | Head of Retail Operations | Confirm each balance with Finance, sweep or return funds, and add a zero-balance check to the closure workflow. Exclude closed accounts from live-balance KPIs until fixed. | High |
| ISS-02 | DQ18 | **48 Active loans** (£2.44M principal) are past their estimated end date. | Status is stale, so overdue exposure may be understated. | Loan status isn't refreshed at maturity. | Head of Credit Risk | Review each loan, reclassify as Paid Off, Overdue or Extended, and add a maturity-date status job. | High |
| ISS-03 | DQ17 | **9 Active loans** (£0.39M principal) sit on **closed accounts**. | Live credit is attached to an account that can't receive repayments. | The account was closed without checking for linked live loans. | Head of Credit Risk | Re-link loans to an open account or correct the account status. Block closure while live loans exist. | High |
| ISS-04 | DQ02 | **990 transactions** (2.0%, £2.47M) have **no transaction date**. | They can't be assigned to a period, so they're excluded from trends and the value is invisible to management. | Date not captured or lost at extract. | Head of Payments Operations | Recover dates from the source system. Make the date mandatory at capture. | High |
| ISS-05 | DQ16 | **18 loans** (£0.81M) **start before their account was opened**. | Date logic is broken, which undermines vintage and account-age analysis. | One of the two dates is wrong, or the loan is linked to the wrong account. | Head of Credit Operations | Validate both dates against source documents and correct the wrong one. | Medium |
| ISS-06 | DQ14 / DQ15 | **6 loans** (£0.41M) have **no start date**, and **1 loan** (400080) **ends before it starts**. | These loans can't be aged or matured correctly. | Incomplete onboarding data and a likely keying error. | Head of Credit Operations | Correct from loan agreements. Add mandatory and date-order checks at loan set-up. | Medium |
| ISS-07 | DQ04 | **1,720 dated transactions** fall **after 2023**. Volumes drop sharply after February 2024, then **485 records** are dated 2025–2026. | Mixing incomplete periods with complete ones would distort trend reporting. | Partial extract after February 2024, and possibly mis-dated records. | Head of Management Information | Keep them outside the governed window. Investigate the 2025–2026 records with the source-system owner. | Medium |
| ISS-08 | DQ07 | **33 accounts** (£1.83M balance) have **no opening date**. | Account age and loan-date checks can't run for these accounts. | Legacy migration gap. | Head of Retail Operations | Back-fill from account-opening records. | Medium |
| ISS-09 | DQ08 | **10 accounts** have a **negative balance** (−£3,247 in total). | Possibly unauthorised overdrafts, or balances in the wrong sign. | Overdraft not recorded as a facility, or a posting error. | Head of Finance Reporting | Confirm against overdraft facilities. Reclassify or correct. | Low |
| ISS-10 | DQ19 | Loan account and customer identifiers are stored as **text**, but as **integers** in the account master. | Joins need explicit conversion, and leading-zero or formatting errors could break links silently. | No shared data standard for identifiers across systems. | Head of Data Management | Agree an identifier standard (integer, fixed length) and apply it at ingestion. | Low |
| MON-01 | DQ10 | **238 customers** (21.6%) hold **no account**. | Not an error, but these may be incomplete onboarding or dormant relationships. | Prospects, or onboarding not completed. | Head of Customer Onboarding | Review quarterly and close out dormant records. Keep them visible in customer counts. | Monitor |

## What passed

These rules passed with no exceptions, and they matter as much as the failures because they show where controls are working:

- Every transaction and account identifier is **unique** (DQ01, DQ06).
- Every loan **links to a real account** and its **correct owner** (DQ12, DQ13).
- Each customer has a **single customer type** (DQ11).
- All transaction amounts are **positive**, and every interest rate is **within the approved range** (DQ03, DQ20).
