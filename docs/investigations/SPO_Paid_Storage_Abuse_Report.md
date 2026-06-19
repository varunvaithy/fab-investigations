# SPO Paid Storage Abuse Ring — Investigation Report

**Investigation Date:** April 8, 2026  
**ICM:** 775773500  
**Scope:** All SPO-paid-SKU storage abusers across 944-tenant DS list  
**Status:** CRITICAL — 5+ PB of fraudulent storage identified

---

## Executive Summary

A systematic scan of all 944 DS-flagged tenants for non-developer (`tenantType == 'Default'`) license patterns revealed **far more** than the 3 SPO Plan 2 tenants initially identified in Japan. Across the full dataset:

- **11 MISTYCLOUD INC. tenants** in Argentina storing **3.76 PB** combined — a coordinated ring
- **5 SPO Plan 2 individual abusers** storing **1.36 PB**
- **6 SPO Plan 1 abusers** storing **209 TB**
- **5 Business Basic/Standard abusers** storing **479 TB**
- **Total: 27 tenants, ~5.8 PB, paying approximately $200-300/month combined**

The MISTYCLOUD ring alone dwarfs the entire FAMILIA CONFEITAR ring (Ring 1) in storage impact. It's the single largest storage abuse operation found in the DS list.

---

## Sub-Ring A: MISTYCLOUD INC. (Argentina) — COORDINATED RING

### Ring Profile
| Metric | Value |
|--------|-------|
| **Operator** | MISTYCLOUD INC. / MISTYCLOUD INC (consistent) |
| **Country** | Argentina, Buenos Aires metro area |
| **Creation Date** | April 23-25, 2025 (2-day burst) |
| **Domain Pattern** | `mistytempspNar.onmicrosoft.com` (N=1-10) + `mssp1ar` |
| **SKU** | SPO Paid (tenant_level blank — likely SPO storage add-on or similar) |
| **Seats** | 1 per tenant |
| **Quota** | 1.03 TB per tenant |
| **ODB Sites** | 0-1 per tenant (storing in SPO sites, not ODB) |
| **FAB Status** | TYPE1 identified Apr 1, 2026 — **NO REMEDIATION TAKEN** |

### Tenant Inventory — 11 Tenants, 3.76 PB

| # | Tenant ID | Domain | City | Stored | Quota | Overage | FraudId | Status |
|---|-----------|--------|------|--------|-------|---------|---------|--------|
| 1 | `8dae3977` | mssp1ar | Buenos Aires | **362 TB** | 1 TB | 350x | 148121 | Identified only |
| 2 | `117f2c6f` | mistytempsp1ar | Muñiz | **270 TB** | 1 TB | 261x | 148125 | Identified only |
| 3 | `9c760ca4` | mistytempsp2ar | Villa Martelli | **352 TB** | 1 TB | 340x | — | Identified only |
| 4 | `e14fa431` | mistytempsp3ar | Jose Ingenieros | **352 TB** | 1 TB | 340x | — | Identified only |
| 5 | `4f4dff80` | mistytempsp4ar | Caseros | **348 TB** | 1 TB | 337x | 148124 | Identified only |
| 6 | `01e17974` | mistytempsp5ar | Caseros | **348 TB** | 1 TB | 337x | — | Identified only |
| 7 | `1bae1b9a` | mistytempsp6 | La Plata | **362 TB** | 1 TB | 350x | — | Identified only |
| 8 | `6c99632a` | mistytempsp7ar | La Plata | **364 TB** | 1 TB | 352x | — | Identified only |
| 9 | `4915ae67` | mistytempsp8ar | Florencio Varela | **359 TB** | 1 TB | 347x | — | Identified only |
| 10 | `9e63b781` | mistytempsp9ar | San Justo | **363 TB** | 1 TB | 351x | — | Identified only |
| 11 | `72795d28` | mistytempsp10ar | San Justo | **364 TB** | 1 TB | 352x | — | Identified only |
| | | | **TOTAL** | **3,844 TB** | 11 TB | **350x avg** | | |

