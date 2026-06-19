-- ============================================================================
-- De-Auth'd Tenant FAB Overlap Investigation
-- Run on SSMS (SAW) against FAB_DAR_DB (fabdarsqldbprod)
-- Date: May 19, 2026
-- Purpose: Check how many de-auth'd tenants (DirectoryFeatures=66) 
--          are already in FAB, their status, and identify gaps
-- ============================================================================
-- 
-- PREREQUISITE: 
--   1. Run KQL Query 7 from deauth_tenant_storage_check.kql on your SAW
--   2. Export results to CSV
--   3. Bulk import that CSV into a temp table (see Step 1 below)
--   OR use the deauth_abuse_tenant_ids.txt file directly (50K IDs from D2K)
-- ============================================================================


-- ─────────────────────────────────────────────────────────────────────────────
-- STEP 1: Create temp table and load de-auth'd tenant IDs
-- Option A: Bulk insert from the txt file (one GUID per line)
-- Option B: Load from KQL export CSV
-- ─────────────────────────────────────────────────────────────────────────────

-- Drop if exists from previous run
IF OBJECT_ID('tempdb..#DeauthTenants') IS NOT NULL DROP TABLE #DeauthTenants;

CREATE TABLE #DeauthTenants (
    OMS_TENANT_ID UNIQUEIDENTIFIER NOT NULL
);

-- Option A: Load from txt file (50K tenant IDs extracted from D2K)
-- Copy deauth_abuse_tenant_ids.txt to your SAW first
-- Adjust path to wherever you place it on the SAW
BULK INSERT #DeauthTenants
FROM 'C:\Temp\deauth_abuse_tenant_ids.txt'
WITH (
    FIELDTERMINATOR = '\n',
    ROWTERMINATOR = '\n',
    FIRSTROW = 1
);

-- Verify count
SELECT COUNT(*) AS DeauthTenantCount FROM #DeauthTenants;
GO


-- ─────────────────────────────────────────────────────────────────────────────
-- QUERY 1: How many de-auth'd tenants are already in FAB?
-- ─────────────────────────────────────────────────────────────────────────────
SELECT 
    'Summary' AS Category,
    COUNT(*) AS TotalDeauthInFAB,
    SUM(CASE WHEN ftd.TENANT_VALIDATION_STATUS IN (4, 5) THEN 1 ELSE 0 END) AS AlreadyDeleted,
    SUM(CASE WHEN ftd.TENANT_VALIDATION_STATUS = 3 THEN 1 ELSE 0 END) AS Blocked,
    SUM(CASE WHEN ftd.TENANT_VALIDATION_STATUS = 2 THEN 1 ELSE 0 END) AS ReadOnly,
    SUM(CASE WHEN ftd.TENANT_VALIDATION_STATUS IN (0, 1) THEN 1 ELSE 0 END) AS Pending,
    SUM(CASE WHEN ftd.TENANT_VALIDATION_STATUS = 99 THEN 1 ELSE 0 END) AS Identified
FROM [fraud].[FRAUD_TENANT_DETAILS] ftd
INNER JOIN #DeauthTenants dt ON ftd.OMS_TENANT_ID = dt.OMS_TENANT_ID;
GO


-- ─────────────────────────────────────────────────────────────────────────────
-- QUERY 2: De-auth'd tenants NOT in FAB at all (the gap)
-- ─────────────────────────────────────────────────────────────────────────────
SELECT 
    COUNT(*) AS DeauthNotInFAB
FROM #DeauthTenants dt
LEFT JOIN [fraud].[FRAUD_TENANT_DETAILS] ftd ON dt.OMS_TENANT_ID = ftd.OMS_TENANT_ID
WHERE ftd.OMS_TENANT_ID IS NULL;
GO


-- ─────────────────────────────────────────────────────────────────────────────
-- QUERY 3: De-auth'd tenants in FAB — breakdown by status and reason code
-- ─────────────────────────────────────────────────────────────────────────────
SELECT 
    ftd.TENANT_VALIDATION_STATUS,
    tsc.STATUS_DESCRIPTION,
    frc.FRAUD_REASON_DESCRIPTION,
    ftd.FRAUD_REASON_CODE,
    COUNT(*) AS TenantCount,
    SUM(CAST(ftd.TENANT_TOTAL_DISK_USED_GB AS FLOAT)) AS TotalDiskUsedGB
FROM [fraud].[FRAUD_TENANT_DETAILS] ftd
INNER JOIN #DeauthTenants dt ON ftd.OMS_TENANT_ID = dt.OMS_TENANT_ID
LEFT JOIN [fraud].[TENANT_STATUS_CONFIG] tsc ON ftd.TENANT_VALIDATION_STATUS = tsc.STATUS_ID
LEFT JOIN [fraud].[FRAUD_REASON_CONFIG] frc ON ftd.FRAUD_REASON_CODE = frc.FRAUD_REASON_CODE
GROUP BY ftd.TENANT_VALIDATION_STATUS, tsc.STATUS_DESCRIPTION, frc.FRAUD_REASON_DESCRIPTION, ftd.FRAUD_REASON_CODE
ORDER BY TenantCount DESC;
GO


-- ─────────────────────────────────────────────────────────────────────────────
-- QUERY 4: De-auth'd tenants in FAB with HIGH storage (potential deletion candidates)
-- ─────────────────────────────────────────────────────────────────────────────
SELECT TOP 100
    ftd.OMS_TENANT_ID,
    ftd.SITE_SUBSCRIPTION_ID,
    ftd.TENANT_NAME,
    ftd.TENANT_TOTAL_DISK_USED_GB,
    ftd.STORAGE_LIMIT_GB,
    ftd.TENANT_VALIDATION_STATUS,
    tsc.STATUS_DESCRIPTION,
    ftd.FRAUD_REASON_CODE,
    ftd.USECASE_TYPE,
    ftd.DETECTED_DATE,
    ftd.LAST_RUN_DATE,
    ftd.D2KINSTANCE
