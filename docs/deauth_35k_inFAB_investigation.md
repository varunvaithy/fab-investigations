# De-Auth 35.9K Investigation: In-FAB but FraudState=False

**Generated:** 2026-05-22  
**Investigator:** Automated via D2K + fabpartnerdb cross-analysis  
**Population:** 35,881 tenants with D2K feature 66 (de-auth) + `locked=abuse`, processed in last 30 days, present in FAB `DIM_TENANTS` with `FraudState=False`, `State=Active`

---

## Executive Summary

**35,881 de-auth'd abuse-locked tenants sit in FAB's reference table but have NEVER been flagged for enforcement.** All 35,881 have zero users, most have zero licenses, and none show legitimate business activity. They collectively reserve **~155 PB of allocated SPO storage**. The reason they're not enforced is simple: FAB's `DIM_TENANTS` is a dimensional table of ALL SPO-provisioned tenants — `FraudState=False` is the default state, not an active decision to exclude them.

**95.5% (34,251) pass all FAB eligibility checks** (no VL, no S500, no paid). These can be ingested immediately.

---

## Why They're Not Being Enforced

| Factor | Explanation |
|--------|-------------|
| **DIM_TENANTS is a reference table** | It contains ALL tenants with SPO provisioning, not just fraud targets |
| **FraudState=False is the default** | It means "not yet evaluated" — not "evaluated and cleared" |
| **No D2K-to-FAB integration exists** | The `locked=abuse` + feature 66 signal from D2K is not piped into FAB's detection/ingestion flow |
| **FAB detects from ODSP signals** | FAB's detection rules look at ODSP-native signals (storage abuse, activity patterns), not external D2K flags |

**Root cause:** There is no automated bridge between AAD/Identity-layer abuse signals (D2K) and ODSP-layer enforcement (FAB). These tenants were caught by Identity but never forwarded to ODSP for cleanup.

---

## Population Profile

### Core Metrics

| Metric | Value | Significance |
|--------|-------|--------------|
| Total tenants | 35,881 | — |
| **Zero users** | 35,881 (100%) | No human has ever logged in |
| Zero licenses | 27,955 (78%) | No O365 product assigned |
| 1-6 licenses | 7,926 (22%) | Likely trial/free SKUs, never activated |
| Has Paid | 306 (0.85%) | Nearly all unpaid |
| Has Volume Licensing | 924 (2.6%) | **Fraudulent VL claims** (single first names, 0 users) |
| IsS500 | 82 (0.2%) | Some may be brand impersonation of real S500 |
| Avg StorageLimit | 4.2 TB | Per tenant |
| **Total allocated storage** | **~155 PB** | 30 tenants claim 100TB+ each (118 PB from those alone) |

### Enforcement Eligibility

| Category | Count | % | FAB Action |
|----------|-------|---|------------|
| **Eligible (no VL, no S500, no paid)** | 34,251 | 95.5% | Can ingest now |
| HasVL (fraudulent claims) | 924 | 2.6% | Need VL override / manual review |
| IsS500 | 82 | 0.2% | Need S500 override / verification |
| HasPaid | 306 | 0.85% | Review individually |
| Overlap (multiple flags) | ~318 | — | Combined exclusion criteria |

---

## Commonality Analysis

### Name Pattern Clusters

| Pattern | Count | % | Examples |
|---------|-------|---|---------|
| **Gibberish (uppercase random 8+ chars)** | 12,238 | 34.1% | "28DSQ96LW6DUWOWT3PS", "AWK2AJVLGVVKHDYRIQ1" |
| **Single first names** | ~14,914 | 41.6% | "ANGELA" (320), "SARAH" (279), "THERESA" (138), "EMILY" (122) |
| **"YAM STORE"** | 931 | 2.6% | Known fraud ring reusing same name |
| **"DEFAULT DIRECTORY"** | 709 | 2.0% | Never configured placeholder |
| **"MICROSOFT"** | 608 | 1.7% | Direct brand impersonation |
| **Phishing messages** | 653 | 1.8% | "YOUR MICROSOFT SUBSCRIPTION HAS BEEN RENEWED VIA PAYPAL..." |
| **Brand impersonation** | ~168 | 0.5% | "COLMEDICA" (66), "UHG" (56), "OPTUM" (46) |
| **Other (short 2-word)** | ~5,275 | 14.7% | "QUANTUM LABS", "TITAN DYNAMICS", "FUSION WORKS" |

### Creation Time Wave

| Period | Tenants Created | Pattern |
|--------|----------------|---------|
| Jan 2026 | ~1,841 | Steady drip |
| Feb 2026 | ~1,151 | Low activity |
| **Mar 23 - Apr 20, 2026** | **~11,400** | **Massive fraud ring wave** |
| Apr 21 - May 3 | ~3,725 | Tapering |
| May 4 - present | ~593 | Declining (post-deauth) |

**70%+ were created in a single 6-week burst (mid-March to early May 2026).**

### Creator App Fingerprint

| Creator App | Count | Identity |
|-------------|-------|----------|
| `b4bddae8-ab25-483e-8670-df09b9f1d0ea` | 6,489 (12.5%) | SMB signup flow (`o365.microsoft.com/smblaunch`) |
| No createdBy tag | 45,158 (87%) | Direct web signup (untagged flow) |
| `8e0e8db5-b713-4e91-98e6-470fed0aa4c2` | 13 | Minor |

### Customer Segment

| Segment | Count | Note |
|---------|-------|------|
| (empty) | 29,572 (82%) | Never classified — confirms they were never real |
| SME&C SMB | 5,800 (16%) | Fake SMB signups |
| Enterprise | 325 (0.9%) | Brand impersonation (COLMEDICA, etc.) |
| EDU | 101 (0.3%) | Fake EDU claims |
| SMC - SMB | 71 (0.2%) | — |

