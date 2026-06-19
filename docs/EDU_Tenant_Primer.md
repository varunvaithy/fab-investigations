# EDU Tenant Primer — The Full Picture

**Date:** April 21, 2026
**Author:** Varun V (FAB Tenant Service)
**Purpose:** Comprehensive grounding document on Microsoft 365 Education tenants — onboarding, verification, lifecycle, fraud vectors, and systemic weaknesses. Covers ODSP/storage fraud (FAB scope) and broader financial/platform abuse (CFAR scope).

---

## 1. What Is an EDU Tenant?

An EDU tenant is a Microsoft 365 / Office 365 tenant that has been verified as belonging to a **Microsoft Qualified Academic Institution** (MQAI). Once verified, the tenant gets access to EDU-specific SKUs (A1/A3/A5) at free or deeply discounted pricing, and the `edu=approved` tag is written into the tenant's D2K `CompanyTags`.

The three EDU plan tiers:

| Plan | Cost | Desktop Office Apps | ODB per User | Pool Contribution | Max Users |
|------|------|-------------------|-------------|-------------------|-----------|
| **Office 365 A1** | **Free forever** | No (web only) | 100 GB | **0 GB** | 500,000 |
| **Office 365 A3** | ~$2.50/user/mo (academic pricing) | Yes | 1-5 TB | 50 GB | 500,000 |
| **Office 365 A5** | ~$6.00/user/mo | Yes + Phone System | 1-5 TB | 100 GB | 500,000 |

Every EDU tenant — regardless of how many free A1 licenses it assigns — gets a **100 TB pooled storage base** across SPO + ODB + Exchange. This is the central design fact that makes EDU so attractive for abuse.

