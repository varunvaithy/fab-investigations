# Ring 2: Japan-Hosted Storage Abuse — Investigation Report

**Investigation Date:** April 8, 2026  
**ICM:** 775773500  
**Ring Size:** 50 tenants | **Total Egress:** 120.2 TB/wk  
**Hosting Region:** Japan East  
**Status:** Sub-classification complete — action phase

---

## Executive Summary

Ring 2 is **NOT a coordinated ring** like Ring 1 (FAMILIA CONFEITAR). It is a geographic bucket of 50 tenants hosted in Japan East, all abusing SPO/OneDrive for personal cloud storage. The tenants are **independent operators** with no shared admin, domain pattern, or infrastructure — but they share common abuse archetypes.

**Key Discovery:** Two SEEMSONLINE-class mega-abusers found storing **693 TB** and **332 TB** respectively on $12.50/month SPO Plan 2 subscriptions. A third tenant (QAZHB) stores **125 TB** on Business Basic Free with 23.8 TB/wk egress.

**Total Storage Consumed (profiled tenants):** ~1.58 PB across 50 tenants  
**Total Revenue:** ≈ $37.50/month (3 paid tenants) + $0 from 47 free/trial tenants

---

## Sub-Classification Taxonomy

### Category A: SPO Plan 2 Mega-Abusers (SEEMSONLINE Class)
**Priority: CRITICAL — Ingest immediately**  
**Pattern:** Paid SPO Plan 2 ($12.50/mo), 1 seat, 100-700x quota overage, rclone-based, individual operators

| Tenant ID | Name | Country | Stored | Quota | Overage | Egress/wk | FAB Status |
|-----------|------|---------|--------|-------|---------|-----------|------------|
| `c177d029` | SEEMSONLINE COMP. | HK (fake) | **693 TB** | 1 TB | 693x | 347 GB (ingress 41.5 TB!) | **NOT IN FAB** |
| `ee62ef68` | 星火计划 (Spark Plan) | CN Shanghai | **332 TB** | 1 TB | 332x | 202 GB | **ReadOnly** (FraudId 133907, Mar 27) |
| `0a79f022` | MSI GSC ENG DEPT. | CN Shenzhen | **103 TB** | 26.7 TB | 3.9x | 1.6 TB | **NOT IN FAB** |

**Notes:**
- SEEMSONLINE: rclone from OVH France (Roubaix/Paris), Chinese consumer ISP downloads. Actively uploading 6-12 TB/day. **TIME SENSITIVE.**
- 星火计划: Already in ReadOnly — no further action needed.
- MSI GSC: Domain `gcsrma.onmicrosoft.com`, 5 subscriptions, 32 ODB sites, Shenzhen. **Possible legitimate MSI (Micro-Star International) engineering dept.** Uses Files/Browser/OneDriveSync — normal apps. 1.6 TB egress is moderate. **Needs manual review before action.** Could be real hardware company QA dept.

### Category B: Business Basic Free Mega-Abuser
**Priority: HIGH**

| Tenant ID | Name | Country | Stored | Quota | Egress/wk | FAB Status |
|-----------|------|---------|--------|-------|-----------|------------|
| `380f38c1` | QAZHB | SG | **125 TB** | 1.2 TB | **23.8 TB** | **NOT IN FAB** |

**Profile:** Gibberish name, SG-registered, Business Basic Free (non-paid), domain `qazhb.onmicrosoft.com`, rclone+dalvik. Created Sept 2021. 2nd highest egress in entire Ring 2. Zero revenue. This is a massive pure content distribution node.

### Category C: E5 Dev Heavy Hoarders (>50 TB stored)
**Priority: HIGH — E5DEV-OVERQUOTA ineffective**

| Tenant ID | Name | Country | Stored | Quota | Egress/wk | FAB Status |
|-----------|------|---------|--------|-------|-----------|------------|
| `ff9948e9` | STAR科技有限公司 | CN | **82.6 TB** | 1.27 TB | 115 GB | E5DEV-OVERQUOTA **rolled back** (FraudId 89364) |

**Notes:** Domain `zedong.onmicrosoft.com`, 21 ODB sites, rclone+synology+python-requests. E5DEV notification sent Aug 2024 → rolled back Sep 2024. Tenant grew from whatever it was to 82.6 TB unimpeded. **Detection rule gap:** E5DEV-OVERQUOTA rollbacks leave mega-hoarders untouched.

### Category D: E5 Dev "MSFT" Impersonation Cluster
**Priority: MEDIUM — Batch ingestible**  
**Pattern:** Tenant named "MSFT", SG-registered, E5 Dev Trial, $0, gibberish .onmicrosoft.com domain, zh-CHS language, Chinese operators using Singapore for residency

