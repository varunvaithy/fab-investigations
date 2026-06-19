# China Network Abuse — CELA Executive Brief

**Date:** April 13, 2026
**Classification:** Microsoft Confidential — CELA Review Required
**Reference:** INV-015 — China Network Abuse Investigation

---

## 1. Summary of Findings & Ask

As part of the E SKU misconfiguration cleanup effort (Incident-718092350), the FAB team has been investigating abusive China-based tenants that exploited the incident. We have received **soft approval** through the ICM (Incident-718092350) to act on tenants identified as fraudulent in this investigation. Based on our findings, **we have placed all 162 confirmed abusive tenants on read-only** as an immediate containment measure.

**We are writing to inform CELA of this action and to request confirmatory sign-off to proceed with the standard remediation cadence: read-only (done) → block → delete.**

### What We Found

In late 2025, a configuration error caused several Exchange Online E SKUs (E3, E5 variants) in China regions to be mistakenly marked as externally free — meaning anyone could acquire them at no cost. This triggered a massive spike in tenant creation and subscription acquisition: approximately **104,000 subscriptions were created across 90,000 tenants** before the misconfiguration was reverted (Incident-718092350, Incident-776217853).

As we began triaging these 90K tenants to distinguish genuine users from bad actors, we identified a significant subset of China-based tenants engaging in coordinated, large-scale abuse of SharePoint Online and OneDrive for Business — well beyond simply acquiring free SKUs. We narrowed the investigation to **46,773 China-registered tenants**, scored them on storage consumption and egress, deep-dived the top 200, and used the patterns discovered to scan the broader population.

Of the **217 tenants analyzed in depth**, we confirmed **162 as abusive** — operating across **12+ coordinated fraud rings** with abuse patterns including:

- **Video/anime piracy CDNs** — streaming pirated media to mobile clients (one tenant generating 130+ TB/week of egress alone)
- **Commercial cloud storage reselling** — operating paid cloud drive businesses on free Microsoft infrastructure (e.g., "Financial City Cloud Drive" at jrcpan.com with 865 TB stored)
- **License fraud** — claiming millions of fake licenses on 1–4 actual users to inflate storage quota (one tenant claims 55 million licenses on 3 users)
- **Brand impersonation** — tenants literally named "Microsoft" and "Microsoft 365", running piracy operations under Microsoft's name
- **Developer SKU exploitation** — using free E3/E5 Developer sandboxes as unlimited storage backends

