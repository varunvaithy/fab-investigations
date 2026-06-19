# China Network Abuse — Investigation Report (INV-015)

**Investigation Date:** April 10, 2026
**Investigator:** Varun V
**Scope:** 217 unique China-based tenants investigated
**ICM Tickets:** Incident-718092350 (E SKU misconfiguration), Incident-776217853 (cleanup & investigation)
**Status:** ACTIVE INVESTIGATION — 162 abusive, 49 legitimate, 6 monitor
**Cross-references:** INV-014 (F1 Soft-Quota Abuse — tenant `24098c20` overlaps)
**Wider List:** 46,773 CN tenants identified; 46,487 remaining after dedup; bulk scoring via KQL in progress

---

## Investigation Origin

This investigation stems from **Incident-718092350** and the follow-on **Incident-776217853**. A number of Exchange E SKUs in China regions were mistakenly marked as externally free, causing a massive spike in tenant creation and subscription acquisition — approximately **104K subscriptions across 90K tenants**. Business Planning was asked to revert the configuration, provide a root cause analysis, and develop a plan to clean up the affected subscriptions and tenants.

As the FAB team began triaging the 90K tenants (a mix of genuine users who acquired free SKUs and fraudulent actors who exploited the misconfiguration), it became clear that a significant subset of China-based tenants were engaging in coordinated abuse — piracy CDN operations, commercial cloud storage reselling, license fraud, and developer SKU exploitation. This investigation (INV-015) documents the fraud analysis of 217 tenants drawn from that population.

---

## Executive Summary

Investigation of 217 unique China-based tenants uncovered coordinated abuse at massive scale:

- **162 tenants confirmed abusive** across 12+ identified rings and multiple individual abusers
- **49 tenants excluded as legitimate** (VL enterprises, approved EDU institutions, verified paid customers)
- **6 tenants under monitoring** (insufficient signal to confirm/deny)
- **Estimated annual cost to Microsoft: $6–8M** on <$4K/year subscription revenue

### Ring Summary

| Ring | Members | Linking Signal | Combined Storage |
|------|---------|---------------|-----------------|
| **Ring A** (HMIAN-ZN) | 2 | Admin email cross-reference | 393 TB |
| **Ring B** (Fake Gmail/+852) | **8** | Shared emails + HK phones + 000000 postal | 90+ TB |
| **Ring C** (Guangdong Tech) | 2 | Same email + phone | 27 TB |
| **Ring D** (Cloud Drive Operators) | 7+ | Business model pattern | 175 TB |
| **Ring E** (tm[X].site Brand Impersonation) | **5** | Domain pattern + "Microsoft" naming | 60+ TB |
| **Ring F** (Phone 4251001000) | 4+ | Shared phone number 4251001000 | TBD |
| **Ring G** (James/Jam Pattern) | 2+ | Naming + registration pattern | TBD |
| **Ring H** (Nanjing Pair) | 2 | Identical email + phone + address + postal | 4.8 TB |
| **Ring I** (.edu.kg EDU Fraud) | 2+ | Kyrgyzstan .edu.kg domains, EDU abuse | TBD |
| **iccfree.com** | 3 | Same-day creation + shared email domain | 6 TB |
| **Haikou Pair** | 2 | 13 min apart, same province, fake data | 62+ TB |
| **Zunyi Pair** | 2 | Same city, same day, 2 hrs apart | — |
| **Hebi Pair** | 2 | Same small city | 20+ TB |

### Key Abuse Patterns

1. **Video/Anime Piracy CDN** — streaming via stagefright/applecoremedia/lavf to mobile clients
2. **Commercial Cloud Storage Reselling** — SPO as backend for paid cloud drive services
3. **rclone/Cloudreve File Distribution** — programmatic bulk upload/download
4. **Developer SKU Abuse** — free E3/E5 Developer sandboxes for storage exploitation
5. **License Fraud** — claiming millions of licenses on 1-4 actual users to inflate quota
6. **Brand Impersonation** — naming tenants "Microsoft"/"Microsoft 365"

---

## Ring Analysis (D2K Verified)

### Ring A: HMIAN-ZN Piracy CDN (2 tenants)

**Link:** ZN's admin email = `admin@hmian.onmicrosoft.com`; HMIAN owns domain `zn.al`.

| | HMIAN (`5edb62e7`) | ZN (`7d5d12c2`) |
|---|---|---|
| **Admin** | 1045304851@qq.com | admin@**hmian**.onmicrosoft.com |
| **Domain** | hmian.onmicrosoft.com + **zn.al** | **cloudpans**.onmicrosoft.com |
| **Created** | 2020-01-22 | 2025-11-12 |
| **City** | 九江 (JX) | Beijing |
| **Storage** | **256 TB** | **137 TB** |
| **Licenses** | **55,000,000** (3 users) | **4,000,000** (4 users) |
| **7d Egress/Ingress** | 10.3 TB / — | 1 TB / **29.7 TB** |
| **Apps** | rclone, guzzlehttp, lavf, applecoremedia | python-requests, guzzlehttp, rclone, lavf |
| **Files** | MP4, MKV | MP4, MKV, AVI |

ZN is **actively filling** piracy CDN at 29.7 TB/week upload. Combined: 393 TB, 59M forged licenses.

**Confidence: CONFIRMED** (admin email cross-reference)

---

### Ring B: Fake Western Gmail / Anhui / +852 HK Phones (8 tenants)

**Expanded to 8 members** via D2K. Two email identities control 8 tenants using fake Western names, Hong Kong phone numbers, and fabricated Anhui addresses.

| Tenant | Name | Admin Email | Phone | Province | PostalCode | Created |
|--------|------|-------------|-------|----------|-----------|---------|
| `f9f1b6da` | 电子有线 | **biancafrancisops895@gmail.com** | +852-9263-3512 | AH (山地, fake) | **000000** | 2022-11-02 |
| `21470293` | 电子有线2 | **biancafrancisops895@gmail.com** | +852-9259-5840 | AH (阿斯顿, fake) | 000000 | 2022-11-10 |
| `56a36e88` | **美亚诗** | **biancafrancisops895@gmail.com** | +852-6717-4732 | AH (瑶海区) | **000000** | 2022-11-22 |
| `8a7f99ee` | 琦琦 | **sheronmorreaugmf12@gmail.com** | +852-4195-8459 | AH (淮南) | **000000** | 2022-11-24 |
| `44b59163` | 首搭科技 | **sheronmorrea*y*gmf12@gmail.com** | 18629559282 | HE (时代小区, fake) | 000000 | 2022-06-08 |
| `bd3be752` | 烤肉 | **sheronmorreaugmf12@gmail.com** | +852-9478-5989 | GZ (安徽, fake) | **000000** | 2023-07-18 |
| `b67f481a` | **NEW1** | **sheronmorreaugmf12@gmail.com** | +852-4439-8669 | SC (shenzhen) | **000000** | 2024-08-12 |

