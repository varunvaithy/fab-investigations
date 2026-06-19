# FAB Tenant Service — Consolidated Fraud & Abuse Vector Landscape

**Date:** April 2, 2026  
**Scope:** All identified fraud/abuse vectors — production rules, automated detection, and ad-hoc investigations  
**Service:** ODSP Fraud and Abuse (FAB) Tenant Service

---

## Summary — Fraud & Abuse Vectors

The FAB Tenant Service tracks **ten distinct fraud and abuse vectors** across ODSP today. Seven of these are **detected and remediated automatically** via production rules and pipelines. **Chia mining abuse** — tenants repurposing SharePoint storage for cryptocurrency plot farming. **Streaming & CDN abuse** — developer tenants with abnormally high egress, using OneDrive/SharePoint as a free content distribution network (e.g., "TDFLIX"). **Developer/EDU storage hoarding** — free E5 Developer or A1 EDU tenants accumulating 20–130 TB each with zero users and zero sessions, purely for bulk storage (e.g., the 4-char-name ring: AWZS, FUQX, QNYA — 31 tenants averaging 97 TB each). **Commercial SKU storage abuse** — M365 Business Basic/Premium/Standard tenants that never pay but consume disproportionate storage relative to their few licenses. **Gibberish/synthetic tenant names** — automatically generated tenant and domain names indicating scripted provisioning, detected daily via linguistic analysis of vowel ratios, consonant clusters, impossible bigrams, keyboard-walk patterns, and character entropy (e.g., "xkqzwpfl", "bfptzwn"). **E5 Developer overquota** — developer tenants that legitimately provisioned but grossly exceed their storage entitlement, handled through a notify-then-block cadence. In addition, a **data science model** surfaces suspected **A1 EDU license fraud** for manual HIT team review.

Four additional vectors are **identified and tracked but not yet fully automated**. **SharePoint Online soft-limit exploitation** — actors create commercial tenants with a single free license (entitled to ~1 TB) and upload 300–360 TB into SPO sites, exploiting the fact that SPO storage quotas are soft limits with no upload blocking; each tenant can exceed quota by 100–340x (e.g., the MistyCloud ring: 12 Argentina-based tenants at ~342 TB each on 1 license each; the ACGDB/SakuraPY ring: 33 tenants under one Gmail admin). **EDU channel impersonation** — actors register tenants under the names of real schools to fraudulently obtain millions of free A1 EDU licenses with massive storage allocations; sub-patterns include commercial entities masquerading as schools (e.g., "SOGA OFFICE 365" on an EDU tenant), impersonation of specific institutions (e.g., fake tenants claiming to be Shanghai Jiao Tong University or Keystone Academy Beijing), MSP/reseller networks managing multiple fake school domains under one tenant, and dormant storage silos with extreme per-user ratios (e.g., 747 GB/user on a free A1 account). **Multiplexing rings** — a single operator splitting operations across many tenants to circumvent per-tenant licensing; the detection capability exists in code (shared admin contacts, IP overlap, sequential naming patterns, coordinated creation timestamps, geography clustering) and is used in on-demand investigations via the MCP tooling, but is not yet running as an automated scheduled scan (e.g., the 32-tenant Procode ring: procode826, procode713, procode558…). **Brand impersonation** — tenants using Microsoft-associated names like "MSFT", "MICROSOFT 365", or "AZURE FOUNDERS HUB" to appear legitimate, typically paired with developer storage abuse. A related concern is **false-positive recidivism** — tenants that resume abuse after being marked FP, sometimes rotating domains to evade re-detection (e.g., GAYHOST changing from `gayshelter.club` to `eeix.cc`), for which there is currently no automated re-detection.

---

## 1. Production Detection & Remediation System

### 1.1 Automated Detection Pipeline — Detection Automation Rules (7 Rules)

The FAB service runs a **Detection Automation Remediation** pipeline that ingests tenants from the `[FRAUD].[DetectionAutomationRulesData]` table. Each tenant is tagged with a `RuleMask` bitmask indicating which rules fired. Tenants are auto-approved (no HIT review) and remediated under usecase `ABUSE-READONLY-BLOCK-DELETE_15DAYS` with reason code `96`.

