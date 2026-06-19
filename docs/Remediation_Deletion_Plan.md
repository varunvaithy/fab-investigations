# FAB Tenant Deletion Remediation Plan
**Status:** DRAFT  
**Date:** April 24, 2026  
**Owner:** ODSP Fraud and Abuse (FAB)  
**FY note:** FY27 begins July 1, 2026. FY26 ends June 30, 2026.

---

## Context & Goals

**Deletion is intentionally paused** — this is a design decision, not a blocker. The plan below reflects that reality.

The two things we need to achieve before June 30 (end of FY26):

1. **By June 30 — BLOCK coverage**: Every tenant whose scheduled deletion date falls on or before June 30 must be in **BLOCKED** state (Status 4 or higher). This ensures no tenant enters FY27 still sitting in ReadOnly/Identified when it was supposed to be on a delete path.

2. **May — Deletion stress test**: Engineering will use May to test that the deletion pipeline actually works end-to-end by doing **real but small-scale deletions** of the overdue "should have been deleted already" cohort. The goal is to find breaks, fix them, and certify the pipeline before FY27's full deletion wave.

**FY27 plan (July+ — out of scope for this plan):** Once deletion is re-enabled, all tenants in BLOCKED state with a deletion use case will be swept and deleted in bulk. That wave needs a working, tested pipeline — which is what May buys us.

**Key constraint:** Do **not** alter the scheduled deletion dates for tenants whose natural remediation timeline puts them in July or later. If a tenant gets blocked in May and its deletion is scheduled for August, leave it alone.

---

## 1. Current State — Pipeline Snapshot (April 20, 2026)

| Stage | Status Code | Tenants | Storage | Note |
|-------|-------------|---------|---------|------|
| Delete Completed | 6 | 33,323 | 435.8 PB | Done ✅ |
| Block Completed | 4 | 64,652 | 112.1 PB | Waiting for deletion; some overdue |
| In Remediation | 8 | 21,767 | 4.51 PB | Active remediation window |
| ReadOnly Done | 3 | 12,657 | 25.4 PB | Block pending |
| Identified | 1 | 8,622 | 37.3 PB | Not yet queued |
| Delete In-Progress | 5 | 5,275 | 23.5 PB | Stuck — unknown root cause |
| False Positive | 7 | 1,179 | 24.9 PB | Resolved |

### In-Remediation Breakdown by Use Case (Status 8)

| Use Case | Tenants | Storage | Delete Window After Block |
|----------|---------|---------|--------------------------|
| ABUSE-READONLY-BLOCK-DELETE_15DAYS | 10,205 | 2.85 PB | 15 days |
| ABUSE-READONLY-BLOCK-DELETE | 825 | 22.84 PB | 30 days |
| ABUSE-BLOCK-DELETE_15DAYS | 4 | 0.39 PB | 15 days |
| TYPE1 | 28 | 0.025 PB | 30 days |

### Engineering Context — `DeleteTenantActivity`

`DeleteTenantActivity.cs` is currently a stub (intentionally). It logs and records metrics but does not call any real deletion API. Engineering will wire up the real deletion call as part of the May testing phase. The 33,323 "Delete Completed" records came from a legacy deletion pipeline, not from the FABTenantService DTF path.

**This is not a blocker for FY26 goals** — FY26 goal is BLOCK coverage, not deletion.

### Known Stuck Tenants
- NDLG, HAZE5, `afba3f73` — stuck Status 1 (INV-008, 15+ days)
- `24098c20` — stuck Status 1 for 15+ days (INV-014/INV-015, TYPE1 stalled)
- `ac295da4` (QUANG TRUNG COLLEGE) — `noDeletionBy=VL` blocker

---

## 2. The Three Tenant Buckets

This is the most important framing. Every deletion-eligible tenant falls into exactly one of three buckets based on their **scheduled deletion date**. The bucket determines what action is taken in FY26 vs. FY27.

---

### Bucket A — Overdue Deletions (Scheduled delete date already passed)

`SCHEDULED_DELETION_DATE < TODAY`

These tenants have been sitting in a blocked state past the date their use case said they should be deleted. Deletion was paused, so they accumulated. This is the primary cohort for **May deletion stress testing**.

- **FY26 action:** Delete in May as engineering test runs. Start small, scale up.
- **Why:** Best test subjects — already past their window, no timing concerns, lowest risk of disturbing active remediation cycles.
- **Count to verify:** Run Q-B-A below.

---

### Bucket B — Deletion Due by June 30 (Scheduled date in May or June)

`SCHEDULED_DELETION_DATE BETWEEN TODAY AND '2026-06-30'`

These tenants will reach their scheduled deletion date during FY26. Their natural pipeline should carry them to deletion before June 30.

- **FY26 action:** Ensure they are **BLOCKED (Status 4 or higher) by June 30**. Actual deletion can proceed in July (FY27) if needed, but the block must happen on schedule.
- **Why this matters:** If deletion is re-enabled on July 1, these tenants need to already be blocked — otherwise FY27 deletion wave has to wait 15–30 more days for the block step.
- **Count to verify:** Run Q-B-B below.

---

### Bucket C — FY27 Deletions (Scheduled date July 1 or later)

`SCHEDULED_DELETION_DATE >= '2026-07-01'` OR no deletion use case / not yet blocked

These tenants are in a normal, healthy remediation cycle. Their timeline puts deletion in FY27. 

- **FY26 action:** **Do not alter the schedule.** Let the pipeline run naturally. The only thing to confirm is that their remediation is progressing (not stuck in ReadOnly with no block scheduled).
- **Count to verify:** Run Q-B-C below.

---

## 3. Goals & Success Criteria (Revised)

### FY26 Goals (by June 30, 2026)

| Goal | Metric | Target |
|------|--------|--------|
| Bucket A (overdue) deletions tested and completed | Tenants with STATUS = 6 from Bucket A | 100% of overdue cohort |
| Bucket B tenants all in BLOCKED state | STATUS ≥ 4 for all Bucket B tenants | 100% by June 30 |
| Deletion pipeline validated end-to-end | Deletion success rate in testing | ≥ 98% |
| No false positive deletions | FP count during deletion test runs | 0 |
| VL/high-risk tenants explicitly reviewed | Bucket A T4 count dispositioned | 100% |
| Observability in place | Deletion metric coverage | 100% per-tenant logging |

### FY27 Goals (July 1+, out of scope for this plan)

- Full deletion wave of all Bucket B + Bucket C tenants on their natural schedule
- Pipeline proven and scaled from May stress testing

