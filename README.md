# Cervical Cancer Screening DAK (Methodology Demonstration)

> **UNOFFICIAL — NOT WHO-ENDORSED.** This repository contains a Digital Adaptation Kit (DAK) authored independently by [Hopena Health](https://hopenahealth.com) as a **methodology demonstration**. It is structured using the WHO [`smart-dak-empty`](https://github.com/WorldHealthOrganization/smart-dak-empty) template (CC BY 4.0) but is **not** a WHO publication, not endorsed by WHO, and not part of the official WHO SMART Guidelines program.

## Why this exists

As of this writing, no publicly available WHO cervical cancer SMART DAK has been published, although the underlying L1 narrative guideline ([2021](https://www.who.int/publications/i/item/9789240030824) plus subsequent updates) exists. This work fills that gap as a non-official methodology demonstration. Discussion is ongoing within the WHO SMART community of practice.

## Scope (v1, in progress)

- **L1:** WHO cervical cancer screening guideline (2021+), Algorithm 5 (HPV DNA + VIA triage), narrowed to **Eligibility Decision** and **Needs Screening Decision** only.
- **L2:** Single persona (CHW or facility nurse, OpenSRP-shaped workflow), two decision tables, authored data dictionary patterned on the WHO HIV DAK structure.
- **L3:** FHIR profiles, ValueSets, Questionnaires, PlanDefinitions, and CQL libraries for the v1 scope.
- **L4 target:** Open Health Stack (OHS) / OpenSRP Android FHIR SDK.

The v1 scope is deliberately narrow. Broader Algorithm 5 coverage (triage, treatment, follow-up) and other algorithms are deferred to later versions, after the L1↔L2↔L3↔L4 round-trip is demonstrated cleanly.

## Status

- **GitHub Pages: unpublished** while v2 content is in flight. The published IG URL will be restored after v2 content is properly disclaimed and branded.
- **Prior work (v1)** — an OpenMRS-targeted CDS implementation with 5 CQL libraries, 4 PlanDefinitions, and 82/82 passing assertions — is preserved on the [`v1-archive`](https://github.com/dhes/cervical-cancer-cds/tree/v1-archive) branch.

## Building the IG

```bash
./_updatePublisher.sh -y
./_genonce.sh
```

Output: `output/index.html`.

Build prerequisites: Java 17+, Node.js 18+, Jekyll.

## References

- WHO cervical cancer screening guideline (2021): https://www.who.int/publications/i/item/9789240030824
- WHO SMART Guidelines: https://smart.who.int/
- WHO smart-dak-empty template: https://github.com/WorldHealthOrganization/smart-dak-empty
- Open Health Stack: https://developers.google.com/open-health-stack
- Android FHIR SDK: https://github.com/google/android-fhir

## License

This Implementation Guide is licensed under the [Apache License, Version 2.0](LICENSE). The underlying `smart-dak-empty` template from WHO is licensed under CC BY 4.0; attribution to that template is retained.
