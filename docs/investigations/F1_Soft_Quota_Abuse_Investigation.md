# F1 License Soft-Quota Abuse — Investigation Report

**Investigation Date:** April 9, 2026  
**Investigator:** Varun V  
**Scope:** F1-licensed tenants exploiting soft-quota enforcement gap  
**ICM Ticket:** [776384949](https://portal.microsofticm.com/imp/v5/incidents/details/776384949/summary)  
**Status:** REMEDIATION IN PROGRESS — 11 of 12 tenants ingested into FAB (RC 106, UseCaseType 7)  
**Updated:** April 9, 2026 — all tenants ingested into FAB for ABUSE-READONLY-BLOCK-DELETE

---

## Executive Summary

A systematic investigation into F1 (Frontline/Kiosk) license abuse uncovered:

1. A **10-tenant coordinated ring in Amsterdam, Netherlands** storing **1.36 PB** combined
2. An **actively uploading piracy CDN in China** (`24098c20`) storing **135 TB** of video content, pumping in **98 TB of ingress** over 5 weeks — **the first confirmed actively-filling F1 abuser**
3. An independent F1 abuser in Hong Kong (BANGUMZIP, 28 TB)

**Key findings across all 12 F1 tenants:**
- Pay **~$2.25/user/month** (F1 license) for a single seat
- Have a **1 TB storage quota** but store **28–164 TB each** (27–160x overage)
- **11 newly ingested into FAB** (RC 106, UseCaseType 7 — ABUSE-READONLY-BLOCK-DELETE) on April 9, 2026
- 1 already in FAB as TYPE1 (stalled since April 1, 2026) — `24098c20`
- Exploit the **soft-quota enforcement gap**: SPO does not hard-block uploads beyond the storage limit

**Total impact: ~1.52 PB stored on ~$27/month in F1 licenses** ($0.018/TB/month vs Azure Blob's ~$20/TB/month — a **1,111x cost arbitrage**).

Additionally, the RequestUsage sweep for single-seat commercial tenants with high I/O revealed a **broader ecosystem of low-cost SKU abuse** (OneDrive Plan 1/2, Business Basic, SPO Plan 1) beyond F1 — documented in the Appendix.

---

## The Soft-Quota Problem

F1 (formerly "Kiosk") is the cheapest Microsoft 365 commercial SKU:
- **ODB entitlement:** 2 GB per user (the lowest tier)
- **SPO tenant pool:** 1 TB base allocation
- **Price:** ~$2.25/user/month

SPO storage limits are enforced as **soft quotas**: tenants receive warnings when they exceed their allocation, but **uploads are not blocked**. This creates a trivially exploitable arbitrage:

1. Buy 1× F1 license ($2.25/mo)
2. Get 1 TB quota (soft limit)
3. Upload unlimited data — no hard enforcement
4. Store petabytes at below-cloud-storage rates

The NL ring has been doing this since **September 2023** — over **2.5 years** with zero detection or remediation.

---

## Ring A: NL Amsterdam F1 Ring (10 Tenants, 1.36 PB)

### Ring Fingerprint
| Attribute | Value |
|-----------|-------|
| **SKU** | F1 (Frontline/Kiosk) |
| **Country** | Netherlands (NL) |
| **City** | Amsterdam / Holland (all 10) |
| **Seats** | 1 per tenant |
| **Quota** | 1,024 GB (1 TB) per tenant |
| **ODB Used** | 0 GB (all storage in SPO sites) |
| **ODB Quota** | 2 GB per tenant |
| **Status** | Paid |
| **Custom Domain** | None (onmicrosoft-only) |
| **Category** | Commercial |
| **FAB Status** | **Ingested** — RC 106, UseCaseType 7, ICM 776384949 (April 9, 2026) |

### Phase 1: September 2023 — "gel\*" Domain Pattern

Created Sep 17–19, 2023. Dutch language registration. Different NL regions.

| # | Tenant ID | Name | Domain | Region | Storage | Overage | Created |
|---|-----------|------|--------|--------|---------|---------|---------|
| 1 | `13170a28` | **JANAVTRE** | gelemi.onmicrosoft.com | NL-FL | **164 TB** | 160x | 2023-09-17 |
| 2 | `7ffd2e07` | **HAGYEA** | gelem.onmicrosoft.com | NL-ZE | **163 TB** | 159x | 2023-09-17 |
| 3 | `0c358e9d` | **AKANDRE** | gelsem.onmicrosoft.com | NL-DR | **162 TB** | 158x | 2023-09-19 |
| 4 | `5a6caea5` | **YEAK** | gelsemi.onmicrosoft.com | NL-NH | **158 TB** | 154x | 2023-09-19 |
| | | | **Phase 1 Total** | | **647 TB** | **158x avg** | |

### Phase 2: November 2023 — "kal\*/ka\*" Domain Pattern

Created Nov 10–23, 2023. English language registration. All NL-UT region.

| # | Tenant ID | Name | Domain | Region | Storage | Overage | Created |
|---|-----------|------|--------|--------|---------|---------|---------|
| 5 | `b06e42ae` | **NAJAL** | kalolm.onmicrosoft.com | NL-UT | **121 TB** | 118x | 2023-11-14 |
| 6 | `e43b72f9` | **KAKAMA** | kakam.onmicrosoft.com | NL-UT | **120 TB** | 117x | 2023-11-23 |
| 7 | `84b88324` | **NOAJL** | kaloki.onmicrosoft.com | NL-UT | **119 TB** | 116x | 2023-11-13 |
| 8 | `b83fb632` | **KALRA** | kalakm.onmicrosoft.com | NL-UT | **118 TB** | 115x | 2023-11-10 |
| 9 | `3de6a707` | **DABA** | kaldar.onmicrosoft.com | NL-UT | **116 TB** | 113x | 2023-11-19 |
| 10 | `979316bb` | **COKLAN** | kalakmi.onmicrosoft.com | NL-UT | **116 TB** | 113x | 2023-11-10 |
| | | | **Phase 2 Total** | | **710 TB** | **115x avg** | |

### Ring Total: 1,357 TB (~1.33 PB) on 10 TB quota — **136x average overage**

### Ring Correlation Evidence

**Domain naming patterns:**
- Phase 1: gel-emi, gel-sem, gel-semi — all share "gel" prefix with phonetically similar suffixes
- Phase 2: kal-olm, kal-oki, kal-akm, kal-akmi, kal-dar, ka-kam — all share "kal/ka" prefix
- Cross-phase: "gelsemi" (Phase 1) ↔ "kalakmi" (Phase 2) — similar suffix construction style

**Tenant name patterns:**
- All gibberish, 4-7 uppercase characters
- Phase 2 has near-anagram pairs: NAJAL ↔ NOAJL (same letters rearranged)

**Registration behavior:**
- Phase 1: `nl` language, different NL regions (FL, DR, NH) — geo-distributed registration
- Phase 2: `en` language, all NL-UT — consolidated registration
- This suggests operator learned to simplify after Phase 1

**Identical profile:**
- All: 1 seat, F1, Paid, Amsterdam, 1 domain, 1 subscription, 0 ODB used, RegularTenant, AADP=1

### Traffic Analysis

RequestUsage returns **zero rows** for all 9 ring tenants in the Mar–Apr 2026 timeframe. This means either:
1. Bulk upload completed months ago and data is now dormant/cold storage
2. Access occurs through APIs not captured by RequestUsage
3. Data is being served through a mechanism we're not monitoring

The **zero-traffic paradox** (164 TB stored, 0 recent activity) itself is a strong abuse indicator — no legitimate F1 frontline-worker tenant stores 164 TB and then goes completely silent.

---

## Tenant B: DEFAULT DIRECTORY / liangsheng32126 (China, 135 TB) — ACTIVE PIRACY CDN

| Attribute | Value |
|-----------|-------|
| **Tenant ID** | `24098c20` |
| **Name** | DEFAULT DIRECTORY |
| **Domain** | liangsheng32126.onmicrosoft.com |
| **Country** | China (CN), Huanggang City |
| **SKU** | F1 |
| **Storage** | **135,002 GB (~135 TB)** |
| **Quota** | 1,024 GB (1 TB) |
| **Overage** | 132x |
| **Created** | 2026-01-26 (only ~2.5 months old) |
| **FAB Status** | **TYPE1 — identified Apr 1, NO REMEDIATION** |
| **FraudId** | 148129 |

### RequestUsage Profile (Mar 1 – Apr 9, 2026)
| Metric | Value |
|--------|-------|
| Total Requests | **6.6M** |
| Unique Users | 7 |
| **Total Ingress** | **98.4 TB** (actively filling at ~2.5 TB/day) |
| **Total Egress** | **29.7 TB** (actively serving content) |
| Blob Reads | 40.3M |
| Blob Writes | 63.4M |
| Partial Content (206) | **2.2M** (streaming pattern) |
| Errors | 271K (mostly client 4xx) |

### Top Apps (CRITICAL)
1. `Other` — bulk operations
2. `MeTA` — metadata service
3. `lavf` — **FFmpeg** (video transcoding/streaming framework)
4. `Unknown`
5. `guzzlehttp` — PHP HTTP client (likely custom web app)
6. `python-requests` — Python automation
7. `MS Search Robot`
8. **`rclone`** — cloud-sync abuse tool
9. `applecoremedia` — iOS video player requesting content
10. `microsoft.office365portal`

### Top File Types
**MP4, MKV, TS, AVI, FLV, MP3, ISO, PNG, JPG** — This is a **video piracy and media distribution operation**. The combination of rclone uploads + FFmpeg/lavf processing + applecoremedia playback confirms a full piracy CDN pipeline: upload → transcode → serve to mobile users.

### Severity: CRITICAL
- **Actively uploading 2.5 TB/day** with no signs of stopping
- Already at 135 TB after just 2.5 months of existence
- At current rate, will exceed 200 TB within a month
- TYPE1 detection fired but stuck — same remediation pipeline gap as MISTYCLOUD
- Full piracy infrastructure: rclone ingest → FFmpeg process → Apple/Android streaming

---

## Tenant C: BANGUMZIP (Hong Kong, 28 TB) — Anime/Media Hosting

| Attribute | Value |
|-----------|-------|
| **Tenant ID** | `cba99602` |
| **Name** | BANGUMZIP |
| **Domain** | bangumi.zip (custom domain) |
| **Country** | Hong Kong (HK) |
| **City** | EL PASO (likely spoofed — Texas city on HK tenant) |
| **SKU** | F1 |
| **Storage** | **27,862 GB (~28 TB)** |
| **Quota** | 1,024 GB (1 TB) |
| **Overage** | 27x |
| **ODB Quota** | 1,026 GB (anomalously high for F1) |
| **ODB Sites** | 2 |
| **Created** | 2025-08-05 |
| **Language** | zh-CHT (Traditional Chinese) |
| **FAB Status** | **NOT IN FAB** |

### BANGUMZIP Profile
- **Custom domain "bangumi.zip"** — "Bangumi" (番組) is Japanese for "program/show", commonly used for anime/media tracking sites. ".zip" TLD is a cheap Google domain. This strongly suggests **media/anime file hosting**.
- **City mismatch**: "EL PASO" (Texas) registered on an HK/Traditional Chinese tenant — likely VPN or fake geo
- **Active traffic** (Mar–Apr 2026): 1.09M requests, 4 users, 36 apps
  - Top apps: `androiddownloadmanager`, `OneDriveSync`, `OneDriveAndroidApp` — mobile download pattern
  - 1,037,990 **unauthorized requests** (95.5% of all traffic) — probing/scanning behavior
  - File types: DOCX, PNG, JPG
  - 174 partial content (206) responses — some streaming
- **Not part of NL ring** — different country, different language, custom domain, much newer tenant, active traffic pattern

---

## Systemic Issues

### 1. Soft-Quota Enforcement is Not Enforcement
The F1 storage quota of 1 TB is purely advisory. No upload blocking occurs at any overage level. A single F1 seat can accumulate 164 TB (160x quota) over 2.5 years with zero friction. This is not a bug in one tenant — it's a **platform-wide architectural gap**.

### 2. F1 Has No FAB Detection Rules  
None of these 10 tenants were detected by any existing FAB rule. The current rule set apparently has no coverage for:
- F1/Kiosk SKU abuse
- Paid single-seat commercial tenants with extreme storage overage
- Low-cost SKU arbitrage patterns

### 3. 2.5 Years of Undetected Accumulation
The oldest NL ring tenants were created in September 2023. They've been storing data for **~30 months** with zero detection, zero remediation, and zero enforcement of any kind.

### 4. The Economics Problem
| Metric | NL Ring (10 tenants) | CN Piracy CDN | BANGUMZIP | Total |
|--------|---------------------|---------------|-----------|-------|
| Monthly cost | ~$22.50 | ~$2.25 | ~$2.25 | **~$27** |
| Storage used | 1,357 TB | 135 TB | 28 TB | **1,520 TB** |
| Cost per TB/mo | $0.017 | $0.017 | $0.080 | **$0.018** |
| Azure Blob equivalent | ~$27,140/mo | ~$2,700/mo | ~$560/mo | ~$30,400/mo |
| **Cost ratio** | **1,206x cheaper** | **1,200x** | **249x** | **1,126x** |

---

## Kusto Detection Queries

### Query 1: Find All F1 Tenants Over Quota (D2K / TENANT_INFO)

```kql
// F1 Soft-Quota Abuse Detection — Full Sweep
// Target: OdspFabKusto → fabdardb
TENANT_INFO
| where TENANT_LEVEL == "F1"
    and TENANT_TOTAL_DISK_USED_GB > STORAGE_LIMIT_GB
| extend OverageRatio = round(todouble(TENANT_TOTAL_DISK_USED_GB) / todouble(STORAGE_LIMIT_GB), 1)
| project 
    SITE_SUBSCRIPTION_ID,
    TENANT_NAME,
    CURRENT_DEFAULT_DOMAIN,
    COUNTRY_CODE,
    CITY,
    TENANT_TOTAL_DISK_USED_GB,
    STORAGE_LIMIT_GB,
    OverageRatio,
    ODBSITE_COUNT,
    ODBDISKUSED_SUM_GB,
    HAS_EVER_PAID,
    TENANT_STATUS,
    TENANT_CREATED_DATE,
    LICENSES_ENABLED,
    HAS_ONLY_ONMICROSOFT_DOMAIN,
    D2KINSTANCE
| order by TENANT_TOTAL_DISK_USED_GB desc
```

### Query 2: F1 Mega-Hoarder Detection (>10x Quota)

```kql
// High-confidence F1 abuse: tenants storing >10x their quota
TENANT_INFO
| where TENANT_LEVEL == "F1"
    and TENANT_TOTAL_DISK_USED_GB > (STORAGE_LIMIT_GB * 10)
    and TENANT_STATUS == "Paid"
| extend OverageRatio = round(todouble(TENANT_TOTAL_DISK_USED_GB) / todouble(STORAGE_LIMIT_GB), 1)
| summarize 
    TenantCount = count(),
    TotalStorageTB = round(sum(todouble(TENANT_TOTAL_DISK_USED_GB)) / 1024, 1),
    AvgOverage = round(avg(OverageRatio), 1),
    MaxOverage = max(OverageRatio)
    by COUNTRY_CODE, CITY
| order by TotalStorageTB desc
```

### Query 3: NL F1 Ring — RequestUsage Profiling

```kql
// Run against: spogdskustocluster.eastus2.kusto.windows.net / SpoProd
let nlF1Ring = dynamic([
    '13170a28-797c-400a-a7a7-a5acf3a5946b',
    '0c358e9d-916f-4c7b-9fb9-fc8b4905a576',
    '5a6caea5-b544-4f60-a8d5-304200b24373',
    'b06e42ae-3d8f-41a3-aa50-9190f029f60d',
    'e43b72f9-c96e-4ed0-b11f-4af5427dacd6',
    '84b88324-71c2-4431-b718-505d90fac6fc',
    'b83fb632-c928-49a5-aa16-8039dc3acb01',
    '3de6a707-d787-4bc8-a447-578b23dc9668',
    '979316bb-f41e-4422-860e-571df5991e3f'
]);
RequestUsage
| where siteSubscriptionId in (nlF1Ring)
| summarize 
    totalEgressGB = round(sum(blobReadBytes) / 1073741824.0, 2),
    totalIngressGB = round(sum(blobWriteBytes) / 1073741824.0, 2),
    totalRequests = count(),
    uniqueApps = dcount(app),
    uniqueUsers = dcount(user)
    by siteSubscriptionId
| order by totalEgressGB desc
```

### Query 4: Broader Low-Cost SKU Abuse Detection

```kql
// Find ALL low-cost SKU tenants (F1, F3, Business Basic, SPO Plan 1)
// with disproportionate storage — the "soft-quota exploitation class"
TENANT_INFO
| where TENANT_LEVEL in ("F1", "F3", "SHAREPOINT (PLAN 1)", "BUSINESS BASIC")
    and TENANT_TOTAL_DISK_USED_GB > (STORAGE_LIMIT_GB * 5)
    and TENANT_STATUS == "Paid"
    and LICENSES_ENABLED <= 5
| extend 
    OverageRatio = round(todouble(TENANT_TOTAL_DISK_USED_GB) / todouble(STORAGE_LIMIT_GB), 1),
    StorageTB = round(todouble(TENANT_TOTAL_DISK_USED_GB) / 1024, 1)
| project 
    SITE_SUBSCRIPTION_ID,
    TENANT_NAME,
    COUNTRY_CODE,
    CITY,
    TENANT_LEVEL,
    StorageTB,
    STORAGE_LIMIT_GB,
    OverageRatio,
    LICENSES_ENABLED,
    TENANT_CREATED_DATE,
    HAS_ONLY_ONMICROSOFT_DOMAIN,
    D2KINSTANCE
| order by OverageRatio desc
```

---

## Proposed FAB Detection Rule

### Rule F1-1: F1/Kiosk Single-Seat Soft-Quota Exploiter

```
TENANT_LEVEL == "F1"
AND LICENSES_ENABLED <= 2
AND TENANT_TOTAL_DISK_USED_GB > (STORAGE_LIMIT_GB * 10)
AND TENANT_STATUS == "Paid"
AND HAS_CUSTOM_DOMAIN == FALSE
```

**Expected coverage:** All 9 NL ring tenants + BANGUMZIP (with custom domain exception)  
**Estimated FP:** Very low — no legitimate F1 frontline worker tenant stores 10x their quota  
**Recommended action:** ABUSE-READONLY-BLOCK-DELETE_15DAYS

### Rule F1-2: Multi-Tenant F1 Ring Detection

```
TENANT_LEVEL == "F1"
AND CITY matches across 3+ tenants
AND LICENSES_ENABLED == 1
AND TENANT_TOTAL_DISK_USED_GB > STORAGE_LIMIT_GB
AND HAS_ONLY_ONMICROSOFT_DOMAIN == TRUE
```

**Expected coverage:** NL Amsterdam ring (9 tenants)

---

## Recommended Actions

### ✅ Completed: FAB Ingestion (April 9, 2026)

**ICM:** [776384949](https://portal.microsofticm.com/imp/v5/incidents/details/776384949/summary)  
**Reason Code:** 106 (Adhoc Investigation)  
**UseCaseType:** 7 (ABUSE-READONLY-BLOCK-DELETE)  
**Review Required:** No  

| # | Tenant ID | Name | Storage | FAB Status | Result |
|---|-----------|------|---------|------------|--------|
| 1 | `13170a28` | JANAVTRE | 164 TB | **INGESTED** | ✅ New ingestion |
| 2 | `7ffd2e07` | HAGYEA | 163 TB | **INGESTED** | ✅ New ingestion |
| 3 | `0c358e9d` | AKANDRE | 162 TB | **INGESTED** | ✅ New ingestion |
| 4 | `5a6caea5` | YEAK | 158 TB | **INGESTED** | ✅ New ingestion |
| 5 | `24098c20` | DEFAULT DIRECTORY | 135 TB | **TYPE1 (pre-existing)** | ⚠️ Already in FAB — needs manual re-escalation |
| 6 | `b06e42ae` | NAJAL | 121 TB | **INGESTED** | ✅ New ingestion |
| 7 | `e43b72f9` | KAKAMA | 120 TB | **INGESTED** | ✅ New ingestion |
| 8 | `84b88324` | NOAJL | 119 TB | **INGESTED** | ✅ New ingestion |
| 9 | `b83fb632` | KALRA | 118 TB | **INGESTED** | ✅ New ingestion |
| 10 | `3de6a707` | DABA | 116 TB | **INGESTED** | ✅ New ingestion |
| 11 | `979316bb` | COKLAN | 116 TB | **INGESTED** | ✅ New ingestion |
| 12 | `cba99602` | BANGUMZIP | 28 TB | **INGESTED** | ✅ New ingestion |

### Short-Term: Run Query 1 for Full F1 Abuse Scope
The 10 tenants found here were from the existing DS triage data. Running Query 1 against the full TENANT_INFO table will likely uncover **many more** F1 abusers platform-wide.

### Medium-Term: Escalate Soft-Quota Gap to SPO Engineering
The fundamental issue is that storage limits are advisory-only for paid tenants. Either:
1. Implement hard quota enforcement for F1/Kiosk SKU at the SPO layer
2. Add a "storage overage ratio" signal to FAB for real-time detection
3. Create a billing-tier-based maximum storage ceiling (e.g., F1 hard cap at 5 TB)

---

## Tenant IDs for Ingestion

```
13170a28-797c-400a-a7a7-a5acf3a5946b
7ffd2e07-754d-4214-a5f6-3245674a4c78
0c358e9d-916f-4c7b-9fb9-fc8b4905a576
5a6caea5-b544-4f60-a8d5-304200b24373
24098c20-486f-4669-8f26-76d5d6927865
b06e42ae-3d8f-41a3-aa50-9190f029f60d
e43b72f9-c96e-4ed0-b11f-4af5427dacd6
84b88324-71c2-4431-b718-505d90fac6fc
b83fb632-c928-49a5-aa16-8039dc3acb01
3de6a707-d787-4bc8-a447-578b23dc9668
979316bb-f41e-4422-860e-571df5991e3f
cba99602-6011-4401-b784-4c07f6d7937d
```

---

## Appendix: Full Tenant Details (FAB Query Output)

| Tenant ID | Name | Domain | CC | City | Region | Lang | Level | Storage GB | Quota GB | ODB Used | ODB Quota | Created | Status | FAB |
|-----------|------|--------|----|------|--------|------|-------|-----------|----------|----------|-----------|---------|--------|-----|
| `13170a28` | JANAVTRE | gelemi.onmicrosoft.com | NL | AMSTERDAM | NL-FL | nl | F1 | 164,133 | 1,024 | 0 | 2 | 2023-09-17 | Paid | **NONE** |
| `7ffd2e07` | HAGYEA | gelem.onmicrosoft.com | NL | HOLLAND | NL-ZE | nl | F1 | 162,690 | 1,024 | 0 | 2 | 2023-09-17 | Paid | **NONE** |
| `0c358e9d` | AKANDRE | gelsem.onmicrosoft.com | NL | AMSTERDAM | NL-DR | nl | F1 | 162,036 | 1,024 | 0 | 2 | 2023-09-19 | Paid | **NONE** |
| `5a6caea5` | YEAK | gelsemi.onmicrosoft.com | NL | AMSTERDAM | NL-NH | nl | F1 | 157,861 | 1,024 | 0 | 2 | 2023-09-19 | Paid | **NONE** |
| `24098c20` | DEFAULT DIRECTORY | liangsheng32126.onmicrosoft.com | CN | HUANGGANG | HB | en | F1 | 135,002 | 1,024 | 0 | 2 | 2026-01-26 | Paid | **TYPE1 (stalled)** |
| `b06e42ae` | NAJAL | kalolm.onmicrosoft.com | NL | AMSTERDAM | NL-UT | en | F1 | 121,219 | 1,024 | 0 | 2 | 2023-11-14 | Paid | **NONE** |
| `e43b72f9` | KAKAMA | kakam.onmicrosoft.com | NL | AMSTERDAM | NL-UT | en | F1 | 120,213 | 1,024 | 0 | 2 | 2023-11-23 | Paid | **NONE** |
| `84b88324` | NOAJL | kaloki.onmicrosoft.com | NL | AMSTERDAM | NL-UT | en | F1 | 119,351 | 1,024 | 0 | 2 | 2023-11-13 | Paid | **NONE** |
| `b83fb632` | KALRA | kalakm.onmicrosoft.com | NL | AMSTERDAM | NL-UT | en | F1 | 117,861 | 1,024 | 0 | 2 | 2023-11-10 | Paid | **NONE** |
| `3de6a707` | DABA | kaldar.onmicrosoft.com | NL | AMSTERDAM | NL-UT | en | F1 | 116,062 | 1,024 | 0 | 2 | 2023-11-19 | Paid | **NONE** |
| `979316bb` | COKLAN | kalakmi.onmicrosoft.com | NL | AMSTERDAM | NL-UT | en | F1 | 115,795 | 1,024 | 0 | 2 | 2023-11-10 | Paid | **NONE** |
| `cba99602` | BANGUMZIP | bangumi.zip | HK | EL PASO | TX | zh-CHT | F1 | 27,862 | 1,024 | 0 | 1,026 | 2025-08-05 | Paid | **NONE** |

---

## Appendix B: RequestUsage Sweep — Top 50 Single-Seat Active Uploaders (7-day window)

The following query was run against SpoProd RequestUsage for all single-seat commercial tenants with >100 GB ingress or >500 GB egress in the last 7 days. This caught active abuse across ALL low-cost SKUs, not just F1:

### Notable Non-F1 Findings from the Sweep

| Tenant ID | Name | CC | SKU | Storage | 7d Ingress | 7d Egress | Notes |
|-----------|------|----|-----|---------|------------|-----------|-------|
| `ec0c02cc` | TAKIMURA WEB OFFICE | JP | SPO Plan 1 | **243 TB** | 3.6 TB | 2.0 TB | JP single-seat, 243x quota, active upload |
| `1bef92c5` | LEONARD WONG | SG | Biz Basic | **102 TB** | 2.9 TB | 0.09 TB | SG, `leonardwong.tech`, 102x quota, ingress-heavy |
| `0c8558a7` | 株式会社乾商事 | JP | ODB Plan 2 | **4.2 TB** | 8.5 TB | 0.12 TB | JP, 4x quota, massive ingress vs storage |
| `2d2207e6` | LIKOM CMS SDN BHD | MY | ODB Plan 2 | **4.4 TB** | 8.2 TB | 0.19 TB | MY Melaka, 4x quota, `likomcloud` |
| `ae2eaa3c` | GTS DISTRIBUIDORA | BR | ODB Plan 2 | **3.9 TB** | 4.6 TB | 1.4 TB | BR Jundiaí, 4x quota, created Feb 2026 |

These suggest the soft-quota problem extends well beyond F1 to OneDrive Plan 1/2 and Business Basic SKUs. TAKIMURA (243 TB on SPO Plan 1) and LEONARD WONG (102 TB on Biz Basic) are particularly egregious.
