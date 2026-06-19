# MistyCloud Inc. Fraud Ring — Investigation Report

**Date:** April 1, 2026  
**Investigator:** Copilot AI Agent + Varun V  
**ICM Ticket:** [771980255](https://portal.microsofticm.com/imp/v5/incidents/details/771980255/summary)  
**Classification:** Coordinated Multi-Tenant SPO Storage Abuse  
**Related:** Discovered during scaled ring-hunting analysis (SpoProd → D2K pivot)

---

## Executive Summary

Through a novel detection methodology — querying **SpoProd blob write volume** for tenants with no enterprise licenses, then pivoting through D2K admin email clustering — we uncovered a **12-tenant fraud ring** operated under the brand "MistyCloud Inc." using the `misty.moe` domain. All tenants are registered in Argentina, each holding exactly **1 license** while consuming **~340-364 TB** of SharePoint storage.

**Total active storage abuse:** ~3,757 TB (~3.67 PB)  
**Total licenses across ring:** 12 (1 per tenant)  
**Storage quota per tenant:** ~1 TB  
**Actual storage per tenant:** ~340-364 TB  
**Average overage:** **~340x** over quota  
**Revenue generated:** $0 paid seats  
**Ring status prior to this investigation:** 1 of 12 in FAB (mistytempsp5ar, identified Mar 30 by detection pipeline)

---

## Discovery Methodology

### How We Found This Ring

Unlike the ACGDB ring (discovered via suspicious tenant names → admin email pivot), the MistyCloud ring was discovered through a **storage-first approach**:

1. **SpoProd Query:** Queried `spogdskustocluster` for tenants with high `blobWriteBytes` in the last 7 days, filtering OUT all enterprise SKUs (E1/E3/E5/F1/F3/A1/A3/A5).
2. **Anomaly Identification:** Tenant `8dae3977` ("Default" / 1 license) appeared with **80,726 GB** of writes in 7 days — an impossible write rate for a 1-license tenant.
3. **ODSP Verification:** `get_tenant_info` confirmed **353 TB** total storage on a 1 TB quota — a **342x** overage.
4. **D2K Admin Email Pivot:** D2K query revealed admin email `mssp1-ar@misty.moe`. Searching D2K for all `misty.moe` emails uncovered **12 tenants** with sequential naming (tempsp1 through tempsp10).
5. **Full Ring Profiling:** Storage check on all 12 tenants confirmed 11 have SPO provisioned, each with 260-364 TB of abuse.

**Key insight:** This ring would NOT have been found via admin-email-first scanning, because each tenant uses a **different** `@misty.moe` email. The domain is the common thread, not a single admin email. SpoProd write-volume analysis was the only effective detection vector.

---

## Ring Anatomy

### All 12 MistyCloud Tenants

| # | Name | Tenant ID | Domain | Created | Storage | Licenses | Admin Email | FAB Status |
|---|------|-----------|--------|---------|---------|----------|-------------|------------|
| 1 | MistyCloud Inc | `8dae3977` | mssp1ar.onmicrosoft.com | Apr 23, 2025 | **354 TB** | 1 acq / 1 en | mssp1-ar@misty.moe | ✅ Ingested today |
| 2 | MistyCloud Inc | `117f2c6f` | mistytempsp1ar.onmicrosoft.com | Apr 23, 2025 | **264 TB** | 1 / 1 | mistytempsp1-ar@misty.moe | ✅ Ingested today |
| 3 | MistyCloud Inc. | `9c760ca4` | mistytempsp2ar.onmicrosoft.com | Apr 25, 2025 | **344 TB** | 1 / 0 | tempsp2-ar@misty.moe | ✅ Ingested today |
| 4 | MistyCloud Inc. | `e14fa431` | mistytempsp3ar.onmicrosoft.com | Apr 25, 2025 | **344 TB** | 1 / 1 | tempsp3-ar@misty.moe | ✅ Ingested today |
| 5 | MistyCloud Inc. | `4f4dff80` | mistytempsp4ar.onmicrosoft.com | Apr 25, 2025 | **340 TB** | 1 / 0 | tempsp4-ar@misty.moe | ✅ Ingested today |
| 6 | MistyCloud Inc. | `01e17974` | mistytempsp5ar.onmicrosoft.com | Apr 25, 2025 | **340 TB** | 1 / 1 | tempsp5-ar@misty.moe | Already in FAB (FraudID 147965, TYPE2) |
| 7 | MistyCloud Inc. | `1bae1b9a` | mistytempsp6.onmicrosoft.com | Apr 25, 2025 | **354 TB** | 1 / 1 | tempsp6-ar@misty.moe | ✅ Ingested today |
| 8 | MistyCloud Inc. | `6c99632a` | mistytempsp7ar.onmicrosoft.com | Apr 25, 2025 | **356 TB** | 1 / 1 | tempsp7-ar@misty.moe | ✅ Ingested today |
| 9 | MistyCloud Inc | `4915ae67` | mistytempsp8ar.onmicrosoft.com | Apr 25, 2025 | **351 TB** | 1 / 1 | tempsp8-ar@misty.moe | ✅ Ingested today |
| 10 | MistyCloud Inc. | `9e63b781` | mistytempsp9ar.onmicrosoft.com | Apr 25, 2025 | **355 TB** | 1 / 1 | tempsp9-ar@misty.moe | ✅ Ingested today |
| 11 | MistyCloud Inc. | `72795d28` | mistytempsp10ar.onmicrosoft.com | Apr 25, 2025 | **355 TB** | 1 / 0 | tempsp10-ar@misty.moe | ✅ Ingested today |
| 12 | MistyCloud Inc. | `a3ba7733` | *(Not in ODSP)* | Mar 18, 2026 | N/A | — | admin@mssp2ar.misty.moe | ⚠️ Not ingestible (no SPO) |

### Aggregated Ring Statistics

| Metric | Value |
|--------|-------|
| **Active tenants** | 11 (1 pending SPO provisioning) |
| **Total storage consumed** | **3,757 TB (~3.67 PB)** |
| **Average storage per tenant** | ~342 TB |
| **Total licenses** | 12 (1 per tenant) |
| **Total storage quota** | ~12 TB (1 TB per tenant) |
| **Average overage** | **~340x** over quota |
| **Revenue** | $0 paid seats |
| **Country** | Argentina (all tenants) |
| **Region** | Buenos Aires Province (various cities) |

---

## Creation Pattern

```
2025-04-23 10:18  mssp1ar created ← primary tenant
2025-04-23 11:13  mistytempsp1ar created ← 55 min later
    ---- 2 day gap ----
2025-04-25 01:30  mistytempsp2ar ← rapid expansion begins
2025-04-25 01:55  mistytempsp3ar  (25 min)
2025-04-25 02:04  mistytempsp4ar  (9 min)
2025-04-25 02:14  mistytempsp5ar  (10 min)
2025-04-25 02:22  mistytempsp6    (8 min)
2025-04-25 02:28  mistytempsp7ar  (6 min)
2025-04-25 02:35  mistytempsp8ar  (7 min)
2025-04-25 02:41  mistytempsp9ar  (6 min)
2025-04-25 02:46  mistytempsp10ar (5 min) ← 9 tenants in 76 minutes
    ---- 11 month gap ----
2026-03-18 20:55  mssp2ar created ← ring still active, new wave
```

Key observations:
- **9 tenants created in 76 minutes** on Apr 25, 2025 — clearly automated/scripted
- Naming evolves: `mssp1ar` → `mistytempsp1ar` → `tempspN-ar`
- **"ar" suffix** = Argentina, suggesting the actor may have other country variants
- `mssp2ar` created March 2026 — actor is still actively expanding
- Domain naming follows `mistytempsp{N}ar.onmicrosoft.com` pattern

---

## Abuse Mechanics

### SPO Soft-Limit Exploitation (Same as ACGDB Pattern)

| Entitled | Actual | Overage |
|----------|--------|---------|
| ~1 TB SPO pool (1 license) | 340-364 TB per tenant | **~340x** |
| 1 TB ODB quota | 0 TB ODB used | N/A |

The actor exploits the same SPO soft-limit gap as the ACGDB ring:
1. Creates commercial tenants in Argentina (no credit card enforcement for single license)
2. Minimal license count (exactly 1 per tenant) to minimize detection footprint
3. Uses SPO for bulk storage (not ODB which has per-user enforcement)
4. Sequential tenant creation with same brand name
5. Different admin email per tenant (but same `misty.moe` domain) — evades single-email clustering detection

### Evasion Improvements Over ACGDB

| Technique | ACGDB | MistyCloud |
|-----------|-------|------------|
| Admin emails | Same Gmail for all | Different @misty.moe per tenant |
| Tenant names | Sequential (ACGDB1, ACGDB2...) | Same company name, different domains |
| Country | HK (flagged region) | AR (lower scrutiny) |
| Licenses | 10-20 per tenant | Exactly 1 per tenant |
| Custom domains | None on ACGDB tenants | Custom domain on primary (misty.moe) |
| Storage per tenant | 29-119 TB | 264-364 TB (much higher) |

---

## Additional Discovery: China Storage Abuser (Singleton)

Discovered via the same SpoProd methodology:

| Metric | Value |
|--------|-------|
| **Tenant ID** | `24098c20-486f-4669-8f26-76d5d6927865` |
| **Name** | Default Directory |
| **Domain** | liangsheng32126.onmicrosoft.com |
| **Country** | China (Hubei / Huanggang City) |
| **Created** | Jan 26, 2026 |
| **Storage** | **110 TB** |
| **Licenses** | 1 (F1 SKU) |
| **Quota** | 1 TB |
| **Overage** | **107x** |
| **Admin** | LIANGSHENG32@126.COM |
| **D2K Ring Check** | Singleton — no other tenants under this email |
| **FAB Status** | ✅ Ingested today (Type1) |

---

## Impact Summary

| Metric | MistyCloud Ring | China Singleton | Combined |
|--------|----------------|----------------|----------|
| **Tenants** | 12 | 1 | 13 |
| **Active (SPO provisioned)** | 11 | 1 | 12 |
| **Total storage abuse** | ~3,757 TB (3.67 PB) | 110 TB | **~3,867 TB (3.78 PB)** |
| **Total licenses** | 12 | 1 | 13 |
| **Revenue** | $0 | $0 | **$0** |
| **In FAB pipeline** | 11 of 12 | 1 of 1 | **12 of 13** |
| **Avg storage/tenant** | 342 TB | 110 TB | 298 TB |
| **Avg overage** | 340x | 107x | 305x |

### Comparison to Previous Investigations

| Ring | Tenants | Total Abuse | Avg/Tenant | Revenue |
|------|---------|-------------|------------|---------|
| **MistyCloud** | **12** | **3.67 PB** | **342 TB** | $0 |
| ACGDB/SakuraPY | 33 | 597 TB | 66 TB | $0 |
| E5 Developer Ring | 26 | ~1.9 PB | 73 TB | $0 |

**MistyCloud is the largest single-ring storage abuse operation discovered to date** — 6.1x the storage impact of ACGDB with only 12 tenants (vs 33).

---

## Remediation Status

### Ingested Today — April 1, 2026

**Batch 1 (6 tenants):** `8dae3977`, `117f2c6f`, `9c760ca4`, `e14fa431`, `4f4dff80`, `1bae1b9a`  
**Batch 2 (5 tenants):** `6c99632a`, `4915ae67`, `9e63b781`, `72795d28`, `24098c20` (China)

| Configuration | Value |
|--------------|-------|
| **useCaseType** | 1 (TYPE1) |
| **reasonCode** | 5 (CLUSTERS) |
| **ICM** | [771980255](https://portal.microsofticm.com/imp/v5/incidents/details/771980255/summary) |
| **isReviewRequired** | false |

### Pre-existing in FAB

| Tenant | FraudID | Status | Notes |
|--------|---------|--------|-------|
| mistytempsp5ar (`01e17974`) | 147965 | Status 1 (Identified) | TYPE2, approvalFlag=1 (pending review). Identified Mar 30, 2026 by detection pipeline. |

### Not Ingestible

| Tenant | Reason |
|--------|--------|
| mssp2ar (`a3ba7733`) | Not in ODSP — SPO not provisioned. Created Mar 18, 2026. Monitor and ingest when SPO activates. |

---

## Recommendations

### ✅ Completed

1. ~~Ingest all MistyCloud ring tenants with SPO into FAB~~ — **DONE** (10 tenants ingested Apr 1, 2026)
2. ~~Ingest China singleton into FAB~~ — **DONE** (ingested Apr 1, 2026)

### Remaining Actions

3. **Immediate:** Block `misty.moe` domain from M365 tenant creation — actor created mssp2ar just 2 weeks ago
4. **Immediate:** Monitor mssp2ar (`a3ba7733`) — ingest once SPO is provisioned
5. **Short-term:** Review mistytempsp5ar (FraudID 147965) — stuck on TYPE2 approvalFlag=1, may need conversion to TYPE1
6. **Short-term:** Search for other `misty.moe` presence across WEU/APAC D2K shards (currently only WUS searched)
7. **Short-term:** Check if actor has variants in other countries (naming includes "-ar" suffix suggesting possible "-us", "-eu" variants)
8. **Medium-term:** Implement SpoProd write-volume anomaly detection for tenants with <10 licenses — this is the most effective detection vector for this abuse pattern
9. **Detection improvement:** Add domain-based clustering (not just email-based) — this ring uses different emails but the same custom domain

---

## Investigation Methodology

### Tools Used

1. **`kusto_query` (SpoProd)** — Blob write volume analysis to identify high-storage abuse tenants
2. **`get_tenant_info`** — ODSP storage verification and licensing details
3. **`query_from_d2_k`** — Admin email extraction from D2K Company table
4. **`kusto_query` (D2K WUS)** — Domain-based admin email search across D2K
5. **`get_tenant_remediation_info`** — FAB pipeline status check
6. **`ingest_tenants`** — Remediation pipeline ingestion

### Detection Chain

```
SpoProd: High blobWriteBytes + no enterprise SKU
    ↓
ODSP: 353 TB on 1-license tenant (342x overage)
    ↓
D2K: Admin email = mssp1-ar@misty.moe
    ↓
D2K WUS: TechnicalNotificationMail has 'misty.moe' → 12 tenants
    ↓
ODSP: All 11 active tenants confirmed 264-364 TB each
    ↓
FAB: 10 new + 1 China singleton ingested (Type1, ICM 771980255)
```

---

*Report generated April 1, 2026 via Copilot AI Agent assisted investigation*
