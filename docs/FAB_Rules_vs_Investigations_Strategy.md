# Rules vs. Investigations: Where Should FAB Invest?

**Date**: April 20, 2026 | **Author**: Varun V  
**Purpose**: Strategic discussion paper for leadership on FAB's detection investment model

---

## The Question

Should FAB invest in building production-grade detection rules, or stay nimble with investigation-driven takedowns that chase emerging patterns?

The data says **both, but not equally** — and the current balance is wrong.

---

## The Case Against More Rules

### Rules decay. Fast.

Every rule we've built has a measurable half-life:

| Rule | Peak Month | Peak Catches | Current (Apr 2026) | Decline | Effective Lifespan |
|------|-----------|-------------|--------------------|---------|--------------------|
| R1 – Chia Mining | Nov 2025 | 10 | **0** | 100% | ~5 months (dead) |
| R2 – Streaming | Nov 2025 | 430 | 2 | 99.5% | ~4 months at useful levels |
| R3 – Storage+Egress | Dec 2025 | 460 | 18 | 96% | ~5 months, declining |
| R5 – FraudInSMB | Dec 2025 | 52 | 0 | 100% | ~4 months |
| R4 – Storage/MAU | Nov 2025 | 524 | 32 | 94% | Still active (rebounded in March) |

**4 of 5 rules declined 94–100% within 5 months of launch.** R1 is entirely extinct. R2 catches 2 tenants/month. R5 is functionally dead. Only R4 — the simplest rule (just "big storage, few users") — showed resilience, and even it is running at 6% of peak.

This isn't a failure of rule design. It's the fundamental nature of deterministic rules against an adaptive adversary. Attackers see tenants get blocked, figure out the trigger, and adjust. Chia miners moved to other platforms. Streaming abusers shifted SKUs. The pattern the rule was built to catch ceases to exist.

### New rules have a long tail of hidden costs

