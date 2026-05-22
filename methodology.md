# Decision Modeling - Cervical Cancer Screening CDS for OpenMRS v0.1.0

* [**Table of Contents**](toc.md)
* **Decision Modeling**

## Decision Modeling

### Decision Modeling Methodology

This IG includes formal decision model artifacts alongside the executable CQL, using the [OMG Decision Model and Notation (DMN)](https://www.omg.org/spec/DMN/) standard to make the relationship between the WHO guideline text and the CQL implementation explicit and traceable.

### Why Decision Models?

WHO SMART Guidelines define three layers of content:

* **L1**: Narrative guideline text (the published WHO document)
* **L2**: Semi-structured decision logic (decision tables, flowcharts)
* **L3**: Fully computable logic (CQL, FHIR PlanDefinitions)

Moving from L1 to L3 requires interpretive decisions – resolving ambiguity, choosing thresholds, mapping concepts to codes, adapting to platform constraints. These decisions are typically made implicitly and undocumented. This IG makes them explicit by producing two L2 artifacts and a register of every divergence between them.

### Two L2 Artifacts

**Textualist L2** (`algorithm-5-hpv-via-textualist.dmn`)

Faithfully mirrors the WHO guideline language without interpretation. Where the guideline says "every 5 to 10 years," the decision table preserves that as a text string. Where the guideline says "women aged 30–49 years," the table uses that range directly. Ambiguity is preserved, not resolved.

**Purposive L2** (`algorithm-5-hpv-via-purposive.dmn`)

Reflects the concrete, operationalized choices made in the CQL implementation. Where the textualist says "every 5 to 10 years," the purposive resolves to 5 (the lower bound, chosen as the most conservative threshold). Where the textualist checks `Client Is Woman`, the purposive checks `Patient.gender = 'female'`. Each resolved choice is annotated with the CQL function and WHO recommendation it traces to.

Both artifacts use the same DMN 1.3 decision table format with the same 6-decision structure, making side-by-side comparison straightforward.

### The Six Decisions

Both artifacts model Algorithm 5 as a Decision Requirements Diagram (DRD) with six chained decisions:

```
Screening Decision --> Due for Screening

Triage Decision ----+--> Treatment Decision --> Follow-up Decision
Ablation Eligibility --+

```

| | |
| :--- | :--- |
| Screening Decision | Eligibility and screening interval |
| Due for Screening | Whether screening is currently needed |
| Triage Decision | VIA result routing (treat, follow-up, or refer) |
| Ablation Eligibility | Whether ablative treatment is appropriate |
| Treatment Decision | Treatment modality selection |
| Follow-up Decision | Post-treatment and post-triage-negative scheduling |

### Interpretation Register

The [Interpretation Register](interpretation-register.md) documents every divergence between the two artifacts. Each entry records:

* What the textualist artifact says (the guideline language)
* What the purposive artifact says (the CQL choice)
* The category of interpretation (Specification, Disambiguation, Inference, or Correction)
* The CQL definition that implements the choice
* The WHO recommendation number
* The rationale for the purposive choice

This register is the central traceability artifact. It allows reviewers to see exactly where and why the CQL departs from the literal guideline text, and to assess whether each departure is appropriate for their context.

### Decision Table Comparison

The [Decision Tables](decision-tables.md) page presents the textualist and purposive tables side by side for each of the six decisions, with divergences highlighted and cross-referenced to the register.

### DMN Files

Both DMN files are available for download on the [Downloads](downloads.md) page, along with rendered HTML views of the decision tables and DRD:

* [Textualist L2 rendered view](images/algorithm-5-hpv-via-textualist.md)
* [Purposive L2 rendered view](images/algorithm-5-hpv-via-purposive.md)

The DMN files can also be opened in any DMN-compatible tool, including [Camunda Modeler](https://camunda.com/download/modeler/) (view only – do not save from Modeler, as it may overwrite FEEL expressions).

