# Re-Entry Prevention Strategy

## Executive Summary

After remediating 160+ fraudulent tenants across 10+ organized rings totaling ~10 PB of abuse, the next priority is ensuring these bad actors cannot re-enter the system. This document outlines a layered prevention approach — from exact-match blocklists (immediate) to behavioral detection (medium-term) to systemic hardening (long-term).

---

## Layer 1: Exact-Match Blocklists (Implemented — `blocklists/`)

**Status: ✅ Blocklists created**

What we've built in `blocklists/`:

| Signal | File | Count | Blocks What |
|--------|------|-------|-------------|
| Email addresses | `emails.json` | 52 | Tenant admin re-registration |
| Domains | `domains.json` | 42 | onmicrosoft + custom domain reuse |
| Phone numbers | `phone_numbers.json` | 6 | Registration phone reuse |
| Tenant IDs | `tenant_ids.json` | 160+ | Cross-reference for re-entry |
| Org names | `org_names.json` | 50+ | Exact + pattern match |
| External services | `external_services.json` | 11 | Operator infrastructure domains |
| App fingerprints | `app_fingerprints.json` | 6 apps + 5 behaviors | Early-warning signals |
| Registration patterns | `registration_patterns.json` | 15+ regex | Structural ring detection |

### Integration Path
1. **Provisioning gate**: At tenant creation time, check admin email, phone, org name, and domain against blocklists. Hard-block on `confirmed` entries.
2. **FAB scoring boost**: Tenants matching any blocklist entry get elevated fraud score.
3. **Kusto scheduled alert**: Periodic query joining new tenants against blocklist values.

---

## Layer 2: Similarity & Fuzzy Matching (Near-Term)

Exact matches catch lazy re-entry. Smart actors change emails slightly. These techniques catch them:

### 2a. Email Domain Blocking
Don't just block `mario@ritzmann.com.br` — block the entire `ritzmann.com.br` domain for admin registrations. Same for `misty.moe`, `sakurapy.com`, `ourpage.cn`, `poweramsonline.com`. Already captured in `external_services.json`.

### 2b. Gibberish Email Detection
The Procode ring used keyboard-mash Gmail addresses (`sdfghj@gmail.com`, `asdghbjnkm@gmail.com`). A consonant-density scorer on the local part (before @) would flag these:
- Entropy score > threshold
- Consonant-to-vowel ratio > 4:1
- No dictionary word matches
- Combined with: free email provider (Gmail/Outlook)

### 2c. Gibberish Org Name Detection
You already have `Test-GibberishName.ps1` and `GibberishTestRunner.csx`. Wire this into provisioning:
- 4-char all-uppercase names (E5 Dev Ring)
- Names failing trigram/bigram frequency tests
- Names with no vowels or impossible consonant clusters

### 2d. Phone Number Clustering
Same phone across >1 tenant = instant flag. Microsoft HQ phone (4258828080) on non-Microsoft tenants = block.

### 2e. Address Matching
Same physical address across multiple tenants (FC ring used identical address 30 times). Normalize and hash addresses, flag duplicates.

---

## Layer 3: Behavioral Detection at Provisioning Time (Medium-Term)

### 3a. Registration Velocity Anomaly
Flag when:
- Same admin email creates >2 tenants in 24 hours (ACGDB created 13 in 30 min)
- Same IP creates >2 tenants in 24 hours
- Same phone/address appears on >3 tenants

### 3b. Sequential Domain Pattern Detection
Auto-detect when new domains follow `{prefix}{N}` pattern:
```
familiaconfeitar17, familiaconfeitar18, familiaconfeitar19  → ALERT
procode487, procode618, procode274  → ALERT
acgdb21, acgdb22  → ALERT
```

### 3c. EDU Verification Hardening
Major injection vector: impersonating real schools to get free EDU licenses.
- **Require domain verification** against actual .edu/.edu.cn/.edu.vn domains
- **Cross-reference** claimed institution against official registries
- **Flag** when EDU domain doesn't match institution name
- **Rate-limit** EDU tenant creation from same geography/IP

