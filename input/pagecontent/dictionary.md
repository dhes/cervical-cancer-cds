<div>
<p><strong>UNOFFICIAL — NOT WHO-ENDORSED.</strong> This Digital Adaptation Kit is early, in-progress work authored independently by Hopena Health. It is structured using the WHO <code>smart-dak-empty</code> template (CC BY 4.0) but is <strong>not</strong> a WHO publication, not endorsed by WHO, and not part of the official WHO SMART Guidelines program. Shared publicly so the WHO SMART community of practice — in which the author participates — can shape its direction through feedback.</p>
</div>{:.stu-note}

This page defines the data dictionary for v1 of this DAK, scoped strictly to the data elements needed by the Eligibility (`CCS.A.DT1`) and Needs Screening (`CCS.A.DT2`) decisions (see [decision-logic.html](decision-logic.html)). Following WHO SMART DAK Component 5 convention, the dictionary captures only data that needs to be persisted, reported, audited, aggregated, or exchanged. Intermediate computational values that exist only inside the CQL evaluation of a decision rule are *not* dictionary-eligible; they live in the L3 Library resources rather than here.

The structure (column set, namespace, conventions) is patterned on the WHO HIV DAK 2023 data dictionary (Web Annex A). Content is original to this work.

### Namespace conventions

- **Process IDs:** `CCS.A` (Cervical Cancer Screening, Process A — screening encounter at cascade entry). Later DAK cycles will add `CCS.B` for triage, `CCS.C` for treatment, `CCS.D` for follow-up.
- **Activity IDs:** `CCS.A1` through `CCS.A9` for the nine workflow steps in the v1 business process. See [business-processes.html](business-processes.html) for activity definitions.
- **Data Element IDs:** `CCS.A.DE<n>`, numbered sequentially within Process A. Running number 1–11 in v1.
- **Decision Table IDs:** `CCS.A.DT<n>`. v1 has two: `CCS.A.DT1` (Eligibility) and `CCS.A.DT2` (Needs Screening).

### Decision tables referenced in v1

| Decision Table ID | Name | Process |
|---|---|---|
| `CCS.A.DT1` | Eligibility | `CCS.A` Screening encounter at cascade entry |
| `CCS.A.DT2` | Needs Screening | `CCS.A` Screening encounter at cascade entry |

### Data dictionary

The dictionary is presented inline as a Markdown table rather than the WHO-standard `.xlsx` data-dictionary format. v1 does not include an `.xlsx` export; later cycles may add one.

