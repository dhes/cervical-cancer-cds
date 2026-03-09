# CQL Evaluation Approach

**Date**: 2026-03-08
**Status**: Recommendation finalized

## Available Options

### Option A: JavaScript cql-execution (via fqm-execution)

**How it works**: CQL is pre-translated to ELM JSON. The `cql-execution` JavaScript
library evaluates ELM against FHIR data retrieved via HTTP from the OpenMRS FHIR
endpoint. Can run in Node.js (CLI/server) or in-browser.

**Dan's existing tooling**:
- `~/fqm-execution/` — fqm-execution v1.7.0 (wraps cql-execution + cql-exec-fhir)
- `~/quality-analytics-service/` — Express service wrapping fqm-execution
- `~/cql_runner/` — Angular CQL IDE with in-browser execution
- `~/simplified-cql-runner/` — Simplified Angular CQL runner
- `~/fqm-test-runner/` — Test harness for CQL measures

**Pros**:
- You know this stack deeply — same as Hopena Dashboard
- Fastest development velocity; can run CQL from CLI immediately
- No Java server infrastructure needed
- Client-side execution model matches OpenMRS community's CDSS architecture
  (the Bacher et al. immunization CDSS uses this exact approach: cql-execution
  in-browser, FHIR data fetched from OpenMRS)
- Can test CQL against OpenMRS FHIR endpoint with minimal setup
- fqm-execution supports $evaluate-measure which could be useful for indicators

**Cons**:
- CQL-to-ELM translation still requires Java (cql-to-elm-cli or translation service)
- Not natively embedded in OpenMRS — requires a separate frontend/service layer
- For production deployment in OpenMRS, would need packaging as an O3 microfrontend

### Option B: Java cql-engine (via cql-cli)

**How it works**: Java CQL engine evaluates CQL directly (or from ELM) against a
FHIR data provider backed by the OpenMRS FHIR endpoint.

**Dan's existing tooling**:
- `~/cql-cli/` — Gradle project with cql-to-elm v3.26.0, model-jackson, elm-jackson
- `~/cql-to-elm-cli-3.26.0.jar` — Standalone translator
- `~/clinical-reasoning/` — Java clinical reasoning library

**Pros**:
- CQL authoring and evaluation in one tool (no separate translation step)
- Java is OpenMRS's native language — closer to production deployment path
- Richer debugging/error messages from the reference implementation

**Cons**:
- Slower development iteration than JavaScript (compile, run JAR)
- More heavyweight for quick CQL prototyping
- OpenMRS community is moving toward client-side CQL execution, not server-side

### Option C: CQF Ruler (HAPI FHIR + CQL)

**How it works**: A HAPI FHIR server with CQL evaluation built in. Load
PlanDefinitions, Libraries, and ValueSets as FHIR resources; invoke
`$apply` or `$evaluate-measure` operations. The server evaluates CQL internally.

**Dan's existing tooling**:
- `~/cqf-ruler/` — Full CQF Ruler project (Maven multi-module)
- `~/cqf-tooling/` — IG tooling for packaging content

**Pros**:
- Full FHIR Clinical Reasoning operations ($apply, $evaluate-measure)
- CQL artifacts are FHIR resources — clean separation of logic from execution
- Closest to the HL7 FHIR Clinical Guidelines IG architecture
- Could proxy to OpenMRS FHIR endpoint for data

**Cons**:
- Requires running a SEPARATE HAPI FHIR server alongside OpenMRS
- Adds infrastructure complexity (now two FHIR servers)
- OpenMRS itself doesn't speak CQF Ruler's operations natively
- Overkill for Phase 2-3 authoring; more relevant for Phase 4 packaging
- The OpenMRS FHIR2 module uses HAPI internally but doesn't expose CQL operations

### Option D: OpenMRS CQL Module (openmrs-module-patientflags + CQL)

**How it works**: OpenMRS's patient flags module has a CQL evaluator that can
trigger flags based on CQL logic. The CQL runs server-side within OpenMRS.

**Pros**:
- Native OpenMRS integration — CDS fires within the EMR workflow
- No separate infrastructure

