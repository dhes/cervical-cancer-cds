This implementation guide provides computable clinical decision support (CDS)
for cervical cancer screening and treatment, implementing the
[WHO guideline for screening and treatment of cervical pre-cancer lesions for
cervical cancer prevention, 2nd edition (2021)](https://www.who.int/publications/i/item/9789240030824).

### Scope

This IG implements **Algorithm 5: HPV DNA primary screening with VIA triage**
for both the general population of women and women living with HIV (WLHIV).
It covers the full screening cascade:

- **Screening eligibility and scheduling** -- age, sex, HIV status, screening interval
- **Triage** -- VIA assessment of HPV-positive women
- **Treatment** -- ablation eligibility checklist, modality selection
- **Follow-up** -- post-treatment and post-triage-negative retesting, WLHIV double follow-up

### Target Platform

[OpenMRS](https://openmrs.org/) O3 Reference Application with the FHIR2 module,
deployed in low- and middle-income countries (LMICs). The CDS artifacts are
platform-agnostic FHIR R4 and CQL, usable with any FHIR-enabled system.

### Artifacts

This IG contains:

- **5 CQL libraries** implementing the clinical logic
- **4 PlanDefinition resources** defining ECA (Event-Condition-Action) rules
- **5 FHIR Library resources** wrapping the CQL for FHIR-based evaluation

See the [Artifacts](artifacts.html) page for the complete list.

### Technical Approach

Clinical logic is authored in [CQL (Clinical Quality Language)](https://cql.hl7.org/)
and compiled to ELM for runtime evaluation. The CQL uses
[CIEL](https://openconceptlab.org/orgs/CIEL/) terminology codes mapped to
SNOMED CT, LOINC, and ICD-10, matching the OpenMRS concept dictionary.

The CDS follows [WHO SMART Guidelines L3](https://smart.who.int/) conventions:
one CQL library per decision table, shared definitions in a common library,
PlanDefinition resources for each decision rule.

### Dependencies

{% include dependency-table-short.xhtml %}

### IP Statements

{% include ip-statements.xhtml %}
