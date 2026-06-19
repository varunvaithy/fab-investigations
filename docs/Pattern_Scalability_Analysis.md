# FAB Cross-Investigation Pattern Scalability Analysis

**Started:** June 11, 2026  
**Owner:** Varun V  
**Purpose:** Catalog all discovery signals across 21 investigations, classify structural vs. behavioral, assess rule potential, and track expansion work.

---

## Pattern Taxonomy

### STRUCTURAL Patterns (metadata-queryable, no activity telemetry needed)

| # | Pattern | Used In | Confirmed Scale | Explored at Scale? | Rule Potential | Status |
|---|---------|---------|----------------|-------------------|----------------|--------|
| S1 | **Admin email clustering** (same email → N tenants) | INV-005 (33t, 1 email), INV-009 (8,939t, 30 emails), INV-014 Ring 1 (1 email → 30t) | 8,939+ tenants | ❌ Only 3 rings explored (APAC + partial EU/WUS) | **HIGH** — Scalable query, near-zero FP | 🔲 TODO |
| S2 | **Sequential/patterned naming** (ACGDB1-N, procode003-967, familiaconfeitar2-30, hamter1-20) | INV-004, INV-005, INV-007, INV-009, INV-014 | 3,900+ tenants | ❌ Only specific rings explored | **MEDIUM** — Regex-detectable, legitimate test envs exist | 🔲 TODO |
| S3 | **High-entropy gibberish names** (4-char random, keyboard-smash) | INV-004 (31t, 2.9 PB), INV-021 (15/50 sample), INV-009 | 31+ confirmed | ❌ Never queried at scale | **MEDIUM** — Needs NLP/entropy + compound signal | 🔲 TODO |
| S4 | **Licenses ÷ Users ratio** (>1000:1) | INV-008, INV-010, INV-016, INV-017, INV-019 (3M cluster: 10,997t) | 29,790 suspicious | ⚠️ Partially (INV-019 landscape) | **HIGH** — Simple arithmetic, massive population | 🔲 TODO |
| S5 | **EDU-declined + still provisioned** | INV-011 (2,902t, 99.5% precision) | 2,902 | ✅ Fully validated | **READY** — Config change only | 🔲 Implement |
| S6 | **Commercial + EDU signal + never paid + zero users** | INV-012 (~47,800t, 0% FP) | 47,800 | ✅ Fully validated | **READY** — Config change only | 🔲 Implement |
| S7 | **D2K locked=abuse + Feature 66 + SPO provisioned** | INV-021 (35,881t, 100% precision) | 35,881 | ✅ Fully validated | **READY** — Needs D2K→FAB bridge | 🔲 Implement |
| S8 | **Burst provisioning velocity** (N tenants from M emails in Z days) | INV-005 (14 in 25 min), INV-006 (9 in 76 min), INV-009 (3,749 in 12 days) | 8,939+ | ❌ Never implemented as detection | **HIGH** — Preventive (catches before abuse) | 🔲 TODO |
| S9 | **Brand-impersonation domains** (ms365vip.com, msdrive365.com, office365.wiki, tm[X].site) | INV-010, INV-016, INV-017, INV-007 | 15+ confirmed | ❌ Never queried at scale | **HIGH** — Near-zero FP, clear intent | 🔲 TODO |
| S10 | **Registration anomaly clusters** (shared phone, 000000 postcode, GeminiSignUpUI) | INV-016 (162 CN tenants), INV-001 | 162+ | ❌ Only CN ring explored | **MEDIUM** — Noisy alone, needs compound | 🔲 TODO |

### BEHAVIORAL Patterns (require Kusto activity telemetry)

| # | Pattern | Used In | Confirmed Scale | Explored at Scale? | Rule Potential | Status |
|---|---------|---------|----------------|-------------------|----------------|--------|
| B1 | **CDN score (egress:ingress >100:1)** | INV-014 (30t, 1.9 PB), INV-015, INV-016 | 30+ confirmed | ❌ Validated — catches nothing net-new (overlap) | **LOW** for rule, **HIGH** for prioritization | ℹ️ Deprioritized |
| B2 | **Niche app fingerprints** (Cloudreve=291, StableBit=22 globally) | INV-013 (9t), INV-014 (7 Cloudreve) | 313 tenants globally | ❌ Never auto-flagged | **HIGH** — Near-100% fraud | 🔲 TODO |
| B3 | **rclone + compound** (rclone + >10TB + MAU<5 + never paid) | INV-014 (139t), INV-015, INV-016, INV-020 | 10,515 rclone total | ⚠️ Too broad alone | **MEDIUM** — Behavioral (tool choice) | 🔲 TODO |
| B4 | **Mobile CDN UA + zero ingress** (androiddownloadmanager, stagefright, applecoremedia) | INV-016, INV-014 | 24,200 tenants | ❌ Never auto-flagged | **MEDIUM** — Needs volume threshold | 🔲 TODO |
| B5 | **Storage growth rate** (>5 TB/week on ≤3 seats) | INV-015 (2.5 TB/day), INV-006 | Unquantified | ❌ Compound threshold caught zero in testing | **LOW** — Hard to threshold | ℹ️ Deprioritized |
| B6 | **Dormant then burst** (months idle → sudden TB-scale activity) | INV-022 (dump & abandon), INV-007 (21mo dormant) | Unquantified | ❌ Never explored | **UNKNOWN** | 🔲 TODO |

