# CSS Quick Reference — Reason Code → Action Cheat Sheet

> **INTERNAL USE ONLY** | Print this. Pin it. Use it.
> Companion to: CSS_Triage_Guide.md + CSS_Response_Templates.md

---

## THE FLOWCHART

```
  Customer reports restricted tenant
              │
              ▼
  ┌──── Extract Tenant ID ────┐
  │  (from ICM or customer)   │
  └────────────┬──────────────┘
               ▼
  ┌──── Check S500/S2200 ─────┐
  │  (FAB Dashboard lookup)    │
  └──────┬─────────────┬──────┘
     TRUE│             │FALSE
         ▼             ▼
  ┌─────────┐  ┌─── Look up Reason Code ───┐
  │ TIER 4  │  │  (FAB Dashboard lookup)    │
  │ STOP.   │  └────────────┬───────────────┘
  │Escalate │               ▼
  │ to FAB  │  ┌─── Match RC to table below ──┐
  │ NOW.    │  │  Find Tier (T1/T2/T3/T4)     │
  └─────────┘  └──────┬────┬────┬────┬────────┘
                   T1  │ T2 │ T3 │ T4 │
                      ▼   ▼   ▼   ▼
              ┌────────────────────────────────┐
              │  Follow Tier action from       │
              │  CSS_Triage_Guide Section 2    │
              └────────────────────────────────┘
```

---

## MASTER TABLE: Every Active Reason Code → What You Do

### 🟢 TIER 1 — VERY HIGH CONFIDENCE — You resolve. You close. No FAB needed.

| RC | What It Is (internal only) | UPHELD Reason Line |
|----|---------------------------|--------------------|
| 5 | Coordinated tenant cluster | D — Licensing |
| 62 | Ransomware detected | A — Content |
| 63 | Crypto mining detected | A — Content |
| 65 | Adult content hosted | A — Content |
| 67 | Non-paid tenant hosting video/games | A — Content |
| 70 | Multiplexing (licensing circumvention) | D — Licensing |
| 71 | Malware detected | A — Content |
| 77 | A1 tenant — spam activity | E — General |
| 82 | EMEA E5 Dev multiplexing | D — Licensing |
| 83 | >10TB streaming video/games | A — Content |
| 84 | >10TB EMEA streaming video/games | A — Content |
| 86 | >10TB multiplexing | D — Licensing |
| 87 | >10TB EMEA multiplexing | D — Licensing |
| 88 | M365 Biz multiplexing | D — Licensing |
| 89 | A1 repeat offender — spam | E — General |
| 91 | Free-level multiplexing | D — Licensing |

---

### 🟡 TIER 2 — HIGH CONFIDENCE — Quick verify, then resolve.

| RC | What It Is (internal only) | UPHELD Reason Line | Verify What? |
|----|---------------------------|--------------------|--------------|
| 0 | High anonymous video streaming | B — Usage | Customer claims video production? |
| 1 | High ODB storage | B — Usage | Customer is enterprise with real users? |
| 6 | A1 tenant high storage | B — Usage | School provides accreditation? |
| 10 | E5 Developer | D — Licensing | Developer provides app registration? |
| 22 | Named pattern cluster | D — Licensing | Customer disputes cluster linkage? |
| 23 | Same name pattern tenants | D — Licensing | Customer explains multiple tenants? |
| 26 | Microsoft-similar name | C — Account | Customer is actually MSFT partner? |
| 27 | ML model — similar names cluster | D — Licensing | Customer disputes? Escalate. |
| 28 | ML model — similar domains cluster | D — Licensing | Customer disputes? Escalate. |
| 34 | Non-academic domain on EDU | D — Licensing | School provides proof of accreditation? |
| 36 | Suspicious org name | C — Account | Customer provides business registration? |
| 39 | Known pattern match | C — Account | Customer provides business documentation? |
| 40 | Brand impersonation | C — Account | Customer proves they own the brand? |
| 47 | E5 Dev over-quota | B — Usage | Developer has migrated to paid? |
| 50 | Unauthorized dev SKU renewal | D — Licensing | Customer moved to paid SKU? |
| 56 | EDU subscription without academic use | D — Licensing | School provides accreditation? |
| 64 | CN dev tenant hosting | A — Content | Customer explains content purpose? |
| 66 | Paid tenant hosting content | A — Content | Customer is media company? |
| 68 | E3 Dev tenant with bad activity | A — Content | Customer disputes content? |
| 72 | P99.99 egress | B — Usage | Customer explains data transfer need? |
| 79 | Detection — streaming tenant | B — Usage | See RC 0 |
| 92 | Free-level streaming | B — Usage | See RC 0 |
| 96 | Detection Automation — rules engine | E — General | Customer provides general justification? |
| 102 | AI agent detected | E — General | Customer provides general justification? |
| 106 | Adhoc investigation (already deep-dived) | E — General | Should already be well-investigated |
| 107 | DS Model 2026 | E — General | Customer provides general justification? |

**Tier 2 Quick Verify**: If customer provides credible docs → Escalate to FAB. If no response in 5 days or no justification → close with template.

---

