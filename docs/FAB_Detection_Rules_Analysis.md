# FAB Detection Rules: Do They Work?

**Date**: April 20, 2026 | **Author**: Varun V | **Data**: `FAB_DAR_DB`, `SpoProd`, `D2KRedacted`

---

## TL;DR

Five rules (R1–R5) + one AI sweep (R0) have flagged **141,975 tenants** and **3+ PB** of abused SPO storage since Oct 2025. The rules are precise (96.4% TP rate) but narrow — they only see storage-heavy fraud on developer/education/SMB SKUs.

Three things need to happen:

1. **Fix R3's false-positive rate** (8.89% → ~2%) by adding a domain filter. Root cause: 82% of FPs have custom domains vs 36% of TPs. One config change.
2. **Fix the upstream feed.** 578 of 592 E5 Dev tenants the DS Model caught were never sent to the rule engine. The "10–20 TB blind spot" is a feed gap, not a threshold problem.
3. **Expand R5's SKU coverage.** SharePoint Plan 2 (avg 255 TB/tenant), F1 Kiosk (avg 206 TB), ODB Plan 2 (avg 162 TB) — no rule covers these. Multi-PB fraud is invisible.

The 85K A1 gap (89.6% zero storage) is unreachable by any storage-based rule. It requires different signals entirely.

---

## Rule Verdicts

| Rule | Tenants | Storage | FP Rate | Verdict |
|------|---------|---------|---------|---------|
| R1 – Chia Mining | 22 | 40 TB | 0% | **RETIRE** — Dead since Dec 2025 |
| R2 – Streaming | 620 | 561 PB | 1.74% | **HEALTHY** — Best rule. 97.6% remediation. |
| R3 – Storage+Egress+MAU | 1,130 | 163 PB | **8.89%** | **FIX FP** — Add domain filter (§2) |
| R4 – Storage/MAU | 1,143 | **1,981 PB** | 4.68% | **FIX PIPELINE** — 196 tenants stuck 146 days (§3) |
| R5 – FraudInSMB | 72 | 290 PB | 3.17% | **EXPAND** — Only 3 SKUs covered. Signal is right; scope isn't. |
| R0 – AI Agent | 44,669 | 10 TB | 0.13% | **MONITOR** — Bulk sweep, held by design. |

Detection Automation (RC96) is 95.8% of enforcement — 90x more precise than manual (0.29% FP vs 27%).

---

## 1. How the Rules Work

An external system evaluates rules against SPO telemetry and writes matching SSIDs + a bitmask into `DetectionAutomationRulesData`. FAB enriches from Kusto, filters ISS500/ISS2200 exclusions, and ingests into the remediation pipeline. Rules are config-driven — no code changes needed.

| Bit | Rule | Key Thresholds | SKU Scope |
|-----|------|---------------|-----------|
| 1 | R1 – Chia Mining | Crypto FileType, Size >100 GB, MAU <10 | E5/E3 Dev, A1 |
| 2 | R2 – Streaming | Video FileType, Storage >20 TB, Egress >P99 | E5/E3 Dev |
| 4 | R3 – Storage+Egress+MAU | MAU <5, Storage >10 TB, Egress >P999 | E5/E3 Dev, A1 |
| 8 | R4 – Storage/MAU | MAU <5, Storage >20 TB | E5/E3 Dev, A1 |
| 16 | R5 – FraudInSMB | MAU <3, PaidLicenses <3, Storage >20 TB | Biz Basic/Std/Premium |

---

## 2. R3: Fixable False-Positive Problem

R3's 8.89% FP rate is 5x worse than R2. Profiled 1,131 FPs vs 10,139 TPs:

| Signal | True Positives | False Positives |
|--------|---------------|----------------|
| Has custom domain | 36.4% | **82.0%** |
| Onmicrosoft-only | 63.5% | 17.9% |

Custom domain = likely legitimate org (school, dev workload) that happens to hit thresholds.

**Fix:** Add `hasInitialDomainOnly = TRUE`. FP drops to ~2%. Trade-off: ~36% of current TPs have custom domains — route those to a higher-threshold or manual-review path.

---

## 3. R4: Pipeline Stall

R4 is the workhorse — 1,143 tenants, ~1.98 PB identified, 65% of all rule-based detection. But **196 tenants are stuck in READONLY for up to 146 days** (~5.8 PB held hostage). Other rules show normal 13–21 day latency. This is a genuine ops issue.

---

## 4. The Feed Gap

The DS Model (RC107) found 720 tenants — **97.8% net-new** (704 that rules never caught). We assumed this was a threshold problem. NR-1 disproved it:

| Storage Bucket | RC107 Tenants | Fed to Rule Pipeline | Matched a Rule |
|----------------|--------------|---------------------|---------------|
| 1–10 TB | 274 | 0 | 0 |
| 10–20 TB | 228 | 9 | **9** |
| 20 TB+ | 89 | 5 | **5** |

