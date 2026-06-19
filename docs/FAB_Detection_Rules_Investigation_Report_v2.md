# FAB Detection Rules: Effectiveness & Gap Analysis

**Date**: April 20, 2026 | **Author**: Varun V  
**Period**: October 2025 – April 2026 (all-time since rule onboarding)  
**Data Sources**: `FAB_DAR_DB` (SQL), `SpoProd` (Kusto), `D2KRedacted` (Kusto), MCP tenant lookups

---

## Executive Summary

FAB's Detection Automation pipeline has flagged **141,975 fraud tenants** and reclaimed over **3 PB** of abused SPO storage since October 2025. Five deterministic rules (R1–R5) and an AI-Agent model (R0) together account for 91,672 tenants under Reason Code 96.

This investigation stress-tested every rule with production data, identified root causes behind failure modes, validated six proposed net-new rule signals against live telemetry, and benchmarked rule coverage against the newly onboarded DS Model (RC107).

### The Three Big Stories

**1. The rules work — but they have a ceiling.** R2–R5 are actively catching fraud with acceptable FP rates. However, rules are purely storage+egress-based and only cover 3 SKUs (E5 Dev, E3 Dev, A1). 85,231 known-fraud A1 tenants sit outside all rules — 89.6% have *zero* storage, making them structurally invisible to any storage-based detection.

**2. The biggest FP problem has a simple fix.** R3's 8.89% false-positive rate traces to a single root cause: **82% of its FPs own custom domains** (vs. 36% of TPs). Adding a domain filter would cut FP to ~2% overnight.

**3. The DS Model catches what rules can't — and shows us where thresholds need adjustment.** RC107's 720 detections are 97.8% net-new. The 592 E5 Dev tenants it found (avg 17 TB each) sit in the 10–20 TB zone that falls between R3's 10 TB floor and R4's 20 TB floor — a blind spot rules created by design.

### Verdict by Rule

| Rule | Verdict | One-Line Rationale |
|------|---------|-------------------|
| R1 – Chia Mining | **RETIRE** | Dead since Dec 2025. 22 all-time catches. Crypto mining trend passed. |
| R2 – Streaming | **HEALTHY** | 97.6% remediation, 1.74% FP. Cleanest rule. Slowing organically. |
| R3 – Storage+Egress+MAU | **FIX FP** | 8.89% FP is unacceptable. Root cause identified. Easy fix available. |
| R4 – Storage/MAU | **FIX PIPELINE** | Workhorse rule at ~2 PB reclaimed. But 196 tenants stuck for 146 days. |
| R5 – Fraud in SMB | **EXPAND** | Only 72 catches — not because it's wrong, but because SKU scope is too narrow. |
| R0 – AI Agent | **MONITOR** | 44,669 tenants. 0.13% FP. Bulk held by design at pre-READONLY. |

---

## Part I: Current Rule Assessment

### 1. Rule Definitions

| Rule | Signal Logic | SKU Scope | Onboarded |
|------|-------------|-----------|-----------|
| **R1** – Chia Mining | FileType = "Crypto Mining" AND FileSize > 100 GB AND MAU < 10 | E5 Dev, E3 Dev, A1 | Jul 2025 |
| **R2** – Streaming | FileType = "Video" AND Storage > 20 TB AND Egress > P99 (~45 GB) | E5 Dev, E3 Dev, E5 Dev Free | Aug 2025 |
| **R3** – Storage+Egress+MAU | MAU < 5 AND Storage > 10 TB AND Egress > P999 (~90 GB) | E5 Dev, E3 Dev, A1 | Sep 2025 |
| **R4** – Storage/MAU | MAU < 5 AND Storage > 20 TB | E5 Dev, E3 Dev, A1 | Oct 2025 |
| **R5** – Fraud in SMB | MAU < 3 AND PaidLicenses < 3 AND Storage > 20 TB | Business Basic, Standard, Premium | Nov 2025 |
| **R0** – AI Agent | ML model (separate signal, mask=0) | Various | Nov 2025 |

