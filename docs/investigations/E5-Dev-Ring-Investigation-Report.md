# E5 Developer 4-Char Abuse Ring — Investigation Report

**Report Date:** April 1, 2026  
**Last Updated:** April 2, 2026  
**Severity:** P0 — CRITICAL  
**Analyst:** FAB Tenant Investigation (Copilot-assisted)  
**Ring ID:** E5-DEV-4CHAR-RING  
**FraudID Range:** 148086–148104  
**IcM Incident:** [771886996](https://portal.microsofticm.com/imp/v5/incidents/details/771886996/summary)  

---

## Executive Summary

| Metric | Value |
|--------|-------|
| **Ring members** | 31 confirmed |
| **Total storage consumed** | **~2,995 TB (~2.9 PB)** |
| **Avg storage per tenant** | ~97 TB |
| **Countries involved** | 11 |
| **Creation window** | June 2023 – January 2024 (7 months) |
| **SKU** | E5 Developer (Trial, never paid) |
| **Revenue lost** | $0 (all free trial abuse) |
| **Ingested to FAB** | 17 of 31 (55%) |
| **Successfully blocked** | 14 of 31 (45%) |
| **Block failures (persistent)** | 3 (QNYA, KQIU, TNRX) — **ACTION REQUIRED** |
| **Not yet in FAB** | 14 of 31 (45%) — **INGESTION BLOCKED** |

This ring was discovered on **March 24, 2026** during a batch investigation of 50 high-storage tenants flagged by Kusto analysis. The 31 ring members accounted for **62% of the batch** and **~2.9 PB of the ~4 PB** total storage across all 50 tenants. On **April 1, 2026** at 07:34 UTC, 17 of the 31 members were ingested into FAB and remediation began — 14 blocked successfully, 3 failed persistently (7+ retries each). Ingestion of the remaining 14 was attempted on April 1 and April 2 via MCP but both attempts were rejected with `ValidationFailureException` — likely a Kusto-side validation failure (tenants may no longer be in TENANT_INFO or are failing HAS_VL/IS500/TenantLevel checks). **Manual ingestion via FAB dashboard required.**

---

## Discovery Context

### The 50-Tenant Batch Investigation (March 24, 2026)

The ring was identified during a systematic investigation of the 50 highest-storage non-FAB tenants in the `fabdardb` Kusto cluster. The investigation revealed:

- **50 tenants** consuming **~4,062 TB (~3.97 PB)** of storage
- **44 tenants (88%)** were NOT tracked in FAB
- **31 tenants (62%)** belonged to this single coordinated ring
- The remaining 19 tenants included the ACGDB ring (3), SPO-only abuse cluster (4), MistyCloud ring (12 found separately), and individual cases

The E5 Dev 4-Char Ring stood out immediately due to its uniform fingerprint across all members. Full details of the parent investigation are in [50_Tenant_Investigation_Report.md](../50_Tenant_Investigation_Report.md).

---

## Ring Fingerprint

Every ring member matches ALL of the following criteria:

| Attribute | Value |
|-----------|-------|
| **SKU** | E5 Developer (Trial) |
| **Has ever paid** | FALSE |
| **Tenant name** | 4-character uppercase alphanumeric (30 of 31) |
| **Outlier name** | "DEEPBYTE" (1 of 31, Barbados-registered) |
| **Domain** | `{name}.onmicrosoft.com` only — no custom domains |
| **Licenses** | 0 acquired / 25 enabled |
| **ODB sites** | 23–25 per tenant |
| **Storage** | 66–127 TB per tenant |
| **Activated users** | 0 |
| **Sessions** | 0 |
| **D2K Instance** | Europe (30), North America (1 — DEEPBYTE) |
| **City field** | Empty (all members) |
| **Language** | en (all members) |
| **Viral subscription** | FALSE |
| **Custom domain** | FALSE |

**Behavioral signature:** Pure storage abuse — accounts were provisioned, ODB sites created to max capacity, and massive data stored. Zero interactive usage. Zero payments. The 4-character random name pattern strongly suggests automated provisioning via script.

---

## Country Distribution

| Country | Code | Count | Tenants |
|---------|------|-------|---------|
| Estonia | EE | 6 | FTAF, QNYA, EJTD, GQBP, KQIU, BIXW |
| Lithuania | LT | 6 | IHQV, ZMDI, JPTK, WODX, AWZS, CCZK |
| United Kingdom | GB | 6 | HXGF, ROOW, HSFU, IXRE, EWHG, ZYVH |
| Poland | PL | 3 | FUQX, YEQX, WEUB |
| Latvia | LV | 3 | EKBI, IGFU, ZFCF |
| Romania | RO | 2 | RPEJ, PZGU |
| Portugal | PT | 1 | KJYS |
| Slovenia | SI | 1 | WQHS |
| Israel | IL | 1 | EHJW |
| Spain | ES | 1 | TNRX |
| Barbados | BB | 1 | DEEPBYTE |

The geographic spread across 11 countries (primarily EU) with identical SKU/behavior is a strong indicator of a single actor using VPNs or multiple registrations.

---

## Remediation Status (as of April 2, 2026)

### Overview

On **April 1, 2026 at 07:34 UTC**, 17 ring members were ingested into FAB as a batch (all share `identifiedDate: 2026-04-01T07:34`). Remediation schedules were created at ~07:45, and block actions executed between 08:48 and 10:05. 14 blocked successfully; 3 have been retrying and failing persistently (7+ attempts each through April 2).

| Status | Count | % | Details |
|--------|-------|---|---------|
| **Blocked (Status 4)** | 14 | 45% | BLOCK_SUCCESS — fully remediated |
| **Block Failed (Status 9)** | 3 | 10% | BLOCK_FAIL — persistent, 7+ retries each |
| **Not in FAB** | 14 | 45% | Ingestion failing — Kusto validation issue |
| **Total** | 31 | 100% | |

### Successfully Blocked (14 tenants)

| # | Tenant ID | Name | CC | FraudID | Block Time (UTC) | Storage TB | Created |
|---|-----------|------|----|---------|-------------------|-----------|---------|
| 1 | `35ff20bc-d0b8-4750-9097-9004c1e4daad` | AWZS | LT | 148088 | 2026-04-01 10:00 | 68 | 2023-08-09 |
| 2 | `72aae8fc-5507-41a2-b516-a42ba594ed2f` | BIXW | EE | 148096 | 2026-04-01 09:46 | 91 | 2023-11-01 |
| 3 | `7b127372-ef6c-4c4b-b2be-26a2f137afac` | CCZK | LT | 148095 | 2026-04-01 10:05 | 66 | 2023-07-26 |
| 4 | `6f5b884d-6109-47d8-abc1-d922b7dd2d78` | EHJW | IL | 148102 | 2026-04-01 09:54 | 89 | 2023-06-22 |
| 5 | `40be4ab0-889c-4ae6-809c-11b714bad085` | EJTD | EE | 148093 | 2026-04-01 09:25 | 107 | 2023-07-16 |
| 6 | `5c0ef4e9-9a1f-41ce-89a6-5b854e07030f` | EWHG | GB | 148101 | 2026-04-01 09:32 | 102 | 2023-07-14 |
| 7 | `36560e55-7565-4d49-8274-fd0649ecfe2a` | FUQX | PL | 148089 | 2026-04-01 09:26 | 106 | 2023-10-21 |
| 8 | `44918409-5f88-4436-8e52-233fb72507c0` | GQBP | EE | 148103 | 2026-04-01 09:52 | 91 | 2023-09-24 |
| 9 | `410b5298-ea9b-4ca7-a9ee-12f176f07af2` | HSFU | GB | 148090 | 2026-04-01 09:23 | 107 | 2023-06-21 |
| 10 | `62659a74-87e0-41f7-a7e0-9fe658cf36b9` | IGFU | LV | 148100 | 2026-04-01 09:21 | 107 | 2023-07-28 |
| 11 | `47350884-41f2-4838-88b5-9d2820c92bec` | IXRE | GB | 148098 | 2026-04-01 09:43 | 98 | 2023-11-01 |
| 12 | `40f232e0-2ff1-48e1-b154-24fbf2fad2a4` | ROOW | GB | 148094 | 2026-04-01 09:29 | 103 | 2023-06-27 |
| 13 | `3e26746b-9006-4dfe-8743-ee529be52cbe` | YEQX | PL | 148086 | 2026-04-01 09:56 | 83 | 2024-01-04 |
| 14 | `6a779e69-99f2-4ad0-aa2b-216146b18443` | ZYVH | GB | 148099 | 2026-04-01 09:50 | 91 | 2023-07-23 |

**UseCase:** ABUSE-BLOCK-DELETE_15DAYS (all)  
**ApprovalFlag:** 2 (auto-approved, all)  
**Blocked storage reclaimed:** ~1,309 TB (~1.28 PB)

### Block Failures — ACTION REQUIRED (3 tenants)

| # | Tenant ID | Name | CC | FraudID | Retries | Last Attempt (UTC) | Storage TB |
|---|-----------|------|----|---------|---------|-------------------|-----------|
| 1 | `3d9b8222-9ec7-4f84-968b-27a2bfa18f82` | QNYA | EE | 148091 | 7 | 2026-04-02 00:45 | 106 |
| 2 | `65e7eeee-b65e-473a-bbfb-ee243097a34d` | KQIU | EE | 148104 | 7 | 2026-04-02 00:44 | 107 |
| 3 | `7cc6ac3e-26c0-4c77-82dc-6066b1c1ca17` | TNRX | ES | 148097 | 7 | 2026-04-02 00:47 | 92 |

All three are **Status 9** with `lastActionStatus: -1`. The system has been auto-retrying approximately every 4 hours since the initial failure on April 1 at ~08:49 UTC. All 7 retries per tenant have failed.

**QNYA retry timeline:** 08:49 → 12:36 → 12:50 → 16:38 → 20:39 → 00:37 → 00:45 (all BLOCK_FAIL)  
**KQIU retry timeline:** 08:48 → 12:36 → 12:48 → 16:37 → 20:37 → 00:37 → 00:44 (all BLOCK_FAIL)  
**TNRX retry timeline:** 08:51 → 12:37 → 12:52 → 16:40 → 20:46 → 00:37 → 00:47 (all BLOCK_FAIL)

**At-risk storage:** ~305 TB  
**Required action:** Escalate — automated retries are not resolving these. Manual investigation into why these 3 specific tenants cannot be blocked.

### Not in FAB — INGESTION BLOCKED (14 tenants)

| # | Tenant ID | Name | CC | Storage TB | Created |
|---|-----------|------|----|-----------|---------|
| 1 | `9e2edf37-07ef-44df-94b7-d03bda7ee3d6` | IHQV | LT | 106 | 2023-11-29 |
| 2 | `c765c9c7-2bb1-4e2a-b06e-f2fc05a8ab08` | HXGF | GB | 91 | 2023-06-26 |
| 3 | `09f2df07-28a3-4697-9f6c-aa370e93d6cd` | KJYS | PT | 101 | 2023-07-18 |
| 4 | `11d0ddd2-2d7f-43ef-9c3b-06a314d8a87b` | RPEJ | RO | 104 | 2023-10-09 |
| 5 | `19239d6d-0019-4ee7-abc2-12ec0aaf17e1` | ZMDI | LT | 93 | 2023-08-28 |
| 6 | `1bb9aeb6-f14e-4c3c-a6c3-79e3d7b77ce3` | FTAF | EE | 101 | 2023-07-04 |
| 7 | `215b8b0e-fa59-424b-b53f-54ffa2236e9d` | WQHS | SI | 72 | 2023-08-01 |
| 8 | `23fdcd94-be71-4b91-8df2-9b2e12a67dfe` | EKBI | LV | 104 | 2023-07-04 |
| 9 | `28eb0462-8ea1-4c5a-a48f-3cfce23b95c9` | PZGU | RO | 100 | 2023-10-20 |
| 10 | `30c755cc-2b93-4ee2-bcf4-c2a8be5ef7e1` | JPTK | LT | 95 | 2023-09-05 |
| 11 | `34c96869-10c0-4adf-b2c6-fef2e6e2e7b2` | WODX | LT | 97 | 2023-10-06 |
| 12 | `7d811bd2-0cb2-43de-84c0-ad2b5515f609` | DEEPBYTE | BB | 124 | 2023-08-20 |
| 13 | `84a5de99-ecde-4d4c-9b06-8af32120c953` | ZFCF | LV | 102 | 2023-09-16 |
| 14 | `8adf047c-a733-4570-abc1-3dcbe2b621e8` | WEUB | PL | 91 | 2023-11-29 |

**Unblocked storage at risk:** ~1,381 TB (~1.35 PB)

**Ingestion attempts:**
- **April 1, 2026** — `ValidationFailureException` (full batch of 18, and single-tenant test)
- **April 2, 2026** — `ValidationFailureException` (reduced batch of 14, and single-tenant test)

The failure occurs during server-side Kusto validation (HAS_VL, IS500, TenantLevel checks or tenant-not-found in Kusto). These tenants may have been removed from the `TENANT_INFO` table or their metadata changed since the March 24 investigation.

**Required action:** Manual ingestion via FAB dashboard, or investigate why these tenants fail Kusto validation.

**Ingestion parameters (for manual retry):**
- **ReasonCode:** 106 (Adhoc Investigation)
- **UseCaseType:** 1 (TYPE1)
- **IsReviewRequired:** false
- **TicketLink:** https://portal.microsofticm.com/imp/v5/incidents/details/771886996/summary

**Comma-separated IDs for bulk ingestion:**
```
9e2edf37-07ef-44df-94b7-d03bda7ee3d6,c765c9c7-2bb1-4e2a-b06e-f2fc05a8ab08,09f2df07-28a3-4697-9f6c-aa370e93d6cd,11d0ddd2-2d7f-43ef-9c3b-06a314d8a87b,19239d6d-0019-4ee7-abc2-12ec0aaf17e1,1bb9aeb6-f14e-4c3c-a6c3-79e3d7b77ce3,215b8b0e-fa59-424b-b53f-54ffa2236e9d,23fdcd94-be71-4b91-8df2-9b2e12a67dfe,28eb0462-8ea1-4c5a-a48f-3cfce23b95c9,30c755cc-2b93-4ee2-bcf4-c2a8be5ef7e1,34c96869-10c0-4adf-b2c6-fef2e6e2e7b2,7d811bd2-0cb2-43de-84c0-ad2b5515f609,84a5de99-ecde-4d4c-9b06-8af32120c953,8adf047c-a733-4570-abc1-3dcbe2b621e8
```

---

## Complete Ring Membership (31 tenants)

Sorted by tenant name. Storage values from Kusto (March 24, 2026).

| # | Tenant ID | Name | CC | Storage TB | ODB Sites | Created | FAB Status |
|---|-----------|------|----|-----------|-----------|---------|------------|
| 1 | `35ff20bc-...` | AWZS | LT | 68 | 24 | 2023-08-09 | **BLOCKED** |
| 2 | `72aae8fc-...` | BIXW | EE | 91 | 24 | 2023-11-01 | **BLOCKED** |
| 3 | `7b127372-...` | CCZK | LT | 66 | 24 | 2023-07-26 | **BLOCKED** |
| 4 | `7d811bd2-...` | DEEPBYTE | BB | 124 | 25 | 2023-08-20 | Not in FAB |
| 5 | `6f5b884d-...` | EHJW | IL | 89 | 24 | 2023-06-22 | **BLOCKED** |
| 6 | `40be4ab0-...` | EJTD | EE | 107 | 24 | 2023-07-16 | **BLOCKED** |
| 7 | `23fdcd94-...` | EKBI | LV | 104 | 24 | 2023-07-04 | Not in FAB |
| 8 | `5c0ef4e9-...` | EWHG | GB | 102 | 23 | 2023-07-14 | **BLOCKED** |
| 9 | `1bb9aeb6-...` | FTAF | EE | 101 | 24 | 2023-07-04 | Not in FAB |
| 10 | `36560e55-...` | FUQX | PL | 106 | 24 | 2023-10-21 | **BLOCKED** |
| 11 | `44918409-...` | GQBP | EE | 91 | 23 | 2023-09-24 | **BLOCKED** |
| 12 | `410b5298-...` | HSFU | GB | 107 | 24 | 2023-06-21 | **BLOCKED** |
| 13 | `c765c9c7-...` | HXGF | GB | 91 | 24 | 2023-06-26 | Not in FAB |
| 14 | `62659a74-...` | IGFU | LV | 107 | 24 | 2023-07-28 | **BLOCKED** |
| 15 | `9e2edf37-...` | IHQV | LT | 106 | 24 | 2023-11-29 | Not in FAB |
| 16 | `47350884-...` | IXRE | GB | 98 | 24 | 2023-11-01 | **BLOCKED** |
| 17 | `30c755cc-...` | JPTK | LT | 95 | 24 | 2023-09-05 | Not in FAB |
| 18 | `09f2df07-...` | KJYS | PT | 101 | 24 | 2023-07-18 | Not in FAB |
| 19 | `65e7eeee-...` | KQIU | EE | 107 | 24 | 2023-07-28 | **BLOCK FAIL** (7x) |
| 20 | `28eb0462-...` | PZGU | RO | 100 | 24 | 2023-10-20 | Not in FAB |
| 21 | `3d9b8222-...` | QNYA | EE | 106 | 24 | 2023-08-07 | **BLOCK FAIL** (7x) |
| 22 | `40f232e0-...` | ROOW | GB | 103 | 24 | 2023-06-27 | **BLOCKED** |
| 23 | `11d0ddd2-...` | RPEJ | RO | 104 | 24 | 2023-10-09 | Not in FAB |
| 24 | `7cc6ac3e-...` | TNRX | ES | 92 | 24 | 2023-12-28 | **BLOCK FAIL** (7x) |
| 25 | `8adf047c-...` | WEUB | PL | 91 | 24 | 2023-11-29 | Not in FAB |
| 26 | `34c96869-...` | WODX | LT | 97 | 24 | 2023-10-06 | Not in FAB |
| 27 | `215b8b0e-...` | WQHS | SI | 72 | 24 | 2023-08-01 | Not in FAB |
| 28 | `3e26746b-...` | YEQX | PL | 83 | 24 | 2024-01-04 | **BLOCKED** |
| 29 | `84a5de99-...` | ZFCF | LV | 102 | 24 | 2023-09-16 | Not in FAB |
| 30 | `19239d6d-...` | ZMDI | LT | 93 | 24 | 2023-08-28 | Not in FAB |
| 31 | `6a779e69-...` | ZYVH | GB | 91 | 24 | 2023-07-23 | **BLOCKED** |

---

## Remediation Timeline (April 1–2, 2026)

All 17 ingested tenants followed the same remediation pipeline:

```
April 1:
07:34 UTC — Batch identified (identifiedDate for all 17)
07:45 UTC — Remediation schedules created (~10s window)
08:48 UTC — KQIU block FAIL ✗
08:49 UTC — QNYA block FAIL ✗
08:51 UTC — TNRX block FAIL ✗
09:21 UTC — IGFU blocked ✓
09:23 UTC — HSFU blocked ✓
09:25 UTC — EJTD blocked ✓
09:26 UTC — FUQX blocked ✓
09:29 UTC — ROOW blocked ✓
09:32 UTC — EWHG blocked ✓
09:43 UTC — IXRE blocked ✓
09:46 UTC — BIXW blocked ✓
09:50 UTC — ZYVH blocked ✓
09:52 UTC — GQBP blocked ✓
09:54 UTC — EHJW blocked ✓
09:56 UTC — YEQX blocked ✓
10:00 UTC — AWZS blocked ✓
10:05 UTC — CCZK blocked ✓
12:36-12:52 — QNYA, KQIU, TNRX retry #2-3 FAIL ✗
16:37-16:40 — QNYA, KQIU, TNRX retry #4 FAIL ✗
20:37-20:46 — QNYA, KQIU, TNRX retry #5 FAIL ✗

April 2:
00:37-00:47 — QNYA, KQIU, TNRX retry #6-7 FAIL ✗
```

---

## Storage Impact Analysis

| Category | Tenants | Total Storage | % of Ring |
|----------|---------|--------------|-----------|
| **Blocked** | 14 | ~1,309 TB (1.28 PB) | 44% |
| **Block Failed** | 3 | ~305 TB | 10% |
| **Not in FAB** | 14 | ~1,381 TB (1.35 PB) | 46% |
| **Ring Total** | 31 | **~2,995 TB (2.9 PB)** | 100% |

**44% of the ring's storage has been neutralized.** 1.69 PB remains at risk (block failures + untracked tenants).

---

## Creation Timeline

The operator provisioned tenants over a 7-month window (June 2023 – January 2024):

| Month | Count | Tenants |
|-------|-------|---------|
| Jun 2023 | 4 | HSFU, EHJW, HXGF, ROOW |
| Jul 2023 | 7 | FTAF, EKBI, EWHG, EJTD, KJYS, ZYVH, CCZK |
| Aug 2023 | 4 | WQHS, QNYA, AWZS, DEEPBYTE |
| Sep 2023 | 3 | JPTK, ZFCF, GQBP |
| Oct 2023 | 4 | WODX, RPEJ, PZGU, FUQX |
| Nov 2023 | 4 | IHQV, IXRE, BIXW, WEUB |
| Dec 2023 | 1 | TNRX |
| Jan 2024 | 1 | YEQX |

Peak provisioning: **July 2023 (7 tenants)** — roughly 1 new tenant every other day. The steady cadence across months suggests a scripted or semi-automated process with periodic batch creation.

---

## Detection Queries

Eight Kusto detection queries have been prepared in [E5_Dev_Ring_Detection_Queries.kql](../E5_Dev_Ring_Detection_Queries.kql):

1. **Core Ring Detection** — Strict 4-char name + high storage match
2. **Broader Detection** — Relaxed name constraint (catches DEEPBYTE variants)
3. **Country Distribution** — Geography summary for reporting
4. **Grand Total** — Overall ring impact metrics
5. **FAB Cross-reference** — Which members are tracked vs. untracked
6. **Creation Timeline** — Provisioning wave analysis (timechart)
7. **Known Member Verification** — Confirms all 31 GUIDs are captured
8. **Bulk Extraction** — Comma-separated tenant IDs for FAB ingestion

These queries target `fabdardb` (MSIT) or `fabdardbpp` (SDF) on the `odspfabkusto` cluster.

---

## Recommended Actions

### Immediate (P0)

1. **Escalate persistent block failures** — QNYA, KQIU, TNRX have each failed 7+ block attempts over 16 hours. Automated retries are not resolving these. Investigate the root cause (possible tenant-level lock, service-side rejection, or regional issue).
   - `3d9b8222-9ec7-4f84-968b-27a2bfa18f82` (QNYA — EE)
   - `65e7eeee-b65e-473a-bbfb-ee243097a34d` (KQIU — EE)
   - `7cc6ac3e-26c0-4c77-82dc-6066b1c1ca17` (TNRX — ES)

2. **Manually ingest remaining 14 tenants via FAB dashboard** — MCP-based ingestion fails with `ValidationFailureException` on both April 1 and April 2. Server-side Kusto validation is rejecting these tenants. Manual dashboard ingestion may bypass this or provide a more descriptive error.

### Short-term (P1)

3. **Run Query 1 (Core Detection) on current Kusto data** — The ring may have grown since March 24. New 4-char E5 Dev tenants matching the fingerprint should be flagged.

4. **Investigate the Kusto validation failure** — Determine why the 14 un-ingested tenants fail the `ValidateTenantsAysnc` check. Possible causes: tenants removed from TENANT_INFO, HAS_VL changed to TRUE, IS500 changed to TRUE, or TenantLevel mismatch.

5. **Investigate DEEPBYTE separately** — Only non-4-char member, only non-EU member (Barbados), only North America D2K instance. May be a test account by the same operator, or a link to a different ring.

### Long-term (P2)

6. **Add E5 Dev ring pattern to automated detection** — The fingerprint (4-char name + E5 Dev Trial + 0 paid + high storage + 0 sessions + EU geography) should be encoded as a scheduled detection rule.

7. **Monitor for new E5 Developer Trial abuse** — The operator may switch to different naming patterns or SKUs after this ring is blocked.

---

## Appendix: FraudID Mapping

| FraudID | Tenant | Name | Status |
|---------|--------|------|--------|
| 148086 | `3e26746b` | YEQX | Blocked |
| 148088 | `35ff20bc` | AWZS | Blocked |
| 148089 | `36560e55` | FUQX | Blocked |
| 148090 | `410b5298` | HSFU | Blocked |
| 148091 | `3d9b8222` | QNYA | **Block Fail (7x)** |
| 148093 | `40be4ab0` | EJTD | Blocked |
| 148094 | `40f232e0` | ROOW | Blocked |
| 148095 | `7b127372` | CCZK | Blocked |
| 148096 | `72aae8fc` | BIXW | Blocked |
| 148097 | `7cc6ac3e` | TNRX | **Block Fail (7x)** |
| 148098 | `47350884` | IXRE | Blocked |
| 148099 | `6a779e69` | ZYVH | Blocked |
| 148100 | `62659a74` | IGFU | Blocked |
| 148101 | `5c0ef4e9` | EWHG | Blocked |
| 148102 | `6f5b884d` | EHJW | Blocked |
| 148103 | `44918409` | GQBP | Blocked |
| 148104 | `65e7eeee` | KQIU | **Block Fail (7x)** |

Note: FraudIDs 148087, 148092 are not assigned to this ring — they may belong to other ingestions in the same batch.

---

## Change Log

| Date | Change |
|------|--------|
| 2026-04-01 | Initial report. 13 of 31 ingested, 11 blocked, 2 block-fail (QNYA, KQIU), 18 not in FAB. |
| 2026-04-01 | Ingestion of remaining 18 failed (`ValidationFailureException`). Retry scheduled for Apr 2. PDF generated. |
| 2026-04-02 | Re-checked all 31 tenants. Discovered 4 more were ingested in the Apr 1 batch (EHJW, BIXW, CCZK, TNRX). TNRX is a new persistent block failure (7 retries). Corrected counts: 17 ingested (14 blocked, 3 block-fail), 14 not in FAB. Ingestion retry on Apr 2 also failed. Report fully rewritten with corrected data. |

---

*Report generated from FAB MCP tool remediation data (April 1–2, 2026) and Kusto tenant analysis (March 24, 2026).*
