# WHO SMART Guidelines Community Post Draft

**Subject:** L3 implementation of WHO cervical cancer screening Algorithm 5 (HPV DNA + VIA)

---

Hello,

I'd like to share a FHIR R4 CDS implementation of the WHO cervical cancer screening and treatment guidelines, specifically Algorithm 5 (HPV DNA primary screening + VIA triage).

## L3 conventions followed

- One CQL library per decision table (Screening, Triage, Treatment, Follow-Up) plus a shared Common library
- PlanDefinition ECA rules with `patient-view` triggers
- WHO SMART template for the published Implementation Guide
- Population-specific pathways: general population and WLHIV

## Scope

The implementation covers the full screening cascade: eligibility determination, HPV DNA screening, VIA triage for HPV-positive women, ablation eligibility assessment, treatment modality selection, and post-treatment/post-triage follow-up scheduling including WLHIV double follow-up (Rec 33).

## Artifacts

- 5 CQL libraries (~2,000 lines)
- 4 PlanDefinition resources
- 14 synthetic test patients, 82 assertions passing
- Target platform: OpenMRS with FHIR2 Module

## Links

- **Published IG**: https://dhes.github.io/cervical-cancer-cds/
- **Source code**: https://github.com/dhes/cervical-cancer-cds
- **License**: Apache 2.0

The IG uses CIEL terminology (OpenMRS concept dictionary) with mappings to SNOMED, LOINC, and ICD-10. Client-side CQL evaluation is used following the approach described in Bacher et al. (AMIA 2024).

I'm interested in feedback on the L3 representation and whether this could serve as a reference implementation for WHO Algorithm 5.

Dan Heslinga
Hopena Health
