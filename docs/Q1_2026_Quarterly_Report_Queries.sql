-- ============================================================================
-- FAB Tenant Service - Q1 2026 Quarterly Remediation Report (Jan 1 - Mar 31, 2026)
-- ============================================================================
-- Run these queries against the production FAB SQL Database (fabdardb)
-- Ensure you have read access to the [FRAUD] schema tables.
-- ============================================================================

-- ============================================================================
-- QUERY 1: Overall Remediation Summary by Action Type
-- Shows total tenants per remediation stage in Q1 2026
-- ============================================================================
SELECT 
    TAS.ACTION AS RemediationAction,
    COUNT(DISTINCT TAS.SITE_SUBSCRIPTION_ID) AS TenantCount,
    SUM(RAW.TENANT_TOTAL_DISK_USED_GB) AS TotalDiskUsedGB,
    SUM(RAW.TENANT_TOTAL_DISK_USED_GB) / (1024.0) AS TotalDiskUsedTB,
    SUM(RAW.TENANT_TOTAL_DISK_USED_GB) / (1024.0 * 1024.0) AS TotalDiskUsedPB,
    SUM(RAW.STORAGE_LIMIT_GB) AS TotalStorageLimitGB,
    SUM(RAW.ODBDISKUSED_SUM_GB) AS TotalODBDiskUsedGB,
    AVG(RAW.TENANT_TOTAL_DISK_USED_GB) AS AvgDiskUsedPerTenantGB
FROM FRAUD.TENANT_ACTIONS_SCHD TAS
JOIN FRAUD.FRAUD_TENANT_DETAILS FTD ON FTD.FRAUD_ID = TAS.FRAUD_ID
JOIN FRAUD.TENANT_DETAILS_RAW RAW ON RAW.RAW_ID = FTD.RAW_ID
WHERE TAS.STATUS = 1  -- Successfully performed
    AND TAS.PERFORMED_DATE >= '2026-01-01' 
    AND TAS.PERFORMED_DATE < '2026-04-01'
    AND FTD.STATUS != 99
GROUP BY TAS.ACTION
ORDER BY TenantCount DESC;


-- ============================================================================
-- QUERY 2: Remediation by Action Type AND Use Case Type
-- Detailed breakdown: ReadOnly / Block / Delete x ABUSE-READONLY-BLOCK, TYPE1, etc.
-- ============================================================================
SELECT 
    TAS.ACTION AS RemediationAction,
    FTD.USECASE_TYPE,
    COUNT(DISTINCT TAS.SITE_SUBSCRIPTION_ID) AS TenantCount,
    SUM(RAW.TENANT_TOTAL_DISK_USED_GB) AS TotalDiskUsedGB,
    SUM(RAW.TENANT_TOTAL_DISK_USED_GB) / (1024.0) AS TotalDiskUsedTB,
    SUM(RAW.STORAGE_LIMIT_GB) AS TotalStorageLimitGB
FROM FRAUD.TENANT_ACTIONS_SCHD TAS
JOIN FRAUD.FRAUD_TENANT_DETAILS FTD ON FTD.FRAUD_ID = TAS.FRAUD_ID
JOIN FRAUD.TENANT_DETAILS_RAW RAW ON RAW.RAW_ID = FTD.RAW_ID
WHERE TAS.STATUS = 1
    AND TAS.PERFORMED_DATE >= '2026-01-01' 
    AND TAS.PERFORMED_DATE < '2026-04-01'
    AND FTD.STATUS != 99
GROUP BY TAS.ACTION, FTD.USECASE_TYPE
ORDER BY TAS.ACTION, TenantCount DESC;


-- ============================================================================
-- QUERY 3: Remediation by Tenant Level (Paid / Non-Paid / Trial / Free)
-- ============================================================================
SELECT 
    TAS.ACTION AS RemediationAction,
    FTF.LEVEL AS TenantLevel,
    COUNT(DISTINCT TAS.SITE_SUBSCRIPTION_ID) AS TenantCount,
    SUM(RAW.TENANT_TOTAL_DISK_USED_GB) AS TotalDiskUsedGB,
    SUM(RAW.TENANT_TOTAL_DISK_USED_GB) / (1024.0) AS TotalDiskUsedTB
