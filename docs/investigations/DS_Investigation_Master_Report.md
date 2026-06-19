# DS Model Investigation List — Master Report

**Start Date:** April 7, 2026  
**Investigator:** Copilot AI Agent + Varun V  
**ICM Ticket:** [775773500](https://portal.microsofticm.com/imp/v5/incidents/details/775773500/summary)  
**Source:** FAB DS Model flagged 944 tenant IDs for investigation  
**Approach:** Bulk Kusto triage → Ring identification → Per-ring deep-dive → Remediation  

---

## Triage Summary

| Metric | Count |
|--------|-------|
| Total tenants in DS list | 944 |
| Active in last 7 days (RequestUsage) | 713 |
| Dormant (zero activity) | 231 |
| Identified rings/clusters | 6 regional + multiple app-based |

### Egress Tier Distribution (7-day)

| Tier | Tenants | Total Egress |
|------|---------|-------------|
| MEGA (>1 TB/wk) | 35 | 1,889 TB |
| HIGH (100 GB – 1 TB) | 22 | 68 TB |
| MEDIUM (10 – 100 GB) | 90 | 29 TB |
| LOW (1 – 10 GB) | 116 | 4 TB |
| MINIMAL (<1 GB) | 450 | 0.4 TB |
| DORMANT (0) | 231 | 0 TB |

---

## Ring Overview & Status

| Ring | Region | Tenants | 7d Egress | Status | Report |
|------|--------|---------|-----------|--------|--------|
| **Ring 1** | Brazil Streaming CDN | 30 core + 6 outlier | 1,696 TB | **Ingested** (30 tenants, RC 107) | [FAMILIA_CONFEITAR_Ring_Investigation_Report.md](FAMILIA_CONFEITAR_Ring_Investigation_Report.md) |
| **Ring 2** | SPO Paid Storage Abuse | 28 (cross-region) | ~5.9 PB stored | **Investigated** — action pending | [SPO_Paid_Storage_Abuse_Report.md](SPO_Paid_Storage_Abuse_Report.md) |
| *Geo Bucket* | Japan High Egress | 50 | 120 TB | Sub-classified (mostly E5 Dev) | [Ring2_Japan_Investigation_Report.md](Ring2_Japan_Investigation_Report.md) |
| *Geo Bucket* | SE Asia High Egress | 33 | 135 TB | Not Started | *Pending* |
| *Geo Bucket* | Taiwan | 23 | 2.6 TB | Not Started | *Pending* |
| *Geo Bucket* | US Regions | 110 | 30 TB | Not Started | *Pending* |
| *Geo Bucket* | Dormant/Other | 231+ | 0 TB | Not Started | *Pending* |

### Brazil Outliers (Not part of FAMILIA CONFEITAR ring, separate operators)

| Tenant ID | Name | Admin | 7d Egress | Status |
|-----------|------|-------|-----------|--------|
| `784553d3` | TDFLIX COMUNICACOES LTDA | tdflix@outlook.com | 1.4 TB | Pending ingestion |
| `e50e8fb9` | DRIVECOMUNIDADE | dinho.plex@gmail.com | 4.9 TB | Already in FAB (FraudId 133908) |
| `ab3ab555` | DVDTECH | deivide.pereira@outlook.com.br | ~0 | Pending ingestion |
| `2c336f21` | MSFT | labtestes@hotmail.com | ~0 | Pending ingestion |
| `2bc77541` | MSFT | speedtv@outlook.es | ~0 | Pending ingestion |
| `71166d27` | N | natanaelnsg2@gmail.com | ~0 | Pending ingestion |

---

## App Fingerprint Cross-Ring Patterns

These app-based clusters cut across geographic rings and represent potential detection rule candidates.

| App | Tenants | Total Egress | Regions | Rule Potential |
|-----|---------|-------------|---------|----------------|
| **rclone** | 139 | 217 TB | All regions | High — rclone on non-enterprise SKUs is near-100% fraud |
| **androiddownloadmanager** | 69 | 186 TB | Japan, SE Asia | High — bulk download tool, often piracy |
| **synology** | 49 | 13 TB | Japan, Taiwan, SE Asia | Medium — legitimate NAS product, need SKU filtering |
| **RaiDrive** | 25 | 20 TB | All regions | High — cloud drive mounting tool, similar to StableBit |
| **Cloudreve** | 7 | 4.4 TB | Japan, SE Asia, US | High — open-source cloud storage platform, self-hosted piracy |
| **air explorer** | ~5 | ~7 TB | US, Japan | Medium — multi-cloud file manager |
| **OpenBoxLab** | ~5 | ~0 | Brazil | Low (probe-level) — but present on FAMILIA CONFEITAR tenants |
| **Other** (anonymous) | 30+ | 1,696 TB | Brazil | High — Brazil CDN pattern with zero ingress |

### Emerging Detection Rule Candidates

1. **rclone + non-enterprise SKU + high egress** — Near 100% fraud correlation in this dataset
2. **Business Basic/E5-Dev + 1 seat + zero ingress + >10TB egress** — FAMILIA CONFEITAR pattern
3. **Sequential `.onmicrosoft.com` domains with same admin** — Multi-tenant circumvention
4. **Storage >10x quota** — Quota enforcement bypass
5. **androiddownloadmanager as primary app + Japan/SE Asia** — piracy download pattern
6. **Cloudreve app fingerprint** — Self-hosted piracy platform using SPO as backend
7. **RaiDrive/StableBit on non-enterprise** — Cloud drive mounting for reselling
8. **SPO Plan 2 + 1 seat + 100x quota + rclone** — SEEMSONLINE archetype (2 found, $0.018/TB/mo arbitrage)
9. **tenantName = "MSFT" + SG + E5 Dev + no custom domain** — Impersonation cluster (7 found in Ring 2)
10. **E5DEV-OVERQUOTA rolled-back tenants** — Pipeline gap: 5 tenants, 127 TB, all grew unchecked post-rollback

---

## Remediation Log

| Date | Ring | Action | Tenants | FraudIds | RC | ICM |
|------|------|--------|---------|----------|------|-----|
| 2026-04-08 | Ring 1 (FAMILIA CONFEITAR) | ABUSE-READONLY-BLOCK-DELETE | 30 | 148626–148641+ | 107 | 775773500 |
| *pending* | Brazil Outliers | — | 5 | — | 107 | 775773500 |
| 2026-04-08 | Ring 2 — SPO Paid Abuse (13 tenants) | ABUSE-READONLY-BLOCK-DELETE | 13 | *pending* | 107 | 775773500 |
| *separate* | Ring 2 — MISTYCLOUD (11 tenants) | TYPE1 → manual re-route | 11 | 148121+ | 107 | 771980255 |
| *pending* | Japan E5 Dev hoarders batch | ABUSE-READONLY-BLOCK-DELETE | ~30 | — | 107 | 775773500 |
| *pending* | Japan E5DEV-OVERQUOTA re-ingest | ABUSE-READONLY-BLOCK-DELETE | 5 | various | 107 | 775773500 |

---

## Investigation Files

| File | Purpose |
|------|---------|
| [ds_investigation_list_0704.txt](ds_investigation_list_0704.txt) | Master list of 944 tenant IDs from DS |
| [_cluster_report.txt](_cluster_report.txt) | Consolidated Kusto triage — all 944 tenants clustered |
| [_analyze.ps1](_analyze.ps1) | PowerShell script for consolidation/clustering |
| [_brazil_ring_ids.txt](_brazil_ring_ids.txt) | 36 Brazil ring tenant IDs (30 core + 6 outlier) |
| [FAMILIA_CONFEITAR_Ring_Investigation_Report.md](FAMILIA_CONFEITAR_Ring_Investigation_Report.md) | Ring 1 detailed investigation |
| [Ring2_Japan_Investigation_Report.md](Ring2_Japan_Investigation_Report.md) | Japan geo-bucket sub-classification (9 categories, 50 tenants) |
| [SPO_Paid_Storage_Abuse_Report.md](SPO_Paid_Storage_Abuse_Report.md) | Ring 2: SPO Paid Storage Abuse (28 tenants, 5.9 PB, MISTYCLOUD + others) |

---

*This report is updated as each ring investigation completes.*
