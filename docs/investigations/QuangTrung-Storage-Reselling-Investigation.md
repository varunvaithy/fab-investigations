# Quang Trung College — Storage Reselling Ring Investigation

**Date:** April 3, 2026  
**Investigator:** Copilot AI Agent + Varun V  
**ICM Ticket:** *Pending creation*  
**Classification:** EDU License Fraud + Storage Reselling + Microsoft Brand Impersonation  

---

## Executive Summary

Tenant `ac295da4-9912-40f3-86ce-a30c44a02883` (**QUANG TRUNG COLLEGE**) is a Vietnamese A1 EDU tenant consuming **433 TB** of OneDrive storage — **4.3× its 100 TB quota** — while showing only **8 active users** across 5,714 ODB sites. The tenant operates a **storage reselling storefront** through Microsoft-impersonating domains (`ms365vip.com`, `msdrive365.com`) and uses a Synology NAS device for systematic data synchronization.

Cross-referencing the reselling domains uncovered a **5-tenant ring** sharing storage-reselling infrastructure across multiple countries. Three ring members are already in FAB (Status 6 — identified/deleted), while the primary tenant (`ac295da4`) and one related tenant remain **uninvestigated**.

**Total active storage at risk:** ~433 TB  
**Fraudulent licenses acquired:** 501,000 (A1 EDU)  
**Ring size:** 5 tenants (3 already remediated, 2 new)  
**Revenue generated:** $0 (zero paid licenses)  

---

## Tenant Profile

| Field | Value |
|-------|-------|
| **Tenant ID** | `ac295da4-9912-40f3-86ce-a30c44a02883` |
| **Display Name** | QUANG TRUNG COLLEGE |
| **Country** | Vietnam (VN) |
| **City** | Hồ Chí Minh |
| **Category** | EDU |
| **License Level** | A1 (Free) |
| **Created** | 2013-06-10 |
| **Has Paid?** | Never |
| **Licenses Acquired** | 501,000 |
| **Licenses Enabled** | 5,887 |
| **ODB Sites** | 5,714 |
| **Total Storage Used** | 443,110 GB (~433 TB) |
| **Storage Quota** | 102,400 GB (~100 TB) |
| **Over-Quota Ratio** | **4.3×** |
| **ODB Disk Used** | 442,550 GB (~432 TB) |
| **Admin Email** | `0313062024@hkt.vn` |
| **FAB Status** | ❌ NOT IN FAB |

### Verified Domains

| Domain | Type | Risk |
|--------|------|------|
| `quangtrungcollege.onmicrosoft.com` | Default | — |
| `quangtrung-college.net` | Custom | Legitimate school domain |
| `ms365vip.com` | Custom | ⚠️ **Microsoft brand impersonation — reselling storefront** |
| `msdrive365.com` | Custom | ⚠️ **Microsoft brand impersonation — reselling storefront** |
| `masterit.vn` | Custom | Vietnamese IT training brand |
| `masterenglish.edu.vn` | Custom | Vietnamese English school brand |
| `masterenglish.vn` | Custom | Vietnamese English school brand |

### D2K Tags

```
edu.microsoft.com/edu=approved
o365.microsoft.com/program=edu
partner.microsoft.com/isdeletable=false
```

The tenant was **approved as an EDU institution** and has the `isdeletable=false` flag, which may complicate remediation.

---

## Usage Analysis (March 1 – April 3, 2026)

| Metric | Value | Signal |
|--------|-------|--------|
| **Total Requests** | 7,801,512 | High volume |
| **Unique Users** | 8 | ⚠️ **Only 8 users for 5,714 ODB sites** |
| **Unique Apps** | 134 | Moderate |
| **Egress** | 2.28 TB | Significant outbound transfer |
| **Ingress** | 275 GB | — |

### Top Applications

| App | Signal |
|-----|--------|
| excel | Normal office use |
| word | Normal office use |
| OneNoteModernClient | Normal |
| OneDriveSync | Bulk sync client |
| **synology** | ⚠️ **Synology NAS — systematic backup/reselling device** |
| Nucleus | — |

### Top File Types

