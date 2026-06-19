# Blocklist-Based Re-Entry Prevention: Proposal

| Field | Value |
|-------|-------|
| **Author** | Varun V |
| **Date** | April 10, 2026 |
| **Status** | Draft — Pending Engineering Review |
| **Related** | [Re-Entry Prevention Strategy](../Re_Entry_Prevention_Strategy.md), [Fraud Ring Consolidation Report](../Fraud_Ring_Consolidation_Report.md) |

---

## 1. Problem

### Current rules don't detect returning actors

R1-R5 detect **abuse patterns** — high storage, egress, mining, streaming. They catch tenants that are actively misbehaving. But when FAB remediates a tenant, the operator's infrastructure goes dark while the operator doesn't. There is currently **no mechanism** in the detection pipeline to recognize a returning bad actor — not at provisioning time, not during detection, not anywhere. The pipeline has no memory.

### Evidence: operators come back

Across investigated rings and the DS-flagged backlog, a consistent pattern emerges — operators return using the same or slightly modified registration details, and the system treats them as brand new:

| Ring | What Happened | Time Between Waves | Evasion Tactic |
|------|--------------|---------------------|----------------|
| **ACGDB/SakuraPY** | ACGDB2 blocked May 2025 → operator created ACGDB21 (Nov 2025) and sakuraod (Mar 2026) **using the same email** | 6 months, then 4 months | Geographic shift (HK → US → AR). Same email — didn't even bother changing it. |
| **MistyCloud** | 11 tenants created Apr 2025 → new tenant `mssp2ar` created Mar 2026 | **11 months** | Naming pattern kept identical (`mistytempsp*`). Operator confident they wouldn't be caught. |
| **FAMILIA CONFEITAR** | 15 tenants created Apr 11, paused, then 15 more tenants May 6-7 | **25 days** | Same email, same phone, same address, same company name, just incremented the number. |
| **F1 NL Ring** | Phase 1 (Sep 2023, `gel*` domains) → Phase 2 (Nov 2023, `kal*` domains) | **2 months** | Changed domain prefix but kept gibberish name pattern with same NL geography. |
| **E5 Dev 4-Char** | Tenants created monthly over 7 months (May 2023 – Jan 2024) | **Continuous** | Same 4-char pattern, rotated across 11 countries. |
| **Procode** | 32 tenants created monthly over **21 months** (Jun 2024 – Mar 2026). **Still adding tenants.** | **Continuous** | Random 3-digit suffixes, gibberish Gmail per tenant. |

### Evidence: large-scale rings went undetected entirely

Beyond confirmed re-entry, the detection backlog contains rings that were never caught at all — meaning if we remediate them now, we should expect re-entry:

| Source | Undetected Tenants | Duration Undetected | Notes |
|--------|-------------------|---------------------|-------|
| Hamter botnet (Vietnam) | 3,749 tenants | Created Sep-Oct 2025, **still undetected** | 21 admin accounts, sequential burst provisioning |
| April 2022 China ring | 4,498 tenants | **4 years** | 9 randomized admin emails, 500 tenants per email |
| shheqing.com ring | 685 tenants | 2.4 years, **still growing** | 2 admin emails, active as of Mar 2026 |
| Uninvestigated IDs | ~9,653 tenant IDs | Unknown | Flagged by DS model but never triaged |

That's **~18,500 tenants in the detection backlog** — all potential re-entry risks once remediated, unless the front door is closed first.


### Why this keeps happening

- **It's free.** Most abuse is on free/trial/F1 tiers. Creating a new tenant costs nothing.
- **It's fast.** ACGDB created 14 tenants in 25 minutes. FC created 15 in 2 hours.
- **There's no memory.** The provisioning system — and our detection pipeline — has no concept of "this operator was previously blocked."
- **They don't even try to hide.** ACGDB used the same email for 3 years. FC used the same phone/address for all 30 tenants.
- **Detection is slow.** Average time from creation to detection across documented rings: **12-18 months**. Operators have learned that persistence = invisibility.

### The gap

R1-R5 answer: *"Is this tenant abusing storage?"* Nothing in the current pipeline answers: **"Have we seen this actor before?"**

