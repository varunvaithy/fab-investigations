# Impersonation Casebook (Validated)

Date: 2026-04-24
Scope: Unflagged EDU storage population (6,804 tenants)
Method: Name-pattern candidate generation + pooled-license-aware scoring + FAB metadata validation

## Guardrail Applied (to avoid false positives)
We do NOT treat large acquired-license counts alone as fraud because pooled provisioning can be legitimate.
A case is elevated only when naming/identity abuse is combined with additional evidence:
- Brand/university impersonation naming
- Trial/Non-Paid posture with EDU abuse indicators
- Geography/domain mismatch
- High storage with very low enabled users
- Fake/synthetic identity patterns

## Candidate Universe
- Total impersonation candidates: 898
- CRITICAL: 13
- HIGH: 85
- Source file: IMPERSONATION_CASEBOOK_CANDIDATES.csv

---

## A) Obvious Brand Impersonation (High Confidence)

| Tenant ID | Name | Country | Evidence | Assessment |
|---|---|---|---|---|
| e112b87e-db84-4181-b846-60f1d53bc96e | MICROSOFT 365 | Vietnam | 3,000,000 licenses / 5 enabled; 1,493 ODB sites; Non-Paid EDU; custom domain `pecofficial.edu.vn` | **Impersonation likely (HIGH)** |
| 1e13f78f-2694-423a-9f48-dd2cc288ed94 | MICROSOFT 365 | Lithuania | 6,000,000 / 13 enabled; Non-Paid EDU; country/region mismatch signal (LT + Binh Duong) | **Impersonation likely (HIGH)** |
| 49260145-034d-4a8d-a7d8-ec41cbad0f88 | MICROSOFT 365 | Thailand | 2,500,000 / 10 enabled; Non-Paid EDU; viral subscription pattern | **Impersonation likely (HIGH)** |
| 1addb028-5a03-4736-974b-adcb4825d1d0 | MICROSOFT 365 | Hong Kong SAR | Trial commercial; custom domain `microsoft365.com.hk`; large active storage | **Brand misuse likely (HIGH)** |
| 15bcdd9e-1d1f-49fb-ad43-dca687e7e6d5 | MICROSOFT OFFICE 365 | Hong Kong SAR | Non-Paid commercial; custom domain `627016.xyz`; explicit Microsoft naming | **Brand misuse likely (HIGH)** |
| 3c7abdb0-e839-4ee9-80e3-ad0186781632 | OFFICE 365 DOMAINS | United Kingdom | Explicit Office naming; 3,000,002 / 9 enabled; paid EDU | **Impersonation signal strong; needs EDU legitimacy check** |

---

## B) Fake/Synthetic Institution Identity (High Confidence)

| Tenant ID | Name | Country | Evidence | Assessment |
|---|---|---|---|---|
| 714dfb93-dd90-4546-ad66-f1c07560c208 | FEIWU UNIVERSITY | Hong Kong SAR | Non-Paid EDU; 110,000 / 3 enabled; 92 TB; minimal institutional footprint | **Synthetic university likely (HIGH)** |
| 0d6af5ac-0fb6-4ee6-8c14-f5a9ee8fe560 | ARASAKA LIMITED | Hong Kong SAR | Trial EDU; 3,001,000 / 3 enabled; 79.9 TB; synthetic naming pattern | **Synthetic identity likely (HIGH)** |
| 62a47b6e-483a-4379-bcd2-e802393c76d4 | ARASAKA PLUS | Taiwan | Trial EDU; 3,000,000 / 18 enabled; related synthetic naming | **Related synthetic ring likely (HIGH)** |
| 31d928cc-3c39-4ced-b924-1c5e59048dea | DEFAULT DIRECTORY | China | Non-Paid commercial; 4,000,000 / 1 enabled; generic/fake identity name | **Synthetic shell likely (HIGH)** |

---

## C) Real Institution Name Possibly Abused (Needs verification, but suspicious)

| Tenant ID | Name | Country | Evidence | Assessment |
|---|---|---|---|---|
| a7997b83-e69e-4e36-b24f-78c4e2909fe6 | HONG KONG TAK MING COLLEGE | Hong Kong SAR | 4,001,000 / 6 enabled; Non-Paid EDU; 198 TB | **Possible impersonation or abandoned/hijacked tenant (HIGH)** |
| 642982c0-f7d5-4a6c-8a40-e78bc19c57a8 | SCHOOL DISTRICT OF CLAY COUNTY, FL | United States | Trial EDU; 1,000,500 / 2 enabled; 95 TB | **Possible compromise/hijack (HIGH)** |
| 8d86cf5b-b18c-4b45-aec1-3629d1a0c938 | HANYANG UNIVERSITY | Singapore | Non-Paid EDU; onmicrosoft-only; institution-country mismatch | **Impersonation plausible (MEDIUM-HIGH)** |

---

## D) Likely Legitimate/Low Priority Exceptions

| Tenant ID | Name | Country | Evidence | Assessment |
|---|---|---|---|---|
| 860a37a8-2c81-4952-8ed0-992ac51e2bdf | TORONTO METROPOLITAN UNIVERSITY (RU) | Canada | Paid EDU; long-standing institution; very large ODB estate consistent with large university | **Likely legitimate (exclude from immediate action)** |
| 244854eb-2f27-4976-ae90-ca8eca3f5d77 | OFFICE 365 | United States | Paid EDU; moderate ratio; lower abuse signal density | **Brand name suspicious, but lower urgency** |

---

## E) Additional High-Risk Candidates for Next Validation Wave
- ff37e297-0eb6-4027-b933-2a6a17b3a270 (BRINNEL OFFICE 365)
- 2424e8dc-01f2-4285-82b2-06f636c904c0 (MICROSOFT 365)
- ca32407b-aa81-44cb-8761-72f2b5ad5a7c (世纪互联 OFFICE 365)
- 82f43583-01af-450a-932b-c4ec087f322c (MICROSOFT EDUCATION) [FAB lookup not found; possible staleness/deleted]

---

## Recommended Triage Logic (for impersonation angle)
1. Immediate action queue:
   - Brand impersonation names + Trial/Non-Paid + high ratio/low enabled users.
2. Manual verify queue:
   - Real institution names with extreme ratio/storage (possible hijack/abandonment).
3. Exclusion queue:
   - Paid, known large institutions with coherent domain and long-lived operational footprint.

## Suggested Reason Codes (if/when action starts)
- RC 40: Impersonation
- RC 56: EDU abuse
- RC 34: Non-academic domains (when applicable)

