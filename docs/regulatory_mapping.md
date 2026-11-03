# Regulatory Mapping

How the controls in this framework support two standards relevant to banks: **BCBS 239** (risk data aggregation and reporting) and the **Nigeria Data Protection Act 2023**.

This is an illustrative mapping for a synthetic dataset, not a compliance assessment. Formally, BCBS 239 applies to global and domestic systemically important banks, but its principles are widely used as good practice for any bank's risk and management data.

## BCBS 239: Principles for effective risk data aggregation and risk reporting

| Principle | What it asks for | How this framework supports it |
|---|---|---|
| **P1 Governance** | Strong governance over risk data, with clear ownership. | Every critical data element has a named owner and steward ([CDE register](cde_register.csv)). Every failed rule becomes an owned issue ([issue log](issue_log.md)). |
| **P2 Data architecture and IT infrastructure** | Integrated data taxonomies and architecture. | A shared business glossary ([glossary](business_glossary.md)) and an identifier-type standard (DQ19, ISS-10). |
| **P3 Accuracy and integrity** | Accurate, reliable data, largely automated, with reconciliation. | 20 automated SQL rules. Totals are reconciled to the published reporting ([lineage](lineage.md)). Referential-integrity checks between loans and accounts (DQ12, DQ13). |
| **P4 Completeness** | Capture all material risk data. | Completeness rules on dates and keys (DQ02, DQ07, DQ14). Customers without accounts are kept visible rather than dropped (DQ10). |
| **P5 Timeliness** | Data available when needed, including under stress. | Status-currency checks (DQ18, stale loan status) and a governed reporting window (DQ04) that stops incomplete periods distorting trends. |
| **P6 Adaptability** | Meet ad hoc and changing requests. | Rules are modular SQL with metadata in a single CSV, so new rules and thresholds can be added without code changes to the runner. |
| **P7 Accuracy (reporting)** | Reports reflect risk accurately and are reconciled. | Reported figures trace back to controlled source elements, with reconciliation ([lineage](lineage.md)). |
| **P8 Comprehensiveness** | Reports cover all material risks. | Overdue exposure is reported by customer type. Stale and misattached loans (ISS-02, ISS-03) are flagged so exposure isn't understated. |
| **P9 Clarity and usefulness** | Clear, concise reporting for decision-makers. | A scorecard by rule and dimension with pass, fail and monitor status, plus a plain-language issue log. |
| **P11 Distribution** | Reports reach the right people. | Each issue is routed to an accountable business owner, not left with the data team. |

Principles 10 (frequency) and 12–14 (supervisory review and cooperation) apply to bank operations and supervisors, so they're out of scope here.

## Nigeria Data Protection Act 2023

Section 24 of the Act sets out principles for processing personal data. The Nigeria Data Protection Commission (NDPC) enforces it. The framework supports the data-quality-related principles:

| NDPA principle | How this framework supports it |
|---|---|
| **Accuracy** (personal data kept accurate and up to date) | Completeness, validity and consistency rules on customer and account data (DQ07, DQ08, DQ09, DQ11). Issues are owned and remediated at source. |
| **Data minimisation** (only what is necessary) | The CDE register records why each element is needed, which supports challenge of any element without a clear purpose. |
| **Storage limitation** (not kept longer than needed) | Closed-account and dormant-customer exceptions (ISS-01, MON-01) are prompts for retention review, not just data fixes. |
| **Integrity and confidentiality** | Uniqueness and referential-integrity checks protect integrity. The synthetic dataset contains no real personal data. |
| **Accountability** | Named owners, rule thresholds and an issue log provide the evidence trail an accountable controller needs. |

## Sources
- Basel Committee on Banking Supervision, *Principles for effective risk data aggregation and risk reporting* (BCBS 239), January 2013.
- Nigeria Data Protection Act 2023, Section 24.