**How it works**: An external system evaluates rules and writes SSIDs + RuleMask into `DetectionAutomationRulesData`. FAB reads, enriches from Kusto, filters ISS500/ISS2200, and ingests with RC96 into the `ABUSE-READONLY-BLOCK-DELETE_15DAYS` pipeline.

### 2. All-Time Performance Scorecard

| Rule | Tenants | Storage Reclaimed | FP Rate | Remediation Rate | Status |
|------|---------|------------------|---------|-----------------|--------|
| R0 – AI Agent | 44,669 | 10 TB | 0.13% | 50.8% | Active (held by design) |
| R4 – Storage/MAU | 1,143 | **1,981 PB** | 4.68% | 75.6% | Active — pipeline stall |
| R3 – Storage+Egress+MAU | 1,130 | 163 PB | **8.89%** | 89.6% | Active — FP problem |
| R2 – Streaming | 620 | 561 PB | 1.74% | **97.6%** | Active — slowing |
| R5 – Fraud in SMB | 72 | 290 PB | 3.17% | 67.5% | Active — scope limited |
| R1 – Chia Mining | 22 | 40 PB | 0% | 68.2% | **Dead since Dec 2025** |

**Key insight — R4 is the workhorse**: Despite catching only 1,143 tenants, R4 accounts for ~1.98 PB of storage reclamation — **65% of total rule-based reclamation**. Its 20 TB threshold catches the heaviest abusers. But its 4.68% FP rate and 196-tenant pipeline stall need attention.

**R2 is the cleanest rule**: Lowest FP (1.74%), highest remediation rate (97.6%), tight signal (video file type + egress). The model for how a well-designed rule should perform.

### 3. Rule Overlap — Are Any Rules Redundant?

| Combination | Tenants |
|-------------|---------|
| R4 only | 1,214 |
| R3 only | 1,081 |
| R2 only | 604 |
| R3 + R4 overlap | 102 |
| R2 + R3 + R4 overlap | 132 |
| R5 only | 73 |
| R1 only | 23 |

**No.** R3 and R4 look structurally similar (both use MAU < 5 + storage thresholds) but overlap by only **102 tenants**. R3 catches the 10–20 TB tier using egress as a qualifying signal; R4 catches the 20 TB+ tier without requiring egress. They're complementary — R3 fishes with a finer net, R4 catches the whales.

### 4. Monthly Trends — What's Alive, What's Dying

| Month | R1 | R2 | R3 | R4 | R5 |
|-------|-----|-----|-----|-----|-----|
| Nov 2025 | 10 | 430 | 310 | 524 | — |
| Dec 2025 | **12** | 102 | 460 | 198 | 52 |
| Jan 2026 | — | 22 | 114 | 42 | 8 |
| Feb 2026 | — | 23 | 161 | 85 | 7 |
| Mar 2026 | — | 40 | 67 | 262 | 4 |
| Apr 2026 | — | 2 | 18 | 32 | 1 |

Three signals in this data:

1. **R1 is extinct.** Zero detections for 4 consecutive months. Chia mining was a transient crypto-boom artifact — the attack vector no longer exists at scale. Retire it.

2. **R4 had a March surge** (262 detections) after declining Jan-Feb. This suggests a new wave of storage-heavy fraud, not a one-time blip. R4 remains essential.

3. **R2 is approaching asymptote.** From 430/month at onboarding to 2 in April. Either streaming abuse is saturated (we caught them all) or attackers adapted. Watch for rebound, but don't rely on this rule for future volume.

### 5. Pipeline Health — Where Tenants Get Stuck

| Rule | Stuck at READONLY | Oldest | Days Stalled |
|------|-------------------|--------|-------------|
| R0 | 11,488 | Mar 24 | 27 | **By design** — AI Agent batch deliberately held |
| **R4** | **196** | **Nov 25** | **146** | **Real stall. Needs investigation.** |
| R3 | 29 | Mar 30 | 21 | Normal latency |
| R2 | 17 | Mar 30 | 21 | Normal latency |
| R5 | 12 | Apr 7 | 13 | Normal latency |