**578 of 592 E5 Dev tenants were never sent to the rule engine.** The 14 that were had a 100% match rate. Rules work when they get data — the upstream system that populates `DetectionAutomationRulesData` is the bottleneck.

Even with a fixed feed, 274 tenants at 1–10 TB sit below all current thresholds and would need new rule coverage.

### 4.1 Pipeline Architecture (Code Trace)

FAB is a **read-only consumer** of rule results. Full pipeline:

```
External System (black box)
    │  evaluates R1–R5 against SPO telemetry
    ▼
[FRAUD].[DetectionAutomationRulesData]          ← written by external system
    │  SiteSubscriptionId, RuleMask, PatternMask,
    │  TotalStorageGB, RunDate, CreatedDate, TenantLevel
    ▼
DetectionRemediationServiceImpl.ProcessDetectionRemediationAsync()
    │  Step 1: SELECT DISTINCT TOP(@batchSize) FROM DetectionAutomationRulesData
    │          LEFT JOIN FRAUD_TENANT_DETAILS WHERE details IS NULL
    │          (GetFetchDetectionRulesCommand — SQLQueries.cs:175)
    │  Step 2: Enrich from Kusto (OdspFabKusto cluster)
    │  Step 3: Filter out ISS500/ISS2200 exclusions
    │  Step 4: Ingest into FRAUD_TENANT_DETAILS with RC96
    ▼
Remediation Pipeline (notification → READONLY → BLOCK → DELETE)
```

**Key code findings:**

1. **FAB only reads one column.** The C# model (`DetectionAutomationRulesData.cs`) exposes only `SiteSubscriptionId`. The table has 7 columns (`RuleMask`, `PatternMask`, `TotalStorageGB`, `RunDate`, `CreatedDate`, `TenantLevel`) — FAB ignores all of them except the ID.

2. **No feedback loop.** `GetFetchDetectionRulesCommand` uses `LEFT JOIN ... WHERE details IS NULL` to skip already-ingested SSIDs. There's no `STATUS` or `PROCESSED_DATE` on the table. The external system has no way to know what FAB did with its results.

3. **Validation blocker for manual remediation.** `CheckValidationBySSIDQuery` (KQLQueries.cs) requires `HAS_EVER_PAID = TRUE` for E3/E5 Dev SKUs before allowing manual ingestion. Never-paid E3/E5 Dev tenants can ONLY enter FAB via RC96 (Detection Automation) or RC107 (DS Model) — manual RC68 is blocked.

4. **Snapshot tables exist.** `DetectionAutomationRulesData_1Dec2025` and `DetectionAutomationRulesData_27122025` suggest the external system does periodic full dumps. Comparing snapshots could reveal feed cadence and drift.

### 4.2 Why This Matters

The feed gap is not a single failure — it creates a **triple blocker** for E5 Dev tenants like `c00ee7f8`:

| Layer | What Fails | Why |
|-------|-----------|-----|
| Rule Engine Feed | External system never sends the SSID | Black box — FAB can't control scan scope |
| Storage Threshold | 0 TB used, below all rule minimums (10–20 TB) | Rules are storage-only; hoarding/staging is invisible |
| Manual Remediation | `CheckValidationBySSIDQuery` rejects never-paid E3/E5 Dev | Code-level block on the only fallback path |

The combination means **a never-paid E5 Dev tenant with 0 TB storage has zero paths into the enforcement pipeline** unless the DS Model (RC107) catches it separately.

### 4.3 Deep-Dive Queries

Run the queries in [`docs/rulecheck/DD-feed-gap.sql`](rulecheck/DD-feed-gap.sql) to quantify the full extent. Key questions:

| Query | Question |
|-------|----------|
| DD-1 | How many FAB tenants (all reason codes) are missing from DetectionAutomationRulesData? |
| DD-2 | What does the feed timeline look like? (RunDate/CreatedDate distribution) |
| DD-3 | Which SKUs are most underserved by the feed? |
| DD-4 | How many unfed tenants would match R3/R4 thresholds right now? |
| DD-5 | What's the RuleMask distribution — which rules actually fire? |
| DD-6 | How did the feed change between Dec 2025 snapshots and today? |

---

## 5. SKU Blind Spots

Rules cover 3 SKU families. Multiple high-storage SKUs have zero coverage:

| Uncovered SKU | Tenants in FAB | Avg TB/Tenant | Total (PB) |
|---------------|---------------|-------------|-----------|
| SharePoint Plan 2 | 40 | **255** | 10.2 |
| F1 Kiosk | 29 | **206** | 6.0 |
| OneDrive Plan 2 | 48 | **162** | 7.8 |
| Business Basic Free | 40 | 40 | 1.6 |
| A5 | 246 | 28 | 6.8 |

