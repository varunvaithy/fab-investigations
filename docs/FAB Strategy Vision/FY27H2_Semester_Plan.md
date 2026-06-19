# FAB FY27H2 Semester Plan

## Jan 1 – Jun 30, 2027

| | |
|---|---|
| **Team** | Fraud & Abuse (ODSP) |
| **PM** | Varun V |
| **Headcount** | 7 Eng, 1 PM, 1 DS (+ intern TBD) |
| **Status** | Draft — Planning |
| **Strategy Reference** | ODSP Fraud & Abuse Strategy Paper (May 2026) |

---

## 1. Semester Context

### What FY27H1 delivered (Jul–Dec 2026)

| Shipped | Impact |
|---------|--------|
| SKU expansion (R4/R5 on commercial) | 7+ PB of previously invisible fraud now detectable |
| CDN score + niche tool rules | Distribution-pattern abuse caught regardless of SKU |
| Rule health monitoring + decay alerts | No rule silently degrades undetected |
| DS model refresh with expanded labels | Coverage beyond storage-only signals |
| Blocklist daily sweep | Re-entry caught within 24 hrs for known patterns |
| V2 remediation pipeline + stuck-state observability | Zero tenants stuck in intermediate state >7 days |
| Sonar Phase 0 — authenticated detonation | Link takedown for authenticated content |
| TRS Phase 0 — feasibility PoC | Evidence base for production investment decision |
| EFR floor estimate (dev/EDU) | First prevalence metric |
| CFAR bidirectional signal sharing | Detection expansion via cross-team signals |

### Gate 1 Decision (end of FY27H1)

> **This plan assumes Gate 1 greenlights TRS v1.** If Gate 1 does NOT greenlight, see Section 7 (Contingency Plan).

Gate 1 criteria:
- Are the signals predictive at acceptable cost?
- Is the feature pipeline tractable on production infra?
- Does the PoC demonstrate meaningful lift over rules-only detection?

---

## 2. Semester Theme

**"From foundations to production systems."**

FY27H1 builds the building blocks. FY27H2 turns them into production-grade, continuously-operating systems that shift FAB from reactive enforcement to proactive ecosystem health measurement.

The three bets:
1. **TRS v1 ships** — unified risk scoring replaces fragmented flag lists
2. **Enforcement becomes durable** — re-entry is measured and declining, not assumed
3. **Ecosystem health is quantified** — EFR moves from estimate to operational metric

---

## 3. Objectives & Key Results

### Objective 1: Ship Tenant Risk Score v1 to Production

*Strategy ref: Section 4.5 (no network view), Section 6 (TRS phased delivery)*

| # | Key Result | Success Criteria | Gated on |
|---|-----------|-----------------|----------|
| 1.1 | TRS v1 scoring all tenants daily | Pipeline operational, <4hr latency, scoring 100% of active tenants | Gate 1 greenlight |
| 1.2 | Investigation queue score-ranked | No ad-hoc flag-list selection; analysts work top-down by risk score | KR 1.1 |
| 1.3 | Cross-tenant similarity detection live | Net-new fraud rings surfaced via fuzzy matching (not just exact blocklist) | KR 1.1 |
| 1.4 | Gate 2 review completed | Production-readiness assessment: score reliability, calibration stability, drift monitoring | KR 1.1 |

**Why this is #1:** TRS v1 is the single dependency that unlocks 3 of 7 below-the-line items from FY27H1 (provisioning gate, graduated enforcement, EFR at full scale). It's the semester's critical path.

---

### Objective 2: Make Enforcement Durable & Measurable

*Strategy ref: Section 4.3 (enforcement timing), Section 4.4 (no memory), Section 8 (measurement)*

| # | Key Result | Success Criteria | Gated on |
|---|-----------|-----------------|----------|
| 2.1 | Blocklist re-entry catch rate ≥80% | Known-pattern re-registrations caught within 48 hrs, measured weekly | Blocklist operational (FY27H1) |
| 2.2 | Remediation hold rate ≥95% at 90 days | No tenant reverts to active abuse post-enforcement within 90-day window | V2 pipeline (FY27H1) |
| 2.3 | Deletion backlog cleared per plan | All tenants from deletion plan executed on schedule | Pipeline capacity |
| 2.4 | EFR reported quarterly with calibration | Prevalence metric operational across all SKU segments with confidence intervals | KR 1.1 (TRS v1) |
| 2.5 | Provisioning gate design complete | Architecture doc, Entra/Commerce integration design, privacy review initiated | KR 1.4 (Gate 2) |

