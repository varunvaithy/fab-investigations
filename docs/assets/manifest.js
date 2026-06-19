// ═══════════════════════════════════════════════════════════
// FAB Investigation Portal — Investigation Manifest
// ═══════════════════════════════════════════════════════════
const INVESTIGATIONS = [
  {
    id: "inv-015",
    title: "China Network Abuse",
    file: "investigations/China_Network_Abuse_Investigation.md",
    date: "2026-04-10",
    status: "active",
    category: "ring-analysis",
    summary: "217 China-based tenants: 162 abusive across 12+ rings. Piracy CDN, cloud storage reselling, license fraud. $6-8M annual cost to MSFT.",
    tenants: 217,
    storage: "2.8 PB",
    severity: "critical",
    tags: ["china", "piracy", "cdn", "rclone", "license-fraud"]
  },
  {
    id: "inv-028",
    title: "YAM STORE Multiplexing Ring",
    file: "YAM_STORE_Full_Ring_Investigation_Report.md",
    date: "2026-06-16",
    status: "pending-action",
    category: "ring-analysis",
    summary: "Massive 1,031 tenant ring all named 'YAM Store'. Coordinated multiplexing across EDU and Commercial. Zero revenue, 100% unflagged.",
    tenants: 1031,
    storage: "300K+ quotas",
    severity: "critical",
    tags: ["yam-store", "multiplexing", "massive-ring"]
  },
  {
    id: "inv-029",
    title: "Fraud Ring Consolidation",
    file: "Fraud_Ring_Consolidation_Report.md",
    date: "2026-04-02",
    status: "active",
    category: "ring-analysis",
    summary: "Admin clustering uncovered 3 major rings: 8,939 tenants, 465 TB quota. Hamter botnet alone is 3,749 tenants created in 12 days. Zero FAB tracking.",
    tenants: 8939,
    storage: "465 TB",
    severity: "critical",
    tags: ["hamter-botnet", "vietnam", "ring-consolidation"]
  },
  {
    id: "inv-014",
    title: "FAMILIA CONFEITAR — Brazil CDN Ring",
    file: "investigations/FAMILIA_CONFEITAR_Ring_Investigation_Report.md",
    date: "2026-04-08",
    status: "active",
    category: "ring-analysis",
    summary: "30-tenant ring: single Brazil operator running piracy streaming CDN on SharePoint. 1.9 PB storage, 1,696 TB/week egress, $180/mo revenue.",
    tenants: 30,
    storage: "1.9 PB",
    severity: "critical",
    tags: ["brasil", "piracy-cdn", "streaming"]
  },
  {
    id: "inv-016",
    title: "E5 Developer 4-Char Ring",
    file: "investigations/E5-Dev-Ring-Investigation-Report.md",
    date: "2026-04-01",
    status: "active",
    category: "ring-analysis",
    summary: "31-member ring consuming 2.9 PB. E5 Developer trial abuse with coordinated 4-character naming across 11 countries.",
    tenants: 31,
    storage: "2.9 PB",
    severity: "critical",
    tags: ["e5-developer", "trial-abuse", "4-char-pattern"]
  },
  {
    id: "inv-009",
    title: "ACGDB / SakuraPY Ring",
    file: "investigations/ACGDB-Ring-Investigation-Report.md",
    date: "2026-04-01",
    status: "active",
    category: "ring-analysis",
    summary: "33-tenant ring: SPO abuse + EDU license fraud. 597 TB storage, 20M fraudulent licenses, 39 PB exposure. pengyoupy001@gmail.com operator.",
    tenants: 33,
    storage: "597 TB",
    severity: "critical",
    tags: ["edu-fraud", "hong-kong", "soft-quota"]
  },
  {
    id: "inv-011",
    title: "MistyCloud Inc. Ring",
    file: "investigations/MistyCloud-Ring-Investigation-Report.md",
    date: "2026-04-01",
    status: "active",
    category: "ring-analysis",
    summary: "12-tenant Argentina ring. 1 license each, 340-364 TB storage per tenant (340x overage). Total 3.67 PB on $0 revenue.",
    tenants: 12,
    storage: "3.67 PB",
    severity: "high",
    tags: ["argentina", "spo-abuse", "soft-quota"]
  },
  {
    id: "inv-012",
    title: "Procode Multiplexing Ring",
    file: "investigations/Procode-Ring-Investigation-Report.md",
    date: "2026-04-01",
    status: "pending",
    category: "ring-analysis",
    summary: "32-member multiplexing ring with systematic naming. Growing for 21 months with zero FAB action. Mostly dormant.",
    tenants: 32,
    storage: "32 TB",
    severity: "medium",
    tags: ["multiplexing", "procode-brand", "dormant"]
  },
  {
    id: "inv-023",
    title: "Japan Storage Abuse (Ring 2)",
    file: "investigations/Ring2_Japan_Investigation_Report.md",
    date: "2026-04-08",
    status: "active",
    category: "ring-analysis",
    summary: "50 Japanese operators abusing SPO. Two mega-abusers at 693 TB and 332 TB on $12.50/month SPO Plan 2. 1.58 PB total.",
    tenants: 50,
    storage: "1.58 PB",
    severity: "high",
    tags: ["japan", "spo-plan2", "rclone"]
  },
  {
    id: "inv-035",
    title: "TM9/TM10 Domain Infrastructure Ring",
    file: "TM9_TM10_Fraud_Ring_Report.md",
    date: "2025-05-31",
    status: "remediated",
    category: "ring-analysis",
    summary: "4-tenant ring sharing tm9.site/tm10.site domains. E5 Developer trials, 120 TB each. All blocked.",
    tenants: 4,
    storage: "483 TB",
    severity: "high",
    tags: ["custom-domains", "e5-developer", "blocked"]
  },
  {
    id: "inv-013",
    title: "StableBit CloudDrive Abuse",
    file: "investigations/StableBit_CloudDrive_Investigation_Report.md",
    date: "2026-04-07",
    status: "active",
    category: "storage-abuse",
    summary: "App-fingerprinted abuse via StableBit CloudDrive. 24 tenants identified, 9 confirmed fraud. 'MSFT' impersonation ring (4 tenants, Vietnamese operators).",
    tenants: 24,
    storage: "468 TB",
    severity: "critical",
    tags: ["stablebit", "storage-reselling", "vietnam"]
  },
  {
    id: "inv-017",
    title: "F1 Soft-Quota Abuse",
    file: "investigations/F1_Soft_Quota_Abuse_Investigation.md",
    date: "2026-04-09",
    status: "active",
    category: "storage-abuse",
    summary: "10-tenant Amsterdam ring storing 1.36 PB + China piracy CDN at 135 TB. Total ~1.5 PB on $27/month F1 licenses (1,111x cost arbitrage).",
    tenants: 12,
    storage: "1.52 PB",
    severity: "critical",
    tags: ["f1-kiosk", "soft-quota", "netherlands", "china"]
  },
  {
    id: "inv-021",
    title: "SPO Paid Storage Abuse",
    file: "investigations/SPO_Paid_Storage_Abuse_Report.md",
    date: "2026-04-08",
    status: "active",
    category: "storage-abuse",
    summary: "27 tenants across sub-rings storing 5.8 PB. MistyCloud subset alone is 3.76 PB. Revenue: $200-300/month.",
    tenants: 27,
    storage: "5.8 PB",
    severity: "critical",
    tags: ["spo-paid", "argentina", "storage-abuse"]
  },
  {
    id: "inv-010",
    title: "Quang Trung Storage Reselling",
    file: "investigations/QuangTrung-Storage-Reselling-Investigation.md",
    date: "2026-04-03",
    status: "pending",
    category: "storage-abuse",
    summary: "Vietnamese A1 EDU tenant at 433 TB (4.3x quota). Operating ms365vip.com storefront. 5-tenant ring.",
    tenants: 5,
    storage: "433 TB",
    severity: "high",
    tags: ["vietnam", "storage-reselling", "edu-fraud"]
  },
  {
    id: "inv-014-addendum",
    title: "CDN Egress: READONLY Doesn't Stop It",
    file: "investigations/CDN_Egress_Ring_Investigation_Report.md",
    date: "2026-04-19",
    status: "active",
    category: "remediation-gap",
    summary: "Critical finding: READONLY status fails to stop egress in CDN abuse. FAMILIA ring still serving 1.53 PB/week after 11 days in READONLY. $190K bandwidth cost.",
    tenants: 26,
    storage: "2.4 PB egress",
    severity: "critical",
    tags: ["remediation-gap", "readonly-ineffective", "brasil"]
  },
  {
    id: "inv-008",
    title: "EDU China/Vietnam Tenant Investigation",
    file: "investigations/EDU_CN_VN_Investigation_Report.md",
    date: "2026-04-03",
    status: "active",
    category: "edu-fraud",
    summary: "202 deep-investigated EDU tenants from CN/VN. 43 confirmed fraud, 7 archetypes identified. 255 TB consumed.",
    tenants: 202,
    storage: "255 TB",
    severity: "high",
    tags: ["edu-fraud", "china", "vietnam", "a1-licenses"]
  },
  {
    id: "inv-018",
    title: "EDU ODSP Storage Fraud (Global)",
    file: "investigations/EDU_ODSP_Storage_Fraud_Investigation.md",
    date: "2026-04-23",
    status: "active",
    category: "edu-fraud",
    summary: "Global EDU analysis: 453K tenants, 1,466 PB total storage. 0.49% fraud rate = 7.2 PB confirmed. 856 over-quota tenants.",
    tenants: 453899,
    storage: "7.2 PB fraud",
    severity: "high",
    tags: ["edu-fraud", "odb", "spo", "global"]
  },
  {
    id: "inv-019",
    title: "EDU Fraud Landscape Prevalence",
    file: "investigations/EDU_Landscape_Fraud_Prevalence_Report.md",
    date: "2026-04-22",
    status: "active",
    category: "edu-fraud",
    summary: "1.78M EDU tenants: 49.4% are ghost tenants. 27K+ suspicious vs 2,611 flagged (10:1 detection gap). 266B licenses acquired, 270 PB provisioned.",
    tenants: 1787313,
    storage: "270 PB provisioned",
    severity: "high",
    tags: ["edu-fraud", "ghost-tenants", "detection-gap"]
  },
  {
    id: "inv-026",
    title: "EDU Storage Fraud & Shell Weaponization",
    file: "investigations/EDU_Storage_Fraud_Report.md",
    date: "2026-04-23",
    status: "active",
    category: "edu-fraud",
    summary: "29 PB active fraud (70-80% confirmed) + 1.06M dormant shells with 254 PB allocated. Weaponizable capacity: 247 PB.",
    tenants: 6804,
    storage: "29 PB",
    severity: "critical",
    tags: ["storage-weaponization", "dormant-shells", "edu"]
  },
  {
    id: "inv-027",
    title: "EDU Tier 2: High-Priority Cohort",
    file: "investigations/EDU_Tier2_Investigation.md",
    date: "2026-04-22",
    status: "pre-ingestion",
    category: "edu-fraud",
    summary: "3,568 high-priority suspicious EDU tenants across 7 sub-categories. FAB pipeline has zero visibility. EDU eligibility rubber-stamping fraud.",
    tenants: 3568,
    storage: "TBD",
    severity: "high",
    tags: ["edu-fraud", "tier2-cohort", "pipeline-blind-spot"]
  },
  {
    id: "inv-025",
    title: "Archetype G At-Scale (EDU Repurposing)",
    file: "investigations/Archetype_G_At_Scale_Report.md",
    date: "2026-04-03",
    status: "active",
    category: "edu-fraud",
    summary: "Vietnamese EDU A1 tenant repurposing at scale. 6 new fraud cases, 499 TB fraudulent storage. Multi-school domain hijacking.",
    tenants: 12,
    storage: "499 TB",
    severity: "high",
    tags: ["vietnam", "edu-a1", "domain-hijacking"]
  },
  {
    id: "inv-r2",
    title: "EDU-DECLINED Ghost Tenants",
    file: "investigations/EDU_Declined_Ghost_Tenant_Report.md",
    date: "2026-04-05",
    status: "ready-enforcement",
    category: "edu-fraud",
    summary: "2,902 ghost EDU tenants with edu=declined. Zero users, zero storage, 2.3 PB provisioned quota. 99.5% precision on 200-sample.",
    tenants: 2902,
    storage: "2.3 PB provisioned",
    severity: "low",
    tags: ["edu-declined", "ghost-tenants", "zero-risk"]
  },
  {
    id: "inv-r3-pending",
    title: "EDU-PENDINGAPPROVAL Ghost Tenants",
    file: "investigations/EDU_PendingApproval_Ghost_Tenant_Report.md",
    date: "2026-04-05",
    status: "ready-enforcement",
    category: "edu-fraud",
    summary: "2,667 ghost EDU tenants stuck in pendingapproval. 100% precision on 45-sample. Abandoned shells sitting on provisioned storage.",
    tenants: 2667,
    storage: "4.4 PB provisioned",
    severity: "low",
    tags: ["edu-pending", "ghost-tenants", "abandoned"]
  },
  {
    id: "inv-022",
    title: "Impersonation Casebook",
    file: "investigations/IMPERSONATION_CASEBOOK_VALIDATED.md",
    date: "2026-04-24",
    status: "active",
    category: "brand-impersonation",
    summary: "13 CRITICAL + 85 HIGH impersonation cases from 6,804 unflagged EDU tenants. Zero false positives on validated sample.",
    tenants: 98,
    storage: "TBD",
    severity: "high",
    tags: ["brand-impersonation", "microsoft-365", "edu"]
  },
  {
    id: "inv-020",
    title: "DS Model Investigation Master",
    file: "investigations/DS_Investigation_Master_Report.md",
    date: "2026-04-07",
    status: "active",
    category: "detection-rules",
    summary: "944 tenant IDs from DS Model. 6 regional rings identified, including Brazil CDN (1,696 TB/wk) and SPO paid abuse (5.9 PB).",
    tenants: 944,
    storage: "1,889 TB egress/7d",
    severity: "critical",
    tags: ["ds-model", "ring-identification", "egress"]
  },
  {
    id: "inv-032",
    title: "Detection Rules 1-5 Effectiveness",
    file: "FAB_Rules_1_5_Effectiveness_Investigation_v3.md",
    date: "2026-04-17",
    status: "active",
    category: "detection-rules",
    summary: "Stress test of R1-R5 + AI agent (R0): 2,393 tenants caught, 4.1 PB storage, 3.59% FP rate. Backfill gap: 1.9 PB missed.",
    tenants: 2393,
    storage: "4.1 PB",
    severity: "high",
    tags: ["detection-rules", "effectiveness", "false-positives"]
  },
  {
    id: "inv-033",
    title: "Detection Rules Gap Analysis",
    file: "FAB_Detection_Rules_Investigation_Report_v2.md",
    date: "2026-04-20",
    status: "active",
    category: "detection-rules",
    summary: "141,975 flagged tenants, 3 PB reclaimed since Oct 2025. But rules cover only 3 SKUs (10.4% coverage). 85K A1 tenants invisible.",
    tenants: 141975,
    storage: "3 PB reclaimed",
    severity: "high",
    tags: ["detection-rules", "sku-gaps", "coverage"]
  },
  {
    id: "inv-024",
    title: "High-Egress Tenant Investigation",
    file: "investigations/High_Egress_Investigation_May12.md",
    date: "2026-05-12",
    status: "active",
    category: "detection-rules",
    summary: "Top-egress tenant sweep from K2 queries. Confirmed FAMILIA ring, found BLOCK_FAIL retry issues (20-30 per tenant).",
    tenants: 30,
    storage: "PB-scale egress",
    severity: "critical",
    tags: ["egress-analysis", "block-failures"]
  },
  {
    id: "inv-r3",
    title: "R3 Rule Validation (Commercial+EDU Signal)",
    file: "investigations/R3_Commercial_EDU_Signal_Investigation_Report.md",
    date: "2026-04-06",
    status: "validated",
    category: "detection-rules",
    summary: "Rule R3 targets commercial tenants with EDU signals. 65,572 population, 100-sample validated: 0% FP, 100% ghost tenants.",
    tenants: 65572,
    storage: "0 usage",
    severity: "medium",
    tags: ["detection-rule", "commercial-edu", "ghost-tenants"]
  },
  {
    id: "inv-034",
    title: "Dormant Tenant Storage Analysis",
    file: "Dormant_Tenant_Storage_Analysis.md",
    date: "2026-06-17",
    status: "active",
    category: "dormant-analysis",
    summary: "886K dormant tenants (6.5% of total). 592 high-value tenants hold 96.6% of dormant storage (15.3 PB). Major remediation targets.",
    tenants: 886248,
    storage: "15.9 PB",
    severity: "medium",
    tags: ["dormant-tenants", "storage-recovery"]
  },
  {
    id: "inv-030",
    title: "Consumer OneDrive Fraud",
    file: "Consumer_Fraud_Investigation_Report_2705.md",
    date: "2026-05-27",
    status: "active",
    category: "consumer-fraud",
    summary: "34 consumer PUIDs / 51 site IDs. All dormant with zero user-driven activity in 30 days. Folder spam and rapid dump archetypes.",
    tenants: 51,
    storage: "26.6 TB",
    severity: "medium",
    tags: ["consumer-fraud", "folder-spam", "dormant"]
  },
  {
    id: "inv-031",
    title: "Business Impact Investigation",
    file: "../Business_Impact_Investigation_Report.md",
    date: "2026-06-15",
    status: "active",
    category: "business-impact",
    summary: "Impact analysis of blocking 1,231 tenants. 1.4M TB quota at risk, only $6,300 annual revenue. 50% China concentration.",
    tenants: 1231,
    storage: "1.4M TB quota",
    severity: "high",
    tags: ["business-impact", "remediation-analysis"]
  }
];

