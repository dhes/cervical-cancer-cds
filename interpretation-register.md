# Interpretation Register - Cervical Cancer Screening CDS for OpenMRS v0.1.0

* [**Table of Contents**](toc.md)
* **Interpretation Register**

## Interpretation Register

### Interpretation Register

This register documents every interpretive decision where the purposive L2 artifact (reflecting the CQL implementation) diverges from the textualist L2 artifact (reflecting the WHO guideline language). Each entry is categorized and traceable to the source CQL definition and WHO recommendation.

#### Categories

* **Specification**: The WHO guideline gives a range, general instruction, or boundary language. The CQL resolves it to a specific computable value.
* **Disambiguation**: The WHO guideline uses a term that could be interpreted multiple ways. The CQL selects one interpretation.
* **Inference**: The CQL adds logic not explicitly stated in the WHO guideline, derived from clinical reasoning or implementation necessity.
* **Correction/Workaround**: The CQL acknowledges the guideline's intent but works around a data model or terminology limitation.

-------

#### Screening Decision

| | | | | | | |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | Interval: "every 5 to 10 years" (text) | Interval: 5 years (number, lower bound) | Specification | `Common."Screening Interval Years"` | Rec 8 | CQL resolves the range to its lower bound for "due" calculation. Comment: "most conservative." Ensures no patient waits longer than the minimum recommended interval. |
| 2 | Input:`Client Is Woman`(boolean) | Input:`IsFemale`(`Patient.gender = 'female'`) | Disambiguation | `Common."Is Female"` | §3.1 p.21 | WHO uses "women." CQL maps this to administrative gender in the EHR. Clinical intent is "has cervix" — transgender men and non-binary people with cervixes may be excluded. |
| 3 | WLHIV interval: "every 3 to 5 years" (text) | Interval: 3 years (number, lower bound) | Specification | `Common."Screening Interval Years"` | Rec 28 | Same rationale as #1. Lower bound selected for conservative scheduling. |
| 4 | Age range: [30..49] | Age range: [30..49] | — | `"Is Within Screening Age Range"`:`< 50`(i.e., ≤49) | Rec 6/7/26/27 | Both artifacts agree: 49 is the last eligible year. WHO Rec 7 says "aged 30–49 years." CQL corrected in v0.2.0 (was`<= 50`, now`< 50`with`Maximum Screening Age`= 49). |
| 5 | WLHIV age range: [25..49] | WLHIV age range: [25..49] | — | `Common."Minimum Screening Age"`= 25 | Rec 25/27 | Same as #4. Both artifacts agree. |
| 6 | No cancer exclusion input | Adds`HasCervicalCancer`input — excludes from screening | Inference | `"Is Eligible For Screening"`:`not Common."Has Cervical Cancer Diagnosis"` | Not in Algorithm 5 diagram | CQL infers that patients with diagnosed cervical cancer should be managed through oncology, not the screening pathway. Clinically obvious but not stated in the algorithm diagram. |
| 7 | No HIV status determination mechanism specified | HIV status = active Condition with CIEL code 138405 | Specification | `Common."Is WLHIV"`:`exists("Active HIV Conditions")` | Recs 21–34 | WHO assumes WLHIV status is known. CQL specifies the EHR query: active Condition with HIV diagnosis code. Does not capture undiagnosed HIV. |

#### Due for Screening

| | | | | | | |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 8 | Screening window: 5–10 years (3 states: not yet due, within window, past window) | Single threshold: due when years since last test >= interval (2 states: due, not yet due) | Specification | `"Screening Interval Has Elapsed"`:`>= Common."Screening Interval Years"` | Rec 8/28 | Textualist preserves the WHO range as a window. CQL collapses it to a single threshold at the lower bound. There is no "past window" concept — a patient at 11 years is simply "due," same as at 5 years. |
| 9 | Threshold operator: ambiguous ("every 5 to 10 years") | Threshold operator: >= (inclusive) | Specification | `"Screening Interval Has Elapsed"` | Rec 8 | A patient screened exactly 5 years ago today is due. Alternative: due only after 5 full years (>). CQL chooses inclusive. |
| 10 | Input:`YearsSinceLastScreen`(null if never screened) | Separate inputs:`HasEverBeenScreened`(boolean) +`YearsSinceLastHPVTest`(number) | Specification | `"Has Never Been Screened"`,`"Years Since Last HPV Test"` | — | CQL separates "never screened" from "screened N years ago" into distinct boolean + numeric inputs rather than using null to encode "never screened." |

