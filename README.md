# Cervical Cancer Screening DAK (Working Draft)

> **UNOFFICIAL — NOT WHO-ENDORSED.** This repository contains early, in-progress work toward a Digital Adaptation Kit (DAK), authored independently by [Hopena Health](https://hopenahealth.com). It is structured using the WHO [`smart-dak-empty`](https://github.com/WorldHealthOrganization/smart-dak-empty) template (CC BY 4.0) but is **not** a WHO publication, not endorsed by WHO, and not part of the official WHO SMART Guidelines program.

## Why this exists

As of this writing, WHO has been updating its cervical cancer screening and treatment guidance in phases. Phase 1 (the second edition of the *WHO guideline for screening and treatment of cervical pre-cancer lesions for cervical cancer prevention*, [July 2021](https://www.who.int/publications/i/item/9789240030824)) and phase 2 (the addendum on use of HPV mRNA tests, December 2021, and the addendum on use of dual-stain cytology to triage women after a positive HPV test, 2024) are published. Phase 3 will address implementation; phase 4 will produce a consolidated "living guideline." This repository is the author's in-progress work in the implementation space — an L1↔L4 deployment (from the narrative WHO L1 guidelines through to an executable application) using the Open Health Stack (OHS) / OpenSRP Android FHIR SDK as the L4 platform. Shared publicly so the WHO SMART community of practice, in which the author participates, can shape its direction through feedback.

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
