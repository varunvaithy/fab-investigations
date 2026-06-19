**To:** Schana  
**Subject:** CELA Sign-off — Temp Support Triage for March Fraud Wave (~21K Tenants)

---

Hi Schana,

Need your sign-off on a **temporary measure** to help our support team handle the volume of customer reach-outs from our recent large-scale fraud remediation. Our stance on fraud enforcement is unchanged and we remain confident in our detections — this is purely an operational ask to make support triage scalable for the current surge.

**Context:** In mid-March, our AI-based fraud detection agent identified ~21K tenants exhibiting fraudulent behavior. These have been pushed into our standard remediation pipeline (readonly → block → delete). For reference, our usual detection rate is ~250 tenants/week, so this was a significant one-time spike. The vast majority of these tenants are on unpaid (free/trial) SKUs across multiple geographies. Our false positive rate is <1%, validated through manual review and signal correlation. S500 and S2200 customers have been explicitly exempted from this wave.

**Problem:** As these tenants hit the block/delete stages, affected users are reaching out to support. Under the current process, support creates one ICM per tenant, which routes to our engineering on-call for manual review. At 21K tenants, this is generating a volume of ICMs that's not sustainable for either support or engineering — and given the high confidence of our detections, the vast majority of these ICMs result in the same outcome (block upheld). We need a way to let support resolve the high-confidence cases without routing each one through engg on-call.

**Proposal — two tiers:**

**Tier 1 (~7K tenants)** — These tenants have multiple independent fraud signals confirming fraudulent activity. Our detection confidence for this group is very high.
- Support gets a **yes/no lookup UI** to check if a tenant ID is in this group. The UI returns only yes/no — no tenant list, no underlying signals, no reason codes are exposed to support.
- If the tenant is in Tier 1 → support **auto-resolves** the case using our standard UPHELD response template (included below). No ICM is created. Decision is final, no appeal.

**Tier 2 (~14K tenants)** — For these tenants, the existing process continues unchanged. If a customer reaches out, support validates the case, raises an ICM, and engineering on-call reviews and dispositions through due process.

| | Tier 1 (Critical) | Tier 2 (Remaining) |
|---|---|---|
| Volume | ~7,000 | ~14,000 |
| Confidence | Very high | Standard |
| Support action | Lookup → auto-resolve | Standard ICM process |
| Appeal | No | Yes |
| S500/S2200 | Exempted | Exempted |

**What I need from CELA:**
1. OK to give support a yes/no lookup UI without exposing tenant list or detection details?
2. Any concern with auto-resolve for Tier 1 given <1% FP, unpaid SKUs, and S500/S2200 exemptions?
3. Any issues with the customer-facing message below?

Support would use our existing **UPHELD** response template (already in use today for confirmed blocks). For reference:

> *Thank you for contacting us regarding your Microsoft 365 tenant [TENANT ID].*
>
> *After review, we have determined that your tenant was restricted because activity was detected that is inconsistent with the intended use of Microsoft 365 services.*
>
> *This action was taken in accordance with the [Microsoft Online Services Terms of Use](https://www.microsoft.com/licensing/terms). The restriction on your tenant will remain in effect.*
>
> *If you believe this was done in error, you may respond with:*
> - *Documentation of your organization (business registration, institutional accreditation, or similar)*
> - *A description of how your organization uses Microsoft 365*
> - *Any context you believe is relevant to your case*
>
> *Our team will review any additional information provided.*

**Longer term:** This proposal is a temporary measure scoped to the current remediation wave. We are actively exploring options including auto-denial of support access for clearly fraudulent tenants and more granular enforcement tiering. We'll reach out to CELA separately as those plans mature — this ask is purely about helping support manage the immediate volume.

Happy to jump on a call if easier.

Thanks,  
Varun
