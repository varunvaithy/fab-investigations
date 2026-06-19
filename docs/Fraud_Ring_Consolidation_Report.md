# Fraud Ring Consolidation Report
**Date**: April 2, 2026  
**Analyst**: Copilot-Assisted Investigation  
**Scope**: APAC D2K (Primary), Global D2K Shards (EU, WUS, JPN, AUS)

---

## Executive Summary

Investigation of admin clustering across D2K identity shards has uncovered **3 major fraud rings** on the APAC cluster totaling **8,939 tenants** with **~465 TB of allocated OneDrive/SharePoint quota**. None of these tenants are currently tracked or blocked by FAB. Additional suspicious rings were identified on EU, WUS, and AUS clusters.

---

## Priority 1: Hamter Botnet

| Metric | Value |
|--------|-------|
| **Total Tenants** | 3,749 |
| **Admin Accounts** | 21 (admin@hamter{1-20}.onmicrosoft.com + guytejydt@hamter3.onmicrosoft.com + admin@hamterk.onmicrosoft.com) |
| **Total Allocated Quota** | 189,000,000 MB (~**189 TB**) |
| **Avg Quota/Tenant** | 50,000 MB (~49 GB) |
| **Country** | Vietnam (VN) |
| **Creation Window** | Sep 21, 2025 → Oct 3, 2025 (**12 days**) |
| **FAB Tracking Status** | **NONE** — 0 tenants tracked |

### Admin Email Breakdown

| Admin Email | Tenant Count |
|-------------|-------------|
| admin@hamter10.onmicrosoft.com | 248 |
| admin@hamter5.onmicrosoft.com | 230 |
| admin@hamter16.onmicrosoft.com | 212 |
| admin@hamter14.onmicrosoft.com | 210 |
| admin@hamter15.onmicrosoft.com | 209 |
| admin@hamter19.onmicrosoft.com | 209 |
| admin@hamter12.onmicrosoft.com | 208 |
| admin@hamter7.onmicrosoft.com | 203 |
| admin@hamter6.onmicrosoft.com | 201 |
| admin@hamter20.onmicrosoft.com | 196 |
| admin@hamter1.onmicrosoft.com | 194 |
| guytejydt@hamter3.onmicrosoft.com | 194 |
| admin@hamter17.onmicrosoft.com | 192 |
| admin@hamter9.onmicrosoft.com | 180 |
| admin@hamter8.onmicrosoft.com | 178 |
| admin@hamter13.onmicrosoft.com | 174 |
| admin@hamter11.onmicrosoft.com | 173 |
| admin@hamter4.onmicrosoft.com | 170 |
| admin@hamter18.onmicrosoft.com | 154 |
| admin@hamterk.onmicrosoft.com | 45 |

### Indicators of Fraud
- **Sequential naming**: hamter1 through hamter20 — automated provisioning
- **Burst creation**: 3,749 tenants in 12 days via 21 admin accounts
- **Human-like display names**: "Kerry Courtney", "Gayle Antione", "Douglass Chance" — synthetic identity generation
- **Single country**: All Vietnam, no legitimate business justification for this volume
- **50GB quota each**: Default trial tenant allocation, abused at scale

---

## Priority 2: April 2022 Burst (China Randomized Email Ring)

| Metric | Value |
|--------|-------|
| **Total Tenants** | 4,498 |
| **Admin Accounts** | 9 (randomized email addresses) |
| **Total Allocated Quota** | 225,150,000 MB (~**225 TB**) |
| **Avg Quota/Tenant** | ~50,056 MB (~49 GB) |
| **Country** | China (CN) |
| **Creation Window** | Apr 7, 2022 → Apr 23, 2022 (**16 days**) |
| **FAB Tracking Status** | **NONE** — 0 tenants tracked |

### Admin Email Breakdown

| Admin Email | Tenant Count |
|-------------|-------------|
| pfgHsWB3dH@yqymeef47F.com | 500 |
| 5FbXNPrqDn@a089PPGs85.com | 500 |
| 2ER0O2f6uq@7i6nAXYNLz.com | 500 |
| 2v2A5N3lCT@JxRD5R4bDS.com | 500 |
| o6VOLimdwY@eHZnRcWwCC.com | 500 |
| fsuwuZthsI@afU7JRSv0M.com | 500 |
| E0ngrb6Q2K@s8k4XL6ENv.com | 500 |
| rQznrmFgcA@5KZGmhAExy.com | 499 |
| IbCnEL9SSP@kDM5ZRZBBO.com | 499 |

### Indicators of Fraud
- **Randomized emails**: Both username and domain are random alphanumeric strings — no real humans
- **Exact 500 limit**: Each admin creates exactly 499-500 tenants — hitting provisioning rate limit per email
- **16-day burst**: 4,498 tenants across 9 synthetic emails in 2.5 weeks
- **No legitimate email domains**: Domains like `yqymeef47F.com`, `a089PPGs85.com` are not real registered domains
- **Old ring (2022)**: Running undetected for **4 years**