**Ring signatures:**
- Two email addresses: `biancafrancisops895` (3 tenants) and `sheronmorreaugmf12` (4 tenants, one with typo "y")
- 6 of 7 have **+852 Hong Kong phone numbers**
- All 7 have **PostalCode "000000"** (deliberately fake)
- Sequential naming: 电子有线 → 电子有线2
- Creation cluster: Jun 2022 – Aug 2024
- All distribute RAR archives via Android clients

`b67f481a` (NEW1) initially classified as standalone "Storage Abuse" — D2K confirms it’s `sheronmorreaugmf12@gmail.com` with +852 phone.

**Confidence: CONFIRMED** (shared email + phone pattern + postal code + geography)

---

### Ring C: Guangdong Tech Company (2 tenants)

Identical admin email AND phone across two fake "tech companies":

| | 广州诗梵科技 (`c7292335`) | 深圳鑫贝帝科技 (`c2502fae`) |
|---|---|---|
| **Admin** | **450512013@qq.com** | **450512013@qq.com** |
| **Phone** | **13040805207** | **13040805207** |
| **City** | Guangzhou (GD) | Shenzhen (GD) |
| **Created** | 2023-08-08 | 2023-07-17 |
| **Files** | ZIP CDN | ZIP CDN |

**Confidence: CONFIRMED** (identical email + phone)

---

### Ring E: Brand Impersonation / tm[X].site (5 tenants)

Five tenants all impersonate "Microsoft" / "Microsoft 365" and share a subdomain naming pattern:

| Tenant | Display Name | Email | Phone | Domain | Created |
|--------|-------------|-------|-------|--------|---------|
| `c246dfc5` | **Microsoft** | 1@163.com | 178201**55704** | **msvip.v6.navy** | 2025-11-17 |
| `3d76e686` | **Microsoft 365** | biuxj@outlook.com | 186201**63288** | **v6.tm9.site** | 2023-02-08 |
| `8f3f7b4c` | **Microsoft 365** | asd5wsew@outlook.com | 162326**52477** | **s3.tm6.site** | 2023-09-07 |

**Ring signatures:**
- All named "Microsoft" or "Microsoft 365" — brand impersonation
- Subdomain pattern: `[prefix].tm[X].site` and `v6.navy`
- All Guangdong area phone codes (178xx, 186xx, 162xx)
- All have `developer365=active` tag
- `c246dfc5` acquired 2M trial E3 licenses; `3d76e686` has 3 onmicrosoft aliases (mindxi + i8k5 + default)
- `8f3f7b4c` runs Cloudreve + synology on s3.tm6.site

**Confidence: HIGH** (brand impersonation pattern + domain naming + Guangdong geography)

---

### iccfree.com Ring (3 tenants)

| Tenant | Name | Admin | Domain | Created |
|--------|------|-------|--------|---------|
| `2b64ab07` | DEFAULT DIRECTORY | 31999929@qq.com | 31999929qq.onmicrosoft.com | 2025-11-14 **04:04** |
| `6a3f3639` | 沈丘县鸿运汽运有限公司 | **c1@iccfree.com** | cace123.onmicrosoft.com | 2025-11-14 **04:58** |
| `2b7a9950` | 周口松娜网络商务有限公司 | **c3@iccfree.com** | cace12.onmicrosoft.com | 2025-11-14 **05:29** |

All 3 created within 90 minutes, same E3 Developer SKU, sequential domains (cace12/cace123), shared email domain (iccfree.com), all rclone + video piracy.

**Confidence: CONFIRMED**

---

### Haikou Pair — Potential Ring F (2 tenants)

| | bigfloor5333 (`94c5e07d`) | mad671001 (`8582d095`) |
|---|---|---|
| **Email** | big.floor5333@foshan.gd | mad@**671001.xyz** |
| **City** | HI (dsdas — gibberish) | HA Haikou (Jinrong) |
| **Address** | **dsadsafsafsa** (gibberish) | Jinrong |
| **PostalCode** | 231112 | 876543 |
| **Created** | 2025-11-14 **02:19** | 2025-11-14 **02:32** |
| **Storage** | 62 TB | — |
| **Apps** | lavf + rclone | — |
| **Files** | MP4/MKV/TS/ISO/WMV/AVI | — |
| **Licenses** | 4,000,000 (2 users) | — |

**13 minutes apart**, both Hainan area, both use disposable/gibberish registration data. `94c5e07d` has full piracy video set + 4M fake licenses.

**Confidence: HIGH** (temporal + geographic + fake data pattern)

---

### Zunyi Pair — Potential Ring G (2 tenants)

| | grpppqqq (`a53f727c`) | LugMe (`7c5f00c6`) |
|---|---|---|
| **Email** | grpppqqq@outlook.com | 888454@gmail.com |
| **City** | GZ **遵义** 红花岗区 | GZ **遵义** 习水县 |
| **Created** | 2025-11-13 **12:06** | 2025-11-13 **14:02** |
| **Domain** | grpppqqqoutlook.onmicrosoft.com | **lug.me** |
| **Tags** | azure=active | edu=**pendingapproval** |

Same city (Zunyi, Guizhou), created **same day 2 hours apart**. LugMe tried for EDU approval with `lug.me` domain — a vanity URL masquerading as educational.

**Confidence: MEDIUM-HIGH** (same city + same day, but different emails)

---

### Hebi Pair — Potential Ring H (2 tenants)

| | yuni (`b824df6c`) | GKinto (`34de18bd`) |
|---|---|---|
| **Email** | yuni1187304093@163.com | gkintowork@gmail.com |
| **City** | HA **鹤壁市** 山城区 | HA **鹤壁市** 黄河路 |
| **Created** | 2025-11-25 | 2024-04-29 |
| **Storage** | 20 TB | 16.6 TB |
| **Apps** | Cloudreve + OneDriveSync | rclone + androidDLmgr |

Same small city (Hebi, Henan — population 1.5M). Both confirmed abusive via RequestUsage. Different creation dates but Hebi is an uncommon city for two separate abuse tenants to both register in.

**Confidence: MEDIUM** (same small city, but different emails/dates)

---

### Ring F: Phone 4251001000 Cluster (4+ tenants)

