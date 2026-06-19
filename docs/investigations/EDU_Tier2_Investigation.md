# EDU Tier 2: High-Priority Investigation Cohort

**Date:** April 22, 2026  
**Source:** EDU Landscape Fraud Prevalence Investigation  
**Scope:** 3,568 tenants across 7 sub-categories — full Tier 1+2 from risk taxonomy  
**Status:** Investigation — pre-ingestion validation  
**Classification:** Microsoft Confidential  

---

## 0. Executive Summary — Critical Findings

1. **FAB Pipeline Blind Spot**: Zero FAB remediation records exist for ANY of these 3,568 tenants. The pipeline has zero visibility.
2. **EDU Eligibility Failure**: D2K shows `edu=approved` for tenants literally named "FRAUD EDU 2", "MICROSOFT", "FUTURE IT FIRM", and auto-generated gibberish names. The eligibility pipeline is rubber-stamping fraud.
3. **InstantOn bypass**: Multiple fraud tenants got `InstantOn=true` — bypassing manual review entirely.
4. **Cross-tenant actor links**: D2K admin emails link ring members — KNRC7367 admin is `admin@tmrc4556.onmicrosoft.com` (already flagged), Nathan Blower admin is `user2@autogenu4.onmicrosoft.com`. Same operators managing multiple fraud tenants.
5. **Segment migration**: Ring operators get flagged in non-EDU segments then recreate in EDU (TMRC4556 flagged → KNRC7367 unflagged in EDU).
6. **Personal name inflation**: The ~2,558 "personal name" category is heavily inflated by legitimate German/Austrian school names (GRUNDSCHULE, VOLKSSCHULE). True personal names are ~800-1,000.
7. **Zero StorageBought**: Not a single suspicious tenant bought additional storage — all free-tier abuse.
8. **210 test/dev/demo tenants**: Legitimate university test tenants hoarding millions of licenses.
9. **55.7 EB storage allocated to suspicious**: 25.6% of all A1 EDU storage goes to <50-user tenants. Actual usage across OMS samples: <1 TB total. The pool formula fundamentally over-allocates.
10. **Subscription-stacking attack**: 3 UK tenants created same-day stack 200/100/52 SPO subs to claim 1.6 EB of storage (0 GB used).

---

## 1. Cohort Definition

The full Tier 1+2 population from §23 risk taxonomy, broken into 7 sub-categories:

1. **Known fraud ring names** (YAM STORE, FUTURE IT FIRM) — global cross-country rings
2. **Brand impersonation** (MICROSOFT, OFFICE 365, OFFICE365, MICROSOFT 365, MICROSOFT CORPORATION, MSO365, CLOUD MSFT, M365 CLOUD, CLOUD STORAGE) — trademark abuse
3. **Self-declared fraud** (FRAUD EDU 2, domain `edufraud.onmicrosoft.com`)
4. **US auto-generated ring** (XXXX9999 pattern — KNRC7367, KHRU3300, etc.) — scripted creation
5. **Non-EDU industry in EDU segment** (Retailers, Capital Markets, Mining, Automotive, Oil & Gas, Insurance, Banking, Real Estate, Consumer Goods, Telecom) — clear segment mismatch, excluding tenants with school/college/university/academy in name

All tenants satisfy: `CustomerSegmentGroup == 'EDU' AND LicensesEnabled > 0 AND LicensesEnabled < 50 AND LicensesAcquired > 100,000 AND FraudState != 'True'`

---

## 2. Cohort Summary — Revised (3,568 tenants)

