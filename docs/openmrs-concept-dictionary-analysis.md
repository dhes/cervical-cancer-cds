# OpenMRS Concept Dictionary — Cervical Cancer Screening Gap Analysis

**Date queried**: 2026-03-08
**Instance**: OpenMRS O3 Reference Application (local Docker)
**API**: `http://localhost/openmrs/ws/rest/v1/concept?q=...`

## Summary

The O3 reference application ships with a general-purpose subset of the CIEL
concept dictionary. It covers primary care, HIV/TB/malaria, maternal health, and
common labs. **It has essentially no cervical cancer screening concepts.** We will
need to load additional CIEL concepts before creating synthetic test data or
running CQL against this instance.

## What IS Present (Relevant)

| Concept | CIEL ID | Mappings | Notes |
|---|---|---|---|
| Malignant neoplasm of cervix uteri | 116023 | SNOMED CT 363354003, ICD-10 C53.9 | End-stage diagnosis only |
| Human immunodeficiency virus (HIV) disease | 138405 | SNOMED CT 86406008, ICD-10 B24, ICPC2 B90 | Well-mapped. Needed for WLHIV pathway. |
| HIV viral load | 856 | CIEL 856 | Numeric test. |
| HIV treatment status | — | SNOMED MVP only | Custom concept, limited mappings. |
| HIV resulting in other conditions | 160160 | ICD-10 B23 | |

## What is NOT Present (Required)

These concepts exist in the full CIEL dictionary but are absent from the reference
application's concept subset. They must be loaded before CDS development can begin.

### Screening Tests

| Clinical Concept | Expected CIEL ID | LOINC | SNOMED CT | Status |
|---|---|---|---|---|
| HPV DNA test | 159859? | 21440-3 | | **Missing** |
| HPV DNA test result (positive/negative) | TBD | | | **Missing** |
| HPV 16 genotyping result | TBD | 77399-4 | | **Missing** |
| HPV 18 genotyping result | TBD | 77400-0 | | **Missing** |
| VIA screening | TBD | | | **Missing** |
| VIA result (positive/negative/suspicious for cancer) | TBD | | | **Missing** |
| Cytology/Pap smear result | TBD | | | **Missing** |
| Cervical cancer screening encounter | TBD | | | **Missing** |

### Diagnoses

| Clinical Concept | Expected CIEL ID | SNOMED CT | ICD-10 | Status |
|---|---|---|---|---|
| CIN1 / LSIL | TBD | 285836003 | N87.0 | **Missing** |
| CIN2 / HSIL | TBD | 285838002 | N87.1 | **Missing** |
| CIN3 | TBD | 92564006 | D06.9 | **Missing** |
| Cervical dysplasia (general) | TBD | | | **Missing** |

### Treatments / Procedures

| Clinical Concept | Expected CIEL ID | SNOMED CT | Status |
|---|---|---|---|
| Thermal ablation of cervix | TBD | 397006004 | **Missing** |
| Cryotherapy of cervix | TBD | 26782000 | **Missing** |
| LEEP / LLETZ | TBD | 120040007 | **Missing** |
| Colposcopy | TBD | 235159007 | **Missing** |

### Immunization

| Clinical Concept | Expected CIEL ID | CVX | Status |
|---|---|---|---|
| HPV vaccine | TBD | 137 (HPV, quadrivalent) | **Missing** |

## Available Concept Sources

The instance has mappings from these terminology systems (relevant ones highlighted):

| Source | Relevance |
|---|---|
| **SNOMED CT** | Primary clinical terminology for conditions, procedures, findings |
| **LOINC** | Lab/test result codes |
| **ICD-10-WHO** | Diagnosis classification |
| **CIEL** | OpenMRS reference terminology — every concept has a CIEL mapping |
| **HL-7-CVX** | Vaccine codes (HPV vaccine = CVX 137) |
| RxNORM | Medications (not directly relevant) |
| AMPATH | Kenya-specific legacy mappings |
| PIH | Partners in Health legacy mappings |
| IMO ProblemIT / ProcedureIT | Commercial terminology (not relevant for us) |
| ANCDAK | WHO SMART Guideline Data Elements — interesting, may have relevant concepts |

## Path Forward: Loading CIEL Concepts

### Option A: Load from Open Concept Lab (OCL)

The full CIEL dictionary is hosted on the Open Concept Lab at
https://app.openconceptlab.org/#/orgs/CIEL/sources/CIEL/. We can:

1. Look up the exact CIEL concept IDs for each required concept
2. Export them as an OCL collection
3. Import into OpenMRS via the OCL subscription module or REST API

### Option B: Create Concepts Manually via REST API

For each missing concept, POST to `/openmrs/ws/rest/v1/concept` with:
- Display name
- Data type (Coded, Numeric, Text, etc.)
- Concept class (Test, Diagnosis, Procedure, etc.)
- Mappings to SNOMED CT, LOINC, ICD-10

This is more work but gives us full control and doesn't require OCL module setup.

### Option C: Import CIEL Subset via SQL

Load concepts directly into the database from a CIEL SQL dump. Fastest but most
brittle and version-dependent.

### Recommendation

**Option A (OCL) is preferred** — it's the officially supported pathway and ensures
our concepts match the canonical CIEL dictionary. Before doing this, we should:

1. Look up exact CIEL IDs for all required concepts on OCL
2. Verify their SNOMED/LOINC/ICD-10 mappings
3. Document the mapping in `docs/concept-mapping.md`
4. Then load them into the OpenMRS instance

If OCL import proves difficult to set up, **Option B (REST API)** is a viable
fallback for the ~20 concepts we need.

## Next Steps

1. **Look up CIEL concept IDs on OCL** for all concepts in the "Required" tables above
2. **Finalize concept-mapping.md** with confirmed CIEL IDs and standard terminology mappings
3. **Load concepts into OpenMRS** via OCL import or REST API
4. **Verify concepts are queryable** via the FHIR endpoint (Observation?code=..., etc.)