| Bit | Rule | Description |
|-----|------|-------------|
| 1 | **Chia Mining** | Tenant is using SPO for Chia mining activities |
| 2 | **Streaming Abuse** | High egress streaming content on a developer tenant |
| 3 | **High Storage + Egress / Low MAU** | High storage and egress with low MAU on developer or educational SKU |
| 4 | **Excessive Storage / Few Users** | Excessively high storage for few active users on developer or educational SKU |
| 5 | **Business SKU Overuse** | High storage, low paid licenses, low MAU on M365 Business Basic/Premium/Standard |
| 6 | **Gibberish Name Detection** | Synthetic/gibberish tenant name or domain via linguistic analysis (vowel ratio, impossible bigrams, keyboard walks, entropy, brand impersonation) — implemented in `GibberishNameDetector.cs`, runs as a **daily scheduled job** scanning newly created tenants |
| 7 | **Multiplexing Ring Detection** | Multiple tenants by same org to circumvent licensing (shared admin, IP overlap, naming patterns, coordinated creation, geo clustering) — implemented in `MultiplexingDetector.cs`. **Not yet automated**; currently on-demand only via MCP `CheckMultiplexing` tool during investigations |

### 1.2 A1 EDU Fraud Automation

A separate pipeline targets **A1 EDU tenants** identified by a data science model (reason code `78`). These flow through the `[FRAUD].[SUSPECTED_A1_FRAUD_TENANTS_STAGING]` table and require HIT team manual review (`approvalFlag = 1`) before remediation under usecase `TYPE1`.

### 1.3 E5 Developer Overquota Pipeline

The `E5DEV-OVERQUOTA` usecase targets E5 Developer tenants exceeding storage quotas. The remediation flow is: **Day 0 notification → Day 23 notification → Day 32 block → Day 62 delete**. Tenants are tracked in `[FRAUD].[DEV_OVERQUOTA_TENANTS]` and `[FRAUD].[TENANT_DETAILS_STAGING]`.

### 1.4 Remediation Use Case Types (Production)

| # | Use Case Type | Flow | Deletion? |
|---|---------------|------|-----------|
| 1 | **TYPE1** | ReadOnly → Block | No |
| 2 | **TYPE2** | Immediate Block | No |
| 3 | **ABUSE-MALWARE** | Immediate Block | No |
| 4 | **ABUSE-READONLY-BLOCK** | 21-day ReadOnly → Block | No |
| 5 | **ABUSE-BLOCK** | Immediate Block | No |
| 6 | **E5DEV-OVERQUOTA** | Day0 Notify → Day23 Notify → Day32 Block → Day62 Delete | Yes |
| 7 | **E5DEV-ABUSE-READONLY-BLOCK** | 21-day ReadOnly → Block | No |
| 8 | **ABUSE-READONLY-BLOCK-DELETE** | 21-day ReadOnly → Block → 30-day Delete (within PITR) → Deprovision | Yes |
| 9 | **ABUSE-BLOCK-DELETE** | Immediate Block → 30-day Delete (within PITR) → Deprovision | Yes |
| 10 | **ABUSE-READONLY-BLOCK-DELETE_15DAYS** | 21-day ReadOnly → 15-day Block → 30-day Delete → Deprovision | Yes |
| 11 | **ABUSE-BLOCK-DELETE_15DAYS** | Immediate Block → 15-day Delete → Deprovision | Yes |
| 12 | **DEPRECATE-WITHOUT-DELETE** | ReadOnly → Block after 30 days | No |
| 13 | **DEPRECATE-WITH-DELETE** | Deprecation banner → Block after 30 days → Delete after 10 days | Yes |
| 14 | **DEPRECATE-WITHOUT-DELETE-90DAYS** | ReadOnly → Block after 90 days | No |

### 1.5 In-Service Detection Capabilities

