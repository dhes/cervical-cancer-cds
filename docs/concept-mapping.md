# Concept Mapping: WHO Guidelines ↔ CIEL ↔ Standard Terminologies

**Date**: 2026-03-08
**Source**: Open Concept Lab API (`https://api.openconceptlab.org/orgs/CIEL/sources/CIEL/`)
**Status**: Initial mapping — CIEL IDs confirmed, ready for OpenMRS import

## How This Document Works

Each concept needed for cervical cancer screening CDS is mapped across three layers:

1. **Clinical concept** — the WHO guideline term
2. **CIEL concept** — the OpenMRS concept dictionary entry (with CIEL ID)
3. **Standard terminologies** — SNOMED CT, LOINC, ICD-10 codes (from CIEL mappings)

The CIEL ID is the primary key for OpenMRS. The SNOMED/LOINC/ICD-10 codes are what
CQL value sets will use. When an Observation or Condition is created in OpenMRS, it
gets coded with the CIEL concept, which carries the standard terminology mappings.

---

## Screening Tests

### HPV DNA Test

| Layer | Value |
|---|---|
| WHO term | HPV DNA test / HPV nucleic acid test (NAT) |
| CIEL ID | **170145** |
| CIEL name | Human papillomavirus (HPV) DNA detection |
| Class / Datatype | Test / Coded |
| SNOMED CT | 35904009 (SAME-AS) |
| LOINC | — (not mapped in CIEL; standard LOINC is 21440-3) |
| Answer concepts | 703 (Positive), 664 (Negative) |
| Notes | This is the primary screening test for all algorithms. Also see CIEL 159859 (HPV PCR qualitative, SNOMED 9718006) — older concept, may appear in legacy data. |

### HPV PCR Qualitative (Legacy)

| Layer | Value |
|---|---|
| CIEL ID | **159859** |
| CIEL name | Polymerase chain reaction, human papilloma virus, qualitative |
| Class / Datatype | Test / Coded |
| SNOMED CT | 9718006 (NARROWER-THAN) |
| Notes | Older concept. CQL value sets should include BOTH 170145 and 159859 to catch historical data. |

### VIA (Visual Inspection with Acetic Acid)

| Layer | Value |
|---|---|
| WHO term | Visual inspection with acetic acid (VIA) |
| CIEL ID | **164805** |
| CIEL name | VIA screening for women aged between 30-49 years |
| Class / Datatype | Misc / N/A |
| SNOMED CT | — (no mapping) |
| Notes | This CIEL concept is age-range-specific and has no standard terminology mapping. It may not be ideal as a test/observation code. Consider also using the generic "Screening result" (CIEL 166664) or "Screened for cancer of uterine cervix" (CIEL 165617, SNOMED 243877001) as the observation code, with VIA-specific answer concepts. **Decision needed.** |

### Colposcopy

| Layer | Value |
|---|---|
| WHO term | Colposcopy |
| CIEL ID | **160705** (generic) or **162816** (with acetic acid) |
| CIEL name | Colposcopy / Colposcopy of cervix with acetic acid |
| Class / Datatype | Procedure / Coded |
| SNOMED CT | 392003006 (160705, SAME-AS), 176786003 + 252689003 (162816) |
| Notes | Use 162816 for VIA-guided colposcopy. 160705 for generic colposcopy. |

### Cytology / Pap Smear

| Layer | Value |
|---|---|
| WHO term | Cytology |
| CIEL ID | **885** |
| CIEL name | Papanicolaou smear |
| Class / Datatype | Test / Coded |
| SNOMED CT | 90226004 (SAME-AS) |

---

## Screening / Test Results (Answer Concepts)

| Result | CIEL ID | CIEL Name | SNOMED CT | LOINC |
|---|---|---|---|---|
| Positive | **703** | Positive | 10828004 | LA6576-8 |
| Negative | **664** | Negative | 260385009 | LA6577-6 |
| Screening result (question) | **166664** | Screening result | — | — |
| ASCUS | **145822** | ASCUS on pap smear | 39035006 | — |
| LSIL / LGSIL | **145808** | Abnormal pap, LGSIL | 309196005 | — |
| HSIL / HGSIL | **145805** | Pap smear with HGSIL | 62061000119107 | — |
| Suspicious for cancer (VIA) | *TBD* | — | — | — |

---

## HPV Genotyping

| Concept | CIEL ID | CIEL Name | SNOMED CT |
|---|---|---|---|
| HPV subtype 16 | **167844** | Human papillomavirus, subtype 16 | 115326008 |
| HPV subtype 18 | **167845** | Human papillomavirus, subtype 18 | 115327004 |

**Note**: These are Organism-class concepts. For genotyping test results, the CQL
would look for an Observation with code = HPV DNA test (170145) and a value or
component indicating HPV 16/18 positivity. The exact observation structure for
genotyping results in OpenMRS needs to be determined — likely an Observation with
value-coded = 167844 or 167845.