// Category metadata
const CATEGORIES = {
  "ring-analysis":       { label: "Ring Analysis",       color: "#ef4444", icon: "🔗" },
  "storage-abuse":       { label: "Storage Abuse",       color: "#f97316", icon: "💾" },
  "edu-fraud":           { label: "EDU Fraud",           color: "#a855f7", icon: "🎓" },
  "detection-rules":     { label: "Detection Rules",     color: "#06b6d4", icon: "🔍" },
  "remediation-gap":     { label: "Remediation Gap",     color: "#dc2626", icon: "⚠️" },
  "brand-impersonation": { label: "Brand Impersonation", color: "#ec4899", icon: "🎭" },
  "consumer-fraud":      { label: "Consumer Fraud",      color: "#d97706", icon: "👤" },
  "business-impact":     { label: "Business Impact",     color: "#22c55e", icon: "📊" },
  "dormant-analysis":    { label: "Dormant Analysis",    color: "#64748b", icon: "💤" },
  "quota-abuse":         { label: "Quota Abuse",         color: "#f59e0b", icon: "📦" },
  "multiplexing":        { label: "Multiplexing",        color: "#8b5cf6", icon: "🔁" }
};

const SEVERITY_META = {
  critical: { label: "Critical", color: "#ef4444", bg: "rgba(239,68,68,0.1)" },
  high:     { label: "High",     color: "#f59e0b", bg: "rgba(245,158,11,0.1)" },
  medium:   { label: "Medium",   color: "#06b6d4", bg: "rgba(6,182,212,0.1)" },
  low:      { label: "Low",      color: "#22c55e", bg: "rgba(34,197,94,0.1)" }
};