| Capability | Module | Purpose |
|------------|--------|---------|
| **Gibberish Name Detection** | `GibberishNameDetector.cs` | Scores tenant/domain names for synthetic/random patterns (vowel ratio, consonant clusters, entropy, keyboard walks, rare bigrams). Threshold ≥ 0.6. Also detects brand impersonation via homoglyph/typosquatting analysis. |
| **Multiplexing Detection** | `MultiplexingDetector.cs` | Scores tenant clusters for coordinated multi-tenant abuse using 10 signals: shared admin, IP overlap, naming patterns, coordinated creation time, geo clustering, usage similarity, low per-tenant users, domain patterns, category match, cluster size. |
| **MCP Investigation Tools** | `FABTenantTools.cs` | Agent-driven investigation via MCP: tenant info, remediation status, D2K lookups, Kusto queries, SPO Request Usage analysis, ingestion, false positive marking. |

---

## 2. Identified Fraud & Abuse Vectors

### Vector 1: E5 Developer Trial Storage Abuse — *P0 CRITICAL*

**Mechanism:** Actors create E5 Developer trial tenants (25 free licenses), never pay, and use OneDrive for Business sites as unlimited cloud storage. Each tenant can accumulate 60–130 TB with zero interactive usage.

**Characteristics:**
- SKU: E5 Developer (Trial, never paid)
- 23–25 ODB sites per tenant, zero activated users, zero sessions
- Gibberish or ultra-short tenant names (4-char random alphanumeric)
- Only `.onmicrosoft.com` domain — no custom domains
- Empty registration fields (city, address)
- Multi-country registration via VPNs

**Discovered Rings:**

| Ring | Tenants | Total Storage | Avg/Tenant | Countries | Status |
|------|---------|--------------|------------|-----------|--------|
| **E5 Dev 4-Char Ring** | 31 | ~2.9 PB | ~97 TB | 11 (EU focus) | 14 blocked, 3 failing, 14 pending ingestion |
| **tm9/tm10 Domain Ring** | 4 | ~483 TB | ~121 TB | Multiple | All blocked |

**Detection signals:** 4-char uppercase name + E5 Dev Trial + HAS_EVER_PAID=FALSE + onmicrosoft-only + 20+ ODB sites + >20 TB storage + 0 sessions + empty CITY.

---

### Vector 2: SharePoint Online Soft-Limit Exploitation — *P0 CRITICAL*

**Mechanism:** Actors create commercial tenants with minimal free licenses (1–10 Business Basic Free), then dump massive data into SharePoint Online sites. SPO's storage pool is a **soft limit** — uploads are not blocked when quota is exceeded. ODB has per-user enforcement but SPO doesn't, so all data goes through SPO.

**Characteristics:**
- 1–10 licenses (cheap/free SKU), zero payment
- 100% SPO storage (not ODB)
- Storage overages of 26x–340x over entitled quota
- Automated/sequential tenant provisioning
- Some rings use different admin emails per tenant to evade clustering

**Discovered Rings:**

| Ring | Tenants | Total Storage | Avg/Tenant | Overage | Status |
|------|---------|--------------|------------|---------|--------|
| **MistyCloud Inc** (`misty.moe`) | 12 | ~3.67 PB | ~342 TB | ~340x | 11 ingested |
| **ACGDB / SakuraPY** (`pengyoupy001@gmail.com`) | 33 | ~597 TB | ~66 TB | 26–108x | 21 in FAB |
| **China Singleton** (`liangsheng32126`) | 1 | ~110 TB | 110 TB | 107x | Ingested |
| **SPO-Only Cluster** (3GV, TDFLIX, HDP, PORMEGA) | 4 | ~271 TB | ~68 TB | Various | Not in FAB |

**Key evasion technique (MistyCloud):** Each tenant uses a *different* `@misty.moe` email address — evades single-email clustering detection. Discovery required SpoProd blob write volume analysis.

---

### Vector 3: EDU License Fraud & School Impersonation — *P1 HIGH*

**Mechanism:** Actors obtain free A1 EDU licenses by impersonating real educational institutions. A single A1 EDU tenant can provision 4 million licenses at 100 GB each = ~400 PB theoretical allocation. Six distinct sub-archetypes identified.