---

## 4. Risk Tier Framework

Used within Bucket A and Bucket B to sequence deletion order — lowest risk deleted first during testing.

| Tier | Criteria | FY26 Action |
|------|----------|-------------|
| **T1 — LOW** | No VL, no paid history, Storage < 1 TB, Dev/Trial SKU | Delete in May micro-batches; safe for bulk |
| **T2 — MEDIUM** | No VL, Storage 1–10 TB, commercial SKU | Delete with monitoring; 100-tenant batches |
| **T3 — HIGH** | Storage > 10 TB OR `HAS_EVER_PAID = TRUE` | Manual pre-approval required per tenant |
| **T4 — CRITICAL** | `HAS_VL = TRUE`, charity, government, or > 500 licenses | Do not delete without explicit Commerce sign-off |

Risk dimensions scored per tenant:
- **COGS**: `TENANT_TOTAL_DISK_USED_GB` — direct storage cost
- **Revenue risk**: `HAS_VL`, `HAS_EVER_PAID` — billing dispute exposure
- **PR/Legal**: `HAS_CHARITY_OFFER`, `HAS_GOVERNMENT_OFFER`, open ICM — reputational
- **Blast radius**: `TOTAL_USERS`, `LICENSES_ACQUIRED` — signals real org activity

---

## 5. Engineering Work Required

### 5.1 P0 — Wire Up `DeleteTenantActivity` (for May testing)

The activity is a stub by design. Engineering needs to replace the stub with a real deletion API call for the May stress testing.

**Work items:**
- [ ] Identify the actual deletion API endpoint (TSCN? O365 Admin API? queue-based via `TENANT_ACTIONS_SCHD`?)
- [ ] Implement the real API call with proper authentication (managed identity / keyvault secret)
- [ ] Add DTF retry logic (`RetryOptions` already exists in the orchestration framework)
- [ ] Update `FRAUD_TENANT_DETAILS.STATUS` → 6 (Delete Completed) on success
- [ ] Handle failure: log error, leave tenant at current status, do NOT silently swallow
- [ ] Unit tests: success path, API failure path, VL-blocked path, idempotency (calling twice = no-op)
- [ ] Integration test in SDF with a test tenant before touching production

**Key question to resolve first:** Does our deletion flow call the deletion API directly in `DeleteTenantActivity`, or does it write a row to `TENANT_ACTIONS_SCHD` and a downstream job (the legacy pipeline) picks it up? The answer determines what the activity needs to do.

### 5.2 P0 — Observability Before First Real Deletion

Must be in place before any May deletion run:
- [ ] Per-deletion Geneva metric with dimensions: `usecase_type`, `risk_tier`, `country`, `success|failure`
- [ ] Per-tenant activity log entry in `[fraud].[FRAUD_TENANT_ACTIVITY]` on both success and failure
- [ ] Alert: deletion failure rate > 5% in a 10-minute window → PagerDuty
- [ ] Alert: deletion throughput = 0 for > 30 minutes during an active batch run

### 5.3 P1 — Confirm `TENANT_ACTIONS_SCHD` Is Populated

Before bucket queries are meaningful, we need to know if scheduled deletion dates actually exist:
- [ ] Run Q-SCHD below to check how many Bucket A/B tenants have a DELETE row in the schedule table
- [ ] If the table is sparsely populated, understand why — was the scheduler turned off? Was this always manual?
- [ ] If dates are missing, determine how to backfill them (compute from block date + use case window)

### 5.4 P1 — VL / Blocker Handling in Code

- [ ] Hard check in `DeleteTenantActivity`: if `HAS_VL = TRUE`, throw a non-retryable `SkipDeletionException`, write to a manual review queue, do not mark as failed
- [ ] Confirm field name for "no deletion" flag in `[fraud].[FRAUD_TENANT_DELETE_DETAILS]` 
- [ ] T4 tenants require Commerce team sign-off — start this track in parallel in April, don't wait

### 5.5 P2 — Safety Gates

- [ ] Pre-delete check: verify tenant is in STATUS = 4 (BLOCKED) before calling deletion API — abort if not
- [ ] Dry-run mode: `--dry-run=true` logs what would be deleted without calling the API; required for first batch selection
- [ ] Circuit breaker: if deletion API returns consecutive 500s, stop the batch and alert

---

## 6. Testing Phases

### Phase 0 — Data Clarity (April 24–28)

**Goal:** Know the exact count and composition of every bucket before writing a line of code.

| Task | Done By |
|------|---------|
| Run all Q queries (Q-BUCKET, Q-SCHD, Q-STUCK, Q-VL, Q-TIER) on FAB DB | Apr 25 |
| Identify actual deletion API endpoint and contract | Apr 25 |
| Confirm whether `TENANT_ACTIONS_SCHD` is populated for Bucket A/B tenants | Apr 25 |
| Build working tenant list: SSID, bucket, risk tier, scheduled date, storage, VL flag | Apr 28 |
| Surface all T4 tenants; begin Commerce escalation for VL ones | Apr 28 |

**Exit criteria:** Exact count of Bucket A, B, C tenants. Exact T1/T2/T3/T4 split within A and B. Deletion API contract documented.

---

### Phase 1 — Engineering Fix (April 28 – May 9)

**Goal:** `DeleteTenantActivity` calls the real deletion API. All tests pass. Observability live.

| Task | Done By |
|------|---------|
| Implement real deletion API call in `DeleteTenantActivity` | May 2 |
| Add observability (metrics, per-tenant activity log) | May 2 |
| Unit tests: success, API failure, VL guard, idempotency | May 5 |
| Integration test in SDF ring (1 test tenant) | May 7 |
| Dry-run execution against 10 Bucket A T1 tenants — verify output logs correct | May 8 |
| Code review + approval | May 9 |

**Exit criteria:** SDF integration test passes. Dry-run log matches expected tenant list. Geneva metrics visible.

---

### Phase 2 — Micro Batch: First Real Deletions (May 12–16)

**Goal:** 10–25 Bucket A T1 tenants actually deleted in production. Confirm the system works.

**Tenant selection criteria:**
- Source: Bucket A (overdue deletion)
- Risk tier: T1 only (no VL, no paid history, storage < 1 TB, dev/trial SKU)
- Use case preference: `ABUSE-READONLY-BLOCK-DELETE_15DAYS` (most common, clearest intent)
- Confirm each tenant individually before triggering (manual eyeball check on tenant name, country, storage)