### 3d. Free Tier Abuse Prevention
Most rings exploit free/trial tiers (Business Basic Free, E5 Dev, F1/Kiosk):
- **Soft-quota enforcement**: Don't let 1-seat tenants exceed 10x their entitled storage
- **Hard storage caps** on trial/free SKUs
- **Progressive verification** as storage grows (verify identity at 1TB, 10TB, 100TB)

---

## Layer 4: Runtime Monitoring & Early Kill (Medium-Term)

### 4a. First-Week Behavioral Profiling
Most fraud tenants show their pattern within days:
- rclone appears in `app` column → flag
- StableBit appears → flag if non-enterprise
- >90% ingress with zero interactive usage → flag
- HTTP 206 dominant response → streaming CDN pattern
- Video file type dominance (MKV/MP4/AVI) → piracy indicator

### 4b. Storage Growth Rate Alerting
Set alerts for:
- Any tenant growing >1 TB/day
- Any free-tier tenant exceeding 10 TB
- Any single-seat tenant exceeding tenant quota by >10x

### 4c. Egress/Ingress Ratio Monitoring
- Read amplification >50x → content distribution network
- >90% blob reads with 0 interactive sessions → storage-only abuse

### 4d. Automated FAB Ingestion on Pattern Match
When a tenant matches multiple signals from Layer 1-3, auto-ingest to FAB with appropriate reason codes rather than waiting for manual investigation.

---

## Layer 5: Systemic Hardening (Long-Term)

### 5a. Eliminate Soft-Quota Exploitation
The #1 systemic enabler across ALL rings: SPO provisions storage far beyond entitlement.
- **F1/Kiosk tenants** should NOT get PB-scale storage for $6/month
- **Business Basic Free** should have enforced caps, not soft quotas
- **E5 Developer** trials should cap at reasonable storage limits

### 5b. Payment Verification at Scale
Require valid payment method (not just free trial) before storage exceeds a threshold.
- Most rings have $0 payment: E5 Dev, ACGDB, MistyCloud, Procode
- Even paid rings (FC at $180/month for 1.9 PB) are absurdly under-priced
- **Metered overages** would make CDN abuse economically unviable

### 5c. API/rclone Throttling for Non-Enterprise
- rclone on EDU A1 = 100% fraud
- Rate-limit or block programmatic bulk file operations on free/trial/low-SKU tenants
- Require explicit opt-in for API-heavy workloads

### 5d. Cross-Tenant Graph Analysis
Build a graph connecting tenants by shared signals:
- Same admin email → edge
- Same phone → edge
- Same IP block → edge
- Same address → edge
- Similar org names → edge
- Same registration timestamp cluster → edge

Clusters in this graph = potential rings. This would have caught every ring we've investigated.

### 5e. External Intelligence Feeds
- Monitor `ms365vip.com`-like reselling sites for new operators
- Watch underground forums for M365 storage reselling advertisements
- Subscribe to domain registration feeds for domains impersonating schools

---

## Layer 6: Process & Governance

### 6a. Post-Remediation Blocklist Update (Standard Operating Procedure)
After every investigation:
1. Extract all identifiers from the report
2. Add to `blocklists/*.json` with ring attribution
3. Bump version number
4. Push to blocklist sync service

### 6b. Quarterly Blocklist Review
- Remove entries that are no longer relevant (tenant permanently deleted)
- Assess false-positive risk for pattern-based rules
- Analyze whether any blocked actors attempted re-entry

### 6c. Cross-Team Sharing
Share blocklist signals with:
- M365 Commerce (block subscription creation)
- AAD/Entra ID (block tenant provisioning)
- SPO Engineering (enforce storage caps)
- Abuse Response (faster remediation for known patterns)

---

## Priority Ranking