**Sources:**
- [Office 365 Education service description](https://learn.microsoft.com/en-us/office365/servicedescriptions/office-365-platform-service-description/office-365-education)
- [SharePoint Online limits](https://learn.microsoft.com/en-us/office365/servicedescriptions/sharepoint-online-service-description/sharepoint-online-limits)

---

## 2. Onboarding Flow — How a School Gets Verified

### Step 1: Signup (Self-Service, < 5 minutes)

1. Navigate to `microsoft.com/education/products/office`
2. Enter a **school email address** (e.g., `admin@university.edu.cn`)
3. Microsoft creates a **trial tenant** immediately — the school can start using it right away
4. A `.onmicrosoft.com` domain is automatically provisioned

**Critical gap:** The trial starts **before** verification completes. The tenant exists, licenses can be assigned, and services are provisioned while verification is still pending.

**Source:** [Create your Office 365 tenant account](https://learn.microsoft.com/en-us/microsoft-365/education/deploy/create-your-office-365-tenant)

### Step 2: Academic Eligibility Verification

The verification wizard runs after the trial is created. It has **three possible outcomes**:

| Outcome | D2K CompanyTag | What Happens |
|---------|---------------|-------------|
| **Instant Approval** | `edu=approved` | Domain recognized in Microsoft's database. Tenant gets full EDU privileges immediately |
| **Manual Review** | `edu=pendingapproval` | Microsoft requests additional documentation. Review takes up to **10 business days** |
| **Declined** | `edu=declined` | School doesn't qualify. Tenant can still exist as Commercial, but no EDU pricing |

**What Microsoft checks:**
- The organization must be a **Microsoft Qualified Academic Institution (MQAI)** — defined as an accredited institution that grants degrees, certificates, or diplomas
- Domain verification: the applicant must prove DNS control of the school's domain (TXT or MX record)
- For instant approval: the domain must exist in Microsoft's proprietary database of known academic institutions worldwide
- For manual review: Microsoft may request accreditation documents, government registration, or other proof

**Source:** [Verify academic eligibility for Microsoft 365 Education subscriptions](https://learn.microsoft.com/en-us/microsoft-365/commerce/subscriptions/verify-academic-eligibility)

### Step 3: Domain Verification (DNS Proof)

The school admin must add a TXT record to their domain's DNS to prove ownership. This is the **only technical gate** — it proves DNS control, not institutional legitimacy.

### Step 4: License Assignment

Once verified, the admin can:
- Self-provision up to **500,000 A1 licenses** at no cost
- Enable student self-service signup (students with a matching email domain can create their own accounts)
- Purchase A3/A5 licenses at academic pricing via Volume Licensing, CSP, or web direct

---

## 3. The Verification Process — Where It's Weak

### 3a. Instant Approval Database

Microsoft maintains a database of known academic institutions globally. If your domain matches an entry, you get **instant approval** with zero human review. This database varies dramatically by country:

| Region | Database Quality | Domain Format | Ease of Verification |
|--------|-----------------|---------------|---------------------|
| **US/Canada** | Excellent — IPEDS/NCES institutions mapped | `.edu` (restricted) | Low fraud risk — `.edu` is EDUCAUSE-gated |
| **UK/EU** | Good — known universities well-cataloged | `.ac.uk`, `.edu.*` | Medium — some countries have loose ccTLD registries |
| **China** | Moderate — large institutions covered | `.edu.cn` (CERNET-gated) | Medium — legitimate `.edu.cn` requires MIIT registration, but fake documents exist |
| **Vietnam** | Weak — many small institutions missing | `.edu.vn` | **High** — small training centers can get `.edu.vn` domains easily |
| **Kyrgyzstan, Central Asia** | Very weak | `.edu.kg`, `.edu.kz` | **Very High** — domains are cheap (~$10/yr) with no accreditation check |
| **India** | Moderate | `.ac.in`, `.edu.in` | Medium-High — massive number of institutions, hard to verify |
| **Sub-Saharan Africa** | Weak | Various | High — limited institutional database coverage |

### 3b. Manual Review Weaknesses

When instant approval fails, the manual review process has these gaps:
- **Document-based**: Schools submit accreditation letters, government registrations, or "proof of being an educational institution" — these are easily forged
- **10-day SLA**: The review team is volume-constrained; pressure to approve drives false negatives
- **No physical inspection**: Everything is document-based and remote
- **No re-verification**: Once approved, the tenant is approved forever. There's no periodic re-check

### 3c. The "No Domain" Loophole

A tenant can get EDU trial access using **only a `.onmicrosoft.com` domain** — the admin can skip the domain verification step and still start using services. The `edu=noDomainSpecified` tag in D2K marks tenants that started EDU verification but never provided a custom domain. Our investigation found many fraud tenants in this state — they got trial access, never finished verification, but still had services provisioned.

---

## 4. Maintenance & Lifecycle — What Happens After Approval

### No Re-Verification

**There is no periodic re-verification of EDU status.** Once `edu=approved` is set in D2K CompanyTags, it persists indefinitely. A school that closes, loses accreditation, or was fraudulently approved retains its EDU privileges forever unless manually revoked.

### Protection Flags

Verified EDU tenants may accumulate protection flags in D2K that prevent automated cleanup:

| Flag | Source | Effect |
|------|--------|--------|
| `edu.microsoft.com/edu=approved` | EDU verification | Identifies as verified EDU — may block certain automation |
| `partner.microsoft.com/isdeletable=false` | Partner/Fasttrack onboarding | **Prevents automated deletion** — requires ICM to Partner team |
| `edu.microsoft.com/noDeletionBy=VL` | Volume Licensing EDU migration | **Explicitly blocks VL-initiated deletion** |
| `edu.microsoft.com/migratedbyedu=true` | Legacy EDU migration (circa 2013) | Marks tenant as migrated from old EDU platform |

These flags create a "triple lock" on fraud tenants like QUANG TRUNG — even after we ingest them into FAB, the deletion step fails because D2K flags override the FAB pipeline.

### Pooled Storage Enforcement (New, Aug 2024)

Starting August 2024 (at contract renewal), Microsoft imposed the 100 TB pooled storage limit on EDU tenants. However:
- **For A1-only tenants, there's no contract to renew** — they're free forever, so the enforcement date is ambiguous
- **SPO storage limits are soft limits** — exceeding the pool shows an admin center warning but does not block writes via API/rclone/Graph
- **Exchange enforces its limits** (Prohibit Send/Receive at 50/100 GB per mailbox), but SPO/ODB does not

### License Expiry

- **A1 licenses don't expire** — they're perpetual free licenses
- **A3/A5 trial licenses expire** after a configurable period (typically 30-90 days)
- **Viral/self-service licenses** that students acquire are tied to the tenant's EDU verification — they persist as long as the tenant is active

---

## 5. Storage Architecture — EDU vs. Commercial

### EDU Pooled Storage Formula

```
Tenant Pool = 100 TB (free base) + Σ(paid license contributions)
```

Office 365 A1 (free) licenses contribute **0 GB** to the pool. So a pure A1 tenant is permanently capped at exactly 100 TB (102,400 GB) — but SPO does not enforce this cap.

### Commercial Storage Formula

```
Tenant Pool = 1 TB (base) + 10 GB × licenses_purchased
```

### The Asymmetry

| Scenario | Licenses | Tenant Pool | Cost |
|----------|----------|------------|------|
| A1 EDU tenant (500K free users) | 500,000 | **100 TB** | **$0** |
| Commercial E3 Developer (25 free seats) | 25 | **1.27 TB** | $0 |
| Commercial E3 (100 paid seats) | 100 | **1.98 TB** | ~$4,300/mo |
| Commercial E3 (1,000 paid seats) | 1,000 | **10.77 TB** | ~$43,000/mo |
| Commercial E3 (10,000 paid seats) | 10,000 | **98.6 TB** | ~$430,000/mo |

A Commercial customer would need to spend **~$430K/month** on E3 licenses to approach the same storage that a single EDU A1 tenant gets for **free**.

### EDU Paid License Pool Contributions

| License | Pool Contribution |
|---------|------------------|
| Office 365 A1 (free) | **0 GB** |
| Student Use Benefit (A3/A5/Apps) | **0 GB** |
| Exchange Online EDU/Alumni | **0 GB** |
| Microsoft 365 F1 | 2 GB |
| O365 F3 / M365 F3 | 5 GB |
| **Microsoft 365 A1** | 10 GB |
| Exchange Plan 1, SPO Plan 1, ODB Plan 1, M365 Apps | 10 GB |
| Exchange Plan 2, SPO Plan 2, ODB Plan 2 | 25 GB |
| O365 E1 / M365 E1, Business Basic/Standard/Premium | 25 GB |
| **Office 365 A3 / Microsoft 365 A3** | **50 GB** |
| O365 E3 / M365 E3 | 50 GB |
| **Office 365 A5 / Microsoft 365 A5** | **100 GB** |
| O365 E5 / M365 E5 | 100 GB |

### ODB Per-User Limits

| SKU | ODB Per-User | Notes |
|-----|-------------|-------|
| Office 365 A1 | **100 GB** | Can't be raised |
| Microsoft 365 A1 | 1 TB | |
| Office 365 A3/A5, M365 A3/A5 | 1-5 TB | 5 TB if ≥5 users; eligible for 25 TB on request |

**Source:** [Office 365 Education service description — OneDrive limits](https://learn.microsoft.com/en-us/office365/servicedescriptions/office-365-platform-service-description/office-365-education)

---

## 6. EDU Fraud Taxonomy — All Known Vectors

### Category A: Storage & ODSP Fraud (FAB Scope)

| Vector | Description | Our Evidence |
|--------|-------------|-------------|
| **Storage hoarding** | Free A1 tenants used as bulk storage silos | TSCN (237 TB), QUANG TRUNG (443 TB), FVRTY (36 TB) |
| **Cloud storage reselling** | Operator builds commercial cloud-drive product on free EDU SPO backend | Vietnamese MSP cluster (IZONE.DEV, HATECHNO, AINKA) |
| **CDN / piracy streaming** | SPO used as free CDN for pirated anime/video content | Pattern P1 from China Network investigation |
| **Rclone/MeTA bulk egress** | Automated exfiltration of stored content to external endpoints | East West (55 GB/wk), Luyen Thi (active rclone) |
| **Dormant storage silos** | Tenant created, filled, then abandoned — storage sits consuming resources | TSCN (1 user, 237 TB, last active years ago) |

### Category B: License & Identity Fraud

| Vector | Description | Our Evidence |
|--------|-------------|-------------|
| **School impersonation** | Tenant claims to be a real university (e.g., "ZJU", "SJTU", "Keystone Academy") | 7 ACGDB ring tenants impersonating real schools with 20M+ licenses |
| **Foreign domain exploitation** | Cheap `.edu.kg` / `.edu.kz` domains to bypass verification | Ring I from China Network investigation |
| **Commercial masquerade** | Non-educational entity on EDU tenant (e.g., "SOGA OFFICE 365") | 14 cases from CN/VN investigation (Archetype A) |
| **Ghost shell creation** | Created for EDU, declined/abandoned, AAD shell persists | 65,572 ghost tenants (R3 rule), 2,902 declined ghosts (INV-011) with 2.3 PB provisioned quota |

### Category C: Financial / Credit Card Fraud (CFAR Scope)

| Vector | Description | How It Works |
|--------|-------------|-------------|
| **EDU-to-paid upgrade fraud** | Actor gets free A1, upgrades to A3/A5 with a stolen credit card, churns before chargebacks | Exploits the trust signal of `edu=approved` to bypass CC fraud checks |
| **Academic discount reselling** | Purchases A3/A5 at academic pricing, resells the licenses at commercial rates | Gray market — licenses are cheap ($2.50-$6 vs $23-$38 commercial) |
| **Azure credit stacking** | EDU-verified tenant claims Azure for Education credits ($100-$200/student), mines crypto or resells compute | Azure Sponsorship uses the same EDU verification; approved → free compute |
| **Gift card / promo abuse** | EDU email addresses qualify for student discounts across the Microsoft ecosystem (Store, Xbox, etc.) | SOGA OFFICE 365 pattern — commercial entity using EDU for discounts |
| **Student benefit fraud** | Bulk creation of student accounts to claim Microsoft Imagine/DreamSpark/Azure student packs | Each "student" account gets free tools, Azure credits, software downloads |

### Category D: Platform Abuse (Beyond Storage)

| Vector | Description | Impact |
|--------|-------------|--------|
| **Exchange spam/phishing** | EDU tenant's Exchange Online used for mass email campaigns | `@*.onmicrosoft.com` email bypasses some spam filters; free tenant = disposable sender |
| **Teams abuse** | Free Teams for Education used for spam calls, phishing, or malware distribution | Teams' trust model gives higher recipient acceptance to "educational" senders |
| **Power Automate/Logic Apps** | Free automation tools on A1 used for bot networks or credential stuffing | A1 includes Power Automate with limited connectors — enough for abuse |
| **Entra ID token farming** | EDU tenants used to generate valid Azure AD tokens for downstream API abuse | Bulk user creation → bulk tokens → API attacks on other services |
| **Graph API abuse** | 500K user tenant used to make massive Graph API calls (data scraping, enumeration) | A1 includes full Graph API access per user |

---

## 7. Country-Specific EDU Landscape

### China (`.edu.cn`)
- **Domain authority:** CERNET (China Education and Research Network) manages `.edu.cn` registrations
- **Requirements:** Institution must be registered with Ministry of Education; `.edu.cn` domain requires MIIT ICP filing
- **Fraud pattern:** Legitimate `.edu.cn` domains are relatively hard to fake — but **operators impersonate real universities without using their actual domain** (onmicrosoft-only tenants claiming to be "ZJU" or "SJTU"). Also: Chinese operators buy `.edu.kg` / `.edu.kz` domains from Central Asia
- **D2K region-specific:** China has its own Mooncake D2K shard (`d2kcnn2`); some tenants exist only there and aren't visible to global FAB tools
- **Scale:** We found 126 CN EDU tenants in our sample; ~23 confirmed fraud. Major universities (HNU 73.7 TB, CSUST 47.4 TB, CUG 33.5 TB) are legitimate but enormous free-tier consumers

### Vietnam (`.edu.vn`)
- **Domain authority:** VNNIC manages `.edu.vn` registrations
- **Requirements:** Officially requires proof of educational activity — but enforcement is loose. Small training centers, tutoring operations, and IT shops can obtain `.edu.vn` domains
- **Fraud pattern:** "Training company masquerading as school" is the dominant vector. QUANG TRUNG (443 TB) runs a Vietnamese IT training operation that got EDU verification. IZONE.DEV (16 TB) operates a cloud hosting business under EDU
- **Key differentiator:** Vietnam has a thriving MSP/reseller ecosystem where IT companies manage multiple school tenants — legitimate practice that blurs the line. HATECHNO and AINKA are examples of companies that have both real EDU and suspicious commercial activity on the same tenant

### United States (`.edu`)
- **Domain authority:** EDUCAUSE exclusively controls `.edu` domain issuance. Requires proof of accreditation by a US DoE-recognized agency
- **Fraud risk:** **Low for domain-based verification** — getting a `.edu` domain is genuinely hard. But the instant-approval database may still be exploitable with social engineering
- **Primary abuse vector:** Not fake schools, but **legitimate school employees** misusing their institution's tenant for personal storage (harder to detect, lower impact per incident)

### Central Asia (`.edu.kg`, `.edu.kz`, `.edu.uz`)
- **Fraud risk:** **Extremely high** — domain registrars sell `.edu.kg` domains for $5-15/year with no accreditation check. Chinese fraud operators buy these domains to pass Microsoft's "has a .edu.* domain" heuristic
- **Our evidence:** Ring I from China Network investigation — Chinese operators running EDU fraud through Kyrgyzstan domains

### India (`.ac.in`, `.edu.in`)
- **Scale:** Massive EDU market — hundreds of thousands of schools
- **Fraud risk:** Medium-high — enormous number of small institutions makes database coverage incomplete; manual review volume is overwhelming

---

## 8. EDU Fraud Archetypes (From Our Investigations)

From the CN/VN investigation (INV-008), we identified **7 distinct archetypes**:

| Archetype | Description | Count Found | Key Signal |
|-----------|-------------|-------------|------------|
| **A: Commercial Masquerade** | Non-educational entity on EDU tenant | 14 | Name contains commercial keywords, commercial TLD domains |
| **B: Identity Theft / Impersonation** | Claims to be a real institution | 8 | `edu=declined`, onmicrosoft-only, geo mismatch to real school |
| **C: MSP/Reseller Network** | Single tenant manages multiple school domains | 7 | 8+ verified domains, cross-domain admin emails |
| **D: Zero-Tag Ghost** | No edu CompanyTags or only "EmailVerified" | ~12 | No `edu=approved`, no contact info in D2K |
| **E: Dormant Storage Silo** | Extreme storage per user, minimal active users | ~18 | <50 users AND >200 GB total, GB/user >10 on free A1 |
| **F: Developer Abuse** | Developer/free SKU on "educational" tenant | 2 | E3 Dev Free on EDU-category tenant |
| **G: VL-Protected Mega-Tenant** | Large real-looking EDU with suspicious activity | 6 | `isdeletable=false`, `noDeletionBy=VL`, high storage |

---

## 9. Detection Rules We Built

| Rule | Signal | Precision | Action |
|------|--------|-----------|--------|
| R1 | Tenant name matches known commercial entity | 93% | Flag for review |
| R2 | D2K: `edu=declined` | 100% | Auto-flag |
| R3 | Only "EmailVerified" in CompanyTags (no `edu=approved`) | ~50% | Review |
| R4 | onmicrosoft-only domain (no custom domain) | 100% when combined | Flag |
| R5 | Gmail/QQ/163 admin on EDU tenant | 85% | Flag |
| R6 | Licenses >> active users (>50x ratio) | 85% | Flag |
| R7 | GB/user ratio >10 on free A1 | ~65% | Review |
| R8 | CompanyTags has only "EmailVerified" (no `edu=approved`) | ~50% | Review |
| R9 | Tenant name is short (<5 chars) gibberish | 95% | Flag |
| R10 | Admin email matches another confirmed fraud tenant | 100% | Auto-flag |
| R11 | Piracy app fingerprints (rclone, stagefright, lavf) | 100% | Auto-flag |
| R12 | Over-provisioned (>1M licenses, <50 users) | 90% | Flag |

---

## 10. Systemic Weaknesses Summary

| # | Weakness | Severity | Status |
|---|----------|----------|--------|
| 1 | **A1 is free forever with 100 TB pool** — zero cost barrier to abuse | Critical | By design |
| 2 | **No re-verification** — approved once = approved forever | Critical | No fix planned |
| 3 | **SPO storage limits are soft** — no write blocking on overage | Critical | Platform gap |
| 4 | **Trial starts before verification** — services available immediately | High | By design |
| 5 | **Instant approval database** varies wildly by country | High | Partial coverage |
| 6 | **500K free licenses per tenant** — massively over-provisioned for most schools | High | By design |
| 7 | **Protection flags block cleanup** — `isdeletable=false` + `noDeletionBy=VL` override FAB | High | Manual escalation only |
| 8 | **No fraud signal sharing** between EDU verification and FAB | High | Siloed teams |
| 9 | **Document-based manual review** — easily forged | Medium | Review team constraints |
| 10 | **Foreign .edu.* domains** used to bypass geo-appropriate checks | Medium | No country-specific logic |
| 11 | **Ghost tenants persist** — declined EDU applications leave AAD shells with SPO provisioned | Medium | 65K+ ghosts identified |
| 12 | **Mooncake gap** — China-sovereign tenants can't be remediated by FAB API | Medium | Platform limitation |

---

## 11. What's the Actual Cost to Microsoft?

For our investigation scope alone:

| Metric | Value |
|--------|-------|
| Confirmed fraud tenants (EDU) | 49 (43 original + 6 Archetype G) |
| Total fraud storage on disk | ~255 TB |
| Highest single tenant | QUANG TRUNG: 443 TB |
| Revenue from all 49 tenants | **$0** (all free A1 or unpaid) |
| Estimated storage cost at $0.02/GB/mo | **~$5,100/month** or **~$61K/year** |
| Ghost tenant provisioned quota (65K tenants) | **~2.3 PB** exposure if filled |
| Legitimate EDU high-storage (not fraud) | ~185 TB across HNU, CSUST, CUG, EDUPIA |

The storage cost is modest in absolute terms ($61K/yr), but the **exposure** — 2.3 PB of provisioned ghost quota plus uncapped soft-limit exploitation — is the real systemic risk. One bad actor filling NDLG's 60 PB(!) allocation would dwarf everything.

---

## 12. Key Internal Data Sources

| Source | Cluster / Table | What It Contains |
|--------|----------------|-----------------|
| **D2K (Directory-to-Kusto)** | Federated: `idsharedwus`, `idsharedapac`, `idsharedweu`, `idsharedjpn`, `idsharedaus`, `d2kcnn2`, `d2karaz` / `Company` | `CompanyTags` (edu=approved/declined/pending), admin contacts, creation dates, org metadata |
| **DIM_TENANTS** | `odspfabkusto.eastus.kusto.windows.net / fabpartnerdb` | Denormalized join of D2K + OMS + MCAPS. `IsEduSegment`, `HasEducation`, `CustomerSegmentGroup` |
| **OMS (Tenant Info)** | FAB MCP `get_tenant_info` | `storagE_LIMIT_GB`, `tenanT_TOTAL_DISK_USED_GB`, `tenanT_CATEGORY`, `tenanT_LEVEL`, `haS_EDUCATION_OFFER` |
| **SPO RequestUsage** | `spogdskustocluster.eastus2.kusto.windows.net / SpoProd` | Per-request telemetry: app fingerprints, file types, read/write bytes, HTTP status |
| **FAB Pipeline** | `get_tenant_remediation_info`, `ingest_tenants` | Remediation status, usecase type, pipeline progression |

---

## References

- [Verify academic eligibility](https://learn.microsoft.com/en-us/microsoft-365/commerce/subscriptions/verify-academic-eligibility)
- [Office 365 Education service description](https://learn.microsoft.com/en-us/office365/servicedescriptions/office-365-platform-service-description/office-365-education)
- [SharePoint Online limits](https://learn.microsoft.com/en-us/office365/servicedescriptions/sharepoint-online-service-description/sharepoint-online-limits)
- [Manage site storage limits](https://learn.microsoft.com/en-us/sharepoint/manage-site-collection-storage-limits)
- Internal: `docs/investigations/EDU_CN_VN_Investigation_Report.md`
- Internal: `docs/investigations/Archetype_G_At_Scale_Report.md`
- Internal: `docs/investigations/China_Network_Abuse_Investigation.md`
- Internal: `docs/Fraud_Abuse_Vectors_Consolidated.md`
- Internal: `docs/Re_Entry_Prevention_Strategy.md`
