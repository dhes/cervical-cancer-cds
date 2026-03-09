# Deployment Guide - Cervical Cancer Screening CDS for OpenMRS v0.1.0

* [**Table of Contents**](toc.md)
* **Deployment Guide**

## Deployment Guide

### Prerequisites

* OpenMRS O3 Reference Application with FHIR2 module
* FHIR R4 endpoint accessible (typically `http://<host>/openmrs/ws/fhir2/R4/`)
* Priority CIEL concepts loaded into the OpenMRS concept dictionary

### Required CIEL Concepts

The following concepts must be present in the OpenMRS concept dictionary. Most are available in the standard CIEL distribution; those marked with an asterisk may need to be loaded from the [Open Concept Lab](https://openconceptlab.org/orgs/CIEL/).

| | | |
| :--- | :--- | :--- |
| 703 | Positive | Result |
| 664 | Negative | Result |
| 170145 | HPV DNA detection | Screening test |
| 151185 | Cervical screening (VIA) | Triage test |
| 166706 | Thermocauterization of cervix | Treatment |
| 162812 | Cryosurgery of cervix | Treatment |
| 165084 | LEEP of cervix | Treatment |
| 138405 | HIV disease | Condition |
| 116023 | Malignant neoplasm of cervix uteri | Condition |
| 145809 | CIN 1 | Diagnosis |
| 145807 | CIN 2 | Diagnosis |
| 145806 | CIN 3 | Diagnosis |

### CQL Evaluation Options

**Option 1: Client-side JavaScript (recommended for O3)**

Use [cql-execution](https://github.com/cqframework/cql-execution) with [cql-exec-fhir](https://github.com/cqframework/cql-exec-fhir) in an OpenMRS O3 microfrontend. This runs entirely in the browser, fetching patient data from the local FHIR endpoint.

```
npm install cql-execution cql-exec-fhir

```

**Option 2: Server-side CQF Ruler**

Deploy [CQF Ruler](https://github.com/cqframework/cqf-ruler) alongside OpenMRS for server-side CQL evaluation via `$apply` operations on PlanDefinition resources.

### Loading FHIR Resources

Load the Library and PlanDefinition resources into your FHIR server:

```
# Load Library resources
for lib in input/resources/library/*.json; do
  curl -X POST -H "Content-Type: application/fhir+json" \
    -d @"$lib" http://localhost/openmrs/ws/fhir2/R4/Library
done

# Load PlanDefinition resources
for pd in input/resources/plandefinition/*.json; do
  curl -X POST -H "Content-Type: application/fhir+json" \
    -d @"$pd" http://localhost/openmrs/ws/fhir2/R4/PlanDefinition
done

```

### Known Gaps

* **Procedure resource**: OpenMRS FHIR2 does not support Procedure. Treatments are tracked as Observations until Procedure support is added.
* **ServiceRequest**: Read-only in OpenMRS FHIR2; cannot create referrals programmatically via FHIR.
* **Ablation eligibility**: TZ type assessment requires direct visualization and cannot be fully automated. The CDS presents a point-of-care checklist.

