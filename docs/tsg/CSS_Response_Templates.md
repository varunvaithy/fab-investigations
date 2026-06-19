# CSS Response Templates — FAB Tenant Remediation

> **INTERNAL USE ONLY — DO NOT SHARE WITH CUSTOMERS**
> Version 2.0 | April 2026
>
> **Rules:**
> - NEVER use "fraud," "abuse," or "suspicious" with customers
> - NEVER disclose rules, thresholds, reason codes, or internal tools
> - NEVER mention specific storage amounts, user counts, or bandwidth numbers

---

## 6 Templates — That's It

| # | Template | When to Use |
|---|----------|-------------|
| 1 | **ACK** | First response to any inquiry |
| 2 | **UPHELD** | Block is confirmed — all tiers, all buckets |
| 3 | **UNDER-REVIEW** | Escalating to FAB (Tier 4) |
| 4 | **NEED-INFO** | You don't have enough to triage |
| 5 | **RESTORED** | FAB confirmed false positive, tenant unblocked |
| 6 | **APPEAL-DENIED** | Customer appealed, FAB re-reviewed, block stands |

---

## 1. ACK — First Response

Send this immediately. Works for every incoming ticket.

> Thank you for contacting Microsoft Support regarding your Microsoft 365 tenant.
>
> We have received your inquiry and our team is reviewing your account. We understand this may be impacting your work and are treating it with priority.
>
> To help us review your case, please confirm:
> - **Tenant ID** (Admin Center → Settings → Org Settings → Organization Profile)
> - **Admin email** associated with the tenant
> - **Brief description** of your organization and how you use Microsoft 365
>
> You can expect an update within **[X] business days**.
>
> Best regards,
> Microsoft Support

**[X] =** 2 for Tier 1/2 | 3 for Tier 3 | 5 for Tier 4

---

## 2. UPHELD — Block Confirmed

**One template. Pick one reason line from the table below and drop it in at [REASON LINE].**

