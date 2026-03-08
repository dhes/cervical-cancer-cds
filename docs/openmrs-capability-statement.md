# OpenMRS FHIR2 Module — CapabilityStatement Analysis

**Date queried**: 2026-03-08
**Endpoint**: `http://localhost/openmrs/ws/fhir2/R4/metadata`
**FHIR version**: R4 (4.0.1)
**Server software**: HAPI FHIR 5.4.0 (embedded in OpenMRS FHIR2 module)

## Supported Resources — Project Relevance

### Full CRUD

| Resource | Interactions | Search Params (project-relevant) |
|---|---|---|
| Patient | create, read, update, patch, delete, search | `identifier`, `birthdate`, `gender`, `name`, `given`, `family`, `death-date`, `deceased` |
| Condition | create, read, update, patch, delete, search | `code`, `clinical-status`, `onset-date`, `onset-age`, `patient`, `recorded-date` |
| Encounter | create, read, update, patch, delete, search | `date`, `type`, `location`, `participant`, `patient`, `_tag` |
| DiagnosticReport | create, read, update, patch, delete, search | `code`, `encounter`, `issued`, `patient`, `result` |
| Task | create, read, update, patch, delete, search | `status`, `based-on`, `owner` |
| Immunization | create, read, update, delete, search | `patient` only — no vaccine-code search |
| Group | create, read, delete, search | `managing-entity` only |
| Practitioner | create, read, update, patch, delete, search | `identifier`, `name`, `given`, `family` |

### Create + Read + Search (no update)

| Resource | Interactions | Search Params (project-relevant) |
|---|---|---|
| Observation | create, read, delete, search | `code`, `category`, `date`, `encounter`, `patient`, `value-concept`, `value-date`, `value-quantity`, `value-string` |

### Read-Only

| Resource | Interactions | Search Params (project-relevant) |
|---|---|---|
| ServiceRequest | read, search | `code`, `encounter`, `occurrence`, `patient`, `requester` |
| MedicationRequest | read, patch, search | `code`, `encounter`, `medication`, `patient`, `status` |

### Not Supported

| Resource | Notes |
|---|---|
| **Procedure** | Not present in CapabilityStatement. Confirmed gap. |

## Implications for Cervical Cancer CDS

### 1. Treatment Tracking — Procedure Gap

The OpenMRS FHIR2 module does not support the Procedure resource. Treatments
(thermal ablation, cryotherapy, LEEP/excision) are core to the screening cascade.

**CLAUDE.md proposed three workarounds:**

| Option | Feasibility | Verdict |
|---|---|---|
| 1. Represent treatments as Observations | **Viable.** Observation supports create and code-based search. | **Use this.** |
| 2. ServiceRequest + Task status tracking | **Not viable.** ServiceRequest is read-only (no create via FHIR). | Eliminated. |
| 3. Contribute Procedure support upstream | Long-term. Does not help near-term CQL authoring. | Defer. |

**Decision: Use Observation for treatment events.** Encode treatments as
Observations with SNOMED procedure codes in `Observation.code` and the treatment
date in `Observation.effectiveDateTime`. Use `Observation.category` to distinguish
treatment observations from screening/test result observations (e.g., a custom
category code or the `procedure` category).

This is admittedly a data-modeling compromise, but it's the pragmatic path given
the FHIR2 module's current resource support. The CQL will retrieve treatments via
`[Observation: "Treatment Value Set"]`, which works fine. If/when Procedure support
is added, the CQL can be refactored to use `[Procedure: ...]` instead.

### 2. Observation Has No Update

Observations cannot be modified after creation (no update or patch interaction).
Corrections require deleting the original and creating a new resource. This is
acceptable for this project — screening results and treatment records are typically
recorded once and not amended. But it means:

- CQL doesn't need to worry about amended vs. original observations
- If test data needs correction during development, use delete + recreate

### 3. Immunization Search Is Limited

The Immunization resource only supports search by `patient` — no `vaccine-code`
parameter. This means CQL cannot server-side filter for HPV vaccines; it must
retrieve all immunizations for a patient and filter client-side by vaccine code.

For the CQL, this means:
```cql
// This will retrieve ALL immunizations, then CQL filters by code
define "HPV Vaccinations":
  [Immunization] I
    where I.vaccineCode in "HPV Vaccine Codes"
```

This is fine for individual patient evaluation. Could be a performance concern for
population-level queries over large cohorts, but likely acceptable given that most
patients in LMIC settings have few immunization records.

### 4. ServiceRequest Is Read-Only

Cannot create ServiceRequests via FHIR. This limits the ability to programmatically
generate referrals (e.g., "refer to colposcopy"). Two alternatives:

- **CDS output only**: The PlanDefinition/CQL produces a recommendation
  ("refer for colposcopy") but doesn't create a FHIR resource. The clinician
  acts on it manually via the OpenMRS UI.
- **Task-based tracking**: Use Task (full CRUD) to track whether a recommended
  action has been completed, even if the referral itself isn't a FHIR resource.

The CDS-output-only approach is standard for guideline-based CDS and is sufficient
for Phase 2-3. Task-based tracking can be layered on later.

### 5. Resources Not Needed

The following supported resources are not directly relevant to cervical cancer CDS:

- AllergyIntolerance, Medication, MedicationDispense, MedicationRequest
- Location (indirectly useful for facility-level reporting, but not in CQL logic)
- Person, RelatedPerson
- ValueSet, OperationDefinition

## Search Parameter Inventory — CQL Data Retrieval

For CQL expressions that retrieve FHIR resources, the available search parameters
determine what the CQL engine can push down to the server vs. filter client-side.

| CQL Retrieve | Server-Side Filterable? | Notes |
|---|---|---|
| `[Patient]` | Yes — `birthdate`, `gender` | Age + sex for eligibility |
| `[Observation: code]` | Yes — `code` search param | HPV results, VIA results, treatment events |
| `[Observation: category]` | Yes — `category` search param | Distinguish test results from treatments |
| `[Condition: code]` | Yes — `code` search param | CIN diagnoses, HIV status |
| `[Encounter: type]` | Yes — `type` search param | Screening encounters |
| `[DiagnosticReport: code]` | Yes — `code` search param | Grouped screening results |
| `[Immunization]` | Patient only | Must filter by vaccine code in CQL |
| `[Task: status]` | Yes — `status` search param | Cascade step tracking |

## Full Resource List

For completeness, all 18 resource types in the CapabilityStatement:

AllergyIntolerance, Condition, DiagnosticReport, Encounter, Group, Immunization,
Location, Medication, MedicationDispense, MedicationRequest, Observation,
OperationDefinition, Patient, Person, Practitioner, RelatedPerson, ServiceRequest,
Task, ValueSet