| # | Action | Effort | Impact | Timeframe |
|---|--------|--------|--------|-----------|
| 1 | Wire blocklists into provisioning gate | Medium | High | 2-4 weeks |
| 2 | Kusto scheduled query: new tenants vs blocklist | Low | High | 1 week |
| 3 | Registration velocity alerting (>2 tenants/day same email) | Low | High | 1-2 weeks |
| 4 | Gibberish email/name detection at signup | Medium | Medium | 2-4 weeks |
| 5 | Storage growth rate alerts (>1TB/day) | Low | High | 1 week |
| 6 | rclone/StableBit app detection → auto-flag | Low | High | 1 week |  
| 7 | Hard storage caps on free/trial SKUs | High | Very High | 1-2 quarters |
| 8 | Cross-tenant graph analysis | High | Very High | 1-2 quarters |
| 9 | EDU domain verification hardening | Medium | High | 1 quarter |
| 10 | Metered storage overages | Very High | Eliminates root cause | 2+ quarters |

---

## Architectural Integration: Where This Lives in FABTenantService

### Three Enforcement Checkpoints

The blocklists aren't useful unless they're checked at the right moments. Based on the existing FABTenantService architecture, there are three natural integration points — each catching a different failure mode:

| Checkpoint | When | What It Catches | Effort |
|---|---|---|---|
| **A. Detection Pipeline (Daily Sweep)** | During `DetectionRemediationServiceImpl.EnrichTenantDataAsync()` | Known bad actors who already re-entered and are actively abusing | Low — extends existing code |
| **B. Proactive Kusto Sweep (New Rules R6-R8)** | Scheduled daily against `TENANT_INFO` for tenants created in last N days | New tenants that match blocklist before they start abusing | Low — KQL query feeding `DetectionAutomationRulesData` |
| **C. Provisioning Gate** | At tenant creation in AAD/Entra ID + M365 Commerce | Prevents creation entirely | High — cross-team dependency (not in this codebase) |

**Checkpoint A** is the immediate win — it's entirely within our control and extends existing flow.
**Checkpoint B** is the proactive sweep — catches re-entry within 24h of tenant creation.
**Checkpoint C** is the ultimate goal but requires partnering with Entra ID / Commerce teams.

### Proposed New Detection Rules: R6, R7, R8

Rules R1-R5 are currently in production. Gibberish name detection and multiplexing ring detection exist as local prototypes but are **not yet in production code** (separate proposals). The next available RULEMASK bits (5-7) are used for this blocklist proposal:

| Rule | Bit | Name | Check Type | Signal | Action |
|---|---|---|---|---|---|
| **R6** | 5 | Blocklist Exact Match | Hash lookup | Admin email, phone, domain, or org name matches a `confirmed` blocklist entry | **Auto-ingest** to FAB (no review needed) |
| **R7** | 6 | Blocklist Pattern Match | Regex | Domain/name follows a known ring regex from `registration_patterns.json` (e.g., `procode\d{3}`, `acgdb\d+`, `mistytempsp\d+`) | **Auto-flag** for HIT review |
| **R8** | 7 | Re-entry Similarity | Fuzzy composite | New tenant shares 2+ weak signals with a remediated ring (same geography + same SKU + same app fingerprint + sequential timing) | **Boost fraud score** by +0.3, surface in dashboard |

### New Component: `BlocklistDetector.cs`

New standalone utility (no dependency on the local-only GibberishNameDetector or MultiplexingDetector prototypes):

```
BlocklistDetector.CheckTenant(tenantName, domain, adminEmail, phone, country)
  → BlocklistResult {
      Score: 0.0–1.0,
      MatchedEntries: [ { value, ring, confidence, matchType } ],
      Verdict: CLEAR | EXACT_MATCH | PATTERN_MATCH | SIMILARITY_MATCH,
      MatchedRules: [ R6 | R7 | R8 ],
      Signals: [ "Email mario@ritzmann.com.br matches FAMILIA-CONFEITAR blocklist", ... ]
    }
```

