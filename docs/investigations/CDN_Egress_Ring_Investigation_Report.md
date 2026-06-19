# INV-014 Addendum: READONLY Does Not Stop CDN Egress

| Field | Value |
|-------|-------|
| **Author** | Varun V |
| **Date** | April 19, 2026 |
| **Parent Investigation** | INV-014 (FAMILIA CONFEITAR) |
| **Finding Type** | Remediation effectiveness gap |

---

## Finding

While validating the proposed CDN Score rule against SpoProd `RequestUsage` (query K2a, 7-day lookback on April 19), the top 26 high-egress tenants turned out to be INV-014's FAMILIA CONFEITAR ring — all `READONLY_SUCCESS` since **April 8, 2026**.

Despite 11 days in READONLY, these tenants are still serving **~1.53 PB/week** in downloads (zero ingress). READONLY only prevents new uploads — existing stored content (~50–76 TB per tenant, ~1.6 PB ring total) remains fully downloadable.

## Impact (post-READONLY only)

| Metric | Value |
|--------|-------|
| Egress since READONLY | ~2.4 PB (11 days × 1.53 PB/7) |
| Estimated bandwidth cost | ~$190K |
| Pipeline state | Stalled at step 1 of `ABUSE-READONLY-BLOCK-DELETE` |

## Action Required

1. **Escalate to Block/Delete** — READONLY is ineffective for CDN/egress abuse. Content must be purged or access disabled.
2. **Investigate pipeline stall** — why hasn't `ABUSE-READONLY-BLOCK-DELETE` progressed past step 1 in 11 days?
3. **Policy recommendation** — for egress-dominant abuse (high reads, zero writes, zero active users), skip READONLY and go directly to Block.

## Evidence Queries

K2a (CDN dry-run) and K2b (fingerprint) in [`docs/kustoqueries_newrules/new_rule_validation_queries.md`](../kustoqueries_newrules/new_rule_validation_queries.md). Raw data in `K2aV2.csv` and `K2b.csv`.

## Relevance to CDN Score Rule

This validates the proposed rule — it correctly surfaces active CDN abuse regardless of remediation status. The rule should include a post-remediation re-check: if egress persists 48h after READONLY, auto-escalate.