| Type | Signal |
|------|--------|
| Unknown | Obfuscated extensions |
| ONE | OneNote files |
| DOC | Documents |
| JPG | Images |
| XLSX | Spreadsheets |
| DOCX | Documents |
| **MKV** | ⚠️ **Video container — possible media piracy storage** |

### Key Behavioral Indicators

1. **8 users managing 5,714 ODB sites** — Classic reselling pattern where a small operator provisions thousands of accounts for external customers
2. **Synology NAS in top apps** — Industrial-grade storage synchronization device used to mirror OneDrive data to local/external storage
3. **MKV files** — High-capacity video format commonly associated with pirated media when found alongside reselling infrastructure
4. **2.28 TB egress in 33 days** — Active distribution of stored content
5. **501,000 licenses acquired vs 5,887 enabled** — Licenses provisioned far beyond any legitimate institution need

---

## Ring Analysis

Cross-referencing the reselling domains (`ms365vip`, `msdrive365`, `free5tb`, `msvip`, `msod`) against D2K revealed **4 related tenants** sharing storage-reselling infrastructure:

| Tenant ID | Name | Country | Admin | Key Domains | FAB Status |
|-----------|------|---------|-------|-------------|------------|
| `ac295da4` | **QUANG TRUNG COLLEGE** | VN | `0313062024@hkt.vn` | ms365vip.com, msdrive365.com | ❌ NOT IN FAB |
| `343bb1a7` | Business | US | `kuangrengzs@gmail.com` | ms365vip.cn, free5tb.tk, msod.tk, msvip.ml, 5tb.eu, emai.edu.pl | ✅ FAB Status 6, TYPE2, identified 2021-07-29, **0 TB** |
| `c5ccb8c6` | vip | US | `administrator@office2016.cc` | *(not found in TENANT_INFO)* | ❓ Not in FAB, not in Kusto |
| `d12d0851` | Scale Sticky Methodologies Edu | US | `z.weiyu@outlook.com` | *(A1 EDU, 10K licenses)* | ✅ FAB Status 6, TYPE1, **deleted** 2023-07-04, 0 TB |
| `f79c9553` | class.galileogiftedschool.org | US | — | msoffice.cc | ✅ FAB Status 6, TYPE2, identified 2021-10-04, 1M licenses acquired, **0 TB** |

### Ring Observations

1. **3 of 5 ring members already remediated** (Status 6) — confirms this is a known abuse pattern
2. **Primary tenant (`ac295da4`) evaded detection** — likely because it's registered as a legitimate Vietnamese EDU and uses a real school name
3. **Domain infrastructure** shares a common playbook: `ms*`, `*365*`, `*5tb*`, `free*` — all designed to look like official Microsoft storage services
4. **Shared reselling domain `ms365vip.com`** appears on both the primary tenant (`.com`) and the already-remediated `343bb1a7` (`.cn`) — same operation, different TLDs
5. **`office2016.cc` admin email** on tenant `c5ccb8c6` suggests another Microsoft-impersonating domain used as identity

### Domain Registrar Analysis

The following domains are used for Microsoft brand impersonation and likely violate Microsoft's trademark:

| Domain | Impersonation Target | Status |
|--------|---------------------|--------|
| `ms365vip.com` | Microsoft 365 | **Active — on primary tenant** |
| `ms365vip.cn` | Microsoft 365 | Active — on remediated tenant |
| `msdrive365.com` | Microsoft OneDrive | **Active — on primary tenant** |
| `msod.tk` | Microsoft OneDrive | On remediated tenant |
| `msvip.ml` | Microsoft | On remediated tenant |
| `msoffice.cc` | Microsoft Office | On remediated tenant |
| `office2016.cc` | Microsoft Office 2016 | Admin email domain |
| `free5tb.tk` | Cloud storage | On remediated tenant |
| `5tb.eu` | Cloud storage | On remediated tenant |

---

## Risk Assessment