| Task | Done By |
|------|---------|
| Generate list of 25 T1 Bucket-A candidates using dry-run | May 12 |
| PM + Engg manual review of each candidate | May 12 |
| Trigger deletion via DTF for 10 tenants (first tranche) | May 13 |
| Verify: STATUS = 6, activity log populated, tenant actually gone in O365/SPO | May 14 |
| Trigger remaining 15 if first 10 clean | May 14 |
| Confirm Kusto TENANT_INFO shows `TENANT_STATUS = 'Deleted'` | May 15 |
| Post-mortem: document any failures, latency, unexpected behavior | May 16 |

**Pass/fail gate:** ≥ 90% of 25 tenants successfully deleted. Zero T4 touched. Zero FP. Latency < 2 hours per tenant.

---

### Phase 3 — Small Batch: Throughput Validation (May 19–23)

**Goal:** 100 tenants deleted. Throughput and error handling proven.

- **Composition:** 80 T1 + 20 T2 from Bucket A
- **New focus:** Validate that the pipeline handles failures gracefully (retry, dead-letter, does not stall)
- **Inject one controlled failure:** pick 1 tenant, temporarily block the deletion API call, confirm it routes to the dead-letter queue and does not cause cascading issues

| Task | Done By |
|------|---------|
| Select 100-tenant batch (T1+T2, Bucket A) | May 19 |
| Trigger batch deletion (one DTF orchestration per tenant) | May 20 |
| Monitor: deletion rate/hour, failure count, DTF queue depth | May 20–21 |
| Verify Kusto confirms deprovisioned status for completions | May 22 |
| Measure: avg latency trigger → STATUS=6 | May 22 |
| Document bottlenecks and fixes needed | May 23 |

**Pass/fail gate:** ≥ 98% success rate. Throughput ≥ 20 tenants/hour. Controlled failure routed correctly.

---

### Phase 4 — Medium Batch: Stress Test (May 26 – June 6)

**Goal:** 1,000 Bucket A tenants deleted. Pipeline tuned for FY27 scale.

- **Composition:** 700 T1 + 250 T2 + 50 T3 (each T3 manually pre-approved)
- **Target throughput:** ≥ 200 tenants/day

| Task | Done By |
|------|---------|
| Pre-batch: PM review and approval for all T3 tenants | May 26 |
| Trigger ~250/day over 4 days | May 26–29 |
| Monitor: API throttle events, DTF queue depth, storage reclaim in Kusto | Ongoing |
| Load test analysis: identify any bottlenecks at this scale | June 2 |
| Tune concurrency settings for FY27 full-scale wave | June 5 |
| Document: achieved throughput, failure rate, latency P50/P95 | June 6 |

**Pass/fail gate:** ≥ 98% success. No throttling > 1 hour. Pipeline certified at 200/day. Throughput metrics documented for FY27 capacity planning.

---

### Phase 5 — FY26 Block Coverage Sweep (June 9–27)

**Goal:** Every Bucket B tenant is in BLOCKED state (STATUS ≥ 4) by June 30.

This is **not a deletion phase** — it's a blocking phase. The goal is to ensure that every tenant whose scheduled deletion date falls by June 30 has completed the block step, so FY27 can start the deletion wave immediately on July 1.

| Task | Done By |
|------|---------|
| Run Bucket B count query; identify any not yet at STATUS 4 | June 9 |
| Identify which Bucket B tenants are still in ReadOnly (STATUS 2/3) | June 9 |
| Verify block is already scheduled for each — check `TENANT_ACTIONS_SCHD` | June 10 |
| For any with no scheduled block, investigate and manually trigger | June 10–20 |
| Final verification: 100% of Bucket B tenants at STATUS ≥ 4 | June 30 |

**Also during June:** Continue Bucket A deletions with remaining T2/T3 tenants if pipeline is certified.

**End state June 30:**
- All Bucket A: deleted (STATUS = 6) or T4 in progress with Commerce
- All Bucket B: blocked (STATUS ≥ 4), deletion scheduled for FY27
- All Bucket C: unchanged — natural pipeline running

---

## 7. Tenant Candidate List Schema

The working spreadsheet/table produced from queries should have these columns:

| Column | Source | Notes |
|--------|--------|-------|
| `SITE_SUBSCRIPTION_ID` | FRAUD_TENANT_DETAILS | Primary key |
| `OMS_TENANT_ID` | FRAUD_TENANT_DETAILS | For deletion API calls |
| `TENANT_NAME` | TENANT_DETAILS_RAW | Human-readable |
| `COUNTRY_CODE` | TENANT_DETAILS_RAW | For regional batching |
| `USECASE_TYPE` | FRAUD_TENANT_DETAILS | Determines deletion window |
| `CURRENT_STATUS` | FRAUD_TENANT_DETAILS | 4=Blocked, 5=DeleteInProgress, 8=InRemediation |
| `BLOCKED_DATE` | FRAUD_TENANT_ACTIVITY | Date block action completed |
| `SCHEDULED_DELETION_DATE` | TENANT_ACTIONS_SCHD | Target date |
| `DAYS_OVERDUE` | Computed | Positive = past scheduled date → Bucket A |
| `BUCKET` | Computed | A / B / C |
| `STORAGE_GB` | TENANT_DETAILS_RAW | TENANT_TOTAL_DISK_USED_GB |
| `HAS_VL` | TENANT_DETAILS_RAW | T4 flag |
| `HAS_EVER_PAID` | TENANT_DETAILS_RAW | T3 signal |
| `HAS_CHARITY_OFFER` | TENANT_DETAILS_RAW | T4 flag |
| `HAS_GOVERNMENT_OFFER` | TENANT_DETAILS_RAW | T4 flag |
| `RISK_TIER` | Computed | T1 / T2 / T3 / T4 |
| `FRAUD_REASON_CODE` | FRAUD_TENANT_DETAILS | Source signal |
| `APPROVED_BY` | Manual | Who approved this deletion |
| `BATCH_ID` | Manual | Which test phase batch |
| `DELETION_STATUS` | Tracked | Pending / Success / Failed / Skipped-VL |
| `ACTUAL_DELETION_DATE` | Tracked | Set when STATUS = 6 |
| `NOTES` | Manual | VL blocker detail, ICM link, stuck reason |

---

## 8. Known Risks & Mitigations

