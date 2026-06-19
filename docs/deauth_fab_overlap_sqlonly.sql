-- ============================================================================
-- De-Auth'd Tenant FAB Overlap — SQL ONLY (no Kusto needed)
-- Run on SSMS (SAW) against fabdarsqldbprod (debug account)
-- Date: May 20, 2026
-- 
-- Schema notes:
--   FRAUD.FRAUD_TENANT_DETAILS (FTD) = workflow/status (STATUS, APPROVAL_FLAG, FRAUD_REASON_CODE)
--   FRAUD.TENANT_DETAILS_RAW (RAW)   = enrichment (TENANT_NAME, TENANT_TOTAL_DISK_USED_GB, etc.)
--   Join: FTD.RAW_ID = RAW.RAW_ID  OR  FTD.OMS_TENANT_ID = RAW.OMS_TENANT_ID
--
-- Input: Run deauth_tenant_ids_insert.sql FIRST in same session to load #DeauthTenants
-- ============================================================================


-- ─────────────────────────────────────────────────────────────────────────────
-- QUERY 1: High-level overlap summary
-- ─────────────────────────────────────────────────────────────────────────────
SELECT 
    (SELECT COUNT(*) FROM #DeauthTenants) AS TotalDeauthLoaded,
    COUNT(DISTINCT ftd.OMS_TENANT_ID) AS InFAB,
    (SELECT COUNT(*) FROM #DeauthTenants) - COUNT(DISTINCT ftd.OMS_TENANT_ID) AS NotInFAB,
    CAST(ROUND(COUNT(DISTINCT ftd.OMS_TENANT_ID) * 100.0 / (SELECT COUNT(*) FROM #DeauthTenants), 1) AS DECIMAL(5,1)) AS PctOverlap
FROM [FRAUD].[FRAUD_TENANT_DETAILS] ftd
WHERE ftd.OMS_TENANT_ID IN (SELECT OMS_TENANT_ID FROM #DeauthTenants);
GO


-- ─────────────────────────────────────────────────────────────────────────────
-- QUERY 2: De-auth'd tenants IN FAB — by current status
-- ─────────────────────────────────────────────────────────────────────────────
SELECT 
    ftd.STATUS AS StatusId,
    CASE ftd.STATUS
        WHEN 0 THEN 'Identified'
        WHEN 1 THEN 'FAB Approved'
        WHEN 2 THEN 'Read Only'
        WHEN 3 THEN 'Blocked'
        WHEN 4 THEN 'Deleted'
        WHEN 5 THEN 'Hard Deleted'
        WHEN 6 THEN 'False Positive'
        WHEN 99 THEN 'Pending'
        ELSE 'Other (' + CAST(ftd.STATUS AS VARCHAR) + ')'
    END AS StatusName,
    COUNT(*) AS TenantCount,
    CAST(ROUND(SUM(ISNULL(raw.TENANT_TOTAL_DISK_USED_GB, 0)) / 1024.0, 2) AS DECIMAL(10,2)) AS StorageTB
FROM [FRAUD].[FRAUD_TENANT_DETAILS] ftd
LEFT JOIN [FRAUD].[TENANT_DETAILS_RAW] raw ON ftd.RAW_ID = raw.RAW_ID
WHERE ftd.OMS_TENANT_ID IN (SELECT OMS_TENANT_ID FROM #DeauthTenants)
GROUP BY ftd.STATUS
ORDER BY TenantCount DESC;
GO


-- ─────────────────────────────────────────────────────────────────────────────
-- QUERY 3: De-auth'd tenants in FAB with storage > 0 that are NOT deleted
-- These are occupying storage despite being de-auth'd — ACTIONABLE
-- ─────────────────────────────────────────────────────────────────────────────
SELECT 
    ftd.OMS_TENANT_ID,
    ftd.SITE_SUBSCRIPTION_ID,
    raw.TENANT_NAME,
    raw.TENANT_TOTAL_DISK_USED_GB,
    CAST(ROUND(raw.TENANT_TOTAL_DISK_USED_GB / 1024.0, 2) AS DECIMAL(10,2)) AS StorageTB,
    raw.STORAGE_LIMIT_GB,
    ftd.STATUS,
    CASE ftd.STATUS
        WHEN 0 THEN 'Identified'
        WHEN 1 THEN 'FAB Approved'
        WHEN 2 THEN 'Read Only'
        WHEN 3 THEN 'Blocked'
        WHEN 99 THEN 'Pending'
        ELSE CAST(ftd.STATUS AS VARCHAR)
    END AS StatusName,
    ftd.FRAUD_REASON_CODE,
    ftd.USECASE_TYPE,
    raw.DETECTED_DATE,
    raw.LAST_RUN_DATE,
    ftd.LAST_PERFORMED_ACTION,
    ftd.LAST_PERFORMED_ACTION_DATE,
    DATEDIFF(DAY, raw.DETECTED_DATE, GETDATE()) AS DaysSinceDetection,
    raw.D2KINSTANCE
FROM [FRAUD].[FRAUD_TENANT_DETAILS] ftd
LEFT JOIN [FRAUD].[TENANT_DETAILS_RAW] raw ON ftd.RAW_ID = raw.RAW_ID
WHERE ftd.OMS_TENANT_ID IN (SELECT OMS_TENANT_ID FROM #DeauthTenants)
  AND ftd.STATUS NOT IN (4, 5)  -- NOT deleted
  AND ISNULL(raw.TENANT_TOTAL_DISK_USED_GB, 0) > 0
ORDER BY raw.TENANT_TOTAL_DISK_USED_GB DESC;
GO


-- ─────────────────────────────────────────────────────────────────────────────
-- QUERY 4: De-auth'd tenants in FAB that were already DELETED — storage reclaimed
-- (validates that de-auth → FAB → delete pipeline works)
-- ─────────────────────────────────────────────────────────────────────────────
SELECT 
    COUNT(*) AS DeletedCount,
    CAST(ROUND(SUM(ISNULL(raw.TENANT_TOTAL_DISK_USED_GB, 0)) / 1024.0, 2) AS DECIMAL(10,2)) AS StorageReclaimedTB,
    MIN(ftd.LAST_PERFORMED_ACTION_DATE) AS EarliestDeletion,
    MAX(ftd.LAST_PERFORMED_ACTION_DATE) AS LatestDeletion
FROM [FRAUD].[FRAUD_TENANT_DETAILS] ftd
LEFT JOIN [FRAUD].[TENANT_DETAILS_RAW] raw ON ftd.RAW_ID = raw.RAW_ID
WHERE ftd.OMS_TENANT_ID IN (SELECT OMS_TENANT_ID FROM #DeauthTenants)
  AND ftd.STATUS IN (4, 5);
GO


-- ─────────────────────────────────────────────────────────────────────────────
-- QUERY 5: STUCK tenants — in FAB, have storage, status is stalled
-- De-auth'd + in FAB but not progressing to deletion
-- ─────────────────────────────────────────────────────────────────────────────
SELECT 
    ftd.OMS_TENANT_ID,
    ftd.SITE_SUBSCRIPTION_ID,
    raw.TENANT_NAME,
    raw.TENANT_TOTAL_DISK_USED_GB,
    ftd.STATUS,
    ftd.FRAUD_REASON_CODE,
    ftd.LAST_PERFORMED_ACTION,
    ftd.LAST_PERFORMED_ACTION_DATE,
    raw.DETECTED_DATE,
    DATEDIFF(DAY, ISNULL(ftd.LAST_PERFORMED_ACTION_DATE, raw.DETECTED_DATE), GETDATE()) AS DaysSinceLastAction,
    DATEDIFF(DAY, raw.DETECTED_DATE, GETDATE()) AS DaysSinceDetection
FROM [FRAUD].[FRAUD_TENANT_DETAILS] ftd
LEFT JOIN [FRAUD].[TENANT_DETAILS_RAW] raw ON ftd.RAW_ID = raw.RAW_ID
WHERE ftd.OMS_TENANT_ID IN (SELECT OMS_TENANT_ID FROM #DeauthTenants)
  AND ftd.STATUS NOT IN (4, 5, 6)  -- Not deleted, not FP
  AND ISNULL(raw.TENANT_TOTAL_DISK_USED_GB, 0) > 0
  AND DATEDIFF(DAY, ISNULL(ftd.LAST_PERFORMED_ACTION_DATE, raw.DETECTED_DATE), GETDATE()) > 30
ORDER BY raw.TENANT_TOTAL_DISK_USED_GB DESC;
GO


-- ─────────────────────────────────────────────────────────────────────────────
-- QUERY 6: Check if de-auth'd tenants are in the scheduled actions queue
-- ─────────────────────────────────────────────────────────────────────────────
SELECT 
    tas.ACTION_TYPE,
    COUNT(*) AS Scheduled
FROM [FRAUD].[TENANT_ACTIONS_SCHD] tas
WHERE tas.SITE_SUBSCRIPTION_ID IN (
    SELECT ftd.SITE_SUBSCRIPTION_ID 
    FROM [FRAUD].[FRAUD_TENANT_DETAILS] ftd
    WHERE ftd.OMS_TENANT_ID IN (SELECT OMS_TENANT_ID FROM #DeauthTenants)
)
GROUP BY tas.ACTION_TYPE;
GO


-- ─────────────────────────────────────────────────────────────────────────────
-- QUERY 7: De-auth'd tenants NOT in FAB at all (the gap — sample)
-- ─────────────────────────────────────────────────────────────────────────────
SELECT TOP 50
    dt.OMS_TENANT_ID
FROM #DeauthTenants dt
LEFT JOIN [FRAUD].[FRAUD_TENANT_DETAILS] ftd ON dt.OMS_TENANT_ID = ftd.OMS_TENANT_ID
WHERE ftd.OMS_TENANT_ID IS NULL
ORDER BY dt.OMS_TENANT_ID;
GO


-- ─────────────────────────────────────────────────────────────────────────────
-- QUERY 8: Also check TENANT_DETAILS_RAW directly for any matches
-- (RAW may have records not yet in FRAUD_TENANT_DETAILS)
-- ─────────────────────────────────────────────────────────────────────────────
SELECT 
    COUNT(*) AS InRawTable,
    CAST(ROUND(SUM(ISNULL(raw.TENANT_TOTAL_DISK_USED_GB, 0)) / 1024.0, 2) AS DECIMAL(10,2)) AS TotalStorageTB,
    SUM(CASE WHEN raw.TENANT_TOTAL_DISK_USED_GB > 0 THEN 1 ELSE 0 END) AS WithStorage,
    SUM(CASE WHEN raw.TENANT_TOTAL_DISK_USED_GB > 1024 THEN 1 ELSE 0 END) AS Over1TB
FROM [FRAUD].[TENANT_DETAILS_RAW] raw
WHERE raw.OMS_TENANT_ID IN (SELECT OMS_TENANT_ID FROM #DeauthTenants);
GO


-- ─────────────────────────────────────────────────────────────────────────────
-- CLEANUP (run when done)
-- ─────────────────────────────────────────────────────────────────────────────
-- DROP TABLE #DeauthTenants;
