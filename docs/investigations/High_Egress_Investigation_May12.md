# High-Egress Tenant Investigation Report

**Date:** May 12, 2026  
**Investigator:** Varun V  
**Scope:** Top egress tenants from K2/K2aV2 queries — fraud ring expansion, cluster analysis, paid tenant review

---

## Executive Summary

Investigation of the top egress tenants in FAB revealed a **30-tenant fraud ring** (FAMILIA CONFEITAR), confirmed a **DYSLEXIASINISTER sibling**, identified **2 unflagged fraudulent tenants** requiring immediate action, and confirmed **2 paid high-egress tenants as false positives**. Key systemic issues: BLOCK_FAIL retry storms (20-30 failures per tenant) and ReadOnly not preventing egress.

---

## 1. FAMILIA CONFEITAR Fraud Ring (30 Tenants)

### Ring Operator Profile

| Attribute | Value |
|---|---|
| **Admin Email** | `mario@ritzmann.com.br` |
| **Phone** | 4196152228 |
| **Company Name** | FAMILIA CONFEITAR COMERCIO DE ALIMENTOS LTDA |
| **Location** | Itapema, Santa Catarina (SC), Brazil |
| **Address** | R 424, 353 SALA 02, 88220-000 |
| **Naming Pattern** | familiaconfeitar{N}.onmicrosoft.com (N = 2–30) |
| **Creation Window** | Apr 11, 2025 – May 7, 2025 (~4 weeks) |

### Ring Characteristics (Per Tenant)

- **Users:** 2 enabled, 0 disabled
- **Licenses:** 1 acquired, 1 enabled
- **Ingress:** Zero
- **Apps:** "Other" (no named app registered)
- **Custom Domain:** None (onmicrosoft.com only)
- **Groups:** 2 mail-enabled, 0 security
- **Devices:** 0
- **Type:** Default / Commercial

### Confirmed Ring Members (26 in Egress Data)

| # | Tenant ID | Domain | Egress (TB, 7d) | FAB Status |
|---|---|---|---|---|
| 1 | `4d94be45-3ad7-49d6-884b-5f761ec2e6e3` | familiaconfeitar15 | 74.23 | Blocked May 4 |
| 2 | `27bd7116-3279-4f9c-bf95-dad5da03fc1f` | familiaconfeitar6 | 66.78 | Blocked May 4 |
| 3 | `b82861b1-5972-4512-8a5e-a9b497c43b3f` | familiaconfeitar14 | 66.07 | Blocked May 4 |
| 4 | `6be3d682-9b5e-4a2c-a1dc-3db3d1006317` | familiaconfeitar2 | 65.99 | Blocked May 4 |
| 5 | `594fadd9-4c3b-4cd3-ae4c-c8bf7d6c3985` | familiaconfeitar* | 65.87 | Blocked May 4 |
| 6 | `85166de6-bd5e-4845-bd55-0111b34974a9` | familiaconfeitar* | 65.76 | Blocked May 4 |
| 7 | `0a14954b-f2d0-4696-be28-1ffcb1f1af8e` | familiaconfeitar17 | 63.61 | Blocked (est.) |
| 8 | `a55f3442-ebfe-4def-9e8c-e44338b07983` | familiaconfeitar* | 62.83 | Blocked May 4 |
| 9 | `f4e6a745-aed5-4eaf-991a-726a4b53161a` | familiaconfeitar12 | 62.69 | Blocked (est.) |
| 10 | `5b562ca7-ca1c-4bbe-88d5-5618e12d7606` | familiaconfeitar7 | 62.40 | Blocked (est.) |
| 11 | `1b05da04-8617-4796-87bb-237a07cb1ac6` | familiaconfeitar13 | 62.22 | Blocked (est.) |
| 12 | `1ca6d9bb-00cc-44b4-b149-3139b2f1f462` | familiaconfeitar3 | 62.11 | Blocked (est.) |
| 13 | `797739ea-6141-4aaa-96a4-76a46d4f56f8` | familiaconfeitar8 | 62.08 | Blocked (est.) |
| 14 | `5408af44-2fe0-4b44-975e-989e8273b4bd` | familiaconfeitar* | 61.88 | Blocked (est.) |
| 15 | `a18f11eb-8368-4278-ba02-90fdf2c22bf8` | familiaconfeitar* | 61.03 | Blocked (est.) |
| 16 | `96a8ac8d-8e88-481b-b12a-3ae1b4cbc5cf` | familiaconfeitar* | 60.15 | Blocked (est.) |
| 17 | `94bfc7fd-addf-4ea5-9e3e-1dcfbc685420` | familiaconfeitar* | 59.38 | Blocked (est.) |
| 18 | `554efcf0-25e5-4586-832f-5a1cebe25719` | familiaconfeitar* | 59.33 | Blocked May 4 |
| 19 | `d1ee8630-3487-4c9e-8384-be884e1b7996` | familiaconfeitar11 | 59.26 | Blocked (est.) |
| 20 | `46d7e95f-6dd0-438c-ac82-05000771c8cc` | familiaconfeitar* | 58.96 | Blocked (est.) |
| 21 | `67abf679-1ffa-4b6d-a383-c6040602bb56` | familiaconfeitar* | 58.66 | Blocked May 4 |
| 22 | `8bf775aa-a43d-40d0-bdc1-ede8eef6fcbf` | familiaconfeitar* | 58.55 | Blocked (est.) |
| 23 | `4db339ce-3601-4912-b594-fcf111574e9d` | familiaconfeitar* | 58.16 | Blocked (est.) |
| 24 | `571c12a6-6d43-4317-ac93-0323c3528da5` | familiaconfeitar* | 55.10 | Blocked May 4 |
| 25 | `30baffe8-6920-472a-96d9-225f91de8928` | familiaconfeitar28 | 44.54 | Blocked May 4 |
| 26 | `aa7e8967-5b0b-4926-b2fd-b13eeccd1317` | familiaconfeitar29 | 42.03 | Blocked May 4 |

