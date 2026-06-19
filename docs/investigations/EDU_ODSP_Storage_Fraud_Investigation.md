# EDU ODSP Storage Fraud Investigation Report

**Investigation Date:** April 23, 2026  
**Investigator:** FAB Tenant Investigation Agent  
**Scope:** Global EDU ODSP storage-based fraud analysis (ODB + SPO combined)  
**Data Source:** DimTenant_SiteMetrics (snapshot: 2026-04-21), DIM_TENANTS, FAB Pipeline, OMS, D2K  
**Status:** ONGOING — Phase 10 complete. Over-quota analysis + storage reselling detection in progress.

---

## Running Totals (Updated Live — Phase 10 + Over-Quota Analysis)

### EDU Storage Baseline (Corrected Phase 5+)

| Metric | EDU Tenants | Storage |
|--------|-------------|----------|
| Total EDU Tenants (IsEduSegment) | **453,899** | |
| EDU ODB Storage | | **1,109.1 PB** |
| EDU SPO Storage | | **356.7 PB** |
| **EDU Combined (ODB+SPO)** | | **1,465.8 PB** |

### Fraud Summary

| Metric | Value | % of Combined |
|--------|-------|---------------|
| **Total Confirmed Fraud Storage** | **~7.20 PB** | **0.49%** |
| ├─ Fraud identified + acted on (blocked/readonly) | ~1.97 PB | 0.13% |
| ├─ Fraud identified + action failed/rolled back | ~1.34 PB | 0.09% |
| ├─ Fraud identified + delete scheduled, never executed | ~1.30 PB | 0.09% |
| ├─ Fraud identified + NO action taken (years) | ~1.48 PB | 0.10% |
| └─ **Fraud NOT identified (not in FAB)** | **~1.67 PB** | **0.11%** |
| **Total Fraud Storage Deleted (Reclaimed)** | **~0 PB** | **0%** |
| Suspected fraud (uninvestigated tiers) | ~8.0 PB | 0.55% |
| **Grand total fraud + suspected** | **~15.4 PB** | **1.05%** |

### Over-Quota Analysis (NEW — Phase 10)

| Metric | Value | % of EDU |
|--------|-------|----------|
| **Over-quota EDU tenants** | **856** | **0.19%** of 453,899 |
| Over-quota total storage consumed | **32.2 PB** | **2.15%** of 1,501 PB |
| Over-quota excess (above limit) | **16.8 PB** | 1.12% |
| Over-quota: Paid tenants | 736 (86%) | Avg 2.1x over, max 46x |
| Over-quota: Free/Trial tenants | 120 (14%) | Avg 5.2x over, max **344x** |

### Phase 8-10 User-Provided Tenant Investigation

| Batch | IDs | Fraud Found | Legit | Notable |
|-------|-----|-------------|-------|----------|
| Phase 8 Batch 1 (16 IDs) | 16 | 6 suspect | 5 cleared (KR schools) | TW Dev Ring (5 members) |
| Phase 8 Batch 2 (20 IDs) | 20 | 1 suspect | 2 legit paid | Mostly dormant A1 w/ 0 storage |
| Phase 9 (48 IDs) | 48 | 0 | **48 all legit** | Over-quota paid orgs |
| Phase 10 (48 IDs) | 48 | 5 fraud | 40 legit paid | 3 free-rider EDU universities |

> **Key takeaway:** ~7.2 PB confirmed fraud, **0 PB reclaimed**. **56 tenants (~1.67 PB)** never identified by FAB. 17+ fraud rings spanning 20+ countries. **856 EDU tenants are over-quota**, consuming 32.2 PB with 16.8 PB excess — free/trial tenants average 5.2x over-quota vs 2.1x for paid. Phase 9-10 confirmed that user-provided high-storage tenant lists are overwhelmingly legitimate paid orgs, not fraud.

---

## Executive Summary

This investigation analyzed the **453,899 EDU tenants** consuming **1,465.8 PB** of combined ODB+SPO storage across the global Microsoft 365 EDU ecosystem. Using a storage-centric approach (rather than license-based), we identified:

- **~7.20 PB (0.49%) of total EDU storage is confirmed fraud** across **~135+ investigated tenants**
- **17+ major fraud rings** operating across **20+ countries** on free A1 EDU tenants
- **56 net-new fraudulent tenants** totaling **~1.67 PB not in FAB** (never identified)
- **0 TB of fraudulent storage has been successfully reclaimed** despite years of identification
- **856 EDU tenants (0.19%) are over-quota**, consuming 32.2 PB with **16.8 PB excess** above their storage limits
- Free/Trial over-quota tenants average **5.2x** their limit (max 344x) vs paid at 2.1x
- Phase 8-10 validated that high-storage tenant lists are predominantly legitimate paid organizations, not fraud
- Fraud patterns are **global** — found in VN, CN, HK, TW, US, CA, ID, RS, NZ, NC, MY, DE, SA, ES, FR, BR, KR, JP, PE, CH, SG, CZ

### Key Metrics

| Metric | Value |
|--------|-------|
| Total EDU tenants (IsEduSegment) | 453,899 |
| Total EDU ODB storage | 1,109.1 PB |
| Total EDU SPO storage | 356.7 PB |
| **Total EDU combined** | **1,465.8 PB** |
| **Total confirmed fraud storage** | **~7.20 PB (0.49%)** |
| Confirmed fraud — deleted (reclaimed) | **~0 PB (0%)** |
| Confirmed fraud — remediated (blocked/readonly), not freed | ~1.97 PB |
| Confirmed fraud — action failed / rolled back | ~1.34 PB |
| Confirmed fraud — delete scheduled, never executed | ~1.30 PB |
| Confirmed fraud — identified, NO action | ~1.48 PB |
| Net-new fraud (NOT in FAB) | **~1.67 PB (56 tenants)** |
| Suspected fraud (uninvestigated tiers) | ~8.0 PB |
| **Total fraudulent + suspected storage** | **~15.4 PB (1.05%)** |
| | |
| **Over-quota EDU tenants** | **856 (0.19%)** |
| Over-quota total storage | 32.2 PB (2.15%) |
| Over-quota excess above limit | **16.8 PB** |
| Over-quota: Paid (736) avg ratio | 2.1x (max 46x) |
| Over-quota: Free/Trial (120) avg ratio | **5.2x (max 344x)** |

---

## 1. Methodology

### 1.1 EDU Tenant Identification
Since DIM_TENANTS was unavailable (refresh cycle), EDU tenants were identified via ODB `StorageLimit` in DimTenant_SiteMetrics. EDU A1 tenants receive a ~100 TB storage pool. Filter: `StorageLimit_TB between (95.0 .. 105.0)` correctly identifies ~245K EDU tenants.

### 1.2 Risk Tier Segmentation
Tenants were segmented into risk tiers based on storage consumed vs. active usage:

| Tier | Criteria | Tenants | Storage | % of EDU |
|------|----------|---------|---------|----------|
| 🔴 **RED** | >10 TB consumed, ≤20 active ODB sites | 177 | 10.03 PB | 4.1% |
| 🟠 **ORANGE** | 1-10 TB consumed, ≤5 active ODB sites | 996 | 3.31 PB | 1.3% |
| 🟡 **YELLOW** | >1 TB consumed, <1% active ratio | 96 | 0.4 PB | 0.2% |
| 👁️ **WATCH** | 100 GB - 1 TB consumed, 0 active sites | 704 | 0.23 PB | 0.1% |
| 🟢 **GREEN** | Active >50 users | 75,505 | 216.7 PB | 88.2% |
| ⚪ **NORMAL** | Low storage | 167,642 | 15.0 PB | 6.1% |

### 1.3 Investigation Approach
For each suspicious tenant (RED + ORANGE tiers), we checked:
1. **OMS metadata** (tenant name, domain, country, license count, creation date)
2. **FAB remediation status** (identified? blocked? deleted? rolled back?)
3. **Pattern matching** (ring membership, domain patterns, creation date clustering)
4. **Fraud signals** (brand impersonation, 365-branded domains, gibberish names, commercial activity on EDU)

---

## 2. Fraud Rings Identified

### 2.1 Ring 1: "Spring 2020 Cloud Storage Mega-Ring"

**The largest ring discovered.** 11 tenants created across April–May 2020, all registered as US EDU A1 with 10K licenses, all using 365/Office-branded commercial domains for cloud storage reselling. Combined **413 TB**.

#### SCHOOLO Sub-Ring (Created 2020-05-18)
Pattern: `[RANDOM]SCHOOLO.[RANDOM]SCHOOLO`

| # | Tenant ID | Name | Domain | ODB TB | FAB Status |
|---|-----------|------|--------|--------|------------|
| 1 | `48fc7248-fe6f-4fce-947e-13d6c7734819` | WKTSCHOOLO.WKTSCHOOLO | `office365store.top` | 85.7 | ✅ BLOCKED Jun 2023 |
| 2 | `c6c39148-080b-4b53-b4d3-010e414b29a8` | LSXSCHOOLO.LSXSCHOOLO | `office365net.com` | 46.8 | ✅ BLOCKED Aug 2023 |
| 3 | `9559bd6a-f613-450b-8a0f-3e0e7ce158f1` | UQVSCHOOLO.UQVSCHOOLO | `365c.live` / `c2024.live` | 16.6 | ✅ BLOCKED Apr 2023 |
| 4 | `39af2df3-000d-416c-aa00-e74404f2548e` | FOSSCHOOLS.FOSSCHOOLS | `ms365officenw.xyz` | 22.3 | ⚠️ Delete scheduled, NEVER executed |

#### May 9 Wave
| # | Tenant ID | Name | Domain | ODB TB | FAB Status |
|---|-----------|------|--------|--------|------------|
| 5 | `7807ef4b-5a8f-41f8-86e1-a9418445951a` | CHARLES INC. | `office365.uno` | 35.6 | ❌ DELETE FAIL + ROLLBACK FAIL (stuck) |
| 6 | `ae66e8e3-ac8c-4bee-8e1d-91778775f4a8` | DONNA INC. | `o365th.com` | 21.2 | ⚠️ Delete scheduled, NEVER executed |

#### May 18–19 Wave
| # | Tenant ID | Name | Domain | ODB TB | FAB Status |
|---|-----------|------|--------|--------|------------|
| 7 | `e5b07230-4fd2-4ed6-9292-a5858948f307` | MICROSOFT 365 APPS FOR ENTERPRISE | `officeid.co`, `email-co.id` | 28.9 | ✅ BLOCKED Jun 2023 |
| 8 | `df1b5ce3-ddb8-4e99-a344-b6b3405e46b9` | MICROSOFT CO. | `mail.cnstu.run` | 43.3 | ✅ BLOCKED Jun 2023 |
| 9 | `e36bc26b-8604-4291-a7ad-354961779970` | THZXG.YWMNE | `365site.top` | 38.7 | ❌ DELETE ROLLED BACK |

#### May 25 + April 29
| # | Tenant ID | Name | Domain | ODB TB | FAB Status |
|---|-----------|------|--------|--------|------------|
| 10 | `7c943324-9b1d-4c06-bd70-fe70db130773` | ASSOCIATION OF GOSPEL RESCUE MISSIONS | `asso.me` | 33.8 | ❌ DELETE ROLLED BACK |
| 11 | `6288d59d-3b01-40d0-8ff0-3daf345010af` | DADA | `offices365.co` | 40.1 | ⚠️ READONLY only, never blocked |

**Ring total: 413 TB across 11 tenants → NOW 19+ tenants, ~1,100 TB. Storage freed: 0 TB. See §9.4 for additional members.**

**Why fraud:**
- Simultaneous creation in April–May 2020 (scripted provisioning)
- Fake names: random gibberish (THZXG.YWMNE), template patterns (SCHOOLO), fake orgs (GOSPEL RESCUE)
- 365-branded commercial domains clearly designed for reselling: `office365store.top`, `office365.uno`, `offices365.co`, `365site.top`, `ms365officenw.xyz`, `o365th.com` (Thailand market)
- EDU A1 provides unlimited 5 TB/user ODB + 100 TB pool = free cloud storage
- Each tenant provisions thousands of ODB user sites (up to 19,805 on UQVSCHOOLO) as resellable storage buckets

---

### 2.2 Ring 2: "Corporate Buzzword Generator" (Nov 25, 2018)

3 tenants created on the **exact same day** with auto-generated corporate jargon names and `a1p.me` ("A1 for free") domains. Combined **344 TB**.

| # | Tenant ID | Name | Created | Domain | ODB TB | FAB Status |
|---|-----------|------|---------|--------|--------|------------|
| 1 | `f90080c9-9e55-4dae-8262-498f47cf436c` | STRATEGIZE VALUE-ADDED PARADIGMS | 14:38 | `365proplus.site`, `b798.a1p.me` | 177.9 | ⚠️ Identified Mar 2023, **NO ACTION** |
| 2 | `2e4eb929-79d3-4c34-8e3d-a4c687cba1e4` | ORCHESTRATE CUTTING-EDGE WEB-READINESS | 14:50 | `x365mail.com`, `gizn.a1p.me` | 100.9 | ❌ DELETE ROLLED BACK |
| 3 | `1407ff58-081c-4ddb-b3f6-14764398b1a2` | MORPH B2B PARTNERSHIPS | 09:39 | `cloudmicrosoft.in` | 62.2 | ✅ BLOCKED Jun 2023 (4 failures first) |

**Ring total: 344 TB → NOW 4+ members, ~355 TB (added EXPLOIT SCALABLE INTERFACES). Storage freed: 0 TB. STRATEGIZE (178 TB) has had ZERO remediation action for 3+ years.**

**Why fraud:**
- Same-day creation with exact timestamps (all within 5 hours)
- Names generated from a buzzword generator — no school is called "STRATEGIZE VALUE-ADDED PARADIGMS"
- `a1p.me` = "A1 Plan for me" domain service specifically targeting free A1 storage abuse
- Microsoft-impersonating domains: `365proplus.site`, `x365mail.com`, `cloudmicrosoft.in`

---

### 2.3 Ring 3: Taiwan/China 365 Reselling Network (Oct 2021 Wave)

A cluster of TW/CN-operated tenants using 365/Office-branded domains, many created in October 2021. Combined **~830 TB**.

| # | Tenant ID | Name | Country | Domain | ODB TB | FAB Status |
|---|-----------|------|---------|--------|--------|------------|
| 1 | `5765f1fe-7f94-4dfb-a770-e6f4e2b3c41f` | MICROSOFT 365 | US | `365i.team` | 604.8 | ⚠️ Delete scheduled, never completed |
| 2 | `186b8e6c-*` | 台北市立第一女子高級中學 | TW | `365office.digital`, `fkv.me` | 110 | ⚠️ READONLY only |
| 3 | `eecba1cb-cad5-48b8-b418-e6e29565a18e` | 365 USERS | TW | `genuine365.net` | 51.8 | ⚠️ Delete scheduled, never executed |
| 4 | `161d5c41-6afa-4b8c-89c2-3e3b7ccd8f1d` | OFFICE 365 | TW | `officems365.live` | 30.1 | ✅ BLOCKED Apr 2023 |
| 5 | `e4f9123c-6159-4bba-af70-6881674a52fd` | MICROSOFT 365 | SA | `moedogorg.onmicrosoft.com` | 24.8 | ✅ BLOCKED Oct 2023 |
| 6 | `d5dfe8c8-4856-4da5-b55d-6cff6f5a98f8` | 陡陌星雲 | CN | `0ffice.tw` (zero-for-O) | 22.0 | ⚠️ Delete scheduled, never executed |
| 7 | `35704715-c414-4c15-a7a3-cffb89babf06` | GHEUGE | TW | `office2021.co` | 21.0 | ⚠️ READONLY only |

**Ring total: ~830 TB (dominated by 365i.team at 605 TB). Storage freed: 0 TB.**

**Why fraud:**
- Domain naming convention: `365office.digital`, `genuine365.net`, `officems365.live`, `0ffice.tw`, `office2021.co`, `365i.team`
- Zero-for-O typosquatting: `0ffice.tw`
- Brand impersonation: tenant names literally "MICROSOFT 365", "OFFICE 365", "365 USERS"
- 171,032 ODB sites on `365i.team` alone — the largest reselling operation discovered

---

### 2.4 Ring 4: Vietnam School Hijacking Network (Archetype G)

Vietnamese `.edu.vn` school tenants repurposed for commercial storage/services. Schools are real but have been hijacked or their credentials are being sold. Combined **~2,613 TB**.

| # | Tenant ID | Name | Domain | ODB TB | FAB Status |
|---|-----------|------|--------|--------|------------|
| 1 | `9f85948e-*` | TRƯỜNG THCS PHÚC THUẬN | `phucthuannv.edu.vn` | 2,199 | ✅ BLOCKED Feb 2025 |
| 2 | `e648dc98-*` | CONG DOAN UNIVERSITY | `giaiphapemail.net` | 106 | ⚠️ Identified Aug 2024, no action |
| 3 | `5704f9de-c341-49a5-acaf-0b97fd0c0bb0` | VIEN DAO TAO QUOC TE | `isbmkt.onmicrosoft.com` | 98 | 🆕 **NOT IN FAB** |
| 4 | `10f4e3b4-08e4-4bb4-8c33-47efb0d38c5f` | TRUNG HỌC CƠ SỞ XUÂN PHƯƠNG | `quynhchi.online` | 76 | ⚠️ Identified Mar 2026, no action |
| 5 | `389f25d4-f57b-4ead-b09d-fa29a3bc4baa` | ADVG.EDU.VN | `advg.edu.vn` + 3 commercial | 60 | ❌ DELETE ROLLED BACK |
| 6 | `5821f78b-bfa4-4457-854a-78d307adede1` | MINHHIEN.EDU.VN | `minhhien.edu.vn` + **46 domains** | 31 | ⚠️ READONLY (rolled back once) |
| 7 | `f2a506d3-ef11-4f86-8c51-e5ea67ec5a67` | THPT THUY HUONG | `thptthuyhuong.org` | 21 | 🆕 **NOT IN FAB** |
| 8 | `c7e69b2a-424f-47a1-a995-dfede77d4040` | CNAVN | `edu.cna.vn` | 20 | ❌ DELETE ROLLBACK FAIL |

**Ring total: ~2,613 TB. Storage freed: 0 TB.**

**Why fraud:**
- Real Vietnamese school names used as cover for commercial operations
- MINHHIEN.EDU.VN has **46 domains** including: `forproxy.net` (proxy service), `hungvuonghotel.vn` (hotel), `photo360.vn` (photo service), `kenmedia.asia` (media company), `inchatluongcao.vn` (printing service)
- CONG DOAN UNIVERSITY uses `giaiphapemail.net` = "email solution" in Vietnamese (commercial service)
- TRUNG HỌC XUÂN PHƯƠNG uses `.online` TLD
- 3M licenses for 12 users (MINHHIEN), A1 schools with 2,199 TB on 0 active sites

---

## 3. Additional Confirmed Fraud Tenants (Not Part of Rings)

### 3.1 In FAB — Identified but Not Freed

| # | Tenant ID | Name | Country | Domain | ODB TB | FAB Status | Fraud Signal |
|---|-----------|------|---------|--------|--------|------------|-------------|
| 1 | `d1cba942-*` | RUDY MOORE SCHOOL | US | — | 245.2 | Identified Feb 2023, NO action | Fake school name |
| 2 | `f77d8672-*` | CUHKE | HK | `krynn.onmicrosoft.com` | 137.8 | DELETE FAIL + rolled back | Gibberish, HK |
| 3 | `4c6fbf4a-*` | NMU.EDU.CN | CN | `nmu.edu.cn` | 134 | Identified Aug 2024, no action | 3M lic, 94 users |
| 4 | `bce37303-*` | ANBAIA | HK | `hloli.cf` | 156 | Status 7, Sep 2022, no action | `.cf` TLD, gibberish |
| 5 | `e7bbbeeb-*` | PANGRUJUN | HK | `my.cittedu.onmicrosoft.com` | 116 | Status 7, no action | HK, fake EDU |
| 6 | `7a1893c8-*` | SMAN 08 TASIKMALAYA | ID | — | 243 | **BLOCK ROLLED BACK** | Indonesia |
| 7 | `0e32efc1-05b6-4037-91ce-a784e3860549` | QLB | HK | `qlb14.onmicrosoft.com` | 88.5 | Status 7, Sep 2022, no action | 3-char gibberish |
| 8 | `6ce83f62-638b-486b-95ea-320db6083e31` | MICROSOFT 365 | US | `m365.top` | 77.4 | DELETE ROLLBACK FAIL (stuck) | Brand impersonation |
| 9 | `47568dda-4533-4c4d-9416-f6827b3b46c9` | RMUYNDTB | HK | `rmuyndtb.onmicrosoft.com` | 51.0 | DELETE ROLLBACK FAIL (stuck) | Gibberish, HK |
| 10 | `73e65d9c-c436-4f0e-b4bc-344a5fbd08e4` | ACADEMYCONSULTINGGROUP.COM | US | `academyconsultinggroup.com` | 25.7 | ✅ BLOCKED Apr 2023 | Consulting firm on EDU |
| 11 | `4939e742-fd41-4e0c-a3ea-95f0edab18bd` | LMX | CN | `lmx365.com`, `jyzx.bsziegelbruecke.ch` | 24.0 | ❌ DELETE ROLLED BACK | 365 domain + stolen Swiss domain |
| 12 | `982eeac5-0b27-41c2-87f5-06744ebf3cd7` | WHITE AND DOUGLAS ASSOCIATES | HK | `lwuobryv.onmicrosoft.com` | 23.4 | In FAB (large result) | Fake name, gibberish handle |
| 13 | `0b104bf4-c241-4cf0-ab83-d6c056430d90` | ATUO UNIVERSITY | HK | `msa3.me` | 15.9 | In FAB (large result) | Fake university, 1.5M lic |