---

## Diagnoses

| Diagnosis | CIEL ID | CIEL Name | SNOMED CT | ICD-10 |
|---|---|---|---|---|
| CIN (general) | **120780** | Cervical intraepithelial neoplasia | 285636001 | N87.9 |
| CIN1 | **145809** | CIN grade 1 | 285836003 | N87.0 |
| CIN2 | **145807** | CIN grade 2 | 285838002 | N87.1 |
| CIN3 | **145806** | CIN grade III with severe dysplasia | 285636001 (NARROWER) | D06.9 |
| Cervical cancer | **116023** | Malignant neoplasm of cervix uteri | 363354003 | C53.9 |
| HIV disease | **138405** | Human immunodeficiency virus (HIV) disease | 86406008 | B24 |

### Note on CIN3 SNOMED Mapping

CIEL maps CIN3 (145806) to SNOMED 285636001 as NARROWER-THAN. This SNOMED code is
actually "Cervical intraepithelial neoplasia" (general), not CIN3 specifically.
The specific SNOMED for CIN3 is 92564006 — this mapping may be missing or the CIEL
team chose the broader code. For CQL value sets, include both 285636001 and 92564006
to be safe.

---

## Treatments / Procedures

| Treatment | CIEL ID | CIEL Name | SNOMED CT |
|---|---|---|---|
| Thermal ablation | **166706** | Thermocauterization of cervix | 1287592000 |
| Cryotherapy | **162812** | Cryosurgery of lesion of cervix | 78203001 |
| LEEP/LLETZ (cervix-specific) | **165084** | LEEP of cervix | 23140002 |
| LEEP/LLETZ (generic) | **162810** | Loop electrosurgical excision procedure | 36899001 |
| LEEP indication (question) | **166620** | LEEP indication | 22725004 |
| Treatment of precancerous lesions (question) | **170092** | Treatment of precancerous lesions of cervix | — |

### FHIR Resource Note

Since OpenMRS FHIR2 does not support Procedure, treatments will be recorded as
Observations. The CQL will retrieve them via `[Observation: "Treatment Value Set"]`
where the value set includes CIEL codes 166706, 162812, 165084, and 162810.

---

## Colposcopy Findings (Ablation Eligibility)

These CIEL concepts represent colposcopic findings that inform treatment eligibility:

| Finding | CIEL ID | CIEL Name | SNOMED CT |
|---|---|---|---|
| HGSIL, full extent seen | **166654** | Suspected HGSIL with full extent of lesion seen | 416033009 |
| HGSIL, >75% of surface | **166617** | Suspected HGSIL >75% of cervical surface | 416033009 |
| HGSIL, extending into canal | **166618** | Suspected HGSIL with lesion extending into cervical canal | 416033009 |
| HGSIL, SCJ not visualized | **166619** | Suspected HGSIL with SCJ not fully visualized | 416033009 |

