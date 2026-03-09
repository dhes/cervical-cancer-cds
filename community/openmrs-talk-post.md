# OpenMRS Talk Post Draft

**Category:** Projects
**Title:** FHIR CDS for WHO cervical cancer screening (Algorithm 5: HPV DNA + VIA) — seeking feedback

---

Hi everyone,

I'm Dan Heslinga, a primary care physician and founder of Hopena Health. I've been building a FHIR R4 clinical decision support implementation of the WHO cervical cancer screening and treatment guidelines, targeting OpenMRS deployments in low- and middle-income countries.

## What it does

The project implements WHO Algorithm 5 (HPV DNA primary screening + VIA triage) as computable CDS covering the full screening cascade:

- **Screening**: Eligibility checks (age, sex, HIV status), scheduling, due-for-screening alerts
- **Triage**: VIA assessment routing for HPV-positive women
- **Treatment**: Ablation eligibility checklist, modality selection (thermal ablation vs excision)
- **Follow-up**: Post-treatment and post-triage-negative retesting, including WLHIV double follow-up per WHO Rec 33

Both general population (age 30-49, 5-10 year interval) and WLHIV (age 25-49, 3-5 year interval) pathways are supported.

## Technical approach

- **5 CQL libraries** (~2,000 lines of clinical logic) compiled to ELM JSON
- **4 PlanDefinition** ECA rules with `patient-view` triggers
- **CIEL terminology** — all clinical concepts use OpenMRS concept dictionary codes mapped to SNOMED/LOINC/ICD-10
- **Client-side CQL evaluation** using [cql-execution](https://github.com/cqframework/cql-execution), following the architecture described in Bacher et al., "FHIRing up OpenMRS" (AMIA 2024)
- **14 synthetic test patients** with 82 test assertions passing
- Licensed under Apache 2.0

The CQL evaluates against FHIR resources retrieved from the OpenMRS FHIR2 Module. I worked around the current limitation where OpenMRS stores treatment procedures as Observations rather than Procedure resources.

## Published IG and source code

- **Implementation Guide**: https://dhes.github.io/cervical-cancer-cds/
- **GitHub**: https://github.com/dhes/cervical-cancer-cds

The IG follows WHO SMART Guidelines L3 conventions (one CQL library per decision table, PlanDefinition ECA rules).

## Looking for feedback

I'd love to hear from:

1. **OpenMRS implementers** working on cervical cancer screening programs — does this match your clinical workflow? What's missing?
2. **FHIR/CQL developers** — feedback on the CQL patterns, PlanDefinition structure, or terminology bindings
3. **Anyone interested in piloting** this at an OpenMRS site

This is a v0.1.0 release. Known gaps include: colposcopy pathway (not in Algorithm 5), pregnancy deferral, hysterectomy exclusion, and age-based exit from screening.

Thanks for any feedback!

Dan