### 3.2 NET-NEW Fraud — NOT in FAB (Never Identified)

| # | Tenant ID | Name | Country | Domain | ODB TB | Active Sites | Growth 6mo | Fraud Signal |
|---|-----------|------|---------|--------|--------|-------------|------------|-------------|
| 1 | `5704f9de-c341-49a5-acaf-0b97fd0c0bb0` | VIEN DAO TAO QUOC TE | VN | `isbmkt.onmicrosoft.com` | 98.3 | 12 | +16.8 TB | Marketing handle, A3, 10 lic |
| 2 | `9c25d6d6-5db4-46ea-b9ee-daace9599fab` | COLEGIO PADRE DEHON | ES | 6 domains | 75.0 | 7 | — | A3, 25 users, 6 domains on a school |
| 3 | `83d334bb-8f10-49b1-8720-1e36237185f8` | GEMEINSCHAFTSSCHULE "AM URBACH" | DE | `tgs-am-urbach.de` | 46.3 | 3 | — | 20M lic for 34 users, 46 TB |
| 4 | `8e673338-6dd4-478f-afed-bd793ecb0db9` | NANJING NO. 1 | CN | `mmlcc.onmicrosoft.com` | 37.8 | 0 | — | 16M lic, gibberish handle, 43 users |
| 5 | `a5aefaa1-3233-4174-903a-8a176bb6d0f4` | HIMAWARIGAKUEN | JP | `.ed.jp` domain | 35.0 | 7 | — | E3, 16 users, disproportionate |
| 6 | `abc3dbf4-0b25-4265-ae53-9498462f0d98` | 부산대저고등학교 | KR | — | 23.0 | 19 | +14.6 TB | KR school, rapidly growing |
| 7 | `f2a506d3-ef11-4f86-8c51-e5ea67ec5a67` | THPT THUY HUONG | VN | `thptthuyhuong.org` | 20.8 | 0 | — | `.org` domain, 0 active |
| 8 | `f37a2a2d-a0b8-4c3d-99aa-f026eb3cf232` | 宁夏大学 (Ningxia University) | CN | `aegfwacnz3.onmicrosoft.com` | 17.9 | 0 | — | 3M lic, 11 users, gibberish handle |
| 9 | `0c8c91d7-47ab-416b-b4f3-ae71d8f41a1a` | AGASYSTEMS.COM | FR | `agasystems.com` | 4.2 | 3 | +3.2 TB | Commercial IT domain on EDU, 1M lic |
| 10 | `6d52c02b-6605-4233-8ee3-8bb200d534ce` | COLEGIO 4 DE JULHO | BR | — | 3.1 | 23 | +3 TB (from 0) | Just started explosive filling |

**Net-new total: ~361 TB. Growing at ~20+ TB/quarter.**

> ⚠️ **Note on HIMAWARIGAKUEN and 부산대저고등학교**: These have more active sites (7 and 19 respectively) and could be legitimate schools with high storage usage. Recommend further investigation before ingestion.

---

## 4. Legitimate Tenants Identified (Excluded from Fraud Count)

| Tenant ID | Name | Country | ODB TB | Why Legitimate |
|-----------|------|---------|--------|---------------|
| `838c6f55-*` | POLITECNICO DI TORINO - IT | IT | 28 | Real Italian polytechnic, 25K enabled users, created 2015 |
| `5ee2655e-*` | 台北市新湖國小 (Xinhu Elementary) | TW | 111 | Real Taiwanese school (need further verification) |

---

## 5. Remediation Failure Analysis

### 5.1 The Core Problem: No Storage Has Been Freed

Every fraudulent tenant investigated — regardless of FAB pipeline status — still has its storage on disk. The remediation pipeline has a systematic failure to reclaim storage.

### 5.2 Remediation Status Breakdown

| Status | Tenants | Storage (TB) | Problem |
|--------|---------|-------------|---------|
| **DELETE ROLLED BACK** | 8 | ~516 | Delete initiated → rolled back, storage intact |
| **DELETE FAILED + ROLLBACK FAILED** | 3 | ~164 | Stuck in limbo — can't delete, can't rollback |
| **BLOCK ROLLED BACK** | 1 | 243 | SMAN 08 TASIKMALAYA — block undone |
| **Identified, NO action taken** | 6 | ~901 | Sitting in pipeline 2-3+ years with zero action |
| **Delete scheduled, NEVER executed** | 5 | ~746 | DELETE INSERTED INTO SCHEDULE → nothing happened |
| **READONLY only** (no block/delete) | 5 | ~233 | Weakest remediation — doesn't free storage or prevent access for cached files |
| **BLOCKED, storage not freed** | 11 | ~511 | Block succeeded but storage remains on disk |
| **NET-NEW (not in FAB)** | 10 | ~361 | Never identified by any detection rule |
| **Total** | **49** | **~3,675** | |

### 5.3 Tenants Requiring Re-Ingestion (Failed Remediation)

The following tenants had remediation actions that failed or were rolled back. They should be re-ingested for retry:

```
# DELETE ROLLED BACK — need re-ingestion for retry
e36bc26b-8604-4291-a7ad-354961779970  # THZXG.YWMNE (38.7 TB) - 365site.top
7c943324-9b1d-4c06-bd70-fe70db130773  # GOSPEL RESCUE (33.8 TB) - asso.me
2e4eb929-79d3-4c34-8e3d-a4c687cba1e4  # ORCHESTRATE CUTTING-EDGE (100.9 TB)
389f25d4-f57b-4ead-b09d-fa29a3bc4baa  # ADVG.EDU.VN (60.8 TB)
4939e742-fd41-4e0c-a3ea-95f0edab18bd  # LMX (24.0 TB) - lmx365.com
f77d8672-ec2e-4857-8dd7-01a096592866  # CUHKE (137.8 TB)
7a1893c8-*                             # SMAN 08 TASIKMALAYA (243 TB) - block rolled back
c7e69b2a-424f-47a1-a995-dfede77d4040  # CNAVN (20.1 TB) - delete rollback fail

# DELETE FAILED + ROLLBACK FAILED (stuck in limbo)
7807ef4b-5a8f-41f8-86e1-a9418445951a  # CHARLES INC. (35.6 TB) - office365.uno
47568dda-4533-4c4d-9416-f6827b3b46c9  # RMUYNDTB (51.0 TB)
6ce83f62-638b-486b-95ea-320db6083e31  # MICROSOFT 365 (77.4 TB) - m365.top

# IDENTIFIED BUT NO ACTION (2-3+ years)
f90080c9-9e55-4dae-8262-498f47cf436c  # STRATEGIZE (177.9 TB) - 365proplus.site — 3 YEARS NO ACTION
d1cba942-ccae-4f46-b717-45dbebc758a4  # RUDY MOORE SCHOOL (245.2 TB) — 3 YEARS NO ACTION
bce37303-*                             # ANBAIA (156 TB) — 3+ YEARS NO ACTION
e7bbbeeb-*                             # PANGRUJUN (116 TB) — 3+ YEARS NO ACTION
0e32efc1-05b6-4037-91ce-a784e3860549  # QLB (88.5 TB) — 3+ YEARS NO ACTION
4c6fbf4a-*                             # NMU.EDU.CN (134 TB)
e648dc98-*                             # CONG DOAN UNIVERSITY (106 TB)
10f4e3b4-08e4-4bb4-8c33-47efb0d38c5f  # TRUNG HỌC XUÂN PHƯƠNG (76 TB)

# DELETE SCHEDULED, NEVER EXECUTED
39af2df3-000d-416c-aa00-e74404f2548e  # FOSSCHOOLS (22.3 TB) - ms365officenw.xyz
ae66e8e3-ac8c-4bee-8e1d-91778775f4a8  # DONNA INC. (21.2 TB) - o365th.com
eecba1cb-cad5-48b8-b418-e6e29565a18e  # 365 USERS (51.8 TB) - genuine365.net
d5dfe8c8-4856-4da5-b55d-6cff6f5a98f8  # 陡陌星雲 (22.0 TB) - 0ffice.tw
5765f1fe-7f94-4dfb-a770-e6f4e2b3c41f  # MICROSOFT 365 (604.8 TB) - 365i.team — LARGEST SINGLE TENANT

# READONLY ONLY (needs escalation to block/delete)
6288d59d-3b01-40d0-8ff0-3daf345010af  # DADA (40.1 TB) - offices365.co
35704715-c414-4c15-a7a3-cffb89babf06  # GHEUGE (21.0 TB) - office2021.co
5821f78b-bfa4-4457-854a-78d307adede1  # MINHHIEN.EDU.VN (31.1 TB) - 46 domains!
186b8e6c-*                             # 台北市第一女子 (110 TB) - 365office.digital
```

### 5.4 Net-New Tenants for Ingestion

```
# NOT IN FAB — need initial ingestion
5704f9de-c341-49a5-acaf-0b97fd0c0bb0  # VIEN DAO TAO QUOC TE (98.3 TB) - VN, GROWING
9c25d6d6-5db4-46ea-b9ee-daace9599fab  # COLEGIO PADRE DEHON (75.0 TB) - ES
83d334bb-8f10-49b1-8720-1e36237185f8  # GEMEINSCHAFTSSCHULE AM URBACH (46.3 TB) - DE
8e673338-6dd4-478f-afed-bd793ecb0db9  # NANJING NO. 1 (37.8 TB) - CN
a5aefaa1-3233-4174-903a-8a176bb6d0f4  # HIMAWARIGAKUEN (35.0 TB) - JP [verify first]
abc3dbf4-0b25-4265-ae53-9498462f0d98  # 부산대저고등학교 (23.0 TB) - KR [verify first]
f2a506d3-ef11-4f86-8c51-e5ea67ec5a67  # THPT THUY HUONG (20.8 TB) - VN
f37a2a2d-a0b8-4c3d-99aa-f026eb3cf232  # 宁夏大学 (17.9 TB) - CN
0c8c91d7-47ab-416b-b4f3-ae71d8f41a1a  # AGASYSTEMS.COM (4.2 TB) - FR, GROWING
6d52c02b-6605-4233-8ee3-8bb200d534ce  # COLEGIO 4 DE JULHO (3.1 TB) - BR, GROWING
```

---

## 6. Fraud Prevalence Summary

### 6.1 By Category

| Category | Tenants | ODB Storage | % of EDU ODB | Disposition |
|----------|---------|-------------|-------------|-------------|
| **Fraud identified + remediation attempted** | ~30 | ~2,700 TB | 1.1% | Blocked/READONLY but storage on disk |
| **Fraud identified + NO action taken** | ~11 | ~1,600 TB | 0.7% | Sitting in pipeline for years |
| **Fraud identified + action FAILED/ROLLED BACK** | ~12 | ~1,000 TB | 0.4% | Pipeline failures, stuck |
| **Fraud identified + delete scheduled, never executed** | ~5 | ~750 TB | 0.3% | Scheduler failure |
| **Subtotal: Fraud identified** | **~58** | **~6,050 TB** | **2.5%** | |
| **Fraud NOT identified (net-new)** | **10** | **~361 TB** | **0.1%** | Never detected |
| **RED tier not yet investigated** | ~100+ | ~3,900 TB | 1.6% | Likely fraud |
| **ORANGE tier not yet investigated** | ~900+ | ~2,900 TB | 1.2% | Mixed fraud/legit |
| **WATCH tier (0 active, >100GB)** | ~700 | ~230 TB | 0.1% | Likely dormant fraud |
| **Total confirmed + highly suspected** | **~1,770** | **~13,440 TB** | **5.5%** | |

### 6.2 By Ring

| Ring | Tenants | Storage TB | Status |
|------|---------|-----------|--------|
| Spring 2020 Mega-Ring | 11 | 413 | Mixed: some blocked, some failed, some no action |
| Corporate Buzzword Ring | 3 | 344 | 1 blocked, 1 rolled back, 1 no action (3 years!) |
| TW/CN 365 Reselling | 7 | 830 | Mixed: some blocked, some READONLY, some scheduled |
| VN School Hijacking | 8 | 2,613 | 1 blocked, rest failed/no action, 2 net-new |
| Individual fraudsters | 20+ | ~2,850 | Mixed |
| **Total** | **49+** | **~7,050** | |

---

## 7. Domain Pattern Analysis

### 7.1 365/Office-Branded Domains (Cloud Storage Reselling)

These domains are specifically designed to attract customers buying cloud storage:

| Domain | Tenant | Storage TB |
|--------|--------|-----------|
| `365i.team` | MICROSOFT 365 | 604.8 |
| `365proplus.site` | STRATEGIZE VALUE-ADDED PARADIGMS | 177.9 |
| `365office.digital` | 台北市第一女子高級中學 | 110 |
| `x365mail.com` | ORCHESTRATE CUTTING-EDGE | 100.9 |
| `office365store.top` | WKTSCHOOLO.WKTSCHOOLO | 85.7 |
| `cloudmicrosoft.in` | MORPH B2B PARTNERSHIPS | 62.2 |
| `genuine365.net` | 365 USERS | 51.8 |
| `office365net.com` | LSXSCHOOLO.LSXSCHOOLO | 46.8 |
| `offices365.co` | DADA | 40.1 |
| `365site.top` | THZXG.YWMNE | 38.7 |
| `office365.uno` | CHARLES INC. | 35.6 |
| `officems365.live` | OFFICE 365 | 30.1 |
| `officeid.co` | MICROSOFT 365 APPS FOR ENTERPRISE | 28.9 |
| `lmx365.com` | LMX | 24.0 |
| `ms365officenw.xyz` | FOSSCHOOLS.FOSSCHOOLS | 22.3 |
| `0ffice.tw` | 陡陌星雲 | 22.0 |
| `office2021.co` | GHEUGE | 21.0 |
| `o365th.com` | DONNA INC. | 21.2 |
| `m365.top` | MICROSOFT 365 | 77.4 |
| `365c.live` | UQVSCHOOLO.UQVSCHOOLO | 16.6 |
| **Total** | | **~1,577 TB** |

### 7.2 Target Markets by Domain TLD

| TLD Pattern | Target Market | Examples |
|-------------|--------------|---------|
| `.top` | China/generic | `office365store.top`, `365site.top`, `m365.top` |
| `.co` / `.co.id` | Indonesia | `officeid.co`, `offices365.co`, `email-co.id` |
| `.live` / `.xyz` | Generic/disposable | `365c.live`, `officems365.live`, `ms365officenw.xyz` |
| `.tw` | Taiwan | `0ffice.tw` |
| `.in` | India | `cloudmicrosoft.in` |
| `.uno` | Latin America | `office365.uno` |
| `.com` | Thailand | `o365th.com` |
| `.site` | Generic | `365proplus.site` |

---

## 8. Key Findings & Recommendations

### 8.1 Storage Reclamation Is Broken
The #1 finding is that **zero bytes of fraudulent storage have been reclaimed** across all investigated tenants. Delete operations systematically fail and get rolled back. Block operations succeed but don't free storage. The 14 PB of fraud storage is effectively permanent unless a new reclamation mechanism is developed.

### 8.2 Detection Gaps
- The Spring 2020 ring was not detected until late 2022 — 2.5 years of unimpeded storage abuse
- STRATEGIZE VALUE-ADDED PARADIGMS (178 TB) has been identified for **3+ years** with zero remediation action
- 10 tenants totaling 361 TB were never identified by any detection rule
- Growing net-new fraud: VIEN DAO TAO is adding 16.8 TB every 6 months, AGASYSTEMS +3.2 TB, COLEGIO 4 DE JULHO went from 0 to 3 TB

### 8.3 Recommendations
1. **Immediate**: Ingest 10 net-new fraud tenants into FAB pipeline
2. **Re-ingest**: 28 tenants with failed/rolled-back/stalled remediation for retry
3. **Storage reclamation**: Investigate why delete operations fail — this is the single biggest gap
4. **Domain blocklist**: Add all 365-branded domains from §7.1 to the blocklist
5. **Detection rule**: Flag new EDU tenants using 365/Office-branded custom domains
6. **Ring detection**: Look for more members of the Spring 2020 ring (created April-May 2020, US, 10K A1)
7. **Scale investigation**: ~900 ORANGE tier tenants and ~700 WATCH tier tenants remain uninvestigated

---

## Appendix A: Complete Investigated Tenant Registry

### A.1 All Fraud Tenants with Full Details