#### Triage Decision

| | | | | | | |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 11 | VIA result: 3 values (positive, negative, suspected cancer) | VIA positive = coded value CIEL 703; negative = not 703 (binary) | Disambiguation | `Common."Most Recent VIA Is Positive"`:`.code contains '703'` | Algorithm 5 | WHO shows 3 VIA outcomes. CQL implements a binary check: code 703 = positive, anything else = negative. No code for "indeterminate." |
| 12 | "Suspected cancer" is a VIA finding | "Suspicious for cancer" = cervical cancer diagnosis (proxy) | Correction | `"Suspicious For Cancer"`:`Common."Has Cervical Cancer Diagnosis"` | Algorithm 5 | The proper CIEL concept for "suspicious for cancer" VIA finding is not loaded in OpenMRS. CQL uses an active cervical cancer Condition as a proxy. Acknowledged as temporary workaround. |
| 13 | No temporal sequencing requirement | VIA must occur on or after HPV test date | Inference | `"Triage Has Been Performed"`:`Date Of Most Recent VIA on or after Date Of Most Recent HPV Test` | Algorithm 5 | WHO diagram shows HPV+ → VIA as a sequence but does not explicitly require temporal ordering in data. CQL enforces it: a VIA done before the HPV test does not count as triage for this episode. |
| 14 | VIA negative: "repeat HPV test in 2 years" (text) | VIA negative: retest in 24 months (number) | Specification | `Common."Post Triage Negative Retest Months"`= 24 | Rec 11 | Resolved from "2 years" to 24 months. |
| 15 | VIA negative WLHIV: "repeat HPV test in 1 year" (text) | VIA negative WLHIV: retest in 12 months (number) | Specification | `Common."Post Triage Negative Retest Months"`= 12 | Rec 31 | Resolved from "1 year" to 12 months. |
| 16 | No "awaiting triage" state | Adds "awaiting VIA triage" when HPV+ but no VIA yet | Inference | `"Triage Is Indicated"` | Algorithm 5 | WHO diagram assumes instantaneous flow from HPV+ to VIA. CQL models the real-world state where VIA has not yet been performed after a positive HPV result. |
| 17 | Algorithm not specified (implicit Algorithm 5) | Algorithm hardcoded to Algorithm 5 | Specification | `"Active Triage Algorithm"`=`'Algorithm 5'` | — | WHO provides 7 algorithms. CQL hardcodes Algorithm 5 with stubs for future multi-algorithm support. |

#### Ablation Eligibility

| | | | | | | |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 18 | Inputs: Suspicion of Cancer (boolean), TZ Type (string) | Inputs: Has Cervical Cancer (boolean), Has CIN2+ (boolean) | Correction | `"Has Known Contraindication To Ablation"`,`"Has CIN2 Or Higher Diagnosis"` | Algorithm 5 footnotes | Textualist models the full WHO criteria (TZ Type 1/2/3). CQL can only check what is in the EHR — cancer diagnosis and CIN grade. TZ assessment is deferred to a clinician checklist. |
| 19 | Output:`AblationEligible`(boolean) | Output:`ModalityRecommendation`(string checklist) | Correction | `"Ablation Eligibility Checklist"` | Algorithm 5 footnotes | Textualist computes eligibility. CQL correctly recognizes that TZ assessment cannot be automated from EHR data alone and presents a clinician checklist instead. This is a meta-decision about the appropriate role of CDS. |
| 20 | No CIN2+ input | CIN2+ shifts modality preference toward excision | Inference | `"Has CIN2 Or Higher Diagnosis"` | Not in Algorithm 5 | CQL infers that higher-grade lesions may warrant excision even if TZ is ablation-eligible. Clinically reasonable but not explicitly stated in WHO Algorithm 5. |

#### Treatment Decision

