# Email to Brown/Fraser Lab (Bacher et al.) — Draft

**To:** Authors of "FHIRing up OpenMRS" (AMIA 2024)
**Subject:** WHO cervical cancer screening CDS — validates your OpenMRS FHIR architecture

---

Dear Dr. Bacher and colleagues,

I'm Dan Heslinga, a primary care physician working on clinical decision support for OpenMRS. I wanted to share a project that validates the architecture you described in your AMIA 2024 paper "FHIRing up OpenMRS."

I've implemented the WHO cervical cancer screening and treatment guidelines (Algorithm 5: HPV DNA + VIA triage) as a FHIR R4 CDS system targeting OpenMRS deployments in LMICs. The implementation uses your approach — client-side CQL evaluation against FHIR resources from the OpenMRS FHIR2 Module — and it works well.

The project includes:
- 5 CQL libraries covering screening, triage, treatment, and follow-up
- 4 PlanDefinition ECA rules
- Both general population and WLHIV pathways
- 14 synthetic test patients with 82 passing assertions
- CIEL terminology with SNOMED/LOINC/ICD-10 mappings

One practical finding: OpenMRS currently stores treatment procedures as Observations rather than Procedure resources. I worked around this in the CQL by querying Observations with procedure-type CIEL concepts. This is documented in the IG if it's useful for your work.

Published IG: https://dhes.github.io/cervical-cancer-cds/
Source code: https://github.com/dhes/cervical-cancer-cds

I'd welcome any feedback, and I'm interested in potential collaboration if your group is working on similar clinical guidelines for OpenMRS.

Best regards,
Dan Heslinga, MD
Hopena Health