Creating a rule is cheap (config change). But the **full lifecycle cost** includes:
- Validation queries to prove it works (we ran 30+ queries for this investigation alone)
- FP analysis and tuning (R3's 8.89% FP took weeks to root-cause)
- Pipeline monitoring that doesn't exist yet (R2/R3 decayed silently)
- Backfill runs that never happen (FAMILIA CONFEITAR missed for months)
- Feed dependence on upstream systems (97.6% of RC107 tenants never reached the rule engine)

Each rule we ship adds another thing to monitor, tune, and eventually retire — without any guarantee it'll last beyond its first quarter.

### The rules we validated for this investigation prove the point

We tested 6 proposed new rules against production data. Results:

| Proposed Rule | Outcome |
|---------------|---------|
| CDN Score | Catches nothing net-new — 34/35 already in FAB |
| Shared Phones | 957K matches — pure noise |
| Storage Growth Rate | Compound threshold catches zero tenants |
| Gibberish Names | Weak discrimination, not validated |
| Low-threshold A1 | Only 31 net-new after all filters |
| Provisioning Velocity | Promising — but it's really an investigation pattern, not a simple threshold rule |

**5 of 6 proposed rules were killed or deferred.** The one that survived (provisioning velocity) is fundamentally an investigation signal — identifying *orchestrators* via admin email clustering — not a simple threshold you can codify.

---

## The Case FOR Investigations

### Every investigation finds a pattern no rule covers

13 investigations over 3 months. Every single one uncovered a net-new attack vector:

| Investigation | Tenants | Storage | New Pattern Found |
|---------------|---------|---------|-------------------|
| E5 Dev 4-Char Ring | 31 | 2.9 PB | Random 4-char naming, zero-usage developer trials |
| FAMILIA CONFEITAR | 30 | 1.9 PB | Brazil CDN streaming, READONLY doesn't stop egress |
| China Network (INV-015) | 162 | 393+ TB | rclone piracy CDN, brand impersonation, commercial reselling |
| MistyCloud | 12 | 3.67 PB | Domain-based clustering (not email), 340x storage overage |
| F1 Soft-Quota | 12 | 1.52 PB | F1 license soft-quota bypass, $22.50/month for 1.5 PB |
| DS Model Study | 944 | 7.8 PB | rclone/Cloudreve/StableBit app fingerprints |
| StableBit (INV-013) | 9 | 25 TB | Chunk-level encryption, "MSFT" impersonation ring |
| Quang Trung | 5 | 433 TB | EDU storage reselling storefront (ms365vip.com) |
| Archetype G | 6 | 499 TB | Tenant repurposing, multi-school domain hijacking |
| Procode Ring | 32 | ~32 TB | Dormant multiplexing — pre-positioned but not yet active |
| ACGDB/SakuraPY | 33 | 597 TB | Sequential naming + shared admin email across 5 countries |
| EDU CN/VN (INV-008) | 43 | 255 TB | Commercial masquerade, identity theft, MSP fraud |
| R3 Commercial+EDU | 65,572 | 1,032 TB | Ghost fraud shells: commercial + EDU signal + zero users |

**~1,300 tenants, ~19+ PB of abuse, 13 distinct attack vectors** — none covered by existing rules at the time of discovery. Each investigation found something fundamentally different from the last.

### Investigations are catching things rules structurally cannot

Rules are threshold-based: storage > X, MAU < Y, SKU = Z. They can only see **quantitative anomalies** on dimensions they're designed to measure.

Investigations find **qualitative patterns**:
- Brand impersonation (ms365vip.com, tm[X].site, "Microsoft 365" naming)
- Tenant repurposing (hijacking dormant school domains)
- App-level fingerprints (Cloudreve, StableBit — 313 tenants globally, near-100% fraud)
- Cross-tenant identity clustering (same admin across 5 countries)
- Dormant provisioning (Procode: 32 tenants pre-positioned for 21 months, zero storage)

No threshold rule will ever detect a dormant ring with zero storage. No storage rule will catch brand impersonation. These are pattern-recognition problems that require human judgment — or ML, which is what the DS Model does (97.8% net-new catch rate).

### The precision is comparable

| Method | Tenants | FP Rate | Storage (PB) |
|--------|---------|---------|-------------|
| Rules (R1–R5, RC96) | 47,003 | 3.59% | 3,045 |
| AI Agent (R0, RC96) | 83,243 | 0.13% | 572 |
| DS Model (RC107) | 720 | 0.00% | 17 |
| **Investigations (RC106)** | **700** | **0.43%** | **15** |
| Manual (no RC) | 1,354 | 1.62% | 0.02 |

Investigation-driven detections (RC106) run at **0.43% FP** — comparable to automated rules and better than manual. Investigations aren't sloppy; they're human-validated before ingestion.

---

## But Rules Do One Thing Investigations Can't: Scale

Here's the uncomfortable counterpoint. Investigations found ~1,300 tenants across 3 months. **R4 alone found 1,143 in one rule cycle.** R0's bulk sweep ingested 44,669 in a single batch.

The math is simple:

| Approach | Tenants/Month (avg) | Effort/Tenant | PB Identified |
|----------|--------------------|--------------|----|
| Investigations | ~100 | High (human hours per takedown) | ~2 |
| R4 alone | ~190 | Zero (automated) | ~330 |
| All Rules (R1–R5) | ~500 (declining) | Zero | ~508 |

You cannot investigate your way to 47,000 tenants. At 100 tenants/month investigation rate, clearing the current backlog would take **39 years**. Rules, even degrading ones, provide the volume coverage that makes the system function.

**The real question isn't rules vs. investigations. It's: what's the right allocation?**

---

## The Hybrid Model: Investigate First, Automate the Durable Patterns

The data points to a specific playbook:

### 1. Investigation is the front line — this is where new patterns get found

Every useful signal we have today started as a manual discovery. rclone abuse, CDN egress patterns, StableBit fingerprinting, provisioning velocity — none of these came from a rule. They came from someone looking at a suspicious tenant and asking "what's different here?"

**Invest in**: Investigation tooling (MCP, Kusto access, faster data pivots), analyst capacity, and a structured process for turning findings into signals.

### 2. Only codify patterns that pass the "durability test"

Not every investigation finding should become a rule. The durability test:

| Test | Pass | Fail |
|------|------|------|
| Is the signal **structural** (tied to physics of the abuse) or **behavioral** (tied to attacker choice)? | Structural: "High storage + few users" can't be gamed without changing the abuse model | Behavioral: "Uses rclone" — attacker switches to a different tool next month |
| Is the population **large enough** to justify automation? | R4: 1,143 tenants | StableBit: 22 tenants globally. Investigate manually. |
| Is the signal **stable over time**? | R4 held at useful levels for 6+ months | R1/R2/R5: collapsed within a quarter |

**R4 passes all three**: it targets the physics of abuse (you can't hoard PBs of storage with 1 user without being abnormal), the population is huge, and it's proven durable. It was worth codifying.

**Rclone fails**: it's a tool choice, not a structural signal. Attackers can (and will) switch tools. The 10,515 rclone tenants today could be 500 next quarter.

### 3. Treat rules as disposable — design for retirement, not permanence

Current rules have no sunset mechanism. R1 ran for 4 months after it stopped catching anything. R2 is still running at 2/month. This is waste.

**Proposal**: Every rule gets a **90-day review trigger**. If detections drop below 10% of launch-month baseline for 2 consecutive months, the rule enters sunset review. If no rebound within 30 days, retire it. This keeps the rule portfolio lean and honest.

### 4. The DS Model is the bridge

RC107 (DS Model) caught 720 tenants at 0% FP, with 97.8% being net-new. It found patterns across SKUs, geographies, and attack types that rules couldn't see. This is the middle ground: **ML-driven pattern recognition that adapts, without requiring manual rule creation per pattern.**

The strategic investment isn't "more rules" — it's "better models." The DS Model already outperforms rules on novelty. The path forward is:
- Investigations discover attack vectors (human creativity)
- Discoveries train and validate ML models (feed the DS Model with investigation-confirmed fraud)
- ML handles ongoing detection at scale (replaces the need for per-pattern rules)
- Simple, durable rules (like R4) stay as a safety net for the most obvious abuse

---

## Recommendation to Leadership

| Area | Current State | Proposed State |
|------|--------------|---------------|
| **Rules** | 5 active, no monitoring, no retirement cadence | Keep 2–3 durable rules (R4, R3-fixed, maybe R5-expanded). Retire the rest. Add 90-day review cycle. |
| **Investigations** | Ad-hoc, no structured process for pattern handoff | Primary detection method for new/emerging abuse. Invest in tooling and analyst capacity. |
| **DS Model** | 720 tenants, newly onboarded | Scale this. Feed it investigation-confirmed labels. This is the rule replacement. |
| **New rules** | 6 proposed, 5 killed | Stop creating rules for transient patterns. Codify only what passes the durability test. |

**The framing for leadership**: Rules are a **maintenance liability** that degrades quarterly. Investigations are a **learning capability** that compounds. The DS Model is the **scaling mechanism** that turns investigation insights into automated detection without the brittleness of static rules.

The question isn't "should we build more rules?" It's "how do we build a system that learns as fast as attackers evolve?"

---

## Supporting Data

### Rule Decay Curves (monthly detection counts)

```
        Nov   Dec   Jan   Feb   Mar   Apr   Decay from Peak
R1       10    12     0     0     0     0    100% (extinct)
R2      430   102    22    23    40     2    99.5%
R3      310   460   114   161    67    18    96%
R4      524   198    42    85   262    32    94% (but rebounded)
R5        —    52     8     7     4     0    100%
```

### Investigation vs. Rule Detection Attribution

```
Rules (R1–R5):     47,003 tenants | 3,045 PB | 3.59% FP | Declining
AI Agent (R0):     83,243 tenants |   572 PB | 0.13% FP | One-time batch
DS Model (RC107):     720 tenants |    17 PB | 0.00% FP | 97.8% net-new
Investigations:       700 tenants |    15 PB | 0.43% FP | Every one found a new pattern
```

### Attack Vector Discovery Timeline

```
Oct 2025  Rules R1-R5 launched (storage + MAU + SKU thresholds)
Nov 2025  INV: E5 Dev 4-char ring discovered (naming pattern — can't be a rule)
Dec 2025  R1 extinct. Chia attackers moved on.
Jan 2026  INV: ACGDB ring (shared admin emails across 5 countries)
Feb 2026  INV: Procode ring (dormant multiplexing — zero storage, invisible to rules)
Feb 2026  R2 at 5% of peak. Streaming attackers shifted.
Mar 2026  INV: China piracy CDN rings (rclone, brand impersonation, commercial reselling)
Mar 2026  INV: F1 soft-quota exploit ($22.50/month for 1.5 PB — new SKU abuse)
Mar 2026  INV: MistyCloud (domain clustering, 3.67 PB — no email overlap to detect)
Apr 2026  INV: StableBit CloudDrive (app fingerprint, encryption obfuscation)
Apr 2026  INV: FAMILIA CONFEITAR discovery that READONLY doesn't stop egress
Apr 2026  DS Model launched — 97.8% net-new. Finds what rules AND investigations missed.
```

Each month, the investigation team discovered attack vectors that no existing or proposed rule could detect. Meanwhile, 3 of 5 rules had already lost their effectiveness. The investigation capability compounds; the rule capability depreciates.

---

*Raw data in `docs/rulecheck/`. Investigation reports in `docs/investigations/`.*
