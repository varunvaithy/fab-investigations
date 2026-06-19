# CSS Triage Guide — FAB Tenant Remediation Cases

> **INTERNAL USE ONLY — DO NOT SHARE WITH CUSTOMERS**
> Version 1.0 | April 2026

---

## Quick Reference: The 60-Second Triage

```
┌─────────────────────────────────────────────────────────────────┐
│  STEP 1: Extract Tenant ID from ICM description                │
│  STEP 2: Look up in FAB Dashboard → note Reason Code + Status  │
│  STEP 3: Check ISS flags (S500/S2200)                          │
│     ├── S500 or S2200 = TRUE → STOP → Tier 4 (Escalate Now)   │
│     └── Both FALSE → continue                                  │
│  STEP 4: Find Reason Code in the Bucket Map (Section 3 below)  │
│  STEP 5: Bucket tells you the Confidence Tier                  │
│  STEP 6: Follow the action for that tier (Section 2 below)     │
└─────────────────────────────────────────────────────────────────┘
```

---

## 1. Confidence Tiers — What They Mean for You

| Tier | Label | What It Means | Your Authority |
|------|-------|---------------|----------------|
| **T1** | **Very High Confidence** | Detection signals are unambiguous. Near-zero false positive rate historically. | **You can resolve and close.** Use the appropriate response template. No FAB involvement needed. |
| **T2** | **High Confidence** | Strong detection signals with rare edge cases. May involve investigated fraud rings or validated automated detection. | **You can resolve and close** with one quick verification (see checklist). If anything looks unusual, escalate. |
| **T3** | **Medium Confidence** | Detection based on behavioral models or pattern matching. Small but real chance of false positive, especially for non-English tenants. | **Verify** using the checklist. If customer provides credible justification, **escalate to FAB** for review. If no pushback, close with template. |
| **T4** | **Escalate Immediately** | Large/enterprise tenants (S500/S2200), sensitive cases, or situations requiring engineering judgment. | **Do NOT resolve.** Acknowledge receipt to customer, escalate to FAB immediately. |

---

## 2. Tier Actions — Exactly What to Do

### Tier 1: Very High Confidence → Resolve & Close

**When you see this tier, the detection is definitive.**

1. Acknowledge the customer's inquiry (**Template: ACKNOWLEDGE**)
2. Respond with the appropriate upheld template (**Template: UPHELD-[BUCKET]**)
3. Close the ICM

**No need to contact FAB engineering.**

Applies to Reason Codes in Buckets: **A1, A2, D1, F1** (see Section 3)

---

### Tier 2: High Confidence → Quick Verify, Then Resolve

**Strong signals, but do one quick check before closing.**

Quick Verification Checklist:
- [ ] Is the customer providing any specific business justification? (e.g., "We're a video production company" for streaming)
- [ ] Does the tenant have a custom domain (not just `.onmicrosoft.com`)?
- [ ] Is the customer a known partner/MSP? (Check if they mention a Partner ID)

**If all clear** → Respond with **Template: UPHELD-[BUCKET]** → Close
**If customer gives credible justification OR is a partner** → Escalate to FAB with note

Applies to Reason Codes in Buckets: **A3, B1, B2, C1, E1** (see Section 3)

---

### Tier 3: Medium Confidence → Verify, May Need FAB

**There's a real chance this could be a false positive. Be careful.**

1. Acknowledge the customer (**Template: ACKNOWLEDGE**)
2. Run through the verification checklist from Tier 2
3. **If customer provides any of the following**, escalate to FAB:
   - Business registration or institutional documentation
   - Specific explanation of their storage/usage needs
   - Claims they are an MSP, partner, or IT services provider
   - Non-English tenant name that could be legitimate in their locale
4. **If customer provides no justification and does not respond within 5 business days** → Respond with **Template: UPHELD-GENERAL** → Close

Applies to Reason Codes in Buckets: **C2, C3, E2** (see Section 3)

---

### Tier 4: Escalate Immediately → Do NOT Resolve

**These require FAB engineering review. Your only job is acknowledgment and routing.**

Triggers:
- **S500 = TRUE** (tenant has 500+ users) — regardless of reason code
- **S2200 = TRUE** (tenant has 2200+ users) — regardless of reason code
- **Paid/Enterprise SKU** where customer is actively disputing (M365 E3/E5, SPO Plan 1/2)
- Customer claims legal action or regulatory complaint
- Customer is a government entity or educational institution with verifiable credentials
- You are unsure about the tier after checking all the above