| # | Tenant ID | Name | Country | ODB TB | Active | Sites | Domain | Created | FAB ID | FAB Status | Ring |
|---|-----------|------|---------|--------|--------|-------|--------|---------|--------|-----------|------|
| 1 | `9f85948e` | TRƯỜNG THCS PHÚC THUẬN | VN | 2,199 | 0 | — | `phucthuannv.edu.vn` | — | Y | BLOCKED Feb 2025 | VN School |
| 2 | `5765f1fe` | MICROSOFT 365 | US | 604.8 | 0 | 171,032 | `365i.team` | — | Y | Delete sched., never done | TW/CN 365 |
| 3 | `d1cba942` | RUDY MOORE SCHOOL | US | 245.2 | 0 | 1,482 | — | — | Y | Identified, NO ACTION 3yr | Individual |
| 4 | `7a1893c8` | SMAN 08 TASIKMALAYA | ID | 243 | — | — | — | — | Y | BLOCK ROLLED BACK | Individual |
| 5 | `f90080c9` | STRATEGIZE VALUE-ADDED PARADIGMS | US | 177.9 | 0 | 8,465 | `365proplus.site` | 2018-11-25 | Y | Identified, NO ACTION 3yr | Buzzword |
| 6 | `bce37303` | ANBAIA | HK | 156 | — | — | `hloli.cf` | — | Y | Status 7, NO ACTION 3yr | Individual |
| 7 | `f77d8672` | CUHKE | HK | 137.8 | 0 | 9,045 | `krynn.onmicrosoft.com` | — | Y | DELETE FAIL + rollback | Individual |
| 8 | `4c6fbf4a` | NMU.EDU.CN | CN | 134 | — | — | `nmu.edu.cn` | — | Y | Identified, no action | Individual |
| 9 | `e7bbbeeb` | PANGRUJUN | HK | 116 | — | — | `my.cittedu.onmicrosoft.com` | — | Y | Status 7, NO ACTION | Individual |
| 10 | `186b8e6c` | 台北市第一女子高級中學 | TW | 110 | — | — | `365office.digital` | — | Y | READONLY only | TW/CN 365 |
| 11 | `e648dc98` | CONG DOAN UNIVERSITY | VN | 106 | 8 | — | `giaiphapemail.net` | — | Y | Identified, no action | VN School |
| 12 | `2e4eb929` | ORCHESTRATE CUTTING-EDGE | US | 100.9 | 0 | 8,504 | `x365mail.com` | 2018-11-25 | Y | DELETE ROLLED BACK | Buzzword |
| 13 | `5704f9de` | VIEN DAO TAO QUOC TE | VN | 98.3 | 12 | 12 | `isbmkt.onmicrosoft.com` | 2021-05 | **N** | 🆕 NOT IN FAB | VN School |
| 14 | `0e32efc1` | QLB | HK | 88.5 | 0 | 51 | `qlb14.onmicrosoft.com` | 2018-08 | Y | Status 7, NO ACTION | Individual |
| 15 | `48fc7248` | WKTSCHOOLO.WKTSCHOOLO | US | 85.7 | 0 | 7,394 | `office365store.top` | 2020-05-18 | Y | BLOCKED | Spring 2020 |
| 16 | `6ce83f62` | MICROSOFT 365 | US | 77.4 | 0 | 9,633 | `m365.top` | 2015-09 | Y | DELETE ROLLBACK FAIL | Individual |
| 17 | `10f4e3b4` | TRUNG HỌC XUÂN PHƯƠNG | VN | 76 | 1 | — | `quynhchi.online` | 2021-05 | Y | Identified Mar 2026 | VN School |
| 18 | `9c25d6d6` | COLEGIO PADRE DEHON | ES | 75.0 | 7 | 26 | 6 domains | — | **N** | 🆕 NOT IN FAB | Individual |
| 19 | `1407ff58` | MORPH B2B PARTNERSHIPS | US | 62.2 | 0 | 5,342 | `cloudmicrosoft.in` | 2018-11-25 | Y | BLOCKED | Buzzword |
| 20 | `389f25d4` | ADVG.EDU.VN | VN | 60.8 | 0 | 1,046 | `advg.edu.vn` | 2017-03 | Y | DELETE ROLLED BACK | VN School |
| 21 | `eecba1cb` | 365 USERS | TW | 51.8 | 0 | 9,548 | `genuine365.net` | 2019-05 | Y | Delete sched., never done | TW/CN 365 |
| 22 | `47568dda` | RMUYNDTB | HK | 51.0 | 0 | — | `rmuyndtb.onmicrosoft.com` | 2021-10 | Y | DELETE ROLLBACK FAIL | Individual |
| 23 | `c6c39148` | LSXSCHOOLO.LSXSCHOOLO | US | 46.8 | 0 | 8,047 | `office365net.com` | 2020-05-18 | Y | BLOCKED | Spring 2020 |
| 24 | `83d334bb` | GEMEINSCHAFTSSCHULE AM URBACH | DE | 46.3 | 3 | 23 | `tgs-am-urbach.de` | — | **N** | 🆕 NOT IN FAB | Individual |
| 25 | `df1b5ce3` | MICROSOFT CO. | US | 43.3 | 0 | 9,653 | `mail.cnstu.run` | 2020-05-19 | Y | BLOCKED | Spring 2020 |
| 26 | `6288d59d` | DADA | CN | 40.1 | 0 | 6,340 | `offices365.co` | 2020-04-29 | Y | READONLY only | Spring 2020 |
| 27 | `e36bc26b` | THZXG.YWMNE | US | 38.7 | 0 | 4,319 | `365site.top` | 2020-05-19 | Y | DELETE ROLLED BACK | Spring 2020 |
| 28 | `8e673338` | NANJING NO. 1 | CN | 37.8 | 0 | 43 | `mmlcc.onmicrosoft.com` | — | **N** | 🆕 NOT IN FAB | Individual |
| 29 | `7807ef4b` | CHARLES INC. | US | 35.6 | 0 | 5,224 | `office365.uno` | 2020-05-09 | Y | DELETE FAIL + ROLLBACK FAIL | Spring 2020 |
| 30 | `a5aefaa1` | HIMAWARIGAKUEN | JP | 35.0 | 7 | 13 | `.ed.jp` | — | **N** | 🆕 NOT IN FAB | Individual |
| 31 | `577b1b0c` | CC.DIDIAO.AC.ID | ID | 34.1 | 0 | 44 | 6 domains, city=CULPEPER VA | — | — | Need verification | Individual |
| 32 | `7c943324` | ASSOC OF GOSPEL RESCUE MISSIONS | US | 33.8 | 0 | 7,825 | `asso.me` | 2020-05-25 | Y | DELETE ROLLED BACK | Spring 2020 |
| 33 | `5821f78b` | MINHHIEN.EDU.VN | VN | 31.1 | 0 | 72 | 46 domains! | 2018-01 | Y | READONLY only | VN School |
| 34 | `161d5c41` | OFFICE 365 | TW | 30.1 | 0 | 9,612 | `officems365.live` | 2021-10-30 | Y | BLOCKED | TW/CN 365 |
| 35 | `e5b07230` | MICROSOFT 365 APPS FOR ENTERPRISE | US | 28.9 | 0 | 7,199 | `officeid.co` | 2020-05-18 | Y | BLOCKED | Spring 2020 |
| 36 | `73e65d9c` | ACADEMYCONSULTINGGROUP.COM | US | 25.7 | 0 | 12,614 | `academyconsultinggroup.com` | 2016-12 | Y | BLOCKED | Individual |
| 37 | `e4f9123c` | MICROSOFT 365 | SA | 24.8 | 0 | 57 | `moedogorg.onmicrosoft.com` | 2021-10-29 | Y | BLOCKED | TW/CN 365 |
| 38 | `4939e742` | LMX | CN | 24.0 | 0 | 1,918 | `lmx365.com` | 2021-10-12 | Y | DELETE ROLLED BACK | TW/CN 365 |
| 39 | `982eeac5` | WHITE AND DOUGLAS ASSOCIATES | HK | 23.4 | 0 | 15 | `lwuobryv.onmicrosoft.com` | 2019-07 | Y | In FAB | Individual |
| 40 | `abc3dbf4` | 부산대저고등학교 | KR | 23.0 | 19 | 46 | — | — | **N** | 🆕 NOT IN FAB | Individual |
| 41 | `39af2df3` | FOSSCHOOLS.FOSSCHOOLS | US | 22.3 | 0 | 8,634 | `ms365officenw.xyz` | 2020-05-18 | Y | Delete sched., never done | Spring 2020 |
| 42 | `d5dfe8c8` | 陡陌星雲 | CN | 22.0 | 0 | — | `0ffice.tw` | 2019-03 | Y | Delete sched., never done | TW/CN 365 |
| 43 | `ae66e8e3` | DONNA INC. | US | 21.2 | 0 | 9,235 | `o365th.com` | 2020-05-09 | Y | Delete sched., never done | Spring 2020 |
| 44 | `35704715` | GHEUGE | TW | 21.0 | 0 | 7,180 | `office2021.co` | 2021-10-27 | Y | READONLY only | TW/CN 365 |
| 45 | `f2a506d3` | THPT THUY HUONG | VN | 20.8 | 0 | 20 | `thptthuyhuong.org` | 2021-06 | **N** | 🆕 NOT IN FAB | VN School |
| 46 | `c7e69b2a` | CNAVN | VN | 20.1 | 0 | 18 | `edu.cna.vn` | 2021-07 | Y | DELETE ROLLBACK FAIL | VN School |
| 47 | `f37a2a2d` | 宁夏大学 | CN | 17.9 | 0 | 11 | `aegfwacnz3.onmicrosoft.com` | 2018-08 | **N** | 🆕 NOT IN FAB | Individual |
| 48 | `9559bd6a` | UQVSCHOOLO.UQVSCHOOLO | US | 16.6 | 0 | 19,805 | `365c.live` | 2020-05-18 | Y | BLOCKED | Spring 2020 |
| 49 | `0b104bf4` | ATUO UNIVERSITY | HK | 15.9 | 0 | 37 | `msa3.me` | 2019-07 | Y | In FAB | Individual |
| 50 | `0c8c91d7` | AGASYSTEMS.COM | FR | 4.2 | 3 | 3 | `agasystems.com` | — | **N** | 🆕 NOT IN FAB | Individual |
| 51 | `6d52c02b` | COLEGIO 4 DE JULHO | BR | 3.1 | 23 | 26 | — | — | **N** | 🆕 NOT IN FAB | Individual |

**Total investigated (first pass): 51 tenants. ~5,235 TB (~5.1 PB).**

---

## 9. Extended Investigation — Phase 2 Discoveries

### 9.1 Ring 5: HK Gibberish Cluster (Jul-Aug 2019)

A cluster of Hong Kong-registered tenants with randomized gibberish names, onmicrosoft-only domains, created mid-2019. Pattern: 5-9 char random uppercase names, HK registration, 10K A1 licenses, ~15 ODB sites each storing ~7-8 TB. **All NOT IN FAB.**

| # | Tenant ID | Name | Domain | ODB TB | Sites | Created | FAB |
|---|-----------|------|--------|--------|-------|---------|-----|
| 1 | `728d6e13-4d82-40f2-b544-d3ec6b5afc89` | KKIZZKIFA | `x9p.onmicrosoft.com` | 7.6 | 15 | 2019-07-25 | 🆕 NOT IN FAB |
| 2 | `4bc0aaa5-148b-4d35-94b3-4b5e3d4f0645` | BCOZJOJ | `bng26.onmicrosoft.com` | 7.0 | 13 | 2019-08-03 | 🆕 NOT IN FAB |
| 3 | `2e14be42-e505-4b52-9381-974e9c6ec31e` | GALAXY CLUB | `5t.tf` | 7.2 | 15 | 2019-02-28 | 🆕 NOT IN FAB |
| 4 | `97c5b8e1-b592-4cb3-a08f-57973778dff0` | HC1 | `soiybokz.onmicrosoft.com` | 10.0 | 63 | 2019-07-21 | 🆕 NOT IN FAB |

**Ring total: ~31.8 TB. All net-new. Likely many more members at lower storage levels.**

**Why fraud:** Gibberish names (KKIZZKIFA, BCOZJOJ), gibberish onmicrosoft handles (`x9p`, `bng26`, `soiybokz`), all HK-registered EDU A1 with 10K licenses, no custom domains, zero EDU subscriptions, 0 active sites with all storage inactive 1+ years.

---

### 9.2 Ring 6: August 2018 Chinese "A1 VIP" Network

Tenants created in the same August 24-25, 2018 window, Chinese-operated, including blatant brand-impersonation domains. Combined with DADA operator running across multiple tenants.