FROM [fraud].[FRAUD_TENANT_DETAILS] ftd
INNER JOIN #DeauthTenants dt ON ftd.OMS_TENANT_ID = dt.OMS_TENANT_ID
LEFT JOIN [fraud].[TENANT_STATUS_CONFIG] tsc ON ftd.TENANT_VALIDATION_STATUS = tsc.STATUS_ID
WHERE ftd.TENANT_TOTAL_DISK_USED_GB > 100  -- > 100 GB
ORDER BY ftd.TENANT_TOTAL_DISK_USED_GB DESC;
GO


-- ─────────────────────────────────────────────────────────────────────────────
-- QUERY 5: De-auth'd tenants in FAB that are STUCK (not deleted/blocked)
-- These are actionable — de-auth'd by identity but FAB hasn't completed remediation
-- ─────────────────────────────────────────────────────────────────────────────
SELECT 
    ftd.OMS_TENANT_ID,
    ftd.SITE_SUBSCRIPTION_ID,
    ftd.TENANT_NAME,
    ftd.TENANT_TOTAL_DISK_USED_GB,
    ftd.TENANT_VALIDATION_STATUS,
    tsc.STATUS_DESCRIPTION,
    ftd.FRAUD_REASON_CODE,
    ftd.DETECTED_DATE,
    ftd.LAST_RUN_DATE,
    DATEDIFF(DAY, ftd.DETECTED_DATE, GETDATE()) AS DaysSinceDetection
FROM [fraud].[FRAUD_TENANT_DETAILS] ftd
INNER JOIN #DeauthTenants dt ON ftd.OMS_TENANT_ID = dt.OMS_TENANT_ID
LEFT JOIN [fraud].[TENANT_STATUS_CONFIG] tsc ON ftd.TENANT_VALIDATION_STATUS = tsc.STATUS_ID
WHERE ftd.TENANT_VALIDATION_STATUS NOT IN (4, 5)  -- Not deleted
  AND ftd.TENANT_TOTAL_DISK_USED_GB > 0
ORDER BY ftd.TENANT_TOTAL_DISK_USED_GB DESC;
GO


-- ─────────────────────────────────────────────────────────────────────────────
-- QUERY 6: Identify de-auth'd tenants that SHOULD be ingested into FAB
-- (Not in FAB, but from the high-storage KQL export)
-- Prereq: Create #DeauthWithStorage from KQL Query 7 export
-- ─────────────────────────────────────────────────────────────────────────────

-- If you've imported the KQL Query 7 CSV with storage data:
IF OBJECT_ID('tempdb..#DeauthWithStorage') IS NOT NULL DROP TABLE #DeauthWithStorage;

CREATE TABLE #DeauthWithStorage (
    OMS_TENANT_ID UNIQUEIDENTIFIER,
    SITE_SUBSCRIPTION_ID UNIQUEIDENTIFIER,
    TENANT_NAME NVARCHAR(500),
    D2K_DisplayName NVARCHAR(500),
    TENANT_TOTAL_DISK_USED_GB FLOAT,
    STORAGE_LIMIT_GB FLOAT,
    ODBDISKUSED_SUM_GB FLOAT,
    SPODISKUSED_SUM_GB FLOAT,
    ODBSITE_COUNT INT,
    SESSION_COUNT INT,
    TOTAL_USERS INT,
    LICENSES_ENABLED INT,
    D2K_CreationTime DATETIME2,
    CompanyTags NVARCHAR(MAX)
);

-- BULK INSERT from KQL Query 7 export CSV (adjust path)
-- BULK INSERT #DeauthWithStorage FROM 'C:\Temp\deauth_with_storage.csv'
-- WITH (FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', FIRSTROW = 2);

-- Find ones NOT in FAB:
SELECT 
    ds.OMS_TENANT_ID,
    ds.SITE_SUBSCRIPTION_ID,
    ds.TENANT_NAME,
    ds.D2K_DisplayName,
    ds.TENANT_TOTAL_DISK_USED_GB,
    ds.STORAGE_LIMIT_GB,
    ds.SESSION_COUNT,
    ds.TOTAL_USERS,
    ds.CompanyTags
FROM #DeauthWithStorage ds
LEFT JOIN [fraud].[FRAUD_TENANT_DETAILS] ftd ON ds.OMS_TENANT_ID = ftd.OMS_TENANT_ID
WHERE ftd.OMS_TENANT_ID IS NULL  -- NOT in FAB
  AND ds.TENANT_TOTAL_DISK_USED_GB > 10  -- meaningful storage
ORDER BY ds.TENANT_TOTAL_DISK_USED_GB DESC;
GO


-- ─────────────────────────────────────────────────────────────────────────────
-- QUERY 7: Quick check — are any de-auth'd tenants in DetectionAutomationRulesData?
-- (i.e., pending detection pipeline processing)
-- ─────────────────────────────────────────────────────────────────────────────
SELECT 
    dard.SiteSubscriptionId,
    dt.OMS_TENANT_ID
FROM [fraud].[DetectionAutomationRulesData] dard
INNER JOIN #DeauthTenants dt ON dard.SiteSubscriptionId = CAST(dt.OMS_TENANT_ID AS VARCHAR(50))
;
GO


-- ─────────────────────────────────────────────────────────────────────────────
-- CLEANUP
-- ─────────────────────────────────────────────────────────────────────────────
-- DROP TABLE #DeauthTenants;
-- DROP TABLE #DeauthWithStorage;
