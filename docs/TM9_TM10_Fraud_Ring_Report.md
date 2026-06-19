# Fraud Ring Investigation Report: tm9.site / tm10.site Infrastructure

**Date:** 2025-05-31  
**Analyst:** FAB Tenant Service (Automated + Manual Investigation)  
**Status:** Ring Identified — All Known Members Blocked  
**Severity:** HIGH — Coordinated Storage Abuse Operation  

---

## Executive Summary

A coordinated fraud ring of **4 tenants** has been identified sharing `tm9.site` and `tm10.site` custom domain infrastructure. All tenants exhibit identical behavioral patterns: E5 Developer trial subscriptions, never paid, ~120 TB storage consumption each (~483 TB total), 25 ODB sites each, and gibberish onmicrosoft domain names. All 4 were blocked on **2025-05-30** with fraud IDs 97361–97367.

The ring uses **disposable Outlook accounts with gibberish prefixes** for admin emails, shares the **GeminiSignUpUI** signup flow, and follows a highly automated provisioning pattern. Two additional external domains (`technep.com`, `who-chhd.org`) were discovered on one member, suggesting possible brand impersonation or broader infrastructure.

---

## Ring Members

| # | Tenant ID | Display Name | OnMicrosoft Domain | Custom Domain | Storage (GB) | ODB Sites | Fraud ID | Status |
|---|-----------|-------------|-------------------|---------------|-------------|-----------|----------|--------|
| 1 | `5dcc17a6-7e2a-401a-84c1-3fd0c9dafedd` | 365 | `8w5e.onmicrosoft.com` | `y39.tm9.site` | 120,780 | 25 | 97361 | **BLOCKED** |
| 2 | `6fec64a5-8f1e-48b3-8929-b2dff1fbc1c9` | 365 | `k2x7.onmicrosoft.com` | `zvv7.tm10.site` | 120,884 | 25 | 97363 | **BLOCKED** |
| 3 | `fbe66fb6-18bc-49a1-b5f1-2c48436fbbae` | MICROSOFT 365 | `k2i1.onmicrosoft.com` | `34.tm10.site` | 120,804 | 25 | 97365 | **BLOCKED** |
| 4 | `dede6e4e-eae7-4e74-abca-dd9e2e23a7ec` | UK3 | `be4v.onmicrosoft.com` | `z18.tm10.site` | 120,804 | 25 | 97367 | **BLOCKED** |

**Total compromised storage: ~483,272 GB (~472 TB)**

---

## D2K Intelligence

### Admin Email Accounts

| Tenant | Admin Email | Email Prefix Pattern |
|--------|------------|---------------------|
| T1 (`5dcc17a6`) | `dw2fef@outlook.com` | 6-char alphanumeric gibberish |
| T2 (`6fec64a5`) | `asdw5d3@outlook.com` | 7-char, starts with `asd` |
| T3 (`fbe66fb6`) | `asd54s2@outlook.com` | 7-char, starts with `asd` |
| T4 (`dede6e4e`) | `biud2e@outlook.com` | 6-char alphanumeric gibberish |

**Pattern:** All admin emails are disposable Outlook accounts with random alphanumeric prefixes. T2 and T3 share the `asd` prefix pattern suggesting the same keyboard mashing habit — likely the **same individual**.

### Domain Cross-References

| Tenant | All Known Domains | Notes |
|--------|------------------|-------|
| T1 | `8w5e.onmicrosoft.com`, `y7u8.onmicrosoft.com`, `y39.tm9.site` | Has additional onmicrosoft alias `y7u8` |
| T2 | `k2x7.onmicrosoft.com`, `zvv7.onmicrosoft.com`, `technep.com`, `who-chhd.org` | **2 external domains** — potential wider infrastructure |
| T3 | `k2i1.onmicrosoft.com`, `234676.onmicrosoft.com`, `34.tm10.site` | Has pure-numeric alias `234676` |
| T4 | `be4v.onmicrosoft.com`, `z18.tm10.site` | Minimal domain footprint |

### Abuse Tags