| Sub-Category | Count | Sum Lic Acquired | Description | Est. FP Rate |
|-------------|-------|-----------------|-------------|-------------|
| T2: Personal names | 2,558 | 5.6B | Two-word names matching `^[a-z]+ [a-z]+$` — includes legitimate German/Austrian schools | ~60% (schools) |
| T1: Gibberish single-word | 594 | 1.3B | 5-8 char single words — mix of gibberish and abbreviations | ~30% |
| T1: Test/Dev/Demo | 210 | ~500M | Names containing test/demo/sandbox/dev/trial/default directory | ~70% (legit uni test) |
| T2: Commercial entity | 157 | 360M | Names with trading/enterprise/solutions/technologies/consulting/etc. | ~20% |
| T1: Known fraud ring | 112 | 311M | YAM STORE (75), FUTURE IT FIRM (24), XXXX9999 (13) | ~0% |
| T1: Brand impersonation | 71 | 232M | MICROSOFT, OFFICE 365, OFFICE365, MICROSOFT 365, etc. | ~5% |
| T2: Non-EDU industry | 58 | 111M | Retailers, Banking, Mining, etc. in EDU segment | ~35% |
| T2: Self-declared fraud | 18 | 66M | Names containing "fraud", "test tenant", "demo tenant" | ~50% |
| **TOTAL (deduplicated)** | **3,568** | **~8.5B** | | |

**Note**: Some tenants may overlap categories. 3,568 is the deduplicated count.

---

## 3. OMS Spot-Check Results

### 3.1 Brand Impersonation

| TenantId | Name | Country | Domain | Disk Used | Viral | Verdict |
|----------|------|---------|--------|-----------|-------|---------|
| `df87739e` | MICROSOFT | HK | `mingschool.onmicrosoft.com` | 1 GB | YES | **FRAUD** — onmicrosoft-only, 21M lic, 26 users, Industry=Consumer Goods |
| `af0787dc` | MICROSOFT | US | *under NYC Board of Education TPID* | — | YES | **FRAUD** — parasitic on NYC BoE, 3M lic, 3 users |
| `730419bd` | OFFICE365 | Norway | *under Skooler AS* | — | NO | **INVESTIGATE** — parasitic on legitimate Skooler partner, 7M lic |

### 3.2 Known Fraud Rings

| TenantId | Name | Country | Domain | Disk Used | Viral | Verdict |
|----------|------|---------|--------|-----------|-------|---------|
| `9b003657` | FUTURE IT FIRM | India | `miltonacademygzb.onmicrosoft.com` | 28 GB | YES | **FRAUD** — hijacked Milton Academy name in domain, Ghaziabad UP |
| `75410325` | YAM STORE | India | `lamverd.com` | 0 GB | YES | **FRAUD** — commercial domain, Delhi, under MHRD TPID |
| `720f2ff6` | KNRC7367 | US | `knrc7367.onmicrosoft.com` | 0 GB | NO | **FRAUD** — auto-generated name, onmicrosoft-only, Birmingham AL |

### 3.3 Self-Declared Fraud

| TenantId | Name | Country | Domain | Disk Used | Viral | Verdict |
|----------|------|---------|--------|-----------|-------|---------|
| `e7892213` | FRAUD EDU 2 | India | `edufraud.onmicrosoft.com` | 0 GB | YES | **FRAUD** — literally named, 28.5M lic, 56 subscriptions(!), Hyderabad |

### 3.4 Non-EDU Industry (Potential False Positives)

| TenantId | Name | Country | Domain | Disk Used | Industry | Verdict |
|----------|------|---------|--------|-----------|----------|---------|
| `b4f55465` | BOONTHAVORN TECHNOLOGY COLLEGE | Thailand | `ms.boontech.ac.th` | 30 GB | Consumer Goods | **FALSE POSITIVE** — real Thai college, `.ac.th` domain, 30 GB usage |
| `dd1c3326` | AUSTRALIAN FITNESS ACADEMY | Australia | custom domain | 0 GB | Transport & Travel | **INVESTIGATE** — fitness training, 4M lic, 1 user, 0 disk |
| `e9d67a76` | LINCOLN.K12.OR.US | US | — | — | Capital Markets | **FALSE POSITIVE** — real K12 school district, miscategorized industry |

**Key finding:** The non-EDU industry sub-category has a **significant false positive rate** (~30-40%). Many are real schools that were miscategorized by the industry classification pipeline. These need individual review before any action.

---

## 4. Pattern Analysis

### 4.1 Brand Impersonation Patterns

**71 tenants** across 33 countries impersonate Microsoft brands:

