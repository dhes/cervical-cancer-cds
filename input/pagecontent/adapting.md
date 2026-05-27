<div>
<p><strong>UNOFFICIAL — NOT WHO-ENDORSED.</strong> This Digital Adaptation Kit is early, in-progress work authored independently by Hopena Health. It is structured using the WHO <code>smart-dak-empty</code> template (CC BY 4.0) but is <strong>not</strong> a WHO publication, not endorsed by WHO, and not part of the official WHO SMART Guidelines program. Shared publicly so the WHO SMART community of practice — in which the author participates — can shape its direction through feedback.</p>
</div>{:.stu-note}

This page documents the adaptation choices baked into v1 of this DAK and provides guidance for deployments that wish to adapt the DAK for a different program context.

The WHO SMART Guidelines approach distinguishes between *generic, software-agnostic content requirements* (the DAK proper) and the *local adaptation* needed to deploy in a specific country or program context. Adaptation occurs along several dimensions — Public Health Authority (PHA) policy choices, terminology bindings, workflow particulars, and resource availability — each of which is addressed below.

### PHA-policy commitment in v1: priority cohort selection

WHO recommendations 7 and 27 establish a hierarchical priority structure for cervical cancer screening:

- **Tier 1 (priority age range):** Women aged 30–49 (general population) or 25–49 (women living with HIV).
- **Tier 2 (50–65 never screened, contingent on tools):** "When tools are available to manage women aged 50–65 years, those in that age bracket who have never been screened should also be prioritized."

The "when tools are available" condition is a programmatic decision that the Public Health Authority owns. v1 of this DAK encodes a specific PHA-policy commitment for this decision.

#### v1 PHA-policy position: **Option II** (tier-2 included)

> v1 implements both tier-1 and tier-2 prioritization. Women aged 50–65 who have never been screened are eligible and prioritized into the Needs Screening decision. This reflects a resource-adequate program posture.

**Rationale.** Implementing tier 2 honors the most-underserved cohort identified by WHO 7 / 27 (older never-screened women, whose cervical cancer mortality risk is disproportionately high) and demonstrates the full L1 priority structure faithfully. Excluding tier 2 — "Option I" below — is also defensible for genuinely resource-constrained programs; the DAK should reflect a deliberate PHA stance rather than ambiguity.

#### Alternative PHA-policy position: **Option I** (tier-2 not included)

Deployments operating under a resource-stretched program posture — where program capacity is fully committed to the tier-1 cohort and adding tier-2 outreach is not feasible — should adopt Option I:

> Women aged 50–65 who have never been screened are *not* separately prioritized in this deployment. Existing screening history rules (WHO 6 / 26 stop rule, WHO 8 / 28 interval) still apply to women already in the screening cascade.

**To adopt Option I in your deployment**, modify the Needs Screening decision table (see [decision-logic.html](decision-logic.html)): the rule for "never screened AND age 50–65 → yes" should be changed to "never screened AND age 50–65 → no (out of program scope per resource constraints)". The L4 application should communicate this clearly to the persona per PHA-policy guidance; the woman should not be silently dismissed.

#### Open under both options: women aged > 65

WHO L1 is silent on women aged over 65 (the priority structure caps at age 65; the stop rule at WHO 6 / 26 depends on prior screening history rather than a hard age ceiling). v1 default behavior: women aged > 65 receive *no* from Needs Screening regardless of screening history. PHA's choosing to extend coverage to never-screened women older than 65 should add an explicit rule to the Needs Screening table reflecting their policy.

### Note on the broader expression of "priority"

The DAK encodes per-patient priority *only at the eligibility / decision-logic level*. Other dimensions of priority that a PHA may set — active outreach intensity, scheduling cadence, surveillance frequency, indicator stratification by cohort — are valid DAK concerns that will be addressed in later cycles via the [scheduling-logic.html](scheduling-logic.html), [business-processes.html](business-processes.html) (extended), and [indicators.html](indicators.html) pages. Deployments that need richer priority expression in v1 should treat this DAK as a partial specification and supplement with their own scheduling and workflow tooling.

### Sample collection method