| Risk | Severity | Mitigation |
|------|----------|------------|
| VL tenant deleted without Commerce clearance → revenue/legal | Critical | T4 tier; hard VL check in `DeleteTenantActivity`; manual review gate |
| `TENANT_ACTIONS_SCHD` sparsely populated — can't determine scheduled dates | High | Run Q-SCHD first; backfill from block date + use case window if needed |
| Status 5 stuck tenants — unknown root cause | High | Run Q-STUCK; audit `FRAUD_TENANT_ACTIVITY`; may need TSCN investigation |
| Deletion API throttling at scale | High | Circuit breaker; cap at ≤ 250/day until Phase 4 certified |
| False positive deletions | High | Pre-delete dry-run; T1-first ordering; manual review for T3/T4 |
| Bucket C tenants accidentally pulled into deletion scope | Medium | Strict date filter in all queries; always verify before triggering batch |
| PITR window — delete after PITR → unrecoverable | Medium | Confirm SPO PITR window; ensure deletion is within recovery window |
| Tenant re-entry after deletion | Medium | Blocklist in place before deleting ring members |

---

## 9. Timeline Summary

```
Apr 24–28   │ Phase 0: Data Clarity
            │   Run all bucket queries, confirm TENANT_ACTIONS_SCHD health
            │   ▶ EXIT: Bucket A/B/C counts + T1-T4 split known
            │
Apr 28–May 9│ Phase 1: Engineering
            │   Wire up DeleteTenantActivity, observability, SDF integration test
            │   ▶ EXIT: Dry-run confirmed; SDF test passes
            │
May 12–16   │ Phase 2: Micro Batch (25 tenants, Bucket A T1)
            │   First real deletions in production
            │   ▶ EXIT: ≥ 90% success, pipeline proven
            │
May 19–23   │ Phase 3: Small Batch (100 tenants, Bucket A T1+T2)
            │   Throughput + error-handling validation
            │   ▶ EXIT: ≥ 98% success, ≥ 20/hour
            │
May 26–Jun 6│ Phase 4: Stress Test (1,000 tenants, Bucket A T1+T2+T3)
            │   Certify pipeline for FY27 scale
            │   ▶ EXIT: 200/day sustained, failure handling documented
            │
Jun 9–30    │ Phase 5: Block Coverage Sweep
            │   Ensure 100% of Bucket B tenants are BLOCKED by June 30
            │   Continue Bucket A T2/T3 deletions
            │   ▶ EXIT: All Bucket B at STATUS ≥ 4; FY27 ready
            │
Jul 1+      │ FY27: Full Deletion Wave (out of scope for this plan)
            │   All Bucket B + C tenants deleted on natural schedule
```

---

## 10. Open Questions (Phase 0 Must Answer)

1. **What is the real deletion API?** Direct TSCN call? O365 Admin API? Does `DeleteTenantActivity` need to call it, or write to `TENANT_ACTIONS_SCHD` for a downstream job?
2. **Is `TENANT_ACTIONS_SCHD` populated** for deletion-eligible tenants? If not — was it ever, and what broke?
3. **What caused Status 5 stalls?** 5,275 tenants stuck "Delete In-Progress" — did the old DTF activity fire and fail silently, or did it never fire?
4. **What is the exact `noDeletionBy` or VL-flag field** in `FRAUD_TENANT_DELETE_DETAILS`?
5. **Is there a test tenant** available in MSIT/SDF ring for Phase 1 integration test without touching a real customer?
6. **What is SPO PITR window?** Needed to confirm deletions are scheduled within recovery window.

---

## 11. Appendix — Schema Verification Queries

Run these first to ensure column names match before running bucket queries.

```sql
-- Confirm column names before relying on them
SELECT TOP 0 * FROM [fraud].[TENANT_ACTIONS_SCHD];
SELECT TOP 0 * FROM [fraud].[FRAUD_TENANT_DELETE_DETAILS];
SELECT TOP 5 * FROM [fraud].[FRAUD_TENANT_DELETE_APPROVER_DETAILS];

-- What deletion-adjacent activity types have been used?
SELECT DISTINCT ACTION_TYPE, STATUS, COUNT(*) AS CNT
FROM [fraud].[FRAUD_TENANT_ACTIVITY]
WHERE ACTION_TYPE LIKE '%DELETE%' OR ACTION_TYPE LIKE '%delete%'
GROUP BY ACTION_TYPE, STATUS
ORDER BY CNT DESC;

-- Verify use case types still in use
SELECT DISTINCT USECASE_TYPE, STATUS, COUNT(*) AS CNT
FROM [fraud].[FRAUD_TENANT_DETAILS]
WHERE STATUS IN (4, 5, 8)
GROUP BY USECASE_TYPE, STATUS
ORDER BY USECASE_TYPE, STATUS;
```

```sql
-- Tenants currently in Status 8 (In Remediation) with a deletion use case
SELECT
    ftd.SITE_SUBSCRIPTION_ID,
    ftd.OMS_TENANT_ID,
    raw.TENANT_NAME,
    raw.COUNTRY_CODE,
    ftd.USECASE_TYPE,
    ftd.STATUS,
    ftd.IDENTIFIED_DATE,
    ftd.APPROVAL_FLAG,
    ftd.FRAUD_REASON_CODE,
    raw.TENANT_TOTAL_DISK_USED_GB,
    raw.ODBDISKUSED_SUM_GB,
    raw.HAS_VL,
    raw.HAS_EVER_PAID,
    raw.HAS_CHARITY_OFFER,
    raw.HAS_GOVERNMENT_OFFER,
    raw.TENANT_CATEGORY,
    raw.TENANT_LEVEL,
    raw.LICENSES_ACQUIRED,
    raw.TOTAL_USERS,
    raw.UNLICENSED_USERS,
    -- Scheduled action info
    schd.ACTION_TYPE         AS SCHEDULED_ACTION,
    schd.SCHEDULED_DATE      AS SCHEDULED_DELETION_DATE,
    schd.ACTUAL_ACTION_DATE  AS ACTUAL_ACTION_DATE,
    -- Days overdue (if scheduled date already passed)
    DATEDIFF(DAY, schd.SCHEDULED_DATE, GETUTCDATE()) AS DAYS_OVERDUE
FROM [fraud].[FRAUD_TENANT_DETAILS] ftd
LEFT JOIN [fraud].[TENANT_DETAILS_RAW] raw
    ON ftd.SITE_SUBSCRIPTION_ID = raw.SITE_SUBSCRIPTION_ID
LEFT JOIN [fraud].[TENANT_ACTIONS_SCHD] schd
    ON ftd.SITE_SUBSCRIPTION_ID = schd.SITE_SUBSCRIPTION_ID
    AND schd.ACTION_TYPE = 'DELETE'
WHERE ftd.STATUS = 8   -- In Remediation
  AND ftd.USECASE_TYPE IN (
      'ABUSE-READONLY-BLOCK-DELETE_15DAYS',
      'ABUSE-READONLY-BLOCK-DELETE',
      'ABUSE-BLOCK-DELETE_15DAYS',
      'ABUSE-BLOCK-DELETE',
      'TYPE1',
      'E5DEV-OVERQUOTA',
      'DEPRECATE-WITH-DELETE'
  )
ORDER BY raw.TENANT_TOTAL_DISK_USED_GB DESC;
```

