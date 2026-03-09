# Cervical Cancer Screening CDS for OpenMRS

FHIR R4 clinical decision support implementing [WHO cervical cancer screening and treatment guidelines](https://www.who.int/publications/i/item/9789240030824) (Algorithm 5: HPV DNA + VIA triage), targeting OpenMRS deployments in low- and middle-income countries.

**Published IG**: https://dhes.github.io/cervical-cancer-cds/

## What This Does

Computable CDS covering the full WHO screening cascade:
- **Screening**: Eligibility (age, sex, HIV status), scheduling, due-for-screening alerts
- **Triage**: VIA assessment routing for HPV-positive women
- **Treatment**: Ablation eligibility checklist, modality selection (thermal ablation vs excision)
- **Follow-up**: Post-treatment and post-triage-negative retesting, WLHIV double follow-up (WHO Rec 33)

Both general population (age 30-49, 5-10 year interval) and WLHIV (age 25-49, 3-5 year interval) pathways.

## Artifacts

- 5 CQL libraries (2,055 lines of clinical logic)
- 4 PlanDefinition resources (ECA rules)
- 5 FHIR Library resources
- 14 synthetic test patients, 82 assertions passing

## Building the IG

### Docker (recommended)

Prerequisites: Docker, Node.js 18+

```bash
npm install -g fsh-sushi
./_updatePublisher.sh -y
./_genonce.sh docker
```

### Local

Prerequisites: Java 17+, Node.js 18+, Jekyll

```bash
npm install -g fsh-sushi
./_updatePublisher.sh -y
./_genonce.sh
```

Output: `output/index.html`

## Running Tests

Prerequisites: Node.js 18+, OpenMRS O3 running locally with synthetic patients

```bash
npm install
node tests/evaluate-cql.mjs
```

## Technical Approach

- **CQL** for clinical logic, compiled to ELM JSON
- **CIEL terminology** (OpenMRS concept dictionary) mapped to SNOMED/LOINC/ICD-10
- **Client-side evaluation** via [cql-execution](https://github.com/cqframework/cql-execution)
- **WHO SMART Guidelines L3** conventions (one CQL library per decision table, PlanDefinition ECA rules)

## References

- [WHO cervical cancer screening guideline (2021)](https://www.who.int/publications/i/item/9789240030824)
- [WHO SMART Guidelines](https://smart.who.int/)
- [OpenMRS FHIR IG](https://fhir.openmrs.org/)
- Bacher et al., "FHIRing up OpenMRS," AMIA 2024 ([PMC11141833](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC11141833/))

## License

Apache 2.0