WHO recommendation 4 / 24 acknowledges that HPV DNA testing may be performed on either provider-collected or self-collected samples. v1 is agnostic on this choice — the Needs Screening decision returns *yes* without specifying which collection method should be used. Deployments configure the L4 application's screening workflow to reflect the locally-available collection methods.

### Sex-at-birth source resolution

WHO recommendations refer to "women" — the population for whom the cervical cancer screening cascade applies. The clinically defensible mapping in FHIR is *sex assigned at birth*, not the administrative `Patient.gender` (which in some jurisdictions tracks current gender identity rather than sex at birth, per FHIR R4B §8.1.8).

v1 reads sex at birth from a layered source chain (see [dictionary.html](dictionary.html), entry I-1, for details):

1. **Patient-level sex-at-birth extension** if defined by the deployment's profile (e.g., US Core `us-core-birthsex`). `smart.who.int.base` v0.2.0 does not define such an extension, so this layer is empty for the default WHO-based profile.
2. **FHIR `Observation` with LOINC code 76689-9** ("Sex assigned at birth") if the deployment captures sex at birth as an observation.
3. **`Patient.gender`** as a pragmatic default, valid for deployments where this field is administratively set at registration to reflect sex at birth and is not subsequently updated to reflect gender identity.

**PHA configuration point.** Deployments in jurisdictions where `Patient.gender` is updated to reflect current gender identity (rather than persisting as sex at birth) must disable layer 3 of the chain — using `Patient.gender` would produce incorrect Eligibility results for transitioned women with intact cervix. In such deployments, populating layer 1 (an extension) or layer 2 (a LOINC observation) and removing the layer 3 fallback is the required configuration.

For target OpenSRP / LMIC deployments, layers 1 and 2 are rarely populated in current practice, and `Patient.gender` is the de facto sex-at-birth field. v1's default chain accommodates both contexts.

### Pseudocode conventions

v1 decision tables include a Pseudocode column expressing each rule's condition as a semi-formal logical expression. The intent is to provide a *verification surface* between the L1 narrative guideline (English) and the L3 CQL implementation (executable code) — a clinical reviewer can verify the pseudocode without reading CQL, and a CQL author can translate the pseudocode mechanically rather than re-interpreting the L1 narrative.

The conventions are FEEL-shaped (resembling the OMG DMN Friendly Enough Expression Language) but deliberately informal — they are not parsed by any tool; they are read by humans. Pattern source: WHO IMMZ DAK 2023 (as observed in the smart-immunizations repository); no published WHO style guide exists.

**Adopted conventions:**

- Quoted concept and field names: `"Sex at birth"`, `"HIV status"`, `"Age"`
- Lowercase logical operators: `and`, `or`, `not`
- Unicode comparison operators where they read more cleanly: `≥`, `≤`, `≠`
- Quoted literal values: `"female"`, `"HIV-positive"`, `"negative"`
- Count expressions: `Count of X (where Y) ≥ N`
- Existence checks: `exists X (where Y)`
- Date arithmetic in natural units: `"Time since most recent screening" ≥ 5 years`
- Named state references rather than re-stating conditions: `"Ever screened"`, `"Two most recent screening results both negative"`. These states are defined in [decision-logic.html](decision-logic.html) (Internal calculated states section) or [dictionary.html](dictionary.html) (Calculation column for retained derived elements)

**Deliberate deviations from WHO IMMZ DAK patterns:**

- v1 does not have a separate `CCSDAK` CodeSystem. Internal calculated states are documented inline in `decision-logic.md` rather than in a CodeSystem. v2+ work may promote these to a CodeSystem (with the pseudocode becoming the CodeSystem concept's `definition` field, following IMMZ's pattern).
- Some IMMZ pseudocode idioms are immunization-specific (e.g., "Doses Administered to Patient", "Primary series", "Booster dose") and do not apply to cervical cancer screening's cascade-shaped domain. We use idioms native to the screening workflow (screening events, time since last screening, screening result history).

**Notes for v2+ work:**