### Additional Siblings (from technical contact search, lower egress)

| Tenant ID | Domain | Egress (TB, 7d) | FAB Status |
|---|---|---|---|
| `dad399d7-9499-4046-babc-473fa9a7e024` | familiaconfeitar21 | 38.97 | Blocked May 4 |
| `9f4a3a45-b52c-429f-9d27-824eb53ca1ac` | familiaconfeitar20 | 26.69 | Blocked May 4 |
| `2007ec41-9fc6-4c48-b0e6-c09a64914f26` | familiaconfeitar30 | 24.97 | Blocked May 4 |

### Total Ring Impact

- **Ring Size:** 30 tenants (familiaconfeitar2 through familiaconfeitar30, plus unnumbered variants)
- **Total 7-Day Egress:** ~1,680 TB (~240 TB/day)
- **Total Stored Data:** Estimated 50–195 TB per tenant
- **Ingress:** Zero across all tenants
- **All in FAB:** Yes — identified Apr 8, ReadOnly Apr 8, blocked May 4–5

### BLOCK_FAIL Pattern (Systemic Issue)

Every single FAMILIA CONFEITAR tenant experienced **20–30 consecutive BLOCK_FAIL events** before block succeeded:

- ReadOnly applied: **Apr 8**
- First BLOCK attempt: **Apr 29** (21-day gap per policy)
- BLOCK_FAIL storm: Apr 29 – May 4 (~5 days, retrying every 4 hours)
- BLOCK_SUCCESS: **May 4–5**

**Impact:** Each tenant had an extra **5 days of egress** during the BLOCK_FAIL window, on top of the **21-day ReadOnly window** where egress continued unabated. Total unmitigated egress window: **~26 days** per tenant.

Example timeline (familiaconfeitar21 / `dad399d7`):
- 32 BLOCK_FAIL events from Apr 29 11:31 → May 4 15:32
- Finally BLOCK_SUCCESS on May 4 20:23

---

## 2. DYSLEXIASINISTER Sibling Confirmed

| Attribute | Value |
|---|---|
| **Tenant ID** | `380f38c1-6ed0-4676-b02e-568b6c3d8704` |
| **Name** | qazhb |
| **Domain** | qazhb.onmicrosoft.com |
| **Admin Email** | `admin@dyslexiasinister.onmicrosoft.com` |
| **Country** | Singapore |
| **Egress** | 8.07 TB (7d) via androiddownloadmanager (57.6% HTTP 206) |
| **FAB Status** | Blocked May 4 (24 BLOCK_FAILs before success) |

This confirms DYSLEXIASINISTER operates at least 2 tenants. The qazhb tenant was registered with the DYSLEXIASINISTER domain as its technical contact — unusual cross-tenant registration pattern.

---

## 3. Unflagged Tenants Requiring Immediate Action

### 3a. ARASAKA AKSLA — **CRITICAL, NOT IN FAB**