---

## Expansion Work Plan (Prioritized)

### 🥇 Tier 1 — Highest ROI (proven signal + large unexplored population)

| # | Task | Signal | Data Needed | Query Template | Expected Yield | Status |
|---|------|--------|-------------|---------------|----------------|--------|
| 1 | **Full D2K admin email clustering** | S1+S8 | D2K Kusto (all 7 shards) | `Company \| summarize TenantCount=count(), MinDate=min(WhenCreated), MaxDate=max(WhenCreated) by TechnicalNotificationMail \| where TenantCount > 5` | 50K–100K+ ring tenants | 🔲 Not started |
| 2 | **License ÷ Users at DIM_TENANTS scale** | S4 | fabpartnerdb DIM_TENANTS | `SELECT * FROM DIM_TENANTS WHERE LicensesAcquired > 100000 AND TotalUsers < 10 AND HasPaid = 'FALSE' AND FraudState = 'False'` | 29,790 suspicious (gap vs FAB) | 🔲 Not started |
| 3 | **Brand-impersonation domain sweep** | S9 | D2K VerifiedDomains | `Company \| mv-expand D=parse_json(VerifiedDomains) \| where D.Name matches regex "(?i)(ms365\|office365\|msdrive\|onedrive\|cloud\|azure)" and D.Name !endswith "onmicrosoft.com"` | Dozens of reselling storefronts | 🔲 Not started |
| 4 | **Provisioning velocity (global)** | S8 | D2K all shards | `Company \| summarize cnt=count(), minD=min(WhenCreated), maxD=max(WhenCreated) by TechnicalNotificationMail \| where cnt > 3 and datetime_diff('day', maxD, minD) < 30` | 10x beyond 8,939 already known | 🔲 Not started |

### 🥈 Tier 2 — High potential (smaller effort, good precision)

| # | Task | Signal | Data Needed | Expected Yield | Status |
|---|------|--------|-------------|----------------|--------|
| 5 | **Cloudreve/StableBit full population** | B2 | SpoProd Kusto (7d) | ~200 unflagged tenants (small but free) | 🔲 Not started |
| 6 | **Name entropy scoring** | S3 | DIM_TENANTS DisplayName | New gibberish-name rings | 🔲 Not started |
| 7 | **Phone clustering + compound** | S10 | D2K Company | CN/VN ring expansions | 🔲 Not started |
| 8 | **EDU 3M-license cluster deep-dive** | S4 | DIM_TENANTS | 10,997 tenants at exactly 3M licenses — fraud ring or system artifact? | 🔲 Not started |

### 🥉 Tier 3 — Ready for Implementation (validated, just need engineering)

| # | Task | Signal | Validated At | Precision | Tenants | Action Required |
|---|------|--------|-------------|-----------|---------|-----------------|
| 9 | **Deploy S5 (EDU-declined ghost cleanup)** | S5 | INV-011: 200 samples | 99.5% | 2,902 | Config change — rule or bulk ingestion |
| 10 | **Deploy S6 (Commercial-EDU mismatch)** | S6 | INV-012: 100 samples | 100% | 47,800 | Config change — auto-flag |
| 11 | **Build S7 (D2K→FAB bridge)** | S7 | INV-021: 50 samples | 100% | 35,881 | Engineering — new integration pipeline |

---

## Ring Discovery Playbook (Methodology)

How we've found rings — codified for reuse:

1. **Seed tenant** — Start with a suspicious tenant (from Kusto top-N, egress anomaly, DS model output, or rule catch)
2. **Pivot on admin email** → D2K Company table, all shards. If email has >1 tenant, you have a potential ring.
3. **Pivot on registration metadata** → Same phone? Same postal code? Same creation day? Same country+city?
4. **Pivot on domain patterns** → Sequential naming? Shared custom domains? onmicrosoft-only cluster?
5. **Validate storage abuse** → DIM_TENANTS: StorageLimit vs DiskUsed ratio, TotalUsers, HasPaid, LicensesAcquired
6. **Cross-reference FAB** → How many are already tracked? What's the gap?
7. **Quantify ring** → Total storage, total tenants, estimated cost to Microsoft
8. **Ingest gap** → Submit unflagged ring members via MCP

