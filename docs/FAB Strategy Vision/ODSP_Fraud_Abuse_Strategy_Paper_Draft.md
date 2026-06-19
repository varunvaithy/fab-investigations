# ODSP Fraud & Abuse

## A Strategic Vision for Detection, Prevention, and Ecosystem Health

<br>

| | |
|---|---|
| **Author** | Varun V |
| **Date** | May 2026 |
| **Status** | Draft |
| **Classification** | Internal — Strategy |

<br>

---

<br>

## Executive Summary

OneDrive and SharePoint Online serve hundreds of millions of users across commercial, education, and consumer segments. With that scale comes a proportional fraud and abuse surface — one that has grown in sophistication, organizational structure, and financial impact over the last two years.

<br>

> ### Impact to Date (July 2025 – April 2026)
>
> | 26,000+ tenants remediated | 90+ PB storage reclaimed | 99.7% detection precision | 75% faster investigations |
> |:---:|:---:|:---:|:---:|
> | Across all detection channels | COGS recovered from abuse | vs. 73% for manual enforcement | 20 min → <5 min per tenant |

<br>

These results demonstrate the program's effectiveness at identifying and remediating storage-intensive fraud. However, the threat landscape has outgrown this approach. Fraud in ODSP is no longer primarily a storage problem — it spans provisioning abuse, collaboration-feature exploitation, identity manipulation, and platform-as-attack-infrastructure. Detection rules, while precise, decay rapidly and cover only a subset of SKUs and signals. The problem definition itself needs to broaden, measurement must mature, and enforcement needs granularity beyond today's tenant-level actions.

**This paper proposes five strategic shifts:**

1. An **expanded definition** of fraud and abuse that accounts for the full threat surface — not just storage consumption
2. A **detection investment model** combining rules, data science, and investigations in a flywheel — with a Tenant Risk Score as the synthesis layer
3. A **capability roadmap** spanning enforcement granularity, provisioning prevention, Commerce integration, and investigation automation
4. A **measurement framework** (3 north star metrics + 1 impact indicator) that quantifies ecosystem health, not just storage savings
5. A **competitive positioning** against Google, Dropbox, and Box that maps specific gaps to specific investments — and identifies what requires cross-team partnership

The goal: shift from reactive enforcement toward proactive ecosystem health — detecting faster, enforcing at the right granularity, preventing re-entry, and measuring whether we're winning.

<br>

---

<br>

## 1. Scale of the Problem

Cloud platform abuse is an industry-wide structural challenge, not an ODSP anomaly. FBI-reported cybercrime losses reached $16 billion in 2024 (+33% YoY). CrowdStrike's 2026 Global Threat Report documents an 89% increase in AI-enabled attacks and a 266% increase in cloud-conscious intrusions. Microsoft's own Threat Intelligence team warned in October 2024 about the growing weaponization of SharePoint, OneDrive, and Dropbox as phishing delivery infrastructure — a technique category they term "living-off-trusted-sites" (LOTS). The pattern is clear: legitimate cloud platforms are no longer incidental victims of abuse. They are the infrastructure *through which* it operates.

Within this landscape, ODSP faces a specific and measurable problem across four dimensions:

**1. Resource exploitation at industrial scale.** Organized operators run multi-tenant storage rings using commercial SKUs as cheap as $2.25/month. Detection has flagged 49,000+ tenants since July 2025 — remediated tenants alone consumed 90+ PB of platform storage. The economics are structurally inverted: it costs more to detect and remediate than it costs to provision and abuse.

**2. Provisioning and identity abuse.** Fraud actors create tenants in bulk for pre-positioning, commercial resale, or future activation. The system has no memory of previously-remediated operators — they return using identical registration details. Enforcement without re-entry prevention is containment without cure.

**3. Detection aperture gaps.** Current detection operates on storage and egress thresholds for specific SKU types. Patterns that don't produce large storage footprints — dormant pre-positioning, below-threshold exploitation, identity manipulation, collaboration-feature abuse — sit outside the detection envelope. The EDU segment exemplifies this: 50,000+ tenants with classification mismatches occupy provisioned capacity with zero revenue, zero users, and zero legitimate activity. They were invisible until investigated.

**4. Platform weaponization.** Fraudulent tenants serve as phishing infrastructure and malware-delivery CDNs. Attackers leverage sharepoint.com and onedrive.live.com domain reputation because enterprise mail filters trust Microsoft URLs. Every undetected fraudulent tenant is a potential brand damage vector, a regulatory liability under the EU DSA and UK Online Safety Act, and a competitive gap relative to Google and Dropbox — both of which now ship default-on trust features that ODSP lacks.

The trajectory is structural: cloud replaces physical media for content distribution, AI lowers the barrier at every stage of the fraud lifecycle (automated registration, synthetic identity generation, behavioral evasion), and regulatory obligations compound. The problem does not plateau.

<br>

---

<br>

## 2. The Definition Must Evolve