**Why this matters:** FY27H1 ships enforcement infrastructure. FY27H2 proves it *works* — with numbers. If re-entry rate isn't declining, enforcement is theater.

---

### Objective 3: Sustain Detection Resilience

*Strategy ref: Section 4.1 (coverage gap), Section 4.2 (rule decay)*

| # | Key Result | Success Criteria | Gated on |
|---|-----------|-----------------|----------|
| 3.1 | TRS as compound scorer | Model-based detection replaces threshold-only rules as primary signal for new detections | KR 1.1 |
| 3.2 | Input table broadened | Full DS-flagged population evaluable by rule engine (feed gap closed) | None |
| 3.3 | Zero rules in silent decay >30 days | All rules have health scores, auto-alerting on degradation, lifecycle managed | Rule monitoring (FY27H1) |
| 3.4 | DS model refreshed quarterly | Non-storage signals included; labels from investigation ground truth | DS capacity |
| 3.5 | COGS Protected sustained or growing | Detection keeps pace with adversary adaptation despite evasion | All of the above |

---

## 4. Resource Allocation

### Headcount: 7 Eng | 1 PM | 1 DS

| Eng allocation | Focus area | Objective |
|---------------|-----------|-----------|
| 2 Eng | TRS v1 build (pipeline, scoring infra, feature engineering, drift monitoring) | O1 |
| 1 Eng | Input table broadening + DS model integration | O3 |
| 1 Eng | Deletion plan execution + remediation pipeline maturity | O2 |
| 1 Eng | Sonar production hardening (authenticated detonation at operational cadence) | O2 |
| 1 Eng | Blocklist iteration + provisioning gate design (Entra/Commerce scoping) | O2 |
| 1 Eng | Rule lifecycle management + new rule development | O3 |

| Other roles | Focus |
|-------------|-------|
| 1 PM | Cross-org coordination (Entra, Commerce, CFAR, MDO), measurement framework, Gate 2 prep, investigations |
| 1 DS | TRS v1 model training/calibration, EFR computation, quarterly model refresh |

### What's NOT staffed (below the line)

| Item | Why below | What unblocks it |
|------|-----------|------------------|
| Provisioning gate build | Requires Gate 2 pass + Entra/Commerce partnership | Ships FY28 if Gate 2 passes |
| User-level enforcement | SPO platform capability — not FAB-only | SPO investment decision |
| Sharing-suspension enforcement state | SPO platform work | SPO investment decision |
| HVL challenge-response | UX infrastructure doesn't exist; design not started | UX scoping could begin late FY27H2 |
| Auto-unlock self-service | Depends on HVL patterns | HVL design first |
| Consumer FAB | Different architecture, dedicated charter needed | Organizational decision + headcount |

---

## 5. Dependencies & Partner Asks

| Partner | What FAB needs | Timeline | Blocking |
|---------|---------------|----------|----------|
| **DS team** | Dedicated collaboration on TRS v1 model + EFR calibration | Full semester | O1, KR 2.4 |
| **Entra ID** | Provisioning-time signal API — design/scoping sessions | FY27H2 Q1 | KR 2.5 |
| **Commerce** | RRS data feed integration + privacy alignment | FY27H2 Q1 | KR 2.5, O1 (TRS features) |
| **CFAR** | Continued bidirectional signal sharing; their detections → our pipeline | Ongoing | KR 3.4, 3.5 |
| **MDO** | Sonar operational ownership handoff | FY27H2 Q1 | Sonar production |
| **SPO Platform** | Investment decision on user-level / sharing-suspension enforcement | FY27H2 (decision only) | FY28 roadmap |

---

## 6. Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| Gate 1 does not greenlight TRS | Low (Phase 0 is designed to validate) | High — 3 below-the-line items permanently blocked | See Section 7 contingency |
| DS single-threaded — model work stalls | Medium | High — TRS v1 + EFR both blocked | Tier 1 investment ask: +0.5 DS |
| Entra/Commerce won't commit to scoping | Medium | Medium — provisioning gate delayed to FY28+ | PM secures design commitment in FY27H1; scoping is the FY27H2 ask, not build |
| Deletion backlog creates operational drag | Low-Medium | Medium — Eng capacity absorbed by ops | Automation in FY27H1 V2 pipeline; monitor % time on ops vs. build |
| Evasion acceleration outpaces detection | Medium | Medium — COGS Protected declines | TRS compound scoring + rule health monitoring provide early warning |