| | | | | | | |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 21 | No "already treated" guard | Adds`HasBeenTreated`— prevents re-treatment | Inference | `"Treatment Is Indicated"`:`not Common."Has Been Treated"` | Not in Algorithm 5 | WHO diagram shows a one-directional flow. CQL adds a guard to prevent recommending treatment for patients who have already been treated in this episode. |
| 22 | Treatment modality from ablation eligibility (boolean) | Treatment modality from clinician checklist (string) | Correction | `"Treatment Recommendation"` | Algorithm 5 | Follows from #18–19. Since ablation eligibility is a checklist, treatment modality is also a clinician-guided decision rather than a computed output. |
| 23 | Ablation = cryotherapy or thermal ablation (equal) | Thermal ablation preferred over cryotherapy | Specification | `"Treatment Recommendation"`: "thermal ablation (preferred) or cryotherapy" | Algorithm 5 footnote a | WHO footnote lists both. CQL states preference for thermal ablation (simpler, portable, battery-operated). |

#### Follow-up Decision

| | | | | | | |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 24 | Post-treatment: "follow-up after 1 year" (text) | Post-treatment: retest at 12 months; window < 24 months | Specification | `Common."Post Treatment Retest Months"`= 12,`"Is In Post Treatment Follow Up Window"`:`< 24` | Rec 13/33 | "1 year" resolved to 12 months. Follow-up window extended to 24 months to accommodate both single follow-up (general) and first interval of WLHIV double follow-up. |
| 25 | No "approaching" scheduling concept | Adds 2-month advance scheduling window (10–12 months) | Inference | `"Post Treatment Retest Is Approaching"`:`>= (Retest Months - 2)` | Not in WHO | CQL introduces a scheduling convenience: alert clinicians 2 months before the retest is due. Operationally useful but not WHO guidance. |
| 26 | No WLHIV double follow-up | WLHIV: two consecutive negative HPV tests at 12-month intervals | Specification | `"Requires Double Follow Up"`,`"WLHIV Needs Second Follow Up Test"`,`"WLHIV Double Follow Up Complete"` | Rec 33 | Textualist Follow-up Decision does not distinguish WLHIV double follow-up (it outputs generic "post-treatment follow-up after 1 year"). Purposive fully models the two-test requirement. |
| 27 | No test counting logic | Counts post-treatment HPV tests (= 1, >= 2) | Specification | `"HPV Tests Since Treatment Count"` | Rec 33 | CQL counts tests to determine WLHIV double follow-up progress. Note: counts tests but does not verify 12-month interval timing between tests. |
| 28 | No post-triage-negative "approaching" concept | Adds 2-month advance window for post-triage-negative retest | Inference | `"Post Triage Negative Retest Is Approaching"` | Not in WHO | Same scheduling convenience as #25, applied to the post-triage-negative pathway. |
| 29 | HPV test "after treatment" implicit | HPV test must occur strictly after treatment date | Specification | `"Has HPV Test After Treatment"`:`Date Of Most Recent HPV Test after Date Of Most Recent Treatment` | Rec 13/33 | CQL requires the HPV test date to be strictly after the treatment date. An HPV test on the same day as treatment does not count. |
| 30 | Histology result determines follow-up | No histology input — follow-up based on HPV retest result | Disambiguation | `"Post Treatment Retest Is Negative"`,`"Post Treatment Retest Is Positive"` | Rec 13/33 | Textualist includes histology (CIN3 or less vs cancer) per the Algorithm 5 diagram. CQL implementation does not use histology — follow-up is driven by HPV retest results. The histology pathway (cancer → further management) is handled by the cervical cancer diagnosis exclusion. |
| 31 | Return to routine: after CIN3-or-less histology | Return to routine: post-treatment HPV negative (general) or double follow-up complete (WLHIV) | Specification | `"Can Return To Routine Screening"` | Rec 13/33 | CQL defines return-to-routine based on HPV retest results, not histology. |

#### Known Gaps

| | | | | | |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 32 | General population post-triage-negative retest negative: should return to routine screening, but`"Can Return To Routine Screening"`does not cover this path | Gap | `"Can Return To Routine Screening"` | Rec 11 | Documented; not fixed in this release |
| 33 | "Suspicious for cancer" uses cervical cancer diagnosis as proxy; proper CIEL concept not yet loaded | Correction | `"Suspicious For Cancer"` | Algorithm 5 | Acknowledged in CQL comments; will be updated when concept is available |
| 34 | WLHIV double follow-up counts tests but does not verify 12-month interval timing between the first and second post-treatment tests | Gap | `"HPV Tests Since Treatment Count"` | Rec 33 | Documented; timing between tests not enforced |

-------

**Summary**: 34 entries total — 15 Specifications, 7 Inferences, 5 Disambiguations, 3 Corrections/Workarounds, 2 Gaps, 2 Resolved (artifacts now agree).