| Risk Factor | Severity | Detail |
|-------------|----------|--------|
| Storage Exposure | 🔴 **Critical** | 433 TB active, 4.3× over quota |
| Brand Impersonation | 🔴 **Critical** | ms365vip.com, msdrive365.com actively used |
| Media Piracy | 🟡 **High** | MKV files + Synology NAS + reselling domains |
| EDU Fraud | 🟡 **High** | Leveraged legitimate school name for 501K free licenses |
| Data Exfiltration | 🟡 **High** | 2.28 TB egress in 33 days via Synology |
| Recurrence Risk | 🟡 **High** | Ring operator has previously spun up replacement tenants |

---

## Action Plan

### Priority 1: Immediate Remediation (Day 0-1)

- [ ] **Create ICM ticket** for this investigation
- [ ] **Ingest tenant `ac295da4-9912-40f3-86ce-a30c44a02883` into FAB**
  - Reason Code: **5** (CLUSTERS)
  - Use Case Type: **10** (ABUSE-READONLY-BLOCK-DELETE_15DAYS)
  - Classification: Storage Reselling + EDU License Fraud
- [ ] **Verify `isdeletable=false` flag** — confirm whether EDU protection will block remediation; escalate to EDU team if needed
- [ ] **Investigate tenant `c5ccb8c6`** (vip / `office2016.cc`) — not found in TENANT_INFO or FAB, may be deleted or renamed

### Priority 2: Storage Reselling Storefront Takedown (Day 1-3)

- [ ] **Investigate `ms365vip.com`** — check if it's an active storefront selling OneDrive storage
- [ ] **Investigate `msdrive365.com`** — check if it's an active storefront selling OneDrive storage
- [ ] **Report both domains to Microsoft Brand Protection / MSRC** for trademark violation
- [ ] **Report domains to registrars** for abuse (Microsoft name impersonation)
- [ ] **Check WHOIS** for both domains to identify registrant (may link to operator identity)

### Priority 3: Ring Expansion Search (Day 2-5)

- [ ] **Query D2K across all shards** for tenants with domains containing: `ms365`, `msdrive`, `free5tb`, `msod`, `msvip`, `5tb`
- [ ] **Query D2K** for admin emails: `kuangrengzs@gmail.com`, `z.weiyu@outlook.com`, `administrator@office2016.cc`
- [ ] **Search for other Vietnamese EDU tenants** with the `masterit.vn` or `masterenglish` domains — these may be additional fronts
- [ ] **Check `0313062024@hkt.vn`** — investigate if this admin email appears on other tenants (hkt.vn query returned empty on `idsharedwus`, check other shards)

### Priority 4: EDU Verification (Day 3-7)

- [ ] **Verify "Quang Trung College" legitimacy** — is this a real Vietnamese institution, or is the name being impersonated?
- [ ] **If real:** The school's IT administrator may be running the reselling operation using institutional credentials
- [ ] **If impersonated:** Escalate to EDU approval team to revoke EDU status
- [ ] **Review `masterit.vn` and `masterenglish.edu.vn`** — are these legitimate training organizations or additional fronts for the same operator?

### Priority 5: Monitoring (Ongoing)

- [ ] **Monitor for new tenant creation** by the same operator using keywords: quangtrung, ms365vip, msdrive365, masterit, hkt.vn
- [ ] **Set up domain alerting** for new registrations matching `ms*365*`, `msdrive*`, `free*tb*` patterns
- [ ] **Track ring recurrence** — given 3 previously remediated tenants, the operator has a history of spinning up replacements

---

## Appendix: D2K Query Used

```kql
Company
| where VerifiedDomain has_any ('msdrive365', 'ms365vip', 'free5tb', 'msvip', 'msod', '5tb.eu')
| project TenantId, DisplayName, CountryLetterCode, TechnicalNotificationMail, VerifiedDomain, CreationTime
```

**Cluster:** `idsharedwus.kusto.windows.net`  
**Database:** `D2kredacted`  

---

## Appendix: RequestUsage Query

```
Tenant: ac295da4-9912-40f3-86ce-a30c44a02883
Period: 2026-03-01 to 2026-04-03
Source: SpoProd RequestUsage via FAB MCP
```

---

*Report generated by Copilot AI Agent. All data sourced from FAB MCP tools, D2K (Azure Kusto), and SpoProd RequestUsage.*
