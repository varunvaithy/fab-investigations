# FAB Detection Rules 1–5: Effectiveness Investigation

| Field | Value |
|-------|-------|
| **Author** | Varun V |
| **Date** | April 17, 2026 |
| **Classification** | INTERNAL — Fraud Engineering Review |
| **Related** | [Investigation Tracker](Investigation_Tracker.md), [Fraud Ring Consolidation Report](Fraud_Ring_Consolidation_Report.md) |

---

## 1. Summary

Five automated detection rules have been live since mid-2025. After 6–9 months: **2,393 unique tenants caught, 4.1 PB of abusive storage, 3.59% FP rate.** The thresholds work. The problems are:

1. **SKU restrictions** — Rules only cover developer/education plans. Multi-PB abuse rings on paid commercial SKUs are invisible.
2. **No backfill** — Tenants that accumulated storage before a rule's launch were never evaluated. Confirmed misses: 30 tenants, 1.9 PB.
3. **Tenant age bias** — Only 5.2% of caught tenants are under 1 year old. The rules are a lagging indicator, not early warning.
4. **Silent decay** — No monitoring. Rule 2 collapsed 93% and Rule 3 declined 87% without anyone noticing.

The single highest-impact fix: **remove Rule 4's SKU restriction** to surface 7+ PB of known undetected fraud.

---

## 2. Methodology

Production data from `fabdardb` — `DetectionAutomationRulesData` (external flags), `FRAUD_TENANT_DETAILS` / `TENANT_DETAILS_RAW` (FAB actions + tenant metadata). Automation table has ~125K rows inflated by daily rescanning; deduplicated via join to `FRAUD_TENANT_DETAILS` for true counts. Cross-referenced against 200+ manually investigated tenants from Q1 2026.

---

## 3. Where Rules 1–5 Fit

Since July 2025, FAB has identified ~49,100 tenants across all detection channels:

| Source | RC | Tenants | FP | FP Rate |
|--------|-----|---------|-----|---------|
| Detection Automation (Rules) | 96 | 47,031 | 137 | 0.29% |
| DS Model (2026) | 107 | 720 | 0 | 0.00% |
| Adhoc Investigation | 106 | 703 | 0 | 0.00% |
| No reason code (manual) | NULL | 316 | 86 | **27.22%** |
| A1 DS Model (deprecated) | 78 | 210 | 0 | 0.00% |
| Multiplexing | 70 | 54 | 0 | 0.00% |
| Other (E5 Dev, Clusters, etc.) | various | 74 | 1 | 1.35% |

**Detection Automation is 95.8% of modern enforcement.** Within RC 96, the one-time AI agent sweep (Rule 0) accounts for ~44,636; Rules 1–5 contribute 2,393 as continuous detection.

- **Manual enforcement: 27% FP rate** (86/316 tenants). Automation (0.29%) is ~90x more precise.
- **DS Model 2026 (RC 107): 0% FP** — 720 tenants. Replaced the deprecated RC 78 A1 model.

---

## 4. Findings

### 4.1 Rule Performance

| Rule | Unique Tenants | FP Rate | Storage Caught | Trend |
|------|---------------|---------|----------------|-------|
| R4 — Storage/MAU | 875 | 2.06% | 2.8 PB | Stable |
| R3 — Storage+Egress+MAU | 1,051 | 4.95% | 211 TB | Down 87% from peak |
| R2 — Streaming | 375 | 3.20% | 661 TB | Collapsed 93% (Feb 2026) |
| R5 — FraudInSMB | 71 | 5.63% | 340 TB | Low volume |
| R1 — Chia Mining | 21 | 0.00% | 82 TB | Effectively dead |
| **Total** | **2,393** | **3.59%** | **4.1 PB** | |

- **Rule 4 — best rule, needlessly limited.** Simple logic, lowest FP, most storage caught. But restricted to Dev/EDU — four known rings on commercial SKUs match exactly, totaling 7+ PB undetected.
- **Rule 3 — most catches, noisiest.** 4.95% FP; egress threshold (~90 GB) may be too low. Volume down 87% from peak.
- **Rule 2 — collapsed.** ~2,900/month → ~200 in Feb 2026. Cause unclear (threat moved to non-Dev SKUs, or external system change).
- **Rule 5 — confirmed miss.** 30 FAMILIA CONFEITAR tenants match every criterion but weren't in the detection table (no backfill at launch).
- **Rule 1 — dead.** Chia mining threat gone. Zero crypto tenants found across 200+ profiled in Q1 2026.

