<div>
<p><strong>UNOFFICIAL — NOT WHO-ENDORSED.</strong> This Digital Adaptation Kit is early, in-progress work authored independently by Hopena Health. It is structured using the WHO <code>smart-dak-empty</code> template (CC BY 4.0) but is <strong>not</strong> a WHO publication, not endorsed by WHO, and not part of the official WHO SMART Guidelines program. Shared publicly so the WHO SMART community of practice — in which the author participates — can shape its direction through feedback.</p>
</div>{:.stu-note}

A persona is a depiction of a relevant stakeholder or end user of the system. Generic personas in WHO SMART DAKs are based on the core competencies and credentials of health worker roles. The persona scoping in this v1 is deliberately narrow; the full persona structure consistent with WHO SMART DAK Component 3 (typically rendered as a Table 3 of targeted personas with key competencies and a Table 4 of related personas) will be developed in later cycles.

### v1 targeted persona

v1 of this DAK targets a **single** persona at the entry point of the cervical cancer screening cascade. Additional personas (the clinician handling triage and treatment, the outreach worker conducting active recruitment, the woman herself for self-screening workflows, the supervisor consuming population indicators) are out of scope for v1.

**Persona (generic):** Community Health Worker or Facility Nurse at the screening-cascade entry point.

**Setting:** Lower-level health facility or community outreach site in a low- or middle-income country (LMIC). The worker carries an Android device running a Cervical Cancer Screening application built on the Open Health Stack (OHS) / OpenSRP Android FHIR SDK. Connectivity is intermittent; the application supports offline operation and synchronization.

**Program context (v1 PHA policy — see [adapting.md](adapting.html) for details and alternatives):** The Public Health Authority has elected the *resource-adequate* posture for cervical cancer screening. HPV DNA testing capacity is available for both:
- the priority age cohort: women aged 30–49 (general population) and 25–49 (women living with HIV); and
- the secondary priority cohort: women aged 50–65 who have never been screened.

**Tools and information available to this persona:**
- HPV DNA test (per WHO recommendation 1/21 as the primary screening modality)
- Either Visual Inspection with Acetic acid (VIA) on-site or a referral pathway to a facility providing VIA, for triage of HPV-positive women (handled in later DAK cycles)
- An Android device running the OHS/OpenSRP-based application, which queries the woman's FHIR-based health record for demographic information, HIV status, and prior screening history
- The two decision-support outputs from this DAK: an Eligibility determination and a Needs Screening determination

### Key competencies and responsibilities of this persona, within v1 scope

| Competency / responsibility | v1 status |
|---|---|
| Encounters a woman presenting at the facility or visited in the community | Entry point to the v1 cascade |
| Confirms the woman is registered in the health record | Assumed already done by another role or process (registration is not a v1 decision) |
| Determines whether the woman is eligible for cervical cancer screening | **In scope — the Eligibility decision** |
| Determines whether an eligible woman is currently due for a screening event | **In scope — the Needs Screening decision** |
| Conveys the recommendation to the woman and supports shared decision making | Implicit in the L4 application's user interaction; not authored as a separate DAK rule in v1 |
| Performs HPV DNA sample collection or supports the woman in self-collection | Acknowledged but agnostic per WHO recommendation 4/24; v1 does not commit to a sample collection method |
| Records the screening event and its result in the FHIR-based health record | Necessary for cascade continuity (subsequent decisions read this history); the L4 application supports this, but it is not authored as a decision rule in v1 |
| Conducts VIA triage for HPV-positive women, or refers for VIA | Deferred to a later DAK cycle covering triage |
| Performs or refers for treatment (thermal ablation, large-loop excision) | Deferred to a later cycle |
| Conducts follow-up scheduling and post-treatment surveillance | Deferred to a later cycle |

### Population this persona engages with in v1

- **Asymptomatic women.** Women presenting with symptoms suggestive of cervical pathology (abnormal bleeding, post-coital bleeding, persistent pelvic pain) belong in a diagnostic pathway not addressed in v1 and should be referred according to local clinical protocols. v1's decision logic assumes the women being screened are asymptomatic.
- **Women not previously diagnosed with cervical cancer.** Women with a known active cervical cancer diagnosis are in oncology surveillance pathways not addressed in this DAK. They are explicitly excluded by the Eligibility decision (see [decision-logic.md](decision-logic.html)).
- **Women in either the general population or living with HIV pathway**, as identified by recorded HIV status in the health record. The HIV status flag drives both the lower age eligibility bound (per WHO 5/25) and the screening interval (per WHO 8/28).

### Related personas (deferred)

Later cycles of this DAK will introduce personas for the clinician handling triage and treatment decisions, the outreach worker conducting active recruitment to screening (where PHA policy directs active outreach — see the discussion of priority semantics in [adapting.md](adapting.html)), the woman herself in self-collection or self-monitoring workflows, and the supervisor or program manager consuming population-level coverage and outcome indicators. A full Table 3 / Table 4 elaboration consistent with WHO SMART DAK Component 3 conventions will accompany those later additions.
