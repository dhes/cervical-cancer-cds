### v0.1.0 — Initial working draft (2026-05)

This is the first version of this Implementation Guide. There are no prior versions to compare against.

**Scope of v0.1.0:**

- L2 (operational) content for two decisions at the cervical cancer screening cascade entry point: **Eligibility** (`CCS.A.DT1`) and **Needs Screening** (`CCS.A.DT2`), derived from WHO Algorithm 5 (HPV DNA + VIA triage).
- Single targeted persona (Community Health Worker or Facility Nurse).
- 9-step business process narrative for the screening encounter (`CCS.A1`–`CCS.A9`).
- 11 data dictionary elements with WHO HIV DAK-aligned column structure.
- Pseudocode discipline (FEEL-shaped formal expressions accompanying each decision rule).
- PHA-policy commitment (Option II — 50–65 never-screened included).

**Not in v0.1.0 scope:**

- L3 (machine-readable) artifacts — no FHIR profiles, ValueSets, CQL libraries, or PlanDefinitions yet.
- Triage, treatment, follow-up, and indicator decisions — deferred to later cycles.
- BPMN diagrams for business processes — deferred.
- Terminology mappings to ICD-11, LOINC, SNOMED GPS — deferred to L3 work.

See [adapting.html](adapting.html) for full v1 methodology choices and what's deferred to later cycles.

**Historical note:**

A prior iteration of this work (v1-era, OpenMRS-targeted, with substantive CQL libraries) is preserved on the `v1-archive` branch of this repository for reference. v0.1.0 of this IG is a scaffold-restart on the WHO `smart-dak-empty` template with new identity, scope, and methodology choices.