Action:
1. Acknowledge the customer (**Template: ACKNOWLEDGE**)
2. Create a new ICM to FAB **or** tag the existing ICM with `[FAB-ESCALATION]`
3. Include in your escalation note:
   - Tenant ID
   - Reason Code
   - S500/S2200 status
   - Customer's stated justification (verbatim)
   - Your assessment of why this needs FAB review
4. Respond to customer with **Template: UNDER-REVIEW**
5. **Do not close the ICM.** FAB will resolve.

Applies to: **Any case with S500/S2200 flags**, Bucket **F2**, and **any case you're unsure about**

---

## 3. Reason Code → Bucket → Tier Mapping

### Bucket A: Content & Application Violations

Tenants detected using Microsoft 365 services for hosting, distributing, or processing prohibited content or running unauthorized applications.

| Bucket | Tier | Reason Codes | Internal Description | CSS Action |
|--------|------|-------------|----------------------|------------|
| **A1** | T1 | 62, 63, 71 | Ransomware, Crypto mining, Malware | Resolve: UPHELD-CONTENT |
| **A2** | T1 | 65, 67, 83, 84 | Adult content, Non-paid hosting video/games/ISO, >10TB streaming | Resolve: UPHELD-CONTENT |
| **A3** | T2 | 64, 66, 68 | CN dev hosting, Paid tenant hosting, E3 Dev bad tenants | Verify, then: UPHELD-CONTENT |

---

### Bucket B: Storage & Bandwidth Anomalies

Tenants consuming storage or bandwidth dramatically beyond what their license tier supports, without corresponding legitimate user activity.

| Bucket | Tier | Reason Codes | Internal Description | CSS Action |
|--------|------|-------------|----------------------|------------|
| **B1** | T2 | 0, 1, 6, 72 | High streaming, High ODB storage, A1 high storage, P99.99 Egress | Verify, then: UPHELD-USAGE |
| **B2** | T2 | 47, 79, 92 | E5Dev over-quota, Detection Automation streaming, Free-level streaming | Verify, then: UPHELD-USAGE |

---

### Bucket C: Account & Identity Integrity

Tenants flagged for patterns in how they were registered, named, or configured that indicate non-genuine or synthetic provisioning.

| Bucket | Tier | Reason Codes | Internal Description | CSS Action |
|--------|------|-------------|----------------------|------------|
| **C1** | T2 | 26, 36, 39, 40 | MSFT-similar name, Suspicious org names, Known pattern, Impersonation | Verify, then: UPHELD-ACCOUNT |
| **C2** | T3 | 11, 12, 38, 69 | Gibberish names, No-space names, Gibberish email, Gibberish sign-in | Verify carefully (non-English risk): UPHELD-ACCOUNT |
| **C3** | T3 | 35, 37, 52, 59 | Suspicious contacts, Account mismatch, Credential misuse, Fictitious persona | Verify: UPHELD-ACCOUNT |

---

### Bucket D: Licensing & Subscription Circumvention

Tenants identified as part of coordinated schemes to circumvent per-user licensing or exploit subscription tiers beyond their intended scope.

| Bucket | Tier | Reason Codes | Internal Description | CSS Action |
|--------|------|-------------|----------------------|------------|
| **D1** | T1 | 5, 70, 82, 86, 87, 88, 91 | Clusters, Multiplexing (all variants), EMEA multiplexing, Free-level multiplexing | Resolve: UPHELD-LICENSING |
| **D2** | T2 | 10, 22, 23, 27, 28, 34, 50, 56 | E5 Dev, Named patterns, ML clusters, Non-academic, Unauthorized renewal, EDU subscription | Verify, then: UPHELD-LICENSING |

---

### Bucket E: Automated & Model-Driven Detection

Tenants flagged by automated detection systems including ML models, AI agents, and rule-based engines.

| Bucket | Tier | Reason Codes | Internal Description | CSS Action |
|--------|------|-------------|----------------------|------------|
| **E1** | T2 | 96, 102, 106, 107 | Detection Automation Rules, AI agent, Adhoc Investigation, DS Model 2026 | Verify, then: UPHELD-GENERAL |
| **E2** | T3 | 48, 78, 80 | High fraud score, A1 DS model, E5 DS model | Verify carefully: may need FAB |

---

### Bucket F: Operational & Special Cases