---

## 7. Contingency: Gate 1 Does NOT Greenlight

If TRS Phase 0 shows signals are not predictive or pipeline is intractable:

| Original KR | Replacement |
|-------------|-------------|
| TRS v1 scores all tenants daily | DS model refresh to monthly cadence with expanded labels |
| Investigation queue score-ranked | Priority heuristic based on storage trajectory + rule hit count |
| Cross-tenant similarity detection | Blocklist expansion — more exact-match patterns, broader indicator set |
| EFR with calibration (TRS-based) | EFR via DS model confidence bands (wider intervals, less precise) |
| Provisioning gate design | Deferred to FY28; blocklist sweep remains primary re-entry defense |

**Resource reallocation:** 2 Eng from TRS v1 → additional rules on commercial SKUs + HVL UX design scoping + accelerated DS integration.

The team still delivers value — but the FY28 roadmap shrinks significantly. The highest-impact investments (provisioning gate, graduated enforcement) remain blocked without a scoring layer.

---

## 8. Measurement: How We Know We're Winning

### North Star Metrics (from strategy paper Section 8)

| Metric | FY27H1 baseline | FY27H2 target |
|--------|----------------|---------------|
| **EFR** | Floor estimate on dev/EDU | Full quarterly reporting with calibration (all segments) |
| **Detection Efficacy — Coverage** | Not derivable | Derivable once TRS scores full population |
| **Detection Efficacy — TTD** | Measured (pipeline data) | Median TTD improves or sustains |
| **Containment Durability — Hold Rate** | First measurement via V2 pipeline | ≥95% at 90 days |
| **Containment Durability — Re-entry Rate** | First measurement via blocklist | ≥80% catch rate, declining re-entry |
| **COGS Protected** | Reported biweekly | Sustained or growing vs. FY27H1 |

### End-of-Semester Success Signals

| Signal | What it proves |
|--------|---------------|
| TRS scoring all tenants daily | Intelligence layer exists — the flywheel produces a unified output |
| EFR reported with confidence intervals | First real answer to "how dirty is the ecosystem?" |
| Re-entry rate measured and declining | Enforcement is durable, not just frequent |
| Gate 2 passed | FY28 provisioning gate greenlit with evidence |
| No rule in silent decay >30 days | Detection is actively managed, not passively decaying |
| COGS Protected not declining | Resilience proven — detection keeps pace with evasion |

---

## 9. What This Semester Sets Up for FY28

If FY27H2 delivers as planned, FY28 opens with:

| FY28 item | Why it's now possible |
|-----------|---------------------|
| Provisioning gate (hard-block at creation) | TRS v1 in production + Gate 2 passed + Entra/Commerce design complete |
| TRS v2 (near-real-time scoring at creation) | v1 operational maturity proven |
| Graduated enforcement matrix | TRS tiers enable proportional response |
| User-level enforcement | SPO platform decision made in FY27H2 |
| Consumer FAB charter | Organizational decision; commercial system proves the model |
| Cross-cloud reputation signals | Industry conversation requires operational credibility |

---

## 10. Planning Session Agenda (Suggested)

| # | Topic | Time | Goal |
|---|-------|------|------|
| 1 | FY27H1 ship review — what actually landed | 15 min | Confirm baseline |
| 2 | Gate 1 outcome + implications | 10 min | Confirm TRS path or contingency |
| 3 | FY27H2 objectives & KRs walkthrough | 20 min | Alignment on the 3 bets |
| 4 | Resource allocation — confirm splits | 10 min | Flag any rebalancing |
| 5 | Dependencies — partner commitments status | 10 min | Identify blockers early |
| 6 | Below-the-line items — what moves up if capacity opens? | 10 min | Priority stack rank |
| 7 | Investment ask — do we bring Tier 1 (2.5 HC)? | 10 min | Decision or escalation path |
| 8 | Risks + open questions | 5 min | Capture and assign |

---

*End of plan.*