FROM FRAUD.TENANT_ACTIONS_SCHD TAS
JOIN FRAUD.FRAUD_TENANT_DETAILS FTD ON FTD.FRAUD_ID = TAS.FRAUD_ID
JOIN FRAUD.TENANT_DETAILS_RAW RAW ON RAW.RAW_ID = FTD.RAW_ID
JOIN FRAUD.FRAUD_TENANT_FLAGS FTF ON FTF.SITE_SUBSCRIPTION_ID = FTD.SITE_SUBSCRIPTION_ID
WHERE TAS.STATUS = 1
    AND TAS.PERFORMED_DATE >= '2026-01-01' 
    AND TAS.PERFORMED_DATE < '2026-04-01'
    AND FTD.STATUS != 99
GROUP BY TAS.ACTION, FTF.LEVEL
ORDER BY TAS.ACTION, TenantCount DESC;


-- ============================================================================
-- QUERY 4: Monthly Trend within Q1 2026
-- Shows remediation volume per month per action
-- ============================================================================
SELECT 
    DATEPART(MONTH, TAS.PERFORMED_DATE) AS MonthNum,
    DATENAME(MONTH, TAS.PERFORMED_DATE) AS MonthName,
    TAS.ACTION AS RemediationAction,
    COUNT(DISTINCT TAS.SITE_SUBSCRIPTION_ID) AS TenantCount,
    SUM(RAW.TENANT_TOTAL_DISK_USED_GB) AS TotalDiskUsedGB,
    SUM(RAW.TENANT_TOTAL_DISK_USED_GB) / (1024.0) AS TotalDiskUsedTB
FROM FRAUD.TENANT_ACTIONS_SCHD TAS
JOIN FRAUD.FRAUD_TENANT_DETAILS FTD ON FTD.FRAUD_ID = TAS.FRAUD_ID
JOIN FRAUD.TENANT_DETAILS_RAW RAW ON RAW.RAW_ID = FTD.RAW_ID
WHERE TAS.STATUS = 1
    AND TAS.PERFORMED_DATE >= '2026-01-01' 
    AND TAS.PERFORMED_DATE < '2026-04-01'
    AND FTD.STATUS != 99
GROUP BY DATEPART(MONTH, TAS.PERFORMED_DATE), DATENAME(MONTH, TAS.PERFORMED_DATE), TAS.ACTION
ORDER BY MonthNum, TAS.ACTION;


-- ============================================================================
-- QUERY 5: Blocked Tenants Only (Active Blocks, excl. those already Deleted)
-- Mirrors the logic in existing BlockedTenantsAgg_Varsha view
-- ============================================================================
WITH RankedBlocks AS (
    SELECT 
        CAST(TAS.PERFORMED_DATE AS DATE) AS BlockedDate,
        FTD.USECASE_TYPE,
        FTF.LEVEL,
        TAS.SITE_SUBSCRIPTION_ID,
        RAW.TENANT_TOTAL_DISK_USED_GB,
        RAW.TENANT_CATEGORY,
        RAW.COUNTRY,
        ROW_NUMBER() OVER (
            PARTITION BY TAS.SITE_SUBSCRIPTION_ID 
            ORDER BY TAS.PERFORMED_DATE DESC
        ) AS rn
    FROM FRAUD.TENANT_ACTIONS_SCHD TAS
    JOIN FRAUD.FRAUD_TENANT_DETAILS FTD ON FTD.FRAUD_ID = TAS.FRAUD_ID
    JOIN FRAUD.TENANT_DETAILS_RAW RAW ON RAW.RAW_ID = FTD.RAW_ID
    JOIN FRAUD.FRAUD_TENANT_FLAGS FTF ON FTF.SITE_SUBSCRIPTION_ID = FTD.SITE_SUBSCRIPTION_ID
    WHERE TAS.ACTION = 'Block'
        AND TAS.STATUS = 1
        AND TAS.PERFORMED_DATE >= '2026-01-01' 
        AND TAS.PERFORMED_DATE < '2026-04-01'
        AND NOT EXISTS (
            SELECT 1 FROM FRAUD.TENANT_ACTIONS_SCHD T2
            WHERE T2.SITE_SUBSCRIPTION_ID = TAS.SITE_SUBSCRIPTION_ID
              AND T2.ACTION = 'Delete' AND T2.STATUS = 1
        )
        AND FTD.STATUS != 99
        AND FTD.USECASE_TYPE != 'E5DEV-OVERQUOTA'
)
SELECT
    USECASE_TYPE,
    LEVEL AS TenantLevel,
    COUNT(SITE_SUBSCRIPTION_ID) AS BlockedTenants,
    SUM(TENANT_TOTAL_DISK_USED_GB) AS TotalDiskUsedGB,
    SUM(TENANT_TOTAL_DISK_USED_GB) / (1024.0) AS TotalDiskUsedTB,
    SUM(TENANT_TOTAL_DISK_USED_GB) / (1024.0 * 1024.0) AS TotalDiskUsedPB