| Tenant ID | Domain | Stored | Egress/wk | Ingress/wk | Primary App |
|-----------|--------|--------|-----------|------------|-------------|
| `2dd67a7e` | 4rzltv | 19.1 TB | **24.8 TB** | 22 GB | androiddownloadmanager |
| `991f0940` | techsivn.io.vn | 14.2 TB | 361 GB | 654 GB | synology/syncovery |
| `1eb06941` | vw50g | 14.3 TB | 110 GB | 588 GB | OneDriveSync |
| `1e88b76d` | syngm | 12.8 TB | 337 GB | 1.1 TB | OneDriveSync |
| `928e47d3` | 0n5jf | 9.2 TB | 315 GB | 953 GB | synology |
| `e3a72310` | vm4sh | 9.4 TB | 642 GB | 1.9 TB | OneDriveSync |
| `538d3959` | 8hg2jv | 10.5 TB | 812 GB | 1.7 TB | Nucleus/Browser |

**Total:** 7 tenants, 89.5 TB stored, ~27.4 TB egress/wk  
**Detection Rule Candidate:** `tenantName == "MSFT" AND country == "SG" AND SKU == E5Dev AND hasCustomDomain == FALSE`

### Category E: Chinese E5 Dev Individual Hoarders
**Priority: MEDIUM — Batch ingestible**  
**Pattern:** Individual Chinese operators, various names, E5 Dev Trial, $0, 5-21 TB stored

| Tenant ID | Name | Country/City | Stored | Egress/wk | Key App | Notes |
|-----------|------|-------------|--------|-----------|---------|-------|
| `5f71e89d` | WMOOV ENTERPRISES | HK | 20.9 TB | 458 GB | OneDriveSync | zh-CHT |
| `6e5b5819` | ALSTARWU | CN | 20.2 TB | 884 GB | OneDriveSync/onenote | |
| `739b8faa` | CHATBINGNB | HK | 19.4 TB | 2.2 TB | rclone/python-requests | |
| `ad77ebbd` | ABCDEOO | SG | 14.5 TB | 590 GB | **rclone** (2.6 TB ingress) | Active upload |
| `79d97ba8` | CHOOL | CN Guangzhou | 14.7 TB | 499 GB | androiddownloadmanager | E3 Dev (not E5) |
| `4e7d8579` | 淄博发发网络科技 | CN | 13.7 TB | 411 GB | rclone/air explorer | od.763333.xyz |
| `2887a029` | MINMINHUI | CN | 11.1 TB | 114 GB | **Cloudreve** | Self-hosted cloud |
| `39160764` | COOL | CN Fuzhou | 10.3 TB | 187 GB | rclone | **E3 Dev**, created Nov 2025 |
| `c24b172b` | DYUNSCOM | CN | 9.2 TB | 217 GB | python-requests | |
| `325590f0` | XIANAO | SG | 16.5 TB | 254 GB | androiddownloadmanager | aoliao.eu.org |
| `233582dc` | XDX1008 | TW Taipei | 14.4 TB | 243 GB | rclone/lavf | |
| `c00dbcf8` | 365 | CN | 8.9 TB | 767 GB | synology/python-requests | 2.1 TB ingress |
| `ca0cd372` | LESLIE | CN | 7.7 TB | 631 GB | synology | |
| `3d76e686` | MICROSOFT 365 | CN | 7.3 TB | 831 GB | word/OneDriveSync | v6.tm9.site |
| `739bd93d` | QWFROG | CN Changchun | 6.6 TB | 611 GB | OneDriveSync | 126354.xyz |
| `01118a50` | 广西简约信息科技 | CN Nanning | 6.4 TB | 4.2 TB | rclone/dalvik | 11101109.xyz |
| `57c59464` | ZQ0FP | SG | 8.1 TB | 255 GB | synology | |
| `5fe0f92c` | CLOUDCLOUD | MY | 9.4 TB | 228 GB | synology | |
| `7aa02550` | ZETX | SG (Hangzhou) | 7.0 TB | 177 GB | rclone | e5.zetx.tech |

**Total:** 19 tenants, ~225.3 TB stored

### Category F: Vietnamese Operators
**Priority: MEDIUM**

