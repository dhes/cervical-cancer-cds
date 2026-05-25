<div>
<p><strong>UNOFFICIAL — NOT WHO-ENDORSED.</strong> This Digital Adaptation Kit is early, in-progress work authored independently by Hopena Health. It is structured using the WHO <code>smart-dak-empty</code> template (CC BY 4.0) but is <strong>not</strong> a WHO publication, not endorsed by WHO, and not part of the official WHO SMART Guidelines program. Shared publicly so the WHO SMART community of practice — in which the author participates — can shape its direction through feedback.</p>
</div>{:.stu-note}

This page presents the decision-support logic for v1 of this DAK, scoped to two decisions at the cervical cancer screening cascade entry point:

1. **Eligibility** — is this woman eligible for cervical cancer screening per the v1 rules?
2. **Needs Screening** — for eligible women, is she currently due for a screening event?

The decisions are derived from the WHO L1 narrative guideline (2021 second edition) for Algorithm 5 (HPV DNA primary screening), narrowed by the v1 PHA-policy commitments documented in [adapting.html](adapting.html). The data elements referenced by these tables are defined in [dictionary.html](dictionary.html).

The tables use Markdown rather than the WHO-standard `.xlsx` decision-logic format. v1 does not include `.xlsx` exports; later cycles may add them.

### Notes on table format

- **First-hit semantics.** Within each table, rules are evaluated top-to-bottom; the first rule whose condition matches determines the output. This is equivalent to the "first hit" hit-policy in DMN.
- **WHO L1 source column.** Each rule cites the WHO recommendation number(s) that motivate it, for traceability between L1 narrative and L2 logic.
- **MoH-configurable? column.** Each rule indicates whether any of its parameters are intended to be configurable by the local Public Health Authority (PHA). v1 hard-codes WHO defaults but flags the configurable seams.
- **Preconditions.** The Needs Screening table assumes Eligibility has returned *eligible* for the same encounter. If Eligibility returns *ineligible*, Needs Screening is not evaluated.

### Decision 1: Eligibility (`CCS.A.DT1`)

For a woman presenting at the screening encounter, determine whether she is eligible for cervical cancer screening under v1 rules.

**Inputs**
- `CCS.A.DE1` Sex at birth
- `CCS.A.DE2` Age in completed years (at the time of the encounter)
- `CCS.A.DE3` HIV status (positive / negative / unknown)
- `CCS.A.DE4` Active cervical cancer diagnosis (present / absent)

**Outputs**
- `CCS.A.DE8` Eligibility: *eligible* or *ineligible*
- `CCS.A.DE9` Eligibility reason: coded value (*none* if eligible; otherwise indicating which rule fired)

| # | Condition (first match wins) | Output | Reason | WHO L1 source | MoH-configurable? |
|---|---|---|---|---|---|
| 1 | Sex at birth ≠ female | ineligible | not at biological risk for cervical cancer | implicit in all WHO recs (the population of "women") | No (clinical basis) |
| 2 | Active cervical cancer diagnosis present | ineligible | active cancer diagnosis; oncology surveillance pathway applies (out of scope of this DAK) | v1 scope decision (implicit in WHO L1) | Yes (definition of "active" cancer is configurable; v1 default = any non-resolved cervical cancer Condition) |
| 3 | HIV status = positive AND age < 25 | ineligible | under the WHO recommendation 25 lower age bound for women living with HIV | WHO 25 | Yes (lower age bound; v1 default = 25) |
| 4 | HIV status ≠ positive AND age < 30 | ineligible | under the WHO recommendation 5 lower age bound for the general population | WHO 5 | Yes (lower age bound; v1 default = 30) |
| 5 | (else) | eligible | meets age criterion for applicable population | WHO 5 and 25 (satisfied) | — |

**Notes on Eligibility rules:**

- **No upper age bound in Eligibility.** WHO L1 does not establish an upper age at which a woman becomes ineligible. The upper age bounds (priority age 49; tier-2 ceiling 65; the 50+ stop rule) are encoded in the Needs Screening decision, not in Eligibility.
- **Sex at birth, not administrative gender.** Rule 1 references *sex at birth* (the biological-anatomic basis for cervical cancer risk). FHIR's `Patient.gender` is administrative gender and may diverge from sex at birth; the data dictionary specifies which underlying data element supplies sex at birth (see [dictionary.html](dictionary.html)).
- **HIV status unknown is treated as not-positive.** Rules 3 and 4 partition on `HIV status = positive` vs `≠ positive`; unknown HIV status falls into the latter, consistent with the WHO 2026 doc framing of the "general population" as "presumed or confirmed to be HIV-negative."