FROM RankedBlocks
WHERE rn = 1
GROUP BY USECASE_TYPE, LEVEL
ORDER BY USECASE_TYPE, BlockedTenants DESC;


-- ============================================================================
-- QUERY 6: Country/Region Breakdown of Remediated Tenants
-- ============================================================================
SELECT 
    RAW.COUNTRY,
    RAW.COUNTRY_CODE,
    TAS.ACTION AS RemediationAction,
    COUNT(DISTINCT TAS.SITE_SUBSCRIPTION_ID) AS TenantCount,
    SUM(RAW.TENANT_TOTAL_DISK_USED_GB) AS TotalDiskUsedGB
FROM FRAUD.TENANT_ACTIONS_SCHD TAS
JOIN FRAUD.FRAUD_TENANT_DETAILS FTD ON FTD.FRAUD_ID = TAS.FRAUD_ID
JOIN FRAUD.TENANT_DETAILS_RAW RAW ON RAW.RAW_ID = FTD.RAW_ID
WHERE TAS.STATUS = 1
    AND TAS.PERFORMED_DATE >= '2026-01-01' 
    AND TAS.PERFORMED_DATE < '2026-04-01'
    AND FTD.STATUS != 99
GROUP BY RAW.COUNTRY, RAW.COUNTRY_CODE, TAS.ACTION
HAVING COUNT(DISTINCT TAS.SITE_SUBSCRIPTION_ID) >= 5
ORDER BY TenantCount DESC;


-- ============================================================================
-- QUERY 7: Tenant Category Breakdown (EDU / Commercial)
-- ============================================================================
SELECT 
    RAW.TENANT_CATEGORY,
    TAS.ACTION AS RemediationAction,
    COUNT(DISTINCT TAS.SITE_SUBSCRIPTION_ID) AS TenantCount,
    SUM(RAW.TENANT_TOTAL_DISK_USED_GB) AS TotalDiskUsedGB,
    SUM(RAW.TENANT_TOTAL_DISK_USED_GB) / (1024.0) AS TotalDiskUsedTB,
    SUM(CAST(RAW.LICENSES_ACQUIRED AS BIGINT)) AS TotalLicensesAcquired,
    SUM(CAST(RAW.LICENSES_ENABLED AS BIGINT)) AS TotalLicensesEnabled
FROM FRAUD.TENANT_ACTIONS_SCHD TAS
JOIN FRAUD.FRAUD_TENANT_DETAILS FTD ON FTD.FRAUD_ID = TAS.FRAUD_ID
JOIN FRAUD.TENANT_DETAILS_RAW RAW ON RAW.RAW_ID = FTD.RAW_ID
WHERE TAS.STATUS = 1
    AND TAS.PERFORMED_DATE >= '2026-01-01' 
    AND TAS.PERFORMED_DATE < '2026-04-01'
    AND FTD.STATUS != 99