---

## 2. What We're Proposing

A **blocklist system** that checks new and existing tenants against known fraud indicators — emails, domains, phone numbers, org names, and registration patterns — extracted from our investigations.

### Three things need to happen:

| # | What | Why |
|---|------|-----|
| **A** | **Seed the blocklist** — gather indicators from our remediation history, CFAR, and partner teams | We have 6 months of remediation data that hasn't been mined. CFAR and other teams may already maintain their own lists. |
| **B** | **Daily sweep** — run Kusto queries matching new tenants against blocklist | Catches re-entry within 24 hours. Feeds into our existing detection pipeline with zero new infrastructure. |
| **C** | **Pipeline integration** — add a `BlocklistDetector` to the detection flow to score and tag matches | Matches get RULEMASK bits and reason codes, same as R1-R5 today. Visible in dashboard and via MCP tools. |

### What won't change:

- Existing R1-R5 rules and pipeline logic stay untouched
- No dependency on the gibberish/multiplexing prototypes (those are separate, future proposals)
- Additive only — blocklist checks run alongside existing enrichment, not instead of it

### Relationship to the existing rules proposal

A separate proposal covers tuning R1-R5 (abuse pattern detection). This proposal adds **identity-based** rules (R6/R7/R8) that answer a different question: not "is this tenant abusing storage?" but "have we seen this operator before?" Both feed the same RULEMASK pipeline and stack — a tenant matching R3 + R6 is a returning abuse actor with the highest possible confidence.

### How it fits into the existing system

See [blocklist-flow.html](blocklist-flow.html) for the interactive process diagram.

The system forms a cycle: Steps 1–2 seed the blocklist. Steps 3–4 run matches through the existing pipeline. Steps 5–6 fire new rules and remediate. On every remediation, identifiers are auto-extracted back into the blocklist — the system gets smarter with each action.

---

## 3. Blocklist Sourcing

The blocklist is only as good as what's in it. Three sources:

### 3a. Our Investigation Reports (Done)

Machine-readable blocklists already created in `blocklists/` from INV-001 through INV-014:

| File | Count | Example High-Signal Entries |
|------|-------|-----------------------------|
| `emails.json` | 52 | `pengyoupy001@gmail.com` (all 33 ACGDB tenants), `mario@ritzmann.com.br` (all 30 FC tenants) |
| `domains.json` | 42 | `misty.moe`, `sakurapy.com`, `ourpage.cn`, `ms365vip.com` |
| `phone_numbers.json` | 6 | `4258828080` (MS HQ phone used by MSFT impersonation ring), `4196152228` (all 30 FC tenants) |
| `tenant_ids.json` | 160+ | Organized by ring for cross-reference |
| `org_names.json` | 50+ | Exact names + sequential patterns (`ACGDB\d+`, `familiaconfeitar\d+`) |
| `registration_patterns.json` | 15+ | Regex patterns per ring (domain, email, address) |
| `external_services.json` | 11 | `ms365vip.com` (reselling), `poweramsonline.com` (multiplexing) |
| `app_fingerprints.json` | 6+5 | `rclone` (100% fraud on EDU A1), `StableBit`, behavioral signals |

### 3b. FAB's 6-Month Remediation History (To Do)

`[fraud].[FRAUD_TENANT_DETAILS]` contains every tenant we've actioned. Plan: query all BLOCKED/DELETED tenants → join with Kusto `TENANT_INFO` for registration metadata → cluster by shared signals → extract and deduplicate into the blocklist.

### 3c. Cross-Team Blocklists (To Discover)

CFAR, M365 Commerce, Entra ID Identity Protection, SPO Abuse Response, and MSTIC may already maintain relevant lists (domains, emails, IPs, payment fraud indicators). Action: schedule meetings with CFAR and Commerce to understand what exists and establish a data-sharing format.

---

## 4. Detection: Three New Rules (R6, R7, R8)

R1-R5 are in production today. Using the next available RULEMASK bits:

| Rule | What It Does | Action on Match | FP Risk |
|------|-------------|-----------------|---------|
| **R6** — Blocklist Exact Match | Admin email, phone, domain, or org name matches a `confirmed` blocklist entry | Auto-ingest to FAB (reason code 107) | Very Low |
| **R7** — Blocklist Pattern Match | Domain/name matches known ring regex (e.g., `familiaconfeitar\d+`, `acgdb\d+`) | Flag for HIT review | Low |
| **R8** — Re-entry Similarity | 2+ weak signals overlap with a remediated ring (geo + SKU + app fingerprint + timing) | Boost fraud score +0.3 | Medium |

These stack with existing rules — they don't replace anything.

---

## 5. Where It Gets Checked

| Checkpoint | What Happens | Catches |
|---|---|---|
| **Daily Kusto sweep** | Scheduled query matches new tenants (last 7 days) against blocklist → inserts into `DetectionAutomationRulesData` | Re-entry before abuse starts |
| **Detection pipeline** | `BlocklistDetector` runs during tenant enrichment, sets RULEMASK bits | Tagging and routing for already-queued tenants |
| **MCP tool + Dashboard** | Investigators can check any tenant against blocklist on demand | Ad-hoc investigation support |
| **Provisioning gate** *(future, cross-team)* | Block tenant creation at signup if registration details match confirmed entries | Prevention at the door |

The first three are fully within FAB's control. The provisioning gate requires Entra ID / Commerce partnership.

---

## 6. Keeping the Blocklist Current

A stale blocklist is a useless blocklist. Three maintenance cadences:

| When | What |
|------|------|
| **After each investigation** | Extract identifiers from report → add to `blocklists/*.json` → commit |
| **Monthly** | Sync with CFAR/Commerce for new indicators; share FAB's new entries back |
| **Quarterly** | Re-sweep full remediation history; prune stale entries |

---

## 7. Phases

| Phase | Scope | Timeline |
|---|---|---|
| **0 — Seed** | Mine 6-month remediation history; backfill blocklist from `FRAUD_TENANT_DETAILS` + `TENANT_INFO` | Week 1 |
| **1 — Kusto Sweep** | Add reason code 107; write & schedule R6/R7 sweep queries; feed into existing pipeline | Week 2-3 |
| **2 — Pipeline Integration** | Build `BlocklistDetector`; add remediation lookback; integrate into detection enrichment; RULEMASK bits | Week 4-5 |
| **3 — Automation** | Auto-extract indicators on remediation; remediation-triggered sibling sweep; rule stacking logic; MCP tool | Week 5-6 |
| **4 — Early Detection** | Cross-tenant identity clustering queries; day-3/day-7 behavioral scoring for new tenants | Week 7-8 |
| **5 — Visibility** | Dashboard endpoint; audit trail table; formalize SOP; quarterly full sweep | Week 9+ |
| **6 — Cross-Team** | CFAR/Commerce blocklist exchange; provisioning gate; storage hardening; graduated trust model | Future |

Phases 0-5 are fully internal to FAB/ODSP — no cross-team dependencies. Phase 6 requires external partnerships.

---

## 8. Beyond the Blocklist

R6-R8 catch known actors. The following enhancements strengthen re-entry prevention structurally — most are internal to FAB/ODSP and can ship alongside the blocklist work.

### Pipeline memory

Today the detection pipeline processes each tenant in isolation. It has no concept of "we blocked a tenant with this same admin email 3 months ago."

**Fix**: On each pipeline run, query `[fraud].[FRAUD_TENANT_DETAILS]` for previously remediated tenants sharing the same admin email, phone, or domain. If a match exists, the new tenant inherits remediation context from the prior case. This is a live query against our own data — always current, no static blocklist required.

### Automatic indicator extraction on remediation

Extracting identifiers from remediated tenants is currently manual. Automate it: when a tenant's status changes to BLOCKED/DELETED, pull its registration metadata from Kusto (`TENANT_INFO`) and insert into the blocklist store. The blocklist grows with every remediation, no investigator action required. The 6-month remediation backlog gets resolved once via backfill, then stays current.

### Remediation-triggered sibling sweep

