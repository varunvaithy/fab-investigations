# StableBit CloudDrive / DrivePool — Investigation Report (INV-013)

**Date:** April 7, 2026  
**Investigator:** Copilot AI Agent + Varun V  
**ICM Ticket:** [775153741](https://portal.microsofticm.com/imp/v5/incidents/details/775153741/summary)  
**Classification:** App-Fingerprinted Cloud Storage Reselling Abuse (StableBit CloudDrive)  
**Related:** Seed from INV-010 (ac295da4 / Quang Trung College deep investigation)

---

## Executive Summary

During deep investigation of tenant `ac295da4` (Quang Trung College — 443 TB storage, Vietnamese EDU repurposed for reselling via ms365vip.com), we identified **StableBit CloudDrive** as the primary application used for abuse. Pivoting across all SpoProd telemetry for the last 30 days, we found **24 tenants** using StableBit CloudDrive, of which **9 are confirmed fraudulent**, **2 were already blocked**, and **6 have been newly ingested** into FAB remediation as part of this investigation.

A notable sub-finding is the **"MSFT" E5 Developer impersonation ring** — 4 tenants all named "MSFT", registered in Singapore, using E5 Developer trials, sharing Microsoft's own phone number (425-882-8080), and operated by Vietnamese actors.

**Key stats:**
- **6 tenants newly ingested** (FraudIds 148608–148613)
- **2 already blocked** (FraudIds 103194, 103368)
- **1 already in pipeline** (FraudId 148605 — Quang Trung College)
- **Total storage at risk:** ~25 TB (newly ingested) + 443 TB (Quang Trung, already in pipeline)
- **30-day egress from newly ingested tenants:** ~17.9 TB
- **Revenue from abusers:** $0 (5 of 6 are unpaid trials)

---

## What is StableBit CloudDrive?

**StableBit CloudDrive** is a Windows application that mounts cloud storage services (OneDrive, Google Drive, etc.) as local NTFS drives. It creates a virtual disk backed by cloud storage, enabling:

- **Local file system access** — mapped cloud storage appears as a regular drive letter (e.g., `D:`)
- **Caching** — intelligent local SSD/HDD cache for hot data
- **Encryption** — AES-256 encryption at the chunk level (opaque to cloud provider)
- **Chunk-based storage** — files split into encrypted chunks, making content inspection impossible

**StableBit DrivePool** (companion product) aggregates multiple CloudDrive volumes into a single pooled drive, enabling:

- Multiple OneDrive accounts → one massive virtual disk
- Automated balancing across drives
- Duplication for redundancy

### When it's legitimate
- Small businesses consolidating cloud storage for local access
- Photographers/videographers working with cloud-stored media
- Backup solutions using OneDrive as a target

### When it's fraudulent (100% of cases found in this investigation)
- **Cloud storage reselling**: Operator mounts OneDrive as NTFS → sells access to third parties
- **Quota circumvention**: DrivePool across multiple free/trial accounts → terabytes of free storage
- **Content obfuscation**: Chunk-level encryption makes abuse invisible to content scanning
- **Infrastructure monetization**: $0 cost to operator → sold as "unlimited cloud storage"

---

## Discovery Methodology

### How We Found This Ring

1. **Seed investigation (INV-010):** Deep investigation of `ac295da4` (Quang Trung College, 443 TB) revealed StableBit CloudDrive as the top application in SpoProd RequestUsage.
2. **App fingerprint sweep:** Queried SpoProd for all tenants where `app has 'StableBit'` in the last 30 days.
3. **24 tenants found** with StableBit activity, ranging from 16 TB egress to near-zero.
4. **D2K cross-correlation:** Pivoted admin emails, domains, and registration metadata to cluster tenants.
5. **"MSFT" ring identified:** 4 tenants sharing the name "MSFT", Singapore registration, and phone number `4258828080` (Microsoft HQ) — clear impersonation.
6. **Fraud scoring:** Applied a point-based heuristic to separate fraudulent from legitimate StableBit users.

**Key insight:** StableBit CloudDrive leaves a clear fingerprint in `app` field of RequestUsage telemetry. Unlike rclone (which FAB already detects), StableBit has **no existing detection rule** despite being equally dangerous for reselling.

---

## All StableBit Users — 30-Day SpoProd Telemetry

| # | Tenant ID | Name | Egress (GB) | Ingress (GB) | Users | Region | Verdict |
|---|-----------|------|-------------|-------------|-------|--------|---------|
| 1 | `fe05c663` | XMAN ASTRO | **16,160** | 21 | 2 | Central US | 🔴 **Block** (FraudId 148608) |
| 2 | `7f106373` | *(unknown)* | **3,698** | 1,888 | 2 | Central US | ⚠️ Needs Review |
| 3 | `837652e4` | FRUTS | **1,564** | 8 | 2 | Brazil South | 🔴 **Block** (FraudId 148611) |
| 4 | `986dbc1f` | MSFT | 110 | 134 | 3 | SE Asia | 🔴 **Block** (FraudId 148609) |
| 5 | `47cd246c` | *(benign)* | 73 | 65 | 2 | South Central US | 🟢 Legitimate |
| 6 | `8103a800` | *(benign)* | 66 | 6 | 2 | East US | 🟢 Legitimate |
| 7 | `21583179` | *(benign)* | 53 | 225 | 2 | Canada East | 🟢 Legitimate |
| 8 | `9538764b` | MSFT | 37 | 26 | 5 | Japan East | 🔴 **Block** (FraudId 148610) |
| 9 | `a804c5ea` | EASTCOM | 24 | 159 | 2 | SE Asia | 🔴 **Block** (FraudId 148612) |
| 10 | `c1da324d` | *(benign)* | 11 | 151 | 2 | Canada East | 🟢 Legitimate |
| 11 | `47e68f2a` | *(benign)* | 3 | 10 | 1 | Canada Central | 🟢 Legitimate |
| 12 | `c7e2e672` | *(benign)* | 3 | 19 | 2 | Australia SE | 🟢 Legitimate |
| 13 | `ac295da4` | Quang Trung College | 2 | 103 | 2 | SE Asia | 🔴 Already in pipeline (FraudId 148605) |
| 14 | `5270e779` | *(benign)* | 1 | 0 | 1 | Australia SE | 🟢 Legitimate |
| 15 | `164fcea4` | iceeyes | 0 | 0 | 10 | Japan East | ✅ Already blocked (FraudId 103368) |
| 16 | `f56aa64f` | MSFT | 0 | 0 | 1 | South Central US | ✅ Already blocked (FraudId 103194) |
| 17 | `bea28936` | — | 0 | 0 | 1 | Japan East / SE Asia | ⚠️ Needs Review |
| 18 | `4f5d18af` | — | 0 | 0 | 1 | East US | 🟢 Negligible |
| 19 | `08420129` | — | 0 | 0 | 1 | Canada East | 🟢 Negligible |
| 20 | `a37707ef` | — | 0 | 0 | 1 | East US | 🟢 Negligible |
| 21 | `e10000a5` | — | 0 | 0 | 3 | South Central US | 🟢 Negligible |
| 22 | `ccbf1560` | MSFT | 0 | 0 | 1 | Japan East | 🔴 **Block** (FraudId 148613) |
| 23 | `3cc86cd5` | — | 0 | 0 | 1 | South Central US | 🟢 Negligible |
| 24 | `be62a12b` | — | 0 | 0 | 1 | Canada Central | 🟢 Negligible |

---

## Newly Ingested Tenants — Detailed Profiles

### 1. `fe05c663` — XMAN ASTRO ← Biggest Single Abuser

| Field | Value |
|-------|-------|
| **FraudId** | 148608 |
| **Tenant ID** | `fe05c663-99cd-4627-aa10-1aeb585e7461` |
| **Name** | XMAN ASTRO |
| **Domain** | xmanastro.onmicrosoft.com |
| **Country** | United States (Albuquerque, NM) |
| **Created** | April 24, 2020 |
| **License** | OneDrive for Business Plan 2 (Paid) |
| **Storage Used** | **22 TB** (22,077 GB) |
| **Storage Quota** | 1 TB (1,024 GB) — **22x overage** |
| **ODB Sites** | 1 |
| **30-Day Egress** | **16.2 TB** (16,160 GB) — dominant abuser |
| **30-Day Ingress** | 21 GB |
| **Admin Email** | badbowtielt1@gmail.com |
| **Phone** | 3039127930 |
| **Signup** | GeminiSignUpUI |
| **Revenue** | hasEverPaid = TRUE (but $0 paid seats currently) |
| **Risk** | 🔴 **Critical** — massively egressing data, likely reselling OneDrive as a storage service |

**Key signals:** 22 TB stored on a 1 TB quota (22x overage). 16 TB egress in 30 days = active reselling. Single ODB site suggests a DrivePool aggregation endpoint. "Paid" status indicates the operator purchased a minimal license to avoid trial expiry.

---

### 2. `986dbc1f` — MSFT (thienthucac.org) ← "MSFT" Ring Member

| Field | Value |
|-------|-------|
| **FraudId** | 148609 |
| **Tenant ID** | `986dbc1f-0fc3-4f8e-995c-15cccdf2dd39` |
| **Name** | MSFT |
| **Domains** | 54rcdq.onmicrosoft.com, giangthe.com, thienthucac.org |
| **Country** | Singapore |
| **Created** | July 31, 2023 |
| **License** | E5 Developer (Trial, never paid) |
| **Storage Used** | **624 GB** |
| **Storage Quota** | 1.2 TB |
| **ODB Sites** | 19 |
| **30-Day Egress** | 110 GB |
| **30-Day Ingress** | 134 GB |
| **Admin Email** | phamtrongan29101989@outlook.com |
| **Phone** | 4258828080 ← **Microsoft HQ number** |
| **Signup** | GeminiSignUpUI, developer365=active |
| **Revenue** | $0 — never paid |
| **Risk** | 🔴 **High** — MSFT impersonation, Vietnamese actor, E5 Dev abuse, custom domains |

**Key signals:** Named "MSFT" to impersonate Microsoft. Vietnamese admin email (phamtrongan) signed up in Singapore with Microsoft's own phone number. Custom domains `giangthe.com` and `thienthucac.org` = Vietnamese. E5 Developer trial = $0 cost with 25 OneDrive licenses.

---

### 3. `9538764b` — MSFT (vn8w5) ← "MSFT" Ring Member

| Field | Value |
|-------|-------|
| **FraudId** | 148610 |
| **Tenant ID** | `9538764b-f9b9-4772-a7ca-f68294849668` |
| **Name** | MSFT |
| **Domain** | vn8w5.onmicrosoft.com |
| **Country** | Singapore |
| **Created** | February 8, 2023 |
| **License** | E5 Developer (Trial, never paid) |
| **Storage Used** | **67 GB** |
| **Storage Quota** | 1.2 TB |
| **ODB Sites** | 17 |
| **30-Day Egress** | 37 GB |
| **30-Day Ingress** | 26 GB |
| **Admin Email** | linjin.archive01@gmail.com |
| **Phone** | 4258828080 ← **Microsoft HQ number** |
| **Signup** | GeminiSignUpUI, developer365=active |
| **Revenue** | $0 — never paid |
| **Risk** | 🔴 **High** — MSFT impersonation ring, gibberish domain `vn8w5` |

**Key signals:** Same "MSFT" pattern. Gibberish `.onmicrosoft.com` prefix. `linjin.archive01` suggests archival/storage intent. 17 ODB sites provisioned on 25 E5 Dev licenses = infrastructure for scale-out.

---

### 4. `a804c5ea` — EASTCOM

| Field | Value |
|-------|-------|
| **FraudId** | 148612 |
| **Tenant ID** | `a804c5ea-9440-418c-aa50-ae1e073d1cf2` |
| **Name** | EASTCOM |
| **Domains** | ep219.onmicrosoft.com, ms.ep220.netlib.re |
| **Country** | China (Nanjing, JS) |
| **Created** | November 16, 2025 |
| **License** | E3 Developer (Non-Paid) |
| **Storage Used** | **737 GB** |
| **Storage Quota** | 1.2 TB |
| **ODB Sites** | 2 |
| **30-Day Egress** | 24 GB |
| **30-Day Ingress** | 159 GB (ingress > egress = still filling up) |
| **Admin Email** | test1@ep219.ip-ddns.com |
| **Phone** | 17714567892 |
| **Signup** | GeminiSignUpUI |
| **Revenue** | $0 — never paid |
| **Risk** | 🔴 **High** — dynamic DNS admin email, numbered sequential domains (ep219/ep220), Chinese infrastructure operator |

**Key signals:** Admin email uses `ip-ddns.com` (dynamic DNS = infrastructure operator). Sequential domain naming `ep219`/`ep220` suggests this is one of many. Custom domain `ms.ep220.netlib.re` = network library resource. 159 GB ingress vs 24 GB egress = actively loading data, still ramping up.

---

### 5. `837652e4` — FRUTS

| Field | Value |
|-------|-------|
| **FraudId** | 148611 |
| **Tenant ID** | `837652e4-adce-494a-a681-77b9ab9abb62` |
| **Name** | FRUTS |
| **Domain** | fruts.onmicrosoft.com |
| **Country** | Brazil (Maceió, AL) |
| **Created** | May 31, 2016 |
| **License** | Business Standard (Paid) |
| **Storage Used** | **2 GB** (low — but 1.5 TB egress!) |
| **Storage Quota** | 1 TB |
| **ODB Sites** | 23 |
| **30-Day Egress** | **1,564 GB (1.5 TB)** — massive for 2 GB stored |
| **30-Day Ingress** | 8 GB |
| **Admin Email** | ti@fikafrio.com.br |
| **Phone** | 8221232600 |
| **Signup** | (predates GeminiSignUpUI) |
| **Revenue** | hasEverPaid = TRUE |
| **VL Tag** | ⚠️ `noDeletionBy=VL` — may block full remediation |
| **Risk** | 🔴 **High** — 1.5 TB egress from 2 GB storage = extreme read amplification (transit/relay pattern) |

**Key signals:** 23 ODB sites on 2 licenses = massive over-provisioning. 1,564 GB egress from 2 GB stored = **782x read amplification**, indicating this tenant is being used as a transit/relay point for data. The VL (Volume Licensing) tag may complicate deletion, but readonly + block should proceed.

---

### 6. `ccbf1560` — MSFT (30hxw6) ← "MSFT" Ring Member

| Field | Value |
|-------|-------|
| **FraudId** | 148613 |
| **Tenant ID** | `ccbf1560-b4cb-42a2-a8da-8bf74beeac33` |
| **Name** | MSFT |
| **Domain** | 30hxw6.onmicrosoft.com |
| **Country** | Singapore |
| **Created** | November 25, 2023 |
| **License** | E5 Developer (Trial, never paid) |
| **Storage Used** | **1,142 GB (1.1 TB)** |
| **Storage Quota** | 1.2 TB |
| **ODB Sites** | 18 |
| **30-Day Egress** | 0 GB (dormant or cached) |
| **30-Day Ingress** | 0 GB |
| **Admin Email** | ardilmahyano@gmail.com |
| **Phone** | 4258828080 ← **Microsoft HQ number** |
| **Signup** | GeminiSignUpUI, developer365=active |
| **Revenue** | $0 — never paid |
| **Risk** | 🔴 **High** — 1.1 TB stored on a free trial, MSFT impersonation ring, gibberish domain |

**Key signals:** 1.1 TB storage in use on a free trial (near quota). Zero recent egress may mean the operator is using cached access via DrivePool. Gibberish domain `30hxw6`. Same MSFT ring pattern.

---

## The "MSFT" E5 Developer Impersonation Ring

A coordinated ring of **4 tenants**, all named "MSFT" (impersonating Microsoft), operating from Singapore-registered E5 Developer trials:

| # | Tenant ID | Domain | Created | Storage | Admin Email | Phone | Status |
|---|-----------|--------|---------|---------|-------------|-------|--------|
| 1 | `986dbc1f` | thienthucac.org / giangthe.com | Jul 2023 | 624 GB | phamtrongan29101989@outlook.com | 4258828080 | 🔴 Ingested (148609) |
| 2 | `f56aa64f` | xzjmt.onmicrosoft.com / sys.tungtek.com | Jul 2023 | — | tung@tungtek.edu.vn | 4258828080 | ✅ Blocked (103194) |
| 3 | `9538764b` | vn8w5.onmicrosoft.com | Feb 2023 | 67 GB | linjin.archive01@gmail.com | 4258828080 | 🔴 Ingested (148610) |
| 4 | `ccbf1560` | 30hxw6.onmicrosoft.com | Nov 2023 | 1,142 GB | ardilmahyano@gmail.com | 4258828080 | 🔴 Ingested (148613) |

### Ring Characteristics
- **Phone number:** All four use `4258828080` — Microsoft's actual headquarters phone number
- **Signup experience:** All four use GeminiSignUpUI
- **Company tag:** All four have `azure.microsoft.com/developer365=active`
- **Country:** All registered in Singapore (but operators are Vietnamese — evident from admin emails, domains like `tungtek.edu.vn`, `thienthucac.org`)
- **Payment:** $0 across all four — never paid for any service
- **D2K Instance:** Asia Pacific (all four)
- **Creation pattern:** Feb 2023, Jul 2023 (×2), Nov 2023 — sequential scaling over 9 months

### Why This is a Single Operator
Despite different admin emails, the shared phone number (Microsoft's own!) and identical registration pattern (Singapore + E5 Dev + Vietnamese signals) strongly indicate a single operator or coordinated group using Microsoft's identity to avoid scrutiny.

---

## Already-Handled Tenants

### `f56aa64f` — MSFT (xzjmt) ← Already Blocked

| Field | Value |
|-------|-------|
| **FraudId** | 103194 |
| **Status** | ✅ Blocked by FAB detection pipeline |
| **Admin Email** | tung@tungtek.edu.vn |
| **Domains** | xzjmt.onmicrosoft.com, sys.tungtek.com |
| **Notes** | "MSFT" ring member. Blocked before this investigation. Vietnamese .edu.vn email. |

### `164fcea4` — iceeyes ← Already Blocked

| Field | Value |
|-------|-------|
| **FraudId** | 103368 |
| **Status** | ✅ Blocked by FAB detection pipeline |
| **Admin Email** | hawkfly2018@outlook.com |
| **Domain** | bingxue2019.onmicrosoft.com |
| **Country** | China |
| **Notes** | Independent Chinese operator. E5 Developer trial. 10 StableBit users detected. |

### `ac295da4` — Quang Trung College ← In Pipeline (INV-010)

| Field | Value |
|-------|-------|
| **FraudId** | 148605 |
| **Status** | ⏳ In FAB pipeline (ABUSE-READONLY-BLOCK-DELETE) |
| **Storage** | **443 TB** — largest single tenant in this investigation |
| **Admin** | Vietnamese EDU repurposed for cloud storage reselling |
| **Reselling Domains** | ms365vip.com, msdrive365.com |
| **Notes** | Seed tenant for this investigation. VL-protected (noDeletionBy=VL). |

---

## Aggregate Impact

### Storage Summary

| Category | Tenants | Storage | 30-Day Egress |
|----------|---------|---------|---------------|
| **Newly ingested (this investigation)** | 6 | **24.6 TB** | **17.9 TB** |
| **Already in pipeline (ac295da4)** | 1 | **443 TB** | 2 GB |
| **Already blocked** | 2 | — | 0 |
| **Total actioned** | **9** | **~468 TB** | **~17.9 TB** |

### Per-Tenant Storage Breakdown

```
fe05c663  XMAN ASTRO      ████████████████████████████████████████  22,077 GB  (89.5%)
ccbf1560  MSFT/30hxw6     ██                                         1,142 GB  ( 4.6%)
a804c5ea  EASTCOM          █                                           737 GB  ( 3.0%)
986dbc1f  MSFT/thienthucac █                                           624 GB  ( 2.5%)
9538764b  MSFT/vn8w5       ░                                            67 GB  ( 0.3%)
837652e4  FRUTS            ░                                             2 GB  ( 0.0%)
                                                              Total: 24,649 GB  (24.1 TB)
```

### Per-Tenant Egress Breakdown (30-Day)

```
fe05c663  XMAN ASTRO      ████████████████████████████████████████  16,160 GB  (90.3%)
837652e4  FRUTS           ████                                       1,564 GB  ( 8.7%)
986dbc1f  MSFT/thienthucac ░                                           110 GB  ( 0.6%)
9538764b  MSFT/vn8w5       ░                                            37 GB  ( 0.2%)
a804c5ea  EASTCOM          ░                                            24 GB  ( 0.1%)
ccbf1560  MSFT/30hxw6      ░                                             0 GB  ( 0.0%)
                                                              Total: 17,895 GB  (17.5 TB)
```

---

## Fraud Detection Heuristics

### StableBit Fraud Scoring Matrix

Based on this investigation, the following point-based scoring system was developed for StableBit-using tenants:

| Signal | Points | Rationale |
|--------|--------|-----------|
| StableBit in app field | +2 | Baseline signal — legitimate use exists, but warrants investigation |
| E5 Developer / E3 Developer license | +3 | Free trial with 25 OneDrive licenses — prime abuse vehicle |
| hasEverPaid = FALSE | +2 | Never paid for any service |
| Storage > 500 GB on trial | +3 | Significant data on a free account |
| Egress > 100 GB / 30 days | +2 | Active data serving (possible reselling) |
| Egress:Storage ratio > 10x | +3 | Transit/relay pattern (data flowing through, not resting) |
| Single ODB site + high storage | +2 | DrivePool aggregation endpoint |
| ODB sites > licenses | +2 | Over-provisioned infrastructure |
| Gibberish domain (.onmicrosoft.com) | +1 | Automated tenant creation |
| No custom domain | +1 | No business identity |
| Phone = 4258828080 (MSFT HQ) | +5 | Deliberate impersonation |
| Name = "MSFT" | +5 | Impersonation |
| Dynamic DNS admin email | +2 | Infrastructure operator pattern |
| developer365=active tag | +1 | Developer program abuse |
| GeminiSignUpUI | +1 | Bot-friendly signup flow |

### Decision Thresholds

| Score | Action | Confidence |
|-------|--------|------------|
| ≥ 15 | 🔴 Auto-block | Very high — near-certain fraud |
| 10–14 | 🟡 Manual review + likely block | High — most will be fraud |
| 5–9 | 🟠 Flag for investigation | Medium — could be legitimate |
| < 5 | 🟢 No action | Low — likely legitimate use |

### Decision Tree (Production-Ready)

```
StableBit detected in app field?
├── NO → exit (not applicable)
└── YES → Check license type
    ├── E5/E3 Developer Trial (never paid)
    │   ├── Name = "MSFT" OR phone = "4258828080" → 🔴 AUTO-BLOCK (impersonation)
    │   ├── Storage > 500 GB → 🔴 BLOCK (significant abuse on free trial)
    │   ├── Egress > 100 GB/30d → 🟡 REVIEW (active, likely not test data)
    │   └── Egress < 100 GB, Storage < 500 GB → 🟢 MONITOR (may be legitimate dev testing)
    ├── EDU A1/A3 (no paid seats)
    │   ├── Reselling domains found (ms365vip, msdrive365, etc.) → 🔴 BLOCK
    │   ├── rclone + StableBit co-occurrence → 🔴 BLOCK
    │   └── StableBit only, moderate usage → 🟡 REVIEW
    ├── Business Basic/Standard (paid)
    │   ├── Egress:Storage > 10x (transit pattern) → 🔴 BLOCK
    │   ├── ODB sites >> licenses → 🟡 REVIEW
    │   └── Normal ratio → 🟢 MONITOR
    └── Enterprise (E3/E5 paid, large org)
        └── 🟢 LIKELY LEGITIMATE (enterprise use of CloudDrive for team workflows)
```

---

## Remediation Summary

### All Ingestions — April 7, 2026

| # | Tenant ID | Name | FraudId | Reason Code | Use Case Type | ICM | Status |
|---|-----------|------|---------|-------------|---------------|-----|--------|
| 1 | `fe05c663-99cd-4627-aa10-1aeb585e7461` | XMAN ASTRO | 148608 | 106 (Adhoc Investigation) | 7 (ABUSE-READONLY-BLOCK-DELETE) | 775153741 | ✅ Ingested |
| 2 | `986dbc1f-0fc3-4f8e-995c-15cccdf2dd39` | MSFT | 148609 | 106 | 7 | 775153741 | ✅ Ingested |
| 3 | `9538764b-f9b9-4772-a7ca-f68294849668` | MSFT | 148610 | 106 | 7 | 775153741 | ✅ Ingested |
| 4 | `837652e4-adce-494a-a681-77b9ab9abb62` | FRUTS | 148611 | 106 | 7 | 775153741 | ✅ Ingested |
| 5 | `a804c5ea-9440-418c-aa50-ae1e073d1cf2` | EASTCOM | 148612 | 106 | 7 | 775153741 | ✅ Ingested |
| 6 | `ccbf1560-b4cb-42a2-a8da-8bf74beeac33` | MSFT | 148613 | 106 | 7 | 775153741 | ✅ Ingested |

**Pipeline:** ABUSE-READONLY-BLOCK-DELETE = 21-day readonly → 30-day block → 30-day delete → deprovision

### VL Blockers

| Tenant | VL Tag | Impact |
|--------|--------|--------|
| `837652e4` (FRUTS) | `noDeletionBy=VL` | Deletion phase may be blocked. Readonly + block should proceed. Needs VL team coordination for final deprovision. |
| `ac295da4` (Quang Trung) | `noDeletionBy=VL` | Same — in INV-010 pipeline. |

---

## Recommendations

### Immediate
1. **Monitor remediation pipeline** for all 6 tenants (FraudIds 148608–148613) — watch for READONLY_FAIL or BLOCK_FAIL
2. **Investigate `7f106373`** — 3.7 TB egress, 1.9 TB ingress, 2 users, Central US. Not yet profiled — could be another high-impact abuser
3. **VL coordination** for `837652e4` (FRUTS) and `ac295da4` (Quang Trung) — both have VL deletion blockers

### Strategic
4. **Create StableBit detection rule (Rule 8)** — add `app has 'StableBit'` to the automated detection pipeline, using the decision tree above
5. **Cross-reference StableBit users with existing FAB database** — some may also trigger Rules 3, 4, or 6
6. **Monitor for StableBit DrivePool specifically** — DrivePool is the more dangerous product (pool-of-pools), but may not appear distinctly in telemetry
7. **Quarterly StableBit sweep** — run the SpoProd query periodically to catch new adopters

---

## Appendix A: KQL Query for StableBit Detection

```kql
// Find all StableBit CloudDrive/DrivePool users in last 30 days
RequestUsage
| where env_time > ago(30d)
| where app has 'StableBit'
| summarize
    TotalEgressGB = sum(blobReadBytes) / 1073741824,
    TotalIngressGB = sum(blobWriteBytes) / 1073741824,
    DistinctUsers = dcount(user),
    Regions = make_set(svc_azureRegion),
    Apps = make_set(app)
  by siteSubscriptionId
| order by TotalEgressGB desc
```

## Appendix B: Tenant ID Full GUIDs

| Short ID | Full GUID |
|----------|-----------|
| `fe05c663` | `fe05c663-99cd-4627-aa10-1aeb585e7461` |
| `986dbc1f` | `986dbc1f-0fc3-4f8e-995c-15cccdf2dd39` |
| `9538764b` | `9538764b-f9b9-4772-a7ca-f68294849668` |
| `a804c5ea` | `a804c5ea-9440-418c-aa50-ae1e073d1cf2` |
| `837652e4` | `837652e4-adce-494a-a681-77b9ab9abb62` |
| `ccbf1560` | `ccbf1560-b4cb-42a2-a8da-8bf74beeac33` |
| `f56aa64f` | `f56aa64f-773a-440e-afc8-ef80cb1fa04e` |
| `164fcea4` | `164fcea4-a4ec-49c4-b2c1-dab722e08e77` |
| `ac295da4` | `ac295da4-9912-40f3-86ce-a30c44a02883` |
| `7f106373` | `7f106373-35e7-4cc5-a2c9-07ba233f1fee` |
