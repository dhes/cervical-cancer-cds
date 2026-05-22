# Architecture - Cervical Cancer Screening CDS for OpenMRS v0.1.0

* [**Table of Contents**](toc.md)
* **Architecture**

## Architecture

### CQL Library Architecture

All decision libraries include a shared Common library that provides patient demographics, HIV status, and clinical history retrieval.

```
CervicalCancerScreeningCommon (shared definitions)
  |
  +-- CervicalCancerScreeningDecision (eligibility, cascade routing)
  +-- CervicalCancerTriageDecision (HPV+ VIA triage)
  +-- CervicalCancerTreatmentDecision (ablation eligibility, modality)
  +-- CervicalCancerFollowUpDecision (retest scheduling, WLHIV double follow-up)

```

### FHIR Resource Dependencies

```
PlanDefinition (ECA rule)
  --> Library (CQL wrapper)
        --> CQL source (text/cql)
        --> ELM compiled (application/elm+json)

```

Each PlanDefinition references its Library via the `library` element. Library resources contain base64-encoded CQL and ELM in their `content` array, populated by the IG Publisher during build.

### Data Requirements

The CQL retrieves three FHIR resource types from the patient record:

| | | |
| :--- | :--- | :--- |
| Patient | Age, sex | – |
| Observation | HPV tests, VIA results, treatments | 170145, 151185, 166706, 162812, 165084 |
| Condition | HIV status, cervical cancer, CIN diagnoses | 138405, 116023, 145809, 145807, 145806 |

### OpenMRS FHIR2 Constraints

This IG targets the OpenMRS FHIR2 module, which has specific constraints:

* **No Procedure resource**: Treatments (thermal ablation, cryotherapy, LEEP) are recorded as Observations with treatment concept codes and value = Positive (CIEL 703)
* **SNOMED URI**: OpenMRS uses `http://snomed.info/sct/` (with trailing slash) rather than the standard `http://snomed.info/sct`
* **ServiceRequest**: Read-only in OpenMRS FHIR2

### Terminology Approach

The CQL uses [CIEL](https://openconceptlab.org/orgs/CIEL/) concept IDs as the primary code system (`https://cielterminology.org`), matching the OpenMRS concept dictionary. CIEL concepts are mapped to SNOMED CT, LOINC, and ICD-10 in the OpenMRS concept dictionary.

The CQL retrieves observations using `.code.coding.code contains '<CIEL code>'` patterns and checks result values using CIEL Positive (703) and Negative (664).

### CQL Evaluation

The CQL is designed for client-side evaluation using the JavaScript [cql-execution](https://github.com/cqframework/cql-execution) engine against the OpenMRS FHIR R4 endpoint. This architecture follows the approach validated by Bacher et al. in "FHIRing up OpenMRS" (AMIA 2024, PMC11141833).

Production deployment target: OpenMRS O3 microfrontend running cql-execution in the browser, with FHIR data fetched from the local OpenMRS instance.

