<div>
<p><strong>UNOFFICIAL — NOT WHO-ENDORSED.</strong> This Digital Adaptation Kit is early, in-progress work authored independently by Hopena Health. It is structured using the WHO <code>smart-dak-empty</code> template (CC BY 4.0) but is <strong>not</strong> a WHO publication, not endorsed by WHO, and not part of the official WHO SMART Guidelines program. Shared publicly so the WHO SMART community of practice — in which the author participates — can shape its direction through feedback.</p>
</div>{:.stu-note}

A business process is a set of related activities performed together to achieve the objectives of a health programme — registration, eligibility assessment, screening, counselling, referrals, result management, and so on. Workflows are visual or narrative representations of the progression of activities within a business process; they provide a "story" of the process and support communication among users, stakeholders, and engineers.

For v1, this DAK addresses **a single business process: the cervical cancer screening encounter at the point of cascade entry** (see Overview below). The two decisions modelled in v1 — Eligibility and Needs Screening (see [decision-logic.html](decision-logic.html)) — sit early in this workflow. Downstream activities (sample collection, result management, triage, treatment, follow-up) are part of the broader cervical cancer screening cascade but are out of v1 scope; they will be addressed in later cycles.

### Overview of business processes in this DAK

The following table describes the process scope. v1 implements only Process A; processes B–D are forward-referenced and deferred to later DAK cycles.

| # | Process Name | Process ID | Personas | Objectives |
|---|---|---|---|---|
| A | Screening encounter at cascade entry | `CCS.A` | Community Health Worker or Facility Nurse | To determine whether a presenting woman is eligible for cervical cancer screening and, if eligible, whether she is currently due, and to initiate the screening encounter when both apply. |
| B | Triage of HPV-positive women | `CCS.B` | (Deferred to a later cycle) | To determine the appropriate triage pathway for women with positive primary screening, per WHO Algorithm 5 — VIA, partial genotyping, cytology, or colposcopy depending on program capacity. |
| C | Treatment | `CCS.C` | (Deferred to a later cycle) | To determine treatment modality (thermal ablation, large-loop excision) and initiate treatment for eligible women. |
| D | Follow-up | `CCS.D` | (Deferred to a later cycle) | To schedule and conduct post-treatment surveillance and routine recall for screened women. |

### Workflows

A BPMN diagram for `CCS.A` will be authored in a later cycle; the workflow narrative below serves as the v1 workflow representation in the meantime.

### v1 business process: screening encounter at cascade entry

The targeted persona (see [personas.html](personas.html)) encounters a woman either through community outreach or at a facility-based visit. The woman is assumed to be registered in the health record system; v1 does not include registration as a workflow step (see Notes on the workflow boundary, below).

The following workflow narrative describes the v1 process. A BPMN diagram for this process will be authored in a later cycle.

#### Workflow steps

1. **`CCS.A1` Encounter initiation.** The persona meets the woman during community outreach or at a facility encounter. The encounter may be specifically for cervical cancer screening, or may be for an unrelated reason during which screening is opportunistically considered (per Scenario B in [scenarios.html](scenarios.html)).

2. **`CCS.A2` Record retrieval.** The persona opens the woman's record on the OHS / OpenSRP application. The application retrieves demographic information (sex at birth, age), HIV status, prior cervical cancer screening history, and prior cervical cancer diagnoses from the FHIR-based health record.

3. **`CCS.A3` Eligibility evaluation.** The DAK runs the Eligibility decision (`CCS.A.DT1`). The decision returns *eligible* or *ineligible*, with a reason if ineligible.

4. **`CCS.A4` Branch on Eligibility.**
   - *Ineligible*: the persona conveys the result and reason per PHA-policy guidance. The encounter is documented in the woman's record. The screening workflow exits; the persona continues with whatever other activities the visit calls for.
   - *Eligible*: the workflow proceeds to step 5.

5. **`CCS.A5` Needs Screening evaluation.** For eligible women, the DAK runs the Needs Screening decision (`CCS.A.DT2`). The decision returns *yes* (currently due) or *no* (not currently due), with rationale.

6. **`CCS.A6` Branch on Needs Screening.**
   - *No (not currently due)*: the persona conveys the result, advises the woman of her next recommended screening date (per the applicable WHO interval), and documents the encounter. The screening workflow exits.
   - *Yes (currently due)*: the workflow proceeds to step 7.