| Tenant | Signup Lock Status | Key Tags |
|--------|-------------------|----------|
| T1 | `signup.microsoft.com/locked=abuse` | Locked at signup layer |
| T2 | Not locked | Additional domains suggest more activity |
| T3 | `signup.microsoft.com/locked=abuse` | Locked at signup layer |
| T4 | Not locked | — |

### Common Attributes (All 4 Tenants)

- **Signup portal:** `GeminiSignUpUI`
- **Developer tag:** `azure.microsoft.com/developer365=active`
- **O365 version:** 15
- **Country:** Various (ring uses multiple registrations)
- **Trial status:** Never converted to paid
- **Storage pattern:** Exactly ~120,800 GB each — automated fill to near-identical levels

---

## Gibberish Analysis

### Tenant Names
| Name | Score | Verdict | Notes |
|------|-------|---------|-------|
| 365 | 0.217 | NORMAL | Too short for detection — just a number |
| MICROSOFT 365 | 0.600 | **IMPERSONATION** | Brand impersonation of Microsoft |
| UK3 | 0.122 | NORMAL | Too short, below threshold |

### OnMicrosoft Subdomains
| Domain | Score | Verdict |
|--------|-------|---------|
| 8w5e | — | 4-char gibberish (too short for reliable scoring) |
| k2x7 | — | 4-char gibberish |
| k2i1 | — | 4-char gibberish |
| be4v | — | 4-char gibberish |
| y7u8 | — | 4-char gibberish (alias on T1) |
| zvv7 | — | 4-char gibberish (alias on T2) |
| 234676 | — | Pure numeric (alias on T3) |

### Admin Email Prefixes
| Prefix | Score | Verdict | Key Signals |
|--------|-------|---------|-------------|
| dw2fef | 0.152 | NORMAL | Low vowel ratio, unnatural bigrams |
| asdw5d3 | 0.187 | NORMAL | Low vowel ratio, digit mixing |
| asd54s2 | 0.157 | NORMAL | Unnatural bigrams, digit mixing |
| biud2e | 0.120 | NORMAL | Unnatural bigrams |

> **Note:** Short gibberish strings score below threshold because they don't trigger enough signals. This ring evades name-based detection through **extremely short names** ("365", "UK3") and **4-character domains**. Detection must rely on **behavioral signals** (storage abuse, trial-never-paid, mass identical provisioning).

---

## Ring Signature

This ring can be identified by the following composite fingerprint:

1. **Domain infrastructure:** `*.tm9.site` and `*.tm10.site` custom domains
2. **OnMicrosoft pattern:** 4-character alphanumeric gibberish subdomains
3. **Storage pattern:** ~120,800 GB per tenant (automated to near-identical levels)
4. **ODB count:** Exactly 25 sites per tenant
5. **SKU:** E5 Developer, trial, never paid
6. **Admin emails:** Random 6-7 char Outlook addresses
7. **Signup flow:** GeminiSignUpUI
8. **Tenant names:** Ultra-short or Microsoft brand impersonation ("365", "MICROSOFT 365", "UK3")

---

## Leads for Additional Ring Members

### Priority 1: Domain Infrastructure Search

Search for any tenants using `tmN.site` pattern domains (likely `tm1.site` through `tm20+.site`):

```kql
// Run in Kusto Web Explorer on fabdardb
TENANT_INFO
| where TENANT_DOMAINS matches regex @"tm\d+\.site"
| project TENANT_ID, TENANT_FRIENDLY_NAME, TENANT_DOMAINS, 
          TENANT_CREATED_DATE, TOTAL_SIZE_GB, ODB_SITE_COUNT,
          SKU_INFO, IS_TRIAL_TENANT, HAS_EVER_HAD_PAID_LICENSE
| order by TENANT_CREATED_DATE desc
```

### Priority 2: External Domain Cross-References

T2 (`6fec64a5`) had two additional external domains that may be registered on other tenants:

```kql
// Search for technep.com on other tenants
TENANT_INFO
| where TENANT_DOMAINS has "technep.com"
| project TENANT_ID, TENANT_FRIENDLY_NAME, TENANT_DOMAINS, TOTAL_SIZE_GB

// Search for who-chhd.org on other tenants
TENANT_INFO
| where TENANT_DOMAINS has "who-chhd.org"  
| project TENANT_ID, TENANT_FRIENDLY_NAME, TENANT_DOMAINS, TOTAL_SIZE_GB
```

### Priority 3: Behavioral Pattern Matching

Search for tenants matching the ring's behavioral fingerprint (even without shared domains):

```kql
// Tenants with 4-char onmicrosoft domains, ~120TB storage, 25 ODB sites, E5 Developer trial
TENANT_INFO
| where TOTAL_SIZE_GB between (115000 .. 125000)
    and ODB_SITE_COUNT == 25
    and IS_TRIAL_TENANT == true
    and HAS_EVER_HAD_PAID_LICENSE == false
    and SKU_INFO has "DEVELOPERPACK_E5"
| project TENANT_ID, TENANT_FRIENDLY_NAME, TENANT_DOMAINS, 
          TENANT_CREATED_DATE, TOTAL_SIZE_GB, ODB_SITE_COUNT
| order by TENANT_CREATED_DATE desc
```

### Priority 4: Admin Email Cross-Reference

If D2K supports email-based queries, search for other tenants registered by the same admins:

- `dw2fef@outlook.com`
- `asdw5d3@outlook.com`  
- `asd54s2@outlook.com`
- `biud2e@outlook.com`

### Priority 5: Phone Number Cross-Reference

Ring member phone numbers (may be reused across tenants):
- T1: `7496695784`
- T2: `16232658343`
- T3: `16286108919`
- T4: `7466184121`

---

## Detector Enhancement Recommendations

This ring exposes two gaps in the current gibberish detection:

### Gap 1: Ultra-Short Name Bypass
- Names like "365" and "UK3" are too short for linguistic analysis
- **Recommendation:** Add a rule flagging tenants with display names ≤ 3 characters when combined with other risk factors (trial, high storage, gibberish domain)

### Gap 2: Short Domain Bypass
- 4-character onmicrosoft subdomains (8w5e, k2x7, k2i1, be4v) are too short for reliable gibberish scoring
- **Recommendation:** Flag onmicrosoft domains ≤ 4 characters as suspicious (legitimate orgs rarely use such short names)

### Gap 3: Behavioral Composite Signal
- This ring is best caught by behavioral patterns, not name/domain analysis alone
- **Recommendation:** Add a composite scoring rule that combines:
  - Storage/ODB ratio anomaly (120TB / 25 sites = ~4.8TB per site)
  - Trial never-paid status
  - Short/gibberish names AND domains
  - Recent creation date

---

## Action Items

| # | Action | Status | Owner |
|---|--------|--------|-------|
| 1 | Block all 4 known ring members | ✅ DONE (Fraud IDs 97361-97367) | FAB Automated |
| 2 | Run Priority 1 Kusto query for `tmN.site` pattern | 🔲 PENDING | Analyst |
| 3 | Run Priority 2 queries for `technep.com` / `who-chhd.org` | 🔲 PENDING | Analyst |
| 4 | Run Priority 3 behavioral pattern query | 🔲 PENDING | Analyst |
| 5 | Cross-reference admin emails in D2K | 🔲 PENDING | Analyst |
| 6 | Report `tm9.site` and `tm10.site` domains to registrar | 🔲 PENDING | Abuse Team |
| 7 | Flag `technep.com` and `who-chhd.org` for investigation | 🔲 PENDING | Abuse Team |
| 8 | Implement ultra-short name detection enhancement | 🔲 PENDING | Dev Team |
| 9 | Add behavioral composite scoring rule | 🔲 PENDING | Dev Team |

---

## Timeline

| Date | Event |
|------|-------|
| ~2025-05 | Ring tenants created (exact dates from Kusto) |
| 2025-05-01 to 2025-05-30 | Storage accumulation to ~120TB per tenant |
| 2025-05-30 | All 4 tenants blocked by FAB detection |
| 2025-05-31 | This investigation report generated |

---

*Report generated by FAB Tenant Service Gibberish Detection System*