ODSP's current fraud program targets a specific set of behaviors: storage-intensive abuse (piracy CDNs, illicit streaming, cloud-backup-as-a-service), low-engagement tenants (high storage, near-zero MAU), SKU exploitation (free/EDU plans for commercial storage), and malicious content hosting (phishing, malware via MDO/Sonar). This scope has produced results — 99.7% precision, 26K+ remediations, 90+ PB reclaimed.

But the operative detection aperture is narrower than the problem it names. Detection triggers primarily on storage/egress thresholds for specific SKU types. If abuse doesn't produce a large storage footprint, it's invisible: provisioning shells with zero storage, dormant tenants pre-positioned for future activation, EDU tenants masquerading as schools, collaboration-feature exploitation through share links and OAuth consent. The definition isn't wrong — it's incomplete for where the threat has migrated.

**Where the industry has moved.** Across commercial cloud peers, the operative definition has shifted from "resource consumption inside the tenant" to "the tenant as attack surface and attack instrument." Google Workspace's AUP explicitly prohibits creating accounts not assigned to individuals and reselling user accounts. Dropbox enforces sharing-only suspension states. Meta's fraud taxonomy separately categorizes *inauthentic identity*, *platform manipulation*, and *evasion* as distinct abuse types — not just resource theft. The Trust & Safety Professional Association (TSPA) curriculum frames platform abuse across four axes: economic harm, external harm, access deception, and control subversion.

### The proposed expanded definition

> **ODSP Fraud & Abuse** = Any use of ODSP-provisioned tenant resources, identity, or collaboration features that is:
>
> **(a) Commercially illegitimate** — extracting value without authorization or proportional payment. A piracy CDN on a $2.25 SKU. A free-tier tenant consuming petabytes. A trial cycler resetting every 30 days.
>
> **(b) Harmful to external parties** — using the tenant as attack infrastructure. Phishing delivery via sharepoint.com links. Malware staging. Credential harvest pages hosted on onedrive.live.com.
>
> **(c) Deceptive in access** — misrepresenting identity, organizational eligibility, or purpose to obtain resources. Commercial entities in the EDU pipeline. Bulk provisioning under synthetic identities. CSP partners creating tenants for unauthorized resale.
>
> **(d) Designed to subvert platform controls** — re-entry after enforcement, dormant pre-positioning for future activation, threshold manipulation to stay below detection, and identity rotation to evade enforcement history.

This definition is signal-agnostic — it doesn't privilege any detection surface. A zero-storage provisioning shell (c/d), a below-threshold free-service exploiter (a/d), a phishing host with 50 MB of content (b), and a multi-PB piracy CDN (a) are all fraud under this framing.

The four categories also map directly to detection investments later in this paper: (a) is addressable by storage/egress rules and the DS model; (b) by MDO/Sonar and content scanning; (c) by registration-time signals and identity verification; (d) by cross-tenant network analysis and the Tenant Risk Score. No single detection channel covers all four — which is why the detection model requires multiple complementary approaches.

<br>

---

<br>

## 3. Current State: What We Do Today

### Detection

Three complementary detection channels operate today *(Data: July 2025 – April 2026)*:

| Channel | How it works | Scale | Strengths | Limitations |
|---------|-------------|-------|-----------|-------------|
| **Detection Automation (Rules)** | Threshold-based: storage × egress × MAU on specific SKUs | ~47K tenants flagged | 99.7% precision, config-driven, scalable | Storage-only signal, SKU-restricted, adaptive decay |
| **DS Model** | ML scoring trained on confirmed fraud labels | ~720 tenants (2026 model) | 0% FP rate, finds compound patterns rules miss | Coverage limited by training labels |
| **Investigations** | Human-driven pattern discovery, bulk analysis | 700+ tenants across 16 investigations | Discovers net-new vectors, produces ground truth | Doesn't scale without tooling; operator-dependent |

<br>

### Remediation

A graduated pipeline: **ReadOnly → Block → Delete** over defined time windows (15-day, 30-day variants). Processing via Durable Task Framework orchestrations. 95.8% of modern enforcement flows through automation. The pipeline processes thousands of tenants reliably but has limited observability — tenants stuck in intermediate states can remain unresolved for 30+ days without alerting.

### Malicious Link Enforcement

- **MDO/Sonar integration** for authenticated file detonation and malicious link takedown (~80% success rate, improving toward 99%)
- Covers link-level and file-level abuse: phishing lures, malware-hosting, credential harvests served from SPO/ODB

### Tooling & Infrastructure

- **MCP server** for accelerated investigation (20 min/tenant → <5 min per tenant)
- **Blocklist infrastructure** created (8 signal types across 160+ confirmed fraud tenants) — not yet integrated into provisioning
- **CFAR signal sharing** in early stages (access under privacy/data review)
- **Performance dashboard** for operational metrics and pipeline health

<br>

---

<br>

## 4. Why the Current Model Breaks

> *Analysis period: November 2025 – April 2026, based on detection pipeline telemetry and rule effectiveness tracking.*

The system was built for one threat — large-storage abuse on developer and education SKUs — and it works for that threat. But the threat has diversified, and the system hasn't. Five structural failures define the boundary of what the current model can and cannot do. They are not independent; they compound.