### 4.2 SKU Blind Spot

**71.8% of detections are E5 Developer SKUs.** F1 Kiosk, SPO Plan 1/2: zero detections. Paid commercial SKUs are cheap enough to exploit:

| Ring | SKU | Monthly Cost | Storage | Cost/PB/Month |
|------|-----|-------------|---------|---------------|
| MISTYCLOUD (11 tenants) | SPO Paid | ~$55 | 3.76 PB | ~$15 |
| NL F1 Ring (10 tenants) | F1 Kiosk | $22.50 | 1.36 PB | ~$17 |
| FAMILIA CONFEITAR (30 tenants) | Biz Basic | $180 | 1.9 PB | ~$95 |

The fraud signal is identical on paid and free plans. Rule 5's 5.63% FP rate (only rule on paid SKUs) suggests paid-SKU expansion should start with dry-run mode.

### 4.3 No Backfill

No rule ran a backfill at launch. Confirmed misses:
- **FAMILIA CONFEITAR** — 30 tenants, 1.9 PB, matching every Rule 5 criterion. Storage accumulated pre-launch.
- **E5 Dev 4-char ring** — 31 tenants (~97 TB each). Predates all rules; 18 of 31 never caught.

### 4.4 Tenant Age: Lagging Indicator

Rules require 10–20 TB to trigger, so they structurally catch old tenants:

| Rule | < 6mo | 6mo–1yr | 1–2yr | 2–5yr | 5yr+ | % under 1yr |
|------|-------|---------|-------|-------|------|-------------|
| R1 — Chia | 0 | 0 | 0 | 7 | 14 | **0%** |
| R2 — Streaming | 18 | 4 | 20 | 268 | 65 | 5.9% |
| R3 — StorageEgress | 55 | 10 | 37 | 759 | 190 | 6.2% |
| R4 — StorageMAU | 14 | 6 | 45 | 416 | 394 | **2.3%** |
| R5 — SMB | 5 | 12 | 12 | 26 | 16 | 23.9% |
| **All R1–R5** | **92** | **32** | **114** | **1,476** | **679** | **5.2%** |

**Only 5.2% under 1 year old. 90% are 2+ years old.** Rule 4 skews oldest (45% are 5+ years). NL F1 Ring ran 30 months undetected; E5 Dev 4-char ring over a year. No rule checks for early-stage signals.

### 4.5 Uncovered Abuse Categories

- **App-based abuse** — SpoProd telemetry (7-day window) shows 10,515 tenants using rclone (4.3 PB traffic/wk), 291 using Cloudreve, 22 using StableBit. Niche tools (Cloudreve, StableBit) are near-100% fraud on investigation; rclone/Synology have massive legitimate use (39K+ Synology tenants) and require compound signals. Mobile media UAs (androiddownloadmanager: 11.7K tenants, stagefright: 999, applecoremedia: 11.5K) show zero ingress — pure consumption, strong CDN signal when combined with volume.
- **Burst provisioning** — Hamter botnet: 3,749 tenants in 12 days. China Burst: 4,498 in 16 days.
- **Multiplexing botnets** — 75K+ tenants from D2K analysis. Outside the per-tenant model.
- **Post-FP recidivism** — tenants resuming abuse after FP clearance. No re-scan exists.

### 4.6 Pipeline and Maintenance

**Pipeline:** 12-hour Quartz job, 3 retries, ECS gates, transactional SQL. 98.6% progression rate. Gaps: no dead-letter queue, no alerting, no external system health monitoring.

**Maintenance:** Zero monitoring. Rule 2's 93% collapse and Rule 3's 87% decline went unnoticed until this investigation. Rule creation is low-effort (external system config, zero FAB code), but no independent threshold tuning or A/B testing.

---

## 5. Assessment

Rules 1–5 are precise but punching well below their weight — 2,393 tenants in 9 months, against a known abuse surface orders of magnitude larger. Three structural issues hold them back:

1. **Scope** — SKU restrictions make 7+ PB of confirmed fraud invisible
2. **Coverage** — No backfill means pre-launch abuse is permanently missed unless manually found
3. **Timing** — Storage-threshold rules can't catch new tenants; 95% of catches are 1+ year old

The automation pipeline is the team's most precise enforcement tool (0.29% FP vs 27% for manual). The investment should go toward expanding what it covers, not questioning whether it works.

---

## 6. Recommendations: Existing Rules

