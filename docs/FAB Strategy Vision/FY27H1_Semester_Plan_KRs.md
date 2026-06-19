# FAB FY27H1 Semester Plan

**Fair Usage (Fraud & Abuse) | Jul – Dec 2026**

PM: varunv | Updated: May 2026 | Status: Draft — Planning

---

## Objectives & Key Results

**Headcount:** 7 Eng, 1 PM, 1 DS

| Objective | Key Result | June 2026 Baseline | Jan 2027 Goal |
|---|---|---|---|
| **O1: Strengthen and scale fraud detection** | KR #1: New detection models shipped — from investigations, rules, and DS signals | 5 rules + 1 AI agent (Rule 0); ad-hoc investigations; 1 one-time DS model | ≥3 new detection models launched and actively scoring |
| | KR #2: TRS v1 evaluates 100% of active tenants daily | Phase 0 PoC only | All tenants scored daily |
| | KR #3: Coordinated fraud rings surfaced through group investigation capability | Manual, single-tenant discovery only | ≥3 rings identified systematically |
| **O2: Link abuse on SPO enforced end-to-end** | KR #1: MDO-flagged malicious links trigger SPO takedown within 24 hours | No integration | Automated pipeline live |
| | KR #2: Sonar detonation at steady-state, zero manual intervention | Requires manual ops | Fully automated at production volume |
| **O3: Detection signals expanded and models kept fresh** | KR #1: ≥2 cross-org signal feeds integrated into detection pipeline | CFAR only (partial) | Exchange + Teams/CFAR live |
| | KR #2: DS model retrained with expanded signals, covering full flagged population | Storage-only features, subset coverage | Full coverage, non-storage signals included |
| | KR #3: Rule lifecycle managed — decay visible, rules refreshed on cadence | No visibility into rule health | Health dashboard live, quarterly refresh cadence |
| **O4: Known fraud actors blocked on re-entry** | KR #1: Returning actors caught within 48 hours of reactivation | No measurement | ≥80% catch rate |
| | KR #2: Provisioning velocity anomalies detected as fraud signal; blocking architecture designed | Not tracked | Signal live + architecture and privacy review complete |
| **O5: Fraud measurement framework launched** | KR #1: Ecosystem Fraud Rate (EFR) launched — a new metric measuring what % of active tenants are estimated fraudulent, computed via model scoring calibrated against human spot-checks | Does not exist | First quarterly EFR report published with confidence intervals |
| | KR #2: Detection Efficacy tracked — coverage (% of fraud identified), time-to-detection, and precision | Partially queryable, not reported | Dashboard operational, reported quarterly |

---

## Priority List (Projects)

| # | Theme | Priority | Initiative / Work | Owner | Delivers KR | Above / Below Line |
|---|---|---|---|---|---|---|
| P1 | Detection & Intelligence | TRS v1 — score all tenants daily | Build production scoring pipeline that assigns a daily fraud risk score to every tenant | Eng + DS | O1 KR #2 | **Above** |
| P2 | Detection & Intelligence | TRS as compound scorer | Consolidate rule outputs as features into TRS so one model score replaces brittle threshold checks | Eng + DS | O1 KR #2 | **Above** |
| P3 | Detection & Intelligence | New detection rules from investigation insights | Turn investigation findings into shipped detection models — formalize the investigation→rule pipeline | PM + Eng | O1 KR #1 | **Above** |
| P4 | Detection & Intelligence | Investigation tooling — multi-tenant querying + group investigations | MCP agent improvements, batch investigation, cross-tenant search to enable ring discovery at scale | Eng + PM | O1 KR #3 | **Above** |
| P5 | Detection & Intelligence | Fraud ring detection | Build capability to identify clusters of tenants operated by the same actor using shared signals | Eng + DS | O1 KR #3 | **Above** |
| P6 | Coverage & Health | Cross-org signal feeds (Exchange/Teams/CFAR) | Onboard fraud signals from partner teams to detect abuse patterns invisible in storage data alone | PM + Eng | O3 KR #1 | **Above** |
| P7 | Coverage & Health | Input table broadening | Expand tenant population evaluated by detection pipeline to full DS-flagged set | Eng | O3 KR #2 | **Above** |
| P8 | Coverage & Health | DS model refresh with expanded signals | Retrain model with collaboration, identity, and CDN features — not just storage | DS + Eng | O3 KR #2 | **Above** |
| P9 | Coverage & Health | Rule health monitoring | Automated visibility into rule performance — know when rules decay, establish refresh cadence | Eng | O3 KR #3 | **Above** |
| P10 | Link Abuse | MDO verdict consumption pipeline | When MDO flags a malicious link on SPO, automatically trigger enforcement to take it down | Eng | O2 KR #1 | **Above** |
| P11 | Link Abuse | Sonar at operational cadence | Stabilize authenticated link detonation at production volume with no manual intervention | Eng | O2 KR #2 | **Above** |
| P12 | Re-Entry Prevention | Blocklist iteration — ≥80% catch rate | Expand to 8 indicator types, measure effectiveness, catch returning actors before they reactivate | Eng | O4 KR #1 | **Above** |
| P13 | Re-Entry Prevention | Provisioning velocity signal + blocking architecture | Detect rapid tenant creation patterns as fraud signal; design Entra/Commerce blocking architecture with privacy review | PM + Eng | O4 KR #2 | **Above** |
| P14 | Measurement | EFR operationalization | Launch Ecosystem Fraud Rate as a new metric — model scoring calibrated against spot-checks, reported quarterly with CIs | DS + PM | O5 KR #1 | **Above** |
| P15 | Measurement | Detection Efficacy dashboard | Track coverage, time-to-detection, and precision; report quarterly | PM | O5 KR #2 | **Above** |
| | | | **——— CUT LINE ———** | | | |
| P16 | Detection & Intelligence | User-level blocking (prototype) | Block individual malicious users within a tenant. Requires SPO platform capability that doesn't exist today | Eng | — | Below |
| P17 | Detection & Intelligence | AI support agent for CRI | LLM-powered agent to assist analysts. Needs new infra + safety guardrails | Eng | — | Below |
| P18 | Re-Entry Prevention | Provisioning gate BUILD | Implement the blocking system. Depends on design (P13) + Entra/Commerce readiness | Eng | O4 KR #2 | Below |
| P19 | Enforcement | Auto-unlock self-service | Let legitimate tenants self-remediate out of enforcement. Blocked on HVL design patterns | Eng | — | Below |
| P20 | Enforcement | Sharing-suspension enforcement state | Lighter enforcement action at sharing level. Requires SPO platform investment | Eng | — | Below |
| P21 | Enforcement | V2 pipeline hardening | Stuck-state fixes, retry automation. Not a pressing problem currently | Eng | — | Below |

---

## Resource Allocation

| Slot | Eng | Priorities Covered |
|---|---|---|
| TRS v1 build (pipeline + compound scorer) | 2 | P1, P2 |
| Investigation tooling + ring detection | 1 | P4, P5 |
| Cross-org signals + input broadening + DS refresh | 1 + DS | P6, P7, P8 |
| MDO + Sonar | 1.5 | P10, P11 |
| Rule health + blocklist + provisioning signal | 1 | P9, P12, P13 |
| Buffer (flex) | 0.5 | Sprint rebalancing, cross-org unknowns |
| **Total** | **7 + DS** | |

*PM covers: P3 (investigation→rule pipeline), P6 (data contracts), P13 (architecture/privacy), P14, P15*

---
