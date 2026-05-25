<div>
<p><strong>UNOFFICIAL — NOT WHO-ENDORSED.</strong> This Digital Adaptation Kit is early, in-progress work authored independently by Hopena Health. It is structured using the WHO <code>smart-dak-empty</code> template (CC BY 4.0) but is <strong>not</strong> a WHO publication, not endorsed by WHO, and not part of the official WHO SMART Guidelines program. Shared publicly so the WHO SMART community of practice — in which the author participates — can shape its direction through feedback.</p>
</div>{:.stu-note}

User scenarios depict typical interactions between the targeted persona (see [personas.html](personas.html)) and the women being served. v1 of this DAK includes three scenarios that exercise the boundaries of the two v1 decisions — **Eligibility** (`CCS.A.DT1`) and **Needs Screening** (`CCS.A.DT2`) — for WHO Algorithm 5 (HPV DNA primary screening). Each scenario follows the v1 business process documented in [business-processes.html](business-processes.html), executing some subset of activities `CCS.A1` through `CCS.A9` depending on outcome. Additional scenarios for triage, treatment, follow-up, and edge cases (symptomatic women, women with active cervical cancer diagnosis) will be added in later cycles.

The scenarios assume the v1 program context described in [personas.html](personas.html) and the program-policy choices documented in [adapting.html](adapting.html). The PHA-policy position for v1 includes the WHO recommendation 7 / 27 tier-2 priority cohort (women aged 50–65 who have never been screened) as eligible.

### Scenario A — Routine return for screening, in the priority age range

A 35-year-old woman in the general population presents at a community outreach session. Her record shows a single prior cervical cancer screening approximately 7 years ago that returned negative. She has no recorded prior cervical cancer diagnosis and is asymptomatic. Her HIV status is recorded as negative.

The Community Health Worker opens her record on the OHS / OpenSRP application. The DAK evaluates:

- **Eligibility** (`CCS.A.DT1`): Eligible. Sex at birth is female; age (35) meets the WHO recommendation 5 lower bound (≥ 30 for the general population); no active cervical cancer diagnosis.
- **Needs Screening** (`CCS.A.DT2`): Yes. Last screen was approximately 7 years ago — within the 5–10 year interval per WHO recommendation 8 for the general population. She is due for re-screening.

The CHW initiates the screening encounter.

### Scenario B — 50–65 never-screened, prioritized under v1 PHA policy

A 55-year-old woman in the general population presents at the clinic for an unrelated visit (e.g., follow-up for a chronic non-communicable condition). Her record shows no prior cervical cancer screening. She has no recorded prior cervical cancer diagnosis and is asymptomatic. Her HIV status is recorded as negative.

The facility nurse opens her record. The DAK evaluates:

- **Eligibility** (`CCS.A.DT1`): Eligible. Sex at birth is female; age (55) meets the WHO recommendation 5 lower bound; the Eligibility decision applies no upper age cap. No active cervical cancer diagnosis.
- **Needs Screening** (`CCS.A.DT2`): Yes. She meets the WHO recommendation 7 tier-2 priority criterion — aged 50–65, never screened — and v1's PHA policy (see [adapting.html](adapting.html)) elects to include this cohort.

The nurse counsels her about cervical cancer screening and offers the screening encounter.

### Scenario C — Women living with HIV pathway

A 27-year-old woman living with HIV (HIV-positive status recorded in her record) presents for an HIV follow-up visit. Her record shows no prior cervical cancer screening. She has no recorded prior cervical cancer diagnosis and is asymptomatic.

The CHW or facility nurse opens her record. The DAK evaluates:

- **Eligibility** (`CCS.A.DT1`): Eligible. Sex at birth is female; age (27) meets the WHO recommendation 25 lower bound for women living with HIV (≥ 25); no active cervical cancer diagnosis.
- **Needs Screening** (`CCS.A.DT2`): Yes. She has never been screened. The applicable screening interval for women living with HIV is 3–5 years per WHO recommendation 28, but interval logic is not the determining factor here.

The screening encounter is initiated. The system flags her record with the WLHIV screening interval for future interactions.

### Out-of-v1-scope cases (illustrative; not handled by v1 decision logic)

The following situations are real and clinically relevant but fall outside v1:

- **Women under the lower age bound** (under 30 in the general population, under 25 for women living with HIV): the Eligibility decision returns *ineligible* by age. The L4 application should communicate this clearly per PHA policy guidance rather than silently dismiss the encounter.
- **Women with active cervical cancer diagnosis**: the Eligibility decision returns *ineligible* by the active-cancer exclusion. These women belong in oncology surveillance pathways outside this DAK.
- **Symptomatic women** (abnormal bleeding, post-coital bleeding, persistent pelvic pain): these belong in a diagnostic pathway, not in screening. v1 assumes the women being evaluated are asymptomatic for cervical pathology.
- **Triage of HPV-positive women, treatment decisions, and follow-up scheduling**: out of v1 scope; addressed in later DAK cycles.

These cases will be elaborated in scenarios for the relevant later cycles.
