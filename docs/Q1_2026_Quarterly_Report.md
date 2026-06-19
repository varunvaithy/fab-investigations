# FAB Tenant Service - Q1 2026 Quarterly Remediation Report
**Period:** January 1, 2026 – March 31, 2026  
**Prepared:** March 18, 2026  
**Team:** ODSP Fraud and Abuse (FAB)

---

## Executive Summary

In Q1 2026, the FAB Tenant Service remediated **[TOTAL_TENANTS]** fraudulent tenants, reclaiming approximately **[TOTAL_STORAGE_TB] TB** ([TOTAL_STORAGE_PB] PB) of storage. Remediation actions included placing tenants in Read-Only mode, Blocking access, and initiating Deletion across multiple abuse use case types.

---

## 1. Remediation Actions Summary

| Remediation Action | Tenants Remediated | Storage Reclaimed (TB) | Storage Reclaimed (PB) | Avg Storage/Tenant (GB) |
|----|----|----|----|----|
| **ReadOnly** | [READONLY_COUNT] | [READONLY_TB] | [READONLY_PB] | [READONLY_AVG_GB] |
| **Block** | [BLOCK_COUNT] | [BLOCK_TB] | [BLOCK_PB] | [BLOCK_AVG_GB] |
| **Delete** | [DELETE_COUNT] | [DELETE_TB] | [DELETE_PB] | [DELETE_AVG_GB] |
| **Total** | **[TOTAL_COUNT]** | **[TOTAL_TB]** | **[TOTAL_PB]** | **[TOTAL_AVG_GB]** |

> *Fill from Query 1 results in Q1_2026_Quarterly_Report_Queries.sql*

---

## 2. Breakdown by Use Case Type

| Use Case Type | Action | Tenants | Storage (TB) |
|----|----|----|----|
| ABUSE-READONLY-BLOCK | ReadOnly | [val] | [val] |
| ABUSE-READONLY-BLOCK | Block | [val] | [val] |
| ABUSE-READONLY-BLOCK-DELETE_15DAYS | ReadOnly | [val] | [val] |
| ABUSE-READONLY-BLOCK-DELETE_15DAYS | Block | [val] | [val] |
| ABUSE-READONLY-BLOCK-DELETE_15DAYS | Delete | [val] | [val] |
| TYPE1 | ReadOnly | [val] | [val] |
| TYPE1 | Block | [val] | [val] |
| E5DEV-OVERQUOTA | Block | [val] | [val] |

> *Fill from Query 2 results*

---

## 3. Breakdown by Tenant Level

| Tenant Level | ReadOnly | Block | Delete | Total | Storage (TB) |
|----|----|----|----|----|----|
| **Paid** | [val] | [val] | [val] | [val] | [val] |
| **Non-Paid** | [val] | [val] | [val] | [val] | [val] |
| **Trial** | [val] | [val] | [val] | [val] | [val] |
| **Free** | [val] | [val] | [val] | [val] | [val] |

> *Fill from Query 3 results*

---

## 4. Monthly Trend

| Month | ReadOnly | Block | Delete | Total | Storage Reclaimed (TB) |
|----|----|----|----|----|----|
| **January 2026** | [val] | [val] | [val] | [val] | [val] |
| **February 2026** | [val] | [val] | [val] | [val] | [val] |
| **March 2026** | [val] | [val] | [val] | [val] | [val] |
| **Q1 Total** | **[val]** | **[val]** | **[val]** | **[val]** | **[val]** |

> *Fill from Query 4 results*

---

## 5. Active Blocked Tenants (Blocked but Not Yet Deleted)

| Use Case Type | Tenant Level | Blocked Tenants | Storage (TB) | Storage (PB) |
|----|----|----|----|----|
| [val] | [val] | [val] | [val] | [val] |

> *Fill from Query 5 results — mirrors the existing BlockedTenantsAgg_Varsha view with Q1 date filter*

---

## 6. Tenant Category Breakdown

| Category | ReadOnly Tenants | Block Tenants | Delete Tenants | Total Storage (TB) | Total Licenses Reclaimed |
|----|----|----|----|----|----|
| **EDU** | [val] | [val] | [val] | [val] | [val] |
| **Commercial** | [val] | [val] | [val] | [val] | [val] |

> *Fill from Query 7 results*

---

## 7. Top Countries by Remediation Volume

| Country | Total Tenants Remediated | Storage (GB) |
|----|----|----|
| [Country 1] | [val] | [val] |
| [Country 2] | [val] | [val] |
| [Country 3] | [val] | [val] |
| ... | ... | ... |

> *Fill from Query 6 results*

---

## 8. Pipeline Funnel

| Metric | Count |
|----|----|
| Tenants Identified in Q1 2026 | [val] |
| Remediation Started in Q1 2026 | [val] |
| Actions Successfully Performed in Q1 2026 | [val] |
| False Positives Identified in Q1 2026 | [val] |

> *Fill from Query 8 results*

---

## 9. Remediation Efficiency

| Action | Avg Days to Remediate | Min Days | Max Days |
|----|----|----|----|
| ReadOnly | [val] | [val] | [val] |
| Block | [val] | [val] | [val] |
| Delete | [val] | [val] | [val] |

> *Fill from Query 9 results*

---

## 10. Failure Analysis

| Action | Failed Attempts | Unique Tenants Affected |
|----|----|----|
| ReadOnly | [val] | [val] |
| Block | [val] | [val] |
| Delete | [val] | [val] |

> *Fill from Query 10 results*

---

## Key Metrics at a Glance

| KPI | Q1 2026 Value |
|----|----|
| Total Tenants Remediated | [val] |
| Total Storage Reclaimed (TB) | [val] |
| Avg Time to Remediate (Days) | [val] |
| False Positive Rate | [val]% |
| Remediation Success Rate | [val]% |
| EDU vs Commercial Split | [val]% EDU / [val]% Commercial |

---

## Notes & Methodology

- **Remediation Actions Counted:** Only successfully executed actions (STATUS = 1 in TENANT_ACTIONS_SCHD) are counted.
- **Storage:** Based on `TENANT_TOTAL_DISK_USED_GB` from the TENANT_DETAILS_RAW table (includes both SPO site storage + ODB storage).
- **Date Range:** Actions with `PERFORMED_DATE` between 2026-01-01 and 2026-03-31 (inclusive).
- **Exclusions:** Tenants with STATUS = 99 (test/internal) are excluded. E5DEV-OVERQUOTA tenants are excluded from the Blocked Tenants view (Query 5) per existing convention.
- **Deduplication:** Where ROW_NUMBER is used, only the latest action per tenant is counted to avoid double-counting.

---

## How to Generate This Report

1. Run all 10 queries from `Q1_2026_Quarterly_Report_Queries.sql` against the production FAB SQL Database
2. Fill in the `[val]` placeholders above with the query results
3. The queries are designed to be copy-paste ready for SSMS or Azure Data Studio