**Cons**:
- Immature — the OpenMRS Talk thread describes it as early-stage
- Patient flags are a narrow CDS modality (flags, not full recommendations)
- Tied to OpenMRS-specific module API, not portable
- Not suitable for authoring/testing CQL — only for production delivery

## Recommendation: Hybrid Approach

**For CQL authoring and testing (Phase 2-3): Option A — JavaScript cql-execution**

Use `fqm-execution` / `cql-execution` to evaluate CQL against the OpenMRS FHIR
endpoint. This gives the fastest iteration loop:

1. Write CQL in `input/cql/` directory
2. Translate to ELM JSON using `cql-to-elm-cli` (already have the JAR)
3. Run against OpenMRS FHIR endpoint using fqm-execution or a simple Node.js script
4. Use `cql_runner` for interactive development/debugging

The CQL will retrieve FHIR data via HTTP from `http://localhost/openmrs/ws/fhir2/R4/`
with Basic Auth. The `cql-exec-fhir` library handles FHIR data retrieval natively.

**For production deployment (Phase 4): Package as O3 microfrontend**

Following the architecture proven by Bacher et al., package the CQL + ELM as an
OpenMRS 3 microfrontend that runs cql-execution in the browser. This is the
architecture the OpenMRS community has validated for CDSS.

**For population-level indicators: fqm-execution $evaluate-measure**

The `CervicalCancerIndicators.cql` library (% screened, % treated, etc.) maps
naturally to FHIR Measures. Use fqm-execution's measure evaluation capabilities,
which Dan already has working for Hopena quality measures.

## Development Workflow

```
┌─────────────────────────────────────────────────────┐
│  Author CQL                                         │
│  input/cql/CervicalCancerScreeningDecision.cql       │
└──────────────────────┬──────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────┐
│  Translate to ELM                                   │
│  java -jar cql-to-elm-cli-3.26.0.jar                │
│    --input input/cql/ --output elm/ --format JSON          │
└──────────────────────┬──────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────┐
│  Evaluate against OpenMRS                           │
│  node evaluate.js                                   │
│    --elm elm/CervicalCancerScreeningDecision.json    │
│    --fhir http://localhost/openmrs/ws/fhir2/R4/     │
│    --patient <patient-uuid>                         │
└──────────────────────┬──────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────┐
│  Review results                                     │
│  {                                                  │
│    "IsEligibleForScreening": true,                  │
│    "IsDueForScreening": true,                       │
│    "RecommendedAction": "HPV DNA test",             │
│    "ScreeningInterval": "5 years"                   │
│  }                                                  │
└─────────────────────────────────────────────────────┘
```

## Setup Tasks for Phase 2

1. **Verify cql-to-elm-cli works**: Test translating a simple CQL file to ELM JSON
   ```
   java -jar ~/cql-to-elm-cli-3.26.0.jar \
     --input input/cql/ --output elm/ --format JSON --model FHIR --fhir-version R4
   ```

2. **Create a minimal Node.js evaluation script**: Use `cql-execution` and
   `cql-exec-fhir` to evaluate ELM against the OpenMRS FHIR endpoint

3. **Test FHIR data retrieval**: Verify that cql-exec-fhir can authenticate
   to OpenMRS (Basic Auth) and retrieve Patient, Observation, Condition resources

4. **Add elm/ directory to .gitignore**: ELM JSON is a build artifact

## Dependencies to Install

```json
{
  "dependencies": {
    "cql-execution": "^3.2.0",
    "cql-exec-fhir": "^2.1.3"
  }
}
```

Or use fqm-execution directly if measure evaluation is needed:
```json
{
  "dependencies": {
    "fqm-execution": "^1.7.0"
  }
}
```

## References

- Bacher et al., "FHIRing up OpenMRS," AMIA 2024 — client-side cql-execution architecture
- Reusable CDSS for immunization (PMC11469393) — browser-based cql-execution with OpenMRS
- OpenMRS Talk: CDS progress on SMART Guidelines — https://talk.openmrs.org/t/cds-progress-on-implementing-smart-guidelines-in-openmrs/38519
- fqm-execution: https://github.com/projecttacoma/fqm-execution
- cql-execution: https://github.com/cqframework/cql-execution