### Key pivot tables (D2K):
- `Company.TechnicalNotificationMail` — admin email clustering
- `Company.DisplayName` — naming pattern detection
- `Company.VerifiedDomains` — domain-based ring expansion
- `Company.TelephoneNumber` + `Company.PostalCode` — registration anomaly detection
- `Company.WhenCreated` — burst/velocity detection
- `Company.CountryLetterCode` + `Company.City` — geographic clustering

### Key pivot tables (ODSP/FAB):
- `DIM_TENANTS.TotalUsers` + `LicensesAcquired` — provisioning anomaly
- `DIM_TENANTS.TenantTotalDiskUsedGB` + `StorageLimitGB` — over-quota detection
- `FRAUD_TENANT_DETAILS.FraudState` — what's already in FAB
- `SpoProd.RequestUsage.AppName` — tool fingerprinting
- `SpoProd.RequestUsage.UserAgent` — UA-based CDN detection

---

## Data Access Requirements

| Data Source | Access Method | Scope | Notes |
|-------------|--------------|-------|-------|
| D2K (Identity) | Kusto Web Explorer → `idshared*.kusto.windows.net` | 7 global shards | Requires APAC, WUS, WEU, JPN, AUS, CNN2, ARAZ |
| fabpartnerdb | SQL via FAB dashboard or direct connection | Full DIM_TENANTS | ~3.8M tenants |
| SpoProd (ODSP telemetry) | Kusto → `spo-prod-*.kusto.windows.net` | 7-day rolling window | RequestUsage, BlobUsage |
| FAB MCP Tool | `mcp_fabtenanttool_get_tenant_remediation_info` | Per-tenant lookup | Rate-limited |

---

## Rules Already Validated (from INV-v3 recommendations)

For reference — these were validated in the April 2026 rules effectiveness investigation:

### Quick Wins (existing rules):
1. Remove SKU restriction from R4 → ~7+ PB detectable
2. Remove SKU restriction from R2 → streaming CDN on any SKU
3. Remove SKU restriction from R3 → egress detection on commercial
4. Expand R5 to F1 Kiosk + SPO Plans → cheapest SKU blind spot
5. Run R5 backfill → 30 missed tenants (1.9 PB)

### Net-New Rules Proposed (from v3 paper):
- **1a:** Niche abuse-tool (Cloudreve/StableBit) — any storage level
- **1b:** CDN UA + volume — androiddownloadmanager/stagefright/applecoremedia + egress >100GB + zero ingress
- **1c:** rclone + compound — rclone + >10TB + MAU<5 + never paid
- **2:** Provisioning velocity — 3+ tenants from 1 admin in 30 days
- **3:** CDN Score — egress:ingress >100:1 on any SKU
- **4:** Gibberish name detection — high-entropy org names
- **5:** Storage growth rate — >5TB/7d on ≤3-seat tenant
- **6:** D2K admin email clustering — same email across shards
- **7:** Brand-impersonation domains — custom domains mimicking MS brands
- **8:** Registration anomaly scoring — shared phones, fake postcodes, GeminiSignUpUI

---

## Progress Log

| Date | Activity | Outcome |
|------|----------|---------|
| 2026-06-11 | Initial taxonomy created from 21 investigations + rules analysis | S1–S10, B1–B6 cataloged. 3 signals ready for deployment (S5/S6/S7). 4 Tier 1 expansion tasks identified. |
| | | |

---

## Reminders & Next Steps

- [ ] **IMMEDIATE:** Deploy S5/S6/S7 — these are validated, zero-FP signals waiting for implementation
- [ ] **This sprint:** Run Task #1 (admin email clustering) — highest ROI, how we found our 3 biggest rings
- [ ] **This sprint:** Run Task #2 (license÷users ratio at scale) — 29,790 suspicious, most unflagged
- [ ] **Next sprint:** Run Task #3 (brand-impersonation domain sweep) — low effort, high precision
- [ ] **Next sprint:** Run Task #5 (Cloudreve/StableBit population) — 313 tenants, near-100% fraud
- [ ] **Monthly:** Re-run email clustering query to catch new burst botnets
- [ ] **Quarterly:** Re-assess rule effectiveness (track R2/R3/R5 decay, validate new rules)
- [ ] **FY27 planning:** Propose D2K→FAB integration pipeline for S7 (engineering budget needed)

---

*Living document — update as expansion work progresses.*
