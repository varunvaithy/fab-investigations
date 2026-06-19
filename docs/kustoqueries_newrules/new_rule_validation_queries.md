# New Rule Validation Queries

Run these to stress-test Tier 1 and Tier 2 net-new rule recommendations with production data.

**Save results as CSV to `docs/kustoqueries_newrules/` using the query ID as filename (e.g., S1.csv).**

---

## SpoProd Kusto (4 queries)

Cluster: `https://spogdskustocluster.eastus2.kusto.windows.net` / Database: `spoprod`

### S1 — Rule 1b: CDN consumption UAs with volume threshold

Answers: Of the 24K tenants using androiddownloadmanager/stagefright/applecoremedia, how many actually have high enough volume to flag?

```kql
let lookback = 7d;
RequestUsage
| where env_time >= ago(lookback)
| where app has "androiddownloadmanager" 
     or app has "stagefright" 
     or app has "applecoremedia"
| summarize 
    EgressGB = sum(blobReadBytes) / (1024.0 * 1024 * 1024),
    IngressGB = sum(blobWriteBytes) / (1024.0 * 1024 * 1024),
    Requests = count()
    by siteSubscriptionId
| where IngressGB < 0.001  // zero ingress
| summarize 
    TotalTenants = count(),
    Over100GB = countif(EgressGB > 100),
    Over10GB = countif(EgressGB > 10),
    Over1GB = countif(EgressGB > 1),
    TotalEgressTB = sum(EgressGB) / 1024.0
```

### S2 — Rule 3: CDN score at scale (egress:ingress ratio)

Answers: How many tenants have extreme egress:ingress ratios? Is this signal noisy or clean?

```kql
let lookback = 7d;
RequestUsage
| where env_time >= ago(lookback)
| summarize 
    EgressGB = sum(blobReadBytes) / (1024.0 * 1024 * 1024),
    IngressGB = sum(blobWriteBytes) / (1024.0 * 1024 * 1024)
    by siteSubscriptionId
| where EgressGB > 10  // pre-filter to avoid timeout
| extend Ratio = iff(IngressGB > 0.001, EgressGB / IngressGB, 99999.0)
| summarize
    TotalTenants = count(),
    Ratio_Over100 = countif(Ratio > 100),
    Ratio_Over50 = countif(Ratio > 50),
    Ratio_Over10 = countif(Ratio > 10),
    StorageTB_Over100Ratio = sumif(EgressGB, Ratio > 100) / 1024.0,
    StorageTB_Over50Ratio = sumif(EgressGB, Ratio > 50) / 1024.0
```

### S3 — Rule 5: Storage growth rate (rapid writers)

Answers: How many tenants are writing >1TB/week? Where's the right threshold?

```kql
let lookback = 7d;
RequestUsage
| where env_time >= ago(lookback)
| summarize 
    WriteGB = sum(blobWriteBytes) / (1024.0 * 1024 * 1024),
    ReadGB = sum(blobReadBytes) / (1024.0 * 1024 * 1024),
    Users = dcount(userKey)
    by siteSubscriptionId
| where WriteGB > 1024  // >1 TB written in 7 days
| summarize
    TotalTenants = count(),
    Over5TB = countif(WriteGB > 5120),
    Over10TB = countif(WriteGB > 10240),
    TotalWriteTB = sum(WriteGB) / 1024.0,
    AvgUsers = avg(Users)
| extend AvgUsers = round(AvgUsers, 1)
```

### S4 — Rule 1c: rclone compound (rclone tenants with low user counts)

Answers: How many of the 10K rclone tenants survive a compound filter?

```kql
let lookback = 7d;
RequestUsage
| where env_time >= ago(lookback)
| where app has "rclone"
| summarize 
    EgressGB = sum(blobReadBytes) / (1024.0 * 1024 * 1024),
    IngressGB = sum(blobWriteBytes) / (1024.0 * 1024 * 1024),
    Users = dcount(userKey),
    Requests = count()
    by siteSubscriptionId
| summarize
    TotalTenants = count(),
    SingleUser = countif(Users == 1),
    Under5Users = countif(Users < 5),
    Over100GB_Under5Users = countif(EgressGB > 100 and Users < 5),
    Over1TB_Under5Users = countif((EgressGB + IngressGB) > 1024 and Users < 5),
    EgressTB_Under5Users = sumif(EgressGB, Users < 5) / 1024.0
```