### 🟠 TIER 3 — MEDIUM CONFIDENCE — Verify carefully. May need FAB.

| RC | What It Is (internal only) | UPHELD Reason Line | Risk of FP | What to Watch For |
|----|---------------------------|--------------------|-----------|-----------------|
| 11 | Gibberish tenant name | C — Account | **Medium** | Non-English names can be flagged incorrectly (Chinese, Arabic, Vietnamese org names) |
| 12 | No spaces in tenant name | C — Account | **Medium** | Some legitimate orgs use single-word names |
| 35 | Suspicious admin/tech contacts | C — Account | **Medium** | IT providers managing multiple clients |
| 37 | Account info mismatches | C — Account | **Medium** | Data entry errors on legitimate accounts |
| 38 | Gibberish account setup/emails | C — Account | **Medium** | Non-English admins with transliterated names |
| 48 | High fraud score (model) | E — General | **Medium** | Threshold is an older model — some false positives |
| 52 | Credential misuse pattern | C — Account | **Low-Medium** | Compromised accounts may be legitimate orgs |
| 59 | Fictitious persona/business | C — Account | **Low-Medium** | Small/new businesses can look synthetic |
| 69 | Gibberish sign-in usernames | C — Account | **Medium** | Auto-generated usernames from SSO integrations |
| 78 | A1 DS model scores | E — General | **Medium** | Older model, broader sweep |
| 80 | E5 DS model scores | E — General | **Medium** | Older model, broader sweep |

**Tier 3 Rule**: If the customer pushes back with ANY of these, escalate to FAB:
- Business registration / institutional accreditation
- Letter from their IT provider
- Specific explanation of why their name/email looks the way it does
- Claims to be non-English-speaking org

---

### 🔴 TIER 4 — ESCALATE IMMEDIATELY — Do not resolve.

| Trigger | Template | Who to Tag |
|---------|----------|------------|
| **S500 = TRUE** (any RC) | UNDER-REVIEW | `[FAB-S500-ESCALATION]` |
| **S2200 = TRUE** (any RC) | UNDER-REVIEW | `[FAB-S500-ESCALATION]` |
| RC 7 — Manual referral from Leslie | UNDER-REVIEW | `[FAB-TRIAGE-ASSIST]` |
| RC 8 — Malicious tenant | UNDER-REVIEW | `[FAB-ESCALATION]` |
| RC 9 — HIT Confirmed | UNDER-REVIEW | `[FAB-ESCALATION]` |
| RC 21 — 3PCO referral | UNDER-REVIEW | `[FAB-ESCALATION]` |
| RC 73, 74 — Farm disruption | UNDER-REVIEW | `[FAB-ESCALATION]` |
| Customer claims legal action | UNDER-REVIEW | `[FAB-LEGAL-ESCALATION]` |
| Customer is government entity | UNDER-REVIEW | `[FAB-ENTERPRISE-REVIEW]` |
| Enterprise SKU + active dispute | UNDER-REVIEW | `[FAB-ENTERPRISE-REVIEW]` |
| RC 45, 85 — Test codes | DO NOT RESPOND | `[FAB-TRIAGE-ASSIST]` → Should not be in production |
| You're unsure | ACK then UNDER-REVIEW | `[FAB-TRIAGE-ASSIST]` |

---

## SPECIAL SITUATIONS

### "I need my data back"
→ Template: UNDER-REVIEW → Escalate to FAB with `[FAB-DATA-RECOVERY]`
→ FAB determines if temporary unblock for data backup is appropriate (RC 99/103)

### "We moved to a paid plan / upgraded our license"
→ Check if tenant status shows any recent license change
→ Escalate to FAB with `[FAB-FP-REVIEW]` — may qualify for RC 93 (Moved to paid SKU) or RC 94

### "We're a Microsoft Partner"
→ Ask for their MPN (Microsoft Partner Network) ID
→ Escalate to FAB with `[FAB-PARTNER-REVIEW]` regardless of tier

### "Multiple tenants, same issue"
→ Check if all tenants share the same reason code
→ If yes → Ring/Batch pattern → Use RING-BATCH template internally
→ Resolve all together using the parent ICM pattern (see Triage Guide Section 4)

### Reason Code Not in This List
→ If you see a RC not listed above (e.g., RC 53, 54, 55, 57, 58) these are CELA-aligned external codes
→ Treat as **Tier 4** → Escalate to FAB

---

## NUMBERS TO REMEMBER

| Metric | Value | Why It Matters |
|--------|-------|----------------|
| T1 resolution | ~60% of all tickets | You handle these start-to-finish |
| T2 resolution | ~25% of all tickets | Quick verify, then you handle |
| T3 + T4 | ~15% of all tickets | These go to FAB |
| Expected FP rate for T1 | <1% | Almost never wrong |
| Expected FP rate for T2 | ~3-5% | Rare, but possible |
| Expected FP rate for T3 | ~10-15% | Real chance — be careful |

*Estimates based on historical investigation data. Actual rates may vary.*

---

## VERSION HISTORY

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | April 2026 | Initial creation — full RC mapping, 4 tiers, special situations |