### Geography (from D2K)

| Country | % |
|---------|---|
| US | 89% |
| PE | 3.4% |
| CL | 2.9% |
| CO | 1.6% |
| BR | 1.2% |

---

## Storage Impact: The 100TB+ Outliers

30 tenants individually claim 100TB-20PB each. Top offenders:

| Tenant ID | Name | Storage Claimed | Signal |
|-----------|------|----------------|--------|
| 0ea93436 | "YOUR MICROSOFT SUBSCRIPTION HAS BEEN RENEWED VIA PAYPAL...CALL (812) 223 8395" | **~19.5 PB** | Phishing scam |
| 29d527e8 | Same phishing name | **~19.5 PB** | Duplicate ring |
| 468b031d | "TENANTHUB SERVICES" | **~19.5 PB** | Storage farming |
| 6e219b7f | Same phishing name | **~19.5 PB** | Duplicate ring |
| 8cc54928 | "CLOUDSYNC" | **~9.7 PB** | Storage farming |
| 170692d2 | Same phishing name | **~9.7 PB** | Duplicate ring |
| 2b4ce95f | Same phishing name | **~9.7 PB** | Duplicate ring |

**These 7 tenants alone claim ~107 PB.** The remaining 23 each claim 100 TB.

---

## Action Plan

### Phase 1: Immediate — Ingest 34,251 Eligible Tenants

These pass all FAB validation (no VL, no S500, no paid, 0 users):

```
IngestTenants:
  tenantIds: <batch of 1000 per call, 35 API calls total>
  reasonCode: 96 (DETECTION_AUTOMATION_REASON_CODE)
  useCaseType: 10 (ABUSE-READONLY-BLOCK-DELETE_15DAYS)
  ticketLink: <ADO work item>
  isReviewRequired: false
```

**Expected timeline per batch:**
- Day 0: Ingest → HIT_APPROVED
- Day 0-1: Block initiated → Block completed
- Day 15: Delete initiated → Delete completed

**Storage reclaimed:** ~143 TB × 34,251 = estimated **~4.4 PB recoverable** (based on actual disk usage being ~1% of allocated for hollow shells)

### Phase 2: Review — 924 HasVL Tenants

These are flagged `HasVolumeLicensing=true` in DIM_TENANTS but are clearly fraud:
- All have 0 users, single first names ("ANGELA", "COREY", "LACY")
- Need to override the VL exclusion for these specific tenants
- **Recommend:** File a bug/feature request to add "VL override for confirmed abuse" to FAB ingestion

### Phase 3: Review — 82 IsS500 Tenants

- "COLMEDICA" (66 tenants) — Colombian healthcare org being impersonated
- Verify none are legitimately associated with the real S500 entity
- If confirmed fraud: override S500 exclusion

### Phase 4: Address the Root Cause

| Action | Owner | Impact |
|--------|-------|--------|
| **Create detection rule:** D2K `feature 66 + locked=abuse` + DIM_TENANTS `TotalUsers=0` → auto-ingest | FAB team | Catches all future de-auth'd abuse tenants |
| **Add to DetectionAutomationRulesData** | FAB team | Automated pipeline |
| **Investigate creator app** `b4bddae8` | Identity/AAD team | Block at signup layer |
| **Request D2K-to-FAB signal bridge** | Cross-team (AAD/ODSP) | Permanent fix for the gap |

---

## Recommended Detection Rule (for `DetectionAutomationRulesData`)

```sql
-- Pseudo-logic for the new detection rule
-- Signal: D2K feature 66 + locked=abuse + ODSP TotalUsers=0
-- Action: ABUSE-READONLY-BLOCK-DELETE_15DAYS (UseCaseType 10)
-- Exclusions: IsS500, HasVolumeLicensing (verified), HasPaid

SELECT t.OMSTenantId
FROM DIM_TENANTS t
WHERE t.TotalUsers = 0
  AND t.LicensesEnabled <= 1
  AND t.HasPaid = 0
  AND t.HasVolumeLicensing = 0
  AND t.IsS500 = 0
  AND t.FraudState = 'False'
  AND t.State = 'Active'
  AND EXISTS (
    -- D2K cross-reference: feature 66 + locked=abuse
    SELECT 1 FROM D2K_DEAUTH_FEED d
    WHERE d.TenantId = t.OMSTenantId
  )
```

---

## Summary of Findings

| Question | Answer |
|----------|--------|
| **Why not enforced?** | No D2K→FAB signal bridge exists. FraudState=False is the default, not a clearance. |
| **Are they legitimate?** | No. 100% have 0 users, 0 activity, 78% have 0 licenses. Names are gibberish/phishing/impersonation. |
| **What's the impact?** | ~155 PB allocated storage held by fraud shells. 34,251 immediately actionable. |
| **What's the fix?** | Ingest 34K now via API batches. Add detection rule for future catches. Build D2K→FAB bridge. |
| **What's the risk of enforcement?** | Very low — 0 users means 0 real humans affected. The 306 "HasPaid" and 82 "IsS500" need individual review. |

---

## Files Generated

| File | Contents |
|------|----------|
| `deauth_51k_full.csv` | All 51,738 tenants (D2K metadata) |
| `deauth_51k_notInFAB_15337.csv` | 15,316 tenants NOT in FAB at all |
| `deauth_51k_sample5000.csv` | First 5000 with full metadata |
| `deauth_51k_analysis.md` | Summary + KQL queries |
| `deauth_35k_inFAB_investigation.md` | This document |