<br>

### 1. Detection sees a fraction of the problem

**Feed gap:** 97%+ of tenants flagged by the DS model were never evaluated by the rule engine. The input funnel itself has blind spots — a rule with 100% precision is irrelevant if most fraud never reaches it.

**SKU gap:** Rules cover only developer/EDU SKUs. Confirmed fraud on paid commercial SKUs (F1 Kiosk, SPlan2, Business Basic) is invisible. Removing SKU restrictions on a single rule would expose 7+ PB of known undetected fraud. The EDU investigation found thousands of tenants with invalid claims auto-approved because upstream pipelines never validated institutional identity.

The estimated undetected fraud surface is conservatively several multiples of what the system catches today.

### 2. Rules decay faster than we can build them

4 of 5 production rules declined 94–100% in effectiveness within five months. The pattern is consistent: every rule that relied on behavioral or configuration signals — app fingerprints, egress patterns, user-count ratios — was evaded by adjusting exactly the parameter it measured. The sole survivor measures raw storage volume, which is hard to fake because storage is the commodity the actor needs.

Three dynamics make this structural, not fixable by building rules faster:

- **Evasion is cheap.** A rule takes weeks to design, validate, and deploy. Evading it requires adjusting one parameter — splitting storage across tenants, adding dummy users, swapping the upload tool. The cost asymmetry is 100:1 or worse.
- **Enforcement leaks signal.** When we act on a tenant, the operator learns which configuration triggered detection. Actors running multiple tenants with slight variations can compare which survived to deduce the rule logic. Every enforcement action teaches the adversary.
- **Decay is silent.** No rule health monitoring exists. A fully-evaded rule continues running for months, catching nothing, and nobody knows until someone manually checks. By the time decay is discovered, the evasion pattern has propagated.

The implication: rules are necessary for known, stable signals — but building more of them faster doesn't change the fundamental dynamic. Rule *diversity* (signals the actor can't observe or cheaply manipulate) and *model-based scoring* of compound patterns are the architectural exits.

### 3. Detection is structurally late

95% of rule-caught tenants are over one year old at detection. Rules require 10–20 TB of accumulated storage to trigger — by design, they cannot catch early-stage or zero-storage abuse. Late detection means the adversary's ROI is fully realized before enforcement begins; phishing damage is done in days, not months; and every month of undetected abuse is un-reclaimed COGS.

### 4. The system has no memory

A remediated actor re-registers with the same email, phone, and address — and the system treats them as new. No provisioning gate, no identity lookup, no cross-tenant similarity detection. Enforcement becomes a *delay*, not a *resolution* — an operating cost the adversary prices in.

### 5. Every tenant is evaluated in isolation

The system evaluates each tenant atomically — no cross-tenant correlation, no network view, no operator-level intelligence. A ring of 50 tenants operated by the same actor, registered with related emails, sharing infrastructure, and overlapping admin identities, looks like 50 independent tenants. Each one is separately below threshold. None triggers individually.

This is the gap that organized fraud exploits most directly. Sophisticated operators distribute storage, users, and activity across tenants specifically to stay below per-tenant detection thresholds. Without a network layer that connects related tenants, the system is structurally blind to the most damaging class of abuse — coordinated rings that individually appear benign.

### How these failures compound

> A fraud actor provisions on a commercial SKU **(invisible)**. Accumulates storage slowly **(undetectable for 12+ months)**. When a rule triggers, adjusts one parameter **(evaded)**. If caught, re-registers with identical details **(no memory)** across multiple new tenants that individually stay below threshold **(no network view)**. Cycle repeats.

These failures span five dimensions — **breadth, speed, resilience, prevention, network intelligence** — and addressing any one in isolation produces diminishing returns. The investment case is for the *system*, not any single component.

<br>

---

<br>

## 5. Competitive Landscape: Where We Lag and Why It Matters

One structural pattern explains most of the gaps below: competitors have moved trust and abuse infrastructure **into the product surface as default-on features**, while Microsoft fragments equivalent capabilities across Entra ID, Defender, and ODSP as separate admin tools behind separate SKUs. But the gap extends beyond UX — it spans detection architecture, provisioning controls, measurement, enforcement, policy, and operational automation.

