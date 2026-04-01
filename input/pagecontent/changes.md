### v0.2.0 (2026-04-01)

Decision modeling and traceability update.

- Textualist L2 DMN artifact (6 decisions, mirrors WHO guideline language)
- Purposive L2 DMN artifact (6 decisions, reflects CQL implementation choices)
- Interpretation Register documenting 34 divergences between the two artifacts
- Decision Modeling methodology page
- Decision Tables comparison page (side-by-side textualist vs purposive)
- Fixed screening age upper bound: Maximum Screening Age changed from 50 to 49, matching WHO Rec 7 ("women aged 30--49 years")
- Updated algorithm page: stop screening age clarified as priority range 30--49 with cessation after age 50

### v0.1.0 (2026-03-09)

Initial release.

- WHO Algorithm 5: HPV DNA primary screening + VIA triage
- 5 CQL libraries (Common, Screening, Triage, Treatment, FollowUp)
- 4 PlanDefinition ECA rules
- General population and WLHIV pathway support
- CIEL terminology (OpenMRS concept dictionary)
- 14 synthetic test patients, 82 test assertions passing
- OpenMRS FHIR2 compatibility (treatment-as-Observation workaround)