| Attribute | Value |
|---|---|
| **Tenant ID** | `dcf4cda6-0827-433d-98df-c91c7095d162` |
| **Domain** | aksla.onmicrosoft.com |
| **Name** | ARASAKA AKSLA |
| **Country** | Singapore |
| **Created** | May 11, 2021 |
| **Type** | Commercial / Default |
| **SKU** | BUSINESS BASIC FREE |
| **Paid** | Never |
| **Licenses** | 4 enabled of 20 acquired |
| **Storage Used** | **195,761 GB (195 TB)** |
| **Storage Limit** | 1,224 GB |
| **7-Day Egress** | **112.25 TB** (#1 in entire dataset) |
| **Ingress** | 660 GB |
| **Top App** | Other (69% HTTP 206) |
| **FAB Status** | **NOT IN FAB** |

**Assessment:** Massively over-quota (195 TB stored on a 1.2 TB limit). The #1 egress tenant in the entire dataset. Free tier, never paid. Immediate ingestion into FAB required.

### 3b. URV — **NOT IN FAB**

| Attribute | Value |
|---|---|
| **Tenant ID** | `17de9483-ab26-4723-aa3f-b0d4ad7d86ce` |
| **Domain** | odcmb.onmicrosoft.com |
| **Name** | URV |
| **Country** | United States (Oklahoma City, OK) |
| **Created** | Jun 6, 2023 |
| **Type** | Commercial / Default |
| **SKU** | SHAREPOINT (PLAN 2) |
| **Paid** | Yes |
| **Licenses** | 5 enabled of 6 acquired |
| **Admin Email** | `ODCBURV@outlook.com` |
| **Storage Used** | **77,756 GB (78 TB)** |
| **Storage Limit** | 1,084 GB |
| **7-Day Egress** | **9.17 TB** via rclone |
| **Custom Domain** | None (onmicrosoft.com only) |
| **FAB Status** | **NOT IN FAB** |

**Assessment:** 78 TB stored with only 5 users (15.5 TB/user). Using rclone for egress. Outlook.com admin email. No custom domain. Over quota by 70x. Suspicious pattern — paid SPO Plan 2 may be used to get storage allocation, then rclone to exfiltrate.

---

## 4. Zombie / Rolled-Back Tenants

### 4a. PLAZIN — Deleted in 2023, Still Egressing

| Attribute | Value |
|---|---|
| **Tenant ID** | `dfb5b2af-040c-4cc7-9c82-787bd6a2175d` |
| **Name** | PLAZIN |
| **Domain** | ozinp.onmicrosoft.com |
| **Country** | Australia |
| **Type** | Edu |
| **Admin** | `haripanel2580@gmail.com` |
| **Users** | 358 |
| **7-Day Egress** | **41.25 TB** via rclone (32.1% HTTP 206) |
| **FAB Status** | Delete initiated May 29, 2023 |

**Assessment:** This tenant was deleted over 3 years ago but still shows 41 TB rclone egress in current data. Either the delete didn't fully execute, or there's residual CDN/blob access. Needs investigation by platform team.

### 4b. duanren — Overquota Notification Rolled Back

| Attribute | Value |
|---|---|
| **Tenant ID** | `e439db60-5858-4549-9368-e297f66d8700` |
| **Name** | duanren |
| **Domain** | duanren.onmicrosoft.com + 123478.xyz |
| **Country** | China |
| **Type** | DeveloperOnly |
| **Admin** | `wangzhehan84@gmail.com` |
| **Users** | 21 |
| **7-Day Egress** | **2.92 TB** via rclone |
| **FAB Status** | E5DEV-OVERQUOTA — notifications rolled back Sep 2024, no further action |

**Assessment:** Was identified as overquota in Aug 2024, received Day 0 and Day 23 notifications, then both were **rolled back** in Sep 2024. Now actively egressing 3 TB/week with no enforcement. Custom domain (123478.xyz) on a developer tenant — suspicious.

---

## 5. Paid High-Egress Tenants — False Positives

### 5a. West Penetone Inc. — LEGITIMATE

| Attribute | Value |
|---|---|
| **Tenant ID** | `8577279e-556d-413c-9ad8-3de4a088b71d` |
| **Name** | West Penetone inc. |
| **Country** | Canada (Anjou, QC) |
| **Custom Domains** | penetone.com, westpenetoneinc.com, westpenetone.com, accuchem.ab.ca, unicacanada.com |
| **Users** | 436 (238 enabled) |
| **Groups** | 173 (117 security) |
| **Devices** | 320 (285 Windows) |
| **Created** | Jul 27, 2017 |
| **VL** | Yes (`noDeletionBy=VL`) |
| **Admin** | `m365@natrix.info` (managed IT provider) |
| **SKU** | Paid, multi-domain |
| **7-Day Egress** | 109.92 TB via Barracuda Backup (46.1% HTTP 206) |
| **FAB Status** | Not in FAB |

**Verdict:** Legitimate Canadian industrial chemical company. Multiple verified custom domains, VL customer, managed by MSP (natrix.info), using Barracuda cloud backup. High egress is proportional to enterprise size (238 users, 285 devices). **No action needed.**

### 5b. SciClone Pharmaceuticals — LEGITIMATE

| Attribute | Value |
|---|---|
| **Tenant ID** | `fc0df6c3-f6ba-4711-aba7-c6126696b6a6` |
| **Name** | SciClone Pharmaceuticals Hong Kong Limited |
| **Country** | Hong Kong |
| **Custom Domains** | SCICLONE.com, Globalsciclone.onmicrosoft.com, globalsmtp.sciclonecloud.com |
| **Users** | 1,880 (1,531 enabled) |
| **Groups** | 213 (45 security, 169 mail-enabled) |
| **Devices** | 488 (487 Windows) |
| **Created** | Jan 13, 2025 |
| **Admin** | `lutao@sciclone.com` (corporate) |
| **SKU** | Paid |
| **7-Day Egress** | 108.63 TB via Veeam (3.3% HTTP 206) |
| **FAB Status** | Not in FAB |

**Verdict:** Legitimate pharmaceutical company. Corporate admin email on company domain, 1,531 active users, 487 Windows devices, using Veeam enterprise backup. Likely recent M365 migration (created Jan 2025) with initial full backup driving high egress. **No action needed.**

---

## 6. Already-Handled Tenants

| Tenant | Egress (TB) | Status |
|---|---|---|
| chinfx (`76b08055`) | 5.28 | Blocked May 5 |
| "MSFT" (`d481e130`) | 1.23 | Blocked Apr 19, delete scheduled May 9 |
| qazhb (`380f38c1`) | 8.07 | Blocked May 4 |

---

## Recommended Actions

### Immediate

1. **Ingest ARASAKA AKSLA** (`dcf4cda6-0827-433d-98df-c91c7095d162`) into FAB — #1 egress tenant at 112 TB/week, never paid, 195 TB stored on free tier
2. **Ingest URV** (`17de9483-ab26-4723-aa3f-b0d4ad7d86ce`) into FAB — 9 TB rclone egress, 78 TB stored with 5 users, suspicious pattern
3. **Investigate PLAZIN zombie** (`dfb5b2af`) — deleted in 2023 but still egressing 41 TB/week; escalate to platform team
4. **Re-evaluate duanren** (`e439db60`) — overquota notifications were rolled back; still actively egressing 3 TB/week via rclone

### Systemic

5. **BLOCK_FAIL investigation** — Every FAMILIA CONFEITAR tenant experienced 20-30 BLOCK_FAILs before success. This adds ~5 days of continued egress per tenant. Root cause analysis needed on why Block is failing repeatedly.
6. **ReadOnly gap** — 21-day ReadOnly→Block gap allows continued egress. Combined with BLOCK_FAIL retries, total unmitigated egress window reaches 26+ days. Case for shortening this gap (user building separately).
7. **Overquota rollback audit** — duanren shows that E5DEV overquota notifications can be rolled back with no follow-up. Need process to prevent rollback abuse on tenants with active egress.

---

## Detection Rule Gaps

The FAMILIA CONFEITAR ring was caught by FAB, but key signals that should enable faster detection:

| Signal | Value | Detection Potential |
|---|---|---|
| Sequential naming (familiaconfeitar2–30) | 30 tenants, 4-week burst | Registration velocity / pattern matching |
| Shared admin email across 30 tenants | mario@ritzmann.com.br | Admin email clustering (D2 query) |
| Shared phone number | 4196152228 | Phone clustering (D3 query) |
| Identical address/city | R 424, 353 SALA 02, Itapema | Address clustering |
| Zero ingress, massive egress | 60-74 TB each | Egress:ingress ratio (S2 query) |
| 2 users, 1 license per tenant | Uniform across ring | Provisioning velocity (S3 query) |

ARASAKA AKSLA and URV are not caught because they don't fit the ring pattern — they're single-tenant abusers with different profiles. ARASAKA should be caught by egress:ingress ratio and overquota detection; URV by rclone app detection.