Four tenants registered with the phone number **4251001000** (Microsoft's main Redmond HQ exchange — clearly fabricated for a Chinese tenant). Members include:

| Tenant | Name | Key Signal |
|--------|------|-----------|
| — | **KMOE** | Phone 4251001000, developer SKU |
| — | **GOOGLEPLEX** | Phone 4251001000, brand impersonation (Google) |
| — | **SHENGJY** | Phone 4251001000 |
| — | **CAPTAINSLEEPY** | Phone 4251001000 |

**Ring signatures:**
- All registered with **4251001000** (425 = Redmond area code, Microsoft HQ switchboard)
- "GOOGLEPLEX" is Google's campus name — double brand impersonation
- Pattern suggests a shared registration guide or script using Microsoft's own phone number

**Confidence: CONFIRMED** (identical phone number)

> *Note: Full tenant IDs to be mapped from D2K queries.*

---

### Ring G: James/Jam Registration Pattern (2+ tenants)

Two or more tenants sharing a "James"/"Jam" naming prefix and similar registration patterns.

**Confidence: MEDIUM** (naming pattern match; D2K details needed for full confirmation)

> *Note: Awaiting full ring member enumeration from bulk scan results.*

---

### Ring H: Nanjing License Fraud + Brand Impersonation (2 tenants)

**D2K CONFIRMED — identical registration data.**

| | 飞翔网络 (`fc122104`) | 抖音 (`edf6cf4d`) |
|---|---|---|
| **Admin Email** | **qaz2830514940@gmail.com** | **qaz2830514940@gmail.com** |
| **Phone** | **15847144678** | **15847144678** |
| **City** | 南京市 **江宁区** | 南京市 **江宁区** |
| **PostalCode** | **223300** | **223300** |
| **Created** | 2025-11-14 | 2025-11-15 |
| **Tenant Level** | E3 | E3 DEVELOPER |
| **Domain** | excal.top | od1a.onmicrosoft.com |
| **Storage** | **4,391 GB** (4.4 TB) | **419 GB** |
| **Licenses** | **2,000,000** (3 users) | 15 (2 users) |

**Ring signatures:**
- **Identical** email, phone, city, district, and postal code
- Created **1 day apart** (Nov 14 & 15, 2025)
- `fc122104` has **2 million licenses on 3 users** — classic license fraud for storage inflation
- `edf6cf4d` named **"抖音"** (Douyin/TikTok) — **brand impersonation** of China's largest short-video platform
- Both in November 2025 creation wave

**Confidence: CONFIRMED** (identical D2K registration: email + phone + address + postal)

---

### Ring I: Kyrgyzstan .edu.kg EDU Fraud (2+ tenants)

At least two tenants using **.edu.kg** (Kyrgyzstan) education domains to fraudulently claim EDU status:

| Tenant | Name | Key Signal |
|--------|------|-----------|
| — | **CHOOL** | .edu.kg domain, EDU tenant abuse |
| — | **云创科技** ("Cloud Create Tech") | .edu.kg domain, EDU tenant abuse |

**Ring signatures:**
- Kyrgyzstan `.edu.kg` domains are cheap/easy to acquire and provide EDU verification bypass
- Both tenants with Chinese names/operators using foreign EDU domains
- Pattern represents a new EDU fraud vector exploiting cheap foreign domain registrations

**Confidence: HIGH** (shared abuse technique with foreign EDU domain pattern)

> *Note: Full tenant IDs to be mapped from D2K queries.*

---

## Abuse Pattern Categories

### Pattern 1: Video/Anime Piracy CDN

| Signal | Indicator |
|--------|-----------|
| **Apps** | stagefright, applecoremedia, lavf, dalvik, androiddownloadmanager |
| **Files** | MP4, MKV, AVI, WMV, MOV, M2TS, TS, FLV |
| **HTTP** | Massive PartialContentCount (206 = range-request streaming) |
| **Traffic** | Egress >> Ingress (uploaded once, streamed to thousands) |
| **Names** | Anime-themed: "myanime", "黑猫动漫", "acgn0", "yuri.city", "MoeOvO" |

Key tenants: ALLANIME (130 TB/wk egress), 黑猫动漫結社 (113 TB stored, Cloudreve), HMIAN-ZN ring (393 TB combined), NEPP, KONGWUZI, PERSONAL, SELF, 4I5I, 奥術魔刃 (FLAC music piracy), MoeOvO (nya.ac)

### Pattern 2: Commercial Cloud Storage Reselling

Operators build user-facing cloud drive products using SPO/ODB as free backend infrastructure:

| Tenant | Domain | Indicator | Storage |
|--------|--------|-----------|---------|
| `6a63e133` | vip.jrcpan.com | "Financial City Cloud Drive" | 865 TB |
| `cddabb98` | **office365.wiki** | Exploitation guide domain | 9.9 TB |
| `7c777e8c` | **ms365.plus** + **office365plus.vip** | Cloud drive reselling, 6 domains | 27 TB |
| `96658824` | eee.7so.top | Named "QiSoCloud" | 1.5 TB |
| `25d865f1` | **huohuo-cloud.xyz** | Explicit "cloud" branding | 5.2 TB |
| `9bb38d0d` | **office.site** | Premium domain exploitation | 1.3 TB |
| `f1475a5c` | **od.jileshe.cc** | "od" = OneDrive | 1 TB |
| `1e49cb2f` | harbinyupai.com | Cloudreve multi-domain | 4 TB |
| `b7ee9fb7` | jqy666.onmicrosoft.com | 金启云 ("Gold Start Cloud") + Cloudreve | 5.3 TB |

### Pattern 3: rclone/Cloudreve File Distribution

Primary upload/download mechanism for abuse. Key fingerprints: `rclone`, `Cloudreve`, `air explorer`, `RaiDrive`, `synology`, `guzzlehttp`, `python-requests`.

### Pattern 4: Developer SKU / License Fraud

| Tenant | SKU | Licenses Claimed | Actual Users | Fraud Ratio |
|--------|-----|-----------------|-------------|-------------|
| HMIAN | SPO Plan 2 | **55,000,000** | 3 | 18.3Mx |
| ZN | SPO Plan 2 | **4,000,000** | 4 | 1Mx |
| bigfloor5333 | — | **4,000,000** | 2 | 2Mx |
| CCTVb | — | **2,000,000** | 9 | 222Kx |
| It Take Two | — | **4,000,000** | 2 | 2Mx |
| 婷阮测试 | — | **2,000,000** | 4 | 500Kx |
| 山东铯唔 | SPO Plan 2 | **400,000** | 1 | 400Kx |
| O6 | SPO Plan 1 | **10,500** | 1 | 10.5Kx |

8+ tenants with developer365=active tags exploiting free Developer SKU sandbox: 129d9a20, ef6ed8b2, ecd4feb2, d0695867, 7002a5d2, b7ee9fb7, e439db60, 3d76e686.

### Pattern 5: Self-Identifying / Taunting Names

| Tenant | Name/Email | Translation |
|--------|-----------|-------------|
| `1c065159` | **mr.hentai@qq.com** | Self-identifying adult content |
| `a208e9d7` | **woshiniyeye6699** | "I am your grandpa" — taunting |
| `fbffe1f1` | **没有公司** | "No Company" — explicit fraud |
| `cd3bf6ac` | **CCTVb** / hdTVb / hachina.cc.cd | CCTV brand reference + piracy domain |
| `736d732b` | **REYNHOLM INDUSTRIES** | Fictional company (IT Crowd TV show) |

---

## Complete Tenant Inventory — Abusive (162 tenants)

> 82 tenants fully detailed below with storage/egress data. Remaining 80 tenants confirmed abusive via tenant_info + D2K analysis; per-tenant tables pending bulk KQL integration.

### Tier 1: Critical Storage (>50 TB)

| # | Tenant ID | Name | Storage (TB) | 7d Egress (TB) | Ring | Key Evidence |
|---|-----------|------|-------------|----------------|------|-------------|
| 1 | `6a63e133` | 金融城网络服务工作室 | **865** | 13.6 | D | Commercial cloud drive (jrcpan.com), 865 TB on 5 seats |
| 2 | `f38aa9fa` | 保密 ("Confidential") | **512** | 3.5 | — | rclone + air explorer, anime-themed domain, 331983711@qq.com |
| 3 | `5edb62e7` | HMIAN | **256** | 10.3 | **A** | 55M fake licenses, piracy CDN, zn.al domain |
| 4 | `a94cb8dc` | 连气瓶 | **178** | — | — | Cloudreve+rclone+synology, MP4/WAV/MKV/AVI, Hangzhou |
| 5 | `7d5d12c2` | ZN | **137** | 1.0 (29.7 in) | **A** | admin@hmian, ACTIVELY FILLING at 29.7 TB/wk |
| 6 | `24098c20` | Default Directory (F1) | **135** | 5 | — | INV-014 crossover, F1 exploit, rclone+lavf |
| 7 | `521ba7a8` | 黑猫動漫結社 | **114** | 8.3 | — | Cloudreve anime CDN, storage.dlspup.org |
| 8 | `e439db60` | duanren | **110** | 2.7 | — | rclone-only, 123478.xyz, ZIP/7Z/RAR/MP4 |
| 9 | `022daa44` | It Take Two | **79** | — (9.3 in) | — | **9.3 TB/wk upload**, ISO/MKV/MP4, 4M licenses, octlog.net |
| 10 | `031245e8` | MoqiArtToys | **78** | 1.8 | — | 6 domains, rclone+excel, MP4/MKV/FLV |
| 11 | `94c5e07d` | bigfloor5333 | **62** | — | **Haikou** | lavf+rclone, full piracy video set, 4M licenses, gibberish addr |

### Tier 2: High Storage (10–50 TB)

| # | Tenant ID | Name | Storage (TB) | 7d Egress (TB) | Ring | Key Evidence |
|---|-----------|------|-------------|----------------|------|-------------|
| 12 | `20f3bc22` | ALLANIME | **49** | **130.7** | — | Most-flagged (7×), 2.7M PartialContent, video CDN |
| 13 | `fbffe1f1` | 没有公司 ("No Company") | **31** | 4.1 | — | "No Company", androidDLmgr, MP4/RAR |
| 14 | `17169edd` | ZHEI | **30** | — | — | EDU A1, m365.lol suspicious, 13 users — **REVIEW** |
| 15 | `c246dfc5` | MICROSOFT | **28** | 20.6 | **E** | Brand impersonation, 2M trial licenses, msvip.v6.navy |
| 16 | `cd3bf6ac` | CCTVb | **28** | — (4.4 in) | — | air explorer, hachina.cc.cd, 2M licenses, TS files |
| 17 | `7c777e8c` | joey.cn | **27** | — | D | ms365.plus + office365plus.vip, 6 domains, cloud reselling |
| 18 | `a3cd2d3e` | NEPP | **23** | 13.8 | — | yuri.city anime CDN, trial, 17.6x overage |
| 19 | `0db3be03` | SHEJIGE | **22** | 0 (throttled) | — | e3.sheji.ge, rclone, rate-limited |
| 20 | `d956edc7` | Default Directory | **22** | 0 (throttled) | — | 100% error rate, hygaoyong@outlook.com, Hunan |
| 21 | `a208e9d7` | woshiniyeye6699 | **21** | 0 (throttled) | — | "I'm your grandpa", 360233.xyz, throttled |
| 22 | `5a457f06` | UEQT | **21** | 0 (throttled) | — | python-requests, throttled |
| 23 | `b824df6c` | yuni (默认目录) | **20** | — | **Hebi** | Cloudreve+OneDriveSync, MP4/RAR/MKV, Hebi |
| 24 | `df6ebb2e` | YUZUKI | **20** | 0.4 | — | lavf, Japanese name, video streaming, Zhejiang |
| 25 | `129d9a20` | 个人 | **19** | 14.4 | — | E5 Dev trial, rclone+video piracy, 15x overage |
| 26 | `44b59163` | 首搭科技 | **19** | 4.4 | **B** | sheronmorreaygmf12, +852, RAR CDN |
| 27 | `fbbc6e82` | 山东铯唔 | **19** | 6.0 | — | 400K licenses, M2TS/MKV = Blu-ray piracy |
| 28 | `bd3be752` | 烤肉 ("BBQ") | **18** | 2.4 | **B** | sheronmorreaugmf12, +852, RAR CDN |
| 29 | `09d450b8` | bingcheng | **17** | — | — | rclone+androidDLmgr, ISO/GZ, 589K PartialContent, ee.ci |
| 30 | `8f3f7b4c` | Microsoft 365 | **16** | — | **E** | Cloudreve+synology, s3.tm6.site, brand impersonation |
| 31 | `c7292335` | 广州诗梵科技 | **15** | 2.0 | **C** | 450512013@qq.com, ZIP CDN |
| 32 | `5cd5dbd4` | 杨氏科技 | **13** | 10.9 | — | E5 Dev trial, rclone, RAR/7Z |
| 33 | `c2502fae` | 深圳鑫贝帝科技 | **12** | 2.8 | **C** | 450512013@qq.com, ZIP CDN |
| 34 | `8a7f99ee` | 琪琪 | **12** | 3.4 | **B** | sheronmorreaugmf12, +852, RAR CDN |
| 35 | `21470293` | 电子有线2 | **10** | — | **B** | biancafrancisops895, +852 |
| 36 | `e9196dc5` | 资源龙 ("Resource Dragon") | **10** | 3.7 | — | theyouyi.site, RAR/ZIP, 836K PartialContent |

### Tier 3: Medium Storage (1–10 TB)

| # | Tenant ID | Name | Storage (TB) | Ring | Key Evidence |
|---|-----------|------|-------------|------|-------------|
| 37 | `cddabb98` | 瑞声科技 | 9.9 | D | office365.wiki, guzzlehttp+synology+rclone |
| 38 | `e4c6b0f6` | ShanghaiTech | 8 | — | dev365 abuse, rclone/MeTA, MP4/MKV, Zhangjiang |
| 39 | `7c0c1be6` | Steffen Inc. | 8 | — | 8shield.net disposable email, air explorer, RAR |
| 40 | `ce7336c1` | HIBIKI | 6.8 | — | 1-seat SPO Plan 2, 6.5x overage |
| 41 | `1d37b572` | O6 | 6.8 | — | 10,500 enabled on 1 paid, 1.9M PartialContent |
| 42 | `01118a50` | 广西简约信息科技 | 6.4 | — | 11101109.xyz, rclone, E5 Dev trial |
| 43 | `3d76e686` | Microsoft 365 | 7 | **E** | v6.tm9.site, biuxj@outlook.com, 3 aliases |
| 44 | `b7ee9fb7` | 金启云 | 5.3 | D | Cloudreve, ISO/FLAC/MP3/FLV, cloud service name |
| 45 | `25d865f1` | 阿五 | 5.2 | D | huohuo-cloud.xyz, 7Z distribution |
| 46 | `f9f1b6da` | 电子有线 | 5.1 | **B** | biancafrancisops895, +852, ODB Plan 2 |
| 47 | `a774b052` | CMSDJ科技有限公司 | 5.0 | — | ODB Plan 2, limulu243, 000000 postal, edu=pending |
| 48 | `970b1641` | VRZWK | 5 | — | rclone+ZIP, 90 GB active upload, Suzhou |
| 49 | `7e9a0e9a` | huleen.net | 5 | — | rclone, throttled 99.6%, Jiangxi |
| 50 | `1a720d28` | MoeOvO | 4.7 | — | nya.ac+coder.moe, anime CDN, 3.6M PartialContent |
| 51 | `60f34acf` | 婷阮测试 | 4.3 | — | 2M licenses, Kristopher fake name, rclone |
| 52 | `3a08a0e1` | 奥術魔刃一号開発 | 4 | — | FLAC/MP4/MOV/M4A = music+video piracy |
| 53 | `1e49cb2f` | XZI | 4 | D | Cloudreve, 4 domains (harbinyupai), Harbin |
| 54 | `ecd4feb2` | PERSONAL | 3.9 | — | E5 Dev trial, video streaming |
| 55 | `b4f10ec5` | goldenladder | 3.5 | — | rclone+synology, yixj.tk, 30K DELETEs (cycling), MP3/FLAC/MP4 |
| 56 | `45567a67` | SELF | 3.3 | — | acgn0.onmicrosoft.com, ODB Plan 2, anime |
| 57 | `fe5a03ae` | Default Dir (joyjoutek) | 3 | — | RAR CDN, "6 East Chang'an Ave" fake address |
| 58 | `ef6ed8b2` | KONGWUZI | 2.8 | — | E5 Dev trial, video CDN |
| 59 | `b67f481a` | NEW1 | 2.7 | **B** | sheronmorreaugmf12, +852, SPO Plan 2 |
| 60 | `0552addc` | ROBOGITHUB | 2.6 | — | python-requests scripted abuse |
| 61 | `2b64ab07` | DEFAULT DIRECTORY | 2.3 | **iccfree** | Same-day creation, rclone piracy |
| 62 | `6a3f3639` | 沈丘县鸿运汽运有限公司 | 2.2 | **iccfree** | c1@iccfree.com, rclone piracy |
| 63 | `2b7a9950` | 周口松娜网络商务有限公司 | 1.7 | **iccfree** | c3@iccfree.com, rclone piracy |
| 64 | `ffce955c` | 无氧科技电子有限公司 | 1.6 | — | E3 Dev, web distribution |
| 65 | `96658824` | QiSoCloud | 1.5 | D | eee.7so.top, named cloud service |
| 66 | `9bb38d0d` | 星ζ哲 | 1.3 | D | office.site, ISO/GZ, oldest tenant (2017) |
| 67 | `840aa988` | 4I5I | 1.0 | — | E5 Dev trial, media library |
| 68 | `f1475a5c` | 默认目录 (jileshe) | 1 | D | od.jileshe.cc, 7Z web distribution |

### Tier 4: Additional Abusers (D2K confirmed, RequestUsage pending detailed #s)

| # | Tenant ID | Name | City | Created | Email | Key Signal |
|---|-----------|------|------|---------|-------|-----------|
| 69 | `56a36e88` | 美亚诗 | AH | 2022-11-22 | biancafrancisops895@gmail.com | **Ring B**, +852, 000000 |
| 70 | `8582d095` | mad671001 | HA Haikou | 2025-11-14 | mad@671001.xyz | **Haikou Pair**, 13 min after bigfloor |
| 71 | `07c605b9` | 阿白科技 | SN 西安 | 2023-07-10 | abaiww@163.com | 000000 postal, abuse apps |
| 72 | `d0695867` | yunabcd | CN | 2023-08-19 | 13734110657@qq.com | developer365=active |
| 73 | `fbc84da6` | 默认目录 (foxilo) | JS Changzhou | 2025-11-16 | foxilo@126.com | azure=active only, Nov wave |
| 74 | `1c065159` | 御所 | BJ | 2024-04-30 | **mr.hentai@qq.com** | Self-identifying, 000000 postal |
| 75 | `736d732b` | REYNHOLM INDUSTRIES | BJ 东城 | 2025-11-18 | 399090790@qq.com | Fictional company (IT Crowd), naominet.com.cn |
| 76 | `166160da` | Default Dir (chilcosta8) | GD Jiangmen | 2025-11-23 | chilcosta8@outlook.com | Nov wave, azure=active |
| 77 | `a53f727c` | Default Dir (grpppqqq) | GZ 遵义 | 2025-11-13 | grpppqqq@outlook.com | **Zunyi Pair** |
| 78 | `7c5f00c6` | LugMe | GZ 遵义 | 2025-11-13 | 888454@gmail.com | **Zunyi Pair**, lug.me, edu=pending |
| 79 | `69b1de3e` | dwf135 | HA Zhengzhou | 2021-06-13 | qq6385@hotmail.com | — |
| 80 | `933d36ad` | 默认目录 (butter25505) | FJ Fuzhou | 2025-11-13 | butter25505@gmail.com | Nov wave |
| 81 | `34de18bd` | GKinto | HA 鹤壁 | 2024-04-29 | gkintowork@gmail.com | **Hebi Pair**, RAR abuse |
| 82 | `7002a5d2` | 海昕网络科技工作室 | CN | 2023-05-13 | yangheng314@outlook.com | developer365=active |

---

## Legitimate Exclusions (49 tenants)

> 16 tenants fully detailed below. Additional 33 legitimate tenants confirmed via VL status, approved EDU tags, ISS2200/ISS500 designation, or verified business operations with custom domains and real usage patterns.

| Tenant ID | Name | Domain | VL | EDU | Key Evidence |
|-----------|------|--------|----|----|-------------|
| `d4c1f548` | SHANGHAI AMERICAN SCHOOL | saschina.onmicrosoft.com | — | A5 (EDU) | 12 paid SPO subs, 8,586 ODB sites, 102 TB, within quota, created 2016 |
| `883d90fd` | KEYSTONE ACADEMY | keystoneacademy.cn | — | A5 (EDU) | 11 paid SPO subs, 2,522 ODB sites, 58 TB, within quota, created 2015 |
| `0e4ec02f` | SANHUA HOLDING GROUP | sanhuagroup.onmicrosoft.com | YES | — | S2200, E5, 7 paid SPO subs, 2,566 licenses, 111 TB, 13 domains |
| `c8635489` | HIGHLY-MARELLI | highly-marelli.com | YES | — | E3, 3 paid SPO subs, 1,572 licenses, 59 TB, Shanghai automotive JV |
| `57dcbd6b` | MAXIM SMART MFG | maxim-group.com | YES | — | ODB Plan 2, 2 paid SPO subs, 337 licenses, 9 TB, created 2015 |
| `ea960b61` | YANFENG | yanfeng.com | YES | — | ISS2200, 18K+ users, 21 domains, automotive enterprise |
| `e5898b7a` | CUHK-Shenzhen | cuhk.edu.cn | YES | approved | 29K users, 6 domains, noDeletionBy=VL |
| `87df1436` | SanDisk Semiconductor | sdsscn.com | YES | — | ISS2200, 8 users, Excel/Word/PPT/OneNote |
| `d2129150` | JCET Global (长电科技) | jcetglobal.com | YES | — | ISS2200, 36 users, Azure Logic Apps, 4 domains |
| `cbc6e1e2` | BASIS International SZ | basischina.com | — | approved | 7 edu domains, 15 users, 166 apps |
| `01636912` | **ByteDance** | o365.bytedance.com | YES | — | noDeletionBy=VL, beender.wang@bytedance.com, 252 TB legit |
| `10a12e64` | **Quanta CN** | quantacn.com | YES | — | noDeletionBy=VL, 6 corp domains, 115 TB, Excel/Teams |
| `e0567466` | **Wellington College** | wellingtoncollege.cn | YES | approved | noDeletionBy=VL, 9 edu domains, 189 TB legit, est. 2014 |
| `7e82de2f` | **Westlake University** (西湖大学) | westlake.edu.cn | YES | approved | noDeletionBy=VL, 11 domains, 244 TB, est. 2018 |
| `1a787527` | **Beijing Po Garden** | bj.ckah.com.cn | YES | — | noDeletionBy=VL, real estate, real address |
| `734d023f` | stu.ccit.edu.cn | stu.ccit.edu.cn | — | approved | EDU A1, mixed use, lower priority |

### Monitor (6 tenants)

| Tenant ID | Name | Reason |
|-----------|------|--------|
| `775629fa` | szjm.edu.cn | EDU approved, EmailVerified, but minimal registration data |
| `0a79f022` | MSI GSC ENG dept. | camusyea@msi.com, legit MSI Shenzhen, but minimal signal |
| — | *(4 additional tenants)* | Insufficient signal to confirm/deny; continued monitoring |

---

## D2K Registration Summary (All Tenants)

### D2K Registration Details (Selected Tenants)

| Tenant | Admin Email | Phone | City/Province | Created | Domains | Key Signal |
|--------|-------------|-------|--------------|---------|---------|-----------|
| CCTVb (`cd3bf6ac`) | 1256074236@qq.com | 15625057507 | GX | 2025-11-20 | hdTVb + **hachina.cc.cd** | CCTV name + piracy domain |
| It Take Two (`022daa44`) | chenxiyu@**octlog.net** | 13372359785 | ZJ 台州 | 2025-11-16 | octlog.net | Real address, corporate email |
| bigfloor5333 (`94c5e07d`) | big.floor5333@foshan.gd | — | HI | 2025-11-14 | — | **Gibberish address** "dsdas/dsadsafsafsa" |
| mad671001 (`8582d095`) | mad@**671001.xyz** | — | HA Haikou | 2025-11-14 | — | Disposable .xyz domain email |
| 连气瓶 (`a94cb8dc`) | lamons.n@gmail.com | 17682342689 | ZJ Hangzhou | 2022-12-07 | colonised.onmicrosoft.com | Random English word domain |
| duanren (`e439db60`) | wangzhehan84@gmail.com | 18231581460 | HE 唐山 | 2023-02-21 | **123478.xyz** | developer365=active |
| goldenladder (`b4f10ec5`) | windyi.n@gmail.com | 52005800 | SH Shanghai | 2020-05-27 | **yixj.tk** | .tk free domain |
| 阿白科技 (`07c605b9`) | abaiww@163.com | 17829029323 | SN 西安 | 2023-07-10 | — | PostalCode 000000 |
| yuni (`b824df6c`) | yuni1187304093@163.com | 18182141041 | HA **鹤壁** | 2025-11-25 | — | Hebi Pair |
| joey.cn (`7c777e8c`) | sjoey@qq.com | 18697996031 | GX 南宁 | 2018-12-15 | **ms365.plus**, office365plus.vip, zjw.ink, sjoey.cn, wellttravel.com, office365svip.onmicrosoft.com | **6 domains**, cloud reselling |
| yunabcd (`d0695867`) | 13734110657@qq.com | 18928493012 | CN | 2023-08-19 | — | developer365=active |
| 美亚诗 (`56a36e88`) | **biancafrancisops895@gmail.com** | **+852-6717-4732** | AH 瑶海区 | 2022-11-22 | sadkjkgwe.onmicrosoft.com | **Ring B** |
| foxilo (`fbc84da6`) | foxilo@126.com | — | JS Changzhou | 2025-11-16 | — | azure=active |
| 御所 (`1c065159`) | **mr.hentai@qq.com** | 18320823313 | BJ 御所 | 2024-04-30 | reimunet.onmicrosoft.com | 000000 postal, self-identifying |
| REYNHOLM (`736d732b`) | 399090790@qq.com | 13520011351 | BJ 东城 | 2025-11-18 | **naominet.com.cn** | Fictional company name |
| chilcosta8 (`166160da`) | chilcosta8@outlook.com | — | GD Jiangmen | 2025-11-23 | — | azure=active |
| grpppqqq (`a53f727c`) | grpppqqq@outlook.com | — | GZ **遵义** | 2025-11-13 | — | Zunyi Pair |
| LugMe (`7c5f00c6`) | 888454@gmail.com | 13314414144 | GZ **遵义** | 2025-11-13 | **lug.me** | Zunyi Pair, edu=pending |
| dwf135 (`69b1de3e`) | qq6385@hotmail.com | 17760710630 | HA Zhengzhou | 2021-06-13 | — | — |
| 金启云 (`b7ee9fb7`) | 2091880578@qq.com | 19186201297 | CN | 2023-06-05 | jqy666.onmicrosoft.com | developer365=active |
| butter25505 (`933d36ad`) | butter25505@gmail.com | — | FJ Fuzhou | 2025-11-13 | — | azure=active |
| GKinto (`34de18bd`) | gkintowork@gmail.com | 13419828800 | HA **鹤壁** | 2024-04-29 | — | Hebi Pair |
| 海昕网络 (`7002a5d2`) | yangheng314@outlook.com | 18725119204 | CN | 2023-05-13 | zero314com.onmicrosoft.com | developer365=active |
| bingcheng (`09d450b8`) | **i@ee.ci** | 18201739989 | CN | 2021-05-26 | **ee.ci** + e5eeci.onmicrosoft.com | Short vanity domain |

### D2K Registration Details (Key Ring Members)

| Tenant | Admin Email | Phone | Province | Created | Key Signal |
|--------|-------------|-------|----------|---------|-----------|
| ALLANIME | nekojinanime@outlook.com | 19941171360 | HN | 2021-08-23 | PostalCode 416000 |
| 金融城网络 | lickceo@foxmail.com | 18684917020 | HN | — | PostalCode 416000 (same as ALLANIME) |
| MICROSOFT (`c246dfc5`) | **1@163.com** | 17820155704 | GD 广州花都 | 2025-11-17 | **Ring E** |
| Microsoft 365 (`8f3f7b4c`) | asd5wsew@outlook.com | 16232652477 | — | 2023-09-07 | **Ring E**, s3.tm6.site |
| 黑猫動漫 | blackcatunderthemoon1@gmail.com | 15515429028 | — | — | — |
| 瑞声科技 | 1819539104@qq.com | 17802582663 | JS | — | office365.wiki |
| ZN | admin@hmian.onmicrosoft.com | 1000861 | BJ | 2025-11-12 | **Ring A** |
| HMIAN | 1045304851@qq.com | 4250000000 | JX | 2020-01-22 | **Ring A**, zn.al |
| 山东铯唔 | cn1@**srv.pub** | 13572813984 | SD | 2025-11-19 | Disposable email |
| 保密 | 331983711@qq.com | 15388091065 | HN 长沙 | 2023-01-11 | "Confidential" |
| 婷阮测试 | Kristopher1198180@mail.com | 13669495967 | SH | 2025-11-16 | Fake Western name |
| Steffen Inc | pretended_clinking586@**8shield.net** | 13185897458 | BJ | 2026-01-25 | Disposable email |
| SELF | yukinoshita6464@gmail.com | 17515036723 | SD Dezhou | 2023-01-24 | acgn0 = anime |
| 个人 | limuyao86@gmail.com | 15307713419 | — | 2023-01-03 | developer365=active |
| KONGWUZI | kongwuzi@outlook.com | 15550357360 | — | 2024-01-11 | developer365=active |
| PERSONAL | 1098037187@qq.com | 15124540576 | — | 2023-02-01 | developer365=active |

---

## Geographic Distribution

### Province Heatmap

| Province | Count | Key Tenants |
|----------|-------|-------------|
| **Guangdong** (GD) | **15** | MoeOvO, O6, QiSoCloud, Ring C (2), CMSDJ, 奥術魔刃, chilcosta8, Ring E (c246dfc5), BASIS |
| **Hunan** (HN) | 5 | ALLANIME, 金融城, 保密, d956edc7 |
| **Beijing** (BJ) | 6 | ZN, joyjoutek, 资源龙, Steffen, 御所, REYNHOLM |
| **Anhui** (AH) | 5 | Ring B nexus: 琪琪, 电子有线, 电子有线2, 美亚诗, 烤肉 |
| **Henan** (HA) | 5 | yuni, GKinto (Hebi Pair), bigfloor, mad671001. dwf135 |
| **Shanghai** (SH) | 4 | MoqiArtToys, 婷阮测试, ShanghaiTech, goldenladder |
| **Guizhou** (GZ) | 5 | 星ζ哲, 没有公司, 无氧科技, grpppqqq, LugMe (Zunyi Pair) |
| **Zhejiang** (ZJ) | 3 | YUZUKI, It Take Two, 连气瓶 |
| **Guangxi** (GX) | 3 | CCTVb, joey.cn, 广西简约 |
| **Jiangsu** (JS) | 3 | VRZWK, foxilo, 瑞声科技 |
| **Shandong** (SD) | 3 | 山东铯唔, woshiniyeye, SELF |
| **Jiangxi** (JX) | 2 | HMIAN, huleen.net |
| **Fujian** (FJ) | 1 | butter25505 |
| **Shaanxi** (SN) | 2 | 阿白科技, 首搭科技 |
| **Hebei** (HE) | 2 | duanren, 首搭科技 |
| **Hubei** (HB) | 1 | 24098c20 (F1 exploit) |
| **Heilongjiang** (HL) | 1 | XZI (Harbin) |
| **Sichuan** (SC) | 1 | NEW1 (Ring B, claims Shenzhen) |

### November 2025 Creation Wave (14 tenants in 2 weeks)

| Date | Tenant | City |
|------|--------|------|
| Nov 12 | ZN (Ring A) | Beijing |
| Nov 13 | grpppqqq (Zunyi Pair) | Guizhou |
| Nov 13 | LugMe (Zunyi Pair) | Guizhou |
| Nov 13 | butter25505 | Fujian |
| Nov 14 | bigfloor5333 (Haikou Pair) | Hainan |
| Nov 14 | mad671001 (Haikou Pair) | Hainan |
| Nov 14 | QiSoCloud | Guangdong |
| Nov 16 | foxilo | Jiangsu |
| Nov 16 | It Take Two | Zhejiang |
| Nov 16 | 婷阮测试 | Shanghai |
| Nov 17 | MICROSOFT (Ring E) | Guangdong |
| Nov 18 | REYNHOLM INDUSTRIES | Beijing |
| Nov 20 | CCTVb | Guangxi |
| Nov 21 | 资源龙 | Beijing |
| Nov 23 | chilcosta8 | Guangdong |
| Nov 24 | joyjoutek | Beijing |
| Nov 25 | yuni (Hebi Pair) | Henan |
| Dec 03 | jileshe | Guangdong |
| Dec 04 | huleen.net | Jiangxi |

**14 new abusive tenants in 2 weeks (Nov 12-25)** suggests a coordinated wave or shared exploit/tutorial circulating in Chinese forums.

---

## Cost/Revenue Analysis

| Metric | Value |
|--------|-------|
| Total abusive tenants | **162** |
| Total abusive storage (measured subset) | 3.5+ PB |
| Estimated total abusive storage | 5–7 PB |
| Monthly storage cost (Azure eq. $15/TB avg) | $100,000+/month |
| Monthly egress cost (Azure eq. $87/TB Asia) | $300,000+/month |
| Total monthly MSFT infrastructure cost | $400,000+/month |
| Monthly revenue from abusers | <$300/month |
| **Estimated annual cost to Microsoft** | **$5–8M/year** |
| **Blended arbitrage ratio** | **1,000x+** |

### Top 5 Cost Drivers

| Tenant | Storage (TB) | Monthly MSFT Cost | Revenue | Arbitrage |
|--------|-------------|-------------------|---------|-----------|
| 金融城网络 | 865 | $22K | $50 | 441x |
| 保密 | 512 | $11K | $50 | 229x |
| ALLANIME | 49 | $46K (egress!) | $10 | **4,648x** |
| HMIAN+ZN | 393 | $12K | $70 | 171x |
| 连气瓶 | 178 | $3K | $10 | 300x |

---

## Recommended Action Plan

### Phase 1: Critical (12 tenants — >50 TB or ring leaders)

All ABUSE-READONLY-BLOCK-DELETE, UseCaseType 7:

```
20f3bc22-a015-4d5b-a0b2-a18316e6c30c  ALLANIME (130 TB/wk egress)
6a63e133-xxxx (865 TB, cloud reselling)
f38aa9fa-34a2-4cd6-8af2-457470322e9a  保密 (512 TB)
5edb62e7-d4e6-4911-92ff-cb6b3aefe3fe  HMIAN (Ring A, 256 TB, 55M licenses)
7d5d12c2-66e9-4254-be08-3eb9c274fe9a  ZN (Ring A, 137 TB, filling)
a94cb8dc-4c00-4751-8ccb-c24be912119a  连气瓶 (178 TB, Cloudreve)
e439db60-5858-4549-9368-e297f66d8700  duanren (110 TB, rclone)
022daa44-37bc-4305-b011-16ae93d4fa36  It Take Two (79 TB, uploading)
94c5e07d-cb0d-4b1c-94c8-37fbd9056179  bigfloor5333 (62 TB, piracy)
521ba7a8-xxxx (114 TB, anime CDN)
031245e8-xxxx (78 TB, 6 domains)
24098c20-xxxx (135 TB, F1 exploit, INV-014)
```

### Phase 2: Ring Takedown (18 tenants)

```
Ring B (7): f9f1b6da, 21470293, 56a36e88, 8a7f99ee, 44b59163, bd3be752, b67f481a
Ring C (2): c7292335, c2502fae
Ring E (3): c246dfc5, 3d76e686, 8f3f7b4c
iccfree (3): 6a3f3639, 2b64ab07, 2b7a9950
Haikou (1): 8582d095
Pairs (1): a53f727c + 7c5f00c6 (Zunyi)
```

### Phase 3: Individual Abusers + Cloud Operators (remaining 52 tenants)

All remaining confirmed abusive tenants from Tiers 2-4.

### Phase 4: Review

- `17169edd` (ZHEI): 30 TB EDU A1 with m365.lol domain — verify if real EDU institution
- `775629fa` (SZJM): Monitor only

### Phase 5: Additional Confirmed Abusive (85 tenants)

Ingest all 85 additionally-confirmed abusive tenants for ABUSE-READONLY-BLOCK-DELETE. Priority order:
1. Ring H (`fc122104` + `edf6cf4d`) — confirmed Nanjing license fraud + Douyin brand impersonation
2. Ring F members (KMOE, GOOGLEPLEX, SHENGJY, CAPTAINSLEEPY) — 4251001000 phone cluster
3. Ring I members (CHOOL, 云创科技) — .edu.kg EDU fraud
4. Ring B member #8 — newly-linked via D2K
5. Ring E members #4 and #5 — additional brand impersonators
6. Remaining individual abusersrand impersonators
6. Remaining individual abusers
### Phase 6: Wide-List Bulk Scanning (46,487 remaining tenants)

A KQL scoring query has been prepared (`China_Network_Abuse_Scoring.kql`) for execution on Kusto Explorer against `odspfabkusto.eastus.kusto.windows.net / fabdardb`. This will instantly score all 46K tenants using weighted signals:

**Scoring signals:** E5/E3 Dev SKU (+25), Non-Paid storage (+30), Trial storage (+25), License fraud (+30), Storage overage (+30), Brand impersonation (+50), Nov 2025 wave (+20), OnMicrosoft-only (+10), Few users (+15), vs. ISS2200 (-100), VL (-80), ISS500 (-60), EDU legitimate (-50)

**Early sample results (30 tenants scanned via MCP):**
- CRITICAL (≥80): 6.7% → est. 3,100 tenants in full list
- HIGH (50-79): 13.3% → est. 6,200 tenants
- MEDIUM (30-49): 33.3%
- LOW (0-29): 33.3%
- LEGITIMATE (<0): 13.3%

If the sample rate holds, **9,300 high-risk tenants** require action out of the 46K list.

---

## Blocklist Additions

### domains.json
```
dlspup.org, storage.dlspup.org, vip.jrcpan.com, office365.wiki,
11101109.xyz, 123478.xyz, 360233.xyz, cloudpans.onmicrosoft.com,
huohuo-cloud.xyz, eee.7so.top, office.site, od.jileshe.cc,
msvip.v6.navy, v6.tm9.site, s3.tm6.site, yuri.city, e3.sheji.ge,
11101109.xyz, 123478.xyz, 360233.xyz, cloudpans.onmicrosoft.com,
huohuo-cloud.xyz, eee.7so.top, office.site, od.jileshe.cc,
harbinyupai.com, hachina.cc.cd, ms365.plus, office365plus.vip,
nya.ac, coder.moe, zn.al, m365.lol, 8shield.net, srv.pub,
theyouyi.site, yixj.tk, ee.ci, lug.me, naominet.com.cn, octlog.net,
671001.xyz, excal.top
```

### emails.json
```
sheronmorreaugmf12@gmail.com, sheronmorreaygmf12@gmail.com,
biancafrancisops895@gmail.com, 450512013@qq.com, 1045304851@qq.com,
c1@iccfree.com, c3@iccfree.com, 1@163.com, cn1@srv.pub,
mr.hentai@qq.com, pretended_clinking586@8shield.net,
331983711@qq.com, asd5wsew@outlook.com, lickceo@foxmail.com,
mad@671001.xyz, big.floor5333@foshan.gd, i@ee.ci,
qaz2830514940@gmail.com
```

### phone_numbers.json
```
+852 pattern: 85294785989, 85241958459, 85292595840, 85292633512,
85267174732, 85244398669
Ring C: 13040805207
Ring F: 4251001000
Ring H: 15847144678
```

### registration_patterns.json
```
.*@iccfree\.com
.*@8shield\.net
.*@srv\.pub
sheronmorre.*@gmail\.com
biancafrancis.*@gmail\.com
.*cloud.*\.onmicrosoft\.com
cace\d+\.onmicrosoft\.com
```

---

## Appendix: Ingestion Parameters

```
UseCaseType: 7
ICM: [TBD - file new ICM]
isReviewRequired: false
```

All **162**+56: Commercial cloud reselling
- RC 40+34: Brand impersonation
- RC 106: Ring members, Dev SKU abuse, general storage abuse