const STATUS_META = {
  "active":            { label: "Active",           color: "#22c55e" },
  "pending":           { label: "Pending",          color: "#f59e0b" },
  "pending-action":    { label: "Pending Action",   color: "#f59e0b" },
  "pre-ingestion":     { label: "Pre-Ingestion",    color: "#06b6d4" },
  "ready-enforcement": { label: "Ready",            color: "#a855f7" },
  "validated":         { label: "Validated",         color: "#6366f1" },
  "remediated":        { label: "Remediated",        color: "#64748b" }
};

// Data files available for explorer
const DATA_FILES = [
  { name: "No MAU 12mo — All Tenants", file: "no_mau_12mo_all_tenants_with_data.csv", rows: "~1000" },
  { name: "No MAU 12mo — All Segments (100MB+)", file: "no_mau_12mo_all_segments_100mb.csv", rows: "~500" },
  { name: "No MAU 12mo — Paid Tenants", file: "no_mau_12mo_paid_tenants.csv", rows: "~200" },
  { name: "DeAuth 51K Analysis", file: "deauth_51k_full.csv", rows: "~51K" },
  { name: "DeAuth 51K Not In FAB", file: "deauth_51k_notInFAB_15337.csv", rows: "~15K" },
  { name: "Rule K1 Results", file: "kustoqueries_newrules/K1.csv", rows: "varies" },
  { name: "Rule K2 Results", file: "kustoqueries_newrules/K2.csv", rows: "varies" },
  { name: "Rule K5 Results", file: "kustoqueries_newrules/K5.csv", rows: "varies" },
  { name: "Consumer Fraud Detection", file: "ConsumerFraudDetection_2026_05_19.csv", rows: "varies" },
  { name: "Phase 2 Batch 2 D2K", file: "../phase2_batch2_d2k.csv", rows: "varies" },
  { name: "Unflagged Fraud (6,804)", file: "investigations/UNFLAGGED_FRAUD_ALL_6804.csv", rows: "6804" },
  { name: "Impersonation Casebook", file: "investigations/IMPERSONATION_CASEBOOK_VALIDATED.csv", rows: "varies" },
  { name: "High/Critical Top 50", file: "investigations/HIGH_CRITICAL_TOP_50.csv", rows: "50" }
];

