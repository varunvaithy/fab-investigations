# Fair Use & Fraud/Abuse: Boundary Definition and Strategic Implications

**Fair Usage (Fraud & Abuse) | May 2026 | Internal Working Paper**

---

## The Landscape Shift

A new **Fair Use** workstream will enforce storage quota limits across all tenants. Tenants that exceed their storage allocation will be throttled, notified, and capped — regardless of intent.

This changes FAB's operating model fundamentally. Today, FAB detects fraud primarily through storage anomalies (Rules 1–5 all require storage thresholds). Once Fair Use enforces quota, fraud tenants get throttled before they reach FAB's detection thresholds. **FAB's current rules become structurally irrelevant within 12 months.**

But the fraud doesn't disappear. It accelerates. Fair Use throttles the *symptom* (over-storage) without burning the *actor* (identity, network, ring). Actors respawn faster. The revolving door spins harder. Non-storage abuse (credential farming, link abuse, license fraud) remains entirely unaddressed.

---

## Scope Definition

| | **Fair Use** | **Fraud & Abuse** |
|---|---|---|
| **Core question** | "Are you using more than you paid for?" | "Are you who you say you are? Is your intent legitimate?" |
| **Assumes** | Legitimate actor, over-consuming | Bad actor, exploiting or weaponizing the platform |
| **Trigger** | Resource consumption exceeds allocation | Intent signals indicate fraud/abuse — regardless of consumption level |
| **Action** | Throttle, notify, cap. Reversible. Tenant stays. | Remediate, blocklist, burn identity. Permanent. Tenant removed. |
| **Outcome** | Customer reduces usage or upgrades | Actor removed from ecosystem, prevented from returning |

### Clear Boundaries

**Fair Use owns:** Legitimate tenants over quota — real orgs, active users, custom domains, paid history. They grew beyond their allocation. Action: bring them into compliance.

**FAB owns:** Tenants with fraudulent intent — fake identities, automated exploitation, weaponization, coordinated rings, non-storage abuse. Storage level is irrelevant. Action: remove permanently and prevent return.

### The Overlap Zone

Tenants with *both* high storage *and* ambiguous intent (e.g., 20TB + MAU=2 + onmicrosoft domain). Resolution:
- **Strong fraud signals** (identity + behavior + network) → FAB owns. Enforce permanently.
- **Weak fraud signals** (only over-quota, no clear intent) → Fair Use owns. Throttle/notify.
- **Moderate signals** (ambiguous) → Fair Use acts first (cheaper, reversible). FAB monitors. If signals strengthen → FAB takes over.

---

## Impact on Existing Detection

| Rule | Fires today because... | Fair Use impact | 12-month outlook |
|---|---|---|---|
| R4 (>20TB, MAU<5) | Tenants accumulate 20TB+ | Tenants throttled at quota, never reach 20TB | **Near-zero catches** |
| R3 (>10TB, egress, MAU<5) | Similar storage trigger | Same preemption | **Significant decline** |
| R2 (Video, >20TB, egress) | Piracy CDNs hit 20TB | Throttled early, respawn undetected | **Zero catches, fraud persists** |
| R5 (SMB, >20TB) | Already dead | — | Retire |

**Net effect:** COGS Protected (TB reclaimed) declines toward zero. Not because fraud is gone — because the measurement mechanism (storage-threshold rules) stops working.

---

## What FAB Detection Must Become

The shift: from **"storage cop" (catch after accumulation)** to **"fraud investigator" (catch on intent, early in lifecycle)."**

### New Detection Axes (non-storage)

| Signal | Detects | When (lifecycle) |
|---|---|---|
| Identity fraud (gibberish names, onmicrosoft-only, fake admin) | Disposable tenants created at scale | Day 0 |
| Tool fingerprints (rclone, StableBit, Cloudreve) | CDN/piracy/reselling operations | Day 1–7 |
| Velocity anomaly (storage growth > P95 for SKU) | Fraud filling fast, even below quota | Day 7–14 |
| Behavioral pattern (zero logins, 100% API, streaming) | Non-human exploitation | Day 1–14 |
| Network signals (shared admin, phone, IP clustering) | Fraud rings | Any time |
| Provisioning velocity (burst tenant creation) | Re-entry, scale operations | Day 0 |
| Non-storage abuse (license hoarding, Teams spam, phishing) | 85K A1 zero-storage tenants | Any time |
| Cross-org signals (MDO, Exchange, CFAR) | Multi-surface abuse invisible to SPO alone | Any time |

**The key advantage:** FAB detects in Days 0–14. Fair Use doesn't act until Day 60+. If FAB is fast enough, there's no temporal overlap — FAB catches fraud before Fair Use ever sees a quota issue.

---

## Measurement Implications

### The Paradox

Better detection = less storage to reclaim = COGS Protected goes DOWN.

| | Catch at Day 90 (today) | Catch at Day 7 (target) |
|---|---|---|
| Storage at catch | ~25 TB | ~0.8 TB |
| COGS Protected | High | Near zero |
| Actual damage to Microsoft | 90 days of exploitation | 7 days |
| Actor disruption | Maybe (single tenant) | Yes (identity burned, ring mapped) |

**Every outcome improves except the one metric leadership currently tracks.**

### The New Measurement Framework

| Tier | Metric | What it proves |
|---|---|---|
| **North Star** | Ecosystem Fraud Rate (EFR) | Is the ecosystem getting cleaner? |
| **Capability** | Time-to-Detection (TTD) | Are we catching fraud earlier? |
| **Capability** | Coverage (% of fraud identified) | Are we missing less? |
| **Capability** | Re-entry Prevention Rate | Are actors staying gone? (FAB's unique value vs Fair Use) |
| **Capability** | Actors/Rings Disrupted | Are we dismantling operations, not just tenants? |
| **Financial** | COGS Prevented (modeled) | Projected damage averted by early catch |

**Critical timing:** EFR and Detection Efficacy must be operational BEFORE COGS declines. The narrative shift must be proactive ("we're evolving to prevention") not defensive ("here's why our numbers dropped").

---

## Strategic Recommendations

1. **Launch new measurement (EFR + TTD) this semester.** The story must be in place before COGS declines.
2. **Build intent-based detection (TRS + new rules)** that works independent of storage thresholds.
3. **Establish Fair Use → FAB escalation path.** Fair Use will catch-and-release fraud actors. FAB needs visibility to burn identities.
4. **Reframe success narrative to leadership now.** "We're shifting from reactive cleanup to proactive prevention. New metrics show this."
5. **Existing rules continue running** but are understood as declining assets. No further investment in storage-threshold rules.

---