R4's 196 stalled tenants are a genuine operational issue. These tenants have been in READONLY since November 2025 without progressing to Block/Delete. At R4's average of 29.5 TB per tenant, that's an estimated **~5.8 PB of storage still held hostage** by stalled remediation.

---

## Part II: Deep-Dive Investigations

### 6. R3's False Positive Problem — Root Cause Found

R3's 8.89% FP rate is 5x higher than R2 and nearly 2x R4. We profiled all 1,131 FPs against 10,139 TPs.

**The smoking gun is custom domain ownership:**

| Signal | True Positives | False Positives | Discrimination |
|--------|---------------|----------------|---------------|
| Custom domain | 36.4% | **82.0%** | **2.25x overrepresented in FP** |
| Onmicrosoft-only | 63.5% | 17.9% | 3.5x overrepresented in TP |
| Never paid | 98.4% | 99.2% | No discrimination |
| A1 SKU | 13.7% | 44.0% | 3.2x overrepresented in FP |

**Why this makes sense**: Tenants with custom domains — especially A1 (education) and E5 Dev trial — are more likely to be legitimate organizations that happen to have high storage + egress. A school streaming lectures, a developer running CI/CD — these are real workloads that trigger R3's thresholds.

**FP by SKU & Geography**: US accounts for 39% of all R3 FPs (245 A1 + 193 E5 Dev). Hong Kong A1 adds another 102.

**The fix**: Add `hasInitialDomainOnly = TRUE` to R3. Impact:
- FP drops from 8.89% → **~2%** (eliminates ~920 of 1,131 FPs)
- TP loss: ~36% of current TPs have custom domains and would no longer auto-detect
- **Mitigation**: Route custom-domain matches to a separate higher-threshold rule (e.g., same conditions but Storage > 25 TB) or a manual review queue

### 7. The A1 Free Tenant Gap — 85K Tenants Rules Can't Reach

85,231 A1 free tenants are in FAB's fraud database (identified by other methods) but invisible to R1–R5. This is the single largest coverage gap.

**The uncomfortable truth**: 89.6% of these tenants have **literally zero SPO storage**. They're not using SharePoint for file abuse — they're abusing A1 licenses for other purposes (Teams, Exchange, credential farming, or pure license hoarding).

**Storage distribution of 85K uncaught A1 tenants:**

| Bucket | Tenants | % |
|--------|---------|---|
| Zero storage | 76,121 | 89.6% |
| 0 – 1 TB | ~3,900 | 4.6% |
| 1 – 10 TB | ~3,100 | 3.6% |
| 10 TB+ | ~2,200 | 2.6% |

**What separates the ones rules DO catch from the ones they DON'T (A1-C):**

| | Missed (85,335) | Caught (8,169) |
|--|----------------|----------------|
| Avg storage | **5 GB** | **48 GB** |
| Ever paid | 6.0% | 94.7% |
| Onmicrosoft-only | 49.7% | 17.6% |
| Storage > 1 TB | 1.1% | 61.3% |

The caught ones are 10x denser on storage and 15x more likely to have ever paid. Rules are biased toward tenants with payment history and storage footprint — by design, since they're storage-based rules.

**What we can do:**
- **Reachable**: ~945 A1 tenants have > 1 TB storage. A new low-threshold A1 rule (A1 + never-paid + onmicrosoft-only + MAU < 5 + Storage > 1 TB) could catch these.
- **Unreachable by storage rules**: ~84,000 tenants. These require entirely different signals — see Proposed Rule 2 (Provisioning Velocity) in Part III.

**Geographic insight**: US alone = 56,947 tenants (67% of the gap). But HK is disproportionate — 6,006 tenants with 119 TB of storage, meaning HK A1 tenants are actually storage-heavy and potentially catchable with lower thresholds.

### 8. DS Model (RC107) — Proof That Rules Have Blind Spots

The DS Model was onboarded in April 2026 with 720 detections. We used it as a benchmark: *what does ML find that deterministic rules miss?*