7. **`CCS.A7` Counselling and consent.** The persona counsels the woman about cervical cancer screening — what the test involves, the cascade that follows a positive result, and the choice of provider-collected or self-collected sample where the program supports both (per WHO recommendation 4 / 24). The woman gives informed consent, defers, or declines.

8. **`CCS.A8` Screening encounter.** If the woman consents, the screening event is initiated. The mechanics of sample collection, sample transport, result reception, and result recording in the FHIR record are part of the broader OHS / OpenSRP-based application workflow but are *not* modelled by v1's decision logic.

9. **`CCS.A9` Encounter documentation.** Whether the screening event occurred, was deferred, was declined, or the woman was found ineligible or not-due, the encounter is documented in the woman's record. This is essential for cascade continuity — subsequent decisions, including future Needs Screening evaluations, read this history.

### Variants by population

The same business process applies to both the general-population pathway and the women living with HIV (WLHIV) pathway. Branching by HIV status occurs *inside* the decision logic — different age thresholds and different screening intervals per WHO recommendations 5 / 25 and 8 / 28 — not at the workflow level. The persona's actions are the same; the system's parameters differ. HIV status is read from the woman's FHIR record as a precondition input to both decisions.

### Variants by PHA policy

v1 implements the Option II PHA policy position (see [adapting.html](adapting.html)): women aged 50–65 who have never been screened are eligible and prioritized into Needs Screening per WHO recommendation 7 / 27 tier 2. From the persona's perspective, the workflow is identical for tier-1 women (priority age range) and tier-2 women (50–65 never screened): the system evaluates and returns *yes*; the persona counsels and initiates the screening encounter.

Deployments that adopt the Option I PHA policy (resource-stretched, tier 2 not included) modify only the Needs Screening decision rule for the 50–65 never-screened case; the workflow itself is unchanged. See [adapting.html](adapting.html) for the details.

### Out-of-v1-scope downstream activities

The following activities follow from the v1 entry-point workflow but are not modelled by v1's decision logic:

- **Sample collection** (provider-collected or self-collected) and sample processing.
- **Result reception and recording** in the FHIR record.
- **Triage decisions** for HPV-positive women (e.g., VIA, HPV partial genotyping, cytology, colposcopy, dual-stain cytology — depending on program capacity).
- **Treatment decisions** (ablation eligibility, ablation modality, excision).
- **Follow-up scheduling** for post-treatment surveillance and routine recall.
- **Cascade continuity tracking** — ensuring women who screen positive complete triage and treatment, including handoffs between roles.

Each of these is a distinct business process that will be addressed in a later DAK cycle.

### Notes on the workflow boundary

**Registration is assumed.** v1 does not include registration as a workflow step. The OHS / OpenSRP-based application typically supports registration as a separate workflow performed either by a different role or by the same persona at a different point. v1 assumes a registered woman with a retrievable FHIR-based health record. Programs in which active outreach reaches unregistered populations should handle registration upstream of this workflow; this is a real operational concern but not part of the v1 DAK rules.

**Symptomatic women are not in scope.** Women presenting with symptoms suggestive of cervical pathology (abnormal bleeding, post-coital bleeding, persistent pelvic pain) should be routed to a diagnostic pathway, not the screening pathway. v1 assumes asymptomatic women. The L4 application should provide clear UX for the persona to route symptomatic women appropriately; that UX is part of the L4 application's responsibilities and outside the DAK's decision logic.

**Outreach intensity, scheduling cadence, surveillance frequency, and indicator stratification are valid DAK concerns but are out of v1 scope.** v1 expresses PHA priority policy at the eligibility / decision-logic level only. Other dimensions of priority — actively recruiting tier-1 women versus passively accepting tier-2 women, for example — would be expressed in scheduling logic, business-process workflows that include outreach steps, and indicator definitions. These will be addressed in later cycles. See [adapting.html](adapting.html) for the placement of PHA-policy commitments within the DAK structure.

**BPMN diagrams deferred.** WHO SMART DAK convention includes BPMN diagrams (and downloadable `.bpmn` source files) for each business process. v1 does not include BPMN diagrams; they will be authored in a later cycle alongside additional business processes (triage, treatment, follow-up).