These changes address Rules 1–5 directly — tuning thresholds, expanding scope, and fixing operational gaps.

### Quick Wins

| # | Change | Expected Impact |
|---|--------|----------------|
| 1 | Remove SKU restriction from Rule 4 | ~7+ PB of invisible fraud becomes detectable |
| 2 | Remove SKU restriction from Rule 2 | Catches streaming CDN rings on any SKU |
| 3 | Remove SKU restriction from Rule 3 | Extends egress-based detection to commercial SKUs |
| 4 | Expand Rule 5 to include F1 Kiosk and SPO Plans | Closes the cheapest-SKU blind spot |
| 5 | Run Rule 5 backfill against existing tenants | Catches 30 confirmed missed tenants (1.9 PB) |

### Medium-Term

| # | Change | Expected Impact |
|---|--------|----------------|
| 6 | Raise Rule 3 egress threshold from P999 (~90 GB) | Reduces 4.95% FP rate |
| 7 | Retire Rule 1 (Chia mining threat gone) | Free up a rule slot for a new signal |
| 8 | Build per-rule KPI tracking with degradation alerts | Prevents silent decay (Rule 2/3 collapses) |

---

## 7. Recommendations: Net-New Rules

Existing rules share one model: **storage volume + low activity on specific SKUs.** Across 16 investigations this past month, we've found abuse patterns this model can't see.

**Rule creation process:** Config change in external system (zero FAB code) → dry-run on historical data → validate FP rate → promote to production.

### Tier 1 — Highest Impact (proven signals, large confirmed scale)

| # | Rule | Signal | Evidence | Est. Impact |
|---|------|--------|----------|-------------|
| 1a | **Niche abuse-tool detection** | Cloudreve or StableBit CloudDrive in SpoProd `app` field — any storage level | INV-014: Cloudreve (7 tenants). INV-013: StableBit (9 tenants, all confirmed fraud). K1 validation: only 291 Cloudreve and 22 StableBit tenants globally — small population, near-zero legitimate use on SPO. | **High-precision, low-FP.** Small catch but every hit is fraud. |
| 1b | **CDN consumption UA + volume** | `androiddownloadmanager`, `stagefright`, or `applecoremedia` + egress >100 GB + zero ingress | K1 validation: 24.2K tenants use these UAs, all with **zero ingress** — pure download/streaming. INV-016: stagefright/applecoremedia on CN piracy CDN rings. Volume threshold filters casual mobile users. | Targets piracy CDN consumers. Volume threshold keeps FP low. |
| 1c | **rclone + compound signal** | `rclone` + storage >10 TB + MAU <5 + never paid | INV-014: rclone on 139 DS-flagged tenants (217 TB). INV-015/016: rclone on every piracy CDN ring. **K1 validation: 10,515 rclone tenants globally — too many for a standalone rule.** Must combine with storage/MAU/payment to separate fraud from legitimate backup. | Catches rclone abuse without flagging enterprise backup users. |
| 2 | **Provisioning velocity** | X tenants from Y admin emails within Z days (e.g., 3+ tenants from 1 admin in 30 days) | INV-009: Hamter botnet (3,749 VN tenants from 21 admin accounts in 12 days), China Burst (4,498 CN tenants from 9 emails in 16 days). INV-006: MistyCloud (9 tenants in 76 minutes). INV-005: ACGDB (33 tenants, 1 operator, 5 countries, 3 years). | **8,939 confirmed ring tenants** from INV-009 alone. Catches rings *before* abuse starts — preventive. |
| 3 | **CDN Score (egress:ingress ratio)** | Egress:ingress > 100:1 on any SKU | INV-014: FAMILIA CONFEITAR (30 tenants, 1.9 PB, 1,696 TB/wk egress, zero ingress). INV-014: 35 MEGA-tier tenants (1,889 TB/wk combined). INV-015: 24098c20 CN piracy CDN (2.5 TB/day active upload). INV-016: piracy CDN rings (stagefright/applecoremedia UA). | Near-zero FP. Directly targets piracy CDN — the highest-storage abuse pattern. |
| 4 | **Gibberish / patterned name detection** | High-entropy org names (random 4-char), sequential naming (ACGDB1-N, procode{NNN}), gibberish admin emails | INV-004: E5 Dev 4-char ring (31 tenants, 2.9 PB, names like AWZS/FUQX/KQIU). INV-005: ACGDB ring (33 tenants, 597 TB). INV-007: Procode ring (32 tenants). INV-001: TM9/TM10 (tm[X].site domains). | **3.5 PB confirmed** from E5 Dev + ACGDB rings. Strong correlation between auto-generated names and fraud. |

