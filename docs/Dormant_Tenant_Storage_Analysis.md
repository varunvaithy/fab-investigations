# Dormant Tenant Storage Analysis

**Date**: June 17, 2026  
**Data Source**: `odspfabkusto.eastus.kusto.windows.net` / `fabpartnerdb` (DIM_TENANTS + DimTenant_SiteMetrics)  
**Snapshot Date**: 2026-06-15  
**Definition**: A tenant is "dormant" if it has **zero active sites** across all workloads (SPO, ODB, RaaS) but still has data stored.

---

## Key Numbers

| Metric | Value |
|--------|-------|
| **Total provisioned tenants with stored data** | 13,715,581 |
| **Dormant tenants (zero active sites, data still stored)** | **886,248** |
| **Dormant % of tenants with data** | **6.5%** |
| **Total storage occupied by dormant tenants** | **15,887 TB (~15.5 PB)** |
| **Total platform storage (all tenants)** | ~17.9 EB |
| **Dormant storage as % of total** | ~0.089% |

---

## Dormant Tenants by Segment

| Segment | Dormant Tenants | Storage (TB) | Avg Storage/Tenant |
|---------|---------------:|-------------:|-------------------:|
| **Paid** | 319,731 | 9,160 TB | 29.3 GB |
| **Free/Other** | 424,997 | 6,503 TB | 15.7 GB |
| **EDU** | 7,380 | 193 TB | 26.8 GB |
| **Charity** | 1,044 | 8.5 TB | 8.3 GB |
| **Total** | **~753,152*** | **15,865 TB** | **18.4 GB** |

*\*Remaining ~133K dormant tenants didn't match DIM_TENANTS join (possibly deleted from directory but data retained).*

---

## Storage Concentration (Highly Skewed)

| Storage Bucket | Dormant Tenants | Storage (TB) | % of Dormant Storage |
|---------------|---------------:|-------------:|---------------------:|
| **>1 TB** | 592 | 15,346 TB | **96.6%** |
| 100 GB – 1 TB | 1,282 | 393 TB | 2.5% |
| 10 GB – 100 GB | 3,320 | 112 TB | 0.7% |
| 1 GB – 10 GB | 4,894 | 18 TB | 0.1% |
| 100 MB – 1 GB | 18,674 | 4.5 TB | <0.1% |
| <100 MB | 857,486 | 13 TB | <0.1% |

**Key Insight**: Just **592 tenants** (0.07% of dormant) hold **96.6% of all dormant storage**. These are the high-value remediation targets.

---

## Storage Distribution (Percentiles)

| Percentile | Storage |
|-----------|---------|
| p50 (Median) | 10 MB |
| p75 | 20 MB |
| p90 | 40 MB |
| p95 | 50 MB |
| p99 | 1.7 GB |
| Max | 2,200 TB (single tenant) |
| Average | 18.4 GB |

---

## Top Countries — Paid Dormant Tenants

| Country | Dormant Tenants | Storage (TB) | Avg/Tenant |
|---------|---------------:|-------------:|-----------:|
| **China (CN)** | 74,476 | 2,982 TB | 40 GB |
| **Vietnam (VN)** | 1,440 | 2,798 TB | **1,943 GB** |
| **Hong Kong (HK)** | 7,093 | 1,624 TB | 229 GB |
| United States (US) | 49,066 | 350 TB | 7 GB |
| Taiwan (TW) | 1,071 | 308 TB | 288 GB |
| Singapore (SG) | 2,376 | 292 TB | 123 GB |
| Brazil (BR) | 15,533 | 132 TB | 8 GB |
| Canada (CA) | 2,432 | 119 TB | 49 GB |
| South Africa (ZA) | 745 | 98 TB | 131 GB |
| France (FR) | 5,545 | 58 TB | 10 GB |

**VN stands out**: 1,440 dormant tenants averaging **1.94 TB each** — consistent with known EDU A1 abuse patterns (storage reselling, video hosting). These are likely the same fraud archetypes identified in the YAM Store investigation.

---

## Actionable Findings

### 1. Target the 592 "mega-dormant" tenants (>1 TB each)
- They hold **15.3 PB** combined — 96.6% of all dormant storage
- High overlap with known fraud patterns (CN mining, VN hosting/reselling, HK shell operations)
- **Recommended**: Cross-reference with FAB fraud database; ingest unflagged tenants for investigation

### 2. VN dormant tenants are fraud signals
- 1,440 tenants × 1.94 TB avg = likely EDU A1 abuse (Archetype G, C/G patterns)
- Same operators seen in YAM Store investigation (ms365vip.com, rclone-driven streaming)
- **Recommended**: Batch-check via D2K for commercial domains on EDU licenses

### 3. CN concentration is consistent with known abuse
- 74,476 dormant tenants with ~3 PB of abandoned data
- Likely Chia mining operations (Rule 1) and developer tenant abuse (Rule 2)
- Many already blocked/abandoned after detection — data just hasn't been cleaned up

### 4. 857K tenants with <100MB are low priority
- Mostly system metadata remnants, abandoned trials, dead shells
- Storage cost is negligible (~13 TB total)
- Cleanup is more of a hygiene exercise than cost savings

### 5. All dormant storage has been inactive 1+ year
- The `InactiveStorageFor1Years` field equals total storage for dormant tenants
- This confirms true abandonment — not seasonal inactivity

---

## Cost Impact Estimate

At Azure Blob Storage equivalent rates (~$0.018/GB/month for hot tier):

| Category | Storage | Monthly Cost Equivalent |
|----------|---------|----------------------:|
| All dormant storage | 15,887 TB | ~$293K/month |
| Top 592 mega-dormant | 15,346 TB | ~$283K/month |
| Paid dormant only | 9,160 TB | ~$169K/month |

**Annual opportunity**: ~$3.5M in storage cost recovery if all dormant data is cleaned up, or **~$3.4M** by just addressing the top 592 tenants.

---

## Methodology Notes

- **"Dormant" definition**: Zero `ActiveSites` across all workloads (SPO, ODB, RaaS) in the latest DimTenant_SiteMetrics snapshot (2026-06-15)
- **"Provisioned with data"**: `TotalStorageConsumed > 0` bytes
- **Storage unit**: `TotalStorageConsumed` is in bytes; `StorageLimit` is in MB
- **Excluded**: Tenants already marked `IsFraud = true` are still included in this analysis (they may have been blocked but data not yet purged)
- **Limitation**: This analysis uses site-level activity metrics, not RequestUsage. A tenant with zero "active sites" may still have residual system-level traffic that doesn't count as user activity.
