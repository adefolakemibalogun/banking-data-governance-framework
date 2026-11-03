# Business Glossary

Agreed definitions for the terms used in reporting. Where two teams could reasonably mean different things, the glossary records the single definition the reports use.

| Term | Definition | Notes and boundaries |
|---|---|---|
| **Customer** | A person or organisation with a customer identifier, whether or not they hold an account. | Customers without an account are kept in counts and flagged (rule DQ10), so incomplete relationships stay visible. |
| **Customer type** | The segment a customer belongs to: Individual, Small Business or Large Enterprise. | One type per customer (DQ11). The account master is the source of truth; loan records must agree. |
| **Account** | A product held by a customer, identified by an account identifier. | One row per account in the account master (DQ06). |
| **Active account** | An open account in normal use. | Counts towards live balances. |
| **Inactive account** | An open account with no recent customer activity. | Still open, so it can hold balances and loans. Monitored, not excluded. |
| **Closed account** | An account that has been formally closed. | Must carry a zero balance (DQ09) and no live loans (DQ17). |
| **Account balance** | The ledger balance at the extract date, measured at account level. | Never summed through transaction or loan joins, which would duplicate balances. Negative balances are exceptions (DQ08). |
| **Transaction** | A single posted movement of money on an account. | Counted once by transaction identifier (DQ01). |
| **Transaction value** | The sum of transaction amounts in the reporting period. | Only dated transactions inside the governed window count (DQ02, DQ04). |
| **Governed reporting window** | 1 January 2020 to 31 December 2023, the last complete, comparable period. | Records after 2023 are sparse and incomplete, so they're reported separately rather than mixed into trends. |
| **Loan** | Credit advanced to a customer and booked against one of their accounts. | Must link to an existing account and its owner (DQ12, DQ13). |
| **Principal amount** | The amount originally advanced under the loan. | Used for the loan portfolio total. It isn't the outstanding balance. |
| **Overdue loan** | A loan with a missed scheduled repayment that hasn't been cleared. | Overdue isn't the same as default. Overdue exposure is reported separately and never labelled as losses. |
| **Overdue exposure** | Total principal of loans with status Overdue. | Reported by customer type to show concentration. |
| **Paid-off loan** | A loan fully repaid before or at maturity. | Excluded from live exposure. |
| **Maturity (estimated end date)** | The contractual date the loan is due to end. | An Active loan past maturity at the reporting date is a status exception (DQ18). |