GROUP BY RAW.TENANT_CATEGORY, TAS.ACTION
ORDER BY RAW.TENANT_CATEGORY, TenantCount DESC;


-- ============================================================================
-- QUERY 8: Pipeline Funnel - Tenants Identified vs Remediated in Q1 2026
-- How many were identified in Q1 vs how many actually got remediated
-- ============================================================================
SELECT 
    'Identified in Q1 2026' AS Metric,
    COUNT(*) AS TenantCount
FROM FRAUD.FRAUD_TENANT_DETAILS FTD
WHERE FTD.IDENTIFIED_DATE >= '2026-01-01' AND FTD.IDENTIFIED_DATE < '2026-04-01'

UNION ALL

SELECT 
    'Remediation Started in Q1 2026' AS Metric,
    COUNT(*) AS TenantCount
FROM FRAUD.FRAUD_TENANT_DETAILS FTD
WHERE FTD.REMEDIATION_START_DATE >= '2026-01-01' AND FTD.REMEDIATION_START_DATE < '2026-04-01'

UNION ALL

SELECT 
    'Actions Performed in Q1 2026' AS Metric,
    COUNT(DISTINCT TAS.SITE_SUBSCRIPTION_ID) AS TenantCount
FROM FRAUD.TENANT_ACTIONS_SCHD TAS
WHERE TAS.STATUS = 1
    AND TAS.PERFORMED_DATE >= '2026-01-01' AND TAS.PERFORMED_DATE < '2026-04-01'

UNION ALL

SELECT 
    'False Positives in Q1 2026' AS Metric,
    COUNT(*) AS TenantCount
FROM FRAUD.FRAUD_TENANT_DETAILS FTD
WHERE FTD.STATUS = 7
    AND FTD.LAST_MODIFIED_DATE >= '2026-01-01' AND FTD.LAST_MODIFIED_DATE < '2026-04-01';


-- ============================================================================
-- QUERY 9: Average Time to Remediate (Days from Identification to Action)
-- ============================================================================
SELECT 
    TAS.ACTION AS RemediationAction,
    COUNT(DISTINCT TAS.SITE_SUBSCRIPTION_ID) AS TenantCount,
    AVG(DATEDIFF(DAY, FTD.IDENTIFIED_DATE, TAS.PERFORMED_DATE)) AS AvgDaysToRemediate,
    MIN(DATEDIFF(DAY, FTD.IDENTIFIED_DATE, TAS.PERFORMED_DATE)) AS MinDaysToRemediate,
    MAX(DATEDIFF(DAY, FTD.IDENTIFIED_DATE, TAS.PERFORMED_DATE)) AS MaxDaysToRemediate
FROM FRAUD.TENANT_ACTIONS_SCHD TAS
JOIN FRAUD.FRAUD_TENANT_DETAILS FTD ON FTD.FRAUD_ID = TAS.FRAUD_ID
WHERE TAS.STATUS = 1
    AND TAS.PERFORMED_DATE >= '2026-01-01' 
    AND TAS.PERFORMED_DATE < '2026-04-01'
    AND FTD.STATUS != 99
    AND FTD.IDENTIFIED_DATE IS NOT NULL
GROUP BY TAS.ACTION;


-- ============================================================================
-- QUERY 10: Failure Analysis - Failed remediation actions in Q1 2026
-- ============================================================================
SELECT 
    TAS.ACTION AS RemediationAction,
    COUNT(*) AS FailedAttempts,
    COUNT(DISTINCT TAS.SITE_SUBSCRIPTION_ID) AS UniqueTenantsAffected
FROM FRAUD.TENANT_ACTIONS_SCHD TAS
WHERE TAS.STATUS != 1  -- Not successful
    AND TAS.PERFORMED_DATE >= '2026-01-01' 
    AND TAS.PERFORMED_DATE < '2026-04-01'
GROUP BY TAS.ACTION
ORDER BY FailedAttempts DESC;