---

## D2K Kusto (4 queries)

Cluster: `https://idsharedwus.kusto.windows.net` / Database: `D2KRedacted`

### D1 — Rule 2: Provisioning velocity

Answers: How common is 3+ tenants per admin email? What's the population?

```kql
TENANT_INFO
| where TENANT_CREATED_DATE > ago(180d)
| where isnotempty(ADMIN_EMAIL)
| summarize 
    TenantCount = dcount(OMS_TENANT_ID),
    Countries = dcount(COUNTRY_CODE),
    FirstCreated = min(TENANT_CREATED_DATE),
    LastCreated = max(TENANT_CREATED_DATE)
    by AdminEmail = tolower(ADMIN_EMAIL)
| where TenantCount >= 3
| extend DaysSpan = datetime_diff('day', LastCreated, FirstCreated)
| summarize
    EmailsWith3Plus = count(),
    EmailsWith5Plus = countif(TenantCount >= 5),
    EmailsWith10Plus = countif(TenantCount >= 10),
    EmailsWith50Plus = countif(TenantCount >= 50),
    TotalTenantsCovered = sum(TenantCount),
    AvgTenantsPerEmail = round(avg(TenantCount), 1),
    MultiCountry = countif(Countries > 1)
```

### D2 — Rule 6: Admin email clustering (cross-shard)

Answers: How many admin emails appear across multiple D2K shards?

```kql
TENANT_INFO
| where isnotempty(ADMIN_EMAIL)
| summarize 
    TenantCount = dcount(OMS_TENANT_ID),
    Shards = dcount(D2KINSTANCE),
    ShardList = make_set(D2KINSTANCE, 10),
    Countries = dcount(COUNTRY_CODE)
    by AdminEmail = tolower(ADMIN_EMAIL)
| where Shards >= 2 and TenantCount >= 3
| summarize
    TotalEmails = count(),
    TotalTenants = sum(TenantCount),
    AvgShards = round(avg(Shards), 1),
    MultiCountry = countif(Countries > 1),
    Over10Tenants = countif(TenantCount >= 10)
```

### D3 — Rule 8: Shared phone number clusters

Answers: How many phone numbers are shared across 3+ tenants?

```kql
TENANT_INFO
| where isnotempty(PHONE_NUMBER)
| summarize 
    TenantCount = dcount(OMS_TENANT_ID),
    Countries = dcount(COUNTRY_CODE),
    Emails = dcount(ADMIN_EMAIL)
    by PHONE_NUMBER
| where TenantCount >= 3
| summarize
    PhonesWith3Plus = count(),
    PhonesWith5Plus = countif(TenantCount >= 5),
    PhonesWith10Plus = countif(TenantCount >= 10),
    TotalTenantsCovered = sum(TenantCount),
    MultiCountry = countif(Countries > 1),
    MultiEmail = countif(Emails > 1)
```

### D4 — Rule 4: Gibberish names at scale

Answers: Short tenant names with high storage on D2K — how many, what SKUs?

```kql
TENANT_INFO
| where strlen(COMPANY_NAME) > 0
| extend NameLen = strlen(COMPANY_NAME)
| where NameLen <= 4
    and TENANT_TOTAL_DISK_USED_GB > 1000  // >1 TB
    and (TOTAL_ACTIVATED_USERS < 5 or isnull(TOTAL_ACTIVATED_USERS))
| summarize
    TotalTenants = count(),
    TotalStorageTB = sum(TENANT_TOTAL_DISK_USED_GB) / 1024.0,
    AvgStorageGB = round(avg(TENANT_TOTAL_DISK_USED_GB), 0),
    NeverPaid = countif(toupper(coalesce(HAS_EVER_PAID, "FALSE")) == "FALSE"),
    OnmsftOnly = countif(HAS_ONLY_ONMICROSOFT_DOMAIN == true)
    by TENANT_LEVEL
| order by TotalStorageTB desc
```

---

## fabdardb SQL (5 queries)

Server: `fabdardbsvr.database.windows.net` / Database: `FAB_DAR_DB`

### F1 — Rule 4: Gibberish name fraud correlation

Answers: Is short tenant name correlated with fraud?