| Activity ID | Data Element ID | Data Element Label | Description and Definition | Multiple Choice | Data Type | Input Options | Quantity Sub-type | Calculation | Required | Linkages to DT | Annotations |
|---|---|---|---|---|---|---|---|---|---|---|---|
| `CCS.A2` Record retrieval / `CCS.A3` Eligibility evaluation | `CCS.A.DE1` | Sex at birth | Biological sex assigned at birth — the anatomic basis for cervical cancer risk. Distinct from administrative gender (FHIR `Patient.gender`). | Select One | Coding | female; not-female (extensible: male, intersex, unknown — Data Type: Codes) | N/A | N/A | R | `CCS.A.DT1` | Resolved from a layered source chain — see Implementation notes. Deployments where `Patient.gender` tracks gender identity rather than sex at birth must disable the fallback layer; see [adapting.html](adapting.html). |
| `CCS.A2` Record retrieval / `CCS.A3` Eligibility evaluation / `CCS.A5` Needs Screening evaluation | `CCS.A.DE2` | Age in completed years at the time of the encounter | The woman's age in integer years, computed from her birthDate and the date of the current encounter. Used for age-bound checks in both `CCS.A.DT1` and `CCS.A.DT2`. | N/A | Quantity | N/A | Integer quantity | `Encounter.period.start − Patient.birthDate` (years) | R | `CCS.A.DT1`, `CCS.A.DT2` | Calculated, not persisted. Will appear in age-stratified screening coverage indicators when those are added in later cycles. |
| `CCS.A2` Record retrieval / `CCS.A3` Eligibility evaluation / `CCS.A5` Needs Screening evaluation | `CCS.A.DE3` | HIV status | The woman's HIV infection status. Determines which WHO recommendation pathway applies — general population or women living with HIV (WLHIV). v1 treats unknown (no relevant Condition or Observation) as equivalent to negative for pathway selection. | Select One | Coding | HIV-positive; HIV-negative; unknown (Data Type: Codes) | N/A | N/A | O | `CCS.A.DT1`, `CCS.A.DT2` | Resolved from FHIR `Condition` (HIV infection, clinicalStatus = active) OR `Observation` (HIV serology code). Absence treated as not-positive. Per the 2026 WHO addendum, "general population of women" means "presumed or confirmed to be HIV-negative." |
| `CCS.A2` Record retrieval / `CCS.A3` Eligibility evaluation | `CCS.A.DE4` | Active cervical cancer diagnosis | Whether the woman has an active diagnosis of cervical cancer (any stage). Used to exclude her from the screening cascade — cervical cancer surveillance and treatment is a separate clinical pathway not addressed by this DAK. | N/A | Boolean | N/A | N/A | Presence of any FHIR `Condition` with cervical cancer code AND `clinicalStatus = active` | O | `CCS.A.DT1` | Absence (no matching Condition) treated as false. PHA may tune the definition of "active" (e.g., excluding "in remission" or "resolved" statuses); v1 default is any non-resolved cervical cancer Condition counts as active. |
| `CCS.A2` Record retrieval / `CCS.A5` Needs Screening evaluation | `CCS.A.DE5` | Prior cervical cancer screening events | Collection of recorded prior cervical cancer screening events for the woman. Each event has a date and a coded result (positive, negative, or inconclusive). Basis for deriving never-screened status, screening history, and interval calculations in `CCS.A.DT2`. | N/A | Coding (collection) | Each event: positive; negative; inconclusive (Data Type: Codes) | N/A | N/A | O | `CCS.A.DT2` | Resolved from FHIR `Observation`, `Procedure`, or `DiagnosticReport` resources with cervical-cancer-screening codes. Specific code set deferred to L3 terminology adaptation. Absence is meaningful (never screened), not missing. |
| `CCS.A5` Needs Screening evaluation | `CCS.A.DE6` | Ever screened | Whether the woman has ever had any recorded prior cervical cancer screening event. | N/A | Boolean | N/A | N/A | `CCS.A.DE5 is non-empty` | R | `CCS.A.DT2` | Calculated, not persisted. Used in the tier-1 and tier-2 priority rules of `CCS.A.DT2`. Will appear in coverage indicators reporting on never-screened populations in later cycles. |
| `CCS.A5` Needs Screening evaluation | `CCS.A.DE7` | Most recent screening date | The date of the woman's most recent prior cervical cancer screening event, if any. | N/A | Date | N/A | N/A | `max(date over CCS.A.DE5)` | C | `CCS.A.DT2` | Conditional: required only if `CCS.A.DE6` Ever screened is true. Calculated, not persisted. Used to evaluate the WHO 8 / 28 screening interval and the WHO 6 / 26 50+-stop rule. |
| `CCS.A3` Eligibility evaluation / `CCS.A4` Branch on Eligibility | `CCS.A.DE8` | Eligibility | Output of the Eligibility decision (`CCS.A.DT1`). Whether the woman is eligible for cervical cancer screening per v1 rules. | Select One | Coding | eligible; ineligible (Data Type: Codes) | N/A | Output of `CCS.A.DT1` | R | `CCS.A.DT1` | Result is conveyed by the L4 application to the persona; may be exchanged via FHIR `CommunicationRequest` or `Task` per L3 design (not yet specified). |
| `CCS.A3` Eligibility evaluation / `CCS.A4` Branch on Eligibility | `CCS.A.DE9` | Eligibility reason | When `CCS.A.DE8` is *ineligible*, the coded reason identifying which `CCS.A.DT1` rule fired. When *eligible*, the value is *none*. | Select One | Coding | none; not-female; active-cervical-cancer; under-age-general-population; under-age-wlhiv (Data Type: Codes) | N/A | Output of `CCS.A.DT1` (paired with `CCS.A.DE8`) | R | `CCS.A.DT1` | Always produced alongside `CCS.A.DE8`. The L4 application uses the reason to inform the persona's next action per PHA-policy guidance — see [business-processes.html](business-processes.html) `CCS.A4`. |
| `CCS.A5` Needs Screening evaluation / `CCS.A6` Branch on Needs Screening | `CCS.A.DE10` | Needs Screening | Output of the Needs Screening decision (`CCS.A.DT2`). Whether the eligible woman currently needs cervical cancer screening per v1 rules. | Select One | Coding | yes; no (Data Type: Codes) | N/A | Output of `CCS.A.DT2`; only produced if `CCS.A.DE8` = eligible | C | `CCS.A.DT2` | Conditional: produced only if `CCS.A.DE8` Eligibility is *eligible*. May be exchanged via `CommunicationRequest` or `Task` per L3 design. |
| `CCS.A5` Needs Screening evaluation / `CCS.A6` Branch on Needs Screening | `CCS.A.DE11` | Needs Screening reason | The coded reason identifying which `CCS.A.DT2` rule fired. | Select One | Coding | never-screened-tier-1; never-screened-tier-2; over-65-never-screened-out-of-scope; over-50-two-negatives; due-per-interval; within-interval (Data Type: Codes) | N/A | Output of `CCS.A.DT2` (paired with `CCS.A.DE10`) | C | `CCS.A.DT2` | Conditional: same precondition as `CCS.A.DE10`. Used by the L4 application to inform the persona of screening rationale. |