Total estimated cost to Microsoft is **$5–8M/year** against **under $4K/year** in revenue from these tenants — a **1,000:1+ cost-to-revenue ratio**. A full SKU and license breakdown is in [Appendix A](#appendix-a-sku--license-profile).

### Paid vs. Non-Paid Breakdown

Of the 162 confirmed abusive tenants:

| Category | Tenants | Description |
|----------|:-------:|-------------|
| **Non-paid** | **159** | Free/trial Developer SKU sandboxes, expired trials, zero revenue. Clear to proceed. |
| **Paid (minimal, abusive)** | **3** | 1 paid seat or sub each with clear abuse indicators (storage overage 3–6x quota); includes Baker Tilly China (12 TB on 1.9 TB limit), HIBIKI (6.8 TB on 1 seat), INSITEINSOLES (90 ODB sites on 1 seat) |
| **Total** | **162** | |

**All 162 tenants are now on read-only.** Five additional tenants initially flagged during investigation (SHANGHAI AMERICAN SCHOOL, KEYSTONE ACADEMY, SANHUA HOLDING, HIGHLY-MARELLI, MAXIM SMART MFG) were verified as legitimate paid enterprises/schools and have been excluded from this remediation.

### What We're Asking

| Step | Status | Detail |
|------|--------|--------|
| **1. Read-only** | **Done** | All 162 tenants placed on read-only |
| **2. Block** | Pending sign-off | Disable all access — requires CELA confirmation to proceed |
| **3. Delete** | Pending sign-off | Purge tenant data after retention period |

### Approvals Required

| Approver | Role | Approval |
|----------|------|----------|
| | CELA Lead | ☐ Approved / ☐ Denied |
| | CELA Attorney | ☐ Approved / ☐ Denied |
| | FAB Exec Sponsor | ☐ Approved / ☐ Denied |

**Upon sign-off, the FAB team will proceed from read-only to block for all 162 tenants, followed by delete after the standard retention period.**

---

## 2. Background

This investigation originated from **Incident-718092350** (with follow-on **Incident-776217853**). A number of Exchange E SKUs in China regions were mistakenly marked as externally free, triggering a massive spike in tenant creation and subscription acquisition — approximately **104K subscriptions across 90K tenants**. Business Planning was asked to revert the configuration, provide root cause analysis, and develop a cleanup plan for the affected subscriptions and tenants.

As the FAB team began triaging the 90K tenants — which contained a mix of genuine users who acquired the free SKUs and fraudulent actors who exploited the misconfiguration — it became clear that a significant subset of China-based tenants were engaging in coordinated abuse well beyond simple SKU acquisition. Shared registration data (emails, phone numbers, postal codes) revealed fraud rings operating across dozens of tenants, with abuse patterns including piracy CDN operations, commercial cloud storage reselling, license fraud, and developer SKU exploitation.

Over the course of the investigation (INV-015), **217 unique China-based tenants** were examined using a combination of:

- **ODSP Kusto telemetry** — storage, egress, app fingerprints, file types, partial-content streaming patterns
- **D2K registration data** — admin email, phone, address, organization, domain registrations
- **Cross-tenant correlation** — identifying rings through shared emails, phones, postal codes, and creation timestamps

Of the 217 tenants investigated, **162 were confirmed abusive**, 49 were excluded as legitimate (VL enterprises, approved EDU institutions, verified paid customers), and 6 remain under monitoring. These 162 tenants represent the most impactful and urgent cases identified to date. The investigation is ongoing — we are continuing to assess whether this pattern extends further across the 90K tenant population, but these tenants require immediate action given their scale of abuse and active data filling.

---

## 3. Risk Summary

| Metric | Value |
|--------|-------|
| **Confirmed abusive tenants** | **162** |
| Legitimate tenants (excluded) | 49 |
| Tenants under monitoring | 6 |
| Identified fraud rings | **12+** |
| Estimated abusive storage | **5–7 PB** |
| Estimated annual cost to Microsoft | **$5–8M** |
| Annual subscription revenue from abusers | **<$4K** |
| **Cost-to-revenue ratio** | **1,000:1+** |
| **Total paid seats across all 162 tenants** | **<10** |
| Tenants with zero paid seats | **155+ of 162** |
| Tenants on free Developer sandbox SKUs | **65+** |
| Tenants claiming >1M fabricated licenses | **11** |

### License Fraud Detail

Several tenants have exploited the license self-service mechanism to claim millions of licenses on single-digit user counts, artificially inflating their storage quotas:

| Tenant | Claimed Licenses | Actual Users | Storage | SKU |
|--------|:----------------:|:------------:|:-------:|-----|
| HMIAN | **55,000,000** | 3 | 256 TB | E3 (trial) |
| ZN | **4,000,000** | 4 | 137 TB | E3 (trial) |
| CCTVb | **2,000,000** | — | 28 TB | E3 (trial) |
| It Take Two | **4,000,000** | 2 | 79 TB | E3 (trial) |
| bigfloor5333 | **4,000,000** | 2 | 62 TB | E3 (trial) |
| PERSONAL (B5) | **2,000,000** | 2 | 22 TB | E3 |
| RIKKER44 | **2,000,000** | 6 | 26 TB | E3 |
| 山东铯唔 | **400,000** | 1 | 19 TB | — |

None of these tenants have purchased any paid licenses. The claimed license counts are fraudulent self-service entries used to inflate SharePoint storage quotas.

---

## 4. Fraud Categories

| Category | Description | Tenant Count | Example |
|----------|-------------|:------------:|---------|
| **Video/Anime Piracy CDN** | SPO used as streaming backend for pirated media via mobile apps (stagefright, applecoremedia, lavf) | 30+ | ALLANIME: 130 TB/wk egress to mobile clients |
| **Commercial Cloud Reselling** | Paid cloud drive services built on free SPO storage (jrcpan.com, ms365.plus, office365.wiki) | 9+ | 金融城网络: 865 TB on 5 seats, branded "Financial City Cloud Drive" |
| **Developer SKU Exploitation** | Free E3/E5 Developer sandbox tenants used for unlimited storage | 20+ | 8+ tenants with `developer365=active` tag |
| **License Fraud** | Claiming millions of licenses on 1–4 actual users to inflate storage quota | 8+ | HMIAN: **55 million** licenses on 3 users |
| **Brand Impersonation** | Tenants named "Microsoft", "Microsoft 365", or "抖音" (Douyin/TikTok) | 5+ | Ring E: 5 tenants all named "Microsoft"/"Microsoft 365" |
| **EDU Fraud** | Foreign .edu.kg domains used to fraudulently claim educational status | 2+ | Kyrgyzstan domains exploited for EDU verification bypass |

### Deep Dive: ALLANIME — Piracy CDN at Scale

**Tenant:** `20f3bc22` · **Name:** ALLANIME · **SKU:** SPO Plan 2 · **Paid Seats:** 0 · **Revenue:** $120/year

This tenant operates a **pirated anime streaming service** using SharePoint Online as its CDN backend. Key indicators:

- **130.7 TB of egress per week** — the highest of any tenant in the investigation
- **2.7 million HTTP 206 (Partial Content) requests per week** — the signature of video streaming to mobile clients (byte-range requests from stagefright/applecoremedia media players)
- **49 TB of stored content** — MP4, MKV, AVI files (pirated anime episodes/movies)
- **Admin email:** nekojinanime@outlook.com ("neko jin anime" = "cat person anime")
- **Flagged 7 times** across separate detection signals — the most-flagged tenant in the dataset

At Azure Asia-Pacific egress rates, this single tenant costs Microsoft approximately **$46,000/month** while paying $10/month. That is a **4,648:1 cost-to-revenue ratio.**

### Deep Dive: 金融城网络 — Commercial Cloud Drive Business

**Tenant:** `6a63e133` · **Name:** 金融城网络服务工作室 ("Financial City Network Service Studio") · **SKU:** SPO Plan 2 · **Paid Seats:** 0 · **Revenue:** $600/year

This tenant is operating a **paid commercial cloud storage service** — selling cloud drive access to end users at `vip.jrcpan.com` — built entirely on free Microsoft SharePoint Online storage:

- **865 TB of storage consumed** — the largest single tenant in the investigation
- **13.6 TB of egress per week** — serving files to paying customers
- **5 licensed seats** — all internal operator accounts, not end users
- The branded domain "jrcpan.com" (金融城盘 = "Financial City Drive") is a customer-facing product with VIP tiers

This tenant is part of **Ring D (Cloud Drive Operators)** — a group of 7+ tenants running similar commercial cloud drive businesses on Microsoft infrastructure. Other members operate under domains like `ms365.plus`, `office365.wiki`, `office365plus.vip`, and `huohuo-cloud.xyz`. Combined Ring D storage exceeds **175 TB**.

---

## 5. Organized Fraud Rings

The investigation uncovered **12+ coordinated fraud rings** linked through shared registration data (email, phone, address), domain patterns, and creation timestamps:

| Ring | Members | Linking Evidence | Combined Storage | Confidence |
|------|:-------:|-----------------|:----------------:|:----------:|
| **A** — HMIAN-ZN | 2 | Admin email cross-reference (`admin@hmian`) | **393 TB** | Confirmed |
| **B** — Fake Gmail/+852 | 8 | 2 shared Gmail addresses, HK phone numbers, PostalCode "000000" | 90+ TB | Confirmed |
| **C** — Guangdong Tech | 2 | Identical email + phone (`450512013@qq.com`) | 27 TB | Confirmed |
| **D** — Cloud Drive Operators | 7+ | Shared business model: SPO-backed commercial cloud services | 175 TB | Confirmed |
| **E** — Brand Impersonation | 5 | "Microsoft"/"Microsoft 365" naming + `tm[X].site` domains | 60+ TB | High |
| **F** — Phone 4251001000 | 4+ | Identical phone (Microsoft HQ switchboard number) | TBD | Confirmed |
| **G** — James/Jam Pattern | 2+ | Shared naming + registration pattern | TBD | Medium |
| **H** — Nanjing Pair | 2 | Identical email, phone, address, postal code | 4.8 TB | Confirmed |
| **I** — .edu.kg EDU Fraud | 2+ | Kyrgyzstan `.edu.kg` domains for EDU bypass | TBD | High |
| **iccfree.com** | 3 | 3 tenants created within 90 min, shared email domain | 6 TB | Confirmed |
| **Haikou Pair** | 2 | Created 13 min apart, same province, gibberish data | 62+ TB | High |
| **Zunyi Pair** | 2 | Same city, same day, 2 hrs apart | — | Medium-High |
| **Hebi Pair** | 2 | Same small city (pop. 1.5M), both confirmed abusive | 20+ TB | Medium |

---

## 6. Top Impact Tenants

The 12 highest-impact tenants by storage consumption. **None have any paid seats** — all operate on free Developer SKU sandboxes, trial licenses, or standalone SPO/ODB Plan 2 subscriptions with artificially inflated license counts.

| # | Tenant | Storage | 7d Egress | SKU | Paid Seats | Est. Revenue | Key Evidence |
|---|--------|--------:|----------:|-----|:----------:|-------------:|-------------|
| 1 | 金融城网络 | **865 TB** | 13.6 TB | SPO Plan 2 | **0** | $600/yr | Commercial cloud drive (jrcpan.com), 5 seats |
| 2 | 保密 ("Confidential") | **512 TB** | 3.5 TB | SPO Plan 2 | **0** | $600/yr | rclone + air explorer, anime domain |
| 3 | HMIAN (Ring A) | **256 TB** | 10.3 TB | E3 (55M lic.) | **0** | $0 | 55M fake licenses on 4 users, piracy CDN |
| 4 | 连气瓶 | **178 TB** | — | ODB Plan 2 | **0** | $0 | Cloudreve+rclone+synology, Hangzhou |
| 5 | ZN (Ring A) | **137 TB** | 1 TB | E3 (4M lic.) | **0** | $0 | Actively filling at 29.7 TB/wk upload |
| 6 | Default Dir (F1) | **135 TB** | 5 TB | F1 | **0** | $96/yr | INV-014 crossover, single F1 seat, 135 TB |
| 7 | 黑猫動漫結社 | **114 TB** | 8.3 TB | SPO Plan 2 | **0** | $600/yr | Cloudreve anime CDN, dlspup.org |
| 8 | duanren | **110 TB** | 2.7 TB | E5 Developer | **0** | $0 | Free dev trial, rclone-only, 123478.xyz |
| 9 | It Take Two | **79 TB** | — | E3 (4M lic.) | **0** | $0 | Trial, uploading 9.3 TB/wk, 4M licenses |
| 10 | MoqiArtToys | **78 TB** | 1.8 TB | ODB Plan 2 | **0** | $0 | 6 domains, video piracy |
| 11 | bigfloor5333 | **62 TB** | — | E3 (4M lic.) | **0** | $0 | Full piracy video set, 4M licenses, gibberish addr |
| 12 | ALLANIME | **49 TB** | **130.7 TB** | SPO Plan 2 | **0** | $120/yr | 2.7M partial-content requests/wk, anime CDN |

**Combined: 2.5 PB of storage, >175 TB/week of egress, $0 in paid seats, $2K total annual revenue across all 12.**

---

## 7. Financial Impact

| Component | Monthly Cost | Annual Cost |
|-----------|------------:|------------:|
| Storage ( 5–7 PB at Azure-equivalent rates) | $100,000+ | **$1.2M+** |
| Egress (Asia-Pacific bandwidth, $87/TB) | $300,000+ | **$3.6M+** |
| Infrastructure overhead | $50,000 | $600K |
| **Total estimated cost to Microsoft** | **$400K+/month** | **$5–8M/year** |
| Revenue from abusive tenants | <$300/month | **<$4K/year** |

**Microsoft is spending over $1,000 in infrastructure for every $1 of revenue** from these tenants.

### Cost Driver: ALLANIME

A single tenant (`20f3bc22`) generates **130.7 TB of egress per week** — streaming pirated anime to mobile clients. At Azure Asia-Pacific egress rates, this single tenant costs Microsoft approximately **$46,000/month** while paying $10/month in subscription fees. That is a **4,648:1 cost-to-revenue ratio**.

---

## 8. Blocklist & Immediate Prevention

In parallel with remediation, the following additions to automated detection blocklists are prepared:

- **37 domains** — abuse-associated domains (e.g., `ms365.plus`, `office365.wiki`, `jrcpan.com`, `excal.top`)
- **17 email addresses** — ring operator accounts (e.g., `sheronmorreaugmf12@gmail.com`, `biancafrancisops895@gmail.com`)
- **10 phone numbers** — including +852 HK cluster, Microsoft HQ number 4251001000
- **7 regex patterns** — for proactive registration blocking (e.g., `.*@iccfree\.com`, `sheronmorre.*@gmail\.com`)

These measures will prevent re-entry by known operators creating new tenants.

---

## 9. Forward-Looking: Detection Rules for Productionalization

This investigation surfaced several **repeatable abuse patterns** that can be codified into automated detection rules. We would like to signal the direction we're heading and will come back to CELA with a formal proposal for approval before productionalizing any of these.

### Patterns We're Looking to Automate

| Pattern | Signal | What It Catches | Confidence |
|---------|--------|----------------|:----------:|
| **License-to-user mismatch** | Tenant claims >10,000 licenses but has <10 actual users | License fraud to inflate storage quota (e.g., 55M licenses on 3 users) | High |
| **Piracy CDN fingerprint** | High HTTP 206 (Partial Content) rate + mobile media-player user agents (stagefright, applecoremedia, lavf) + video file types (MP4, MKV, AVI) | Video/anime piracy streaming operations | High |
| **Commercial cloud drive detection** | Cloudreve/rclone/synology app fingerprints + commercial-sounding domains + high storage on free SKUs | SPO/ODB used as backend for paid cloud storage services | High |
| **Developer SKU storage abuse** | E3/E5 Developer sandbox with >5 TB storage + 0 paid seats + rclone/bulk-upload fingerprints | Free trial exploitation for unlimited storage | High |
| **Brand impersonation** | Tenant display name matches "Microsoft", "Microsoft 365", or other Microsoft product names | Tenants impersonating Microsoft to operate piracy/fraud infra | High |
| **Registration fraud indicators** | PostalCode "000000", disposable email domains, fake Western names on CN-registered tenants, same-day bulk creation from same city | Fraud rings creating throwaway tenants | Medium-High |

### What We're Proposing (Next Step)

1. **Immediate (this ask):** Approve remediation of the 162 confirmed abusive tenants documented here
2. **Near-term:** We will draft formal rule definitions for the high-confidence patterns above, with false-positive analysis and proposed thresholds, and bring them back to CELA for review before any automated enforcement is enabled
3. **Goal:** Move from reactive investigation to proactive detection — catch these patterns at tenant creation or early in the abuse lifecycle, before tenants accumulate hundreds of terabytes of pirated content

We believe automated rules for the confirmed patterns (especially license fraud, piracy CDN fingerprinting, and developer SKU abuse) can significantly reduce the volume of manual investigation work while preventing the cost impact from recurring.

---

*Full investigation details available in [China_Network_Abuse_Investigation.md](China_Network_Abuse_Investigation.md) (INV-015). A complete list of all 162 confirmed abusive tenant IDs with categorization is attached as [China_Network_Abuse_Tenant_List.md](China_Network_Abuse_Tenant_List.md).*

---

## Appendix A: SKU & License Profile

Breakdown of SKU types across the 162 confirmed abusive tenants:

| SKU Category | Tenants | Paid Seats | Notes |
|--------------|:-------:|:----------:|-------|
| E5 Developer (free sandbox) | 45 | **0** | Largest single category — free trial abused for storage |
| E3 Developer (free sandbox) | 20 | **0** | Same pattern as E5 Dev |
| E3/E5 with inflated licenses | 15 | **0** | Trial SKUs claiming millions of fake licenses (e.g., 55M, 4M, 2M) to inflate quota |
| ODB Plan 2 / SPO Plan 2 | 12 | **0–1** | Standalone plans, minimal paid seats, massive overage |
| A1 (EDU) | 2 | **0** | EDU SKUs on free A1 plans |
| Business Basic / F1 / Other | 10 | **0–1** | Misc. free-tier or minimal-cost SKUs |
| Unknown / No active SKU | 58 | **0** | Deprovisioned, expired trials, or fingerprint-only confirmed |

**Across all 162 tenants, total paid seats are in the single digits. Total combined annual revenue is under $4K.** Multiple tenants have zero subscriptions remaining but still consume tens of terabytes of storage.