### Q2 — Stuck "Delete In-Progress" Tenants (Status 5)

```sql
-- Tenants stuck in Status 5 (Delete In-Progress) — these should have completed
SELECT
    ftd.SITE_SUBSCRIPTION_ID,
    ftd.OMS_TENANT_ID,
    raw.TENANT_NAME,
    raw.COUNTRY_CODE,
    ftd.USECASE_TYPE,
    ftd.IDENTIFIED_DATE,
    ftd.LAST_MODIFIED_DATE,
    raw.TENANT_TOTAL_DISK_USED_GB,
    raw.HAS_VL,
    raw.HAS_EVER_PAID,
    DATEDIFF(DAY, ftd.LAST_MODIFIED_DATE, GETUTCDATE()) AS DAYS_STUCK,
    act.LAST_ACTIVITY,
    act.LAST_ACTIVITY_STATUS
FROM [fraud].[FRAUD_TENANT_DETAILS] ftd
LEFT JOIN [fraud].[TENANT_DETAILS_RAW] raw
    ON ftd.SITE_SUBSCRIPTION_ID = raw.SITE_SUBSCRIPTION_ID
OUTER APPLY (
    SELECT TOP 1
        ACTION_TYPE AS LAST_ACTIVITY,
        STATUS      AS LAST_ACTIVITY_STATUS
    FROM [fraud].[FRAUD_TENANT_ACTIVITY]
    WHERE SITE_SUBSCRIPTION_ID = ftd.SITE_SUBSCRIPTION_ID
    ORDER BY CREATED_DATE DESC
) act
WHERE ftd.STATUS = 5   -- Delete In-Progress
ORDER BY DAYS_STUCK DESC;
```

### Q3 — Blocked Tenants with Deletion Use Cases Not Yet Promoted (Status 4)

```sql
-- Tenants that are BLOCKED (Status 4) but whose use case mandates deletion
-- These may have passed their scheduled deletion window
SELECT
    ftd.SITE_SUBSCRIPTION_ID,
    raw.TENANT_NAME,
    ftd.USECASE_TYPE,
    ftd.STATUS,
    ftd.LAST_MODIFIED_DATE AS BLOCKED_DATE,
    DATEDIFF(DAY, ftd.LAST_MODIFIED_DATE, GETUTCDATE()) AS DAYS_SINCE_BLOCK,
    -- Expected deletion window per use case
    CASE
        WHEN ftd.USECASE_TYPE LIKE '%_15DAYS'    THEN 15
        WHEN ftd.USECASE_TYPE = 'ABUSE-READONLY-BLOCK-DELETE' THEN 30
        WHEN ftd.USECASE_TYPE = 'TYPE1'           THEN 30
        WHEN ftd.USECASE_TYPE = 'E5DEV-OVERQUOTA' THEN 30
        ELSE NULL
    END AS EXPECTED_DELETE_AFTER_DAYS,
    raw.TENANT_TOTAL_DISK_USED_GB,
    raw.HAS_VL,
    raw.HAS_EVER_PAID,
    raw.COUNTRY_CODE,
    schd.SCHEDULED_DATE AS SCHEDULED_DELETION_DATE,
    schd.ACTUAL_ACTION_DATE
FROM [fraud].[FRAUD_TENANT_DETAILS] ftd
LEFT JOIN [fraud].[TENANT_DETAILS_RAW] raw
    ON ftd.SITE_SUBSCRIPTION_ID = raw.SITE_SUBSCRIPTION_ID
LEFT JOIN [fraud].[TENANT_ACTIONS_SCHD] schd
    ON ftd.SITE_SUBSCRIPTION_ID = schd.SITE_SUBSCRIPTION_ID
    AND schd.ACTION_TYPE = 'DELETE'
WHERE ftd.STATUS = 4   -- Block Completed
  AND ftd.USECASE_TYPE IN (
      'ABUSE-READONLY-BLOCK-DELETE_15DAYS',
      'ABUSE-READONLY-BLOCK-DELETE',
      'ABUSE-BLOCK-DELETE_15DAYS',
      'ABUSE-BLOCK-DELETE',
      'E5DEV-OVERQUOTA',
      'DEPRECATE-WITH-DELETE'
  )
  -- Only include tenants past their expected delete window
  AND DATEDIFF(DAY, ftd.LAST_MODIFIED_DATE, GETUTCDATE()) >= 
      CASE
          WHEN ftd.USECASE_TYPE LIKE '%_15DAYS'    THEN 15
          WHEN ftd.USECASE_TYPE = 'ABUSE-READONLY-BLOCK-DELETE' THEN 30
          WHEN ftd.USECASE_TYPE = 'TYPE1'           THEN 30
          ELSE 30
      END
ORDER BY DAYS_SINCE_BLOCK DESC;
```

### Q4 — VL / High-Risk Blockers (T4 Tenants — Do Not Auto-Delete)

```sql
-- Tenants flagged for deletion but carrying high-risk attributes
-- These need explicit human review before proceeding
SELECT
    ftd.SITE_SUBSCRIPTION_ID,
    raw.TENANT_NAME,
    raw.COUNTRY_CODE,
    ftd.USECASE_TYPE,
    ftd.STATUS,
    raw.TENANT_TOTAL_DISK_USED_GB,
    raw.HAS_VL,
    raw.HAS_EVER_PAID,
    raw.HAS_CHARITY_OFFER,
    raw.HAS_GOVERNMENT_OFFER,
    raw.LICENSES_ACQUIRED,
    raw.TOTAL_USERS,
    raw.NONTRIAL_AVAILABLE_UNITS,
    -- Check for open FP actions
    (SELECT COUNT(*) FROM [fraud].[APPROVER_COMMENTS] 
     WHERE SITE_SUBSCRIPTION_ID = ftd.SITE_SUBSCRIPTION_ID) AS FP_COMMENT_COUNT
FROM [fraud].[FRAUD_TENANT_DETAILS] ftd
LEFT JOIN [fraud].[TENANT_DETAILS_RAW] raw
    ON ftd.SITE_SUBSCRIPTION_ID = raw.SITE_SUBSCRIPTION_ID
WHERE ftd.STATUS IN (4, 5, 8)
  AND ftd.USECASE_TYPE IN (
      'ABUSE-READONLY-BLOCK-DELETE_15DAYS',
      'ABUSE-READONLY-BLOCK-DELETE',
      'ABUSE-BLOCK-DELETE_15DAYS'
  )
  AND (
      raw.HAS_VL = 'TRUE'
      OR raw.HAS_CHARITY_OFFER = 'TRUE'
      OR raw.HAS_GOVERNMENT_OFFER = 'TRUE'
      OR raw.LICENSES_ACQUIRED > 500
  )
ORDER BY raw.TENANT_TOTAL_DISK_USED_GB DESC;
```

