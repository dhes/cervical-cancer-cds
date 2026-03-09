# Cervical Cancer Screening CDS for OpenMRS

## Project Overview

This project implements WHO cervical cancer screening and treatment guidelines as
computable clinical decision support (CDS) artifacts using FHIR R4 and CQL,
targeting OpenMRS deployments in low- and middle-income countries (LMICs).

### Motivation

Cervical cancer kills ~342,000 women annually, overwhelmingly in LMICs. WHO's
global elimination strategy calls for 70% screening coverage with high-performance
tests, but implementation lags far behind — especially the "cascade" from screening
to triage to treatment to follow-up, where patients are lost at every handoff.

OpenMRS is deployed in 6,000+ health facilities across 45+ LMICs. It has a maturing
FHIR R4 API but virtually no CDS layer for cervical cancer screening. This project
aims to fill that gap by authoring platform-agnostic FHIR/CQL clinical reasoning
artifacts that can run against any FHIR-enabled system, with OpenMRS as the primary
target.

This work is informed by an effective altruism (EA) analysis of marginal utility:
the CDS space for major US screening guidelines (mammography, colonoscopy) is
crowded, but cervical cancer screening CDS for LMIC contexts is essentially
greenfield. The marginal QALY-per-effort is orders of magnitude higher here.

### Relationship to Hopena Health

This is a sister project to Hopena Health's US-focused CDS work (USPSTF guidelines,
CMS quality measures, SMART on FHIR apps for Epic). The architectural patterns are
shared — CQL logic, PlanDefinition-based recommendations, FHIR data retrieval — but
the target guidelines (WHO vs USPSTF), target platform (OpenMRS vs Epic), and target
population (LMIC women vs US primary care patients) differ. Lessons flow both
directions.

## Technical Architecture

### OpenMRS Development Instance

- **Docker deployment**: `openmrs-distro-referenceapplication` (lives in separate directory)
- **FHIR R4 endpoint**: `http://localhost/openmrs/ws/fhir2/R4/`
- **Authentication**: Basic Auth, `admin:Admin123`
- **OpenMRS FHIR IG**: https://fhir.openmrs.org/

### Supported FHIR Resources (OpenMRS FHIR2 Module)

Resources available via the OpenMRS FHIR API that are relevant to this project:

- **Patient** — screening-eligible population identification (age, sex)
- **Observation** — HPV test results, VIA findings, cytology results
- **Condition** — cervical pre-cancer diagnoses (CIN grades)
- **Procedure** — VIA/colposcopy performed, thermal ablation, LEEP/excision
  (NOTE: Procedure is NOT in the current OpenMRS FHIR2 resource list — this is a
  known gap. Treatment tracking may need to use Observation or ServiceRequest as
  workarounds until Procedure support is added.)
- **ServiceRequest** — referrals for triage, treatment, or follow-up
- **Task** — tracking cascade step completion status
- **Encounter** — visit context for screening encounters
- **DiagnosticReport** — grouping of screening/triage results
- **Immunization** — HPV vaccination status (relevant for risk stratification)
- **Group** — cohort definitions for population-level indicators

### Key Gap: Procedure Resource

The OpenMRS FHIR2 module does NOT currently support the Procedure resource. This is
significant because treatment events (thermal ablation, cryotherapy, LEEP/excision)
are most naturally represented as Procedures. Workaround options:

1. Represent treatments as Observations with appropriate SNOMED/LOINC codes
2. Use ServiceRequest with status tracking via Task
3. Contribute Procedure support to the FHIR2 module (longer term)

This gap should be investigated early — query the CapabilityStatement to confirm,
and check OpenMRS Talk / JIRA for any in-progress work on Procedure support.

### CQL Evaluation