| Bucket | Tier | Reason Codes | Internal Description | CSS Action |
|--------|------|-------------|----------------------|------------|
| **F1** | T1 | 77, 89 | A1 spam, A1 repeat offender | Resolve: UPHELD-GENERAL |
| **F2** | T4 | 7, 8, 9, 21, 73, 74 | Manual referrals, Malicious tenant, HIT confirmed, 3PCO, Farm disruption | Escalate to FAB |

---

### Special Reason Codes — NOT for CSS Triage

These are **internal workflow codes**, not detection reasons. If you see one of these as the primary reason, escalate to FAB:

| RC | Description | Why It's Here |
|----|-------------|---------------|
| 45, 85 | Test/Fraud Test | Internal testing, should not appear in production ICMs |
| 90 | E3 Dev deprecation activity | Deprecation workflow, not fraud-related |
| 99 | Temporary Unblock DataBackup | Internal operational code |

---

## 4. Ring/Batch Awareness

When multiple ICMs arrive around the same time with similar characteristics, they may be part of a **coordinated ring**. Look for:

- **Same Reason Code** across multiple ICMs filed in the same 24-48 hours
- **Similar tenant names** (e.g., all gibberish, all 4-letter names)
- **Same admin contact email** mentioned across tickets
- **Same geographic region** (e.g., all from CN, all from NL)

**If you identify a ring pattern:**
1. Pick one ICM as the **parent ticket**
2. Note the related ICM IDs in the parent ticket
3. Resolve the parent → apply the same resolution to all children
4. Add a note to each child: "Resolved as part of batch [Parent ICM#]. Same enforcement pattern."

This lets you resolve 10+ tickets in the time it takes to resolve 1.

---

## 5. Escalation Routing

| Situation | Route To | Expected SLA |
|-----------|----------|-------------|
| S500 / S2200 tenant | FAB Engineering — tag `[FAB-S500-ESCALATION]` | 4 business hours |
| Customer provides business justification you can't evaluate | FAB Engineering — tag `[FAB-FP-REVIEW]` | 24 business hours |
| Customer claims legal/regulatory action | FAB Engineering + PM — tag `[FAB-LEGAL-ESCALATION]` | 4 business hours |
| Enterprise SKU with active dispute | FAB Engineering — tag `[FAB-ENTERPRISE-REVIEW]` | 24 business hours |
| You're unsure about the tier | FAB Engineering — tag `[FAB-TRIAGE-ASSIST]` | 24 business hours |
| Customer is a known Microsoft partner | FAB Engineering — tag `[FAB-PARTNER-REVIEW]` | 24 business hours |

---

## 6. What You Should NEVER Do

1. **Never tell the customer the specific detection rule or reason code** (e.g., "Rule 3" or "Reason Code 67")
2. **Never use the words "fraud" or "abuse"** in customer communications — use "usage inconsistent with service terms" or "activity that does not align with your subscription"
3. **Never disclose thresholds** (e.g., "your storage exceeded 10TB" or "you had fewer than 5 users")
4. **Never unblock a tenant yourself** — all unblock actions go through the FAB system
5. **Never promise a specific timeline** for unblock/restoration unless FAB has confirmed it
6. **Never share investigation reports, Kusto queries, or internal analysis** with the customer

---

## 7. FAB Dashboard Quick Reference

**URL**: [To be filled by FAB team]

**What you can look up:**
- Tenant ID → Current status, Reason Code, Remediation date
- Domain search → Find related tenants
- S500/S2200 flag status

**What you need:**
- `VIEWER` role access (request from FAB team)
- Your Microsoft Entra ID authentication

---

## Appendix: Glossary

| Term | Meaning |
|------|---------|
| **RC** | Reason Code — the numeric code identifying why a tenant was flagged |
| **S500/ISS500** | Important Shared Service flag — tenant has 500+ users |
| **S2200/ISS2200** | Important Shared Service flag — tenant has 2200+ users |
| **RuleMask** | Bitmask indicating which automated rules triggered for a tenant |
| **UCT** | Use Case Type — determines the remediation action sequence |
| **FP** | False Positive — tenant was incorrectly flagged and should be restored |
| **HIT** | Human Intelligence Team — manual review team |
| **FAB** | Fraud, Abuse & Billing — the engineering team (your escalation point) |
| **Ring/Cluster** | Group of tenants operated by the same actor |
| **EDU A1** | Microsoft 365 Education A1 — free educational license tier |
| **E5 Dev** | Microsoft 365 E5 Developer — free developer license |
