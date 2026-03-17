# Cold Email to WHO Digital Health & Innovation — Draft

**To:** Garrett Mehl, mehlg@who.int
**Subject:** FHIR CDS implementation of WHO cervical cancer screening guidelines — potential DAK contribution

---

Dear Dr. Mehl,

I'm Dan Heslinga, a primary care physician and health IT developer. I'm writing because I've built a computable implementation of the WHO cervical cancer screening and treatment guidelines (Algorithm 5: HPV DNA + VIA triage) and I believe it could contribute to the SMART Guidelines DAK pipeline, where cervical cancer screening is not yet represented.

The project implements the full screening cascade — eligibility, HPV DNA screening, VIA triage, ablation eligibility, treatment modality selection, and post-treatment follow-up — as FHIR R4 CDS artifacts:

- 5 CQL libraries covering general population and WLHIV pathways
- 4 PlanDefinition ECA rules following SMART Guidelines L3 conventions
- 14 synthetic test patients with 82 passing assertions
- CIEL terminology (OpenMRS) with SNOMED, LOINC, and ICD-10 mappings
- Target platform: OpenMRS with FHIR2 Module, for LMIC deployments

Published IG: https://dhes.github.io/cervical-cancer-cds/
Source: https://github.com/dhes/cervical-cancer-cds

Given WHO's cervical cancer elimination strategy and the 70% screening target by 2030, I'd expect digital systems supporting screening programs will need computable decision support. I'd welcome any guidance on whether this work could align with WHO's DAK roadmap, or feedback on how to make it more useful to the SMART Guidelines community.

I've also posted to the WHO SMART Guidelines Zulip channel and OpenMRS Talk for broader community feedback.

Best regards,
Dan Heslinga, MD
Hopena Health