```sql
SELECT 
    CASE 
        WHEN LEN(r.TENANT_NAME) <= 4 THEN '1-4 chars'
        WHEN LEN(r.TENANT_NAME) <= 8 THEN '5-8 chars'
        WHEN LEN(r.TENANT_NAME) <= 15 THEN '9-15 chars'
        ELSE '16+ chars'
    END AS NameBucket,
    COUNT(*) AS TotalTenants,
    SUM(CASE WHEN f.FRAUD_ID IS NOT NULL THEN 1 ELSE 0 END) AS FraudTenants,
    CAST(100.0 * SUM(CASE WHEN f.FRAUD_ID IS NOT NULL THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0) AS DECIMAL(5,2)) AS FraudPct,
    SUM(CAST(r.TENANT_TOTAL_DISK_USED_GB AS BIGINT)) / 1024 AS TotalStorageTB
FROM [FRAUD].[TENANT_DETAILS_RAW] r
LEFT JOIN [FRAUD].[FRAUD_TENANT_DETAILS] f ON r.RAW_ID = f.RAW_ID
GROUP BY CASE 
        WHEN LEN(r.TENANT_NAME) <= 4 THEN '1-4 chars'
        WHEN LEN(r.TENANT_NAME) <= 8 THEN '5-8 chars'
        WHEN LEN(r.TENANT_NAME) <= 15 THEN '9-15 chars'
        ELSE '16+ chars'
    END
ORDER BY NameBucket
```

### F2 — Rule 7: Brand impersonation

Answers: Are there Microsoft-mimicking tenant names with storage that we haven't caught?

```sql
SELECT 
    r.TENANT_NAME, r.CURRENT_DEFAULT_DOMAIN, r.TENANT_TYPE,
    r.TENANT_TOTAL_DISK_USED_GB, r.TOTAL_ACTIVATED_USERS, r.HAS_EVER_PAID,
    CASE WHEN f.FRAUD_ID IS NOT NULL THEN 'In FAB' ELSE 'NOT in FAB' END AS FABStatus
FROM [FRAUD].[TENANT_DETAILS_RAW] r
LEFT JOIN [FRAUD].[FRAUD_TENANT_DETAILS] f ON r.RAW_ID = f.RAW_ID
WHERE (r.TENANT_NAME LIKE '%microsoft%' 
    OR r.TENANT_NAME LIKE '%m365%' 
    OR r.TENANT_NAME LIKE '%office365%'
    OR r.TENANT_NAME LIKE '%azure founder%'
    OR r.CURRENT_DEFAULT_DOMAIN LIKE '%ms365vip%'
    OR r.CURRENT_DEFAULT_DOMAIN LIKE '%msdrive%'
    OR r.CURRENT_DEFAULT_DOMAIN LIKE '%poweramsonline%')
  AND r.TENANT_TOTAL_DISK_USED_GB > 100
ORDER BY r.TENANT_TOTAL_DISK_USED_GB DESC
```

### F3 — Rule 8: Onmicrosoft-only fraud correlation

Answers: Is having only an onmicrosoft domain correlated with fraud?

```sql
SELECT 
    CASE WHEN r.HAS_ONLY_ONMICROSOFT_DOMAIN = 1 THEN 'Onmicrosoft Only' 
         WHEN r.HAS_ONLY_ONMICROSOFT_DOMAIN = 0 THEN 'Has Custom Domain'
         ELSE 'Unknown' END AS DomainType,
    COUNT(*) AS TotalTenants,
    SUM(CASE WHEN f.FRAUD_ID IS NOT NULL THEN 1 ELSE 0 END) AS FraudTenants,
    CAST(100.0 * SUM(CASE WHEN f.FRAUD_ID IS NOT NULL THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0) AS DECIMAL(5,2)) AS FraudPct,
    SUM(CAST(r.TENANT_TOTAL_DISK_USED_GB AS BIGINT)) / 1024 AS TotalStorageTB
FROM [FRAUD].[TENANT_DETAILS_RAW] r
LEFT JOIN [FRAUD].[FRAUD_TENANT_DETAILS] f ON r.RAW_ID = f.RAW_ID
GROUP BY CASE WHEN r.HAS_ONLY_ONMICROSOFT_DOMAIN = 1 THEN 'Onmicrosoft Only' 
              WHEN r.HAS_ONLY_ONMICROSOFT_DOMAIN = 0 THEN 'Has Custom Domain'
              ELSE 'Unknown' END
```