| Dimension | Competitor state | ODSP state | Implication |
|-----------|-----------------|------------|-------------|
| **Detection architecture** | Google: abuse classifiers at upload, share, and access (3 real-time checkpoints). Dropbox: content scanning at upload. Box Shield: ML for anomalous download patterns. | Post-hoc batch detection. DS model scores annually. Rules evaluate accumulated storage (10+ TB). No real-time inference at upload/share for fraud signals. | Competitors detect at the *action* level; ODSP detects at the *accumulated-state* level — structurally late. → Section 6 |
| **Enforcement granularity** | Google: file quarantine → sharing restriction → account suspension → termination. Dropbox: link block → sharing-only suspension → full suspension. Box: feature throttle → suspend → terminate. | Link/file takedown (MDO/Sonar) + tenant-level R-B-D. **Missing middle:** no sharing-suspension, no user-level action, no intermediate tenant state. | Binary enforcement creates over-caution or over-punishment. → Section 7 |
| **Provisioning prevention** | Google: phone verification, CAPTCHA, behavioral scoring, device/IP reputation — all at signup in real-time. Published academic work on bulk-creation detection. | Commerce evaluates payment risk via Risk Reputation Service (RRS), but ODSP neither consumes RRS nor feeds signals upstream. No identity memory. Remediated actors re-register immediately. | Every remediation is structurally temporary. An existing Commerce risk signal goes unconsumed. → Section 7 |
| **Measurement & transparency** | Google: quarterly Transparency Report (content removals, suspensions by category, per-product). Dropbox: bi-annual (government requests). | No public-facing abuse metrics. Internal = storage reclaimed only. No EFR, no detection coverage, no precision reporting. | Can't demonstrate improvement, justify investment, or satisfy DSA Article 15 transparency mandates. → Section 8 |
| **AUP specificity** | Dropbox AUP enumerates prohibited fraud patterns (bulk signup, referral abuse, proof-of-storage, unauthorized resale). Google AUP prohibits non-individual accounts and CDN use. Both tie violations to enforcement actions. | MSA has broad clauses. ODSP-specific fraud patterns not enumerated. No published enforcement-state matrix. | Vague language creates friction on every CELA escalation and weakens DSA Article 14 posture. |
| **AI/automation in ops** | Google: >99% of content enforcement automated via classifiers. Human review for borderline/appeals only. Dropbox: automated link blocking for known-bad content. | MDO/Sonar automates link enforcement. R-B-D automated for rule matches. But *novel detection* (investigations, pattern discovery) is fully manual. MCP tooling nascent. | Automation gap is in detection discovery, not enforcement execution. → Section 6, Section 7 |

**What's architecturally outside FAB's control:** OAuth/app reputation lives in Entra ID (requires partnership to surface in ODSP). Provisioning gating requires Commerce integration to consume TRS/blocklist signals. Both are cross-team dependencies registered in the roadmap (Section 9), not direct builds.

<br>

---

<br>

## 6. The Detection Model: Rules, Patterns, and Data Science

No single detection approach works alone. The adversary is too adaptive for rules, too novel for DS models, and too numerous for manual investigation. The model is a **flywheel** — each component's output feeds the next:

> **Investigations** (discover novel patterns) → **DS Models** (learn from confirmed labels) → **Rules** (codify stable signals) → **Decay signals** (reveal evasion) → **Investigations** (discover what changed)

The flywheel only turns if all three components are invested in. Remove any one, and the system degrades: rules without investigations ossify against yesterday's threats; models without fresh labels drift; investigations without rules-at-scale can't enforce what they discover.

### What each tool is good at — and where it breaks

| | **Rules** | **DS Models** | **Investigations** |
|---|---|---|---|
| **Sweet spot** | Known patterns with stable, measurable signals — app fingerprints, egress ratios, provisioning velocity | Population-level scoring, similarity detection, prevalence estimation across 10K+ tenants | Unknown-unknowns. Ground truth generation. Novel pattern identification |
| **Structural limit** | Anything the adversary can observe and evade. Anything requiring compound judgment | Cold-start on new abuse types. Coverage gaps when training labels are narrow | Scale — human-driven work doesn't cover 10,000s of tenants per quarter |
| **Decay mode** | Evasion: actors modify exactly the signal the rule measures | Label rot: fraud evolves away from historical training distribution | Knowledge loss: findings stay in one person's head, never codified |

### Where we're imbalanced today

The flywheel is lopsided. Rules are over-indexed — 5 production rules maintained by an external system with no health monitoring. DS is under-invested — one model refresh per year, trained on historical labels only. Investigations are ad-hoc — no cadence, no systematic output channel, dependent on individual initiative.

**The rebalancing:**

| Component | Current state | Target state |
|-----------|--------------|--------------|
| **Rules** | 5 static rules, no decay monitoring | Expanded scope (SKU, backfill, new signals) + lifecycle management + health dashboards |
| **DS Models** | Annual refresh, storage-only labels | Quarterly refresh, label expansion beyond storage, prevalence estimation as a product |
| **Investigations** | Ad-hoc, tooling-limited | Quarterly cadence, MCP + multi-agent tooling, output explicitly feeds rule proposals and DS labels |

### The missing synthesis layer: Tenant Risk Score

The flywheel produces detection outputs — but those outputs remain disconnected. Rules emit binary flags. The DS model produces an annual score for a subset of tenants. Investigations produce one-time ingestion lists. No unified, continuous view of tenant risk exists.

A **Tenant Risk Score (TRS)** fills this gap: a continuous 0–100 score assigned to every tenant, updated daily, drawing from all three detection channels plus registration, behavioral, and identity signals. It is what the flywheel *produces* — and what enforcement, measurement, and provisioning all *consume*.

**What becomes possible:**