> Thank you for contacting us regarding your Microsoft 365 tenant **[TENANT ID]**.
>
> After review, we have determined that your tenant was restricted because **[REASON LINE]**.
>
> This action was taken in accordance with the [Microsoft Online Services Terms of Use](https://www.microsoft.com/licensing/terms). The restriction on your tenant will remain in effect.
>
> If you believe this was done in error, you may respond with:
> - Documentation of your organization (business registration, institutional accreditation, or similar)
> - A description of how your organization uses Microsoft 365
> - Any context you believe is relevant to your case
>
> Our team will review any additional information provided.
>
> Best regards,
> Microsoft Support

### Pick Your [REASON LINE]

| Bucket | Use When RC Is In | Drop-In Line |
|--------|-------------------|-------------|
| **A — Content** | 62, 63, 64, 65, 66, 67, 68, 71, 83, 84 | content or applications were detected on your tenant that do not align with the intended use of Microsoft 365 services |
| **B — Usage** | 0, 1, 6, 47, 72, 79, 92 | the usage patterns on your account are significantly outside the scope of your current subscription |
| **C — Account** | 11, 12, 26, 35, 36, 37, 38, 39, 40, 52, 59, 69 | account characteristics were identified that are inconsistent with standard organizational use |
| **D — Licensing** | 5, 10, 22, 23, 27, 28, 34, 50, 56, 70, 82, 86, 87, 88, 91 | the account configuration and usage are inconsistent with the terms of your subscription type |
| **E — General** | 48, 77, 78, 80, 89, 96, 102, 106, 107 | activity was detected that is inconsistent with the intended use of Microsoft 365 services |

**If you don't know the bucket → use the E (General) line. It works for everything.**

---

## 3. UNDER-REVIEW — Escalating to FAB

Send this when you're routing to FAB (Tier 4, S500/S2200, unsure cases).

> Thank you for the information regarding your Microsoft 365 tenant **[TENANT ID]**.
>
> Your case has been escalated to our specialized review team for further analysis. You can expect an update within **5 business days**. If additional information is needed, we will reach out directly.
>
> We appreciate your patience.
>
> Best regards,
> Microsoft Support

---

## 4. NEED-INFO — Missing Context

Send when the customer didn't include enough detail and you can't look them up.

> Thank you for contacting Microsoft Support.
>
> To review your case, we need a few details:
> 1. **Tenant ID** (Admin Center → Settings → Org Settings → Organization Profile)
> 2. **Your organization's name and what it does**
> 3. **How you use Microsoft 365** (email, SharePoint, OneDrive, Teams, etc.)
> 4. **Number of people** in your organization using the service
> 5. **Any third-party tools** connected to your Microsoft 365 environment
>
> This will help us conduct a thorough review. Please respond at your earliest convenience.
>
> Best regards,
> Microsoft Support

*(Internal note: If they mention rclone, StableBit, CloudDrive, air explorer, or similar — that is confirming signal. Do not tell the customer this.)*

---

## 5. RESTORED — False Positive Confirmed

Send when FAB has confirmed FP and the tenant is unblocked.

> Thank you for your patience regarding your Microsoft 365 tenant **[TENANT ID]**.
>
> After further review, we have determined that the restriction on your tenant was applied in error. **Your tenant has been restored** and you should have full access to all services.
>
> Please allow up to **[4/24] hours** for all services to fully propagate. If you experience any continued issues after that, please contact us again and reference this ticket.
>
> We apologize for the inconvenience.
>
> Best regards,
> Microsoft Support

**[4/24] =** 4 hours for unblock | 24 hours for full data restoration (confirm with FAB)

---

## 6. APPEAL-DENIED — Re-Reviewed, Block Stays

Send when customer provided additional info, FAB reviewed it, and the block is upheld.

> Thank you for providing additional information regarding your Microsoft 365 tenant **[TENANT ID]**.
>
> Our team has conducted a thorough review of your account, including the documentation you provided. After this review, we have determined that the restriction will remain in place.
>
> The usage patterns identified on your account remain inconsistent with the [Microsoft Online Services Terms of Use](https://www.microsoft.com/licensing/terms).
>
> If you have questions about Microsoft 365 plans that may better suit your needs, please visit [https://www.microsoft.com/microsoft-365/business/compare-all-plans](https://www.microsoft.com/microsoft-365/business/compare-all-plans).
>
> Best regards,
> Microsoft Support

---

## Common Situations — Quick Responses

These are drop-in lines you can add to any template when the customer asks a specific question.

**"What exactly did we do wrong?"**
> For security and platform integrity reasons, we are unable to share specific technical details of our review process. If you believe your usage is consistent with your subscription terms, we encourage you to provide documentation as described above.

**"When will my data be deleted?"**
> Your data is preserved during the restriction period in accordance with Microsoft's standard retention policies. For details, please refer to the [Microsoft Trust Center](https://www.microsoft.com/trust-center).

**"We upgraded / moved to a paid plan"**
> Thank you for letting us know. We have noted this and escalated your case for priority review.
> *(Internal: Escalate to FAB with `[FAB-FP-REVIEW]` — may qualify for RC 93/94)*

**"We're a Microsoft Partner"**
> Thank you. Could you please share your Microsoft Partner Network (MPN) ID? We will escalate your case for priority review.
> *(Internal: Escalate to FAB with `[FAB-PARTNER-REVIEW]` regardless of tier)*

**Customer threatens legal action**
> We take all inquiries seriously. Your case has been escalated to our specialized review team for priority attention. If you wish to involve legal counsel, they may contact Microsoft's legal department.
> *(Internal: Escalate immediately — Tier 4 `[FAB-LEGAL-ESCALATION]`)*

---

## Internal Notes — Batch/Ring Resolution

When resolving multiple related ICMs, add this to the **internal ICM notes** (not to customer):

> **Batch Resolution** — This ICM is part of [N] related tickets (Parent: [ICM#]).
> Same enforcement pattern across all (Bucket [X], Tier [Y]).
> Related ICMs: [list]

Send each customer the standard UPHELD template individually. They don't need to know about the batch.

---

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | April 2026 | Initial — 11 templates |
| 2.0 | April 2026 | Consolidated to 6 templates. Single UPHELD with drop-in reason lines. Removed redundant variants. |