| Brand | Count | Countries (sample) | Avg Lic |
|-------|-------|--------------------|---------|
| OFFICE 365 | 39 | VN(7), ID(5), IN, HK, FR, IE, HU, RO, TN, CA | 3.3M |
| MICROSOFT | 12 | HK, US(3), ID(2), IN, TH, JP | 5.0M |
| OFFICE365 | 10 | NO, HK, MY, PH, US, TH, DK, BG, DE | 3.4M |
| MICROSOFT 365 | 6 | VN, ID, UAE, IN, UK | 3.2M |
| MICROSOFT CORPORATION | 5 | JP, AU, PH, UK, US | 3.0M |
| CLOUD MSFT | 1 | IT | 4.0M |
| M365 CLOUD | 1 | MX | 3.0M |
| CLOUD STORAGE | 1 | ID | 3.0M |

**Vietnam dominates** brand impersonation (7 "OFFICE 365" tenants + 1 "MICROSOFT 365") — all created 2020–2023, parasiting Vietnamese high school TPIDs.

**Parasitic registration confirmed**: Brand impersonation tenants register under legitimate schools' parent orgs — NYC Board of Education, Hong Kong Education City, Vietnamese high schools, Indonesian SMKs.

### 4.2 Known Fraud Ring Geography

**YAM STORE (75 tenants)** — present in 25 countries:
- Asia Pacific: Indonesia (9), India (4), Nepal (4), Thailand (3), Vietnam (2), Singapore, Philippines, Sri Lanka, Pakistan, Malaysia
- Americas: Colombia (4), US (3), Mexico (3), Brazil (2), Chile, Ecuador, Peru, Dominican Republic, El Salvador
- EMEA: UK (3), Germany (2), South Africa, Kenya

**FUTURE IT FIRM (24 tenants)** — present in 18 countries:
- Each tenant registered under a DIFFERENT legitimate school's parent org
- Pattern: create tenant → name it "FUTURE IT FIRM" → but domain/TPID comes from the hijacked school
- Example: India tenant has domain `miltonacademygzb.onmicrosoft.com` (Milton Academy Ghaziabad)

### 4.3 US Auto-Generated Ring

13 tenants with `^[A-Z]{4}[0-9]{4}$` pattern, created Dec 2024–Jan 2025:

| TenantId | Name | Lic Acquired | Created |
|----------|------|-------------|---------|
| `bfe33636` | KHRU3300 | 6,000,000 | 2025-01-22 |
| `450f4c3f` | KDEH4411 | 6,000,000 | 2025-01-23 |
| `1da5a5f5` | UPPE2031 | 6,000,000 | 2025-01-28 |
| `1ffc3dce` | UVVT1449 | 6,000,000 | 2025-01-23 |
| `994f4713` | XORD8301 | 6,000,000 | 2025-01-22 |
| `720f2ff6` | KNRC7367 | 6,000,000 | 2025-01-22 |
| `95b57812` | FANL1459 | 6,000,000 | 2025-01-22 |
| `8345d541` | WNLD7962 | 6,000,000 | 2025-01-28 |
| `f64b2df5` | IXSM5433 | 5,000,000 | 2025-01-07 |
| `1c98fe13` | KARA6245 | 4,000,000 | 2025-01-07 |
| `17f4b4c5` | VSKH9432 | 1,000,000 | 2025-01-03 |
| `ca50fbc2` | JXJQ2490 | 1,000,000 | 2024-12-30 |
| `c0767185` | CGOK9372 | 1,000,000 | 2024-12-30 |

License escalation pattern: started at 1M (Dec 30), escalated to 4–5M (Jan 7), then 6M (Jan 22–28). Same actor testing limits.

### 4.4 FRAUD EDU 2 — The Extreme Case

Single tenant, India, Hyderabad (Gachibowli — tech hub area):
- **56 total subscriptions** — the most of any tenant in this cohort
- Domain: `edufraud.onmicrosoft.com` (the domain literally declares fraud)
- 28.5M licenses, 2 users, 0 GB disk
- HasViralSubscription=TRUE
- Created 2018 — has been active for 8 years unflagged

---

## 5. Recommended Action Plan

### Phase 1: Immediate (No ingestion needed)