---

## Priority 3: shheqing.com Ring

| Metric | Value |
|--------|-------|
| **Total Tenants** | 685 |
| **Admin Accounts** | 2 |
| **Total Allocated Quota** | 51,250,000 MB (~**51 TB**) |
| **Avg Quota/Tenant** | ~74,818 MB (~73 GB) — higher than default |
| **Countries** | China (CN), Hong Kong (HK) |
| **Creation Window** | Nov 10, 2023 → Mar 30, 2026 (**ongoing, 2.4 years**) |
| **FAB Tracking Status** | **NONE** — 0 tenants tracked |

### Admin Email Breakdown

| Admin Email | Tenant Count |
|-------------|-------------|
| wuqc@shheqing.com | 396 |
| pangcx@shheqing.com | 289 |

### Indicators of Fraud
- **Single corporate domain**: shheqing.com — a real domain that appears to be a shell company
- **Actively growing**: Still creating tenants as of March 30, 2026
- **Higher-than-default quota**: ~73 GB average vs standard 49 GB — may have upgraded some tenants
- **Long-running operation**: 2.4 years of steady tenant creation

---

## APAC Rings — Grand Totals

| Ring | Tenants | Allocated Quota | Country | Period | Status |
|------|---------|----------------|---------|--------|--------|
| **Hamter Botnet** | 3,749 | ~189 TB | VN | Sep-Oct 2025 | Undetected |
| **April 2022 Burst** | 4,498 | ~225 TB | CN | Apr 2022 | Undetected 4yrs |
| **shheqing.com** | 685 | ~51 TB | CN/HK | Nov 2023 - present | Active |
| **TOTAL** | **8,932** | **~465 TB** | — | — | **0 tracked by FAB** |

---

## Global Ring Detection — Other Clusters

### EU Cluster (idsharedweu.westeurope.kusto.windows.net)

Suspicious rings found (excluding known Microsoft test/partner infrastructure):

| Admin Email | Tenants | Countries | Period | Assessment |
|-------------|---------|-----------|--------|------------|
| soporte-kitdigital@fractalia.es | 10,740 | ES | Nov 2024 - Mar 2026 | **Investigate** — Kit Digital reseller, could be legit |
| support@treeveinsmedia.com | 6,862 | MA | Jun 2022 - Mar 2023 | **FRAUD** — Domain farming (headpark.xyz, elasticclammy.life) |

### WUS Cluster (idsharedwus.westus.kusto.windows.net)

Suspicious rings found (excluding Microsoft internal stockpiling/test accounts):

| Admin Email | Tenants | Countries | Period | Assessment |
|-------------|---------|-----------|--------|------------|
| sdsd@dsdsd.com | 212,338 | US/multi | Oct-Nov 2023 | **Investigate** — Massive, fake email |
| pascal.landre@laposte.net | 22,748 | GP | Feb-Dec 2020 | **FRAUD** — Single personal email, Guadeloupe |
| licenses@hypertide.io | 13,727 | US | Dec 2024 - Feb 2025 | **FRAUD** — Fake US companies ("PVT LTD" pattern) |
| admin@2OyvG.onmicrosoft.com | 10,373 | US | May-Jun 2020 | **FRAUD** — Random admin, random tenant names |
| admin@BaefA.onmicrosoft.com | 9,584 | US | Jun 2020 | **FRAUD** — Same botnet pattern |
| admin@eh5OS.onmicrosoft.com | 9,333 | US | Jun 2020 | **FRAUD** — Same botnet pattern |
| admin@ehC1nBtalEanWmAl7GJy.onmicrosoft.com | 8,340 | US | May 2020 | **FRAUD** — Same botnet pattern |
| admin@eScvp.onmicrosoft.com | 8,032 | US | Jun 2020 | **FRAUD** — Same botnet pattern |
| Licenses@infrainbox.io | 7,955 | US | Nov 2024 - Oct 2025 | **FRAUD** — Same pattern as hypertide.io |
| admin@miBT5.onmicrosoft.com | 7,633 | US | Jun 2020 | **FRAUD** — Same botnet pattern |
| admin233@MuBVk4MFwd5TdzeQjXvP1dDTBTi.onmicrosoft.com | 7,373 | US | May 2020 | **FRAUD** — Long random admin name |
| blain@thorshammer.ai | 6,650 | CA/US | Oct 2024 - Oct 2025 | **Investigate** — Company patterns |
| admin233@vMhXvNtqNY09sh1IB721MN4IW5J.onmicrosoft.com | 5,697 | US | May 2020 | **FRAUD** — Long random admin name |

**WUS June 2020 Botnet Subtotal**: ~66,365 tenants across 8 random admin@*.onmicrosoft.com accounts (May 30 - Jun 5, 2020 — 6 days)