### Implementation notes

These notes flag concerns that bridge the L2 dictionary to L3 implementation; they document intent for L3 work and are not themselves L2 rules.

- **`CCS.A.DE1` Sex at birth is *not* simply `Patient.gender`.** Implementations should resolve sex at birth using a layered source chain:
  - *Layer 1*: Patient-level sex-at-birth extension if defined by the deployment's profile (e.g., US Core `us-core-birthsex`). As of v0.2.0, `smart.who.int.base` does not define such an extension; this layer is empty for the default WHO-based profile.
  - *Layer 2*: FHIR `Observation` with LOINC code 76689-9 ("Sex assigned at birth") if the deployment captures sex at birth as an observation.
  - *Layer 3*: `Patient.gender` as the pragmatic default — appropriate for deployments where this field is set at registration to reflect sex at birth and is not subsequently updated to reflect gender identity.

  The CQL attempts each layer in order and uses the first hit. Deployments where `Patient.gender` records gender identity rather than sex at birth must disable layer 3 — see [adapting.html](adapting.html).

- **`CCS.A.DE3` HIV status is read from multiple possible FHIR sources.** Implementations should look at both `Condition` (HIV infection diagnosis) and `Observation` (HIV serology result) and treat "active HIV infection" via either source as *HIV-positive*. Resolved or remission-status HIV conditions should be discussed at the program level — v1 treats any non-resolved HIV `Condition` as *HIV-positive*.

- **`CCS.A.DE5` Prior screening events require a defined local code set.** Each deployment will need to enumerate which codes (LOINC HPV codes, VIA procedure codes, cytology codes) count as cervical cancer screening events. v1 does not commit to a specific code set; this is a terminology-adaptation task per [adapting.html](adapting.html).

- **`CCS.A.DE4` Active cancer diagnosis** is a boolean derived from a Condition query. The simplest v1 implementation queries for any cervical cancer Condition with `clinicalStatus = active` and returns `true` if any match. Stricter staging-aware or status-aware versions can be added in later cycles.

- **The WHO 6 / 26 two-most-recent-negatives rule** referenced by `CCS.A.DT2` requires sorting prior events by date. Edge case: if the woman has only one prior screening result, the rule cannot fire (it requires *two* negatives). If the prior result is inconclusive rather than negative, that event does not count toward the stop rule.

- **Dictionary scope discipline (per WHO HIV DAK README Note 1).** Only data that persists, reports, audits, aggregates, or is exchanged is included here. Earlier v1 drafts included purely intermediate computations (time since most recent screen, two-recent-both-negative, applicable population pathway) as "Derived inputs." Those have been removed from the dictionary per the WHO criterion; they remain as CQL `define` blocks inside the decision-logic implementation. The exception is `CCS.A.DE6` Ever screened and `CCS.A.DE7` Most recent screening date, which are retained because they're expected to appear in coverage indicators in later cycles.

### Items deferred to later DAK cycles

- Full FHIR profile definitions (StructureDefinition resources) for inputs and outputs — L3 work.
- ValueSet and CodeSystem definitions for each coded element — L3 work, dependent on terminology adaptation.
- ConceptMap resources for local-to-WHO-bound terminology adaptation — see [adapting.html](adapting.html).
- Code-system binding columns (ICD-11, ICD-10, LOINC, ICHI, ICF, SNOMED GPS Code / URI / Comments / Relationship) — WHO DAK convention adds these as a tail of columns once terminology bindings exist. v1 has none yet.
- Validation Condition and Explain Conditionality columns — v1's conditionality is captured in Annotations; later cycles may move it into dedicated columns once a richer set of conditional elements exists.
- Linkages to Aggregate Indicators column — v1 has no indicators; will be populated when indicators are added.
- Data dictionary entries for triage, treatment, follow-up, and indicator decisions — out of v1 scope.
- A separate UI-design data dictionary (per the digital transformation handbook §3.5.1 distinction between database-design and UI-design dictionaries) — v1 covers database-design intent only.
- `.xlsx` export of the dictionary in the WHO-standard format.