**Integration points for `BlocklistDetector`:**

| Where | How |
|---|---|
| `DetectionRemediationServiceImpl.EnrichTenantDataAsync()` | After Kusto enrichment, run `BlocklistDetector.CheckTenant()` on each enriched tenant. If R6 match → auto-ingest with new reason code. If R7/R8 → flag. |
| `FABTenantTools.cs` — new MCP tool `CheckBlocklist` | Expose for Copilot-driven investigation: "Is this tenant related to a known ring?" |
| `DashboardController.cs` — new endpoint | Show blocklist match status on tenant detail page |
| Kusto sweep query | Daily: join new tenants in `TENANT_INFO` vs blocklist values, insert matches into `DetectionAutomationRulesData` |

### Kusto Sweep Query (R6/R7 Implementation)

This is the "are they back?" query — runs daily against all tenants created in the last 7 days:

```kql
// R6: Exact match — admin email, domain, phone in blocklist
let blocklist_emails = dynamic(["pengyoupy001@gmail.com", "mario@ritzmann.com.br", ...]);
let blocklist_domains = dynamic(["misty.moe", "sakurapy.com", "ourpage.cn", ...]);
let blocklist_phones = dynamic(["4258828080", "4196152228", ...]);
let known_tenant_ids = dynamic(["35ff20bc-...", ...]); // already remediated
TENANT_INFO
| where CREATED_DATE > ago(7d)
| where SITE_SUBSCRIPTION_ID !in (known_tenant_ids) // skip already-known
| where ADMIN_EMAIL in (blocklist_emails)
    or CURRENT_DEFAULT_DOMAIN has_any (blocklist_domains)
    or PHONE in (blocklist_phones)
| project SITE_SUBSCRIPTION_ID, TENANT_NAME, CURRENT_DEFAULT_DOMAIN, COUNTRY,
          ADMIN_EMAIL, PHONE, CREATED_DATE
```

```kql
// R7: Pattern match — sequential domain naming, known ring prefixes
TENANT_INFO
| where CREATED_DATE > ago(7d)
| where CURRENT_DEFAULT_DOMAIN matches regex @"^(procode\d{2,3}|acgdb\d+|familiaconfeitar\d+|mistytempsp\d+)"
    or TENANT_NAME matches regex @"^(ACGDB|FAMILIA CONFEITAR|MistyCloud)"
| project SITE_SUBSCRIPTION_ID, TENANT_NAME, CURRENT_DEFAULT_DOMAIN, COUNTRY, CREATED_DATE
```

SSIDs from these queries feed directly into `[fraud].[DetectionAutomationRulesData]` — the existing pipeline picks them up automatically.

### Blocklist Data Flow

```
blocklists/*.json (source of truth, maintained in repo)
        │
        ├──→ Kusto external table (for KQL joins in sweep queries)
        │         ↓
        │    DetectionAutomationRulesData (SSIDs of matches)
        │         ↓
        │    DetectionRemediationServiceImpl (existing pipeline picks up)
        │
        ├──→ BlocklistDetector.cs (loaded at startup, in-memory)
        │         ↓
        │    Detection pipeline enrichment (real-time scoring)
        │    MCP tool (Copilot investigation)
        │    Dashboard API (UI display)
        │
        └──→ Provisioning Gate API (future, cross-team)
                  ↓
             M365 Commerce / Entra ID (block creation)
```

---

## What's Ready Now

The `blocklists/` directory contains machine-readable JSON files ready for integration:
- Can be loaded into a Kusto table for join queries
- Can be served via an API for provisioning gate checks
- Can feed into the existing FAB scoring model
- Pattern files enable proactive detection of *new* tenants by the *same* operators
- **See [Blocklist Re-Entry Prevention Proposal](proposals/Blocklist_ReEntry_Prevention_Proposal.md) for the full engineering proposal**