- When we build a `CCSDAK` CodeSystem, the internal calculated states should move there. The CodeSystem concept's `definition` field carries the pseudocode (matching IMMZ's pattern).
- Pseudocode conventions may evolve as we encounter cases that need new idioms (e.g., for triage, treatment, or follow-up decisions in later DAK cycles).

### Terminology adaptation

WHO L1 recommendations reference HPV DNA testing, VIA, cytology, cervical pre-cancer (CIN1/2/3), and cervical cancer using clinical concepts. v1 inherits terminology bindings only where they exist in widely-adopted FHIR base profiles and standards (ICD-11, LOINC, SNOMED CT). Programs operating under specific national or regional terminology systems (e.g., CIEL in OpenMRS-derived deployments, or national variants of ICD) will need to map between local codes and the v1-bound codes.

v1 explicitly does *not* assume CIEL bindings (the v1 archive branch reflects an earlier OpenMRS / CIEL-targeted iteration of this work; that branch can be consulted for prior CIEL mappings, but the v1 target is OHS / OpenSRP which uses standard FHIR codings).

A formal ConceptMap resource set covering local-to-WHO-bound terminology mappings is out of v1 scope and will be addressed in later cycles.

### Structural adaptation: smart-dak-empty → this DAK

This DAK was scaffolded from the WHO [`smart-dak-empty`](https://github.com/WorldHealthOrganization/smart-dak-empty) template (CC BY 4.0). The template's structural conventions (page set, folder layout, dependency on `smart.who.int.base`, build tooling) have been preserved. The template's identity defaults (publisher = WHO, canonical under `smart.who.int`, title = "SMART DAK Empty") have been adapted to reflect that this is an unofficial work — publisher is Hopena Health, canonical is under `hopena.info`, title indicates working-draft status. This is the structural-vs-identity separation that allows third-party DAK-style authoring without claiming WHO endorsement. See the IG `sushi-config.yaml` for the specific values.

Downstream adopters of *this* DAK who wish to publish their own adaptation should do the same: keep the structural conventions, change the identity fields to reflect their own publisher and canonical, and add their own disclaimer clarifying the adaptation lineage.

**One further structural divergence from WHO HIV DAK convention.** WHO HIV materials separate the operational (L2) and machine-readable (L3) layers into distinct artifacts: a standalone DAK PDF plus Web Annex spreadsheets for L2, and a separate FHIR Implementation Guide for L3. This work combines L2 and L3 content into a single IG — narrative pages (personas, scenarios, business-processes, dictionary) carry L2 content alongside the L3-targeted decision logic, profiles, and (eventually) CQL libraries. This combination is a tractability choice for methodology demonstration; a fully WHO-aligned production DAK would separate the layers as WHO does.

**Adaptation responsibility framing.** WHO's own `adapting.md` in published DAKs (e.g., HIV) is largely meta-framework: it explains the L1–L4 model and indicates that country implementers do the actual adaptation work. This DAK's `adapting.md`, by contrast, is denser with specific operational adaptation content because *this work is acting as the country/program adaptation* WHO points to — recording the choices a downstream implementer would otherwise have to make. Readers familiar with the WHO HIV DAK `adapting.md` should expect this difference and not interpret it as a deviation. For the WHO SMART Guidelines layer model, see [WHO's SMART Guidelines](https://smart.who.int/) and the [Mehl et al. Lancet Digital Health article (2021)](https://www.thelancet.com/journals/landig/article/PIIS2589-7500(21)00038-8/fulltext).

### Items deferred to later DAK cycles

- BPMN diagrams for the v1 business process and the downstream cascade processes (triage, treatment, follow-up).
- Indicators and population-level performance metrics, including cohort stratification reflecting any PHA-policy priority distinctions.
- Scheduling logic for active outreach to tier-1 women and the cadence of routine recall.
- ConceptMap resource set for local-to-WHO-bound terminology adaptation.
- Detailed adaptation guidance for the WLHIV pathway in settings with high HIV prevalence.
- The 2026 WHO addendum (HPV DNA genotyping with 12 cHPV types stratified into 4 risk groups, 13 algorithms in section 3.5) is not reflected in v1 — v1 follows the 2021 second edition Algorithm 5 pattern. Later cycles will engage with the 2026 expansion.