// KQL/SQL query files
const QUERY_FILES = [
  { name: "New Rule Validation Queries", file: "kustoqueries_newrules/new_rule_validation_queries.md", lang: "kql" },
  { name: "E5 Dev Ring Detection", file: "E5_Dev_Ring_Detection_Queries.kql", lang: "kql" },
  { name: "China Network Abuse Scoring", file: "investigations/China_Network_Abuse_Scoring.kql", lang: "kql" },
  { name: "Gibberish Name Detection", file: "Gibberish_Name_Detection_Queries.kql", lang: "kql" },
  { name: "SKU License Fraud Analysis", file: "SKU_License_Fraud_Analysis.kql", lang: "kql" },
  { name: "No MAU 12mo Extraction", file: "no_mau_12mo_extraction.kql", lang: "kql" },
  { name: "DeAuth Tenant Storage Check", file: "deauth_tenant_storage_check.kql", lang: "kql" },
  { name: "PUID Fraud Investigation", file: "PUID_Fraud_Investigation_Queries.kql", lang: "kql" },
  { name: "DeAuth FAB Overlap", file: "deauth_tenant_fab_overlap.sql", lang: "sql" },
  { name: "DeAuth FAB Overlap (SQL Only)", file: "deauth_fab_overlap_sqlonly.sql", lang: "sql" },
  { name: "Q1 2026 Quarterly Report Queries", file: "Q1_2026_Quarterly_Report_Queries.sql", lang: "sql" }
];