When we block tenant X, immediately sweep for other tenants sharing its identifiers — "block one, find all siblings." If FC tenant #1 had triggered this sweep, we'd have found tenants #2-#30 immediately (same email, same phone). Instead, all 30 sat undetected for weeks.

### Cross-tenant identity clustering

Lightweight linkage using Kusto data we already have — cluster tenants by shared admin email, phone, domain pattern, or creation timing. Any cluster where one member is remediated → all others get flagged. This doesn't require a blocklist at all; it self-identifies rings structurally.

### Rule stacking and priority escalation

When a tenant matches a re-entry rule (R6/R7/R8) **and** an abuse rule (R1-R5), auto-escalate:

| Combination | Meaning | Action |
|------------|---------|--------|
| R6 + any R1-R5 | Known actor, actively abusing | Auto-block |
| R7 + any R1-R5 | Probable ring member, confirmed abuse | Fast-track review (24h SLA) |
| R6/R7 alone | Known actor, hasn't started abusing yet | Watch list — recheck at day 7 |

### Early behavioral scoring

Most fraud tenants reveal their intent within 72 hours — rclone appears, HTTP 206 dominates, video files flood in. A day-3 and day-7 health check for new tenants using existing SpoProd `RequestUsage` data would catch aggressive abuse before it scales to TB/PB.

### Storage and rate limit hardening (ODSP-wide)

Hard storage caps on free/trial/F1/EDU A1 SKUs. API rate limits for non-enterprise tenants. Anonymous sharing restrictions on free-tier tenants. These don't prevent re-entry directly, but limit what a returning actor can do — a returning ACGDB operator capped at 5 TB is a nuisance, not a crisis.

### Cross-team opportunities (future)

| Idea | Partner Team |
|------|-------------|
| Tenant creation friction (identity verification, payment gating, CAPTCHA) | Entra ID, Commerce |
| Provisioning gate — block creation when registration matches confirmed blocklist | Entra ID, Commerce |
| Graduated trust model — new tenants start restricted, earn capabilities over time | Cross-org policy |
| Operator intelligence sharing — domain registration feeds, abuse report feeds | MSTIC |

---

## 9. Success Metrics

| Metric | Target |
|--------|--------|
| Re-entry detection rate (known patterns) | >90% |
| Time from tenant creation to blocklist alert | <24h (Phase 1), <1h (Phase 2) |
| False positive rate | <1% (R6), <5% (R7) |
| Remediation history coverage in blocklist | >80% after seeding |
| Known operator recidivism (post-blocklist) | Trending to 0 |
| Sibling discovery rate on remediation | >80% of related tenants found within 24h |

---

## 10. Open Questions

1. **CFAR/Commerce blocklists** — What format do they maintain? Is there an existing API or data feed, or manual export?
2. **ISS flag interaction** — Should blocklist matches override ISS500/ISS2200 filtering in the detection pipeline?
3. **Kusto hosting** — Where should blocklist CSVs live for `externaldata()` joins? (Blob storage, ADX ingestion, or inline arrays?)
4. **Data sharing agreements** — Any privacy/security constraints on sharing indicators between CFAR, Commerce, and FAB?
5. **Remediation history completeness** — Do older remediated tenants still have `TENANT_INFO` entries in Kusto, or have some been purged?
6. **R8 calibration** — Need to backtest similarity thresholds against the 160+ known-fraud tenants. Who should own this?

---

## Appendix: Database Changes

### New Reason Code

| Code | Name | Description |
|------|------|-------------|
| **107** | Blocklist Match | Tenant matched known fraud ring blocklist (R6/R7/R8) |

### Audit Table (Optional)

```sql
CREATE TABLE [fraud].[BLOCKLIST_MATCH_LOG] (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    SiteSubscriptionId NVARCHAR(36) NOT NULL,
    MatchedValue NVARCHAR(500),
    MatchedRing NVARCHAR(100),
    MatchType NVARCHAR(50),
    Confidence NVARCHAR(20),
    DetectedDate DATETIME2 DEFAULT GETUTCDATE(),
    BlocklistVersion NVARCHAR(20)
);
```