| Tenant ID | Name | Country | Stored | Egress/wk | Key App | FAB Status |
|-----------|------|---------|--------|-----------|---------|------------|
| `d4a7e56f` | BLOGCUAHIEU | VN | ~10 TB est | 10.9 TB | rclone | E5DEV-OVERQUOTA **rolled back** |
| `d84a5072` | FS (dungle) | VN | ~5 TB est | 4.7 TB | Browser/OneDrive | NOT IN FAB |
| `eacdec87` | LVD | VN | ~3 TB est | 967 GB | python-requests | NOT IN FAB |
| `90813241` | COGVND | VN | 9 TB | 293 GB | synology | NOT IN FAB |

**Notes:** Vietnamese domain patterns (techsivn.io.vn, dungle). BLOGCUAHIEU had E5DEV-OVERQUOTA notification rolled back and is now the 5th highest egress tenant in Ring 2.

### Category G: Content Concern / Known Rings
**Priority: HIGH (content policy)**

| Tenant ID | Name | Domain | Stored | FAB Status |
|-----------|------|--------|--------|------------|
| `ba704491` | **SUPERLOLI** | lolicandyhouse.top | 18.4 TB | E5DEV-OVERQUOTA **rolled back** (FraudId 89877) |
| `1e32c146` | ACGDB7 | acgdb7.onmicrosoft.com | ~10 TB | **Blocked** (FraudId 148105, Apr 1) |

**Notes:** SUPERLOLI domain name and content indicators suggest potentially illegal content hosting. E5DEV notification was rolled back — tenant is STILL ACTIVE with 18.4 TB. **Recommend escalation beyond standard abuse flow.** ACGDB7 is part of ACGDB anime piracy ring, already blocked.

### Category H: Already Remediated
**No action needed**

| Tenant ID | Name | FAB Status | Action Date |
|-----------|------|------------|-------------|
| `ee62ef68` | 星火计划 | ReadOnly | Mar 27, 2026 |
| `1e32c146` | ACGDB7 | Blocked | Apr 1, 2026 |
| `724c3654` | SRBUFF | ReadOnly | Prior |
| `005da870` | (unknown) | ReadOnly | Prior |

### Category I: E5DEV-OVERQUOTA Failures (Rolled-Back Notifications)
**Priority: HIGH — Detection gap**

| Tenant ID | Name | Stored | FraudId | Identified | Notification | Rollback |
|-----------|------|--------|---------|------------|-------------|----------|
| `ff9948e9` | STAR科技有限公司 | 82.6 TB | 89364 | Aug 7, 2024 | Aug 8, 2024 | Sep 19, 2024 |
| `ba704491` | SUPERLOLI | 18.4 TB | 89877 | Aug 10, 2024 | Aug 14, 2024 | Oct 15, 2024 |
| `129d9a20` | (unknown) | ~12 TB | — | — | — | rolled back |
| `d4a7e56f` | BLOGCUAHIEU | ~10 TB | — | — | — | rolled back |
| `e439db60` | DUANREN | ~5 TB | — | — | — | rolled back |

**SYSTEMIC ISSUE:** All 5 E5DEV-OVERQUOTA tenants had Day0 notifications sent in Aug 2024 → rolled back Sep-Oct 2024 → tenants continued hoarding for 6+ months untouched. Combined they now store ~127 TB. **This is a detection pipeline failure that should be escalated.**

---

## Remaining Unactionned Tenants (lower-tail, 100-200 GB egress)

These tenants in the 100-200 GB/wk egress range have not been individually profiled but follow the same E5 Dev pattern:

| Tenant ID | Egress/wk | Ingress/wk | Primary Apps |
|-----------|-----------|------------|-------------|
| `c4093ec3` | 207 GB | 347 GB | synology |
| `0c99cb2d` | 201 GB | 684 GB | NucleusFiles/OneDriveSync |
| `ba4c663a` | 187 GB | 322 GB | OneDriveSync |
| `a9642cdf` | 175 GB | 817 GB | synology |
| `fd7185cc` | 149 GB | 986 GB | synology |
| `abf38cac` | 146 GB | 764 GB | rclone/androiddownloadmanager |
| `b53084cf` | 145 GB | 451 GB | OneDriveSync |
| `ae661b75` | 140 GB | 28 GB | OneDriveSync/androiddownloadmanager |
| `a82cbd10` | 124 GB | 1.0 TB | OneDriveSync |

---

## Storage Impact Analysis