**Ablation eligibility mapping**:
- 166654 (full extent seen) → **eligible** for ablation (if no cancer suspicion)
- 166617 (>75% surface) → **not eligible** (too large for ablation probe)
- 166618 (into canal) → **not eligible** (endocervical extension = TZ type 3)
- 166619 (SCJ not visualized) → **not eligible** (can't confirm TZ type)

---

## Immunization

| Concept | CIEL ID | CIEL Name | SNOMED CT | CVX |
|---|---|---|---|---|
| HPV vaccination (procedure) | **168017** | Administration of HPV vaccine | 761841000 | — |
| HPV quadrivalent vaccine (drug) | **159708** | HPV types 6/11/16/18 vaccine | 2001000221108 | 62 |
| HPV bivalent vaccine (drug) | **159709** | HPV types 16/18 vaccine | 424519000 | 118 |

---

## Screening Status / Workflow

| Concept | CIEL ID | CIEL Name | Class | Datatype |
|---|---|---|---|---|
| Cervical cancer screening status | **170072** | Cervical cancer screening status | Question | Coded |
| Date of last screening | **165429** | Date of last cervical cancer screening | Question | Date |
| Screening for cervical cancer (encounter) | **151185** | Screening for malignant neoplasm of cervix | Diagnosis | N/A |
| Screened for cervical cancer | **165617** | Screened for cancer of uterine cervix | Question | Coded |
| Screening not performed | **165618** | Cervical cancer screening not performed | Finding | N/A |
| Ca cervix screening done | **146602** | Ca cervix - screening done | Diagnosis | N/A |

---

## Concepts NOT Found in CIEL

The following clinical concepts do not appear to have dedicated CIEL concepts:

| Concept | Notes | Proposed Approach |
|---|---|---|
| VIA result (positive/negative/suspicious) | No dedicated VIA result concept. Use generic Positive (703) / Negative (664) as answers to a VIA observation. | Use CIEL 164805 or 165617 as the question, with 703/664 as answers |
| Transformation zone type (1/2/3) | No CIEL concept for TZ classification | May need to create a local concept, or use the HGSIL finding concepts (166617-166619) as proxies |
| "Suspicious for cancer" (VIA finding) | Not explicitly in CIEL | Use CIEL 116023 (malignant neoplasm of cervix uteri) as a referral indicator, or CIEL 170240 (atypia suspicious for malignancy) |
| HPV genotyping result (as a test) | Only organism concepts exist (167844, 167845), not a test concept | Record as components of the HPV DNA test observation |

---

## CQL Value Set Mapping

These are the value sets the CQL libraries will define:

| Value Set Name | Purpose | CIEL IDs | SNOMED Codes |
|---|---|---|---|
| HPV DNA Test Codes | Identify HPV test observations | 170145, 159859 | 35904009, 9718006 |
| VIA Test Codes | Identify VIA observations | 164805, 165617 | 243877001 |
| Cytology Test Codes | Identify Pap smear observations | 885 | 90226004 |
| Colposcopy Procedure Codes | Identify colposcopy | 160705, 162816 | 392003006, 176786003 |
| Positive Result | Positive answer | 703 | 10828004 |
| Negative Result | Negative answer | 664 | 260385009 |
| CIN Diagnoses | All CIN grades | 120780, 145809, 145807, 145806 | 285636001, 285836003, 285838002, 92564006 |
| Cervical Cancer Diagnosis | Invasive cancer | 116023 | 363354003 |
| HIV Diagnosis | HIV status identification | 138405 | 86406008 |
| Treatment Codes | Ablation, cryo, LEEP | 166706, 162812, 165084, 162810 | 1287592000, 78203001, 23140002, 36899001 |
| HPV Vaccine Codes | HPV immunization | 168017, 159708, 159709 | 761841000, 2001000221108, 424519000 |
| HSIL Cytology Results | HSIL on Pap | 145805 | 62061000119107 |
| LSIL Cytology Results | LSIL on Pap | 145808 | 309196005 |
| ASCUS Cytology Results | ASCUS on Pap | 145822 | 39035006 |
| Ablation Ineligible Findings | Colposcopy findings precluding ablation | 166617, 166618, 166619 | 416033009 |

---

## Concepts to Load into OpenMRS

The following CIEL concepts are NOT in the O3 reference application and must be
loaded before creating synthetic test data. Grouped by priority:

### Priority 1 — Required for Algorithm 5 (HPV + VIA Triage)

| CIEL ID | Name | Class |
|---|---|---|
| 170145 | HPV DNA detection | Test |
| 703 | Positive | Misc |
| 664 | Negative | Misc |
| 166706 | Thermocauterization of cervix | Procedure |
| 162812 | Cryosurgery of lesion of cervix | Procedure |
| 165084 | LEEP of cervix | Procedure |
| 145809 | CIN grade 1 | Diagnosis |
| 145807 | CIN grade 2 | Diagnosis |
| 145806 | CIN grade 3 | Diagnosis |
| 151185 | Screening for malignant neoplasm of cervix | Diagnosis |
| 170072 | Cervical cancer screening status | Question |
| 165429 | Date of last cervical cancer screening | Question |

Note: 703 (Positive) and 664 (Negative) are **confirmed present** in the O3
reference app. 116023 (cervical cancer) and 138405 (HIV) also confirmed present.

### Priority 2 — Required for Algorithms 3, 4, 6, 7

| CIEL ID | Name | Class |
|---|---|---|
| 885 | Papanicolaou smear | Test |
| 145805 | Pap smear with HGSIL | Diagnosis |
| 145808 | Pap smear with LGSIL | Diagnosis |
| 145822 | ASCUS on pap smear | Diagnosis |
| 160705 | Colposcopy | Procedure |
| 162816 | Colposcopy of cervix with acetic acid | Procedure |
| 167844 | HPV subtype 16 | Organism |
| 167845 | HPV subtype 18 | Organism |
| 166654 | Suspected HGSIL, full extent seen | Finding |
| 166617 | Suspected HGSIL >75% surface | Finding |
| 166618 | Suspected HGSIL into canal | Finding |
| 166619 | Suspected HGSIL, SCJ not visualized | Finding |

### Priority 3 — Nice to Have

| CIEL ID | Name | Class |
|---|---|---|
| 168017 | HPV vaccine administration | Procedure |
| 159708 | HPV quadrivalent vaccine | Drug |
| 159709 | HPV bivalent vaccine | Drug |
| 159859 | HPV PCR qualitative (legacy) | Test |
| 166620 | LEEP indication | Question |
| 170092 | Treatment of precancerous lesions of cervix | Question |
| 165617 | Screened for cancer of uterine cervix | Question |
| 165618 | Cervical cancer screening not performed | Finding |