1. **Validate non-EDU industry sub-category** (57 tenants) — expected ~30-40% false positive rate due to industry misclassification
   - Check for `.edu`, `.ac.*`, `.sch.*` custom domains → likely legitimate
   - Check for 0 disk + onmicrosoft-only → likely fraud
   - Split into "confirmed abuse" and "misclassified legitimate"

2. **D2K domain verification** on brand impersonation tenants — check `CompanyTags` for `edu=approved` vs `declined`

### Phase 2: Ingestion (After validation)

3. **Batch 1 — Highest confidence (est. ~180 tenants):**
   - All YAM STORE (75) → reason code 39 (Known Fraud Pattern)
   - All FUTURE IT FIRM (24) → reason code 39
   - All brand impersonation (71) → reason code 40 (Impersonation)
   - US XXXX9999 ring (13) → reason code 11 (Gibberish Tenant Names)
   - FRAUD EDU 2 (1) → reason code 36 (Suspicious org names)
   - `isReviewRequired=true`

4. **Batch 2 — After validation (~30-40 tenants):**
   - Confirmed non-EDU industry abuse (after removing false positives) → reason code 56 (EDU abuse)

### Phase 3: Expand to Tier 1 and Tier 3

5. **Tier 1** (confirmed rings) — the gibberish-name Dec 2024 burst (21 tenants), additional ring variants
6. **Tier 3** — orphan high-risk, requires D2K + OMS enrichment at scale

---

## 6. Investigation Vector Results

### 6.1 D2K CompanyTags — EDU Eligibility Pipeline Failure

Spot-checked 6 tenants from different sub-categories against D2K:

| TenantId | Name | edu Tag | InstantOn | Admin Email | Verdict |
|----------|------|---------|-----------|-------------|---------|
| `df87739e` | MICROSOFT (HK) | **edu=approved** | — | `a-mingsi@microsoft.com` | Pipeline approved brand impersonation |
| `e7892213` | FRAUD EDU 2 (IN) | **edu=approved** | InstantOn=true | `j@contoso.com` | Pipeline approved self-declared fraud |
| `9b003657` | FUTURE IT FIRM (IN) | **edu=approved** | InstantOn=true | `support@futureitfirm.io` | Pipeline approved known ring |
| `720f2ff6` | KNRC7367 (US) | **edu=approved** | — | `admin@tmrc4556.onmicrosoft.com` | Pipeline approved auto-generated |
| `17c81ccf` | NATHAN BLOWER (US) | **edu=approved** | — | `user2@autogenu4.onmicrosoft.com` | Pipeline approved personal name |
| `dc19732c` | YAM STORE (US) | **edu=pendingapproval** | InstantOn=true | `44danelaballos@hotmail.com` | Still pending but has EDU subs |

**Key insight**: 5 of 6 blatant fraud tenants got `edu=approved`. The eligibility pipeline is not performing name-based or signal-based screening.

### 6.2 Cross-Tenant Actor Detection (D2K Admin Emails)

D2K reveals admin email cross-links between ring members:

**US Auto-Generated Ring:**
- KNRC7367 → admin: `admin@tmrc4556.onmicrosoft.com` → TMRC4556 is **already flagged** (`FraudState=True`, non-EDU)
- NATHAN BLOWER → admin: `user2@autogenu4.onmicrosoft.com` → another auto-generated tenant
- ZAINMARK → parented under `RRNJ3840` → another auto-generated name pattern

**FUTURE IT FIRM (India):**
- Admin: `support@futureitfirm.io` (commercial IT domain)
- Security email: `eva.demon90@hotmail.com` (personal hotmail)
- Domains: `miltonacademygzb.onmicrosoft.com` + `miltonacademyghaziabad.in` + `mindtechsolution.cfd` (cheap fraud TLD)

**YAM STORE (US):**
- Admin: `44danelaballos@hotmail.com`
- Domains: `adaenerat.onmicrosoft.com` + `kolpiuters.com` (misspelled "computers")

**Cross-segment migration confirmed**: TMRC4556 flagged as fraud in non-EDU → same operator created KNRC7367 in EDU with 6M licenses, unflagged.

### 6.3 Subscription Count Anomalies