### Ring Characteristics
- **Sequential domain naming:** `mistytempspNar.onmicrosoft.com` where N = 1 through 10, plus prototype `mssp1ar`
- **2-day creation burst:** 2 tenants on Apr 23, 9 tenants on Apr 25, 2025
- **All Buenos Aires metro:** Cities span ~50km radius (Buenos Aires, Villa Martelli, Caseros, La Plata, San Justo, Florencio Varela, José Ingenieros, Muñiz) — likely different IPGeo for same operator
- **Zero ODB usage on most:** Storage is in SPO sites, not OneDrive — likely used as a CDN/storage backend
- **TYPE1 detection fired but NO remediation:** FraudIds assigned Apr 1, 2026 but usecaseType is "TYPE1" which apparently does not trigger ABUSE-READONLY-BLOCK-DELETE. These tenants have been sitting in FAB for 7 days with NO action.
- **Economics:** ~$55-120/month total for 3.76 PB = **$0.015-0.032/TB/month** (vs Azure Blob $20/TB/month)

### FAB Gap
The MISTYCLOUD tenants were detected by TYPE1 rule but are stuck in "Identified" status with no remediation schedule created. This is a **remediation pipeline gap** — TYPE1 detections apparently do not auto-progression to ReadOnly/Block/Delete. They have been accumulating storage for **11.5 months** since creation.

---

## Sub-Ring B: SPO Plan 2 Individual Abusers

| # | Tenant ID | Name | Country/City | Stored | Quota | Overage | FAB Status |
|---|-----------|------|-------------|--------|-------|---------|------------|
| 1 | `c177d029` | SEEMSONLINE COMP. | HK (fake) | **693 TB** | 1 TB | 693x | **NOT IN FAB** |
| 2 | `ee62ef68` | 星火计划 (Spark Plan) | CN Shanghai | **332 TB** | 1 TB | 332x | ReadOnly ✅ |
| 3 | `1db6c094` | CREATIVEINFO | US NJ Edison | **230 TB** | 1 TB | 222x | **NOT IN FAB** |
| 4 | `0a79f022` | MSI GSC ENG DEPT. | CN Shenzhen | **103 TB** | 26.7 TB | 3.9x | **NOT IN FAB** |
| 5 | `ce7336c1` | HIBIKI | CN Shanghai | **6.8 TB** | 1 TB | 6.6x | **NOT IN FAB** |
| | | | **TOTAL** | **1,365 TB** | | | |

### Key Profiles

**SEEMSONLINE** (`c177d029`): rclone from OVH France (Roubaix/Paris), actively uploading 6-12 TB/day. 693 TB on 1 TB quota. Most urgent ingestion target.

**CREATIVEINFO** (`1db6c094`): US-based, NJ Edison. 230 TB on SPO Plan 2 ($12.50/mo). Just discovered — **NOT in FAB**. Needs immediate investigation — could be a US-based reseller operation.

**MSI GSC ENG DEPT** (`0a79f022`): CN Shenzhen, 5 subscriptions, 32 ODB sites, domain `gcsrma.onmicrosoft.com`. 103 TB but with 26.7 TB quota (multiple subscriptions). Uses Files/Browser/OneDriveSync — normal app pattern. **Possible legitimate MSI (Micro-Star International) engineering department.** Only 3.9x over quota. Recommend manual review before action.

**HIBIKI** (`ce7336c1`): Small abuser at 6.8 TB. Shanghai, domain `nagami05`, SPO Plan 2. Low priority.

---

## Sub-Ring C: SPO Plan 1 Abusers