**The answer: almost everything it finds is net-new.**

| Category | Tenants | Avg Storage (TB) |
|----------|---------|-----------------|
| Also caught by R1–R5 | 16 | 20 |
| **Net-new (RC107 only)** | **704** | **22** |

**97.8% net-new catch rate.** The DS Model isn't duplicating rule work — it's finding a fundamentally different population.

**What RC107 catches by SKU — revealing the uncovered attack surface:**

| SKU | Tenants | Avg Storage (TB) | Covered by Rules? |
|-----|---------|-----------------|-------------------|
| E5 Developer | 592 | 17 | Partially (R3/R4 miss these) |
| Business Basic | 38 | **58** | R5 should catch — threshold/scope issue |
| SharePoint Plan 2 | 15 | **113** | **No rule covers this SKU** |
| SharePoint Plan 1 | 8 | 37 | **No rule covers this SKU** |
| Business Basic Free | 6 | 94 | **No rule covers this SKU** |
| OneDrive Plan 2 | 2 | 71 | **No rule covers this SKU** |
| Business Standard | 2 | **170** | R5 should catch — threshold issue |

**Three insights from this data:**

1. **The 10–20 TB blind spot**: 592 E5 Dev tenants avg 17 TB each, yet R3 (needs > 10 TB + egress > P999) and R4 (needs > 20 TB) both miss them. Most likely evasion: MAU ≥ 5 (defeating both rules' MAU < 5 filter) or insufficient egress for R3. These tenants are gaming MAU thresholds — adding a few bot users to push past the MAU < 5 gate.

2. **SKU blind spots are real and expensive**: SharePoint Plan 2 tenants average **113 TB** each, Business Standard averages **170 TB** — and no rule covers these SKUs. That's concentrated, high-storage fraud completely outside the rule perimeter.

3. **Geographic shift**: CN (187) and SG (168) account for 49% of RC107 detections. R1–R5 historically are US-dominated. Fraud is migrating to APAC, and rules haven't adapted.

---

## Part III: Proposed New Rules & Rule Expansions

We validated six proposed net-new detection signals against production data from SpoProd Kusto, D2K Kusto, and FAB_DAR_DB. Each proposal was tested against the principle: **does it catch tenants that current detection doesn't?**

### Proposal 1: CDN Score (Egress:Ingress Ratio)

**Concept**: Flag tenants with extreme egress:ingress ratios (> 100:1) on SPO — indicating CDN-like abuse (content uploaded once, served millions of times).

**Validation (SpoProd K2/K2a/K2b)**:
- Found a 26-tenant coordinated ring doing **~1.53 PB/week** egress — all zero ingress, all 1 unique user
- However: all 26 turned out to be **INV-014 (FAMILIA CONFEITAR)** — already READONLY since April 8
- Extended to top 35 tenants: 28 FAMILIA CONFEITAR + 5 other known fraud + 1 overquota + 1 legitimate FP
- **34 of 35 already in FAB**

**Verdict: NOT NET-NEW for initial detection.** The CDN Score rule correctly identifies abuse but catches nothing that current detection hasn't already flagged. However, it has value as a **post-remediation monitor** — the FAMILIA CONFEITAR ring was still serving 1.53 PB/week 11 days after READONLY, proving READONLY doesn't stop egress abuse. Recommend using CDN Score as an auto-escalation trigger (if egress persists 48h post-READONLY → escalate to Block).

### Proposal 2: Provisioning Velocity (Multi-Tenant Admin Emails)

**Concept**: Flag admin emails that provision 5+ tenants across 3+ countries in 180 days.

**Validation (D2K D1)**:
- **91 emails** met the compound threshold (5+ tenants AND 3+ countries)
- These emails collectively control thousands of tenants
- Strong signal for fraud ring detection

**Verdict: PROMISING — but requires cross-referencing with FAB to confirm net-new value.** Provisioning velocity is one of the few non-storage signals that could address the 84K-tenant A1 gap (Section 7). Not yet validated against FAB's existing coverage for overlap; needs a follow-up query joining D2K results to FAB_DAR_DB.

### Proposal 3: Shared Phone Number Clusters

**Concept**: Flag phone numbers shared across 3+ tenants as fraud ring indicators.

**Validation (D2K D3)**:
- **957,000+ phone numbers** shared across 3+ tenants

**Verdict: KILLED — too noisy.** Nearly a million shared phone numbers is not a usable signal without extreme compound filtering. Shared phones are common for legitimate reasons (corporate provisioning, call centers, MSPs). The false positive surface is too large.

### Proposal 4: Storage Growth Rate (Rapid Writers)

**Concept**: Flag tenants writing > 1 TB/week as rapid data hoarders.

**Validation (SpoProd K5/K5a)**:
- At the > 1 TB/week threshold: **18,215 tenants** — too broad
- Adding compound filter (> 1 TB write + Storage > 10 TB + MAU < 5): **zero tenants**

**Verdict: KILLED — threshold intersection is empty.** The tenants writing > 1 TB/week are either legitimate (avg 22.7 users) or already caught by existing rules. The compound threshold that would make this precise catches nothing new.

### Proposal 5: Suspicious App Fingerprints (rclone, androiddownloadmanager)

**Concept**: Flag tenants using known file-sync/exfiltration tools with low user counts.

**Validation (SpoProd K1/S4)**:
- **rclone**: 10,515 tenants, 100% under 5 users — strong signal
- **androiddownloadmanager**: 11,736 tenants, 24 TB egress, zero ingress
- **Synology NAS**: 39,582 tenants — too common, likely legitimate NAS backups
- rclone compound (> 100 GB egress + < 5 users) was not validated against FAB overlap

**Verdict: DEFERRED — rclone is promising but needs net-new validation.** The rclone signal is tight (100% under 5 users, mix of read/write activity suggesting file sync abuse). However, we didn't confirm what % are already caught by R3/R4 via their storage footprint. A cross-reference query against FAB is needed. androiddownloadmanager is likely downstream of CDN abuse already covered.

### Proposal 6: Gibberish / Short Tenant Names

**Concept**: Flag tenants with company names ≤ 4 characters and high storage as likely auto-provisioned fraud.

**Validation (D2K D4)**: Designed but not yet executed at scale.

**Verdict: UNTESTED — low confidence.** Short names alone are a weak signal — many legitimate small businesses and test tenants have 3-4 character names. Would need aggressive compound filtering (short name + never-paid + > 10 TB + MAU < 5) to be viable.

### Summary: Proposed Rule Scorecard

| Proposal | Signal | Verdict | Net-New? | Action |
|----------|--------|---------|----------|--------|
| CDN Score | Egress:Ingress > 100:1 | Validated for monitoring | No — catches existing | Use as post-READONLY escalation trigger |
| Provisioning Velocity | 5+ tenants/email, 3+ countries | Promising | Likely yes — addresses A1 gap | Cross-ref with FAB, then pilot |
| Shared Phones | 3+ tenants per phone | Killed | N/A | Too noisy (957K matches) |
| Storage Growth Rate | > 1 TB/week write | Killed | N/A | Compound threshold is empty |
| App Fingerprints (rclone) | rclone + < 5 users | Deferred | Unknown | Cross-ref with FAB for overlap |
| Gibberish Names | Name ≤ 4 chars + high storage | Untested | Unknown | Needs D2K validation |

---

## Part IV: Structural Findings & Cross-Cutting Insights

### 9. The Detection Landscape — Who Catches What

| Method | Tenants | Storage (TB) | Avg TB/Tenant | FPs |
|--------|---------|-------------|--------------|-----|
| R1–R5 Rules (RC96) | 47,003 | 3,045,314 | **65** | 3,620 |
| R0 AI Agent (RC96) | 83,243 | 572,425 | 7 | 1,032 |
| DS Model (RC107) | 720 | 16,707 | 22 | 0 |
| Other RCs (manual/legacy) | ~12,000 | ~250,000 | ~21 | — |
| **Total** | **141,975** | | | |

The story these numbers tell: **Rules are precision tools, R0 is a dragnet, and the DS Model finds what both miss.**
- R1–R5 catch only 33% of fraud tenants by count but **~80% by storage** — they target the biggest abusers.
- R0 catches 59% by count at low storage density — it's sweeping up volume.
- RC107 at only 720 tenants is small, but 97.8% net-new signals that rules have genuine blind spots.

### 10. Fraud Outside All Rules — Where the Uncovered Storage Lives

Tenants in FAB from non-rule detection methods, by SKU:

| SKU | Never Paid | Tenants | Storage (TB) | Rules Cover This SKU? |
|-----|-----------|---------|-------------|----------------------|
| A1 | Yes | 85,231 | 452,424 | R3/R4 (but thresholds too high) |
| E5 Dev | Yes | 2,460 | 59,616 | R2/R3/R4 (caught elsewhere) |
| E3 Dev Free | Yes | 2,388 | 20,988 | R3/R4 |
| A5 | Yes | 246 | 6,783 | **No** |
| SharePoint P2 | Yes | 40 | **10,198** | **No** |
| ODB P2 | Yes | 48 | **7,793** | **No** |
| Business Basic | Yes | 153 | 9,535 | R5 (partially) |
| F1 | Yes | 29 | 5,979 | **No** |

**Three SKU gaps stand out:**
1. **SharePoint Plan 2**: 40 tenants, 10.2 PB — no rule covers this. Avg 255 TB/tenant.
2. **ODB Plan 2**: 48 tenants, 7.8 PB — no rule covers this. Avg 162 TB/tenant.
3. **A5**: 246 tenants — a premium SKU with no rule coverage.

### 11. Geographic Signatures by Rule

| Rule | #1 Country | #2 Country | #3 Country | Pattern |
|------|-----------|-----------|-----------|---------|
| R1 | VN (532) | CN (288) | JP (247) | Asia-Pacific crypto mining |
| R2 | SG (3,834) | US (3,652) | CN (3,097) | Distributed, SG-heavy |
| R3 | CN (1,938) | US (1,528) | SG (1,448) | China-first |
| R4 | US (11,925) | CN (8,392) | SG (5,549) | US-dominant |
| RC107 | CN (187) | SG (168) | US (76) | **APAC shift** |

RC107's geographic profile is notable: CN + SG = 49% of detections, while rules historically skew US. This suggests **fraud patterns are migrating to APAC** and rules (especially R4, which is 23% US) may need geographic-aware threshold adjustments.

### 12. Payment & Identity Profile by Rule

| Rule | Never Paid % | Onmicrosoft-Only % | Avg Storage/Tenant |
|------|-------------|-------------------|-------------------|
| R1 | 85.2% | 55.9% | 749 GB |
| R2 | 97.7% | 65.2% | 5.1 TB |
| R3 | 98.7% | 58.8% | 3.6 TB |
| R4 | 95.7% | 42.4% | **29.5 TB** |
| R5 | **10.2%** | 57.5% | 1.9 TB |

**R5 is the outlier**: 90% of R5 tenants have payment history — SMB fraud operates differently from dev/trial fraud. These are tenants that paid for Business Basic/Standard/Premium and then abused storage. This changes the FP risk profile: paid tenants are harder to auto-remediate and more likely to escalate.

**R4 catches the heaviest hitters**: 29.5 TB average, with 42.4% onmicrosoft-only. The 57.6% with custom domains are likely organized operations that registered proper domains to appear legitimate.

---

## Part V: Recommendations

### Tier 1 — Immediate (Config Changes, No New Code)

| # | Action | Impact | Effort |
|---|--------|--------|--------|
| 1 | **Add `hasInitialDomainOnly=TRUE` filter to R3** | FP: 8.89% → ~2%. Saves ~920 false positives. | Config change |
| 2 | **Retire R1 (Chia Mining)** | Removes dead rule. Zero detection loss. | Config change |
| 3 | **Unblock R4's 196 stalled READONLY tenants** | Recovers ~5.8 PB stuck for up to 146 days. | Ops investigation |

### Tier 2 — New Rules & Expansions (Validated by Data)

| # | Action | Expected Catch | Data Basis |
|---|--------|---------------|-----------|
| 4 | **New A1 low-threshold rule**: A1 + never-paid + onmicrosoft-only + MAU < 5 + Storage > 1 TB | ~945 tenants | A1-C: 945 tenants > 1 TB missed by all rules |
| 5 | **Expand R5 SKU scope** to SharePoint Plan 1/2, OneDrive Plan 2, Business Basic Free | 65+ tenants at avg 44–170 TB | DS-B + S4: high-storage fraud on uncovered SKUs |
| 6 | **Close the 10–20 TB blind spot**: Either lower R4 to 15 TB or relax R3's egress threshold for onmicrosoft-only tenants | ~592 E5 Dev tenants (avg 17 TB) | DS-C: RC107 net-new population |
| 7 | **CDN Score as post-READONLY escalation trigger**: If egress > 100 GB persists 48h after READONLY → auto-escalate to Block | Closes remediation gap | INV-014: 1.53 PB/week egress continued 11 days post-READONLY |

### Tier 3 — Strategic (Requires New Signals or Infrastructure)

| # | Action | Rationale |
|---|--------|-----------|
| 8 | **Provisioning velocity detection**: 5+ tenants per admin email across 3+ countries | Addresses the 84K A1 zero-storage gap (non-SPO abuse). 91 emails validated in D2K. |
| 9 | **Cross-FAB rclone validation**: Join SpoProd rclone tenants (10.5K) against FAB to measure net-new overlap | rclone is a tight signal (100% < 5 users) but needs overlap check before rule creation |
| 10 | **Geographic-aware thresholds**: Consider lower thresholds for CN/SG where RC107 is catching net-new at 17 TB avg | Fraud migrating to APAC. CN+SG = 49% of DS Model catches vs. US-heavy in rules. |

### Deprioritized (Validated and Rejected)

| Signal | Why Not |
|--------|---------|
| Shared phone clusters | 957K matches — signal is pure noise without extreme filtering |
| Storage growth rate (rapid writers) | Compound threshold with MAU/storage catches zero tenants |
| CDN Score for initial detection | 34/35 top tenants already in FAB — adds zero net-new to initial catch |
| Gibberish tenant names | Untested at scale; weak expected discrimination power |

---

## Appendix A: Data Sources

All SQL queries ran against `FAB_DAR_DB`. Kusto queries ran against `SpoProd` and `D2KRedacted`. Results saved to `docs/rulecheck/`.

| Query | Description | Section |
|-------|-------------|---------|
| S1 | Per-rule effectiveness (all-time) | §2 |
| S2 | Rule overlap (bitmask combinations) | §3 |
| S3 | Monthly detection trends | §4 |
| S4 | Fraud outside rules by SKU | §10 |
| S5 | Fraud outside rules by RC & use case | §10 |
| S6 | Pipeline stalls (stuck at status) | §5 |
| S7 | Avg storage per remediated tenant | §12 |
| S8 | Remediation status distribution | §9 |
| S9 | Payment & domain profile per rule | §12 |
| S10 | Total fraud landscape | §9 |
| S11 | Geographic distribution per rule | §11 |
| S12 | Detection attribution by method | §9 |
| R3-A/B/C | R3 FP root cause analysis | §6 |
| A1-A/B/C/D | A1 coverage gap analysis | §7 |
| DS-A/B/C/D | DS Model (RC107) gap analysis | §8 |
| K1 | App fingerprint prevalence (SpoProd) | Proposal 5 |
| K2/K2a/K2b | CDN Score validation (SpoProd) | Proposal 1 |
| K5/K5a | Storage growth rate (SpoProd) | Proposal 4 |
| D1 | Provisioning velocity (D2K) | Proposal 2 |
| D3 | Shared phone clusters (D2K) | Proposal 3 |