// Other docs sections
const DOC_SECTIONS = [
  { name: "Strategy & Planning", items: [
    { title: "FAB Detection Strategy Paper", file: "detection-strategy-paper/", type: "folder" },
    { title: "FY27H2 Semester Plan", file: "FAB Strategy Vision/FY27H2_Semester_Plan.md", type: "md" },
    { title: "FY27H1 KRs", file: "FAB Strategy Vision/FY27H1_Semester_Plan_KRs.md", type: "md" },
    { title: "S2 2026 Planning Draft", file: "FAB Strategy Vision/S2_2026_Planning_Draft.md", type: "md" },
    { title: "ODSP Fraud Strategy Paper", file: "FAB Strategy Vision/ODSP_Fraud_Abuse_Strategy_Paper_Draft.md", type: "md" },
    { title: "FAB Rules vs Investigations", file: "FAB_Rules_vs_Investigations_Strategy.md", type: "md" },
    { title: "Fair Use vs FAB Boundary", file: "FAB Strategy Vision/Fair_Use_vs_FAB_Boundary_Paper.md", type: "md" },
    { title: "Pattern Scalability Analysis", file: "Pattern_Scalability_Analysis.md", type: "md" }
  ]},
  { name: "Proposals & Processes", items: [
    { title: "Blocklist Re-Entry Prevention", file: "proposals/Blocklist_ReEntry_Prevention_Proposal.md", type: "md" },
    { title: "Re-Entry Prevention Strategy", file: "Re_Entry_Prevention_Strategy.md", type: "md" },
    { title: "CELA Support Process Proposal", file: "CELA_Support_Process_Proposal_Draft.md", type: "md" },
    { title: "OBO Feature Flag", file: "OBO_Feature_Flag.md", type: "md" },
    { title: "Remediation Deletion Plan", file: "Remediation_Deletion_Plan.md", type: "md" },
    { title: "Compliance Policy FAB Impact", file: "Compliance_Policy_FAB_Impact_Email.md", type: "md" }
  ]},
  { name: "Operational Guides", items: [
    { title: "CSS Triage Guide", file: "tsg/CSS_Triage_Guide.md", type: "md" },
    { title: "CSS Response Templates", file: "tsg/CSS_Response_Templates.md", type: "md" },
    { title: "CSS Quick Reference Card", file: "tsg/CSS_Quick_Reference_Card.md", type: "md" },
    { title: "Local Development Setup", file: "LocalDevelopmentSetup.md", type: "md" },
    { title: "FAB Grid Certificate Renewal", file: "tsg/FABGridCertificateRenewal.md", type: "md" }
  ]},
  { name: "Reports", items: [
    { title: "Q1 2026 Quarterly Report", file: "Q1_2026_Quarterly_Report.md", type: "md" },
    { title: "Remediation Action Items (May 4)", file: "Remediation_Action_Items_May4.md", type: "md" },
    { title: "Fraud Abuse Vectors (Consolidated)", file: "Fraud_Abuse_Vectors_Consolidated.md", type: "md" },
    { title: "EDU Tenant Primer", file: "EDU_Tenant_Primer.md", type: "md" },
    { title: "DeAuth Investigation", file: "deauth_35k_inFAB_investigation.md", type: "md" },
    { title: "Phase 2 Validation Report", file: "../phase2_corrected_validation_report.md", type: "md" }
  ]}
];