- **CQL engine**: To be determined — options include:
  - Java-based cql-engine (same as Hopena's cql-cli setup)
  - fqm-execution (JavaScript, used in Hopena's Dashboard)
  - CQF Ruler (HAPI FHIR server with built-in CQL evaluation)
- **FHIR version**: R4 (matching OpenMRS FHIR2 module)
- **CQL-to-ELM translation**: Existing Hopena pipeline (cql-cli / Gradle)

### Project Structure

```
cervical-cancer-cds/
├── CLAUDE.md              # This file
├── sushi-config.yaml      # FHIR IG configuration
├── ig.ini                 # IG Publisher settings
├── _genonce.sh            # Build IG
├── _updatePublisher.sh    # Download IG Publisher
├── README.md              # GitHub repo README
├── LICENSE                # Apache 2.0
├── input/
│   ├── cql/               # CQL logic libraries (source of truth)
│   │   ├── CervicalCancerScreeningCommon.cql
│   │   ├── CervicalCancerScreeningDecision.cql
│   │   ├── CervicalCancerTriageDecision.cql
│   │   ├── CervicalCancerTreatmentDecision.cql
│   │   ├── CervicalCancerFollowUpDecision.cql
│   │   ├── FHIRHelpers.cql
│   │   └── cql-options.json
│   ├── resources/
│   │   ├── library/       # .unprocessed Library stubs (IG Publisher fills content)
│   │   └── plandefinition/ # PlanDefinition ECA rules (4 files)
│   └── pagecontent/       # IG documentation pages
├── fhir/                  # Fully-authored FHIR resources (reference copies)
│   ├── libraries/         # Complete Library resources with metadata
│   └── plan-definitions/  # Complete PlanDefinition resources
├── tests/                 # CQL test runner and synthetic patients
│   ├── evaluate-cql.mjs
│   ├── create-phase3-patients.mjs
│   └── patients/README.md
├── docs/                  # Design documents
├── elm/                   # ELM build artifacts (.gitignored)
└── .github/workflows/     # CI/CD for IG build + GitHub Pages
```

## Clinical Guidelines Being Implemented

### Primary Source

WHO guideline for screening and treatment of cervical pre-cancer lesions for
cervical cancer prevention, 2nd edition (2021).
https://www.who.int/publications/i/item/9789240030824

### Key Decision Points in the Screening Cascade

1. **Screening eligibility**: Women aged 30-49 (general population) or 25-49
   (women living with HIV). Screening interval: every 5-10 years (general) or
   every 3-5 years (WLHIV).

2. **Screening test**: HPV DNA test is the preferred primary screening method
   (replacing VIA or cytology as primary screen). HPV self-collection is an
   acceptable specimen collection method.

3. **Triage of HPV-positive women**: Options include VIA, cytology, HPV16/18
   genotyping, or colposcopy, depending on available resources.

4. **Treatment decision**: Screen-and-treat approach (treat without histologic
   confirmation) vs. screen-diagnose-treat approach, depending on setting.
   Treatment options: thermal ablation (eligible lesions) or excision (LEEP/LLETZ).

5. **Post-treatment follow-up**: Re-screening at 12 months post-treatment, then
   return to routine screening interval if negative.

6. **Special populations**: Women living with HIV have different screening age,
   interval, and management recommendations throughout.

### Decision Logic Structure (CQL mapping)

Each decision point maps to a CQL library with:
- **Input expressions**: Retrieve relevant FHIR resources (Observations, Conditions, etc.)
- **Decision expressions**: Evaluate guideline criteria
- **Output/Guidance expressions**: Return recommendation text and coded actions
- **PlanDefinition**: Wraps CQL into an event-condition-action rule

This follows the WHO SMART Guidelines L3 authoring conventions:
- Each decision table gets its own CQL library + PlanDefinition
- Common definitions go in a shared library
- CommunicationRequest is used for clinician-facing guidance/alerts
- Test cases cover each row of each decision table

## Concept Mapping Challenge

A critical early task is mapping between:

- **WHO guideline terminology** (clinical concepts as described in the guideline)
- **Standard terminologies** (SNOMED CT, LOINC, ICD-10) used in CQL value sets
- **OpenMRS concept dictionary** (CIEL concepts mapped to standard terminologies)

Key concepts to map:

| Clinical Concept | SNOMED CT | LOINC | ICD-10 |
|---|---|---|---|
| HPV DNA test result | | 21440-3 (HPV DNA) | |
| HPV16/18 genotyping | | 77399-4 (HPV 16), 77400-0 (HPV 18) | |
| VIA result | | | |
| CIN1 / LSIL | 285836003 | | N87.0 |
| CIN2 / HSIL | 285838002 | | N87.1 |
| CIN3 | 92564006 | | D06.9 |
| Thermal ablation | 397006004 | | |
| LEEP/LLETZ | 120040007 | | |
| Cervical cancer screening encounter | | | Z12.4 |
| HIV positive status | 86406008 | | B20 |

This table is preliminary and will be refined against the CIEL concept dictionary.
Document all mapping decisions in `docs/concept-mapping.md`.

## Development Workflow

### Phase 1: Reconnaissance (COMPLETE)

- [x] OpenMRS O3 running locally via Docker
- [x] FHIR R4 endpoint confirmed accessible with Basic Auth
- [x] Query CapabilityStatement to confirm supported resources and search params
  - See `docs/openmrs-capability-statement.md`
  - Procedure confirmed absent; ServiceRequest is read-only
  - Treatment tracking will use Observation (workaround option #1)
- [x] Explore OpenMRS concept dictionary for cervical cancer-related concepts
  - See `docs/openmrs-concept-dictionary-analysis.md`
  - O3 ref app has virtually no cervical cancer concepts (no HPV, VIA, CIN, LEEP, etc.)
  - Only relevant concept present: Malignant neoplasm of cervix uteri (CIEL 116023)
  - HIV concepts are present (CIEL 138405) — sufficient for WLHIV pathway identification
  - ~20 concepts must be loaded from CIEL (via OCL or REST API) before synthetic data creation
- [x] Review WHO cervical cancer screening guideline decision tables in detail
  - See `docs/who-guidelines.md`
  - 7 algorithms, 23 recommendations, 2 populations (general + WLHIV)
  - Start with Algorithm 5 (HPV DNA + VIA triage) — covers both populations, most LMIC-relevant
  - Added CervicalCancerFollowUpDecision as a new CQL library (follow-up logic is complex enough)
  - Ablation eligibility requires TZ type assessment via VIA in all algorithms
- [x] Create initial concept mapping document
  - See `docs/concept-mapping.md`
  - All key CIEL IDs confirmed via OCL API with SNOMED CT / LOINC / ICD-10 mappings
  - ~12 Priority 1 concepts needed for Algorithm 5 (HPV + VIA triage)
  - 703 (Positive), 664 (Negative), 116023 (cervical cancer), 138405 (HIV) already in O3
  - HPV DNA test = CIEL 170145; thermal ablation = CIEL 166706; LEEP = CIEL 165084
  - CIN1/2/3 = CIEL 145809/145807/145806
- [x] Determine CQL evaluation approach (standalone engine vs CQF Ruler vs fqm-execution)
  - See `docs/cql-evaluation-approach.md`
  - **Authoring/testing (Phase 2-3)**: JavaScript cql-execution via fqm-execution
  - **Production deployment (Phase 4)**: O3 microfrontend with client-side cql-execution
  - **Population indicators**: fqm-execution $evaluate-measure
  - CQL-to-ELM translation via existing cql-to-elm-cli-3.26.0.jar
  - Architecture validated by Bacher et al. (AMIA 2024) and OpenMRS immunization CDSS

### Phase 2: Synthetic Data & First CQL

- [x] Load Priority 1 CIEL concepts into OpenMRS (10 concepts via REST API)
  - HPV DNA test (170145), treatments (166706, 162812, 165084), CIN diagnoses (145809/807/806)
  - Screening concepts (151185, 170072, 165429)
  - Added SNOMED/CIEL/LOINC mappings to Positive (703) and Negative (664)
- [x] Create synthetic patients and POST to OpenMRS FHIR endpoint
  - See `tests/patients/README.md` for full scenario details and UUIDs
  - S1 Amara: age 35, never screened (eligible, due)
  - S2 Blessing: age 35, HPV+ 2 weeks ago (needs triage)
  - S3 Chioma: age 35, HPV+ VIA+ (needs treatment)
  - S4 Deka: age 35, treated 10 months ago (follow-up approaching)
  - S5 Esther: age 35, WLHIV, never screened (eligible under HIV criteria)
  - S6 Fatima: age 25, general pop (not yet eligible, age < 30)
  - S7 Grace: age 25, WLHIV (not yet eligible, age < 25)
- [x] Write CervicalCancerScreeningCommon.cql with shared definitions
- [x] Write CervicalCancerScreeningDecision.cql for basic eligibility
- [x] Test CQL evaluation against OpenMRS FHIR endpoint

### Phase 3: Full Decision Logic

- [x] Implement triage decision logic (CervicalCancerTriageDecision.cql)
- [x] Implement treatment decision logic (CervicalCancerTreatmentDecision.cql)
- [x] Implement follow-up scheduling logic (CervicalCancerFollowUpDecision.cql)
- [x] Implement HIV-specific pathway variations (integrated into all libraries)
- [x] Full test suite: 82/82 assertions across 4 libraries × 14 patients
- [x] Build out comprehensive test cases (S8-S14: triage-negative, retest-due, routine-recall, WLHIV double follow-up, retest-positive re-entry, interval-elapsed re-screening)
- [x] Create PlanDefinition resources for each decision rule
  - 5 FHIR Library resources (Common, Screening, Triage, Treatment, FollowUp)
  - 4 PlanDefinition resources (Screening, Triage, Treatment, FollowUp) as ECA rules
  - CPG-on-FHIR pattern: named-event triggers, CQL conditions, dynamicValue actions
  - Canonical URLs: https://hopenahealth.com/fhir/cervical-cancer-cds/
  - All resources in fhir/libraries/ and fhir/plan-definitions/

### Phase 4: Packaging & Community Engagement

- [ ] Package as FHIR Implementation Guide (using IG Publisher)
- [ ] Publish to GitHub
- [ ] Engage OpenMRS FHIR squad (OpenMRS Talk, Slack #fhir)
- [ ] Connect with WHO SMART Guidelines L3 authoring community
- [ ] Explore connection with Brown/Fraser lab (Bacher et al. authors)

## Key References

- Bacher et al., "FHIRing up OpenMRS: Architecture, Implementation and Real-World
  Use-Cases in Global Health," AMIA 2024. PMC11141833
- WHO cervical cancer screening guideline (2021):
  https://www.who.int/publications/i/item/9789240030824
- WHO SMART Guidelines L3 SOP (CQL authoring conventions):
  https://smart.who.int/ig-starter-kit/
- OpenMRS FHIR IG: https://fhir.openmrs.org/
- OpenMRS FHIR2 module source: https://github.com/openmrs/openmrs-module-fhir2
- CDC CCSM CDS (US context, FHIR/CQL-based): PMC9206487
- cqframework content-ig-walkthrough: https://github.com/cqframework/content-ig-walkthrough
- HL7 FHIR Clinical Guidelines IG: http://hl7.org/fhir/uv/cpg/

## Community Entry Points

- **OpenMRS Talk forum**: https://talk.openmrs.org/ (introduce yourself, join FHIR discussions)
- **OpenMRS Slack**: slack.openmrs.org (channels: #fhir, #fhir-development)
- **OpenMRS FHIR squad weekly calls**: check community calendar
- **Healthcare providers WhatsApp group**: community@openmrs.org
- **WHO SMART Guidelines**: https://smart.who.int/
- **HL7 FHIR chat**: https://chat.fhir.org/

## Notes for Claude Code Sessions

- The OpenMRS Docker instance is in a SEPARATE directory from this project.
  Do not modify files in openmrs-distro-referenceapplication/.
- FHIR endpoint: http://localhost/openmrs/ws/fhir2/R4/
- Auth: Basic Auth with admin:Admin123
- Test FHIR connectivity with:
  `curl -u admin:Admin123 http://localhost/openmrs/ws/fhir2/R4/Patient`
- The OpenMRS FHIR2 module uses HAPI FHIR internally — same library as the
  Hopena HAPI FHIR server (cds.hopena.info), so behavior should be familiar.
- CQL value sets should use standard terminologies (SNOMED, LOINC) that map
  to CIEL concepts in the OpenMRS concept dictionary. The OpenMRS concept
  dictionary uses CIEL as its primary reference and maps to SNOMED/LOINC/ICD-10.
- When writing CQL, follow WHO SMART Guidelines L3 conventions:
  - One CQL library per decision table
  - Common definitions in a shared library
  - PlanDefinition references CQL Library
  - @input:, @output:, @pseudocode:, @guidance: comment tags
  - Test resources for each decision table row