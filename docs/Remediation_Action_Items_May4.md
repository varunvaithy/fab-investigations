# FAB Remediation Action Items — May 4, 2026

**Purpose:** Per-investigation tenant ID lists for manual remediation / ingestion.  
**Generated from:** Investigation Tracker audit (18 days since last check, Apr 16).  
**Format:** Copy-paste tenant IDs directly into FAB MCP ingestion tool.

---

## INV-015: F1 Soft-Quota — Stuck Status 1

**ICM:** [776384949](https://portal.microsofticm.com/imp/v5/incidents/details/776384949/summary)  
**Issue:** 1 tenant stuck in Status 1 for ~33 days. ACTIVELY FILLING at 2.5 TB/day.  
**Action:** Push manual remediation / escalate via ICM.

```
24098c20-486f-4669-8f26-76d5d6927865
```

| Name | Storage | Notes |
|------|---------|-------|
| DEFAULT DIRECTORY | 135 TB | CN piracy CDN, rclone+FFmpeg, F1 $2.25/mo seat. No remediation schedule ever created. |

---

## INV-008: EDU CN/VN — Stuck Status 1

**ICM:** [772521899](https://portal.microsofticm.com/imp/v3/incidents/details/772521899/home)  
**Issue:** 3 stuck Status 1 + 1 unqueryable (MCP error). Stuck ~31 days.  
**Action:** Check dashboard status; push remediation if still stuck.  
**Note:** Only 8-char short prefixes available from investigation report. Use dashboard search.

```
13c17f9e
11a3d097
afba3f73
d0960147
```

| Short ID | Name | Storage | Details |
|----------|------|---------|---------|
| `13c17f9e` | NDLG | ~0 TB (60 TB provisioned) | Commercial masquerade, 6M fake E3 licenses |
| `11a3d097` | HAZE5 | ~0 TB | Developer SKU hoarding shell (2,048 lic / 2 enabled) |
| `afba3f73` | 浙江大学 (Zhejiang Univ) | 0.185 TB | 2.3M licenses for 14 users, QQ admin |
| `d0960147` | TSCN | 237 TB | Dormant storage silo (904 users). MCP tool fails on this tenant. |

---

## INV-016: China Network Abuse — Stuck Status 1 (~42% of 162 ingested)

**ICM:** [718092350](https://portal.microsofticm.com/imp/v5/incidents/details/718092350/summary), [776217853](https://portal.microsofticm.com/imp/v5/incidents/details/776217853/summary)  
**Issue:** All 162 ingested Apr 15. ~42% stuck Status 1 (no remediation triggered). ~50% confirmed READONLY_SUCCESS. ~8% edge cases.  
**Action:** Bulk status check all 162 IDs below, then push stuck ones. Prioritize Ring A (HMIAN+ZN actively filling).

**All 162 tenant IDs (full list — copy-paste for bulk status check):**

```
5edb62e7-d4e6-4911-92ff-cb6b3aefe3fe
7d5d12c2-66e9-4254-be08-3eb9c274fe9a
f9f1b6da-0d5f-464b-9e4a-f8746195b2df
21470293-5879-4b35-aa83-6a4002e56b2f
56a36e88-b7b9-4927-8e88-06fafa6f01d4
8a7f99ee-9adb-49ff-a5e0-0d9c767bd44b
44b59163-f15d-4f71-bbc8-4d97ccca920a
bd3be752-6702-4f91-b758-1f1fa0a223a5
b67f481a-3733-4ff9-bfaf-6703a506e7d9
c7292335-c19a-4293-b3af-0acf563b832b
c2502fae-280d-4941-bea5-8ad37843358c
6a63e133-20b0-4a3c-a8bc-f03f7dd7eb7f
7c777e8c-da0c-4314-8607-3d4f2ffa633a
cddabb98-1762-44e6-b41f-f82958363ac5
b7ee9fb7-d823-49c5-a428-13d472229b9f
25d865f1-9bfb-4c52-9d21-a975274dd6cb
1e49cb2f-647c-49ec-a03b-778bb513a3c1
96658824-43a7-4cd6-8967-9c6eb17bd258
9bb38d0d-6c6f-40e7-aab8-f12353e2a3e3
f1475a5c-5d64-4c35-87c6-9c19aa70d099
c246dfc5-c25d-4006-8e36-d024fd9594e0
3d76e686-8416-4aa5-9d63-119e1efd492d
8f3f7b4c-ace2-4471-869f-a7630ce2d577
fc122104-d0b0-4bee-9c9c-51c1b2b71799
edf6cf4d-f123-48b9-9908-9eca727e7490
2b64ab07-467c-4b74-8acc-ec96177d49ba
6a3f3639-7562-4f96-8e7c-e97d19b0648b
2b7a9950-c405-4a49-b1f3-beca2dc1107c
94c5e07d-cb0d-4b1c-94c8-37fbd9056179
8582d095-5557-443a-a769-895c1f53e93c
a53f727c-dbae-4ada-a20e-1305e4b543dc
7c5f00c6-71d5-43bd-915f-aafd52a0facd
b824df6c-956a-43f1-b5d2-f8c4ef644fc6
34de18bd-356e-4057-abc6-17d4173ed575
20f3bc22-a015-4d5b-a0b2-a18316e6c30c
521ba7a8-9833-498a-97ee-f0737a863550
f38aa9fa-34a2-4cd6-8af2-457470322e9a
a94cb8dc-4c00-4751-8ccb-c24be912119a
a3cd2d3e-9eac-4990-b174-5f4debe3411f
df6ebb2e-bd89-4a5f-888c-e5967ec45bad
1a720d28-bae5-44c1-81cd-8a183677f5da
3a08a0e1-98e8-47fc-8a7d-1aca00adfde6
cd3bf6ac-442c-4cc4-a53f-fb7a229e2940
fbffe1f1-6f5c-416b-a87c-74a988595fc0
e9196dc5-34f8-4055-ac22-9fc0a0577959
fbbc6e82-13bc-4738-8561-03fb9bff47b6
09d450b8-e803-4334-bfda-29d77dd4d8cf
e4c6b0f6-2783-4155-bfb6-6154e29e9c17
022daa44-37bc-4305-b011-16ae93d4fa36
60f34acf-8dfb-4b50-8e30-45db69b4e668
129d9a20-3e5d-455c-8633-65924fbbbf59
ecd4feb2-2720-4bd9-86b0-1ccaeaa0e090
ef6ed8b2-24d7-47b0-bed1-dda05d1fc620
840aa988-8d9f-464b-8d36-a8a93e8e6860
01118a50-e1b6-4377-88be-a07ff4e4e64d
24098c20-486f-4669-8f26-76d5d6927865
e439db60-5858-4549-9368-e297f66d8700
031245e8-09a2-4225-9482-dc8c898ac993
0db3be03-3d43-4c2a-bcaf-3ce6ee5fe714
d956edc7-8be2-441b-b6b8-32ded7faeb55
a208e9d7-0e6e-447f-904e-96e6422c064b
5a457f06-07e5-4597-a6eb-1b2a752b82df
5cd5dbd4-b4d7-4bdc-be27-67b63a9cbb8a
ce7336c1-920a-4aed-985c-cb25970744dc
1d37b572-af58-4e0d-b961-e4457faa9141
a774b052-80a8-44d7-b930-4b0dd55e1e5b
970b1641-f456-425f-98a2-baa150ce62b5
7e9a0e9a-6a2a-40b0-bd4d-96f71ab5701a
b4f10ec5-e85a-42cf-b928-e393891886eb
45567a67-ab00-4d24-9796-1fc86c1f2917
0552addc-5e88-4eb3-83b5-dcd7b0c33dbd
7c0c1be6-d3ab-4e98-835d-31f31e4fb0af
fe5a03ae-e171-4835-8799-4ce4069c6738
ffce955c-ffa3-480c-9b86-efd0c0347653
07c605b9-cb74-4a6f-a41a-e77e60a9012a
d0695867-e38e-46a1-89cf-43d7894360f5
fbc84da6-66d1-49f3-abd3-0794bf9d127c
1c065159-add3-4856-b00f-50a69601d978
736d732b-63f2-4eba-ae4f-ee4d39f1b516
166160da-9423-4379-b023-aa8c6584a918
69b1de3e-13fd-4cbd-937f-d1e0face25a8
933d36ad-a968-455c-929d-a5d4559b7dad
7002a5d2-b72c-47db-bdaf-0cdd2ce75eb6
17169edd-28e9-44b5-855f-1d84654bbdc5
34234e14-29e7-440f-8de7-f5edd8521d1d
aa806bb1-1139-4f3d-b317-6358213e7457
79d97ba8-c3ce-4e65-8197-9f5cbba175f6
5162360a-a636-45ee-9771-6c507c345be0
f48a0392-a91f-4c0d-bb72-1f88e7fc223c
cfcdbcc8-79fc-4917-84fb-e0236453996c
bbe9613f-087f-4676-b641-4021fda072c2
cfde10d3-aa8c-42ab-88bb-53f24c95ebaf
b8f741ce-5341-41ec-a091-c075d2a99655
f1464c2a-6dc4-4c82-aafb-be46dc8542e6
0c0e6974-be5a-4a8f-8a2d-3483a233097c
d18173cf-bfcd-4d51-afa1-938ddd6c81f9
77fc6064-cdf7-4793-9c46-2ef2aaad4dc5
fe791a2c-1196-4271-8dc2-874230674b53
451c36ed-95ac-49c0-bb92-7d9e67f9e96a
eea5471e-73fa-4e31-8465-273c61cf1abc
3c7b4851-f466-4e80-a3f5-a6a39735f583
c362f6c6-874b-4e0e-99e0-bed71dc348f2
11ae9015-e3fc-43d2-be24-bc353f8e1ec1
34f8919d-d935-4e7f-a23a-2fdc8eeb8bce
e96e19e5-ab4b-43f4-8a52-dd463702bed0
94f0c532-f440-4fe5-a3fc-e9d11a59165d
578c90d4-671f-425c-b9b4-a579819c66e6
c4b79747-ba56-47c5-9e6d-a95c7b2f4fb8
46de7a43-75e2-4b20-ba12-648c83c17d2a
400d07e9-e5c0-4094-b3d5-cee58c7fe96e
82c2d516-48ca-418f-ab8c-c39b625af056
2472f147-712a-4207-85a1-93af6a8f7ee6
62909441-813f-4aa2-8c6c-3ee993419193
39e8bbc9-e21a-4577-9c74-fb3d79203328
0c48a1b3-6ae7-4a8d-82c7-ddaced760dde
4cb42d96-bb49-46f0-8069-93cc79527838
5f8a4397-c175-413c-8e50-a56fb6df2461
cf98ed60-5b90-4264-a125-4b19853dff68
486b7c2d-9a18-462e-98fe-b08033674786
c15fcf47-ab31-4907-b3f7-08d86f4fd4fd
efc5a898-c97f-408a-bb94-531e6f40b3a5
d0347bda-8e2f-4c3a-a1aa-e6625b95b775
a41521f2-a15c-4e6b-87f0-ef00a1816e52
8d289dc4-8873-4c9f-9ce9-6e82c87d20ed
d8a2e871-e862-4afe-a3cc-d1c71f1f5987
208cc550-3813-4137-bfcd-12422bfa7ef5
72719efc-3f2f-4291-a5e6-f344cfcda270
14fa6a5f-e926-4fc9-8ed4-4f7cb9555aec
05d14e3b-c06f-42e7-a3ec-6bb75264a725
37b6cd37-feef-46ec-817c-9596443d38ea
beb30c00-2158-445a-bc3e-58be129d9c0d
45fd3c8b-b9d6-49e8-afbc-a8dc2267653f
502d8d62-4314-4220-a337-6c9c7e3638aa
1991d8ac-10fc-4645-b89e-6e0677a0ddee
a82cbd10-391b-446f-9c14-4f16a3279f25
c24b172b-77fe-47ec-8d22-2489b6688c6b
2887a029-33eb-4de0-a66c-1d6b92cb40ce
503e4e5f-ae33-4951-a826-66a6dae5b41f
d731fec3-f621-4524-9b4a-526b6624cd4d
29253d8a-ad50-44ae-abc4-2d059465ac75
88fee196-5974-406c-8bc5-217b32f48dcb
57706ddc-c01b-4ded-a1a8-ef27154be98f
4e7d8579-49ea-4ce6-94a4-788286a34164
ae8cdfd6-f7a0-4b05-a826-8b5531434a02
b73327cd-9440-4298-b469-1405ea350bf9
c1b3f812-6758-455a-964f-e9d515974255
005da870-0014-4f55-bf97-2a0a28e5bf3d
724c3654-3f96-426e-9906-b9a3292450f5
6e5b5819-02d6-44fe-88f0-8eeb3b5a68f8
152891a7-cd00-4a12-afff-f72586e6bdc7
84f846c8-0f9f-499a-a4da-1a16b22afd7e
17946c73-e2af-4228-b6d1-9e97757f6a63
0aac818b-9eb1-4e60-8859-d9ed194b3573
739bd93d-0a22-4f4d-b5eb-ae42c062249c
5f8748f8-fef0-4af6-8954-7fce5ed01c9b
a303c829-29a6-4b82-aea3-c5790d1ede5c
2ade4281-cbdc-48ac-98d2-a8444ea530f3
7f488022-66c2-49d8-8c2d-6fddbe8779dd
7efd9334-2979-4106-b980-368427d8bc88
5f938334-dd60-4d4f-90ee-af4a1fea3a63
82c993bd-4551-4dd3-b292-def2098f0854
ca258f28-834a-4774-addb-f205ce8df0b9
```

**Highest-priority stuck tenants (check these first):**

| Tenant ID | Name | Storage | Why Priority |
|-----------|------|---------|--------------|
| `5edb62e7-d4e6-4911-92ff-cb6b3aefe3fe` | HMIAN | 256 TB | Ring A leader, 55M fake licenses |
| `7d5d12c2-66e9-4254-be08-3eb9c274fe9a` | ZN | 137 TB | Ring A, **filling at 29.7 TB/week** |
| `20f3bc22-a015-4d5b-a0b2-a18316e6c30c` | ALLANIME | 49 TB | 130.7 TB/wk egress |
| `6a63e133-20b0-4a3c-a8bc-f03f7dd7eb7f` | 金融城网络 (jrcpan) | 865 TB | Largest single tenant — commercial cloud reselling |
| `521ba7a8-9833-498a-97ee-f0737a863550` | 黑猫動漫結社 | 114 TB | Anime piracy CDN |
| `022daa44-37bc-4305-b011-16ae93d4fa36` | It Take Two | 79 TB | 4M fake licenses, 9.3 TB/wk upload |
| `c246dfc5-c25d-4006-8e36-d024fd9594e0` | MICROSOFT | 28 TB | Brand impersonation |
| `fbffe1f1-6f5c-416b-a87c-74a988595fc0` | 没有公司 | 31 TB | Named "No Company" (explicit fraud) |
| `fc122104-d0b0-4bee-9c9c-51c1b2b71799` | 飞翔网络 | 4.4 TB | Nanjing license fraud ring |

---

## INV-004: E5 Dev 4-Char Ring — Not Ingested (Kusto Validation Failure)

**ICM:** [771886996](https://portal.microsofticm.com/imp/v5/incidents/details/771886996/summary)  
**Issue:** 14 tenants fail Kusto ValidationFailureException. Never entered FAB. **1,381 TB** sitting outside remediation.  
**Action:** Retry ingestion (metadata may have refreshed since Apr 1) or bypass validation gate via ICM escalation.

```
9e2edf37-07ef-44df-94b7-d03bda7ee3d6
c765c9c7-2bb1-4e2a-b06e-f2fc05a8ab08
09f2df07-28a3-4697-9f6c-aa370e93d6cd
11d0ddd2-2d7f-43ef-9c3b-06a314d8a87b
19239d6d-0019-4ee7-abc2-12ec0aaf17e1
1bb9aeb6-f14e-4c3c-a6c3-79e3d7b77ce3
215b8b0e-fa59-424b-b53f-54ffa2236e9d
23fdcd94-be71-4b91-8df2-9b2e12a67dfe
28eb0462-8ea1-4c5a-a48f-3cfce23b95c9
30c755cc-2b93-4ee2-bcf4-c2a8be5ef7e1
34c96869-10c0-4adf-b2c6-fef2e6e2e7b2
7d811bd2-0cb2-43de-84c0-ad2b5515f609
84a5de99-ecde-4d4c-9b06-8af32120c953
8adf047c-a733-4570-abc1-3dcbe2b621e8
```

| Tenant ID | Name | Storage |
|-----------|------|---------|
| `9e2edf37-07ef-44df-94b7-d03bda7ee3d6` | IHQV | 106 TB |
| `c765c9c7-2bb1-4e2a-b06e-f2fc05a8ab08` | HXGF | 91 TB |
| `09f2df07-28a3-4697-9f6c-aa370e93d6cd` | KJYS | 101 TB |
| `11d0ddd2-2d7f-43ef-9c3b-06a314d8a87b` | RPEJ | 104 TB |
| `19239d6d-0019-4ee7-abc2-12ec0aaf17e1` | ZMDI | 93 TB |
| `1bb9aeb6-f14e-4c3c-a6c3-79e3d7b77ce3` | FTAF | 101 TB |
| `215b8b0e-fa59-424b-b53f-54ffa2236e9d` | WQHS | 72 TB |
| `23fdcd94-be71-4b91-8df2-9b2e12a67dfe` | EKBI | 104 TB |
| `28eb0462-8ea1-4c5a-a48f-3cfce23b95c9` | PZGU | 100 TB |
| `30c755cc-2b93-4ee2-bcf4-c2a8be5ef7e1` | JPTK | 95 TB |
| `34c96869-10c0-4adf-b2c6-fef2e6e2e7b2` | WODX | 97 TB |
| `7d811bd2-0cb2-43de-84c0-ad2b5515f609` | DEEPBYTE | 124 TB |
| `84a5de99-ecde-4d4c-9b06-8af32120c953` | ZFCF | 102 TB |
| `8adf047c-a733-4570-abc1-3dcbe2b621e8` | WEUB | 91 TB |

---

## INV-010: Archetype G — Pending Ingestion

**ICM:** [772521899](https://portal.microsofticm.com/imp/v5/incidents/details/772521899/summary)  
**Issue:** 4 confirmed fraud tenants never ingested into FAB. ~56 TB.  
**Action:** Ingest via FAB MCP. IZONE.DEV may need Legal flag for Wyndham brand impersonation.

```
e16b03cf-f8c4-4652-a943-ee7a1d87e43b
08773a10-f97a-4a73-a72e-346fe7e4c01d
dbfa0f53-94be-41af-9592-37189c548ce4
```

| Tenant ID | Name | Storage | Notes |
|-----------|------|---------|-------|
| `e16b03cf-f8c4-4652-a943-ee7a1d87e43b` | FVRTY | 35 TB | Multi-school domain hijacking |
| `08773a10-f97a-4a73-a72e-346fe7e4c01d` | IZONE.DEV | 17.4 TB | 25 domains, Wyndham brand impersonation |
| `dbfa0f53-94be-41af-9592-37189c548ce4` | M.U.N | 2.9 TB | Commercial eCoupon company |

> MSONLINE (0.3 TB) — full GUID not available in report. Check dashboard by name.

---

## INV-014: FAMILIA CONFEITAR CDN Egress — Escalate READONLY → BLOCK

**ICM:** [775773500](https://portal.microsofticm.com/imp/v5/incidents/details/775773500/summary)  
**Issue:** 26 FAMILIA CONFEITAR tenants still serving ~1.53 PB/week CDN egress despite READONLY (since Apr 8). READONLY blocks uploads but not downloads. ~2.4 PB total egress since READONLY applied. ~$190K estimated bandwidth cost.  
**Action:** Escalate these tenants from READONLY to BLOCK via ICM. Full list of 30 Ring 1 tenants in [FAMILIA_CONFEITAR_Ring_Investigation_Report.md](investigations/FAMILIA_CONFEITAR_Ring_Investigation_Report.md).

---

## INV-017: Brand Impersonation — New Ingestion

**ICM:** ⚠️ Needs creation  
**Issue:** 4 validated "MICROSOFT 365" brand impersonation tenants. Ready for FAB ingestion.  
**Action:** Ingest with ReasonCode 40 (Impersonation) + 56 (EDU abuse). Case 3 (Thailand) conditional — requires institutional contact first.

```
e112b87e-db84-4181-b846-60f1d53bc96e
1e13f78f-2694-423a-9f48-dd2cc288ed94
1addb028-5a03-4736-974b-adcb4825d1d0
```

> Case 3 (conditional — ingest after 2-3 day institution contact attempt):
```
49260145-034d-4a8d-a7d8-ec41cbad0f88
```

| Tenant ID | Name | Country | Storage | Notes |
|-----------|------|---------|---------|-------|
| `e112b87e-db84-4181-b846-60f1d53bc96e` | MICROSOFT 365 | Vietnam | 2.1 TB | pecofficial.edu.vn, 3M lic / 5 enabled, 1,493 ODB sites |
| `1e13f78f-2694-423a-9f48-dd2cc288ed94` | MICROSOFT 365 | Lithuania | 3.2 TB | suutech.net, 6M lic / 13 enabled, ring with Case 1 |
| `1addb028-5a03-4736-974b-adcb4825d1d0` | MICROSOFT 365 | Hong Kong | 27.5 TB | **microsoft365.com.hk** direct trademark, trial commercial |
| `49260145-034d-4a8d-a7d8-ec41cbad0f88` | MICROSOFT 365 | Thailand | 1.5 TB | thanodluang.ac.th — legitimate school domain hijacked. Contact school first. |

**Additional validated impersonation (from casebook — ingest after Phase 1):**

```
15bcdd9e-1d1f-49fb-ad43-dca687e7e6d5
3c7abdb0-e839-4ee9-80e3-ad0186781632
714dfb93-dd90-4546-ad66-f1c07560c208
0d6af5ac-0fb6-4ee6-8c14-f5a9ee8fe560
62a47b6e-483a-4379-bcd2-e802393c76d4
31d928cc-3c39-4ced-b924-1c5e59048dea
```

| Tenant ID | Name | Storage | Notes |
|-----------|------|---------|-------|
| `15bcdd9e-1d1f-49fb-ad43-dca687e7e6d5` | MICROSOFT OFFICE 365 | — | HK, 627016.xyz domain |
| `3c7abdb0-e839-4ee9-80e3-ad0186781632` | OFFICE 365 DOMAINS | — | UK, PAID EDU, 3M+ lic / 9 enabled |
| `714dfb93-dd90-4546-ad66-f1c07560c208` | FEIWU UNIVERSITY | 92 TB | HK, fake institution, 110K lic / 3 enabled |
| `0d6af5ac-0fb6-4ee6-8c14-f5a9ee8fe560` | ARASAKA LIMITED | 79.9 TB | HK, Trial EDU, 3M lic / 3 enabled |
| `62a47b6e-483a-4379-bcd2-e802393c76d4` | ARASAKA PLUS | — | Taiwan, Trial EDU, 3M lic / 18 enabled |
| `31d928cc-3c39-4ced-b924-1c5e59048dea` | DEFAULT DIRECTORY | — | China, 4M lic / 1 enabled |

**Needs verification before ingestion (real institution names — may be abused or may be legit):**

```
a7997b83-e69e-4e36-b24f-78c4e2909fe6
642982c0-f7d5-4a6c-8a40-e78bc19c57a8
8d86cf5b-b18c-4b45-aec1-3629d1a0c938
```

| Tenant ID | Name | Storage | Notes |
|-----------|------|---------|-------|
| `a7997b83-e69e-4e36-b24f-78c4e2909fe6` | HONG KONG TAK MING COLLEGE | 198 TB | 4M lic / 6 users — verify if real school |
| `642982c0-f7d5-4a6c-8a40-e78bc19c57a8` | SCHOOL DISTRICT OF CLAY COUNTY, FL | 95 TB | 1M lic / 2 users — verify |
| `8d86cf5b-b18c-4b45-aec1-3629d1a0c938` | HANYANG UNIVERSITY | — | Singapore, onmicrosoft-only — verify |

---

## INV-018: Unflagged Fraud Validation — New Ingestion

**ICM:** ⚠️ Needs creation  
**Issue:** 35 confirmed fraud tenants from two sampling exercises. None in FAB. ~251 TB.  
**Action:** Bulk ingest. ReasonCode 106 (Investigation).  
**Note:** Only 8-char short prefixes available. Use FAB dashboard search by prefix.

**HIGH tier (ingest first — highest confidence, biggest storage):**

```
4ebc9261
57dadf44
5e94ab8c
87bc768a
1660f6f7
d60d678f
ca456806
3b1e889f
```

| Short ID | Name | Country | Storage |
|----------|------|---------|---------|
| `4ebc9261` | CONG TY CO PHAN FPT | Vietnam | 164.9 TB |
| `57dadf44` | SJSBD | Hong Kong | 17.2 TB |
| `5e94ab8c` | MUD CLUB | Canada | 6.5 TB |
| `87bc768a` | YORI TECH AUTOMATION | India | 6.5 TB |
| `1660f6f7` | TANISHA SYSTEMS, INC | USA | 3.2 TB |
| `d60d678f` | DANSK JØDISK MUSEUM | Denmark | 2.1 TB |
| `ca456806` | PRAGATI SOFTWARE PVT LTD | India | 2.0 TB |
| `3b1e889f` | 成都市龙泉驿区技术培训学校 | Taiwan | 1.7 TB |

**MEDIUM tier:**

```
d24edd0c
73d57438
b5b79a51
eb4342bf
bcfb0070
```

| Short ID | Name | Country | Storage |
|----------|------|---------|---------|
| `d24edd0c` | ABACUS ARK | UK | 3.5 TB |
| `73d57438` | THE CAMBRIDGE INSTITUTE | Austria | 3.4 TB |
| `b5b79a51` | FRANKLINS TRAINING SERVICES | UK | 2.3 TB |
| `eb4342bf` | CHIROPRACTIC AUSTRALIA | Australia | 1.7 TB |
| `bcfb0070` | 茅葺会 はるまちこども園 | Japan | 1.3 TB |

**LOW + NONE tier:**

```
3e9f1305
e096dcba
8d285dfe
b9bff50b
6fb13652
a1a41b14
97cf90a4
d5d95b30
8b58739a
```

| Short ID | Name | Country | Storage |
|----------|------|---------|---------|
| `3e9f1305` | YAM STORE | Indonesia | 1.4 TB |
| `e096dcba` | MTES.NTPC.EDU.TW | Taiwan | 10.7 TB |
| `8d285dfe` | BOYSDENVER.ORG | USA | 5.3 TB |
| `b9bff50b` | STUDYCARE EDUCATION | Vietnam | 3.2 TB |
| `6fb13652` | WANG KANG | Hong Kong | 2.5 TB |
| `a1a41b14` | VASD | Pitcairn Islands | 2.8 TB |
| `97cf90a4` | SOCIAL PSYCHOLOGIST | Hong Kong | 2.6 TB |
| `d5d95b30` | НИЖЕГОРОДСКИЙ ГОСУДАРСТВЕННЫЙ | Russia | 1.0 TB |
| `8b58739a` | NHATTRUNG | Vietnam | 1.7 TB |

**DETAILED_TENANT confirmed fraud (8-char IDs):**

```
9ee6d8aa
5637f60c
a40d2c08
e7bbbeeb
a57a9c98
0d6af5ac
a7997b83
642982c0
714dfb93
```

| Short ID | Name | Country | Storage |
|----------|------|---------|---------|
| `9ee6d8aa` | CORPORATIVO MARVA | Mexico | 0.4 TB |
| `5637f60c` | SOLUCIONES MARVA | Mexico | 0.07 TB |
| `a40d2c08` | TRUNG TÂM HỢP TÁC | Vietnam | 0.1 TB |
| `e7bbbeeb` | PANGRUJUN | China | 0.11 TB |
| `a57a9c98` | SANSKRITI SCHOOL PUNE | India | 0.09 TB |
| `0d6af5ac` | ARASAKA LIMITED | Hong Kong | 0.08 TB |
| `a7997b83` | HONG KONG TAK MING COLLEGE | Hong Kong | 0.2 TB |
| `642982c0` | SCHOOL DISTRICT OF CLAY COUNTY | USA | 0.1 TB |
| `714dfb93` | FEIWU UNIVERSITY | Hong Kong | 0.09 TB |

> **Note:** `0d6af5ac`, `a7997b83`, `642982c0`, `714dfb93` overlap with INV-017 casebook. Ingest once under whichever INV goes first.

---

## Summary: Priority Order

| # | INV | Action | Storage at Stake | ICM |
|---|-----|--------|-----------------|-----|
| 1 | INV-015 | Push `24098c20` remediation | 135 TB (growing +2.5 TB/day) | [776384949](https://portal.microsofticm.com/imp/v5/incidents/details/776384949/summary) |
| 2 | INV-014 | Escalate FAMILIA CONFEITAR READONLY→BLOCK | 1.6 PB, 1.53 PB/wk egress | [775773500](https://portal.microsofticm.com/imp/v5/incidents/details/775773500/summary) |
| 3 | INV-016 | Bulk status check 162 tenants, push stuck | ~1,105 TB stuck | [718092350](https://portal.microsofticm.com/imp/v5/incidents/details/718092350/summary) |
| 4 | INV-004 | Retry ingestion for 14 E5 tenants | 1,381 TB | [771886996](https://portal.microsofticm.com/imp/v5/incidents/details/771886996/summary) |
| 5 | INV-008 | Check 4 stuck tenants | ~237 TB | [772521899](https://portal.microsofticm.com/imp/v3/incidents/details/772521899/home) |
| 6 | INV-010 | Ingest 3 tenants | 55 TB | [772521899](https://portal.microsofticm.com/imp/v5/incidents/details/772521899/summary) |
| 7 | INV-017 | Ingest 3 (+1 conditional) impersonation cases | 34 TB | ⚠️ Create ICM |
| 8 | INV-018 | Ingest 35 tenants (HIGH tier first) | ~251 TB | ⚠️ Create ICM |

**Total addressable: ~4.2 PB**