These are the highest per-tenant storage concentrations in the fraud database, and no rule will ever see them. INV-014 confirmed F1 as a cheap abuse vector — the NL Ring ran 1.36 PB on ~$22.50/month in F1 licenses.

---

## 6. The A1 Gap: 85K Unreachable Tenants

85,231 A1 free tenants are in FAB but invisible to rules. **89.6% have zero SPO storage** — they're abusing A1 for Teams, Exchange, credential farming, or license hoarding. No storage rule can reach them.

We tested a low-threshold A1 rule (never-paid + onmicrosoft-only + MAU <5 + Storage >1 TB). After all filters: **only 31 net-new actionable.** Not viable.

The A1 gap requires non-storage signals — provisioning velocity (91 admin emails validated with 5+ tenants across 3+ countries), behavioral analytics, or identity clustering.

---

## 7. Other Findings

**No backfill at rule launch.** Confirmed misses: FAMILIA CONFEITAR (30 tenants, 1.9 PB), E5 Dev 4-char ring (31 tenants, ~97 TB each). Both predated their matching rules.

**Lagging indicator.** Only 5.2% of caught tenants are under 1 year old. Rules require 10–20 TB, so they structurally catch old fraud.

**Silent decay.** R2 collapsed 93% from peak (430 → 2/month) and R3 declined 87% with zero alerting. No per-rule monitoring exists.

**Geographic shift.** CN+SG = 49% of DS Model catches vs US-heavy in existing rules. Fraud is migrating to APAC.

**R3/R4 are complementary**, not redundant — only 102 tenants overlap. R3 uses egress to catch 10–20 TB; R4 catches 20 TB+ without egress.

---

## 8. Recommendations

### Fix Existing Rules (config changes, do now)

| # | Action | Impact |
|---|--------|--------|
| 1 | **Add `hasInitialDomainOnly=TRUE` to R3** | FP: 8.89% → ~2% |
| 2 | **Unblock R4's 196 stalled READONLY tenants** | Recovers ~5.8 PB stuck 146 days |
| 3 | **Retire R1** | Dead rule, free the slot |
| 4 | **Add per-rule KPI monitoring + decay alerts** | No more silent collapses |
| 5 | **Run R5 backfill** on pre-launch tenants | ~30 missed tenants, 1.9 PB |

### Expand Coverage (validated, config-level)

| # | Action | Expected Catch |
|---|--------|---------------|
| 6 | **Fix upstream feed** so RC107-class tenants reach the rule engine (see §4.1–4.3, run DD queries) | ~578 E5 Dev tenants, avg 22 TB |
| 6a | **Move rule evaluation into FAB** — own the logic, eliminate black-box dependency | Full feed control, threshold tuning, A/B testing |
| 7 | **Expand R5 SKU scope** to SPO Plan 1/2, ODB Plan 2, F1, Biz Basic Free | 65+ tenants, avg 44–255 TB |
| 8 | **CDN Score as post-READONLY escalation** — auto-Block if egress persists 48h | Closes "READONLY doesn't stop egress" gap |

### New Signals (requires infrastructure)

| Priority | Signal | Why |
|----------|--------|-----|
| **P0** | **Provisioning velocity** — 5+ tenants per admin email, 3+ countries | Only signal for the 84K A1 gap. 91 emails validated. |
| P1 | **rclone compound** — rclone + <5 users + >10 TB + never-paid | 10.5K tenants, 100% <5 users. Needs FAB overlap check. |
| P2 | **APAC-adapted thresholds** for CN/SG | Fraud migrating. CN+SG = 49% of DS Model catches. |

### Killed

| Signal | Reason |
|--------|--------|
| Low-threshold A1 rule | Only 31 net-new after filters |
| Shared phone clusters | 957K matches — noise |
| Storage growth rate | Compound threshold catches zero |
| CDN Score for initial detection | 34/35 already in FAB |

---

## Appendix: Query Index

30+ queries against production systems. All raw results in `docs/rulecheck/`.

| Queries | What they cover |
|---------|----------------|
| S1–S12 | Rule scorecard, overlap, trends, stalls, attribution, geo, profiles |
| R3-A/B/C | R3 FP root cause (custom domain) |
| A1-A/B/C/D | A1 coverage gap |
| DS-A/B/C/D | DS Model (RC107) benchmark |
| NR-1 | Feed gap validation |
| NR-2 | Low-threshold A1 rule viability |
| K1, K2, K5 | SpoProd: app fingerprints, CDN score, storage growth |
| D1, D3 | D2K: provisioning velocity, shared phones |

---

*Data verified April 15–20, 2026 via direct SQL and Kusto queries.*