- **Prioritized investigation queue** — score-ranked rather than ad-hoc selection from flag lists
- **Graduated enforcement** — proportional response by score tier, not binary flag-or-nothing
- **Provisioning-time detection** — registration features scored at creation; high-risk tenants flagged before they store a single byte
- **Re-entry detection** — fuzzy similarity scoring surfaces new tenants that resemble remediated actors, beyond exact-match blocklists
- **Ecosystem fraud rate** — score distribution across the population yields prevalence estimates, calibrated against expert review
- **Cross-team consumption** — partners receive a single number ("risk score: 82") rather than needing to understand our rules or model internals

**Architecture:** Gradient-boosted model (LightGBM) trained on confirmed fraud + confirmed legitimate tenants. Features span five signal families: registration (provisioning velocity, email domain risk, naming entropy), behavioral (storage trajectory, MAU ratios, egress patterns), identity (admin clustering, prior enforcement history), Commerce signals (the Commerce platform's Risk Reputation Score, which evaluates payment risk, device fingerprints, and IP reputation at transaction time), and existing model outputs. Commerce RRS is particularly high-value because it captures signals ODSP never observes — payment instrument risk, device trust, and transaction-time behavioral patterns. Daily batch scoring for all tenants; near-real-time scoring at tenant creation.

**Phased delivery — three programs, two gates.** TRS is not a single project on a 6-month slide; it is three sequential programs with explicit go/no-go gates between them.

| Phase | Scope | Timeline |
|-------|-------|----------|
| **Phase 0** | Feasibility PoC (intern-led with DS mentorship). Feature extraction prototype on sampled population, baseline model on existing labels, handoff documentation. Not a deployable system — evidence that the production investment is worth making. | FY27H1 (6–8 weeks) |
| **Gate 1** | Greenlight decision: are signals predictive at acceptable cost? Is the feature pipeline tractable on production infra? If yes → fund Phase 1. If no → rules + DS continue as primary detection; no TRS dependency in downstream plans. | End of FY27H1 |
| **Phase 1** | Production v1. Daily batch scoring across all tenants, production feature pipeline, model retraining cadence, drift monitoring. Consumed initially by investigation prioritization. | FY27H2 (6–9 months, FAB SWE + DS) |
| **Gate 2** | Production-readiness review: score reliability, calibration stability, and operational maturity sufficient to gate provisioning decisions and graduated enforcement. | End of FY27H2 |
| **Phase 2** | Provisioning & enforcement integration. Near-real-time scoring at tenant creation; integration with Entra, Commerce/RRS, and the graduated enforcement matrix. Privacy review on the critical path. | FY28+ (cross-team) |

The gates matter: Phase 0 is bounded effort with bounded risk. Phases 1 and 2 are the real investment and should be greenlit on evidence. The strategy has TRS-dependent and TRS-independent paths — the gates make clear when each is committed.

<br>

---

<br>

## 7. Key Capability Investments

### Human Verification Layer (HVL)

**Direction:** Shift from relying exclusively on platform-side telemetry to a shared accountability model where tenants provide signals about their legitimacy. Add measured friction where suspicion exists — not as punishment, but as telemetry procurement.

**Examples:** Challenge-response at provisioning for flagged patterns. Periodic re-verification for tenants matching behavioral risk profiles. Self-service proof-of-legitimacy flows that remove enforcement when completed (auto-unlock).

**Why this matters:** Current detection is limited to what we can observe externally. HVL produces signals the tenant must actively provide — signals that are expensive for fraud actors to fabricate at scale but trivial for legitimate organizations.

### Investigations as Ground Truth Engine

**Direction:** Systematize pattern discovery into a recurring, tooling-accelerated operation. Investigation output explicitly feeds DS model labels and new rule proposals — closing the flywheel loop.

**Why this matters:** Every investigation conducted to date has found patterns invisible to existing rules. Investigations are the only source of *novel* ground truth — they find what you didn't know to look for. With MCP tooling reducing per-tenant analysis time by 75%+, the economic case for systematic investigation has improved significantly.

### Granular Enforcement

**Direction:** Expand enforcement from tenant-level-only to multi-level:

| Level | Action | Use case |
|-------|--------|----------|
| **Link/file** | Quarantine, takedown, detonation | Malicious shared links, malware hosting (MDO/Sonar) |
| **Sharing** | Suspend external sharing, retain internal access | Suspected phishing infrastructure; intermediate state before full block |
| **User** | Block specific users without tenant-wide impact | Compromised accounts within legitimate tenants |
| **Tenant** | ReadOnly → Block → Delete | Confirmed full-tenant fraud (current model) |

### Auto-Unlock / Self-Authentication

**Direction:** Build high-confidence workflows where legitimately-blocked tenants can self-authenticate and remove enforcement — without requiring support escalation. This reduces support load while maintaining enforcement courage (we can act more aggressively if the undo path is available for legitimate tenants).

**Requirements:** Workflows must be designed to be non-gameable — identity verification, behavioral attestation, admin proof steps that are expensive to fake at scale.

### Re-Entry Prevention

**Direction:** Close the provisioning gap. Today, a remediated actor re-registers immediately using identical details. Integration path:

0. **Commerce RRS consumption** (immediate opportunity): The Commerce platform already computes a Risk Reputation Score at tenant creation time using payment, device, and IP signals. Consuming this score as a TRS input feature requires no new signal infrastructure — only a data feed. This is the lowest-cost, highest-leverage first step because the signal already exists in production.
1. **Blocklist daily sweep** (near-term): Match new tenants against known-bad indicators. Catch re-entry within 24 hours.
2. **Provisioning gate** (medium-term): Hard-block at tenant creation for confirmed indicators. Soft-flag for medium-confidence. Feed TRS and blocklist signals upstream to Commerce so that provisioning decisions incorporate ODSP-specific fraud intelligence — making the integration bidirectional.
3. **Behavioral detection at registration** (longer-term): Provisioning velocity, sequential naming, gibberish patterns, shared-phone clustering — all detectable at creation time.

<br>

---

<br>

## 8. Measuring Success: Three North Stars + Impact

### Why current measurement is insufficient

Today, FAB measures impact through **storage reclaimed** — petabytes remediated, COGS saved. This metric is important but structurally incomplete: it counts only storage-consuming fraud, biases investment toward large-storage actors, and says nothing about whether the ecosystem is getting healthier or whether enforcement actions persist.

### Proposed measurement framework

**Three North Stars** (ecosystem health) + **One Impact Indicator** (financial accountability):

| Metric | Question it answers | Sub-dimensions |
|--------|-------------------|----------------|
| **Ecosystem Fraud Rate (EFR)** | "How dirty is our ecosystem?" | % of active tenants estimated fraudulent, stratified by SKU/segment. Trend over time. |
| **Detection Efficacy (DE)** | "How well do we find it, and how fast?" | Coverage (% of estimated fraud identified), Time-to-Detection (median days from creation to catch), Precision (1 - FP rate) |
| **Containment Durability (CD)** | "When we act, does it stick?" | Remediation hold rate, re-entry prevention rate, link takedown success rate, time-to-re-entry-detection |
| **COGS Protected** | "What's the financial impact?" | TB reclaimed + TB prevented via early detection/provisioning blocks. Dollar-convertible. |

### How EFR works (the hardest metric)

EFR requires a prevalence estimator — something that can score all tenants on a risk continuum and then be calibrated against human review. Initially, this can use the existing DS model at multiple confidence thresholds. Once the Tenant Risk Score is operational, EFR computation simplifies: the TRS distribution across the population, calibrated against expert spot-checks, *is* the prevalence estimate — continuously computable rather than a periodic exercise.

The calibration process:
1. Score all tenants (via DS model initially, TRS long-term)
2. Human spot-check validation on random samples from each score band
3. Extrapolate: estimated total fraud = Σ (tenants in band × validated true-positive rate for that band)
4. Report quarterly with confidence intervals

EFR's confidence bands will be wide initially and narrow over time as ground truth grows.

### Maturation path

| Timeframe | What's measurable |
|-----------|-------------------|
| **Today** | COGS Protected (already reported). DE: TTD + Precision (queryable from pipeline). |
| **FY27H1** | EFR floor estimate on developer/EDU segments. CD: hold rate (pipeline data). |
| **FY27H2** | Full EFR with calibration (contingent on TRS v1 deployment). CD: re-entry rate once blocklist sweep is live. DE: Coverage derivable. |
| **FY28** | All four metrics operational across segments. Consumer segments added. |

### The strategic insight these metrics create

> The gap between COGS Protected (“we reclaimed 90 PB”) and EFR (“we estimate X% of tenants are still fraudulent”) **is itself the investment case**. It quantifies what we can’t see. It says: “We’re effective at finding storage fraud. We’re blind to the rest of the problem. Here’s what’s needed to close the gap.”

<br>

---

<br>

## 9. Roadmap

The roadmap is organized by workstream, each mapped to the structural failure it addresses (Section 4). Items are sequenced: near-term work creates the foundation that medium-term investments depend on.

### Workstream 1: Detection Breadth (addresses Section 4.1 — coverage gap)

| Horizon | Item | Impact |
|---------|------|--------|
| **FY27H1** | SKU expansion for Rules 4/5 — remove developer/EDU restriction | Exposes 7+ PB of invisible fraud on commercial SKUs. Single largest COGS Protected gain available. |
| **FY27H1** | CDN score rule (egress:ingress ratio >100:1) | Catches distribution-pattern abuse regardless of SKU |
| **FY27H1** | Niche abuse-tool rules: Cloudreve, StableBit fingerprints | Near-zero FP, small catch volume, every hit is confirmed fraud |
| **FY27H1** | DS model refresh with expanded labels (cross-team w/ DS) | Coverage beyond storage-only signals. FAB provides structured label pipeline from investigations |
| **FY27H2** | Input table broadening — close the feed gap | Makes the DS model's full flagged population evaluable by the rule engine |

### Workstream 2: Detection Resilience (addresses Section 4.2 — rule decay)

| Horizon | Item | Impact |
|---------|------|--------|
| **FY27H1** | Rule health monitoring with automated decay alerts | Ends silent decay. Dead rules detected in days, not months |
| **FY27H1** | Rule lifecycle management (build → monitor → decay → retire/refresh) | Shifts rules from static configs to managed assets |
| **FY27H2** | TRS as compound scorer (see Workstream 4) | Model-based detection replaces threshold-only rules as primary signal |

### Workstream 3: Enforcement Durability & Re-Entry Prevention (addresses Section 4.3 timing, Section 4.4 memory)

| Horizon | Item | Impact |
|---------|------|--------|
| **FY27H1** | Blocklist daily sweep — match new tenants against 8 known-bad signal types | First memory system. Catches re-entry within 24 hours |
| **FY27H1** | V2 remediation pipeline (DTF-based) + stuck-state observability | Zero tenants stuck in intermediate enforcement state >7 days |
| **FY27H1** | Sonar Phase 0 completion — authenticated file detonation | Link takedown success rate ≥95%. Reduces external harm window |
| **FY27H2+** | Provisioning gate — hard-block at creation for confirmed indicators | *Requires TRS v1 + Entra/Commerce partnership.* Shifts from post-hoc detection to pre-provisioning prevention |
| **FY27H2+** | Auto-unlock self-service — high-confidence recovery for legitimate tenants | Enables aggressive enforcement because the undo path exists |

### Workstream 4: Intelligence & Measurement (addresses Section 4.5 — no network view, and measurement gap)

| Horizon | Item | Impact |
|---------|------|--------|
| **FY27H1** | TRS Phase 0 — feasibility PoC (intern-led, 6–8 weeks) | Evidence base for production investment decision |
| **FY27H1** | Gate 1 — greenlight decision: fund Phase 1 or adjust strategy | Go/no-go on TRS-dependent investments |
| **FY27H1** | EFR floor estimate (dev/EDU segments) | First prevalence metric. Quantifies what we can't see — the investment case |
| **FY27H1** | CFAR bidirectional signal sharing | FAB ground truth → CFAR models. CFAR detections → FAB pipeline |
| **FY27H1** | Commerce RRS exploration (stretch) | Feasibility validated, integration design documented for TRS v2 |
| **FY27H2** | TRS v1 — production daily scoring across all tenants (gated on Phase 0) | Unified risk view. Investigation prioritization. Cross-tenant similarity detection |
| **FY27H2** | EFR quarterly reporting across all SKU segments with calibration | Ecosystem health metric operational (contingent on TRS v1) |
| **FY28+** | TRS v2 — provisioning gating + enforcement integration | Near-real-time scoring at creation. Graduated enforcement tiers |

### Workstream 5: Enforcement Granularity (addresses competitive gap — Section 5)

| Horizon | Item | Impact |
|---------|------|--------|
| **FY27H2+** | Sharing-suspension enforcement state | Intermediate between "normal" and "ReadOnly." Competitors already have this |
| **FY27H2+** | User-level enforcement — block users without tenant-wide impact | Handles compromised accounts within legitimate tenants |
| **FY27H2+** | Graduated enforcement matrix — published internally, then externally | Clear, defensible enforcement framework for CELA and regulatory posture |

### Long-Term Vision (3–5 years)

- **Prevention-first model**: Majority of fraud detected at registration time, not 12+ months later
- **Cross-cloud reputation signals**: Industry collaboration on provisioning-abuse indicators (analogous to PhotoDNA for CSAM, but for tenant-level fraud)
- **Zero-touch investigation**: Human review only for truly novel patterns; known archetypes handled automatically
- **Full DSA/OSA enforcement transparency**: Published enforcement-state matrix, public reporting on fraud actions
- **Consumer FAB**: Different architecture, different scale — requires dedicated charter and headcount

### Cross-Org Dependencies

Most workstreams above require cross-team partnership. Key dependencies:

| Partner team | What FAB needs | Why |
|-------------|---------------|-----|
| **Entra ID** | Provisioning-time signals, app reputation data | Gate at tenant creation, OAuth abuse detection |
| **Defender / Purview** | File quarantine signals, DLP triggers | File-level enforcement, share-link reputation |
| **Commerce / CSP** | Channel fraud signals, payment anomalies | Synthetic-tenant detection through partner provisioning |
| **CFAR** | Bidirectional signal sharing (their detections → our pipeline, our ground truth → their models) | Detection coverage expansion, deduplication |
| **DS team** | Quarterly model refresh, prevalence estimation collaboration, label expansion | EFR computation, model coverage beyond storage |

<br>

---

<br>

## 10. Above/Below the Line — FY27H1

The team is ~8 engineers (IDC) plus DS collaboration. The cut line reflects what can ship with current headcount vs. what requires additional investment, cross-org partnership, or platform capabilities that don't yet exist. The principle: **above the line delivers measurable improvement on the five Section 4 failures within the semester; below the line builds capabilities that depend on above-the-line foundations being in place.**

### Above the Line (Ships with current resources)

| Item | Which Section 4 failure | Metric impact | Dependency |
|------|------------------|---------------|------------|
| SKU expansion for R4/R5 | Coverage gap | COGS Protected ↑↑, DE Coverage ↑ | None — config change + validation |
| CDN score + niche tool rules | Coverage gap | DE Coverage ↑ | None |
| Rule health monitoring + decay alerts | Rule decay | DE sustained | None |
| DS model refresh with expanded labels | Coverage gap, decay | DE Coverage ↑ | DS team partnership |
| Blocklist daily sweep | No memory | CD Re-entry ↑ | None — Kusto automation |
| V2 remediation pipeline + stuck-state observability | Enforcement reliability | CD Hold Rate ↑ | None — in-flight |
| Sonar Phase 0 completion | Late detection (external harm) | CD Takedown ↑ | MDO partnership |
| TRS Phase 0 → v1 (PoC through production scoring) | No network view | Investigation prioritization, cross-tenant detection | DS collaboration, intern for Phase 0. v1 gated on Phase 0 greenlight |
| EFR floor estimate (dev/EDU) | Measurement gap | First prevalence metric | DS collaboration |
| CFAR bidirectional signal sharing | Coverage gap | Detection expansion | CFAR partnership |

### Below the Line (Requires additional investment or prerequisites not yet met)

| Item | Why below | What unblocks it |
|------|-----------|-----------------|
| Provisioning gate (hard-block at creation) | Requires TRS v1 in production + Entra/Commerce integration + privacy review | TRS v1 ships FY27H2 (gated on Phase 0). Cross-org partnership scoped in FY27H2, builds in FY28+. |
| HVL challenge-response | Requires tenant-facing UX infrastructure that doesn't exist. Design work not yet started | UX design scoping could begin in FY27H1; build is FY27H2+ |
| User-level enforcement | SPO platform capability build — not a FAB-only ship | Requires SPO platform investment decision |
| Auto-unlock self-service | Depends on HVL design patterns + abuse-resistant verification flows | HVL design (above) informs this |
| Sharing-suspension enforcement state | SPO platform work. Intermediate state between "normal" and "ReadOnly" | SPO platform investment decision |
| Consumer FAB scoping | Different architecture, different scale. Requires dedicated charter + headcount | Organizational decision, not technical |
| Commerce RRS integration (beyond exploration) | Data feed feasibility not yet validated. Stretch exploration in S2 | S2 exploration (above the line) determines feasibility |

**The key sequencing dependency:** TRS Phase 0 (FY27H1) validates feasibility; if Gate 1 greenlights, TRS v1 (FY27H2) unlocks the highest-impact below-the-line items — provisioning gating, graduated enforcement tiers, and EFR at full scale. Phase 0 is bounded effort with bounded risk. The real investment decision comes at Gate 1.

<br>

---

<br>

## 11. Cost of Inaction

If FAB continues at current investment level and scope for 24 months, each Section 4 failure compounds unchecked:

**The coverage gap widens.** Commercial SKUs (F1, SPlan2, Business Basic) remain unmonitored. At current abuse creation rates, the undetected fraud surface — already conservatively several multiples of what we catch — grows with platform adoption. Every new tenant provisioned on an unmonitored SKU is invisible by design. The 7+ PB of known undetected fraud on commercial SKUs identified in Section 4 is the *floor*, not the ceiling.

**Rule decay continues silently.** Without health monitoring, rules that have already lost 94–100% effectiveness remain in production indefinitely, creating the illusion of coverage. New rules built against today's evasion patterns will follow the same decay curve. The detection system appears operational while catching a shrinking fraction of abuse.

**Re-entry remains free.** Without blocklist infrastructure or provisioning gates, every remediation is structurally temporary. The 26,000+ remediations to date represent enforcement effort, not enforcement outcomes — a remediated actor who re-registers immediately and is undetectable for another 12+ months was never actually stopped.

**COGS exposure grows uncapped.** The cheapest commercial SKUs provide effectively unlimited storage for $2.25/month. With no detection on these SKUs, the COGS gap between what we charge and what abuse consumes widens with every provisioned tenant. Storage costs compound — this is not a stable-state problem.

**Regulatory risk materializes.** DSA fines for VLOPs can reach 6% of global annual turnover. The UK OSA imposes proactive detection duties. Microsoft's AUP specificity relative to competitors (Dropbox and Google enumerate specific prohibited fraud patterns — bulk signup, CDN use, account resale — while Microsoft relies on broad umbrella clauses) creates enforcement-basis risk when a regulator asks "what did you know and when did you act?"

**Brand damage accumulates.** Every phishing campaign staged from sharepoint.com that appears in security research erodes enterprise trust in the platform. This is not hypothetical — Microsoft Threat Intelligence flagged LOTS (living-off-trusted-sites) attacks using SPO/ODB in October 2024. Google's default-on protections make this a competitive differentiator they actively market.

<br>

> The strategy outlined here is not about building a larger enforcement machine. It is about building a *smarter* one — one that detects faster, acts at the right granularity, prevents re-entry, and measures whether the ecosystem is actually getting healthier. The cost of building it is a fraction of the cost of not having it.

<br>

---

*End of document.*