| # | Tenant ID | Name | Country/City | Stored | Quota | FAB Status |
|---|-----------|------|-------------|--------|-------|------------|
| 1 | `46165939` | DNG LINKS | VN Hanoi | **72 TB** | 1 TB | **NOT IN FAB** |
| 2 | `2effe1af` | RUUNG BEAUTY & HEALTH | VN Hanoi | **45 TB** | 1 TB | **NOT IN FAB** |
| 3 | `b567378a` | LC SPORT | VN Hanoi | **37 TB** | 1 TB | **NOT IN FAB** |
| 4 | `7288630e` | HDP | VN Hanoi | **24 TB** | 1 TB | **NOT IN FAB** |
| 5 | `54739162` | SKYSTUDIO | HK | **18 TB** | 1 TB | **NOT IN FAB** |
| 6 | `e1edde8b` | 终点 (Terminus) | CN Harbin | **13 TB** | 1 TB | **NOT IN FAB** |
| | | | **TOTAL** | **209 TB** | | |

### Vietnamese SPO Plan 1 Cluster (4 tenants)
DNG LINKS, RUUNG BEAUTY & HEALTH, LC SPORT, and HDP are all:
- Vietnam, Hanoi
- SPO Plan 1, 1 seat, $5/mo
- Created May 21-22, 2024 (3 of 4 — HDP is Dec 2023)
- Fake Vietnamese company names
- All NOT in FAB

This is likely a single operator using multiple Vietnamese company registrations. Combined 178 TB on 4 TB of quota.

---

## Sub-Ring D: Business Basic/Standard Abusers

| # | Tenant ID | Name | Country/City | SKU | Stored | Quota | FAB Status |
|---|-----------|------|-------------|-----|--------|-------|------------|
| 1 | `c6c7afca` | SUGARINC | VN HCM | Biz Basic | **205 TB** | 1 TB | **Blocked** ✅ |
| 2 | `41e4853c` | DQDB (blfmiller.com) | IN Delhi | Biz Basic | **177 TB** | 52 TB | **ReadOnly** ✅ |
| 3 | `a597ef09` | HIMANYA EXPORT | IN Ghaziabad | Biz Basic | **99 TB** | 103 TB | **NOT IN FAB** |
| 4 | `9e0ae8bf` | PORMEGA | VE Maracaibo | Biz Basic | **67 TB** | 1 TB | **NOT IN FAB** |
| 5 | `8d1205a5` | PORMEGA | VE Maracaibo | Biz Basic | **60 TB** | 1 TB | **NOT IN FAB** |
| 6 | `f9aaa56e` | CAS TERM LTD | NZ Auckland | Biz Standard | **48 TB** | 1 TB | **NOT IN FAB** |
| | | | | **TOTAL** | **656 TB** | | |

### PORMEGA Ring (Venezuela, 2 tenants)
Both named "PORMEGA", same city (Maracaibo), sequential domains (pormega389, pormega012). Business Basic, 1 seat each. Combined 127 TB. **NOT in FAB.**

### HIMANYA EXPORT — Edge Case
99 TB stored on 103 TB quota — not over quota! But still a 1-seat Business Basic tenant storing 99 TB on a $6/mo plan. The quota is suspiciously high (103 TB for 1 seat). May have purchased additional storage. **Lower priority — investigate quota source.**

---

## Complete Inventory Summary

| Sub-Ring | Tenants | Total Storage | Revenue/mo | NOT in FAB | Status |
|----------|---------|---------------|-----------|-----------|--------|
| A: MISTYCLOUD (Argentina) | 11 | **3,844 TB** | ~$60-120 | 0 (all TYPE1) | Handled separately (ICM 771980255) |
| B: SPO Plan 2 | 5 | **1,365 TB** | ~$62 | 0 | 1 ReadOnly, **3 ingested Apr 8** |
| C: SPO Plan 1 | 6 | **209 TB** | ~$30 | 0 | **6 ingested Apr 8** |
| D: Business Basic/Std | 6 | **656 TB** | ~$36 | 0 | 2 prior remediated, **4 ingested Apr 8** |
| **GRAND TOTAL** | **28** | **6,074 TB (5.9 PB)** | **~$190-250** | **0** | **13 ingested + 11 separate + 3 prior + 1 manual review** |