**Sub-Archetypes:**

| Archetype | Description | Count | Key Signals |
|-----------|-------------|-------|-------------|
| **A: Commercial Masquerade** | Non-educational entity using EDU tenant | 14 | Name contains commercial keywords, commercial TLD domains |
| **B: Identity Theft / Impersonation** | Claims to be a real institution | 8 | `edu=declined`, onmicrosoft-only, geo mismatch to real school |
| **C: MSP/Reseller Network** | Single tenant manages multiple school domains | 7 | 8+ verified domains, cross-domain admin emails |
| **D: Zero-Tag Ghost** | No edu CompanyTags or only "EmailVerified" | ~12 | No edu=approved, no contact info in D2K |
| **E: Dormant Storage Silo** | Extreme storage per user, minimal active users | ~18 | <50 users AND >200 GB total, GB/user >10 on free A1 |
| **F: Developer Abuse** | Developer/free SKU on EDU tenant | 2 | E3 Dev Free on "educational" tenant |

**Notable Cases:**
- ACGDB/SakuraPY ring: 7 EDU impersonation tenants pretending to be **Keystone Academy**, **Beijing City International School**, **Abbotswood Primary** (UK), **Sennybridge C.P. School** (Wales) — ~20M fraudulent licenses
- Shanghai Jiao Tong University, South China Normal University, Harbin Institute of Technology impersonated with onmicrosoft-only tenants
- Vietnamese A1 EDU cluster: 7 VN tenants with short cryptic names, elevated storage/user ratios

**Total scope investigated:** 126 CN/VN EDU tenants — 23 confirmed fraud, ~15 suspicious

---

### Vector 4: Multiplexing / ToS Violation Rings — *P1 HIGH*

**Mechanism:** A single operator creates many tenants under different identities to circumvent per-tenant licensing limits, effectively operating as one organization across dozens of tenants.

**Discovered Ring:**

| Ring | Tenants | Span | Status | Key Signal |
|------|---------|------|--------|------------|
| **Procode Ring** (`procode{NNN}`) | 32 | 21 months (Jun 2024 – Mar 2026) | Mapped, no action yet | Systematic naming, gibberish gmail admins, zero licensing |

**Procode characteristics:**
- All tenants follow `procode{NNN}.onmicrosoft.com` with random 3-digit suffixes (anti-sequential detection)
- 28 of 32 use keyboard-mash gmail addresses (some with typos like `@gmil.com`, `@gmail.comm`)
- One "control tenant" (ProcodeSix) with custom domain, real address (Irvine, CA), and formal admin email
- Zero payment, zero licensing across all 32 tenants
- Currently minimal storage impact but represents a pre-positioned abuse infrastructure

**Detection built:** `MultiplexingDetector.cs` scores clusters on 10 weighted signals (shared admin, IP overlap, naming patterns, coordinated creation, geo clustering, etc.).

---

### Vector 5: Brand Impersonation — *P1 HIGH*

**Mechanism:** Tenants use Microsoft-associated names ("MSFT", "MICROSOFT 365", "AZURE FOUNDERS HUB") to appear legitimate or deceive review processes.

**Confirmed Cases:**

| Tenant | Fake Name | Real Purpose | Storage |
|--------|-----------|-------------|---------|
| `7165dd1d` | MSFT | E5 Dev storage abuse | 36 TB |
| `ef308585` | AZURE FOUNDERS HUB | E5 Dev storage abuse | 19 TB |
| `f3121032` | MSFT | E5 Dev storage abuse | 5 TB |
| `2d361d0b` | MSFT | E5 Dev storage abuse | 4 TB |
| `f2fe2b85` | MSFT KOS | E5 Dev storage abuse | 1.6 TB |
| `fbe66fb6` | MICROSOFT 365 | tm10 ring member | 121 TB |

**Detection built:** `GibberishNameDetector.cs` includes a brand impersonation module with a list of 90+ protected brands (Microsoft, Google, Apple, Azure, etc.) and homoglyph/typosquatting analysis.