### F4 — Rule 1c: Compound filter profile in FAB

Answers: What does the fraud population look like under compound-filter conditions (>10TB, <5 MAU, never paid)?

```sql
SELECT 
    r.TENANT_TYPE,
    COUNT(*) AS FraudTenants,
    SUM(CAST(r.TENANT_TOTAL_DISK_USED_GB AS BIGINT)) / 1024 AS StorageTB,
    AVG(ISNULL(r.TOTAL_ACTIVATED_USERS, 0)) AS AvgMAU,
    SUM(CASE WHEN ISNULL(r.HAS_EVER_PAID, 'false') = 'false' THEN 1 ELSE 0 END) AS NeverPaid
FROM [FRAUD].[FRAUD_TENANT_DETAILS] f
JOIN [FRAUD].[TENANT_DETAILS_RAW] r ON f.RAW_ID = r.RAW_ID
WHERE f.FRAUD_REASON_CODE = 96
  AND ISNULL(r.TOTAL_ACTIVATED_USERS, 0) < 5
  AND r.TENANT_TOTAL_DISK_USED_GB > 10240  -- >10 TB
  AND ISNULL(r.HAS_EVER_PAID, 'false') = 'false'
GROUP BY r.TENANT_TYPE
ORDER BY StorageTB DESC
```

### F5 — SKU expansion dry-run (validates Section 6 #1 recommendation)

Answers: How many tenants match Rule 4's logic on uncovered SKUs and aren't in FAB?

```sql
SELECT 
    r.TENANT_TYPE,
    COUNT(*) AS MatchingTenants,
    SUM(CAST(r.TENANT_TOTAL_DISK_USED_GB AS BIGINT)) / 1024 AS TotalStorageTB
FROM [FRAUD].[TENANT_DETAILS_RAW] r
WHERE r.TENANT_TOTAL_DISK_USED_GB > 20480
  AND ISNULL(r.TOTAL_ACTIVATED_USERS, 0) < 5
  AND r.TENANT_TYPE NOT IN ('E5 DEVELOPER', 'E3 DEVELOPER', 'E3 DEVELOPER FREE', 'A1', 'A3',
                             'BUSINESS BASIC', 'BUSINESS STANDARD', 'BUSINESS PREMIUM')
  AND r.SITE_SUBSCRIPTION_ID NOT IN (
      SELECT SITE_SUBSCRIPTION_ID FROM [FRAUD].[FRAUD_TENANT_DETAILS]
  )
GROUP BY r.TENANT_TYPE
ORDER BY TotalStorageTB DESC
```

---

## Summary: What each query validates

| Query | Rule | Key question | Green light | Red flag |
|---|---|---|---|---|
| S1 | 1b CDN UAs | How many exceed 100GB egress? | 50-500 tenants | 10K+ |
| S2 | 3 CDN Score | How many tenants have >100:1 ratio? | Hundreds with high egress | Tens of thousands |
| S3 | 5 Growth rate | How many write >5TB/week? | Dozens-hundreds | Thousands |
| S4 | 1c rclone | How many rclone + <5 users? | <1K | 5K+ |
| D1 | 2 Provisioning velocity | How common is 3+ tenants/email? | Hundreds of emails | Millions |
| D2 | 6 Email clustering | Multi-shard emails? | Clear clustering | No multi-shard overlap |
| D3 | 8 Registration anomaly | Shared phone clusters? | Concentrated clusters | Uniform distribution |
| D4 | 4 Gibberish names | Short names + high storage? | High fraud % in ≤4-char | No correlation |
| F1 | 4 Gibberish names | What % of short names are fraud? | 10x+ fraud rate vs 16+ chars | Flat across buckets |
| F2 | 7 Brand impersonation | MS-mimicking names not in FAB? | Specific unflagged tenants | All already caught |
| F3 | 8 Registration anomaly | Onmicrosoft-only = fraud? | Higher fraud % | No difference |
| F4 | 1c rclone | Compound-filter fraud profile | Matches investigation profile | Scattered |
| F5 | SKU expansion | Rule 4 on uncovered SKUs | PBs of undetected storage | Nothing there |