| Category | Count | Total Storage | Avg/Tenant | Revenue |
|----------|-------|---------------|-----------|---------|
| A: SPO Plan 2 Mega | 3 | **1,128 TB** | 376 TB | $37.50/mo |
| B: BizBasic Mega | 1 | **125 TB** | 125 TB | $0 |
| C: E5 Dev Heavy (>50TB) | 1 | **83 TB** | 83 TB | $0 |
| D: MSFT Impersonation | 7 | **90 TB** | 12.8 TB | $0 |
| E: Chinese Individual | 19 | **225 TB** | 11.8 TB | $0 |
| F: Vietnamese | 4 | ~27 TB | ~7 TB | $0 |
| G: Content Concern | 2 | ~28 TB | ~14 TB | $0 |
| H: Already Remediated | 4 | — | — | — |
| I: Unactionned tail | 9 | ~50 TB est | ~5.5 TB | $0 |
| **TOTAL** | **50** | **~1.76 PB** | **35 TB** | **$37.50/mo** |

---

## Recommended Action Plan

### Immediate (Today)
1. **Ingest SEEMSONLINE** (`c177d029`) — RC 107, UseCaseType 7, ICM 775773500. 693 TB, actively uploading 6-12 TB/day.
2. **Ingest QAZHB** (`380f38c1`) — 125 TB, 23.8 TB/wk egress, $0 revenue.
3. **Escalate SUPERLOLI** (`ba704491`) — Content concern + 18.4 TB. E5DEV-OVERQUOTA rollback left it active.

### Short-term (This Week)
4. **Batch ingest Category D (MSFT cluster)** — 7 tenants, clear pattern, zero revenue
5. **Batch ingest Category E (Chinese hoarders)** — 19 tenants, zero revenue
6. **Batch ingest Category F (Vietnamese)** — 4 tenants
7. **Manual review MSI GSC** (`0a79f022`) before action — verify if legitimate

### Systemic
8. **Escalate E5DEV-OVERQUOTA rollback gap** — 5 tenants, 127 TB, all rolled back in 2024
9. **Re-ingest all 5 rolled-back tenants** under RC 107 / UseCaseType 7 (ABUSE-READONLY-BLOCK-DELETE) to bypass the ineffective E5DEV-OVERQUOTA pipeline

---

## Detection Rule Candidates

### Rule R2-A: SPO Plan 2 Personal Cloud Storage
```
SKU = "SharePoint (Plan 2)"
AND seats = 1
AND storageTotalDiskUsed > 100 * storageLimitGB
AND app CONTAINS "rclone"
AND hasCustomDomain = FALSE
```
**Coverage:** SEEMSONLINE (693 TB), 星火计划 (332 TB)  
**Estimated FP rate:** Very low — legitimate SPO Plan 2 at 1 seat with rclone is virtually nonexistent

### Rule R2-B: MSFT Impersonation E5 Dev
```
tenantName = "MSFT"  
AND country = "SG"
AND SKU = "E5 Developer"
AND hasEverPaid = FALSE
AND tenantTotalDiskUsedGB > 5000
```
**Coverage:** 7 tenants in Ring 2

### Rule R2-C: E5 Dev Over-Quota with Automated Sync
```
SKU IN ("E5 Developer", "E3 Developer")
AND hasEverPaid = FALSE
AND tenantTotalDiskUsedGB > 10 * storageLimitGB
AND app IN ("rclone", "synology", "Cloudreve", "python-requests", "air explorer")
```
**Coverage:** ~35 tenants in Ring 2

### Rule R2-D: Business Basic Free Mega Storage
```
SKU = "Business Basic Free"
AND tenantTotalDiskUsedGB > 50 * storageLimitGB
AND hasEverPaid = FALSE
AND egress > 10 TB/wk
```
**Coverage:** QAZHB (125 TB)

---

## Appendix: How SEEMSONLINE Fits

SEEMSONLINE is **not part of a ring**. It is an individual mega-abuser whose profile defines a new archetype:

- **Vector:** Buy cheapest SPO Plan 2 ($12.50/mo, 1 seat, 1 TB quota)
- **Method:** Use rclone from VPS (OVH France) to upload content at 6-12 TB/day
- **Exploit:** SPO does not enforce hard quota limits — tenant grew to 693x overage
- **Economics:** $12.50/mo for 693 TB = $0.018/TB/month (vs Azure Blob $20/TB/month)
- **Peers in Ring 2:** 星火计划 (332 TB, already ReadOnly), QAZHB (125 TB, different SKU but same pattern)
- **Tracking:** These should be tracked as "SPO-Plan2-MegaAbuser" archetype, not as a ring

The common thread across ALL Ring 2 tenants is exploiting the gap between allocated storage quota and actual enforcement. Whether E5 Dev (1.27 TB quota → 82 TB stored) or SPO Plan 2 (1 TB quota → 693 TB stored), the platform does not enforce hard limits.