### Q5 — Risk Tier Summary (Run After Q1 to Size Each Tier)

```sql
-- Summarize the deletion backlog by risk tier
WITH candidates AS (
    SELECT
        ftd.SITE_SUBSCRIPTION_ID,
        ftd.USECASE_TYPE,
        raw.TENANT_TOTAL_DISK_USED_GB,
        raw.HAS_VL,
        raw.HAS_EVER_PAID,
        raw.HAS_CHARITY_OFFER,
        raw.HAS_GOVERNMENT_OFFER,
        raw.TENANT_LEVEL,
        CASE
            WHEN raw.HAS_VL = 'TRUE' 
              OR raw.HAS_CHARITY_OFFER = 'TRUE'
              OR raw.HAS_GOVERNMENT_OFFER = 'TRUE'
              OR raw.LICENSES_ACQUIRED > 500        THEN 'T4-CRITICAL'
            WHEN ISNULL(raw.TENANT_TOTAL_DISK_USED_GB, 0) > 10000  -- > 10 TB
              OR raw.HAS_EVER_PAID = 'TRUE'         THEN 'T3-HIGH'
            WHEN ISNULL(raw.TENANT_TOTAL_DISK_USED_GB, 0) BETWEEN 1000 AND 10000 THEN 'T2-MEDIUM'
            ELSE                                         'T1-LOW'
        END AS RISK_TIER
    FROM [fraud].[FRAUD_TENANT_DETAILS] ftd
    LEFT JOIN [fraud].[TENANT_DETAILS_RAW] raw
        ON ftd.SITE_SUBSCRIPTION_ID = raw.SITE_SUBSCRIPTION_ID
    WHERE ftd.STATUS IN (4, 5, 8)
      AND ftd.USECASE_TYPE IN (
          'ABUSE-READONLY-BLOCK-DELETE_15DAYS',
          'ABUSE-READONLY-BLOCK-DELETE',
          'ABUSE-BLOCK-DELETE_15DAYS',
          'ABUSE-BLOCK-DELETE'
      )
)
SELECT
    RISK_TIER,
    COUNT(*) AS TENANT_COUNT,
    SUM(TENANT_TOTAL_DISK_USED_GB) / 1024.0 / 1024.0 AS STORAGE_PB,
    SUM(CASE WHEN HAS_VL = 'TRUE' THEN 1 ELSE 0 END) AS VL_COUNT,
    SUM(CASE WHEN HAS_EVER_PAID = 'TRUE' THEN 1 ELSE 0 END) AS PAID_COUNT
FROM candidates
GROUP BY RISK_TIER
ORDER BY RISK_TIER;
```

---

## 5. Engineering Work Required

### 5.1 P0 — Fix DeleteTenantActivity (Highest Priority)

`DeleteTenantActivity.cs` must call the real tenant deletion API. Current code is a mock.

**Work items:**
- [ ] Identify the actual deletion API endpoint (TSCN endpoint? O365 admin? SPO decommission API?)
- [ ] Add the HTTP client / service reference to `FABTenantService.DTF.Activities.csproj`
- [ ] Implement retry logic (the existing DTF retry via `RetryOptions` can handle transient failures)
- [ ] Add explicit logging of: attempt time, API response, tenant ID, success/failure
- [ ] Update `FRAUD_TENANT_DETAILS.STATUS` to 6 (Delete Completed) on success, back to 8 on failure
- [ ] Write unit tests: mock the deletion API, verify status transitions
- [ ] Write integration test: run against test ring tenant, verify tenant is actually gone

**Key question to answer before starting:** Does deletion go through `TENANT_ACTIONS_SCHD` and then a downstream job picks it up, or does the DTF activity call TSCN directly? This determines the implementation approach.

### 5.2 P0 — Observability Instrumentation

Before deleting a single tenant in production, we must have:
- [ ] Per-deletion success/failure metric (Geneva counter + dimension: `usecase_type`, `risk_tier`, `country`)
- [ ] Deletion latency histogram (time from scheduled → actual delete)
- [ ] Dead-letter queue or table for stuck/failed deletion attempts
- [ ] Alert: if deletion failure rate exceeds 5% in any 10-minute window → PagerDuty
- [ ] Alert: if deletion throughput drops to 0 for > 30 minutes during a batch run

### 5.3 P1 — Scheduled Deletion Date Computation

The `TENANT_ACTIONS_SCHD` table tracks scheduled actions. Confirm the following for each deletion-eligible use case:

| Use Case | Expected Delete Trigger |
|----------|------------------------|
| ABUSE-READONLY-BLOCK-DELETE_15DAYS | 15 days after Block action recorded |
| ABUSE-READONLY-BLOCK-DELETE | 30 days after Block action recorded |
| ABUSE-BLOCK-DELETE_15DAYS | 15 days after Block action recorded |
| E5DEV-OVERQUOTA | 30 days after block (day 62 from first notify) |

- [ ] Query `TENANT_ACTIONS_SCHD` to confirm scheduled dates are populated for all Status 8 tenants
- [ ] Build a view/query that shows: tenantId, scheduledDeletionDate, daysOverdue, riskTier

### 5.4 P1 — VL / Blocker Handling

- [ ] Identify all T4 tenants from Q4 above
- [ ] For each `HAS_VL = TRUE` tenant: file a cancellation request with Commerce team before deleting
- [ ] Confirm "no deletion" flag mechanism in `FRAUD_TENANT_DELETE_DETAILS` table (field name TBD — confirm with DB schema)
- [ ] Add check in `DeleteTenantActivity`: if tenant has active VL, throw `SkipDeletionException` → route to manual review queue, do NOT retry