50 tenants have >20 O365 subscriptions (normal is 4-8):

| Tenant | Subs | Lic Acquired | Notes |
|--------|------|-------------|-------|
| HOYLAND SPRINGWOOD (UK) | 200 | 200M | Known suspicious, 2 users |
| PUSAN NATIONAL UNIVERSITY (KR) | 125 | 62M | Likely legitimate large uni |
| HANDSWORTH GRANGE (UK) | 100 | 100M | Known suspicious, 1 user |
| FRAUD EDU 2 (IN) | 56 | 28.5M | Self-declared fraud |
| ALBURGH WITH DENTON (UK) | 52 | 48M | 1 user, mass sub-stacking |
| FOCUS HIVE (US) | 47 | 3M | 45 users, under Tao Learning |
| NETVIEW MAROC (MA) | 43 | 1.5M | Under French institutes |
| MICROSOFT EDUCATION (MY) | 33 | 8M | Brand impersonation |

**UK subscription-stacking pattern**: HOYLAND (200), HANDSWORTH (100), ALBURGH (52) — all UK tenants stacking subscriptions to inflate license counts.

### 6.4 StorageBought Analysis

**Zero tenants** in the entire suspicious population have `StorageBought > 0`. This confirms all abuse is free-tier only — no credit card fraud escalation.

### 6.5 AllowedOverageQuantity

All 28,755 suspicious tenants have `AllowedOverageQuantity > 1M` with `IncludedQuantity ≈ 0`. The overage mechanism is the primary vehicle for license inflation.

### 6.6 O365TenantReleaseTrack

| Track | Suspicious | Total EDU | Suspicious % |
|-------|-----------|-----------|-------------|
| Education | 28,643 | 555,613 | 5.16% |
| Viral and Other | 61 | 197,386 | 0.03% |
| (blank) | 47 | 91,363 | 0.05% |
| Charity | 4 | 2,600 | 0.15% |

**98.9%** of suspicious tenants are on the Education release track — no anomalous ring concentration on other tracks.

### 6.7 TopSkuSegment Distribution

| SKU | Count | Sum Lic | Notes |
|-----|-------|---------|-------|
| O365 A1 | 23,422 | 51B | **81%** — the overwhelming abuse vector |
| A3 | 4,648 | 10B | 16% — significant non-A1 abuse |
| A5 | 494 | 0.9B | 1.7% — premium SKU abuse |
| E3 | 24 | 71M | Commercial SKU crossover |
| E5 | 7 | 10M | Commercial SKU crossover |
| E1 | 8 | 13M | Commercial SKU crossover |

**Non-A1 abuse is 19%** — not limited to A1 free tier. A3 and A5 SKUs represent significant over-provisioning.

### 6.8 FraudStateUpdatedTime

2,611 EDU tenants have `FraudState=True`, but **zero have FraudStateUpdatedTime populated**. The timestamp field is not maintained in DIM_TENANTS, preventing temporal analysis of detection cadence.

### 6.9 Personal Name Category Analysis

The 2,558 "personal name" tenants (two-word pattern) are heavily inflated:

| Country | Count | Common Pattern | Likely FP? |
|---------|-------|---------------|-----------|
| Germany | 386 | GRUNDSCHULE + location | **Yes** — real schools |
| Austria | 213 | VOLKSSCHULE + location | **Yes** — real schools |
| United States | 213 | Mix of real names + school names | ~50% |
| United Kingdom | 191 | Mix | ~40% |
| India | 137 | Mix, many true personal names | ~20% |
| Indonesia | 95 | SMK/SDN + location | **Yes** — real schools |

After filtering German/Austrian/Indonesian school patterns and cross-referencing with TopParentName, estimated **~800-1,000 true personal name abuse** out of 2,558.

### 6.10 Gibberish Single-Word Names (594 tenants)

Mix of actual gibberish and abbreviations. Key suspicious examples:

| Name | Country | Parent | Lic | Signal |
|------|---------|--------|-----|--------|
| TENANT | Czechia | Parliament children org | 10M | Generic name |
| CLOUD | Colombia | UNIV PARIS 8 | 6.6M | **Parasitic** — Colombia under Paris uni |
| CRUERIZE | Germany | self | 6M | Pure gibberish |
| ZAINMARK | US | **RRNJ3840** | 6M | **Ring link** — parent is auto-gen name |
| ADMIN | Indonesia | self | 4.5M | Generic name |
| IOFFICED | Thailand | self | 4.5M | Commercial service name |

### 6.11 Test/Dev/Demo Tenants (210 tenants)

Legitimate university test tenants with excessive over-provisioning:
- MEMORIAL UNIVERSITY TEST DOMAIN (Canada, 5M lic, 37 users)
- NYIT TEST TENANT (US, 4M lic, 8 users)
- AZUREAD-TEST (US, 3M lic, under UPenn, 33 users)
- SCHULUNGS-TEST-TENANT (Germany, 3M lic)

Most are legitimately created by universities for testing but hold millions of unused licenses. Policy issue rather than fraud.

### 6.12 Commercial SKU Crossover (39 tenants)

EDU tenants on E1/E3/E5/F1/Project SKUs — suspicious segment mismatch:
- "SANDRA IS HERE" (Romania, E5, 3M lic, 3 users) — suspicious
- "DEFAULT DIRECTORY" (China, E3, 4M lic, 1 user) — 2 instances
- "HOLY ROSARY BILINGUAL ACADEMY" (US, E3, 8M lic, 1 user)
- BLACKBOARD (US, E5, 1M lic) — legitimate ed-tech company

---

## 7. Full Tenant ID List

### 7.1 Known Fraud Ring — YAM STORE (75 tenants)

_(Query: `OrganizationName == 'YAM STORE' AND LicensesEnabled > 0 AND LicensesEnabled < 50 AND LicensesAcquired > 100000 AND FraudState != 'True'`)_

### 7.2 Known Fraud Ring — FUTURE IT FIRM (24 tenants)

_(Query: `OrganizationName == 'FUTURE IT FIRM' AND LicensesEnabled > 0 AND LicensesEnabled < 50 AND LicensesAcquired > 100000 AND FraudState != 'True'`)_

### 7.3 Brand Impersonation (71 tenants)

```
df87739e-022a-41ff-9bd3-8613a919981c  MICROSOFT (HK, 21M lic)
730419bd-f4e4-45b3-86f9-b771a2be8c65  OFFICE365 (NO, 7M lic)
fffb5d2e-5dcd-4e44-9ce2-51a74f0dedf0  OFFICE 365 (HK, 5M lic)
efe4025c-02de-4d1f-b3cc-048cb0e7ce8d  OFFICE 365 (HU, 4M lic)
6cf86c71-5031-434f-9d29-6a02790fb284  OFFICE 365 (VN, 4M lic)
81865d22-c188-4c4e-a610-a157e00191a2  OFFICE 365 (FR, 4M lic)
69489b23-8fe6-4119-b45f-632b354c8f5d  OFFICE 365 (IN, 4M lic)
35b83bcf-59c0-4175-96a0-9dac7c5db196  MICROSOFT (ID, 4M lic)
2a50299b-794a-46c3-909e-86fd7d1ecbac  MICROSOFT 365 (ID, 4M lic)
3e20a313-55f8-40fd-857d-171b7f2345b5  OFFICE 365 (IE, 4M lic)
565020b5-126d-4fe8-8150-6cc664bcd809  OFFICE 365 (TN, 4M lic)
0a96f8b9-2af1-4bef-aa9c-0f1a75af0c63  OFFICE 365 (VN, 4M lic)
fda8fd8b-b56a-4d07-a6f9-831822adaf7a  OFFICE 365 (VN, 4M lic)
17927bb6-da61-4a97-b7a1-9e5c070ccb4f  OFFICE 365 (CA, 4M lic)
5e78d7d2-2665-405f-a78b-711ee34de54b  MICROSOFT 365 (UAE, 4M lic)
1b761459-dd81-4729-9f85-bb0565f04f1d  CLOUD MSFT (IT, 4M lic)
6ec925b8-6a78-467c-a6b3-cd8bc28361c4  OFFICE 365 (VN, 4M lic)
7af68d75-20cc-40c1-9ca7-7363aa8a7aba  OFFICE 365 (VN, 4M lic)
63ded175-aea7-4ad3-b002-19ebd661df47  OFFICE365 (MY, 3.2M lic)
af8af6cb-c08e-44ad-9cc9-36ebaaeb79ce  M365 CLOUD (MX, 3M lic)
3ebdaee9-c420-4a62-afa7-989ce7abf6d5  OFFICE 365 (ID, 3M lic)
e112b87e-db84-4181-b846-60f1d53bc96e  MICROSOFT 365 (VN, 3M lic)
e14bae6e-f1a4-4cb5-953e-04239f668116  MICROSOFT CORPORATION (JP, 3M lic)
af0787dc-9f2e-423a-92ab-2e7b187f0a08  MICROSOFT (US, 3M lic)
8b746dc7-5283-4e28-9114-7c3455d9a9ba  OFFICE365 (HK, 3M lic)
5bb38414-c25e-46d8-b680-713ba1d0df6d  OFFICE 365 (RO, 3M lic)
63150348-f941-47d5-8576-3139743ec3a9  OFFICE 365 (ID, 3M lic)
d365fd04-7998-439c-adcd-dcb326b3a85b  MICROSOFT CORPORATION (AU, 3M lic)
653aea0e-699a-4c1f-9012-d2b14587cd55  OFFICE 365 (ID, 3M lic)
5896bc58-a629-4d57-baa2-81b025038a5f  MICROSOFT (US, 3M lic)
```
_(Full list continues — 71 total. Retrieve via Kusto query in §6.2 definition.)_

