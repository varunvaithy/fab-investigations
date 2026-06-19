# CY2026 Semester 2 — FAB Planning Doc (Draft)

| | |
|---|---|
| **Author** | Varun V |
| **Status** | Brainstorm / Planning |
| **Scope** | July – December 2026 |
| **Team** | ~8 engineers (IDC) + DS collaboration |

---

## Context: Where S1 Leaves Us

S1 OKRs (O4–O6) established the enforcement foundation:
- CFAR + ODSP see same fraud list ✓
- 99% reliable tenant remediation ✓  
- MDO/Sonar link takedown at ~90% ✓
- Investigations absorbed from HIT team ✓

**S2 shifts from "build the machine" to "expand what it sees, harden how it works, and measure whether we're winning."**

---

## Proposed Objectives & Key Results

### O1: Detection coverage expands beyond storage-only, commercial-only blind spots

*S1 proved the rules engine works. S2 expands what it can see and ensures it doesn't silently decay.*

| KR | Jan 2027 Baseline | June 2027 Goal | Type |
|---|---|---|---|
| **KR #1:** Detection automation covers all commercial SKUs | Dev/EDU only. Blind to F1, SPlan2, Business Basic. | All SKU types covered. ≥10 PB newly-detectable fraud exposure. | Achievable |
| **KR #2:** New detection rules shipped + rule health monitoring with decay alerts | 5 rules, no monitoring, silent decay (4/5 rules lost 94-100% effectiveness in 5 months) | 8+ rules in production. Health dashboard operational. Automated decay alerting. | Achievable |
| **KR #3:** DS model refreshed with expanded labels | 720 tenants scored, annual refresh, storage-only labels | Refreshed model with ≥2x label coverage. FAB provides structured label pipeline from investigations. | Cross-team (DS) |

**Engineering work under this objective:**
- Feed expansion (input table broadening to include commercial SKU tenants)
- Rule config changes + validation testing for SKU removal
- New rule implementation: CDN score (egress:ingress >100:1), Cloudreve, StableBit fingerprint
- Rule health monitoring service: decay detection, automated alerting, dashboard
- Label pipeline tooling: structured export from investigations → DS training format

---

### O2: Enforcement is durable — remediation sticks, links stay down, pipeline is reliable

*Direct continuation of S1 O5/O6. Engineering-heavy. Pipeline reliability, MDO/Sonar hardening, observability.*

| KR | Jan 2027 Baseline | June 2027 Goal | Type |
|---|---|---|---|
| **KR #1:** Abuse link takedown success rate ≥95% | ~90% (S1 goal) | ≥95% sustained. Authenticated detonation complete. | Achievable |
| **KR #2:** Remediation pipeline: zero tenants stuck in intermediate state >7 days | Tenants stuck 30+ days without alerting | Observability + auto-escalation live. Zero stuck >7d. | Achievable |
| **KR #3:** Re-entry detected within 24 hours — blocklist sweep operational | No re-entry detection. System has no memory. | Daily sweep matching new tenants against 8 blocklist signal types. Automated alerting on matches. | Achievable |

**Engineering work under this objective:**
- **MDO/Sonar:** Authenticated file detonation hardening, retry/fallback logic, success rate tracking, edge case handling
- **Remediation pipeline:** DTF orchestration observability, stuck-state detection + alerting, auto-retry for failed state transitions, dead-letter handling
- **Deletion pipeline:** Reliability improvements, data integrity validation, completion confirmation, logging
- **Blocklist sweep:** Kusto automation, new-tenant matching pipeline, alert routing, false-positive review workflow
- **Telemetry:** Pipeline health metrics, enforcement completion rates, stage-transition timing, failure categorization
- **Data logging:** Audit trail for all enforcement actions, enforcement-state history per tenant, support for debugging and compliance

---

### O3: FAB builds the intelligence + measurement layer

*TRS is the semester's "big bet." EFR is the first ecosystem health metric. CFAR goes bidirectional.*

| KR | Jan 2027 Baseline | June 2027 Goal | Type |
|---|---|---|---|
| **KR #1:** Tenant Risk Score v1 — scoring all tenants daily in production | Intern v0 (model + feature pipeline) | Production daily scoring across all tenants. Validated precision ≥90%. Integrated into MCP for investigation prioritization. | Audacious |
| **KR #2:** Ecosystem Fraud Rate (EFR) floor estimate published | No prevalence metric exists. Only measure = PB reclaimed. | First EFR number (dev + EDU segments) with methodology + confidence bands. | Achievable |
| **KR #3:** CFAR bidirectional signal sharing operational | "Same list" (S1) | FAB ground truth → CFAR models. CFAR detections → FAB pipeline. ≥1 CFAR signal triggering FAB enforcement action. | Cross-team (CFAR) |
| **KR #4:** Commerce RRS explored as TRS signal source [Stretch] | No integration. Commerce scores unused by ODSP. | Exploratory: data feed scoped, feasibility validated, integration design documented. Signal available for TRS v2. | Stretch |

**Engineering work under this objective:**
- **TRS productionization:** Kusto/Spark pipeline for daily batch scoring, feature store, model serving infrastructure, score API, MCP integration to surface scores in investigation workflows
- **TRS validation:** Precision measurement framework, human review calibration loop, score-band analysis
- **EFR methodology:** DS model scoring at multiple thresholds, stratified sampling for human validation, confidence interval computation, reporting automation
- **CFAR integration:** Signal routing pipeline (inbound + outbound), schema alignment, deduplication logic, action trigger mapping
- **Commerce RRS:** Data feed exploration, schema discovery, feasibility doc, integration design for v2

