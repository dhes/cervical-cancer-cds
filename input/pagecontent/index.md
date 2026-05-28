<div>
<p><strong>UNOFFICIAL — NOT WHO-ENDORSED.</strong> This Digital Adaptation Kit is early, in-progress work authored independently by Hopena Health. It is structured using the WHO <code>smart-dak-empty</code> template (CC BY 4.0) but is <strong>not</strong> a WHO publication, not endorsed by WHO, and not part of the official WHO SMART Guidelines program. Shared publicly so the WHO SMART community of practice — in which the author participates — can shape its direction through feedback.</p>
</div>{:.stu-note}

<div>
<p>This DAK is in active development; content is provisional and subject to change.</p>
</div>{:.stu-note}

### Summary

This Implementation Guide presents v0.1.0 of a methodology-demonstration Digital Adaptation Kit (DAK) for cervical cancer screening. It is authored independently by Hopena Health, structured per WHO `smart-dak-empty` conventions, and not endorsed by WHO.

**v0.1.0 scope:** WHO Algorithm 5 (HPV DNA + VIA triage), narrowed to the **Eligibility** and **Needs Screening** decisions at the screening-cascade entry point. The target L4 deployment platform is the Open Health Stack (OHS) / OpenSRP Android FHIR SDK. Cascade activities downstream of the entry-point (triage, treatment, follow-up) and L3 machine-readable artifacts (CQL libraries, ValueSets, profiles) are deferred to later DAK cycles.

### v0.1.0 contents

**Authored L2 content:**

- [Generic Personas](personas.html) — single Community Health Worker or Facility Nurse persona at the screening-cascade entry point
- [User Scenarios](scenarios.html) — three illustrative scenarios exercising the v1 decision boundaries
- [Business Processes](business-processes.html) — 9-step workflow narrative with Activity IDs `CCS.A1`–`CCS.A9`
- [Data Dictionary](dictionary.html) — 11 data elements with WHO HIV DAK-aligned column structure
- [Decision-support Logic](decision-logic.html) — Eligibility (`CCS.A.DT1`) and Needs Screening (`CCS.A.DT2`) decision tables with FEEL-shaped pseudocode
- [Adapting Guidelines for Country Use](adapting.html) — PHA-policy commitments (Option II tier-2 included), sex-at-birth resolution chain, pseudocode conventions, structural adaptation notes

**Reference pages:**

- [Changes](changes.html) — version history
- [References](references.html) — WHO cervical cancer guideline corpus, SMART program resources, methodology paper, standards
- [Dependencies](dependencies.html) — `smart.who.int.base` v0.2.0
- [License](license.html) — Apache 2.0

**Section landings with deferred sub-pages:**

- [Business Requirements](business-requirements.html) — L2 sub-pages (some authored, some deferred)
- [Data Models and Exchange](data-models-and-exchange.html) — L3 sub-pages, all deferred
- [Deployment](deployment.html) — L4 sub-pages, all deferred
- [Indices](indices.html) — artifact and mapping indices

### WHO SMART Guidelines layer model — where v0.1.0 sits

The WHO SMART Guidelines approach distinguishes five layers of knowledge representation:

- **L1** — narrative guideline (WHO published recommendations)
- **L2** — operational requirements / DAK (personas, scenarios, business processes, data dictionary, decision-support logic)
- **L3** — machine-readable representation (FHIR profiles, ValueSets, CodeSystems, CQL libraries, PlanDefinitions)
- **L4** — executable applications and services (reference implementations on specific platforms)
- **L5** — dynamic guidelines that update as evidence emerges

This Implementation Guide is positioned at **L2** — it includes operational content as narrative pages, decision tables, data dictionary, and pseudocode. **L3** is deferred to a later DAK cycle (see [adapting.html](adapting.html) for the documented L3 first-pass discipline). **L4** target is Open Health Stack / OpenSRP Android FHIR SDK, but L4 deliverables are not part of this IG. **L5** is the longer-term WHO vision; this work is positioned to inform L1↔L4 traceability that L5 will eventually depend on.

For more on the SMART Guidelines layer model see [WHO's SMART Guidelines](https://smart.who.int/) and the [Mehl et al. *Lancet Digital Health* article (2021)](https://www.thelancet.com/journals/landig/article/PIIS2589-7500(21)00038-8/fulltext).

### Contact

<p>This is an unofficial work by Hopena Health. For questions or feedback, see <a href="https://hopena.info">hopena.info</a> or open an issue at the <a href="https://github.com/dhes/cervical-cancer-cds/issues">GitHub repository</a>. For questions about the WHO SMART Guidelines program itself, contact <a href="mailto:SMART@who.int">SMART@who.int</a> directly.</p>

### License

This Implementation Guide is licensed under the [Apache License, Version 2.0](https://www.apache.org/licenses/LICENSE-2.0). The underlying `smart-dak-empty` template from WHO is licensed under CC BY 4.0; attribution to that template is retained.

For more license details please see the [license page](license.html).

### Feedback

The most useful feedback for v0.1.0 comes via the WHO SMART community of practice (in which the author participates) or via [GitHub Issues](https://github.com/dhes/cervical-cancer-cds/issues) on this repository. Documentation gaps, methodological inconsistencies with established WHO DAK conventions, and clinical-correctness questions are particularly welcome.