---

## Remediation Log

### April 8, 2026 — Batch Ingestion (13 tenants)
**RC:** 107 | **UseCaseType:** 7 (ABUSE-READONLY-BLOCK-DELETE) | **ICM:** 775773500

Ingested tenants:
- `c177d029` SEEMSONLINE (693 TB, SPO Plan 2)
- `1db6c094` CREATIVEINFO (230 TB, SPO Plan 2)
- `ce7336c1` HIBIKI (6.8 TB, SPO Plan 2)
- `46165939` DNG LINKS (72 TB, SPO Plan 1, VN)
- `2effe1af` RUUNG BEAUTY & HEALTH (45 TB, SPO Plan 1, VN)
- `b567378a` LC SPORT (37 TB, SPO Plan 1, VN)
- `7288630e` HDP (24 TB, SPO Plan 1, VN)
- `54739162` SKYSTUDIO (18 TB, SPO Plan 1, HK)
- `e1edde8b` 终点/Terminus (13 TB, SPO Plan 1, CN)
- `9e0ae8bf` PORMEGA (67 TB, Biz Basic, VE)
- `8d1205a5` PORMEGA (60 TB, Biz Basic, VE)
- `f9aaa56e` CAS TERM LTD (48 TB, Biz Standard, NZ)
- `a597ef09` HIMANYA EXPORT (99 TB, Biz Basic, IN)

### MISTYCLOUD Ring (11 tenants) — Handled Separately
**ICM:** 771980255 — Existing TYPE1 detections being re-routed to ABUSE-READONLY-BLOCK-DELETE manually.

### Pending Manual Review
- `0a79f022` MSI GSC ENG DEPT (103 TB, SPO Plan 2, CN Shenzhen) — possibly legitimate MSI hardware company

### Previously Remediated (No Action Needed)
- `ee62ef68` 星火计划 — ReadOnly ✅
- `c6c7afca` SUGARINC — Blocked ✅
- `41e4853c` DQDB — ReadOnly ✅

---

## Detection Rule Candidates

### Rule SPO-1: SPO Paid Single-Seat Mega-Hoarder
```
SKU IN ("SharePoint Plan 1", "SharePoint Plan 2", "Business Basic", "Business Standard")
AND seats == 1
AND tenantTotalDiskUsedGB > 50 * storageLimitGB
AND hasCustomDomain == FALSE
```
**Coverage:** 25 of 28 tenants  
**Estimated FP:** Very low

### Rule SPO-2: Sequential Domain Multi-Tenant Ring
```
tenantName matches across tenants
AND domain matches pattern `{prefix}N{suffix}.onmicrosoft.com`
AND createdDate within 7 days of each other
AND SKU is SPO-paid
AND seats == 1
```
**Coverage:** MISTYCLOUD (11), PORMEGA (2), FAMILIA CONFEITAR (30)

### Rule SPO-3: Argentina/LatAm SPO Storage Arbitrage
```
country IN ("AR", "VE", "BR")
AND SKU is SPO-paid  
AND seats == 1
AND tenantTotalDiskUsedGB > 100 * storageLimitGB
AND hasEverPaid == TRUE
```
**Coverage:** MISTYCLOUD (11) + PORMEGA (2)

---

## Systemic Issues Identified

1. **TYPE1 detection does not trigger remediation** — MISTYCLOUD has been in FAB for 7 days as TYPE1 with no auto-progression. 3.76 PB sitting unactioned.
2. **SPO quota not enforced** — All tenants exceeded quota by 6x-693x with no hard limit preventing continued uploads.
3. **Multi-tenant circumvention** — Same operator creates multiple tenants (MISTYCLOUD, PORMEGA, FAMILIA CONFEITAR) to distribute storage load and avoid per-tenant detection.
4. **Cross-geography arbitrage** — SPO pricing is uniform globally but detection varies. Argentina and Vietnam are exploitation hotspots.