### Tier 2 — High Impact (strong signal, moderate effort)

| # | Rule | Signal | Evidence | Est. Impact |
|---|------|--------|----------|-------------|
| 5 | **Storage-growth-rate** | >5 TB growth in 7 days on a ≤3-seat tenant | INV-015: 24098c20 adding 2.5 TB/day (135 TB in weeks). INV-006: MistyCloud tenants filled to 340 TB each rapidly. | Addresses the 95% old-tenant gap — catches abuse before it reaches the 20 TB threshold. |
| 6 | **D2K admin email clustering** | Same admin email creating tenants across multiple D2K shards | INV-009: 21 hamter accounts → 3,749 tenants. INV-005: pengyoupy001@gmail.com across 5 countries. INV-016: shared gmail/+852 phone registrations across CN rings. | **8,939+ confirmed tenants** from ring analysis. Enables cross-shard ring detection. |
| 7 | **Brand-impersonation domains** | Custom domains mimicking Microsoft brands (`ms365vip.com`, `msdrive365.com`, `poweramsonline.com`, `tm[X].site`) | INV-010: Quang Trung (443 TB, ms365vip.com storage reselling). INV-007: Procode (poweramsonline.com). INV-016: tm[X].site ring (5 tenants, "Microsoft" naming). INV-003: AZURE FOUNDERS HUB. | Clear intent signal with near-zero FP. Catches commercial reselling operations. |
| 8 | **Registration anomaly scoring** | Shared phone clusters (e.g., 4251001000), fake postal codes (000000), GeminiSignUpUI signup, empty address fields | INV-016: 162 CN abusive tenants with shared registration patterns. INV-001: GeminiSignUpUI signup. INV-011/012: empty address + onmicrosoft-only. | Complements provisioning velocity — catches coordinated registration even when spread across time. |

### Tier 3 — Large Scale, Requires Cross-Team Coordination

| # | Rule | Signal | Evidence | Est. Impact |
|---|------|--------|----------|-------------|
| 9 | **EDU ghost tenant cleanup** | EDU-declined (D2K CompanyTags `edu=declined`) + no VL + zero users + onmicrosoft-only | INV-011: 2,902 high-confidence ghosts, 2.3 PB provisioned, 99.5% precision on 200-sample validation. | Zero actual storage, but removes **2.3 PB of provisioned attack surface**. |
| 10 | **Commercial-EDU mismatch** | Commercial segment + IsEduSegment=true + never paid + zero licenses | INV-012: ~47,800 strict Commercial tenants, ~1 PB provisioned. 0% FP on 100-sample validation. | **47,800 ghost tenants**. Zero storage but massive cleanup. Needs EDU team coordination. |
| 11 | **Multiplexing / dormant ring detection** | Patterned naming + zero-license + dormant tenants pre-positioned for coordinated activation | INV-007: Procode (32 tenants, 21 months dormant, zero disk). INV-009: D2K analysis (75K+ suspect tenants). | Catches pre-positioned rings before they activate. Hard to quantify storage until activation. |
| 12 | **Move rule evaluation into FAB** | Own the logic instead of depending on external system | All investigations — current dependency means no threshold tuning, no A/B testing, no feedback loops. | Infrastructure change. Enables faster iteration on all rules above. |

---

## Appendix: Rule Thresholds

| Bit | Rule | Thresholds | SKU Scope | Since |
|-----|------|-----------|-----------|-------|
| 1 | Chia Mining | FileType = Crypto Mining, Size > 100 GB, MAU < 10 | E5/E3 Dev, A1 | Jul 2025 |
| 2 | Streaming | FileType = Video, Storage > 20 TB, Egress > P99 (~45 GB) | E5/E3 Dev | Aug 2025 |
| 4 | Storage+Egress+MAU | MAU < 5, Storage > 10 TB, Egress > P999 (~90 GB) | E5/E3 Dev, A1 | Sep 2025 |
| 8 | Storage/MAU | MAU < 5, Storage > 20 TB | E5/E3 Dev, A1 | Oct 2025 |
| 16 | FraudInSMB | MAU < 3, Paid Licenses < 3, Storage > 20 TB | Biz Basic/Standard/Premium | Nov 2025 |

---

*Data verified April 15–17, 2026 via direct SQL queries against fabdardb. Raw results in `docs/rulecheck/`.*