---

### Vector 6: E5 Developer Overquota — *P2 MEDIUM*

**Mechanism:** E5 Developer tenants that legitimately provisioned but vastly exceeded their entitled storage. Some are borderline — they may have started legitimate but evolved into abuse. Many are Chinese-origin tenants.

**Characteristics:**
- E5 Developer SKU, sometimes with custom domains
- Storage far exceeding developer allocation
- Some rotate domains (e.g., `gayshelter.club → eeix.cc`)
- Several previously marked False Positive but continue growing

**Known cases:** ~4 tenants (GAYHOST, DUANREN, OD, 1OVETG) totaling ~299 TB, all previously in FAB under `E5DEV-OVERQUOTA` but rolled back to FP (Status 7) despite continued abuse indicators.

---

### Vector 7: Streaming / Content Distribution Abuse — *Signal, Not Yet Confirmed*

**Mechanism:** Tenants use SharePoint/OneDrive as a free CDN for streaming media or distributing pirated content, identifiable through egress-heavy traffic patterns.

**Indicators:**
- High blob egress relative to ingress
- Unusual request patterns (high volume reads from external referrers)
- Names suggesting media content (e.g., "TDFLIX" — suggests streaming/piracy)
- The investigation prompt explicitly checks for "streaming abuse" via SPO Request Usage egress/ingress patterns

---

## 3. Cumulative Impact Summary

| Vector | Known Tenants | Known Storage Impact | Revenue Generated |
|--------|--------------|---------------------|-------------------|
| E5 Dev Trial Storage Abuse | ~35 | ~3.4 PB | $0 |
| SPO Soft-Limit Exploitation | ~50 | ~4.6 PB | $0 |
| EDU License Fraud | ~23 confirmed | ~250+ TB + ~39 PB exposure | $0 |
| Multiplexing (Procode) | 32 | Minimal (pre-positioned) | $0 |
| Brand Impersonation | ~6 | ~187 TB | $0 |
| E5 Dev Overquota (FP recidivism) | ~4 | ~299 TB | $0 |
| **Total Known** | **~150+** | **>8 PB active + 39 PB potential** | **$0** |

---

## 4. Detection Gaps & Open Risks

| Gap | Description | Mitigation Status |
|-----|-------------|-------------------|
| **SPO soft-limit not enforced** | Tenants can exceed SPO quota by 340x with no block | Root cause; requires platform fix |
| **Email-per-tenant evasion** | Rings like MistyCloud use different admin emails per tenant | Need domain-based clustering (not just email) |
| **Short name detection** | 4-char gibberish names score below gibberish threshold | Behavioral signals must supplement name detection |
| **EDU approval abuse** | Actors get `edu=approved` with fake school documentation | Stronger EDU verification needed |
| **FP recidivism** | Tenants marked False Positive resume abuse | Need post-FP monitoring with auto-re-escalation |
| **DEPRECATE stuck tenants** | 8+ tenants blocked >180 days under DEPRECATE-90D (no delete path) | Manual usecase change or deletion needed |
| **Block failures** | ~3 tenants with 7+ BLOCK_FAIL retries each | Requires manual investigation |
| **Ingestion validation failures** | 14 E5 Dev ring tenants failing Kusto validation | Manual dashboard ingestion required |

---

## 5. Investigation Tooling

| Tool | Purpose |
|------|---------|
| FAB Dashboard | Manual tenant review, ingestion, FP marking, usecase modification |
| FAB MCP Server | Agent-driven investigation via Copilot (get_tenant_info, ingest, FP, D2K queries) |
| Kusto (fabdardb) | Storage analysis, ring detection queries, TENANT_INFO enrichment |
| SpoProd Kusto | Blob write volume analysis (how MistyCloud was found) |
| D2K Shards | Admin email clustering, domain cross-references, CompanyTags analysis |
| GibberishNameDetector | Automated name quality scoring (in-code) |
| MultiplexingDetector | Automated ring detection scoring (in-code) |
| KQL Detection Queries | Saved ring-pattern queries for E5 Dev and gibberish detection |