### 7.4 US Auto-Generated Ring (13 tenants)

```
bfe33636-bb87-489b-b6f2-89d84444d5d4  KHRU3300 (6M)
450f4c3f-9ad4-4a9d-b382-fb9d1d4ce982  KDEH4411 (6M)
1da5a5f5-289a-4649-be3b-a3bb46c15e15  UPPE2031 (6M)
1ffc3dce-ed23-4906-8b91-2910f81f4dc4  UVVT1449 (6M)
994f4713-ba51-4cf6-a22b-335da1ed130b  XORD8301 (6M)
720f2ff6-3e58-4682-ad1b-cc2c52b42398  KNRC7367 (6M)
95b57812-ecf7-44c1-975c-638739105d66  FANL1459 (6M)
8345d541-6ab2-40b4-8a37-3630f783aa4f  WNLD7962 (6M)
f64b2df5-7d55-4bb8-bd7c-f0c815404e1d  IXSM5433 (5M)
1c98fe13-7747-4f5a-89e5-0e2d9b8d9d94  KARA6245 (4M)
17f4b4c5-6014-4c15-add6-46046923802c  VSKH9432 (1M)
ca50fbc2-f527-4abf-aada-c52da14adf1b  JXJQ2490 (1M)
c0767185-64b4-49b1-902e-d864a701235f  CGOK9372 (1M)
```

### 7.5 Self-Declared Fraud (1 tenant)

```
e7892213-23dd-45ab-bc81-df1d18aa1d03  FRAUD EDU 2 (IN, 28.5M lic)
```

### 7.6 Non-EDU Industry — Needs Validation (57 tenants)

_(These require individual OMS + domain review. ~30-40% expected false positive due to industry misclassification.)_

**Kusto query to reproduce:**
```kql
DIM_TENANTS
| where CustomerSegmentGroup == 'EDU'
| where LicensesEnabled > 0 and LicensesEnabled < 50
| where LicensesAcquired > 100000 and FraudState != 'True'
| where Industry in ('Retailers', 'Capital Markets', 'Mining', 'Automotive',
    'Oil & Gas', 'Insurance', 'Banking', 'Real Estate', 'Consumer Goods',
    'Telecommunications')
| where not(tolower(OrganizationName) contains 'school'
    or tolower(OrganizationName) contains 'college'
    or tolower(OrganizationName) contains 'university'
    or tolower(OrganizationName) contains 'academy')
| project OMSTenantId, OrganizationName, MSSalesCountry, Industry,
    LicensesAcquired, LicensesEnabled
| order by LicensesAcquired desc
```

