# Decision Tables - Cervical Cancer Screening CDS for OpenMRS v0.1.0

* [**Table of Contents**](toc.md)
* **Decision Tables**

## Decision Tables

### Decision Table Comparison

This page presents the textualist and purposive decision tables side by side for each of the six decisions in Algorithm 5. Divergences are noted with references to the [Interpretation Register](interpretation-register.md).

-------

### 1. Screening Decision

Determines whether a patient is eligible for cervical cancer screening and the recommended screening interval.

**Textualist**

| | | | | |
| :--- | :--- | :--- | :--- | :--- |
| true | [30..49] | false | true | "every 5 to 10 years" |
| true | [25..49] | true | true | "every 3 to 5 years" |
| true | <30 | false | false | – |
| true | <25 | true | false | – |
| true | >49 | – | false | – |
| false | – | – | false | – |

**Purposive**

| | | | | | |
| :--- | :--- | :--- | :--- | :--- | :--- |
| true | [30..49] | false | false | true | 5 |
| true | [25..49] | true | false | true | 3 |
| true | <30 | false | false | false | – |
| true | <25 | true | false | false | – |
| true | >49 | – | false | false | – |
| true | – | – | true | false | – |
| false | – | – | – | false | – |

**Key divergences:**

* Interval resolved from text range to numeric lower bound (Register #1, #3)
* `Client Is Woman` vs `Patient.gender = 'female'` (Register #2)
* Cervical cancer exclusion added as input (Register #6)
* HIV status determined from EHR Condition resource (Register #7)

-------

### 2. Due for Screening

Determines whether screening is currently needed based on eligibility and screening history.

**Textualist**

| | | | | |
| :--- | :--- | :--- | :--- | :--- |
| true | – | null | – | never screened – screen now |
| true | "every 5 to 10 years" | <5 | negative | not yet due |
| true | "every 5 to 10 years" | [5..10] | negative | within screening window |
| true | "every 5 to 10 years" | >10 | negative | past screening window |
| true | "every 3 to 5 years" | <3 | negative | not yet due |
| true | "every 3 to 5 years" | [3..5] | negative | within screening window |
| true | "every 3 to 5 years" | >5 | negative | past screening window |
| true | – | – | positive | prior positive – enter triage pathway |
| false | – | – | – | not eligible |

**Purposive**

| | | | | |
| :--- | :--- | :--- | :--- | :--- |
| true | – | – | false | due for screening |
| true | not null | >= interval | true | due for screening |
| true | not null | < interval | true | not yet due |
| false | – | – | – | not eligible |

**Key divergences:**

* Textualist has 3 states (not yet due, within window, past window); purposive has 2 (due, not yet due) (Register #8)
* Single threshold at lower bound vs. screening window range (Register #8, #9)
* Separate `HasEverBeenScreened` input vs. null encoding (Register #10)
* No "prior positive" routing in purposive Due for Screening – handled by Triage Decision instead

-------

### 3. Triage Decision

Routes HPV-positive patients based on VIA triage results.

**Textualist**

| | | |
| :--- | :--- | :--- |
| positive | – | VIA positive – eligible for treatment |
| negative | false | VIA negative – repeat HPV test in 2 years |
| negative | true | VIA negative – repeat HPV test in 1 year |
| suspected cancer | – | suspected cancer – refer for evaluation and biopsy |

**Purposive**

| | | | | | |
| :--- | :--- | :--- | :--- | :--- | :--- |
| – | – | – | true | refer to oncology | – |
| positive | – | true | false | VIA positive – proceed to treatment | – |
| negative | false | true | false | VIA negative – repeat HPV test in 24 months | 24 |
| negative | true | true | false | VIA negative – repeat HPV test in 12 months | 12 |
| – | – | false | false | awaiting VIA triage | – |

**Key divergences:**

* VIA positive = CIEL code 703; binary interpretation (Register #11)
* "Suspected cancer" replaced with cervical cancer diagnosis proxy (Register #12)
* VIA must occur after HPV test (temporal sequencing) (Register #13)
* Follow-up intervals resolved to exact months (Register #14, #15)
* "Awaiting triage" state added for real-world workflow (Register #16)

-------

### 4. Ablation Eligibility

Determines whether ablative treatment is appropriate.

**Textualist**

| | | |
| :--- | :--- | :--- |
| true | – | false |
| false | Type 1 | true |
| false | Type 2 | true |
| false | Type 3 | false |

**Purposive**

| | | | |
| :--- | :--- | :--- | :--- |
| true | – | true | excision – ablation contraindicated |
| false | true | false | consider excision – CIN2+ diagnosed |
| false | false | false | assess TZ at point of care |

**Key divergences:**

* Textualist computes eligibility from TZ type; purposive defers TZ to clinician (Register #18, #19)
* CIN2+ modality preference added (Register #20)
* Output is a recommendation string, not a boolean (Register #19)

-------

### 5. Treatment Decision

Selects treatment modality based on triage and ablation eligibility.

**Textualist**

| | | |
| :--- | :--- | :--- |
| VIA positive | true | ablative treatment |
| VIA positive | false | LLETZ |
| VIA negative (gen) | – | no treatment – repeat HPV in 2 years |
| VIA negative (WLHIV) | – | no treatment – repeat HPV in 1 year |
| suspected cancer | – | refer for evaluation and biopsy |

**Purposive**

| | | | |
| :--- | :--- | :--- | :--- |
| – | – | true | already treated – see follow-up |
| refer to oncology | – | false | refer to oncology |
| VIA positive | assess TZ at point of care | false | assess TZ – ablation or excision |
| VIA positive | consider excision (CIN2+) | false | consider excision (LEEP/LLETZ) |
| VIA positive | ablation contraindicated | false | excision (LEEP/LLETZ) |
| VIA negative (24 months) | – | false | no treatment – repeat HPV in 24 months |
| VIA negative (12 months) | – | false | no treatment – repeat HPV in 12 months |
| awaiting VIA triage | – | false | no treatment decision |

**Key divergences:**

* "Already treated" guard prevents re-treatment (Register #21)
* Treatment modality is clinician-guided, not computed (Register #22)
* Thermal ablation preferred over cryotherapy (Register #23)

-------

### 6. Follow-up Decision

Determines post-treatment and post-triage-negative follow-up scheduling.

**Textualist**

| | | |
| :--- | :--- | :--- |
| ablative treatment | CIN3 or less | post-treatment follow-up after 1 year |
| ablative treatment | cancer | cancer – further management |
| LLETZ | CIN3 or less | post-treatment follow-up after 1 year |
| LLETZ | cancer | cancer – further management |
| no treatment (gen) | – | repeat HPV test after 2 years |
| no treatment (WLHIV) | – | repeat HPV test after 1 year |
| refer for evaluation | – | evaluation, biopsy and further management |

**Purposive**

| | | | | | | | |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| – | – | – | true | – | true | re-enter triage/treatment | retest-positive-reenter |
| – | true | – | true | >=2 | false | return to routine (3-5 years) | return-to-routine |
| – | false | – | true | >=1 | false | return to routine (5-10 years) | return-to-routine |
| – | true | – | true | 1 | false | WLHIV second retest at 12 months | wlhiv-awaiting-second-retest |
| – | – | >=12 | false | 0 | – | post-treatment HPV retest due | post-treatment-retest-due |
| – | – | [10..12) | false | 0 | – | retest approaching | post-treatment-retest-approaching |
| – | – | [0..10) | false | 0 | – | retest at 12 months | post-treatment-waiting |
| no treatment (gen) | false | – | – | – | – | repeat HPV after 24 months | post-triage-negative-waiting |
| no treatment (WLHIV) | true | – | – | – | – | repeat HPV after 12 months | post-triage-negative-waiting |
| refer to oncology | – | – | – | – | – | oncology management | refer-oncology |

**Key divergences:**

* No histology input; follow-up driven by HPV retest results (Register #30)
* WLHIV double follow-up fully modeled (Register #26, #27)
* 2-month "approaching" scheduling window (Register #25, #28)
* Post-treatment HPV test must be strictly after treatment date (Register #29)
* Return-to-routine criteria based on retest results, not histology (Register #31)
* Known gap: general pop post-triage-negative return to routine not covered (Register #32)