---

## Below the Line (HC Case / Future Semesters)

Items that are strategically important but require additional headcount, cross-org commitment, or platform capabilities not yet available:

| Item | Why it matters | What blocks it |
|---|---|---|
| **Provisioning gate** (hard-block at creation for confirmed indicators) | Only way to make enforcement permanent. Currently actors re-register freely. | Requires Entra + Commerce partnership, privacy review, TRS v1 must exist first |
| **User-level enforcement** (block users without tenant-wide impact) | "Missing middle" — current enforcement is too coarse. Over-punishes mixed tenants. | Platform capability build in SPO. Not a FAB-only ship. |
| **Auto-unlock self-service** | Enables enforcement courage — act aggressively knowing undo path exists for legit tenants. Reduces support load. | UX design, tenant-facing infra, abuse-resistant verification |
| **Sharing-suspension state** | Intermediate enforcement between "normal" and "ReadOnly." Competitors have this. | SPO platform work. Design + impl. |
| **Consumer FAB scoping** | Different architecture, different scale, growing abuse surface | Dedicated HC, cross-team charter |
| **Recurring phishing attacker blocking** | Repeat offenders currently re-attack from same tenant | May need user-level enforcement (above). Design reviewed in S1. |

---

## Themes for Discussion

### Theme A: Pipeline & Reliability Engineering
*What the 8 engineers spend most of their time on.*

- Remediation pipeline observability + self-healing
- Deletion pipeline reliability + completion guarantees
- Sonar/MDO integration hardening
- Data logging + audit trails (compliance, debugging, support)
- Telemetry instrumentation across all pipeline stages
- Alerting infrastructure (PagerDuty/ICM integration, escalation paths)
- Performance regression detection

**Open question:** Is "pipeline reliability" its own KR, or is it measured by outcomes (zero stuck tenants, 95% takedown rate)? Currently using outcome-based KRs.

### Theme B: Detection Breadth
*Expanding what we can see.*

- SKU expansion (biggest single COGS impact item)
- New signal types beyond storage (egress ratios, app fingerprints, provisioning velocity)
- Rule lifecycle management (build → monitor → decay → retire/refresh)
- DS model refresh cadence improvement

**Open question:** Should "Time-to-Detection" (median days from tenant creation to catch) be an explicit KR target? Currently it's a metric we track, not a KR.

### Theme C: Intelligence & Prevention
*The forward-looking bet.*

- TRS as the unified scoring layer everything else consumes
- Blocklist sweep as the near-term memory system
- Commerce RRS as future signal (stretch)
- EFR as the measurement that justifies future investment

**Open question:** TRS v1 for "all tenants" vs. "dev/EDU tenants first" — scoping decision. Full-population is more audacious but more useful.

### Theme D: Cross-Team Integrations
*Leverage points that multiply FAB's impact without proportional eng effort.*

- CFAR bidirectional flow
- Commerce RRS feed
- DS model refresh partnership
- MDO/Sonar deeper integration (authenticated detonation, phishing pattern sharing)

### Theme E: Tooling & Investigation Acceleration
*Making the humans faster.*

- MCP tooling improvements (multi-tenant batch analysis, score-ranked queues)
- Investigation output → structured labels (formalized, not ad-hoc)
- Multi-agent investigation workflows (longer-term)

**Open question:** Is investigation tooling improvement an explicit KR, or does it live implicitly under TRS integration + label pipeline?

---

## Capacity Sketch (8 engineers)

| Allocation | Engineers | Primary KRs served |
|---|---|---|
| Detection expansion (rules, feeds, SKU config, monitoring) | 2–3 | O1.KR1, O1.KR2 |
| Remediation + MDO/Sonar (pipeline reliability, deletion, observability, Sonar) | 3–4 | O2.KR1, O2.KR2, O2.KR3 |
| TRS productionization + CFAR + EFR (pipeline infra, data routing, scoring) | 1–2 | O3.KR1, O3.KR2, O3.KR3 |
| Varun + DS | — | TRS model work, EFR methodology, Commerce exploration |

**Note:** Allocation is approximate. Engineers move between streams as priorities shift within the semester.

---

## Decisions Needed

1. **TRS v1 scope:** All tenants (audacious) vs. dev/EDU only (safer)? → Current proposal: all tenants.
2. **Commerce RRS:** Stretch KR vs. drop entirely? → Current proposal: stretch/exploratory.
3. **Recurring phishing blocking:** Above or below the line? → Current proposal: below (needs platform support).
4. **Pipeline reliability KRs:** Is "zero stuck >7 days" sufficient, or do we need explicit deletion/telemetry KRs?
5. **Investigation work:** Implicit (feeds into O1.KR3 label pipeline) or explicit KR?

---

## Input Requested

- [ ] Eng team: pipeline reliability priorities, deletion pipeline scope, telemetry gaps
- [ ] DS team: model refresh timeline commitment, TRS v1 production requirements
- [ ] Commerce team: RRS feed feasibility, partnership appetite
- [ ] CFAR team: bidirectional flow readiness, schema/format alignment
- [ ] MDO/Sonar team: authenticated detonation status, S2 integration scope

---

*This is a living planning doc. Iterate themes → finalize KRs → port to OKR format.*