### 5.5 P2 — Idempotency and Safety Gates

- [ ] `DeleteTenantActivity` must be idempotent: calling it twice on an already-deleted tenant should be a no-op, not an error
- [ ] Pre-delete check: verify tenant is currently in BLOCKED state (status 4) before issuing delete call — abort if not
- [ ] Circuit breaker: if the deletion API returns 500s or throttles, back off and stop the batch (don't retry the entire batch immediately)
- [ ] Dry-run mode flag: `--dry-run=true` → logs all tenants that *would* be deleted without actually calling the API

---

## 6. Testing Phases

### Phase 0 — Data Clarity (April 24–28)
**Goal:** Crystal-clear picture of every tenant that needs deletion before any code is written.

| Task | Owner | Done By |
|------|-------|---------|
| Run Q1–Q5 on FAB DB, share results | Engg | Apr 25 |
| Identify actual deletion API endpoint + contract | Engg | Apr 25 |
| Build deletion candidate spreadsheet: SSID, tier, scheduledDate, storage, flags | PM+Engg | Apr 28 |
| Identify all T4 (VL/high-risk) tenants; escalate to Commerce | PM | Apr 28 |
| Confirm `TENANT_ACTIONS_SCHD` is populated for Status 8 tenants | Engg | Apr 28 |

**Exit criteria:** Exact count of T1/T2/T3/T4 tenants known. Deletion API contract documented.

---

### Phase 1 — Pipeline Fix & Unit Tests (April 28 – May 9)
**Goal:** `DeleteTenantActivity` actually calls the deletion API. All unit/integration tests pass.

| Task | Owner | Done By |
|------|-------|---------|
| Implement `DeleteTenantActivity` with real API call | Engg | May 2 |
| Add observability (metrics, logging) | Engg | May 2 |
| Unit tests: success path, API failure, VL blocker, idempotency | Engg | May 5 |
| Integration test in LOCAL/DEV: delete 1 test tenant | Engg | May 5 |
| Integration test in SDF: delete 1 test tenant | Engg | May 7 |
| Code review + approval | Engg lead | May 9 |

**Exit criteria:** Integration test in SDF succeeds end-to-end. Metrics visible in Geneva. Zero flaky tests.

---

### Phase 2 — Micro Batch Test (May 12–16) — MSIT
**Goal:** Prove the pipeline works at small scale with real fraud tenants.

- **Batch size:** 10–25 tenants, all T1 (lowest risk — dev tenants, < 1 TB, no VL, no paid history)
- **Source:** From Q1 results, pick tenants where `USECASE_TYPE = 'ABUSE-READONLY-BLOCK-DELETE_15DAYS'`, `HAS_VL = FALSE`, `TENANT_TOTAL_DISK_USED_GB < 100`, `HAS_EVER_PAID = FALSE`
- **Environment:** MSIT → Production (MSIT ring points to real production deletion for actual tenants)

| Task | Done By |
|------|---------|
| Select 10–25 T1 tenants from candidate list | May 12 |
| Manual review of each tenant before triggering | May 12 |
| Trigger deletion via DTF orchestration for each tenant | May 13 |
| Verify: STATUS = 6, activity log recorded, tenant actually deprovisioned in O365 | May 14 |
| Confirm storage reclaimed (Kusto TENANT_INFO: TENANT_STATUS = 'Deleted') | May 15 |
| Post-mortem and pipeline adjustments | May 16 |

**Pass/fail gate:** ≥ 95% of 10–25 tenants successfully deleted. Zero T4 tenants touched. No FP.

---

### Phase 3 — Small Batch (May 19–23)
**Goal:** Scale to 100 tenants, validate throughput and error handling.

- **Batch size:** 100 tenants
- **Composition:** 80 T1 + 20 T2
- **New tests:** Inject 1 artificial failure (tenant blocked by circuit breaker) to verify retry/DLQ path

| Task | Done By |
|------|---------|
| Select 100-tenant batch from candidate list (T1+T2) | May 19 |
| Trigger batch deletion (DTF fan-out, one orchestration per tenant) | May 20 |
| Monitor: deletion rate/hour, failure count, alert trigger validation | May 20–21 |
| Verify Kusto confirms tenants deprovisioned | May 22 |
| Measure: avg latency from trigger → STATUS=6 | May 22 |
| Address any issues found | May 23 |

**Pass/fail gate:** ≥ 98% success rate. Throughput ≥ 20 tenants/hour sustained. No false positives.

---

### Phase 4 — Medium Batch Stress Test (May 26 – June 6)
**Goal:** Stress test at 1,000 tenants. Confirm the pipeline doesn't degrade or throttle.

- **Batch size:** 1,000 tenants
- **Composition:** 700 T1 + 250 T2 + 50 T3 (T3 with manual pre-approval)
- **Goal throughput:** ≥ 200 tenants/day

| Task | Done By |
|------|---------|
| Pre-batch review: confirm all T3 tenants reviewed by PM | May 26 |
| Trigger 250/day over 4 days | May 26–29 |
| Monitor for: API throttling, DTF queue depth, storage reclaim rate | Ongoing |
| Validate daily: Kusto TENANT_INFO shows STATUS='Deleted' for completed tenants | Daily |
| Load test analysis: identify bottlenecks (DTF worker count? API rate limits?) | June 2 |
| Tune batch size and concurrency for full rollout | June 5 |

**Pass/fail gate:** ≥ 98% success rate. No throttling errors sustained for > 1 hour. T3 deletes manually verified.

---

### Phase 5 — Full Rollout (June 9–27)
**Goal:** Delete all eligible tenants in remediation by June 27.

**Tentative weekly schedule:**

| Week | Dates | Tenants | Notes |
|------|-------|---------|-------|
| Week 1 | June 9–13 | 5,000 | Remaining T1 |
| Week 2 | June 16–20 | 10,000 | T1 + T2 |
| Week 3 | June 23–27 | Remaining | T2 + T3; T4 handled separately |

- T4 (VL/high-risk) tenants: each requires explicit sign-off. Target completion by June 27 but this is a separate track with Commerce team.
- Stuck Status 5 tenants: diagnose and recover in parallel. These may need manual intervention via TSCN.

**Daily monitoring during rollout:**
- Deletions completed today (target: ≥ 500/day)
- Failure count and reason
- Storage reclaimed (Kusto)
- Any new FP reports from customers (ICM watch)

---

## 7. Tenant Candidate List Schema

The output of Q1–Q5 above should be materialized into a working spreadsheet/table with these columns:

| Column | Source | Notes |
|--------|--------|-------|
| `SITE_SUBSCRIPTION_ID` | FRAUD_TENANT_DETAILS | Primary key |
| `OMS_TENANT_ID` | FRAUD_TENANT_DETAILS | For O365 API calls |
| `TENANT_NAME` | TENANT_DETAILS_RAW | Human-readable name |
| `COUNTRY_CODE` | TENANT_DETAILS_RAW | For regional rollout sequencing |
| `USECASE_TYPE` | FRAUD_TENANT_DETAILS | Deletion window calculation |
| `CURRENT_STATUS` | FRAUD_TENANT_DETAILS | 4=Blocked, 5=DeleteInProgress, 8=InRemediation |
| `IDENTIFIED_DATE` | FRAUD_TENANT_DETAILS | When originally flagged |
| `BLOCKED_DATE` | FRAUD_TENANT_ACTIVITY | When block action completed |
| `SCHEDULED_DELETION_DATE` | TENANT_ACTIONS_SCHD | Computed target date |
| `DAYS_OVERDUE` | Computed | Positive = past scheduled date |
| `ACTUAL_DELETION_DATE` | To be filled | Set when STATUS = 6 |
| `STORAGE_GB` | TENANT_DETAILS_RAW | TENANT_TOTAL_DISK_USED_GB |
| `HAS_VL` | TENANT_DETAILS_RAW | T4 flag |
| `HAS_EVER_PAID` | TENANT_DETAILS_RAW | T3 signal |
| `HAS_CHARITY_OFFER` | TENANT_DETAILS_RAW | T4 flag |
| `HAS_GOVERNMENT_OFFER` | TENANT_DETAILS_RAW | T4 flag |
| `RISK_TIER` | Computed from Q5 | T1/T2/T3/T4 |
| `FRAUD_REASON_CODE` | FRAUD_TENANT_DETAILS | Source signal |
| `APPROVED_BY` | Manual | Who approved this deletion |
| `BATCH_ID` | Manual | Which test/rollout batch |
| `DELETION_STATUS` | Tracked | Pending / Success / Failed / Skipped |
| `NOTES` | Manual | VL blocker details, ICM links, etc. |

---

## 8. Known Risks & Mitigations

| Risk | Severity | Mitigation |
|------|----------|------------|
| `DeleteTenantActivity` stub — no real deletion API | **CRITICAL — blocks all work** | P0 fix in Phase 1 |
| VL tenants accidentally deleted → revenue/legal issue | Critical | Q4 query; T4 tier; hard check in activity code |
| Deletion API throttling at scale | High | Circuit breaker; phase batches at ≤ 500/day initially |
| Status 5 stuck tenants — unknown root cause | High | Audit `FRAUD_TENANT_ACTIVITY` for each; may need TSCN ticket |
| False positive deletions (legitimate tenant deleted) | High | Pre-delete manual review for T3/T4; VL check in code |
| PITR window: deletes must stay within PITR to be fully recoverable | Medium | Confirm SPO PITR window (typically 14–30 days); schedule deletions within it |
| Tenant re-entry after deletion | Medium | Blocklist updated before deleting; re-entry prevention active |
| June 27 deadline slip if Phase 1 delays | Medium | Parallel-track T4 VL review with Commerce now; don't wait |

---

## 9. Timeline Summary

```
April 24–28  │ Phase 0: Data Clarity — run all queries, size every tier
             │ ▶ EXIT: Exact tenant list with risk tiers + deletion API identified
             │
April 28–May 9 │ Phase 1: Engineering — fix DeleteTenantActivity, tests, observability
             │ ▶ EXIT: Integration test passes in SDF; metrics visible
             │
May 12–16   │ Phase 2: Micro Batch (10–25 tenants) — first real deletions
             │ ▶ EXIT: ≥ 95% success, pipeline proven
             │
May 19–23   │ Phase 3: Small Batch (100 tenants) — throughput validation
             │ ▶ EXIT: ≥ 98% success, ≥ 20/hour throughput
             │
May 26–Jun 6│ Phase 4: Medium Batch (1,000 tenants) — stress test
             │ ▶ EXIT: ≥ 98% success, tuned for 500/day
             │
Jun 9–27    │ Phase 5: Full Rollout (~21,767 + 5,275 tenants)
             │ ▶ EXIT: All eligible tenants deleted, T4 handled separately
```

---

## 10. Open Questions (To Be Answered in Phase 0)

1. **What is the actual tenant deletion API?** Is it a direct call to TSCN? O365 Admin API (`DELETE /v1.0/directory/deleteditems/{id}`)? A queue-based mechanism via `TENANT_ACTIONS_SCHD`?
2. **What does "deleted" mean in O365 terms?** Soft delete (30-day recoverable) vs hard delete? Does SPO data persist in PITR after tenant deletion?
3. **Is `TENANT_ACTIONS_SCHD` already populated** for all Status 8 tenants? If yes, is there a downstream job that reads it and calls the deletion API — and is that job working?
4. **What is the exact failure mode for stuck Status 5 tenants?** Did the DTF activity fire but API returned an error? Did DTF never schedule the delete activity?
5. **For VL tenants with `noDeletionBy` flag**: what is the exact field name in the DB? How do we clear it after Commerce cancels the subscription?
6. **What is PITR window for SPO?** Confirm maximum days after tenant deletion when data is still recoverable (needed for scheduling deletions safely).
7. **Is there a test tenant available in MSIT ring** that we can use for Phase 2 without impacting real customers?

---

## 11. Appendix — TENANT_ACTIONS_SCHD Schema (To Verify)

Before using `TENANT_ACTIONS_SCHD` in queries, run this to confirm column names:
```sql
SELECT TOP 0 * FROM [fraud].[TENANT_ACTIONS_SCHD];
-- Also check what FRAUD_TENANT_DELETE_DETAILS looks like:
SELECT TOP 0 * FROM [fraud].[FRAUD_TENANT_DELETE_DETAILS];
SELECT TOP 5 * FROM [fraud].[FRAUD_TENANT_DELETE_APPROVER_DETAILS];
```

And confirm the deletion-adjacent activity types in the activity log:
```sql
SELECT DISTINCT ACTION_TYPE, STATUS, COUNT(*) AS CNT
FROM [fraud].[FRAUD_TENANT_ACTIVITY]
GROUP BY ACTION_TYPE, STATUS
ORDER BY CNT DESC;
```

This tells you exactly what action types have been logged, which ones have succeeded/failed, and whether the deletion action type name matches what the DTF activity uses.