### AUS Cluster (idsharedaus.australiacentral.kusto.windows.net)

| Admin Email | Tenants | Countries | Period | Assessment |
|-------------|---------|-----------|--------|------------|
| hajcina6@gmail.com | 3,167 | AU | Sep 24-29, 2025 | **FRAUD** — All named "TELSTRA CORPORATION LIMITED" (brand impersonation) |
| bills@havealook.com.au | 2,070 | AU | Sep 2023 - Feb 2024 | **FRAUD** — Auto-generated .com.au domain names |
| jolivaru@fxzig.com | 602 | AU | Sep 8-11, 2025 | **FRAUD** — Generic single-word names |

### JPN Cluster (idsharedjpn.japaneast.kusto.windows.net)

Mostly legitimate Japanese resellers (icsics.co.jp, azbil.com, otsuka-shokai.co.jp). No clearly fraudulent rings detected at the ≥50 tenant threshold.

---

## Storage Quantification Notes

- **ODSPFAB Kusto direct access**: 403 Forbidden for user principal — cannot query actual storage usage
- **FAB MCP tenant info**: Returns "Tenant not found" for ring tenants — none provisioned SPO or tracked by FAB
- **D2K QuotaAmount**: Used as proxy — shows allocated quota (not actual usage)
- **Actual storage consumed** will require ODSPFAB access or SpoProd.RequestUsage queries (also 403 currently)
- To get actual storage data, request ODSPFAB Kusto reader access for `fabdardb` database

---

## Remediation Plan

### Phase 1: Immediate Action — APAC Priority Rings (8,932 tenants)

1. **Ingest all ring tenants into FAB** using `ingest_tenants` API with reason code for fraud ring detection
2. **Block Priority 1 (Hamter)** — 3,749 VN tenants, 12-day burst, clearly automated
3. **Block Priority 2 (April 2022 Burst)** — 4,498 CN tenants, 4 years undetected
4. **Block Priority 3 (shheqing.com)** — 685 CN/HK tenants, actively growing (stop bleeding first)

### Phase 2: Global Ring Remediation

5. **WUS June 2020 Botnet** — ~66,365 tenants, verify not Microsoft test infra, then block
6. **WUS hypertide.io + infrainbox.io** — ~21,682 tenants, fake US company pattern
7. **EU treeveinsmedia.com** — 6,862 tenants, Morocco domain farming
8. **AUS hajcina6@gmail.com + havealook + jolivaru** — ~5,839 tenants

### Phase 3: Investigation Required

9. **sdsd@dsdsd.com** (WUS) — 212,338 tenants — needs deep investigation (could be test infra)
10. **pascal.landre@laposte.net** (WUS) — 22,748 tenants
11. **soporte-kitdigital@fractalia.es** (EU) — 10,740 tenants — verify if Kit Digital program
12. **blain@thorshammer.ai** (WUS) — 6,650 tenants

### Detection Gap Recommendations

- **Add TechnicalNotificationMail clustering to FAB automated detection** — none of these 9,000+ APAC tenants were detected
- **Rate limit check**: Flag when single admin email creates >50 tenants in <30 days
- **Pattern check**: Flag randomized email addresses (high entropy username + domain)
- **Sequential naming check**: Flag hamter1/hamter2/hamterN patterns in onmicrosoft.com domains
- **Cross-shard detection**: Currently no cross-shard admin clustering — consider federated query

---

## Data Files

Full tenant ID lists for each ring are available from the D2K queries executed during this investigation. To extract for bulk ingestion:

```kql
// Hamter Ring - 3,749 tenants
Company
| mv-expand email = TechnicalNotificationMail
| where tostring(email) contains 'hamter'
| where tostring(email) startswith 'admin@hamter' or tostring(email) startswith 'guytejydt@hamter'
| distinct TenantId

// April 2022 Burst Ring - 4,498 tenants
let aprilBurstEmails = dynamic([
  'E0ngrb6Q2K@s8k4XL6ENv.com','pfgHsWB3dH@yqymeef47F.com',
  '5FbXNPrqDn@a089PPGs85.com','2ER0O2f6uq@7i6nAXYNLz.com',
  '2v2A5N3lCT@JxRD5R4bDS.com','o6VOLimdwY@eHZnRcWwCC.com',
  'fsuwuZthsI@afU7JRSv0M.com','rQznrmFgcA@5KZGmhAExy.com',
  'IbCnEL9SSP@kDM5ZRZBBO.com']);
Company
| mv-expand email = TechnicalNotificationMail
| where tostring(email) in (aprilBurstEmails)
| distinct TenantId

// shheqing.com Ring - 685 tenants
Company
| mv-expand email = TechnicalNotificationMail
| where tostring(email) in ('wuqc@shheqing.com', 'pangcx@shheqing.com')
| distinct TenantId
```

All queries run against: `idsharedapac.southeastasia.kusto.windows.net / d2kredacted`