### Decision 2: Needs Screening (`CCS.A.DT2`)

For an eligible woman, determine whether she is currently due for a cervical cancer screening event per the v1 rules.

**Preconditions**
- `CCS.A.DT1` (Eligibility) returns *eligible* for the same encounter

**Inputs**
- `CCS.A.DE2` Age in completed years
- `CCS.A.DE3` HIV status (positive / negative-or-unknown)
- `CCS.A.DE5` Prior cervical cancer screening events (collection of {date, result})
- `CCS.A.DE6` Ever screened (calculated boolean)
- `CCS.A.DE7` Most recent screening date (calculated, if any prior screen exists)
- Internal calculations (not dictionary-eligible per WHO HIV DAK guidance): time since most recent screening; whether the two most recent results were both negative; applicable population pathway (general / WLHIV)

**Outputs**
- `CCS.A.DE10` Needs Screening: *yes* or *no*
- `CCS.A.DE11` Needs Screening reason: coded value indicating which rule fired

| # | Condition (first match wins) | Output | Reason | WHO L1 source | MoH-configurable? |
|---|---|---|---|---|---|
| 1 | Never screened AND age ≤ 49 | yes | tier-1 priority — never screened, within priority age range | WHO 7 (general) / 27 (WLHIV) tier 1 | Yes (priority upper age; v1 default = 49) |
| 2 | Never screened AND age 50–65 | yes | tier-2 priority — 50–65 never screened, included under v1 PHA policy (Option II) | WHO 7 / 27 tier 2; PHA policy Option II | **Yes** — *this is the central PHA-policy seam.* Under Option I, this rule changes to *no, out-of-program-scope per resource constraints*. See [adapting.html](adapting.html). |
| 3 | Never screened AND age > 65 | no | over 65 never screened — WHO L1 is silent on this cohort; v1 default = not in scope | (silence in WHO L1) | Yes (default behavior for > 65; PHAs choosing to extend coverage should add a rule) |
| 4 | Age ≥ 50 AND two most recent screening results both negative | no | WHO 6 / 26 stop rule — after age 50 with two consecutive negatives, screening is stopped | WHO 6 (general) / 26 (WLHIV) | Yes (definition of "consecutive at recommended interval"; v1 default = any two most recent screens) |
| 5 | HIV status = positive AND time since most recent screening ≥ 3 years | yes | due per the 3–5 year interval for women living with HIV | WHO 28 | Yes (interval threshold; v1 default = 3 years, the lower bound of the 3–5 year range) |
| 6 | HIV status ≠ positive AND time since most recent screening ≥ 5 years | yes | due per the 5–10 year interval for the general population | WHO 8 | Yes (interval threshold; v1 default = 5 years, the lower bound of the 5–10 year range) |
| 7 | (else) | no | within the recommended interval; not yet due | WHO 8 / 28 | — |

**Notes on Needs Screening rules:**

- **Interval thresholds default to the *lower* bound** of WHO's recommended ranges (5 years for general population, 3 years for WLHIV). This is the most conservative choice within the WHO envelope — it means women become due at the earliest acceptable point rather than the latest. PHAs operating under different resource postures may configure the threshold to the upper bound (10 / 5) or a midpoint; this changes only the threshold constant in rules 5 and 6, not the rule structure.
- **Rule 4 simplifies WHO 6 / 26 slightly.** The L1 text says "after age 50, screening stopped after two consecutive negative screening results consistent with the recommended regular screening intervals." v1 treats "any two most recent negative results" as sufficient, regardless of the inter-screening interval. A stricter interpretation — requiring the two negatives to be at the recommended interval — can be added in a later cycle.
- **Rule 2 is the central PHA-policy seam.** Switching from Option II (tier 2 included) to Option I (tier 2 not included) requires changing only this rule's output from *yes* to *no* with a reason of "out-of-program-scope per resource constraints." All other rules are unchanged. See [adapting.html](adapting.html) for the policy rationale.
- **The "WHO L1 silence on > 65" framing in rule 3** is discussed in [adapting.html](adapting.html). v1 defaults to *no* for > 65 never-screened women; this is one of two defensible defaults (the other being *yes*, extending tier-2 logic past its stated upper bound).