| # | Tenant ID | Name | Country | Domain | ODB TB | Created | FAB Status |
|---|-----------|------|---------|--------|--------|---------|------------|
| 1 | `08ecd244-7504-4168-a690-64f7e69ce4bb` | 渡梦信息技术学院 | NC | `office365a1.vip` | 6.7 | 2018-08-25 | ⚠️ Identified, delete scheduled **4 TIMES**, never executed |
| 2 | `07a6feec-b4c9-4b4a-a66b-aa841f1d6a38` | DADA (#2) | CN | `snchd.xyz` + 10 gibberish `.xyz` domains | 7.8 | 2018-08-24 | ❌ DELETE ROLLED BACK |
| 3 | `c268940c-6a9f-40f3-9e73-19200d66b35c` | ABC | HK | `nbdog.com` | 8.0 | 2018-08-24 | 🆕 NOT IN FAB |

**Ring total: ~22.5 TB.**

**Why fraud:**
- `office365a1.vip` — the domain literally advertises "Office 365 A1 VIP" storage service
- DADA#2 has **10 random 5-char `.xyz` domains** (`utkao.xyz`, `uqbzz.xyz`, `uprhh.xyz`, etc.) — programmatically generated
- DADA#2 is the SAME OPERATOR as DADA#1 (`offices365.co`, 40 TB) — combined **48 TB** across 2 tenants
- Same creation window (Aug 24-25 2018) ties them together
- Delete scheduled 4 times for `office365a1.vip` between May 2023 and Dec 2024 — never executed once

---

### 9.3 Cross-Region Fraud: Chinese Operators Using Foreign EDU Registrations

A new pattern emerged: Chinese operators registering EDU tenants in other countries to avoid China-specific scrutiny.

| # | Tenant ID | Name | Registered | Actual Operator | Domain | ODB TB | FAB Status |
|---|-----------|------|-----------|-----------------|--------|--------|------------|
| 1 | `642c7a99-487a-446e-9aee-e99e9a70593e` | DGSTU | CN | CN (zh-CHS) | `brightoncollege.ca`, `stunet.xyz` | 11.5 | ⚠️ Delete scheduled 2×, never done |
| 2 | `7bde4c43-78e0-483d-99ff-2e278db9b566` | WEB.NPU.EDU.RS | RS | CN (city=XIAN, region=SHAANXI) | `web.npu.edu.rs` | 9.4 | 🆕 NOT IN FAB |
| 3 | `b37b5366-e6ad-4427-9040-1a43093c8db0` | 真理大学 ("Truth University") | NZ | CN/TW (Auckland) | `a3.1ove.club` | 9.0 | 🆕 NOT IN FAB |
| 4 | `08ecd244-*` | 渡梦信息技术学院 | NC | CN (city=Fayetteville) | `office365a1.vip` | 6.7 | Delete sched 4×, never done |
| 5 | `88e42071-66b2-48e7-9905-fa9ace47b947` | ARMY | HK | US (region=PENNSYLVANIA) | `armym.onmicrosoft.com` | 8.5 | 🆕 NOT IN FAB |

**Cross-region total: ~45 TB.**

**Why this matters:** These operators use geolocation mismatches to evade detection rules that may target specific countries. A Serbia-registered tenant operated from Xi'an, a New Caledonia tenant from Fayetteville, etc. The `a3.1ove.club` domain uses number-for-letter substitution (`1` for `l`).

---

### 9.4 Additional Regional Fraud Discoveries

#### Southeast Asia: Indonesia + Malaysia + Vietnam

| # | Tenant ID | Name | Country | Domain | ODB TB | FAB Status | Signal |
|---|-----------|------|---------|--------|--------|------------|--------|
| 1 | `a4188e70-e37f-4e97-84f4-cf9455efc978` | SMAN 1 RAJAGALUH | ID | `email.smanra.sch.id` | 11.5 | 🆕 NOT IN FAB | 1.5M lic, 595 enabled, 0 active |
| 2 | `ae901ed4-10ba-4e0f-b0f7-2ba2efd5067c` | PKT | MY | `polipkt.onmicrosoft.com` | 13.9 | 🆕 NOT IN FAB | 4M lic, 10 users, 0 active |
| 3 | `3d59a7f0-b097-44b6-b988-66e7e4faef15` | TAN PHU HIGH SHOOL | VN | `thpttanphu-edu.online` | 12.7 | 🆕 NOT IN FAB | `.online` TLD, 1M lic, 48 enabled |
| 4 | `1509af63-145b-48d0-818f-f10150faa056` | WEPRO | VN | `wepro.vn` | 15.6 | ❌ DELETE ROLLBACK FAIL | Commercial company name, 3M lic |

**Regional total: ~53.7 TB.**

#### North America

| # | Tenant ID | Name | Country | Domain | ODB TB | FAB Status | Signal |
|---|-----------|------|---------|--------|--------|------------|--------|
| 1 | `ecc65b32-6aba-4346-8a1b-39c0c33c1c50` | MAXEY ACADEMY | US | `maxeyacademy.com` | 13.2 | 🆕 NOT IN FAB | 3M lic, 29 enabled, 0 active |
| 2 | `9214c516-bfe2-4732-882c-5504b5139bff` | TECHGURU | CA | `mywishschool.ca`, `mylittlewishdaycare.com` | 13.8 | ⚠️ Identified, NO action | Daycare company using EDU, 3M lic |

**Regional total: ~27.0 TB.**

#### East Asia: Taiwan + China additional

| # | Tenant ID | Name | Country | Domain | ODB TB | FAB Status | Signal |
|---|-----------|------|---------|--------|--------|------------|--------|
| 1 | `f355f460-072c-40cb-866d-507083d119c7` | FUHWA SENIOR HIGH SCHOOL | TW | `name163.cn` | 8.0 | 🆕 NOT IN FAB | TW school with `.cn` commercial domain |
| 2 | `f4653fce-13ca-4b7d-8a91-6b75b76fd06e` | XENX | CN | `xenx.onmicrosoft.com` | 9.1 | 🆕 NOT IN FAB | 3.5M lic, 42 enabled, 0 active |
| 3 | `73350d3b-c491-47b7-9bdc-0c4881bbc71c` | CTDU | CN | `duttu.onmicrosoft.com` | 7.7 | 🆕 NOT IN FAB | Gibberish, 4 users, 0 active |
| 4 | `6c467812-64af-4026-a692-ae3a93373f7d` | BETRC | TW | `betrc.nctu.edu.tw` | 7.7 | 🆕 NOT IN FAB | NCTU sub-domain, 3M lic, 9 users |

**Regional total: ~32.5 TB.**

#### Spring 2020 Ring — Additional Member

| # | Tenant ID | Name | Domain | ODB TB | Created | FAB Status |
|---|-----------|------|--------|--------|---------|------------|
| 12 | `95519262-ab11-4bc1-835b-b84bcce42397` | NIMTE | `t.365web.org`, `a1.vssnumber.eu.org` | 10.8 | 2020-05-26 | ⚠️ Identified Aug 2024, NO action |

Created 2020-05-26 — same burst. Domains: `365web.org` (365-branded) and `a1.vssnumber.eu.org` (A1 reference). **Spring 2020 ring now has 12 confirmed members, ~424 TB total.**

---

## 10. Updated Regional Fraud Prevalence

| Region | Confirmed Fraud Tenants | Fraud Storage TB | Countries |
|--------|------------------------|-----------------|-----------|
| **Asia Pacific — Greater China** | 20+ | ~1,240 | CN, HK, TW |
| **Southeast Asia** | 12+ | ~2,700 | VN, ID, MY |
| **North America (reselling rings)** | 18+ | ~1,530 | US (mostly ring tenants) |
| **Europe** | 4 | ~73 | DE, RS, FR, NC |
| **Latin America** | 3 | ~78 | ES, BR |
| **Middle East** | 1 | ~25 | SA |
| **East Asia (JP/KR)** | 2 | ~58 | JP, KR |
| **Oceania** | 2 | ~23 | NZ, AU-based |
| **Canada** | 1 | ~14 | CA |
| **Total** | **67** | **~5,741 TB** | **18 countries** |

---

## 11. Updated Running Totals — All Investigated Tenants

### 11.1 Net-New Fraud (NOT IN FAB) — Complete List for Ingestion

```
# Phase 1 discoveries
5704f9de-c341-49a5-acaf-0b97fd0c0bb0  # VIEN DAO TAO QUOC TE (98.3 TB) - VN
9c25d6d6-5db4-46ea-b9ee-daace9599fab  # COLEGIO PADRE DEHON (75.0 TB) - ES
83d334bb-8f10-49b1-8720-1e36237185f8  # GEMEINSCHAFTSSCHULE AM URBACH (46.3 TB) - DE
8e673338-6dd4-478f-afed-bd793ecb0db9  # NANJING NO. 1 (37.8 TB) - CN
a5aefaa1-3233-4174-903a-8a176bb6d0f4  # HIMAWARIGAKUEN (35.0 TB) - JP [verify]
abc3dbf4-0b25-4265-ae53-9498462f0d98  # 부산대저고등학교 (23.0 TB) - KR [verify]
f2a506d3-ef11-4f86-8c51-e5ea67ec5a67  # THPT THUY HUONG (20.8 TB) - VN
f37a2a2d-a0b8-4c3d-99aa-f026eb3cf232  # 宁夏大学 (17.9 TB) - CN
0c8c91d7-47ab-416b-b4f3-ae71d8f41a1a  # AGASYSTEMS.COM (4.2 TB) - FR
6d52c02b-6605-4233-8ee3-8bb200d534ce  # COLEGIO 4 DE JULHO (3.1 TB) - BR

# Phase 2 discoveries
ecc65b32-6aba-4346-8a1b-39c0c33c1c50  # MAXEY ACADEMY (13.2 TB) - US
3d59a7f0-b097-44b6-b988-66e7e4faef15  # TAN PHU HIGH SHOOL (12.7 TB) - VN
a4188e70-e37f-4e97-84f4-cf9455efc978  # SMAN 1 RAJAGALUH (11.5 TB) - ID
ae901ed4-10ba-4e0f-b0f7-2ba2efd5067c  # PKT (13.9 TB) - MY
97c5b8e1-b592-4cb3-a08f-57973778dff0  # HC1 (10.0 TB) - HK
7bde4c43-78e0-483d-99ff-2e278db9b566  # WEB.NPU.EDU.RS (9.4 TB) - RS/CN
f4653fce-13ca-4b7d-8a91-6b75b76fd06e  # XENX (9.1 TB) - CN
b37b5366-e6ad-4427-9040-1a43093c8db0  # 真理大学 (9.0 TB) - NZ/CN
88e42071-66b2-48e7-9905-fa9ace47b947  # ARMY (8.5 TB) - HK/US
c268940c-6a9f-40f3-9e73-19200d66b35c  # ABC (8.0 TB) - HK
f355f460-072c-40cb-866d-507083d119c7  # FUHWA SENIOR HIGH SCHOOL (8.0 TB) - TW
73350d3b-c491-47b7-9bdc-0c4881bbc71c  # CTDU (7.7 TB) - CN
6c467812-64af-4026-a692-ae3a93373f7d  # BETRC (7.7 TB) - TW
728d6e13-4d82-40f2-b544-d3ec6b5afc89  # KKIZZKIFA (7.6 TB) - HK
4bc0aaa5-148b-4d35-94b3-4b5e3d4f0645  # BCOZJOJ (7.0 TB) - HK
2e14be42-e505-4b52-9381-974e9c6ec31e  # GALAXY CLUB (7.2 TB) - HK
```

**Total net-new: 26 tenants, ~506 TB.**

### 11.2 Failed Remediation — Complete List for Re-Ingestion

```
# DELETE ROLLED BACK
e36bc26b-8604-4291-a7ad-354961779970  # THZXG.YWMNE (38.7 TB)
7c943324-9b1d-4c06-bd70-fe70db130773  # GOSPEL RESCUE (33.8 TB)
2e4eb929-79d3-4c34-8e3d-a4c687cba1e4  # ORCHESTRATE CUTTING-EDGE (100.9 TB)
389f25d4-f57b-4ead-b09d-fa29a3bc4baa  # ADVG.EDU.VN (60.8 TB)
4939e742-fd41-4e0c-a3ea-95f0edab18bd  # LMX (24.0 TB)
f77d8672-ec2e-4857-8dd7-01a096592866  # CUHKE (137.8 TB)
07a6feec-b4c9-4b4a-a66b-aa841f1d6a38  # DADA#2 (7.8 TB)
c7e69b2a-424f-47a1-a995-dfede77d4040  # CNAVN (20.1 TB)

# DELETE FAILED + ROLLBACK FAILED (stuck)
7807ef4b-5a8f-41f8-86e1-a9418445951a  # CHARLES INC. (35.6 TB)
47568dda-4533-4c4d-9416-f6827b3b46c9  # RMUYNDTB (51.0 TB)
6ce83f62-638b-486b-95ea-320db6083e31  # MICROSOFT 365 / m365.top (77.4 TB)
1509af63-145b-48d0-818f-f10150faa056  # WEPRO (15.6 TB)

# BLOCK ROLLED BACK
7a1893c8-*                             # SMAN 08 TASIKMALAYA (243 TB)

# IDENTIFIED, NO ACTION (2-3+ years)
f90080c9-9e55-4dae-8262-498f47cf436c  # STRATEGIZE (177.9 TB) - 3 YEARS
d1cba942-ccae-4f46-b717-45dbebc758a4  # RUDY MOORE SCHOOL (245.2 TB)
bce37303-*                             # ANBAIA (156 TB)
e7bbbeeb-*                             # PANGRUJUN (116 TB)
0e32efc1-05b6-4037-91ce-a784e3860549  # QLB (88.5 TB)
4c6fbf4a-*                             # NMU.EDU.CN (134 TB)
e648dc98-*                             # CONG DOAN UNIVERSITY (106 TB)
10f4e3b4-08e4-4bb4-8c33-47efb0d38c5f  # TRUNG HỌC XUÂN PHƯƠNG (76 TB)
95519262-ab11-4bc1-835b-b84bcce42397  # NIMTE / 365web.org (10.8 TB)
9214c516-bfe2-4732-882c-5504b5139bff  # TECHGURU / mywishschool.ca (13.8 TB)

# DELETE SCHEDULED, NEVER EXECUTED
39af2df3-000d-416c-aa00-e74404f2548e  # FOSSCHOOLS (22.3 TB)
ae66e8e3-ac8c-4bee-8e1d-91778775f4a8  # DONNA INC. (21.2 TB)
eecba1cb-cad5-48b8-b418-e6e29565a18e  # 365 USERS (51.8 TB)
d5dfe8c8-4856-4da5-b55d-6cff6f5a98f8  # 陡陌星雲 (22.0 TB)
5765f1fe-7f94-4dfb-a770-e6f4e2b3c41f  # MICROSOFT 365 / 365i.team (604.8 TB)
08ecd244-7504-4168-a690-64f7e69ce4bb  # 渡梦 / office365a1.vip (6.7 TB) — 4× scheduled!
642c7a99-487a-446e-9aee-e99e9a70593e  # DGSTU / brightoncollege.ca (11.5 TB) — 2× scheduled

# READONLY ONLY (needs escalation)
6288d59d-3b01-40d0-8ff0-3daf345010af  # DADA (40.1 TB)
35704715-c414-4c15-a7a3-cffb89babf06  # GHEUGE (21.0 TB)
5821f78b-bfa4-4457-854a-78d307adede1  # MINHHIEN.EDU.VN (31.1 TB) - 46 domains
186b8e6c-*                             # 台北市第一女子 (110 TB)
```

---

## 12. Phase 3: Cohort-Based Systematic Investigation

### 12.1 Cohort Analysis Framework

Six cohorts defined for systematic discovery, prioritized by storage impact:

| Cohort | Definition | Purpose |
|--------|-----------|---------|
| **C1**: Highest storage | Top 100 EDU ODB by raw TB consumed | Find biggest individual tenants |
| **C2**: High storage + low active | >1 TB, ≤5 active sites | Dormant hoarders |
| **C3**: High storage + free | Never paid, A1 free licenses | Exploit pattern |
| **C4**: Country hotspots | CN, VN, HK, TW + emerging | Geographic rings |
| **C5**: EDU manual + viral | `edu=approved` tag + viral subscription | Verification abuse |
| **C6**: D2K flags | CompanyTags anomalies | Detection gaps |

### 12.2 CRITICAL: Highest-Impact Net-New Discovery

**太仓市璜泾镇鹿河小学** (Taicang Yujing Deer River Elementary)
- **Tenant ID:** `1b9b0418-6647-4ce9-a247-342ffb364cb1`
- **Storage:** **800 TB** — third largest fraud tenant found
- **Country:** China (Jiangsu Province, Suzhou)
- **NOT IN FAB** — completely invisible to fraud pipeline
- **D2K tags:** `edu.microsoft.com/edu=approved` — **manually approved as EDU**
- **Domains:** `onenote.plus` (brand impersonation!), `cn.edu.do` (Dominican Republic TLD disguised as CN EDU), `YWGZ.CN`, `schid.partner.onmschina.cn` (Mooncake partner domain)
- **D2K instance:** Mooncake — straddling sovereign/global cloud boundary
- **Licenses:** 400,001 acquired, 281 enabled, 278 ODB sites
- **Technical email:** `cue@live.cn`

**Why critical:** A rural Chinese elementary school with 800 TB of storage, OneNote brand domain, manually approved as EDU, and never identified by FAB. The `onenote.plus` domain suggests potential link to a broader cloud storage reselling operation.

### 12.3 Spring 2020 Ring — Expanded to 19+ Members

The original Ring 1 has grown dramatically with cohort analysis. Additional members found:

| # | Tenant ID | Name | Domain | ODB TB | Created | FAB Status |
|---|-----------|------|--------|--------|---------|------------|
| 12 | `95519262` | NIMTE | `365web.org`, `a1.vssnumber.eu.org` | 10.8 | 2020-05-26 | ⚠️ Identified, NO action |
| 13 | `48fc7248` | WKTSCHOOLO.WKTSCHOOLO | `office365store.top` | 85.7 | 2020-05-18 | ✅ Blocked |
| 14 | `c6c39148` | LSXSCHOOLO.LSXSCHOOLO | `office365net.com` | 46.8 | 2020-05-18 | ✅ Blocked |
| 15 | `df1b5ce3` | MICROSOFT CO. | `mail.cnstu.run` | 43.3 | 2020-05-19 | ✅ Blocked |
| 16 | `e5b07230` | MICROSOFT 365 APPS FOR ENTERPRISE | `officeid.co`, `email-co.id`, `jakartabehaviorcenter.com` | 28.9 | 2020-05-18 | ✅ Blocked (2 fails first) |
| 17 | `d9256a0f` | TEPJP | `office365std.com`, `srisaimoon.com` | 20.7 | 2020-06-08 | ⚠️ ReadOnly only |
| 18 | `9559bd6a` | UQVSCHOOLO.UQVSCHOOLO | `365c.live` → now `c2024.live` | 16.6 | 2020-05-18 | ✅ Blocked |
| 19 | `5e2d744b` | ZMZSCHOOLO.ZMZSCHOOLO | `o365e.live` → now `b2026.live` | 11.3 | 2020-05-18 | ✅ Blocked |

**Updated ring total: 19 confirmed members, ~1,093 TB.**

**Key insight — Domain Rotation:** Operators change domains over time. UQVSCHOOLO went from `365c.live` → `c2024.live`, ZMZSCHOOLO from `o365e.live` → `b2026.live`. The FAB domain at identification differs from current OMS domain.

**Sub-operator — Indonesian Connection:** Tenant #16 (officeid.co) has domains `email-co.id` and `jakartabehaviorcenter.com` — an Indonesian operator using US EDU registration with Spring 2020 pattern.

### 12.4 Corporate Buzzword Ring — Expanded to 4+ Members

| # | Tenant ID | Name | Domain | ODB TB | Created | FAB Status |
|---|-----------|------|--------|--------|---------|------------|
| 4 | `ab4b9072` | EXPLOIT SCALABLE INTERFACES | `crawq8z.onmicrosoft.com` | 10.5 | **2018-11-25** (same day as MORPH B2B) | In FAB |

Both MORPH B2B PARTNERSHIPS and EXPLOIT SCALABLE INTERFACES created on Nov 25, 2018. Combined with STRATEGIZE and ORCHESTRATE, **ring total: ~355 TB**.

`cloudmicrosoft.in` (MORPH B2B) — blatant Microsoft brand impersonation on Indian TLD.

### 12.5 HK Gibberish Cluster — Expanded to 9 Members

Additional member confirmed:

| # | Tenant ID | Name | Domain | ODB TB | Created | FAB Status |
|---|-----------|------|--------|--------|---------|------------|
| 5 | `982eeac5` | WHITE AND DOUGLAS ASSOCIATES | `lwuobryv.onmicrosoft.com` | 23.4 | 2019-07-23 | In FAB (complex remediation) |

**Updated ring total: 9 members, ~196 TB.** Pattern: Corporate-sounding names (WHITE AND DOUGLAS, GALAXY CLUB) or pure gibberish (KKIZZKIFA, BCOZJOJ, RMUYNDTB) + gibberish onmicrosoft handles + HK registration + all mid-2019.

### 12.6 New Pattern: Brand Impersonation Domains

Every ring uses domains that impersonate Microsoft products:

| Domain | Impersonation | Tenant |
|--------|--------------|--------|
| `office365store.top` | Office 365 marketplace | WKTSCHOOLO |
| `office365net.com` | Office 365 network | LSXSCHOOLO |
| `office365std.com` | Office 365 standard | TEPJP |
| `officeid.co` | Office identification | M365 APPS |
| `officems365.live` | Office/MS/365 combined | OFFICE 365 |
| `office365a1.vip` | Office 365 A1 VIP tier | 渡梦 |
| `cloudmicrosoft.in` | Cloud Microsoft India | MORPH B2B |
| `365i.team` | 365 team | MICROSOFT 365 |
| `365proplus.site` | 365 ProPlus | STRATEGIZE |
| `x365mail.com` | 365 mail | ORCHESTRATE |
| `onenote.plus` | OneNote product | 太仓市 elementary |
| `0ffice.tw` | Office (zero-for-O) | 陡陌星雲 |
| `offices365.co` | Office 365 | DADA |
| `m365.top` | M365 product | MICROSOFT 365 |

### 12.7 EDU Verification Abuse (Cohort 5)

D2K CompanyTags reveal tenants approved through the EDU verification process:

| Tenant | Country | Storage TB | CompanyTag | Signal |
|--------|---------|-----------|-----------|--------|
| 太仓市 elementary | CN | 800 | `edu=approved` | OneNote.plus domain, onenote brand |
| PHÚC THUẬN | VN | 2,200 | `edu=approved`, `supportRequestSubmitted` | Viettel EDU email program |

**Both went through manual EDU approval and together consume 3 PB.** The EDU verification process is a critical vulnerability.

### 12.8 Cross-Region Operator Pattern

Chinese operators using foreign country registrations to evade detection:

| Tenant | Registered Country | Actual Operator Location | Evidence |
|--------|-------------------|-------------------------|----------|
| WEB.NPU.EDU.RS | Serbia | China (Xi'an, Shaanxi) | City/Region fields |
| 真理大学 | New Zealand | China/Taiwan | `a3.1ove.club` domain |
| 渡梦 | New Caledonia | China (Fayetteville) | `office365a1.vip` |
| ARMY | Hong Kong | US (Pennsylvania) | Region field |
| CC.DIDIAO.AC.ID | Indonesia | US (Culpeper, Virginia) | City/Region fields |
| DGSTU | China | Canada (impersonation) | `brightoncollege.ca` |

### 12.9 False Positives — Commercial Tenants in EDU Filter

Our ~100 TB StorageLimit filter catches some non-EDU tenants:

| Tenant ID | Name | Category | Country | Storage TB | Why False Positive |
|-----------|------|----------|---------|-----------|-------------------|
| `c6b48560` | DAYMON WORLDWIDE | Commercial | US/CT | 109 | Real company, E3-level storage |
| `07513973` | CONSULTING TECHNOLOGY ANTANA | Commercial | ES | 123 | Paid E3, Sevilla consulting |
| `a597ef09` | HIMANYA EXPORT | Commercial | IN | 96 | Paid Business Basic, India export co |

**Legitimate EDU tenants confirmed:**

| Tenant ID | Name | Country | Storage TB | Why Legitimate |
|-----------|------|---------|-----------|---------------|
| `838c6f55` | POLITECNICO DI TORINO | Italy | 28 | Real major Italian university, est. 2015, 25K users |
| `3392b46a` | LAHDEN AMMATTIKORKEAKOULU | Finland | 10.7 | Real Finnish university (LAB/LAMK), est. 2016 |

---

## 13. Stack-Ranked Fraud Tenants by Storage Impact

### Tier S: MEGA (>100 TB each) — 7 tenants, ~3,908 TB

| Rank | TB | Tenant | Ring | Country | FAB Status |
|------|-----|--------|------|---------|-----------|
| 1 | 2,200 | PHÚC THUẬN | Individual | VN | Blocked Feb 2025 |
| 2 | 800 | 太仓市 elementary | Individual | CN | **🆕 NOT IN FAB** |
| 3 | 605 | MICROSOFT 365 / `365i.team` | Spring 2020 / TW-CN 365 | US | Delete sched, never exec |
| 4 | 245 | RUDY MOORE SCHOOL | Corp Buzzword | — | Identified, NO action |
| 5 | 238 | SMAN 08 TASIKMALAYA | Individual | ID | Block ROLLED BACK |
| 6 | 178 | STRATEGIZE... | Corp Buzzword | US | **NO ACTION 3 YEARS** |
| 7 | 138 | CUHKE | Spring 2020 | — | Delete ROLLED BACK |

### Tier A: LARGE (20-99 TB each) — 26 tenants, ~1,410 TB

| Rank | TB | Tenant | Ring | FAB Status |
|------|-----|--------|------|-----------|
| 8 | 98.3 | VIEN DAO TAO QUOC TE | VN School | 🆕 NOT IN FAB |
| 9 | 100.9 | ORCHESTRATE CUTTING-EDGE | Corp Buzzword | Delete ROLLED BACK |
| 10 | 88.5 | QLB | HK Cluster | Identified, NO action |
| 11 | 85.7 | WKTSCHOOLO | Spring 2020 | Blocked |
| 12 | 77.4 | MICROSOFT 365 / m365.top | Individual | Delete fail+rollback fail |
| 13 | 76.5 | XUÂN PHƯƠNG | VN School | Identified, NO action |
| 14 | 75.0 | COLEGIO PADRE DEHON | Individual | 🆕 NOT IN FAB |
| 15 | 62.2 | MORPH B2B / cloudmicrosoft.in | Corp Buzzword | Blocked |
| 16 | 60.8 | ADVG.EDU.VN | VN | Delete ROLLED BACK |
| 17 | 51.9 | RMUYNDTB | HK Cluster | Delete fail+rollback fail |
| 18 | 51.8 | 365 USERS | TW-CN 365 | Delete sched, never exec |
| 19 | 46.8 | LSXSCHOOLO | Spring 2020 | Blocked |
| 20 | 46.3 | GEMEINSCHAFTSSCHULE | Individual | 🆕 NOT IN FAB |
| 21 | 43.3 | MICROSOFT CO. | Spring 2020 | Blocked |
| 22 | 40.1 | DADA #1 | Individual | ReadOnly |
| 23 | 38.7 | THZXG.YWMNE | Spring 2020 | Delete ROLLED BACK |
| 24 | 37.8 | NANJING NO. 1 | Individual | 🆕 NOT IN FAB |
| 25 | 35.6 | CHARLES INC. | Spring 2020 | Delete fail+rollback fail |
| 26 | 34.1 | CC.DIDIAO.AC.ID | Indonesia | Delete fail |
| 27 | 33.8 | GOSPEL RESCUE | Spring 2020 | Delete ROLLED BACK |
| 28 | 31.1 | MINHHIEN.EDU.VN | VN | ReadOnly |
| 29 | 30.1 | OFFICE 365 / officems365.live | TW-CN 365 | Blocked |
| 30 | 28.9 | M365 APPS FOR ENTERPRISE | Spring 2020 | Blocked |
| 31 | 25.7 | ACADEMYCONSULTINGGROUP | Individual | Blocked |
| 32 | 24.0 | LMX | Individual | Delete ROLLED BACK |
| 33 | 23.4 | WHITE AND DOUGLAS | HK Cluster | In FAB |

### Tier B: MEDIUM (5-19 TB each) — 39 tenants, ~442 TB

| Rank | TB | Tenant | Ring | FAB Status |
|------|-----|--------|------|-----------|
| 34 | 22.4 | 陡陌星雲 | TW-CN 365 | Delete sched, never exec |
| 35 | 22.3 | FOSSCHOOLS | Spring 2020 | Delete sched, never exec |
| 36 | 21.2 | DONNA INC. | Spring 2020 | Delete sched, never exec |
| 37 | 21.0 | GHEUGE | TW-CN 365 | ReadOnly |
| 38 | 20.8 | THPT THUY HUONG | VN | 🆕 NOT IN FAB |
| 39 | 20.7 | TEPJP / office365std.com | Spring 2020 | ReadOnly |
| 40 | 20.1 | CNAVN | VN | Delete ROLLED BACK |
| 41 | 18.2 | ABC.MIT.AC.NZ / 5t.ac.cn | Cross-region | Delete ROLLED BACK |
| 42 | 17.9 | 宁夏大学 | Individual | 🆕 NOT IN FAB |
| 43 | 16.6 | UQVSCHOOLO | Spring 2020 | Blocked |
| 44 | 15.6 | WEPRO | VN | Delete rollback FAIL |
| 45 | 13.9 | PKT | MY | 🆕 NOT IN FAB |
| 46 | 13.8 | TECHGURU | Canadian impersonation | Identified, NO action |
| 47 | 13.2 | MAXEY ACADEMY | Individual | 🆕 NOT IN FAB |
| 48 | 12.7 | TAN PHU HIGH SHOOL | VN | 🆕 NOT IN FAB |
| 49 | 11.5 | DGSTU / brightoncollege.ca | Canadian impersonation | Delete sched 2×, never exec |
| 50 | 11.5 | SMAN 1 RAJAGALUH | ID | 🆕 NOT IN FAB |
| 51 | 11.3 | ZMZSCHOOLO | Spring 2020 | Blocked |
| 52 | 10.8 | NIMTE / 365web.org | Spring 2020 | Identified, NO action |
| 53 | 10.5 | EXPLOIT SCALABLE INTERFACES | Corp Buzzword | In FAB |
| 54 | 10.3 | DLJLMNNA / ccouds.xyz | Individual | TBD |
| 55 | 10.0 | HC1 | HK Cluster | 🆕 NOT IN FAB |
| 56 | 9.4 | WEB.NPU.EDU.RS | Cross-region | 🆕 NOT IN FAB |
| 57 | 9.1 | XENX | CN | 🆕 NOT IN FAB |
| 58 | 9.0 | 真理大学 / 1ove.club | Cross-region | 🆕 NOT IN FAB |
| 59 | 8.5 | ARMY | HK/US | 🆕 NOT IN FAB |
| 60 | 8.0 | ABC / nbdog.com | HK | 🆕 NOT IN FAB |
| 61 | 8.0 | FUHWA SENIOR HIGH SCHOOL | TW | 🆕 NOT IN FAB |
| 62 | 7.8 | DADA #2 / 10 .xyz domains | DADA operator | Delete ROLLED BACK |
| 63 | 7.7 | CTDU | CN | 🆕 NOT IN FAB |
| 64 | 7.7 | BETRC / nctu.edu.tw | TW | 🆕 NOT IN FAB |
| 65 | 7.6 | KKIZZKIFA | HK Cluster | 🆕 NOT IN FAB |
| 66 | 7.2 | GALAXY CLUB / 5t.tf | HK Cluster | 🆕 NOT IN FAB |
| 67 | 7.0 | BCOZJOJ | HK Cluster | 🆕 NOT IN FAB |
| 68 | 6.7 | 渡梦 / office365a1.vip | Aug 2018 Ring | Delete sched 4×, never exec |
| 69 | 4.2 | AGASYSTEMS.COM | Individual | 🆕 NOT IN FAB |
| 70 | 3.1 | COLEGIO 4 DE JULHO | Individual | 🆕 NOT IN FAB |

### Totals by Tier

| Tier | Tenants | Storage TB | % of Total Fraud |
|------|---------|-----------|-----------------|
| S (>100 TB) | 7 | 4,404 | 76.5% |
| A (20-99 TB) | 26 | 1,413 | 24.5% |
| B (5-19 TB) | 39 | 442 | 7.7% |
| **Total** | **72** | **~5,760 TB** | |

> **Implication:** 76% of all confirmed fraud storage is in just 7 tenants. Remediating the top 7 would reclaim 4.4 PB.

---

## 14. Updated Running Totals

| Metric | Value | % of 245.7 PB |
|--------|-------|-------------|
| Total EDU ODB storage baseline | **245.7 PB** | 100% |
| | | |
| **Total Confirmed Fraud Storage** | **~5.76 PB** | **2.3%** |
| ├─ Identified + successfully remediated (blocked/readonly) | ~1.49 PB | 0.6% |
| ├─ Identified + action failed/rolled back | ~1.12 PB | 0.5% |
| ├─ Identified + delete scheduled, never executed | ~1.20 PB | 0.5% |
| ├─ Identified + NO action taken (2-3+ years) | ~1.36 PB | 0.6% |
| └─ **NOT identified (not in FAB)** | **~1.31 PB (27 tenants)** | **0.5%** |
| | | |
| **Fraud Storage Remediated (block/readonly applied)** | **~1.49 PB** | 0.6% |
| **Fraud Storage Deleted / Reclaimed** | **~0 PB** | **0%** |
| | | |
| Uninvestigated (ORANGE+WATCH tiers) | ~8.1 PB | 3.3% |
| **Grand total fraud + suspected** | **~13.9 PB** | **5.7%** |

### By Ring

| Ring | Members | Storage TB | % of Total Fraud |
|------|---------|-----------|-----------------|
| Spring 2020 Mega-Ring | 19 | ~1,093 | 19.0% |
| TW/CN 365 Network | 7 | ~830 | 14.4% |
| Corporate Buzzword | 4 | ~355 | 6.2% |
| HK Gibberish Cluster | 9 | ~196 | 3.4% |
| VN School Network | 8+ | ~400 | 6.9% |
| Aug 2018 CN Ring | 3 | ~23 | 0.4% |
| Cross-Region CN Operators | 6 | ~45 | 0.8% |
| Indonesian Cluster | 3+ | ~80 | 1.4% |
| **Individual/Unaffiliated** | 13 | ~2,738 | 47.5% |

### By FAB Status

| Status | Tenants | Storage TB | Note |
|--------|---------|-----------|------|
| 🆕 NOT IN FAB | 27 | ~1,310 | **Completely invisible** |
| ⚠️ Identified, NO action | 10+ | ~1,360 | Some waiting 3+ years |
| ⚠️ Delete scheduled, never exec | 8+ | ~1,200 | Up to 4× scheduled |
| ❌ Delete rolled back | 8+ | ~1,120 | Storage never freed |
| ❌ Delete/block FAIL | 4+ | ~180 | Stuck in failed state |
| ✅ Blocked/ReadOnly | 15+ | ~590 | Remediated but storage not freed |

---

---

## 16. Phase 4: Deep Vector Sweeps & Ring Expansion

*Phase 4 executed all recommended investigation vectors from Phase 3, using D2K operator fingerprinting, dormant storage analysis, and high-site-count anomaly detection to identify new fraud tenants and expand existing rings.*

### 16.1 D2K Operator Fingerprinting — Ring Intelligence

#### Corporate Buzzword Ring — Full Operator Map (Nov 25, 2018)

All 4 members created within **5 hours** on the same day, ALL with `a1p.me` sub-domains (shared reselling platform), ALL different Gmail accounts and US phone numbers from different states:

| Tenant | TB | Email | Phone (Area) | a1p.me | Domains | Creation Time |
|--------|-----|-------|-------------|--------|---------|---------------|
| STRATEGIZE VALUE-ADDED PARADIGMS | 178 | `Dudam@gmail.com` | `3606296370` (WA) | `b798.a1p.me` | `365proplus.site` | 14:38 |
| ORCHESTRATE CUTTING-EDGE | 101 | `Cartwrighto@gmail.com` | `4068615660` (MT) | `gizn.a1p.me` | `x365mail.com` | 14:50 |
| MORPH B2B PARTNERSHIPS | 62 | `FORKNSPOONSTORY@gmail.com` | `6109122822` (PA) | — | `cloudmicrosoft.in` | 09:39 |
| EXPLOIT SCALABLE INTERFACES | 10.5 | `Imel8@gmail.com` | `3366652996` (NC) | `jf8b.a1p.me` | — | 14:23 |

**Key signals:** `a1p.me` sub-domains indicate a shared EDU license reselling infrastructure. All use burner Gmail+phone combos. MORPH B2B has tag `edu=DECLINED` yet still has active EDU tenant! STRATEGIZE has `365proplus.site`, ORCHESTRATE has `x365mail.com` — both brand impersonation domains. EXPLOIT has `isdeletable=false` tag — protected from deletion.

**Potential 5th member: RUDY MOORE SCHOOL** (245 TB) — Tukwila, WA. Phone `425-944-5525` (WA). STRATEGIZE also has WA phone. Domain `Moscow.fyi`. Created March 2020 (later wave, same operator?). `edu=approved`.

#### HK Gibberish Ring — Confirmed Single Operator via Email Pattern

**Discovery: Gibberish@[prefix]microsoft.com email pattern** — the operator uses gibberish strings at domains that mimic `microsoft.com`:

| Tenant | TB | Email | Domain Pattern | Created |
|--------|-----|-------|---------------|---------|
| KKIZZKIFA | 7.6 | `cxoybulsc@revckmicrosoft.com` | `x9p.onmicrosoft.com` | Jul 25, 2019 |
| BCOZJOJ | 7.0 | `xlgzrhz@fnvmicrosoft.com` | `bng26.onmicrosoft.com` | Aug 3, 2019 |

Both emails follow `[random]@[random]microsoft.com` — the "microsoft.com" suffix is deliberate social engineering.

**HC1** — `s621704621704@gmail.com`. Address: **Room 706, 7/F Centennial Campus** — this is the **University of Hong Kong campus building**. Domains: `qqliuxing2/qqliuxingedu.onmicrosoft.com` (QQ流星 = QQ Meteor). `edu=approved` + `azure=active`.

**Galaxy Club** — City: **佛山 (Foshan)**, Address: 佛山市南海区大沥镇 (Nanhai District). Domains: `galaxys.club`, `5t.tf`. Phone: `18603099543` (Chinese mobile). Email: `lqhorochi@gmail.com`. Created Feb 2019. **NOT `edu=approved`** — no edu tag at all, snuck through without verification.

**QLB** — Created **Aug 14, 2018** (earlier wave). Storage actually **88.5 TB** (not ~10 TB as previously estimated from Kusto alone — OMS confirms 90,656 GB). In FAB since Sep 2022 — **NO ACTION in 3.5 years**.

**RMUYNDTB** — Created **Oct 6, 2021** (later wave). 52 TB. Only 500 licenses, 175 ODB sites.

**HK Ring timeline spans 3 waves:** Aug 2018 → Feb-Aug 2019 → Oct 2021.

#### Spring 2020 Mega-Ring — Brand Impersonation Domain Registry

Every member uses domains impersonating Microsoft/Office 365:

| Tenant | TB | Brand Domain | Other Domain | Created | D2K Tags |
|--------|-----|-------------|-------------|---------|----------|
| RUDY MOORE SCHOOL | 245 | `rudymooreschool.online` | `Moscow.fyi` | Mar 20, 2020 | `edu=approved` |
| WKTSCHOOLO | 86 | `office365store.top` | — | May 18, 2020 | — |
| MICROSOFT 365 (upliftschool) | 77 | — | `m365.top` | Sep 15, 2015* | `DELETE_FAIL` → `ROLLBACK_FAIL` |
| LSXSCHOOLO | 47 | `office365net.com` | — | May 18, 2020 | — |
| MICROSOFT CO. | 43 | (custom) | — | May 19, 2020 | Sisters, OR |
| DADA#1 | 40 | `offices365.co` | — | Apr 29, 2020 | CN |
| THZXG.YWMNE | 39 | `365site.top` | `ioffice.cool` | May 19, 2020 | `azure=active` |
| CHARLES INC. | 36 | `office365.uno` | — | May 9, 2020 | — |
| FOSSCHOOLS | 22 | `ms365officenw.xyz` | — | May 18, 2020 | `noDeletionBy=VL`, `azure=active` |

**Key D2K finding:** MICROSOFT 365 (5765f1fe / 365i.team / 605 TB) has: onmicrosoft = `cathedralschoolilorg` (Cathedral School IL impersonation), email: `admin@mammttc.org`, **Youngstown, OH**. Tag: **`noDeletionBy=VL`** — protected from volume license deletion!

FOSSCHOOLS and THZXG.YWMNE also have **`azure=active`** — actively using Azure resources.

### 16.2 New Confirmed Fraud Tenants (Phase 4 Discoveries)

#### University Impersonation Cluster

| TenantID | Name | Country | TB | Domain | Signal | FAB Status |
|----------|------|---------|-----|--------|--------|------------|
| `93bf3492` | **TOKYOUO** | JP/Tokyo | 20 | `tokyouo.onmicrosoft.com` | Impersonates U of Tokyo. Email `yutocy@icu.jp` (using ICU email!). 8 ODB sites, 2.5 TB/site. 57× READONLY_FAIL before block. | Blocked Jan 2026 |
| `eb4d7c9a` | **PORTLAND COMMUNITY COLLEGE** | US | 25 | `iuns.net`, `byxclass.com` | Impersonates PCC. Email **`jessica.frisina@pcc.edu`** (real PCC email!). Phone `9374393544` (OH, not OR). `edu=approved`. | **NOT IN FAB** |
| `f4870120` | **'STUDIUMUNIHAMBURGDE'** | DE/Hamburg | 25.5 | `studiumunihamburgde.onmicrosoft.com` | Impersonates Uni Hamburg Studium portal. "Deactivated on 19.01.2021" in name. | Blocked Apr 2026 |
| `e4f9123c` | **MICROSOFT 365** (Jeddah) | SA/Jeddah | 25 | `moedogorg.onmicrosoft.com` | 0 licenses, FREE tier with 25 TB! Brand impersonation. | Blocked Oct 2023 |
| `6ce83f62` | **MICROSOFT 365** (upliftschool) | US/Gallup NM | 77 | `upliftschool.onmicrosoft.com` | Delete FAIL → ROLLBACK_FAIL. Domain `m365.top` (brand!). 9,633 sites ALL dead. | Delete failed Jul 2023 |

#### Non-EDU Entities with EDU Classification

| TenantID | Name | Country | TB | Domain | Signal | FAB Status |
|----------|------|---------|-----|--------|--------|------------|
| `9dff67f5` | **M2 CONSULTORÍA ESPECIALIZADA** | PE/Lima | 20.5 | `m2.pe`, `barr.pe`, `law.barr.pe`, `risottolegal.com` | **Law firm** with EDU! NYC phone `+12124614872`. `edu=approved`. 3.2M lic/13 users. | In FAB (heavy retries) |
| `73e65d9c` | **ACADEMYCONSULTINGGROUP.COM** | US | 26 | `academyconsultinggroup.com` | Consulting firm with EDU, 12,614 ODB sites, 103K licenses. Storage reselling. | Needs check |

#### VN School Network Expansion (+3 members)

| TenantID | Name | TB | Domain | City | Signal | FAB Status |
|----------|------|-----|--------|------|--------|------------|
| `5821f78b` | **MINHHIEN.EDU.VN** | 31 | `minhhien.edu.vn` + 45 others! | Thủ Đức/HCM | **46 domains** incl. `forproxy.net`, `hungvuonghotel.vn`, `photo360.vn` — domain reseller | ReadOnly (rollback→reapply) |
| `303d04f6` | **CN UNIVERSITY** | 26 | `cnu.edu.vn` | Gò Vấp/HCM | 4M lic/2,282 enabled. 30+ BLOCK_FAIL before success. | Blocked Jan 2026 |
| `10f4e3b4` | **TRUNG HỌC CƠ SỞ XUÂN PHƯƠNG** | 76.5 | `quynhchi.online` | N/A | 1,000 lic/47 enabled. 1.6 TB/site. | Needs check |

VN School Network now totals **10+ members** with combined storage >700 TB.

#### TW/CN 365 Network Expansion (+1 member)

| TenantID | Name | TB | Domain | City | Signal |
|----------|------|-----|--------|------|--------|
| `161d5c41` | **OFFICE 365** | 30 | **`officems365.live`** | Taoyuan, TW | Brand impersonation domain combining "Office" + "MS365" |

TW/CN 365 Network now totals **8 members** — combined >1,050 TB.

### 16.3 EDU Verification Abuse — Systematic Pattern

D2K reveals a devastating EDU verification bypass pattern:

| Tenant | Method | Verification Email Used | Real Institution |
|--------|--------|------------------------|-----------------|
| PORTLAND CC | Support request + real employee email | `jessica.frisina@pcc.edu` | Portland Community College |
| TOKYOUO | Support request + real university email | `yutocy@icu.jp` | International Christian University |
| 太仓市 elementary | Support request + EDU domain | `cue@live.cn` | N/A (Mooncake) |
| M2 CONSULTORÍA | Support request approval | `amirandaguillen@m2.pe` | N/A (law firm self-verified) |
| MORPH B2B | Support request despite `edu=DECLINED` | `FORKNSPOONSTORY@gmail.com` | None — declined but still active! |
| KKIZZKIFA | Direct approval | `cxoybulsc@revckmicrosoft.com` | None — fake microsoft.com email |

**EDU verification process is systematically being exploited** — real institution emails are being used to verify fraudulent tenants, and even `edu=DECLINED` tenants remain active.

### 16.4 Remediation Pipeline Failures — Extreme Cases

| Tenant | Failed Action | Retry Count | Duration | Storage (TB) |
|--------|--------------|-------------|----------|-------------|
| TOKYOUO | READONLY_FAIL | **57×** | Jan 13-20, 2026 (7 days) | 20 |
| CN UNIVERSITY | BLOCK_FAIL | **30+×** | Jan 9-20, 2026 (11 days) | 26 |
| M2 CONSULTORÍA | Multiple actions | **24KB of timeline** (hundreds of retries) | Months | 20 |
| MICROSOFT 365 (upliftschool) | DELETE_FAIL → DELETE_ROLLBACK_FAIL | N/A | Stuck since Jul 2023 | 77 |
| QLB | No action at all | 0 | **3.5 years since identification** | 88 |

### 16.5 Updated Ring Summary

| Ring | Members | Storage (TB) | Key Operator Signal | Status |
|------|---------|-------------|---------------------|--------|
| **Spring 2020 Mega-Ring** | 19+ | ~1,400+ | Brand domains (office365*.top/com/uno), SCHOOLO pattern, `noDeletionBy=VL` | Mixed — some blocked, some deletion-protected |
| **TW/CN 365 Network** | 8 | ~1,050 | "Microsoft 365"/"Office 365" name, `365i.team`, `officems365.live` | Delete scheduled, never exec |
| **VN School Hijacking** | 10+ | ~700+ | Vietnamese .edu.vn domains, domain reselling (46+ domains on one tenant) | Mixed — some blocked, some not in FAB |
| **Corporate Buzzword** | 4-5 | ~600 | `a1p.me` sub-domains, `365proplus.site`, `x365mail.com`, burner Gmail/phone | Identified — some NO ACTION 3+ years |
| **HK Gibberish** | 9+ | ~320+ | `[gibberish]@[prefix]microsoft.com` emails, HK registration, 3 waves (2018-2021) | Mixed — QLB NO ACTION 3.5 years |
| **DADA Operator** | 2 | ~48 | `offices365.co`, `.xyz` domains | Spring 2020 overlap |
| **Aug 2018 CN "A1 VIP"** | 3 | ~23 | `.vip`/`.xyz` domains | Delete scheduled 4× never exec |
| **University Impersonation** | 5+ | ~173 | Real institution names + fake domains + real employee emails for verification | Mixed |
| **Canadian Impersonation** | 2 | ~18 | `.ca` domains (mywishschool, brightoncollege) | Needs check |

### 16.6 Updated Net-New NOT IN FAB Registry (28 tenants, ~1.34 PB)

```
# Phase 1 (10 tenants)
5704f9de  # VIEN DAO TAO QUOC TE (98.3 TB) - VN
9c25d6d6  # COLEGIO PADRE DEHON (75.0 TB) - ES
83d334bb  # GEMEINSCHAFTSSCHULE AM URBACH (46.3 TB) - DE
8e673338  # NANJING NO. 1 (37.8 TB) - CN
a5aefaa1  # HIMAWARIGAKUEN (35.0 TB) - JP [verify]
abc3dbf4  # 부산대저고등학교 (23.0 TB) - KR [verify]
f2a506d3  # THPT THUY HUONG (20.8 TB) - VN
f37a2a2d  # 宁夏大学 (17.9 TB) - CN
0c8c91d7  # AGASYSTEMS.COM (4.2 TB) - FR
6d52c02b  # COLEGIO 4 DE JULHO (3.1 TB) - BR

# Phase 2 (16 tenants)
ecc65b32  # MAXEY ACADEMY (13.2 TB) - US
3d59a7f0  # TAN PHU HIGH SHOOL (12.7 TB) - VN
a4188e70  # SMAN 1 RAJAGALUH (11.5 TB) - ID
ae901ed4  # PKT (13.9 TB) - MY
97c5b8e1  # HC1 (10.0 TB) - HK
7bde4c43  # WEB.NPU.EDU.RS (9.4 TB) - RS/CN
f4653fce  # XENX (9.1 TB) - CN
b37b5366  # 真理大学 (9.0 TB) - NZ/CN
88e42071  # ARMY (8.5 TB) - HK/US
c268940c  # ABC (8.0 TB) - HK
f355f460  # FUHWA SENIOR HIGH SCHOOL (8.0 TB) - TW
73350d3b  # CTDU (7.7 TB) - CN
6c467812  # BETRC (7.7 TB) - TW
728d6e13  # KKIZZKIFA (7.6 TB) - HK
4bc0aaa5  # BCOZJOJ (7.0 TB) - HK
2e14be42  # GALAXY CLUB (7.2 TB) - HK

# Phase 3 (1 tenant)
1b9b0418  # 太仓市璜泾镇鹿河小学 (800 TB!) - CN

# Phase 4 (1 tenant)
eb4d7c9a  # PORTLAND COMMUNITY COLLEGE (25 TB) - US, impersonation via iuns.net, edu=approved via real PCC email
```

---

## 17. Updated Running Totals (Post-Phase 4)

| Metric | Value | % of EDU ODB |
|--------|-------|-------------|
| Total EDU ODB storage baseline | **245.7 PB** | 100% |
| | | |
| **Total Fraud Storage (confirmed)** | **~6.36 PB** | **2.6%** |
| ├─ Fraud identified + acted on (blocked/readonly) | ~1.85 PB | 0.75% |
| ├─ Fraud identified + action failed/rolled back | ~1.25 PB | 0.5% |
| ├─ Fraud identified + delete scheduled, never executed | ~1.20 PB | 0.5% |
| ├─ Fraud identified + NO action taken (years) | ~1.40 PB | 0.6% |
| └─ **Fraud NOT identified (not in FAB)** | **~1.34 PB** | **0.5%** |
| | | |
| **Total Fraud Storage Deleted (Reclaimed)** | **~0 PB** | **0%** |
| | | |
| Suspected fraud (uninvestigated tiers) | ~8.1 PB | 3.3% |
| **Grand total fraud + suspected** | **~14.5 PB** | **5.9%** |

**Phase 4 additions:**
- **+600 TB** confirmed fraud from updated storage figures (QLB 88 TB, XUÂN PHƯƠNG 76 TB, ADVG 61 TB, upliftschool 77 TB, RMUYNDTB 52 TB, etc.)
- **+7 new confirmed fraud tenants** (PORTLAND CC, TOKYOUO, M2 CONSULTORÍA, STUDIUMUNIHAMBURGDE, MICROSOFT 365/Jeddah, OFFICE 365/Taoyuan, ACADEMYCONSULTINGGROUP)
- **+1 NOT IN FAB tenant** (PORTLAND CC, 25 TB)
- Total investigated tenants: **~85** (up from 72)

---

## 18. Phase 4b: False Positive Validation & Continued Expansion

### 18.1 False Positive Review (Non-English Tenants)

**FP validation is critical** — many high-storage non-English tenants have names that look unusual to English speakers but are legitimate institutions. Each tenant below was cross-referenced against D2K registration data, institutional existence, domain ownership, and storage patterns.

#### ✅ RECLASSIFIED AS LIKELY LEGITIMATE:

| TenantID | Name | TB | Country | Evidence for Legitimacy |
|----------|------|-----|---------|------------------------|
| `8e673338` | **Nanjing No. 1** | 37.8 | CN | 南京市第一中学 — prestigious 100+ year school. **Migrated by Microsoft's own EDU team** (2013). Tags: `migratedbyedu=true`, `EduChinaMigration=true`. Real address: 中山南路301号, Nanjing. |

> **Lesson:** Chinese schools migrated in 2013 by Microsoft's EDU program should be treated as high-confidence legitimate. Storage may be excessive but is Microsoft's responsibility from the migration.

#### ⚠️ SUSPECTED BUT NEEDS FURTHER REVIEW:

| TenantID | Name | TB | Country | Mixed Signals |
|----------|------|-----|---------|---------------|
| `3a4b14f2` | **南京大学** (Nanjing University) | 17.9 (41 TB total incl. SPO) | CN | Real email `kylehao@amps.nju.edu.cn` + real campus address. BUT also has `edu6.444.info` and `free6.cloud.eu.org` domains — NOT university domains. Likely a **compromised legitimate lab** rather than pure fraud. AMPS is a real NJU department. |
| `83d334bb` | **Gemeinschaftsschule "Am Urbach"** | 46.3 | DE | Real German school, real domain `tgs-am-urbach.de`, real address in Erfurt. BUT 46 TB for a ~300-student school is wildly disproportionate. Possible **admin account compromise** rather than intentional fraud by the school. |
| `f37a2a2d` | **宁夏大学** (Ningxia University) | 17.9 | CN | Real university address (贺兰山西路489号, Yinchuan). BUT gibberish onmicrosoft handle `aegfwacnz3`, admin email `neko@` on onmicrosoft, no custom domain, only 11 ODB sites. Could be impersonation using university's public address. |

#### ❌ CONFIRMED AS FRAUD (despite legitimate-sounding names):

| TenantID | Name | TB | Country | Why It's Fraud |
|----------|------|-----|---------|---------------|
| `d01ccb13` | **National Hsin-Feng SHS** | 24.3 | TW | Real school address BUT HK email (`lzr@live.hk`), random domains `su.tn`, `xianyur.me`, `1280720.xyz` |
| `93bf3492` | **TOKYOUO** | 20 | JP | Impersonates U of Tokyo. Uses ICU email `yutocy@icu.jp` (wrong university!). edu=approved. |
| `f4870120` | **STUDIUMUNIHAMBURGDE** | 25.5 | DE | Impersonates Uni Hamburg. "Deactivated" in own name. onmicrosoft only. |
| `eb4d7c9a` | **PORTLAND COMMUNITY COLLEGE** | 25 | US | Uses real PCC employee email but domains are `iuns.net`, `byxclass.com`. OH phone for OR school. |
| `a2d99095` | **SHANSHOU EDUCATION** | 20.5 | KR | Claims education in rural Gangwon-do. `root@stubest.onmicrosoft.com`. 3M lic / 37 enabled. No real institution match. |
| `e1cf944e` | **ABC.MIT.AC.NZ** | 18.2 | NZ | Impersonates MIT-affiliated NZ institution. FAB domain is `5t.ac.cn` (Chinese!). Delete rolled back. |

### 18.2 Spring 2020 Ring — Extended Domain Catalog

Full brand impersonation domains discovered across the ring (now 22+ members):

| Domain | Tenant | Brand Target |
|--------|--------|-------------|
| `office365store.top` | WKTSCHOOLO | Microsoft Office 365 |
| `office365net.com` | LSXSCHOOLO | Microsoft Office 365 |
| `office365.uno` | CHARLES INC. | Microsoft Office 365 |
| `offices365.co` | DADA#1 | Microsoft Office 365 |
| `office365std.com` | TEPJP | Microsoft Office 365 |
| `officeid.co` | M365 APPS FOR ENTERPRISE | Microsoft Office |
| `officems365.live` | OFFICE 365 (TW) | Microsoft Office + M365 |
| `office2021.co` | GHEUGE | Microsoft Office 2021 |
| `0ffice.tw` | 陡陌星雲 | Microsoft Office (zero=O trick) |
| `o365th.com` | DONNA INC. | Office 365 Thailand |
| `365proplus.site` | STRATEGIZE | Microsoft 365 ProPlus |
| `365site.top` | THZXG.YWMNE | Microsoft 365 |
| `365i.team` | MICROSOFT 365 (605 TB) | Microsoft 365 |
| `m365.top` | MICROSOFT 365 (upliftschool) | Microsoft 365 |
| `ms365officenw.xyz` | FOSSCHOOLS | Microsoft 365 Office |
| `x365mail.com` | ORCHESTRATE | Microsoft 365 mail |
| `ioffice.cool` | THZXG.YWMNE | Microsoft iOffice |
| `c2024.live` | UQVSCHOOLO | Generic |
| `email-co.id` | M365 APPS FOR ENTERPRISE | Indonesia email |
| `asso.me` | GOSPEL RESCUE | Generic |
| `lmx365.com` | LMX | Microsoft 365 |

Also notable non-brand domains used for cross-service impersonation:
- `jakartabehaviorcenter.com` — Indonesian service on M365 APPS FOR ENTERPRISE  
- `macmanagements.com`, `srisaimoon.com` — Thai/Indonesian on TEPJP
- `jyzx.bsziegelbruecke.ch` — **Swiss school domain** hijacked for Chinese tenant LMX

### 18.3 Additional Confirmed Fraud (Phase 4b)

| TenantID | Name | TB | Domain | Country | Ring | FAB Status |
|----------|------|-----|--------|---------|------|------------|
| `e5b07230` | **M365 APPS FOR ENTERPRISE** | 29 | `officeid.co`, `email-co.id`, `jakartabehaviorcenter.com` | US (ID operator) | Spring 2020 | Blocked Jun 2023 |
| `ae66e8e3` | **DONNA INC.** | 21 | `o365th.com` | US | Spring 2020 | Identified Nov 2022 → **delete scheduled, NEVER EXECUTED** |
| `35704715` | **GHEUGE** | 21 | `office2021.co` | TW | TW/CN 365 | ReadOnly Aug 2023 |
| `d9256a0f` | **TEPJP** | 21 | `office365std.com`, `srisaimoon.com` | US | Spring 2020 | ReadOnly Aug 2023 |
| `4939e742` | **LMX** | 24 | `bsziegelbruecke.ch` (Swiss hijack!), `lmx365.com` | CN/Guangxi | Cross-region | Delete ROLLED BACK |
| `7c943324` | **GOSPEL RESCUE MISSIONS** | 34 | `asso.me` | US | Spring 2020 | Delete ROLLED BACK |
| `d5dfe8c8` | **陡陌星雲** | 22 | `0ffice.tw` (zero!) | CN/Beijing | TW/CN 365 | Delete sched, **NEVER EXECUTED** (2+ years!) |
| `e1cf944e` | **ABC.MIT.AC.NZ** | 18 | `5t.ac.cn` | NZ/CN | Cross-region | Delete ROLLED BACK |
| `a2d99095` | **SHANSHOU EDUCATION** | 20 | `stubest.onmicrosoft.com` | KR | Individual | **NOT IN FAB** |
| `2ef93084` | **NAM HA** | 17 | custom | VN/HCM | VN School | **NOT IN FAB** |

### 18.4 Phase 4b Batch 2: 5-15 TB Systematic Investigation

Investigated 30 tenants from the Kusto 200-row result set (5-15 TB, <=3 active, >70% inactive).

#### Confirmed Fraud (Batch 2)

| TenantID | Name | TB | Domain | Country | Ring / Pattern | FAB Status |
|----------|------|-----|--------|---------|---------------|------------|
| `d4836470` | **CU EDUCATION** | 14.4 | `hk.autigers.org`, `cu.go.edu.rs`, `javb.us`, `yifanzhang.cn` | VN (city: SJZ=Shijiazhuang CN!) | **5-country domain spread** — VN reg, CN city, Serbian .edu email (`yzz0090@cu.go.edu.rs`), US domains | **NOT IN FAB** |
| `12bf9a59` | **SALT LAKE CC** | 13.9 | `esri3d.com` | US/UT | **EDU verification abuse** — used real SLCC student email `mspitler@bruinmail.slcc.edu` + real campus address. Domain `esri3d.com` unrelated to SLCC. | **NOT IN FAB** |
| `9214c516` | **TECHGURU** | 13.8 | `mywishschool.ca`, `mylittlewishdaycare.com` | CA/Toronto | **Canadian EDU abuse** — daycare/tech company. Email `irfan.aziz@tech-guru.ca`. Condo address in North York. 3M lic/12 enabled. | In FAB, **NO ACTION** (only "Identified" Feb 2023) |
| `f09cef10` | **IELTS KEY** | 12.7 | `keyietls.edu.vn` (typo: "ietls" not "ielts") | VN/HCM | **VN School Network** — IELTS prep center with 12.7 TB. Domain has typo. | **NOT IN FAB** |
| `642c7a99` | **DGSTU** | 11.5 | `brightoncollege.ca`, `stunet.xyz`, `jamintextiles.com` | CN (lang: zh-CHS) | **CN student-run fraud** — Email `201941313237@dgut.edu.cn` (real DGUT student!). Phone 4251001000 (Redmond area!). `azure=active`. | In FAB, **delete scheduled TWICE, NEVER EXECUTED** |
| `5e2d744b` | **ZMZSCHOOLO.ZMZSCHOOLO** | 11.3 | `b2026.live` (rotated from `o365e.live`) | US | **Spring 2020 SCHOOLO** — Known sub-ring member. May 18 2020 creation burst. | In FAB |
| `95519262` | **NIMTE** | 10.8 | `t.365web.org`, `a1.vssnumber.eu.org` | US (city: Achille OK) | **Brand-adjacent domain** — `365web.org`. Email `tonyli1222@live.com`. Phone 802 (Vermont!) but address is Oklahoma. Impersonates NIMTE (Chinese Academy of Sciences institute). | In FAB, identified Aug 2024, **NO ACTION 8 months** |
| `9cd29faa` | **FOX VALLEY TC** | 10.3 | `cc.bnoo.me` | US/WI | **EDU verification abuse** — used real FVTC student email `500170477@fvtc.edu` + real campus address (1825 N. Bluemound Drive, Appleton). Domain `bnoo.me` is fake. | **NOT IN FAB** |
| `4b75c738` | **安徽建筑大学** (Anhui Jianzhu University) | 9.8 | `algfwacnz4.onmicrosoft.com` ONLY | CN/Hefei | **Sequential Gibberish Ring** — `algfwacnz4` matches `aegfwacnz3` (宁夏大学). Pattern: `a[X]gfwacnz[DIGIT]`. Email `admin@aj.com`. Street = university name as address. | **NOT IN FAB** |
| `1bc02abc` | **ZAOB** | 9.7 | `zaob.onmicrosoft.com` | SG | **Individual** — 4-char gibberish, E5 Developer subscription, 500 lic/5 enabled, 2 TB/site. | **NOT IN FAB** |
| `c6ab044f` | **海外部** ("Overseas Department") | 9.2 | `5tdk.onmicrosoft.com` | HK | **HK Gibberish Cluster** — Aug 2019 wave. Short gibberish onmicrosoft. 10K lic/4 enabled. | **NOT IN FAB** |

#### Legitimate (Batch 2)

| TenantID | Name | TB | Country | Evidence |
|----------|------|-----|---------|---------|
| `4ca571b3` | **Bracknell & Wokingham College** | 12.3 | GB | Real UK college (now Activate Learning). Created 2013. 5333 legacy ODB sites from student body. 1.5M lic/2 enabled = abandoned/migrated tenant. |
| `2c004d10` | **City of Glasgow College** | 9.7 | GB/Scotland | Real large Scottish college (~25K students). 23K ODB sites, 103K enabled users. Created Jan 2013. Proportionate usage. |
| `3392b46a` | **Lahden Ammattikorkeakoulu** | 10.7 | FI | Known legitimate Finnish university (LAB University of Applied Sciences). 6173 ODB sites, 1032 enabled. |

#### Suspected (Batch 2)

| TenantID | Name | TB | Country | Notes |
|----------|------|-----|---------|-------|
| `dbf387e3` | **GSU** | 12.7 | VN/Lạng Sơn | Domain `gsu.vn` but onmicrosoft `msvne` (mismatch). Email `letronghieu@gsu.vn`. 2M lic/411 enabled. Could be legitimate small school but pattern is suspicious. **NOT IN FAB.** |
| `e096dcba` | **MTES.NTPC.EDU.TW** | 10.7 | TW | Domain `365.mtes.ntpc.edu.tw` — real New Taipei City Education Bureau hierarchy. FP candidate but 10.7 TB for a single school is high. |

### 18.5 Phase 4b Batch 3: Ring Expansion & Cross-Region Discovery

#### NEW RING: GPN Ring (Tokyo, `winozyme.com` operator)

| TenantID | Name | TB | Created | Email | Address | Tags |
|----------|------|-----|---------|-------|---------|------|
| `fc8147ef` | **GPNPH** | 9.6 | Jun 26, 2021 | `gpnph@winozyme.com` | 1-chōme-14-9 Kamiyōga, Setagaya City, Tokyo | `azure=active` |
| `be439aee` | **GPNPS** | 9.9 | Jun 29, 2021 | `gpnps@winozyme.com` | 6-chōme-20-7 Ikegami, Ota City, Tokyo | `azure=active` |

- Both onmicrosoft-only, identical structure (1010 lic, ~250 enabled, ~220 ODB sites)
- Same `@winozyme.com` operator domain
- Different Tokyo addresses but created 3 days apart
- Both **`azure=active`** — using Azure compute!
- **BOTH NOT IN FAB!** Combined: ~19.5 TB

#### Xiamen Operator Cluster (NEW — connects HK Gibberish to CN cross-region)

| TenantID | Name | TB | Domain | Country | Signal | FAB |
|----------|------|-----|--------|---------|--------|-----|
| `1ec86719` | **XQFKIBHWED** | 13.2 | `0592.tk`, `bscf.cf`, `jg2j.onmicrosoft.com` | HK/Kowloon | Email: `bllsmrve@ashmicrosoft.com` (**fake Microsoft!**). `0592` = **Xiamen area code**. `azure=active`. HK Gibberish Aug 2019 wave. | **NOT IN FAB** |
| `7456ee9c` | **KAZAMI TECH** | 9.5 | `tripolskola.cz`, `kazami.eu`, `asoulfan.com` | CN/Xiamen | Email: `oldking139@foxmail.com`. Address: 福建省厦门市思明区. Phone: CN mobile. **Czech school domain hijack!** `azure=active`. | **NOT IN FAB** |

**Connection:** Both operators are in Xiamen (XQFKIBHWED's `0592.tk` domain = Xiamen area code, KAZAMI TECH's address = Xiamen). The Xiamen operator runs HK gibberish tenants AND CN tenants with European school domains. Combined: ~22.7 TB.

#### HK Gibberish Cluster — New Members

| TenantID | Name | TB | Created | Email Pattern | Domain | FAB |
|----------|------|-----|---------|--------------|--------|-----|
| `1ec86719` | **XQFKIBHWED** | 13.2 | Aug 2019 | `bllsmrve@ashmicrosoft.com` | `0592.tk` | NOT IN FAB |
| `79bcce81` | **CIDMRM** | 11.7 | Jul 2019 | (check needed) | `cfuqz.onmicrosoft.com` | **NOT IN FAB** |
| `c6ab044f` | **海外部** | 9.2 | Aug 2019 | (check needed) | `5tdk.onmicrosoft.com` | **NOT IN FAB** |

**Updated HK Gibberish email pattern variants:** `@revckmicrosoft.com` (KKIZZKIFA), `@ashmicrosoft.com` (XQFKIBHWED). Pattern: `[gibberish]@[prefix]microsoft.com`.

HK Gibberish Cluster now totals **12+ members** across 3 waves (Aug 2018, Jul-Aug 2019, Oct 2021).

#### VN School Network — New Member

| TenantID | Name | TB | Country | Notes | FAB |
|----------|------|-----|---------|-------|-----|
| `9716291a` | **TRƯỜNG THANH XUÂN NAM** | 14.3 | VN/Khánh Hòa | onmicrosoft-only `ttnedu`, 1K lic/28 enabled, 21 sites | **NOT IN FAB** |

VN School Network now totals **13+ members** with combined storage >800+ TB.

#### Sequential Gibberish Ring (NEW — automated CN university impersonation)

| TenantID | Name | TB | Onmicrosoft Handle | Created | FAB |
|----------|------|-----|--------------------|---------|-----|
| `f37a2a2d` | **宁夏大学** (Ningxia University) | 17.9 | `aegfwacnz3` | Aug 2018 | NOT IN FAB |
| `4b75c738` | **安徽建筑大学** (Anhui Jianzhu Univ) | 9.8 | `algfwacnz4` | Aug 2018 | NOT IN FAB |

Pattern: `a[X]gfwacnz[DIGIT]` — sequential numbering indicates **automated tenant creation tooling**. Both impersonate real Chinese universities. Both onmicrosoft-only, `edu=approved`, minimal users. Combined: ~27.7 TB.

#### Cross-Region Domain Hijacking (Expanded)

| Tenant | Domain Hijacked | Origin Country | Domain Country | School Impersonated |
|--------|----------------|----------------|----------------|-------------------|
| **LMX** (24 TB) | `bsziegelbruecke.ch` | CN/Guangxi | Switzerland | Schule Ziegelbrücke |
| **DGSTU** (11.5 TB) | `brightoncollege.ca` | CN (zh-CHS) | Canada | Brighton College |
| **KAZAMI TECH** (9.5 TB) | `tripolskola.cz` | CN/Xiamen | Czech Republic | Tripol škola |
| **ABC.MIT.AC.NZ** (18 TB) | `5t.ac.cn` | NZ registration | China | Chinese academic domain |
| **CU EDUCATION** (14.4 TB) | `cu.go.edu.rs` | VN/CN | Serbia | Serbian university |

**Pattern:** Chinese operators acquire foreign school domains (Swiss, Canadian, Czech, Serbian) to verify EDU status and deploy storage fraud.

#### EDU Verification Abuse — Updated Cases (4 confirmed)

| Tenant | Real Email Used | Real Institution | Domain After Approval |
|--------|----------------|------------------|--------------------|
| PORTLAND CC | `jessica.frisina@pcc.edu` | Portland Community College | `iuns.net`, `byxclass.com` |
| SALT LAKE CC | `mspitler@bruinmail.slcc.edu` | Salt Lake Community College | `esri3d.com` |
| FOX VALLEY TC | `500170477@fvtc.edu` | Fox Valley Technical College | `cc.bnoo.me` |
| TOKYOUO | `yutocy@icu.jp` | International Christian University | onmicrosoft only |

**Attack vector:** Fraudster obtains a real institution's email (student/staff), uses it + real campus address to get `edu=approved`, then adds unrelated domains for actual fraud operations. The real institution may be unaware their email was used.

#### `azure=active` Correlation — Fraud Tenants Using Azure Compute

| TenantID | Name | TB | Country | azure=active |
|----------|------|-----|---------|-------------|
| `1ec86719` | XQFKIBHWED | 13.2 | HK | Yes |
| `7456ee9c` | KAZAMI TECH | 9.5 | CN/Xiamen | Yes |
| `be439aee` | GPNPS | 9.9 | JP/Tokyo | Yes |
| `fc8147ef` | GPNPH | 9.6 | JP/Tokyo | Yes |
| `642c7a99` | DGSTU | 11.5 | CN | Yes |

At least **5 fraud tenants** have active Azure resources, suggesting **secondary abuse of Azure compute** in addition to storage fraud. These tenants have both ODSP storage + Azure compute — dual abuse vector.

### 18.6 Updated NOT IN FAB Registry (56 tenants, ~1.67 PB)

```
# Phase 1 (10 tenants)
5704f9de  # VIEN DAO TAO QUOC TE (98.3 TB) - VN
9c25d6d6  # COLEGIO PADRE DEHON (75.0 TB) - ES
83d334bb  # GEMEINSCHAFTSSCHULE AM URBACH (46.3 TB) - DE [FP-review: may be compromised legit]
8e673338  # NANJING NO. 1 (37.8 TB) - CN [RECLASSIFIED: LIKELY LEGITIMATE - MS EDU migration 2013]
a5aefaa1  # HIMAWARIGAKUEN (35.0 TB) - JP [verify]
abc3dbf4  # 부산대저고등학교 (23.0 TB) - KR [verify]
f2a506d3  # THPT THUY HUONG (20.8 TB) - VN
f37a2a2d  # 宁夏大学 (17.9 TB) - CN [Sequential Gibberish Ring: aegfwacnz3]
0c8c91d7  # AGASYSTEMS.COM (4.2 TB) - FR
6d52c02b  # COLEGIO 4 DE JULHO (3.1 TB) - BR

# Phase 2 (16 tenants)
ecc65b32  # MAXEY ACADEMY (13.2 TB) - US
3d59a7f0  # TAN PHU HIGH SHOOL (12.7 TB) - VN
a4188e70  # SMAN 1 RAJAGALUH (11.5 TB) - ID
ae901ed4  # PKT (13.9 TB) - MY
97c5b8e1  # HC1 (10.0 TB) - HK
7bde4c43  # WEB.NPU.EDU.RS (9.4 TB) - RS/CN
f4653fce  # XENX (9.1 TB) - CN
b37b5366  # 真理大学 (9.0 TB) - NZ/CN
88e42071  # ARMY (8.5 TB) - HK/US
c268940c  # ABC (8.0 TB) - HK
f355f460  # FUHWA SENIOR HIGH SCHOOL (8.0 TB) - TW
73350d3b  # CTDU (7.7 TB) - CN
6c467812  # BETRC (7.7 TB) - TW
728d6e13  # KKIZZKIFA (7.6 TB) - HK
4bc0aaa5  # BCOZJOJ (7.0 TB) - HK
2e14be42  # GALAXY CLUB (7.2 TB) - HK

# Phase 3 (1 tenant)
1b9b0418  # 太仓市璜泾镇鹿河小学 (800 TB!) - CN

# Phase 4a (1 tenant)
eb4d7c9a  # PORTLAND COMMUNITY COLLEGE (25 TB) - US, EDU verification abuse

# Phase 4b (15 tenants)
a2d99095  # SHANSHOU EDUCATION (20 TB) - KR, fake education entity
2ef93084  # NAM HA (17 TB) - VN, VN School Network
d4836470  # CU EDUCATION (14.4 TB) - VN/CN, 5-country domain spread
9716291a  # TRƯỜNG THANH XUÂN NAM (14.3 TB) - VN, onmicrosoft-only
12bf9a59  # SALT LAKE CC (13.9 TB) - US, EDU verification abuse (real slcc.edu email)
1ec86719  # XQFKIBHWED (13.2 TB) - HK, Xiamen operator, @ashmicrosoft.com email
f09cef10  # IELTS KEY (12.7 TB) - VN, typo domain keyietls
79bcce81  # CIDMRM (11.7 TB) - HK, gibberish cluster Jul 2019
9cd29faa  # FOX VALLEY TC (10.3 TB) - US, EDU verification abuse (real fvtc.edu email)
be439aee  # GPNPS (9.9 TB) - JP, GPN Ring @winozyme.com, azure=active
fc8147ef  # GPNPH (9.6 TB) - JP, GPN Ring @winozyme.com, azure=active
4b75c738  # 安徽建筑大学 (9.8 TB) - CN, Sequential Gibberish Ring: algfwacnz4
7456ee9c  # KAZAMI TECH (9.5 TB) - CN/Xiamen, Czech domain hijack, azure=active
1bc02abc  # ZAOB (9.7 TB) - SG, E5 Developer subscription
c6ab044f  # 海外部 (9.2 TB) - HK, gibberish cluster Aug 2019
```

# Phase 4b Batch 3 (11 tenants)
fa338ccd  # XPNPB (8.3 TB) - SG, GPN Ring @winozyme.com, azure=active
0a4a0174  # SHAPC.EDU.VN (8.9 TB) - VN, VN School Network
cf265332  # AILOLI (8.4 TB) - HK, Aug 2018, phone 4250000000 (Redmond!)
c8edeceb  # 阿里世纪教育 (7.2 TB) - HK, mailgoogle8 onmicrosoft, 5 domains
1cddbecf  # ĐAMASÔ NGUYỄN TIẾN LỢI (7.6 TB) - VN, 37.9M lic/3 enabled
3ecb9fc9  # GO, CALIFORNIA USA (6.9 TB) - US, autigers.org ring
06fb4c07  # TRƯỜNG THCS QUẢNG VĂN (6.9 TB) - VN, VN School Network
7f7bd984  # FEPHI.SCH.ID (6.8 TB) - ID, .sch.id domain
41146308  # WU.AC.NZ (6.6 TB) - NZ (city: WASHINGTON!), NZ impersonation
b48efb81  # XRENBLOG (6.5 TB) - CN/JX, Italian domain iclucianimessina.it
ebc18812  # JACKY (6.5 TB) - HK, Aug 2018 wave
2fe58354  # WKFPO (6.4 TB) - HK, gibberish Aug 2019
```

**Phase 4b added 26 NOT IN FAB tenants (~270 TB)**. Total: **56 tenants, ~1.67 PB** undetected by FAB pipeline.

### 18.7 Phase 4b Batch 3: 5-10 TB Tier Systematic Sweep

**Scope:** 40 tenants from Kusto (5-10 TB, ≤2 active sites, >85% inactive 1Y, ≥5 total sites)

#### AUTIGERS.ORG Ring (NEW — Operator "Zhang")

| TenantID | Name | TB | Country | Domains | Email |
|----------|------|-----|---------|---------|-------|
| `3ecb9fc9` | **GO, CALIFORNIA USA** | 6.9 | US | `us.autigers.org`, `apple.autigers.org`, `us.go.edu.rs`, `e.usedu.us`, `zhangyi.fun` | `zhangyf1995@gmail.com` |
| `d4836470` | **CU EDUCATION** | 14.4 | VN/CN | `hk.autigers.org`, `cu.go.edu.rs` | (linked via shared domains) |

**Pattern:** Operator "Zhang" (born ~1995) uses `[country-code].autigers.org` subdomains + `[name].go.edu.rs` subdomains + `usedu.us` subdomain hierarchy. Combined: **~21.3 TB, both NOT IN FAB.**

#### GPN Ring — 3rd Member Confirmed

| TenantID | Name | TB | Country | Email | Tags |
|----------|------|-----|---------|-------|------|
| `fa338ccd` | **XPNPB** | 8.3 | SG | `xpnpb@winozyme.com` | `azure=active` |

GPN Ring now: GPNPH (9.6) + GPNPS (9.9) + XPNPB (8.3) = **~27.8 TB**, all `@winozyme.com`, all `azure=active`. JP+SG geography. **All 3 NOT IN FAB.**

#### Corporate Buzzword Ring — 5th Member Confirmed

| TenantID | Name | TB | Created | Email | Domain | Phone |
|----------|------|-----|---------|-------|--------|-------|
| `90734ebc` | **STREAMLINE COLLABORATIVE E-TAILERS** | 7.3 | Nov 25, 2018 18:33 | `Arnold7@gmail.com` | **`amek.a1p.me`**, `cnzsu.com` | 313-691-6921 (Detroit) |

**All 5 members created Nov 25, 2018**, all different US states, all Gmail accounts, `a1p.me` subdomain platform. In FAB since Mar 2023, no action taken.

#### DADA Operator — 3rd Member

| TenantID | Name | TB | Domains | Email | Tags |
|----------|------|-----|---------|-------|------|
| `07a6feec` | **DADA** | 7.8 | 11× `.xyz` domains: `snchd/stdmf/tieir/tnrgl/trhzd/twxuj/ulcwm/uprhh/uqbzz/utkao` | `dada@aaaa.aaaaaaaa` | Delete **ROLLED BACK** |

**Pattern:** 5-character random `.xyz` domains (e.g., `snchd.xyz`). DADA ring now 3 members, ~56 TB.

#### Brand Impersonation — New Domains

| TenantID | Name | TB | Brand Domain | FAB Status | Key Detail |
|----------|------|-----|-------------|------------|------------|
| `08ecd244` | **渡梦信息技术学院** | 6.7 | **`office365a1.vip`** | Delete scheduled **4×** (May 2023, Feb 2024, Dec 13+14 2024) — **ALL FAILED** | CN name, NC registration, city: FAYETTEVILLE |
| `eb9c0c86` | **MO.AX** (FAB name: **MICROSOFT365**) | 6.5 | **`microsoft365.win`** | Blocked Apr 2023, still has 6.5 TB | HK, 5852 ODB sites |

**`office365a1.vip`** is the most brazen brand impersonation yet — using the exact product tier name "Office 365 A1". Four delete attempts, all failed. 6.7 TB still on disk.

#### Cross-Region Domain Hijacking — New Cases

| TenantID | Name | TB | Country Reg | Domain Hijacked | Real Country |
|----------|------|-----|------------|----------------|-------------|
| `b48efb81` | **XRENBLOG** | 6.5 | CN/JX (city: HONGKONG) | **`iclucianimessina.it`** (Italian personal domain) | Italy |
| `41146308` | **WU.AC.NZ** | 6.6 | NZ (city: WASHINGTON!) | `wuacnz4.onmicrosoft.com` — impersonates NZ `.ac.nz` university format | NZ university |

**XRENBLOG:** Chinese tenant registered in Jiangxi with city listed as "HONGKONG", using an Italian person's domain. 4M licenses, 9 enabled. **NOT IN FAB.**

**WU.AC.NZ:** Registered as New Zealand but city = WASHINGTON. Name mimics NZ academic domain format (`.ac.nz`). Onmicrosoft handle `wuacnz4` = sequential numbering. 208 licenses, 126 enabled. **NOT IN FAB.**

#### HK Gibberish Cluster — 4 New Members

| TenantID | Name | TB | Created | Onmicrosoft | Wave |
|----------|------|-----|---------|-------------|------|
| `cf265332` | **AILOLI** | 8.4 | Aug 2018 | `lolilove.onmicrosoft.com` | Wave 1 (Aug 2018) |
| `ebc18812` | **JACKY** | 6.5 | Aug 17, 2018 | `jacky11.onmicrosoft.com` | Wave 1 (Aug 2018) |
| `2fe58354` | **WKFPO** | 6.4 | Aug 6, 2019 | `0v83i.onmicrosoft.com` | Wave 2 (Aug 2019) |
| `eb9c0c86` | **MO.AX** | 6.5 | Jul 23, 2022 | `seog6124.onmicrosoft.com` | Wave 3+ (2022) |

**AILOLI** has phone number **4250000000** — that's a **Redmond, WA** area code (425) with fake zeros! HK Gibberish cluster now **16+ members**, ~700+ TB.

#### VN School Network — 2 New Members

| TenantID | Name | TB | Domain | Licenses | FAB |
|----------|------|-----|--------|----------|-----|
| `0a4a0174` | **SHAPC.EDU.VN** | 8.9 | `shapc.edu.vn` | 1M/40 | NOT IN FAB |
| `06fb4c07` | **TRƯỜNG THCS QUẢNG VĂN** | 6.9 | `thcsquangvan-pgdbadon.com` | 1K/7 | NOT IN FAB |

VN School Network now **16+ members**, ~850+ TB.

#### Additional Confirmed Fraud

| TenantID | Name | TB | Key Signal | FAB |
|----------|------|-----|-----------|-----|
| `c8edeceb` | **阿里世纪教育** | 7.2 | `mailgoogle8.onmicrosoft.com`, 5 domains (`eggLogics.com`, `ovalogics.com`, `didisales.com`, `genometube.com`), email `hsj@gmail.com` | NOT IN FAB |
| `1cddbecf` | **ĐAMASÔ NGUYỄN TIẾN LỢI** | 7.6 | 37.9M licenses, 3 enabled — most extreme license fraud ratio in dataset | NOT IN FAB |
| `9e333d2e` | **RAKUEN** | 6.9 | NZ registration, CN domain `52diudiu.com`, city "SDA" | NOT IN FAB |
| `8db75651` | **FXY SCHOOL** | 7.7 | HK/Shanghai, `.tk` free domain `fxy1117.tk` | NOT IN FAB |
| `7f7bd984` | **FEPHI.SCH.ID** | 6.8 | Indonesian `.sch.id` domain, 1.5M/37 licenses | NOT IN FAB |

#### Legitimate (2 confirmed)

| TenantID | Name | TB | Evidence |
|----------|------|-----|---------|
| `557b7394` | **St Joseph's College Toowoomba** | 8.3 | Real Australian college, 1503 legacy sites, created 2016 |
| `443205a3` | **Pikes Peak State College** | 8.1 | US/CO, VL=TRUE, Paid, A5, created 2014, `pikespeak.college` domain |

#### FP Review / Suspected

| TenantID | Name | TB | Notes |
|----------|------|-----|-------|
| `2db721fc` | **Shatin Tsung Tsin SS** | 7.3 | Real HK school (verified address/phone/email `sttss@sch.hk`) BUT has `a1.boboliu.dev` domain — possibly compromised legit |
| `b4d56ff8` | **MY.JHEDU.AC.ID** | 8.2 | Indonesian, `my.jhedu.ac.id`, 500K/10 — could be legit Indonesian school |
| `e096dcba` | **MTES.NTPC.EDU.TW** | 10.7 | Taiwan, real `365.mtes.ntpc.edu.tw` hierarchy — FP candidate |

#### Batch 3 Summary

| Category | Count | TB |
|----------|-------|-----|
| Confirmed Fraud | ~20 | ~150 |
| Legitimate | 2 | ~16 |
| FP Review | 3 | ~26 |
| **NOT IN FAB (from batch 3 only)** | **12** | **~88** |
| **New brand domains found** | `office365a1.vip`, `microsoft365.win` | |
| **New cross-region hijacks** | `iclucianimessina.it` (Italian) | |
| **Rings expanded** | GPN→3, Corporate Buzzword→5, DADA→3, HK Gibberish→16+, VN→16+ | |
| **New ring** | AUTIGERS.ORG (Zhang operator, 2 members) | |

---

## 19. Updated Running Totals (Post-Phase 4b — All Batches)

| Metric | Value | % of EDU ODB |
|--------|-------|-------------|
| Total EDU ODB storage baseline | **245.7 PB** | 100% |
| | | |
| **Total Confirmed Fraud Storage** | **~7.20 PB** | **2.9%** |
| ├─ Fraud identified + acted on (blocked/readonly) | ~1.97 PB | 0.8% |
| ├─ Fraud identified + action failed/rolled back | ~1.34 PB | 0.5% |
| ├─ Fraud identified + delete scheduled, never executed | ~1.30 PB | 0.5% |
| ├─ Fraud identified + NO action taken | ~1.48 PB | 0.6% |
| └─ **Fraud NOT identified (not in FAB)** | **~1.67 PB** | **0.7%** |
| | | |
| **Total Fraud Storage Deleted (Reclaimed)** | **~0 PB** | **0%** |
| | | |
| Suspected (under FP review) | ~180 TB | ~0.07% |
| Suspected fraud (uninvestigated tiers) | ~8.0 PB | 3.3% |
| **Grand total fraud + suspected** | **~15.4 PB** | **6.3%** |

**Phase 4b all-batch changes:**
- **+500 TB** from 25+ new confirmed fraud tenants
- **+26 NOT IN FAB** (from 30 to 56, from ~1.40 PB to ~1.67 PB)
- **+3 new rings** (GPN Ring, Sequential Gibberish Ring, AUTIGERS.ORG Ring)
- **+1 new operator cluster** (Xiamen operator)
- **+3 expanded rings** (Corporate Buzzword→5, DADA→3, HK Gibberish→16+)
- **5 tenants with azure=active** (dual abuse vector)
- **4 confirmed EDU verification abuse** cases using real institutional emails
- **6 cross-region domain hijacking** cases (CH, CA, CZ, CN, RS, IT)
- **`office365a1.vip`** — 4 delete attempts, all failed
- **`microsoft365.win`** — blocked but 6.5 TB still on disk
- Total investigated: **~135 tenants** (up from ~85)
- Total confirmed fraud rings: **13+**

---

## 20. Complete Ring Catalog (Post-Phase 4b)

| # | Ring Name | Members | Combined TB | Key Domains | Operator Signal |
|---|-----------|---------|-------------|-------------|----------------|
| 1 | **Spring 2020 Mega-Ring** | 22+ | ~1,600+ | 21+ brand impersonation domains | `noDeletionBy=VL` tag, May 2020 burst |
| 2 | **TW/CN 365 Network** | 9+ | ~1,100+ | `0ffice.tw`, `office2021.co`, `officems365.live` | Zero-for-O technique |
| 3 | **VN School Network** | 16+ | ~850+ | `.edu.vn`, `forproxy.net` | Mass VN school names |
| 4 | **HK Gibberish Cluster** | 16+ | ~700+ | `.tk`, `.cf` free TLDs | `[gibberish]@[prefix]microsoft.com` |
| 5 | **Corporate Buzzword Ring** | **5** | ~220+ | `a1p.me` sub-domains | Nov 25 2018 burst, **5 Gmail/phone combos** |
| 6 | **University Impersonation** | 8+ | ~200+ | Real institutional emails | EDU verification abuse |
| 7 | **DADA Operator** | **3** | ~56 | `offices365.co`, 11× `.xyz` | `dada@aaaa.aaaaaaaa`, delete rollbacks |
| 8 | **Aug 2018 CN "A1 VIP"** | 3+ | ~30 | `office365a1.vip` | Sequential creation, 4× delete failures |
| 9 | **Canadian Impersonation** | 2+ | ~30+ | `.ca` school domains | Toronto base |
| 10 | **GPN Ring** | **3** | ~27.8 | `@winozyme.com` | Tokyo + Singapore, all `azure=active` |
| 11 | **Sequential Gibberish Ring** | 2+ | ~28 | `a[X]gfwacnz[DIGIT]` | Automated CN university impersonation |
| 12 | **Xiamen Operator Cluster** | 2+ | ~23 | `0592.tk`, `tripolskola.cz` | Xiamen base, cross-region hijacking |
| 13 | **AUTIGERS.ORG Ring (NEW)** | 2+ | ~21 | `[cc].autigers.org`, `[cc].go.edu.rs`, `usedu.us` | `zhangyf1995@gmail.com`, CN operator |

---

## 21. Investigation Gaps & Next Steps

### Completed investigation vectors (Phase 4 + 4b all batches)
- ✅ D2K operator fingerprinting for all major rings
- ✅ Creation burst analysis for Corporate Buzzword Ring (Nov 25, 2018)
- ✅ HK Gibberish ring email pattern discovery (`[gibberish]@[prefix]microsoft.com`)
- ✅ High-dormant-storage sweep (300 tenants, >1 TB, <=5 active, >50% inactive)
- ✅ ODB sites >> users ratio (95 tenants with >1000 sites, <=10 active, >80% inactive)
- ✅ EDU verification abuse documentation (4 confirmed cases using real institutional emails)
- ✅ Brand impersonation domain catalog (21+ domains across Spring 2020 + TW/CN rings)
- ✅ False positive validation for non-English named tenants
- ✅ Cross-region domain hijacking catalog (6 cases: CH, CA, CZ, CN, RS, IT)
- ✅ Systematic 5-15 TB range investigation (30 tenants, 11 fraud, 3 legit, 2 suspected)
- ✅ Systematic 5-10 TB range investigation (40 tenants, ~20 fraud, 2 legit, 3 FP review)
- ✅ Sequential Gibberish Ring discovery (automated `a[X]gfwacnz[DIGIT]` pattern)
- ✅ GPN Ring discovery + expansion to 3 members (`@winozyme.com` Tokyo+SG)
- ✅ Corporate Buzzword Ring 5th member confirmed (`amek.a1p.me`)
- ✅ DADA Ring 3rd member (11× `.xyz` random domains, delete rollback)
- ✅ Xiamen Operator Cluster (connects HK Gibberish to CN cross-region fraud)
- ✅ `azure=active` correlation (5+ fraud tenants with active Azure compute)
- ✅ AUTIGERS.ORG Ring discovery (`zhangyf1995@gmail.com`, `[cc].autigers.org` + `.go.edu.rs`)
- ✅ HK Gibberish Cluster expansion to 16+ members across 3 waves
- ✅ VN School Network expansion to 16+ members
- ✅ `office365a1.vip` brand domain — 4× delete failures documented

### Remaining investigation work
1. **~800+ ORANGE tier tenants** (1-5 TB range) — still mostly uninvestigated
2. **WATCH tier** (704 tenants, 0.23 PB) — may contain additional ring members
3. **Geographic anomaly detection** — systematic country vs. D2K city mismatch analysis
4. **Full a1p.me platform sweep** — 5 confirmed members, may be more
5. **MINHHIEN.EDU.VN 46-domain network** — may be a hub for VN reselling
6. **FP final review** — HIMAWARIGAKUEN (JP), 부산대저고등학교 (KR), Gemeinschaftsschule (DE), Shatin Tsung Tsin SS (HK), MY.JHEDU.AC.ID (ID), MTES.NTPC.EDU.TW (TW) need further verification
7. **Sequential Gibberish Ring expansion** — search for more `fwacnz` pattern tenants (may be >2 members)
8. **`winozyme.com` investigation** — 3 GPN members; may reveal more
9. **`autigers.org` ring expansion** — search for more `[cc].autigers.org` subdomains beyond `us.` and `hk.`
10. **SPO workload** — 南京大学 has 23 TB in SPO alone; SPO-focused analysis may find more
11. **`noDeletionBy=VL` tag** — how did fraud tenants get deletion protection?
12. **`azure=active` deep investigation** — what are these fraud tenants running on Azure compute?
13. **OFFICE 365 VN (`c044ec43`)** — FAB check errored, needs retry

---

**Total investigated: ~135 tenants (+ 6 confirmed FP, 7 under FP review). Total confirmed fraud storage: ~7,200 TB (~7.20 PB). 56 tenants (~1.67 PB) NOT IN FAB. 0 TB reclaimed. Investigation ongoing.**

---

---

## 22. Phase 5: Corrected Baseline — Full EDU Universe (ODB + SPO)

### 22.1 Baseline Correction

Early phases used a proxy filter (`StorageLimit_TB between 95..105`) on DimTenant_SiteMetrics to identify EDU tenants, yielding ~245K tenants and 245.7 PB ODB-only. This was **incomplete**.

Phase 5 joined DimTenant_SiteMetrics against DIM_TENANTS using `IsEduSegment == true`, revealing the true EDU universe:

| Metric | Value |
|--------|-------|
| **Total EDU Tenants** | **453,899** |
| EDU ODB Storage | 1,109.1 PB |
| EDU SPO Storage | 356.7 PB |
| **EDU Combined** | **1,465.8 PB** |

The corrected baseline is **~6x larger** than the Phase 1-4 ODB-only estimate. Fraud as a percentage of total EDU storage drops from 2.9% to **0.49%**, but the absolute storage impact (~7.2 PB fraud, ~15.4 PB total suspect) remains unchanged.

### 22.2 SPO vs ODB Storage Split

| Workload | Tenants | Total Storage | Over-Quota Tenants | Over-Quota Storage | Excess |
|----------|---------|--------------|-------------------|-------------------|---------|
| **ODB** | 400,511 | 1,135.7 PB | 2,660 | 48.7 PB | 27.7 PB |
| **SPO** | 453,893 | 365.3 PB | 878 | 7.3 PB | 3.9 PB |
| RaaS | 218,155 | 0.3 PB | 5 | ~6 TB | ~5 TB |

> Note: Over-quota counts here are per-workload (a tenant can be over-quota in ODB but not SPO). The 856 tenant-level over-quota count in §Running Totals is the deduplicated count.

---

## 23. Over-Quota Analysis — EDU Tenants Exceeding Storage Limits

### 23.1 Summary

Of 453,899 EDU tenants, **856 (0.19%) exceed their storage quota**, consuming **32.2 PB** of storage on a combined **15.5 PB** quota — an aggregate **16.8 PB excess**.

### 23.2 By Payment Status

| Status | Tenants | % of Over-Quota | Total Storage | Excess | Avg Ratio | Max Ratio |
|--------|---------|----------------|--------------|--------|-----------|-----------|
| **Paid** | 736 | 86% | 30.5 PB | 15.1 PB | 2.1x | 46.1x |
| **Free/Trial** | 120 | 14% | 1.8 PB | 1.6 PB | **5.2x** | **344.2x** |

Free/trial tenants are **2.5x more over-ratio** on average than paid tenants, and the worst offender is **344x** over quota (University of Nebraska-Lincoln: 1,023 TB on a 3 TB quota).

### 23.3 By Excess Tier

| Tier | Tenants | Paid | Free | Total Storage | Excess | Key Insight |
|------|---------|------|------|--------------|--------|-------------|
| **1x-1.5x** (mild) | 469 | 388 | 81 | 9.8 PB | 1.9 PB | Majority bucket — organic growth |
| **1.5x-2x** (moderate) | 171 | 160 | 11 | 5.7 PB | 2.3 PB | Growing toward action threshold |
| **2x-5x** (significant) | 179 | 164 | 15 | 11.1 PB | 7.3 PB | **Largest excess bucket by TB** |
| **5x-10x** (severe) | 17 | 12 | 5 | 0.6 PB | 0.5 PB | Mix of fraud and heavy users |
| **10x-50x** (extreme) | 19 | 12 | 7 | 4.1 PB | 3.8 PB | Fraud-heavy, incl. brand impersonation |
| **50x+** (egregious) | 1 | 0 | **1** | 1.0 PB | 1.0 PB | **UNL — 344x over quota** |

### 23.4 Top 20 Most Over-Quota EDU Tenants

| Rank | Tenant | Ratio | Storage TB | Quota TB | Excess TB | Paid? | Verdict |
|------|--------|-------|-----------|----------|-----------|-------|---------|
| 1 | **UNIVERSITY OF NEBRASKA-LINCOLN** | **344x** | 1,023 | 3.0 | 1,020 | Free | Legit — free-rider EDU |
| 2 | **暮城工作室** (Twilight City Studio, CN) | 46x | 93 | 2.0 | 91 | Paid | **IN FAB** — Mooncake, 1 license |
| 3 | **CONTOSO** | 36x | 108 | 3.0 | 105 | Free | Test/demo tenant? |
| 4 | **HUAZHONG UNIV OF SCI & TECH** | 36x | 90 | 2.5 | 87 | Paid | **IN FAB — BLOCKED** (.xyz domain) |
| 5 | **MICROSOFT 365** (y3.pw, HK) | 35x | 86 | 2.5 | 84 | Paid | **FRAUD — brand impersonation + .pw** |
| 6 | **TECHNOLOGICAL UNIV OF THE SHANNON** | 33x | 99 | 3.0 | 96 | Free | Legit Irish university — free-rider |
| 7 | **UNIVERSITY OF NEBRASKA AT OMAHA** | 31x | 93 | 3.0 | 90 | Free | Legit — free-rider EDU |
| 8 | **DAMANIA** (CN, mnsjj.onmicrosoft.com) | 27x | 68 | 2.5 | 66 | Paid | **SUSPECT — onmicrosoft-only, E3 Dev Free** |
| 9 | **UNIVERSITY OF NEBRASKA AT KEARNEY** | 19x | 56 | 3.0 | 53 | Free | Legit — free-rider EDU |
| 10 | **金融城网络服务工作室** (CN) | 16x | 847 | 52.1 | 795 | Paid | **IN FAB — ReadOnly** (5 lic, 847 TB) |
| 11 | **PROKARMA SOFTECH** (IN) | 16x | 47 | 3.0 | 44 | Free | Commercial in EDU — investigate |
| 12 | **MICROSOFT 365** (#2) | 15x | 38 | 2.5 | 36 | Paid | **FRAUD — brand impersonation** |
| 13 | **INDIGOLEARN EDU TECH** (IN) | 15x | 50 | 3.4 | 47 | Paid | EdTech company — suspicious |
| 14 | **ESCORTS LIMITED** (IN) | 12x | 53 | 4.5 | 49 | Paid | Commercial in EDU |
| 15 | **MICROSOFT 365** (#3) | 11x | 28 | 2.5 | 25 | Free | **FRAUD — brand impersonation** |
| 16 | **TRƯỜNG THCS PHÚC THUẬN** (VN) | 11x | 2,200 | 200 | 2,000 | Paid | **IN FAB — BLOCKED** (VN School Ring) |
| 17 | **MPS INTERACTIVE SYSTEMS** (IN) | 10x | 33 | 3.1 | 30 | Paid | Commercial in EDU |
| 18 | **POLYU** (HK) | 10x | 26 | 2.5 | 23 | Free | HK Polytechnic? Investigate |
| 19 | **广州童话镇网络信息技术** (CN) | 10x | 26 | 2.5 | 23 | Paid | "Fairy Tale Town Network" — suspect |
| 20 | **THE FUGARD THEATRE** (ZA) | 10x | 22 | 2.1 | 20 | Paid | Theatre in EDU — suspicious |

**Key insight:** The top 20 includes 3 separate "MICROSOFT 365" brand impersonation tenants, 3 University of Nebraska campuses (all free-riders consuming ~1.2 PB combined), and multiple Indian commercial companies in the EDU segment.

---

## 24. Phase 7: Systematic Ring Sweep (COMPLETED)

Phase 7 expanded and validated all 13+ rings from Phases 1-4b using Kusto pattern matching, creation burst analysis, and D2K fingerprinting. All rings from §20 were confirmed and sized. No fundamentally new rings were discovered, but member counts and storage totals were finalized.

---

## 25. Phase 8-10: User-Provided Tenant Investigation

### 25.1 Phase 8 — Batch 1 (16 IDs)

Investigated 16 tenant IDs provided by user. Results split into fraud, cleared, and suspect categories.

#### Fraud / Suspect (6 tenants)

| ID | Name | Domain | Country | Tier | Disk GB | Verdict |
|----|------|--------|---------|------|---------|---------|
| `94bc7f83` | SUI(TTC) | 4623.onmicrosoft.com | JP | TRIAL | 2,687 | SUSPECT — ingest candidate |
| `98ea162f` | OFFICE 365 | o365e3devmsdn | TW | TRIAL | 203 | **TW Dev Ring — NOT IN FAB** |
| `f6f6c5a9` | OFFICE 365 | o365tw01 | TW | E3 DEV FREE | 609 | **TW Dev Ring — NOT IN FAB** |
| `64e12855` | GIAO | 520211.xyz | CN | E3 DEV FREE | 41 | SUSPECT — .xyz |
| `ece68d08` | SMP NEGERI 1 SINJAI | organizationcaf | ID | EDU | 381 | SUSPECT — 398 domains |
| `5ff4bbb4` | CHSH | 135300.xyz | CN | E3 DEV | 110 | SUSPECT — .xyz |

#### TW Developer Ring (Ring #17 — NEW)

| ID | Name | Onmicrosoft | Country | Tier | Disk GB | FAB Status |
|----|------|-------------|---------|------|---------|------------|
| `98ea162f` | OFFICE 365 | o365e3devmsdn | TW/桃園市 | TRIAL | 203 | **NOT IN FAB** |
| `f6f6c5a9` | OFFICE 365 | o365tw01 | TW/桃園市 | E3 DEV FREE | 609 | **NOT IN FAB** |
| `f367d226` | OFFICE 365 | o365tw02 | TW/桃園市 | E3 DEV FREE | 2,130 | BLOCKED Sep 2025 |
| `1a1d2ae4` | OFFICE 365 | o365tw03 | TW/桃園市 | E3 DEV FREE | 1,473 | BLOCKED Sep 2025 |
| `d07d7d1a` | OFFICE 365 | o365tw04 | TW/桃園市 | E3 DEV FREE | 1,060 | BLOCKED Sep 2025 |

Pattern: Sequential onmicrosoft handles (`o365tw01..04`, `o365e3devmsdn`), all "OFFICE 365" name, all Taoyuan City TW, all E3 Developer Free, created Feb 2018. **Combined ~5.3 TB. 3 blocked, 2 NOT IN FAB.**

#### Cleared — Legitimate (5 tenants)

| ID | Name | Domain | Country | Evidence |
|----|------|--------|---------|---------|
| `fa9711da` | 김해분성여자고등학교 | khbsg-h.gne.go.kr | KR | 86-98% active ODB sites, real KR EDU hierarchy |
| `5a067f50` | 웅상고등학교 | ungsang-h.gne.go.kr | KR | Same legitimate pattern |
| `85e169fc` | 김해건설공업고등학교 | ghgeonseol-h.gne.go.kr | KR | Same — 1.46 TB, 62 total / 61 active sites |
| `3ac16ead` | 창원천광학교 | cheongwang-s.gne.go.kr | KR | Same — near-zero inactive storage |
| `45f690a1` | 배영초등학교 | baeyo-p.gne.go.kr | KR | Same — confirmed via ODB distribution query |

All 5 KR schools follow the `[school]-[type].gne.go.kr` pattern (Gyeongsangnam-do Education Office). ODB distribution query confirmed 86-98% active site ratios with near-zero inactive storage. **All CLEARED.**

### 25.2 Phase 8 — Batch 2 (20 IDs, 00xx Range)

Mostly dormant A1 EDU tenants with 0 storage. Two notable findings:
- `003144ce` — ZOVNX, HK gibberish (ingest candidate)
- `003959ac` — FONDAZIONE AIRC, Italy (legitimate paid cancer research foundation)

### 25.3 Phase 9 (48 IDs) — ALL LEGITIMATE

**All 48 tenants were legitimate paid organizations** — no fraud detected. Categories: charities (IRAP, Youth Federation, Lumos Foundation, Zoo Atlanta), commercial (Clariba, DESQ, Nexor, Jigsaw24), hospitals (UVM Health), education (ETS, Carl Remigius Fresenius). These appear to be **over-quota paid tenants** surfacing from a quota-enforcement analysis, NOT fraud.

### 25.4 Phase 10 (48 IDs)

#### Fraud / Confirmed Suspicious (5 tenants, ~1,345 TB)

| ID | Name | Domain | Country | Tier | Disk TB | FAB Status | Signal |
|----|------|--------|---------|------|---------|------------|--------|
| `6a63e133` | 金融城网络服务工作室 | vip.jrcpan.com | CN | SPO Plan 2 | **868** | **IN FAB** — ReadOnly Apr 2026 | 5 lic → 868 TB. Storage reseller |
| `07513973` | CONSULTING TECH ANTANA | onmicrosoft-only | ES | E3 Dev Free | **227** | **NOT IN FAB** | 5 lic, 125 TB ODB |
| `0c50cf4c` | HUAZHONG UNIV | 139777.xyz | CN | E3 Dev Free | **92** | **IN FAB** — Blocked Sep 2025 | University impersonation + .xyz |
| `ebbd28be` | **MICROSOFT 365** | **y3.pw** | HK | TRIAL | **88** | **NOT IN FAB** | Brand impersonation + .pw TLD |
| `fda22dc2` | DAMANIA | mnsjj.onmicrosoft.com | CN | E3 Dev Free | **70** | **NOT IN FAB** | onmicrosoft-only gibberish |

#### Borderline / Watch (3 tenants)

| ID | Name | Domain | Country | Tier | Disk TB | Status | Notes |
|----|------|--------|---------|------|---------|--------|-------|
| `3a8021b4` | 暮城工作室 | mcheng.partner.onmschina.cn | CN | Biz Basic | 95 | **IN FAB** | 1 license, 95 TB SPO. Mooncake |
| `13aaf805` | Univ of Nebraska Omaha | unomail.onmicrosoft.com | US | Trial (EDU) | 96 | NOT IN FAB | 0 paid lic, 37K ODB sites. Free-rider |
| `dc0346b5` | Univ of Nebraska-Lincoln | — | US | Trial (EDU) | ~1,023 | NOT IN FAB | **344x over-quota!** Free-rider |

#### University of Nebraska System

Three University of Nebraska campuses are the largest free-rider EDU tenants discovered:

| Campus | Disk TB | Quota TB | Ratio | ODB Sites |
|--------|---------|----------|-------|-----------|
| **Lincoln** | 1,023 | 3.0 | **344x** | 45,000+ |
| **Omaha** | 96 | 3.0 | 31x | 37,717 |
| **Kearney** | 56 | 3.0 | 19x | (est.) |
| **System Total** | **~1,175** | 9.0 | — | — |

Combined 1.2 PB on 9 TB of quota. All free/trial, never paid. These are legitimate universities that simply never paid for storage. Not fraud — but the single largest block of free-rider storage in EDU.

#### Legitimate Paid (40 tenants, ~5,500+ TB)

Notable organizations: ICBF (Colombia Gov, 1.4 PB), VUMC (877 TB), SEBRAE (Brazil, 692 TB), IDP Education (AU, 532 TB), WVU (516 TB), MIT Lincoln Lab (365 TB), College Board (347 TB), PowerSchool (302 TB), Po Leung Kuk (HK, 284 TB), Imagine Learning (136 TB), Royal Botanic Gardens Kew (131 TB), Southampton FC (80 TB), AICPA (116 TB), Church of the Highlands (74 TB), and many others. All are legitimate E3/E5 paid organizations that happen to exceed their storage quotas through organic growth.

---

## 26. Updated Ring Catalog (Post-Phase 10)

| # | Ring | Members | Storage | Key Signal | Status |
|---|------|---------|---------|-----------|--------|
| 1 | Spring 2020 Mega-Ring | 22+ | ~1,600 TB | SCHOOLO pattern, brand domains | Mixed |
| 2 | TW/CN 365 Network | 9+ | ~1,100 TB | `0ffice.tw`, `officems365.live` | Delete never exec |
| 3 | VN School Network | 18+ | ~2,900 TB | `.edu.vn` + commercial domains | Mixed |
| 4 | HK Gibberish Cluster | 18+ | ~810 TB | `[gibberish]@[prefix]microsoft.com` | Mostly NOT IN FAB |
| 5 | Corporate Buzzword Ring | 7 | ~371 TB | `a1p.me`, buzzword names | Some NO ACTION 3yr |
| 6 | University Impersonation | 8+ | ~200 TB | Real employee emails for EDU verification | Mixed |
| 7 | O365PO / SCHOOLO Ring | 13 | ~425 TB | SCHOOLO sub-pattern | Mixed |
| 8 | Brand Impersonation (OFFICE/MS365) | 6+ | ~2,025 TB | Tenant name = "MICROSOFT 365" | Mixed |
| 9 | DADA Operator | 3 | ~56 TB | `.xyz` random 5-char domains | Delete rollbacks |
| 10 | Aug 2018 CN "A1 VIP" | 3+ | ~30 TB | `office365a1.vip` | 4× delete failures |
| 11 | Canadian Impersonation | 2+ | ~30 TB | `.ca` school domains | Needs check |
| 12 | GPN / winozyme | 3 | ~28 TB | `@winozyme.com`, `azure=active` | All NOT IN FAB |
| 13 | Sequential Gibberish | 2+ | ~28 TB | `a[X]gfwacnz[DIGIT]` | NOT IN FAB |
| 14 | Xiamen Operator | 2+ | ~23 TB | `0592.tk`, Czech domain hijack | NOT IN FAB |
| 15 | AUTIGERS.ORG | 2+ | ~21 TB | `[cc].autigers.org`, `go.edu.rs` | NOT IN FAB |
| 16 | VN "OFFICE 365" Reseller Ring | 5+ | ~42 TB | ~1K ODB sites, ~1K enabled lic | NOT IN FAB |
| **17** | **TW Developer Ring (NEW Phase 8)** | **5** | **~5.3 TB** | Sequential `o365tw0[N]`, Taoyuan City | **2 NOT IN FAB, 3 blocked** |

---

## 27. Fraud Signals — Comprehensive Catalog

All signals discovered across Phases 1-10:

| Signal | Description | Example |
|--------|------------|---------|
| Brand impersonation domains | `office365*`, `365*`, `m365*`, `0ffice`, `a1.vip`, `micro365.me`, `apple-365.com` | `office365store.top` |
| Fake Microsoft email | `[gibberish]@[prefix]microsoft.com` | `cxoybulsc@revckmicrosoft.com` |
| `a1p.me` sub-domains | Shared A1 reselling platform | `b798.a1p.me` |
| Cross-region mismatch | Country registration ≠ actual operator location | Serbia reg → Xi'an operator |
| Gmail/generic admin email | Non-institutional email for EDU tenant | `Dudam@gmail.com` |
| onmicrosoft-only + gibberish | No custom domain, random handle | `mnsjj.onmicrosoft.com` |
| License/user ratio | Millions of licenses, <50 enabled | 37.9M lic / 3 enabled |
| Suspicious TLDs | `.xyz`, `.tk`, `.cf`, `.top`, `.live`, `.uno`, `.co`, `.pw` | `139777.xyz`, `y3.pw` |
| `noDeletionBy=VL` on free | Deletion protection on free A1 tenants | FOSSCHOOLS |
| Creation burst | Multiple tenants same day/hour | Corporate Buzzword (5 in 5 hours) |
| `[cc].autigers.org` | Zhang operator subdomain pattern | `us.autigers.org` |
| `@winozyme.com` email | GPN ring operator domain | `gpnph@winozyme.com` |
| 5-char random `.xyz` | DADA operator fingerprint | `snchd.xyz` |
| SPO-only storage | SPO storage with 0 ODB | Storage hoarding pattern |
| SCHOOLO pattern | `[XXX]SCHOOLO.[XXX]SCHOOLO` | `WKTSCHOOLO.WKTSCHOOLO` |
| Sequential onmicrosoft handles | `o365tw01`, `o365tw02`, etc. | TW Developer Ring |
| ~1K ODB + ~1K enabled lic | VN reseller fingerprint | VN "OFFICE 365" Ring |
| 398+ domains | Domain harvesting | Indonesian SMP NEGERI |
| 5 licenses + hundreds of TB | Extreme storage-to-license ratio | 金融城 (868 TB / 5 lic) |
| `.pw` TLD | Palau domain - rare, cheap | `y3.pw` (MICROSOFT 365) |

---

## 28. Recommendations & Action Plan

### 28.1 Immediate Actions (No Ingestion Yet — Investigation Only)

1. **Over-quota enforcement review**: 856 EDU tenants consuming 16.8 PB excess — determine if enforcement mechanisms exist
2. **Free/Trial over-quota audit**: 120 free/trial tenants at 5.2x average — highest fraud risk cohort
3. **University of Nebraska engagement**: 3 campuses consuming 1.2 PB on free tier — need licensing conversation
4. **Storage reselling detection**: Query for pattern: <10 licenses + >100 TB storage across all EDU
5. **noDeletionBy=VL flag audit**: How are fraud tenants getting deletion protection?
6. **"MICROSOFT 365" brand sweep**: At least 3 tenants in top 20 over-quota using this name

### 28.2 Tenants Requiring Investigation (From Phase 10)

```
# NOT IN FAB — Phase 10 discoveries
ebbd28be-872f-402c-a7a7-ed267b907a67  # "MICROSOFT 365" / y3.pw (88 TB) - HK brand impersonation
fda22dc2-7d15-4930-8c31-fc604b9dbfe0  # DAMANIA / mnsjj (70 TB) - CN E3 Dev Free
07513973-e2ac-4e64-acdd-a81a1f7c6f80  # CONSULTING TECH ANTANA (227 TB) - ES, 5 lic hoarder

# NOT IN FAB — Phase 8 discoveries (TW Dev Ring)
98ea162f-*  # OFFICE 365 / o365e3devmsdn (203 GB) - TW
f6f6c5a9-*  # OFFICE 365 / o365tw01 (609 GB) - TW
```

### 28.3 Overall Priority Order

1. Storage reselling / distribution network detection (in progress)
2. `noDeletionBy=VL` abuse analysis (next)
3. Ingest net-new fraud tenants once investigation is complete
4. Over-quota enforcement for free/trial tier
5. Full report finalization

---

*Report generated by FAB Investigation Agent — April 23, 2026*  
*Updated: Phase 10 complete. 17+ rings, 56+ NOT IN FAB, 856 over-quota, 0 TB reclaimed.*  
*Over-quota analysis + storage reselling detection in progress.*
