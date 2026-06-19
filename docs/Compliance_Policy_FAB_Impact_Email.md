**Subject:** Compliance policies blocking FAB deletion — need telemetry + workarounds

---

Hey team,

Wanted to raise something I've been digging into around our enforcement failures. TL;DR: compliance holds (retention policies, labels, preservation locks) are silently blocking tenant deletion and we have no visibility into it.

**What's happening**

When a tenant has an active retention policy or preservation lock, SharePoint keeps content in a hidden Preservation Hold Library (PHL). Our enforcement pipeline hits this, gets a failure, and retries the next day. Same result. We've seen tenants fail 49 times over 8 days with zero escalation — just infinite retry.

The kicker: our `EnforcementEvent` telemetry only tells us *that* it failed. No reason code. No distinction between "compliance hold blocked this" vs "timeout" vs "site already gone." We're flying blind.

**Why this matters for trial/dev tenants**

E5 Developer tenants (free, 25 licenses, 1.27TB quota) get **full Purview compliance** — same as paid E5. That means a bad actor can:
- Sign up for a free E5 Dev trial
- Upload whatever they want
- Slap a 10-year retention policy with **Preservation Lock** (irreversible — even we can't remove it)
- FAB flags the tenant, enforcement tries to delete, fails forever

From EnforcementEvent data: 10,515 E5 Dev trial tenants have failed every single enforcement attempt in the last 30 days. These are all free, never-paid tenants.

**What we need**

Short-term (May-June):
1. Add a `failureReason` to EnforcementEvent — even a basic categorization (ComplianceHold / Timeout / Other) would be a massive improvement
2. Pre-flight check: query compliance state before attempting deletion. If Preservation Lock exists, don't bother retrying — route differently
3. Detection rule: trial tenant + Preservation Lock within 7 days of creation = fraud signal
4. Escalation logic: after 5 consecutive failures, stop retrying and flag for review

Longer-term:
5. Work with Purview to disable Preservation Lock for trial SKUs (no legitimate reason a free trial needs SEC 17a-4 immutability)
6. Two-phase enforcement: Phase 1 disables uploads/sharing/access (kills abuse value), Phase 2 waits for holds to expire then deletes
7. Cap retention duration for trial tenants (e.g., max 1 year)

**Asks**

- Engineering: Can we get failure reason telemetry into `EnforcementEvent` this sprint?
- PM: Do we have (or can we get) an API to check compliance state pre-enforcement?
- CELA: Stance on restricting Preservation Lock for trial/dev SKUs?

Happy to share the Kusto queries and specific tenant examples. Let me know if you want to sync on this.

Thanks
