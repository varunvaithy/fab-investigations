# FAMILIA CONFEITAR — Brazil Streaming CDN Ring Investigation Report

**Date:** April 8, 2026  
**Investigator:** Copilot AI Agent + Varun V  
**ICM Ticket:** [775773500](https://portal.microsofticm.com/imp/v5/incidents/details/775773500/summary)  
**Classification:** Brazil Streaming CDN / Content Piracy Ring — SharePoint Online Abuse  
**Parent Investigation:** DS Model Investigation List (944 tenants) — Ring 1 of 6  
**Reason Code:** 107 — Detection from FAB DS Model (2026)  
**Action Type:** ABUSE-READONLY-BLOCK-DELETE

---

## Executive Summary

Investigation of 944 tenant IDs flagged by the FAB DS Model identified a 30-tenant ring operated by a single actor (`mario@ritzmann.com.br`) in Itapema, Santa Catarina, Brazil. All 30 tenants are registered under the name **"FAMILIA CONFEITAR COMERCIO DE ALIMENTOS LTDA"** (a food company) with sequential domains `familiaconfeitar1-30.onmicrosoft.com`, each running Microsoft 365 Business Basic with a single seat.

The ring is using SharePoint Online as a **piracy streaming CDN**: ~1.9 PB of content stored across 30 tenants (63-73x over the 1 TB allocated quota per tenant), with **zero ingress** and **~1,696 TB/week egress** served via HTTP 206 partial-content range requests. This is the largest single-operator storage abuse ring identified in the DS list.

**Key stats:**
- **30 tenants ingested** into FAB remediation
- **Total storage consumed:** ~1.9 PB (vs. 30 TB allocated quota = **63x overage**)
- **Weekly egress:** ~1,696 TB (zero ingress)
- **Revenue to Microsoft:** ~$180/month ($6/mo × 30 tenants × 1 seat)
- **Estimated COGS to Microsoft:** Orders of magnitude greater than revenue (storage + bandwidth)
- **False positive risk:** Zero — single operator, sequential domains, identical fingerprint
- **6 outlier tenants** in same piracy ecosystem identified separately (TDFLIX, DVDTECH, DRIVECOMUNIDADE, etc.)

---

## Ring Composition

### Core Ring — 30 FAMILIA CONFEITAR Tenants

All 30 tenants share identical attributes:

| Attribute | Value |
|-----------|-------|
| **Tenant Name** | FAMILIA CONFEITAR COMERCIO DE ALIMENTOS LTDA |
| **Admin Email** | mario@ritzmann.com.br |
| **Address** | R 424, 353 SALA 02, ITAPEMA, SC 88220-000, Brazil |
| **Phone** | 4196152228 |
| **SKU** | Microsoft 365 Business Basic |
| **Seats** | 1 acquired, 1 enabled |
| **Paid Status** | Paid ($6/month per tenant) |
| **Trial** | No |
| **Custom Domain** | No (onmicrosoft.com only) |
| **Storage Quota** | 1,034 GB (~1 TB) per tenant |
| **Actual Storage** | 62,616 – 75,898 GB per tenant (avg ~63 TB) |
| **Over-Quota Ratio** | **60x – 73x** |
| **ODB Usage** | 0 GB (all content in SPO sites) |
| **SPO Sites** | 6-7 per tenant |
| **Distinct Users** | 3-4 per tenant |
| **Weekly Ingress** | 0 bytes |
| **Weekly Egress** | ~56 TB per tenant |

### Tenant Inventory

| # | Domain | Tenant ID | Created | Storage (TB) | Egress/7d (TB) |
|---|--------|-----------|---------|-------------|----------------|
| 1 | familiaconfeitar1 | `b82861b1-5972-4512-8a5e-a9b497c43b3f` | 2025-04-11 18:38 | ~63 | 65.6 |
| 2 | familiaconfeitar2 | `0a14954b-f2d0-4696-be28-1ffcb1f1af8e` | 2025-04-11 18:42 | ~63 | 65.4 |
| 3 | familiaconfeitar3 | `1ca6d9bb-00cc-44b4-b149-3139b2f1f462` | 2025-04-11 18:49 | ~63 | 63.8 |
| 4 | familiaconfeitar4 | `502a91ad-c53b-439c-a0d4-d85a3d734c04` | 2025-04-11 18:55 | ~63 | 62.7 |
| 5 | familiaconfeitar5 | `2007ec41-9fc6-4c48-b0e6-c09a64914f26` | 2025-04-11 19:01 | ~63 | 62.5 |
| 6 | familiaconfeitar6 | `9f4a3a45-b52c-429f-9d27-824eb53ca1ac` | 2025-04-11 19:09 | ~63 | ~55 |
| 7 | familiaconfeitar7 | `dad399d7-9499-4046-babc-473fa9a7e024` | 2025-04-11 19:14 | ~63 | ~55 |
| 8 | familiaconfeitar8 | `aa7e8967-5b0b-4926-b2fd-b13eeccd1317` | 2025-04-11 19:19 | ~63 | ~55 |
| 9 | familiaconfeitar9 | `30baffe8-6920-472a-96d9-225f91de8928` | 2025-04-11 19:24 | ~63 | ~55 |
| 10 | familiaconfeitar10 | `571c12a6-6d43-4317-ac93-0323c3528da5` | 2025-04-11 19:34 | ~63 | ~55 |
| 11 | familiaconfeitar11 | `d1ee8630-3487-4c9e-8384-be884e1b7996` | 2025-04-11 19:42 | ~63 | ~55 |
| 12 | familiaconfeitar12 | `46d7e95f-6dd0-438c-ac82-05000771c8cc` | 2025-04-11 19:47 | ~63 | ~55 |
| 13 | familiaconfeitar13 | `94bfc7fd-addf-4ea5-9e3e-1dcfbc685420` | 2025-04-11 19:52 | ~63 | ~55 |
| 14 | familiaconfeitar14 | `554efcf0-25e5-4586-832f-5a1cebe25719` | 2025-04-11 19:57 | ~63 | ~55 |
| 15 | familiaconfeitar15 | `4d94be45-3ad7-49d6-884b-5f761ec2e6e3` | 2025-04-11 20:02 | ~76 | 75.5 |
| 16 | familiaconfeitar16 | `8bf775aa-a43d-40d0-bdc1-ede8eef6fcbf` | 2025-05-06 | ~63 | ~55 |
| 17 | familiaconfeitar17 | `67abf679-1ffa-4b6d-a383-c6040602bb56` | 2025-05-06 | ~63 | ~55 |
| 18 | familiaconfeitar18 | `4db339ce-3601-4912-b594-fcf111574e9d` | 2025-05-06 | ~63 | ~55 |
| 19 | familiaconfeitar19 | `6be3d682-9b5e-4a2c-a1dc-3db3d1006317` | 2025-05-06 | ~63 | 66.1 |
| 20 | familiaconfeitar20 | `594fadd9-4c3b-4cd3-ae4c-c8bf7d6c3985` | 2025-05-06 | ~63 | 66.5 |
| 21 | familiaconfeitar21 | `27bd7116-3279-4f9c-bf95-dad5da03fc1f` | 2025-05-06 | ~63 | 66.8 |
| 22 | familiaconfeitar22 | `a55f3442-ebfe-4def-9e8c-e44338b07983` | 2025-05-07 | ~63 | ~55 |
| 23 | familiaconfeitar23 | `a18f11eb-8368-4278-ba02-90fdf2c22bf8` | 2025-05-07 | ~63 | ~55 |
| 24 | familiaconfeitar24 | `85166de6-bd5e-4845-bd55-0111b34974a9` | 2025-05-07 | ~63 | 67.4 |
| 25 | familiaconfeitar25 | `96a8ac8d-8e88-481b-b12a-3ae1b4cbc5cf` | 2025-05-07 | ~63 | ~55 |
| 26 | familiaconfeitar26 | `5b562ca7-ca1c-4bbe-88d5-5618e12d7606` | 2025-05-07 | ~63 | ~55 |
| 27 | familiaconfeitar27 | `5408af44-2fe0-4b44-975e-989e8273b4bd` | 2025-05-07 | ~63 | 63.8 |
| 28 | familiaconfeitar28 | `f4e6a745-aed5-4eaf-991a-726a4b53161a` | 2025-05-07 | ~63 | 63.7 |
| 29 | familiaconfeitar29 | `797739ea-6141-4aaa-96a4-76a46d4f56f8` | 2025-05-07 | ~63 | 63.6 |
| 30 | familiaconfeitar30 | `1b05da04-8617-4796-87bb-237a07cb1ac6` | 2025-05-07 | ~63 | 63.5 |

### Creation Pattern

- **Wave 1 (April 11, 2025):** familiaconfeitar1–15, created within ~2 hours (18:38–20:02 UTC)
- **Wave 2 (May 6–7, 2025):** familiaconfeitar16–30, created over two days

---

## Violations Summary

### 1. Extreme Storage Quota Abuse (60-73x Overage)

Each tenant has a 1,034 GB quota (Business Basic with 1 seat includes 1 TB + 10 GB base). Actual storage per tenant ranges from 62,616 to 75,898 GB — a **60-73x quota overage**. Across all 30 tenants, the ring consumes ~1.9 PB against a combined quota of ~30 TB. Storage quota enforcement has not triggered.

### 2. CDN / Content Distribution Abuse

Telemetry shows the dominant pattern is HTTP 206 partial-content range-request streaming:
- **Scenarios:** `DownloadFile_P2`, `DownloadFile_P2_Asp`, `Unknown`
- **Error codes:** Almost all are `206_*` variants (partial content success with connection resets)
- **Apps:** `Other` (anonymous download links), `OneProfileService`, `OpenBoxLab`
- **Zero ingress** — content was loaded once and is now being served indefinitely

This is SharePoint Online operating as a free streaming CDN for pirated content.

### 3. Multi-Tenancy Circumvention

30 identical tenants created by the same operator in two automated waves to distribute load across tenants and circumvent per-tenant throttling/quotas. Evidence of `429_ThrottledRequest_AppResourceUnit` errors confirms they're hitting and distributing around rate limits.

### 4. Terms of Service / Acceptable Use Violations

- Content piracy (co-located ecosystem with TDFLIX, DVDTECH, DRIVECOMUNIDADE — explicit piracy brands)
- No legitimate business use (1 user, 0 collaboration, no ODB usage, no custom domains)
- Fraudulent business registration (food company name for piracy CDN operation)

### 5. Revenue/Cost Disparity

Total revenue: ~$180/month. Estimated storage cost alone at Azure rates (~$0.018/GB/month for hot blob): $180/month revenue vs. ~$34,200/month storage cost (1.9 PB × $0.018). Add bandwidth egress costs at ~$0.05/GB for 1,696 TB/week and the cost is astronomical.

---

## Ring Expansion Analysis

Systematic search for additional FAMILIA CONFEITAR tenants beyond the 30 known:

- **Global CDN fingerprint query** (Brazil + zero ingress + "Other" app + >1TB egress): Found 10 new tenant IDs. All 10 were profiled via D2K and **confirmed as legitimate Brazilian companies** (ARGOPLAN 806 seats/E3, MBRF/BRF 34K seats/E5, NOVATEC 152 seats, etc.). None are ring members.
- **Admin email pivot** (`mario@ritzmann.com.br`): Present on all 30 FAMILIA CONFEITAR tenants and no others.
- **Conclusion:** The FAMILIA CONFEITAR ring boundary is definitively 30 tenants. No additional members found.

---

## Related Tenants — Brazil Piracy Ecosystem (Not in This Ingestion)

Six outlier tenants in the DS list share the Brazil streaming CDN pattern but are operated by **different actors**:

| Tenant ID | Name | Admin | Storage (TB) | Status |
|-----------|------|-------|-------------|--------|
| `784553d3` | TDFLIX COMUNICACOES LTDA | tdflix@outlook.com | ~63 | **Pending ingestion** |
| `e50e8fb9` | DRIVECOMUNIDADE | dinho.plex@gmail.com | ~45 | Already in FAB (FraudId 133908, ReadOnly since 3/27) |
| `ab3ab555` | DVDTECH | deivide.pereira@outlook.com.br | ~40 | **Pending ingestion** |
| `2c336f21` | MSFT | labtestes@hotmail.com | ~30 | **Pending ingestion** |
| `2bc77541` | MSFT | speedtv@outlook.es | ~25 | **Pending ingestion** |
| `71166d27` | N | natanaelnsg2@gmail.com | ~20 | **Pending ingestion** |

**TDFLIX and DRIVECOMUNIDADE** share the same physical address (Rua Edgar de Sousa, 03502-010 São Paulo) and phone number — they are a separate 2-tenant mini-ring.

These outliers will be ingested separately as they represent distinct operators in the same piracy ecosystem.

---

## Enforcement Risk Assessment

| Risk | Level | Detail |
|------|-------|--------|
| **False Positive** | **Zero** | Single operator, 30 sequential domains, identical fingerprint |
| **Revenue Impact** | **Negligible** | $180/month total against ~$34K+/month storage COGS |
| **Paid Tenant Pushback** | **Low** | Paid but 63x over-quota is indefensible; clear ToS violations |
| **Data Loss to Legitimate Users** | **None** | 1 user per tenant, pirated content, no collaboration |
| **Legal/Jurisdiction** | **Low** | Brazil (ITAPEMA, SC). DRIVECOMUNIDADE already enforced without incident |
| **Block Execution** | **Proven** | DRIVECOMUNIDADE successfully ReadOnly'd on 3/27 |
| **Re-creation Risk** | **High** | Operator created 30 tenants in 2 waves; will likely recreate |

---

## Detection Rule Proposals

Post-enforcement, the following detection rules should prevent re-creation:

1. **Sequential Domain Pattern** — `familiaconfeitar\d+.onmicrosoft.com` or any `<name>\d{1,3}.onmicrosoft.com` pattern with same admin
2. **Business Basic CDN Fingerprint** — Business Basic + 1 seat + Brazil + zero ingress + >10 TB egress/week + "Other" app dominant
3. **Storage Quota Ratio** — Any tenant using >10x allocated quota should be flagged
4. **Admin Email Clustering** — Same admin email across >3 tenants with identical SKU and behavior pattern

---

## Remediation

- **Action:** ABUSE-READONLY-BLOCK-DELETE
- **Reason Code:** 107 — Detection from FAB DS Model (2026)
- **ICM:** [775773500](https://portal.microsofticm.com/imp/v5/incidents/details/775773500/summary)
- **Tenants Ingested:** 30
- **FraudIds:** 148626–148641 (and surrounding; 30 total)
- **Ingestion Date:** April 8, 2026