---

## 8. Kusto Queries for Full Extraction

### Full Tier 1+2 population (3,568 deduplicated)
```kql
let suspicious = DIM_TENANTS
| where CustomerSegmentGroup == 'EDU' and LicensesEnabled > 0
    and LicensesEnabled < 50 and LicensesAcquired > 100000
    and FraudState != 'True';
let nameL = suspicious | extend NL = tolower(OrganizationName);
let t1_rings = nameL | where NL in ('yam store', 'future it firm')
    or NL matches regex '^[a-z]{4}[0-9]{4}$';
let t1_brand = nameL | where NL in ('office 365', 'office365', 'microsoft',
    'microsoft 365', 'microsoft corporation', 'mso365', 'cloud storage',
    'cloud msft', 'm365 cloud');
let t1_gibberish = nameL | where NL matches regex '^[a-z]{5,8}$';
let t2_industry = nameL | where Industry in ('Retailers', 'Capital Markets',
    'Mining', 'Automotive', 'Oil & Gas', 'Insurance', 'Banking',
    'Real Estate', 'Consumer Goods', 'Telecommunications')
    and not(NL contains 'school' or NL contains 'college'
    or NL contains 'university' or NL contains 'academy');
let t2_personal = nameL | where NL matches regex '^[a-z]+ [a-z]+$'
    and strlen(NL) < 25 and not(NL contains 'school' or NL contains 'college'
    or NL contains 'university' or NL contains 'store' or NL contains 'office'
    or NL contains 'microsoft');
let t2_selfdeclared = nameL | where NL contains 'fraud'
    or NL contains 'test tenant' or NL contains 'demo tenant';
let t2_commercial = nameL | where (NL contains 'trading'
    or NL contains 'enterprise' or NL contains 'solutions'
    or NL contains 'technologies' or NL contains 'consulting'
    or NL contains 'services ltd' or NL contains 'corp'
    or NL contains 'inc.' or NL contains 'llc' or NL contains 'pvt'
    or NL contains 'private limited')
    and not(NL contains 'school' or NL contains 'college'
    or NL contains 'university' or NL contains 'academy'
    or NL contains 'education');
union t1_rings, t1_brand, t1_gibberish, t2_industry, t2_personal,
    t2_selfdeclared, t2_commercial
| distinct OMSTenantId, OrganizationName, MSSalesCountry, Industry,
    LicensesAcquired, LicensesEnabled
| order by LicensesAcquired desc
```

### All YAM STORE tenant IDs
```kql
DIM_TENANTS
| where CustomerSegmentGroup == 'EDU' and OrganizationName == 'YAM STORE'
| where LicensesEnabled > 0 and LicensesEnabled < 50
| where LicensesAcquired > 100000 and FraudState != 'True'
| project OMSTenantId, MSSalesCountry, LicensesAcquired, TopParentName
| order by MSSalesCountry asc
```

### All FUTURE IT FIRM tenant IDs
```kql
DIM_TENANTS
| where CustomerSegmentGroup == 'EDU' and OrganizationName == 'FUTURE IT FIRM'
| where LicensesEnabled > 0 and LicensesEnabled < 50
| where LicensesAcquired > 100000 and FraudState != 'True'
| project OMSTenantId, MSSalesCountry, LicensesAcquired, TopParentName
| order by MSSalesCountry asc
```

### All brand impersonation tenant IDs
```kql
DIM_TENANTS
| where CustomerSegmentGroup == 'EDU'
| where LicensesEnabled > 0 and LicensesEnabled < 50
| where LicensesAcquired > 100000 and FraudState != 'True'
| where tolower(OrganizationName) in ('office 365', 'office365', 'microsoft',
    'microsoft 365', 'microsoft corporation', 'mso365', 'cloud storage',
    'cloud msft', 'm365 cloud')
| project OMSTenantId, OrganizationName, MSSalesCountry, LicensesAcquired
| order by LicensesAcquired desc
```

---

*Investigation file created April 22, 2026. Updated with 12 investigation vectors, D2K cross-referencing, and full 3,568-tenant Tier 1+2 population. Pre-ingestion validation in progress.*
