# Algorithm 5: Purposive L2 — DMN Viewer

# Algorithm 5: Purposive L2

Rendered from algorithm-5-hpv-via-purposive.dmn

## Decision Requirements Diagram

Information Requirement

Authority Requirement

Association

## Decision Tables

Screening Decision
Hit policy: U (Unique)

| | | | | | | | |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | true | [30,49] | false | false | true | 5 | CQL: Common."Is Female", Common."Minimum Screening Age" = 30, Common."Maximum Screening Age" = 49, Common."Screening Interval Years" = 5. WHO Rec 5/6/7/8. Interval resolved to lower bound (most conservative). |
| 2 | true | [25,49] | true | false | true | 3 | CQL: Common."Minimum Screening Age" = 25 for WLHIV, Common."Screening Interval Years" = 3. WHO Rec 25/26/28. Interval resolved to lower bound. |
| 3 | true | <30 | false | false | false | — | CQL: AgeInYears < 30 for non-WLHIV |
| 4 | true | <25 | true | false | false | — | CQL: AgeInYears < 25 for WLHIV |
| 5 | true | >49 | - | false | false | — | CQL: AgeInYears > Common."Maximum Screening Age" (49). WHO Rec 6/7/26/27. |
| 6 | true | - | - | true | false | — | CQL: Common."Has Cervical Cancer Diagnosis". Not in textualist (which has no cancer input). Purposive adds exclusion. |
| 7 | false | - | - | - | false | — | CQL: Patient.gender = 'female'. Textualist uses "Client Is Woman". See Interpretation Register #2. |
| 8 | — | - | - | - | false | — | Catch-all for null inputs |

Due for Screening
Hit policy: U (Unique)

| | | | | | | |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | true | - | - | false | due for screening | CQL: "Has Never Been Screened" and "Is Eligible For Screening". Same as textualist. |
| 2 | true | not(null) | - | true | due for screening | CQL: "Years Since Last HPV Test" >= Common."Screening Interval Years". Textualist uses a window (5-10 or 3-5); purposive uses single lower-bound threshold. See Interpretation Register #3. |
| 3 | true | not(null) | - | true | not yet due | CQL: not "Screening Interval Has Elapsed". Single threshold: < interval. |
| 4 | false | - | - | - | not eligible | Same as textualist. |

Triage Decision
Hit policy: U (Unique)

| | | | | | | | |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | - | - | - | true | refer to oncology | — | CQL: "Suspicious For Cancer" uses Common."Has Cervical Cancer Diagnosis" as proxy. See Interpretation Register #19. Not in textualist (which uses "suspected cancer" VIA finding). |
| 2 | positive | - | true | false | VIA positive — proceed to treatment | — | CQL: "VIA Triage Is Positive" requires VIA on or after HPV test date. See Interpretation Register #14. |
| 3 | negative | false | true | false | VIA negative — repeat HPV test in 24 months | 24 | CQL: Common."Post Triage Negative Retest Months" = 24 for non-WLHIV. WHO Rec 11. Resolved from "2 years" to 24 months. |
| 4 | negative | true | true | false | VIA negative — repeat HPV test in 12 months | 12 | CQL: Common."Post Triage Negative Retest Months" = 12 for WLHIV. WHO Rec 31. Resolved from "1 year" to 12 months. |
| 5 | - | - | false | false | awaiting VIA triage | — | CQL: "Triage Is Indicated" — HPV+ but no VIA after HPV test. Not in textualist (which assumes VIA has been performed). |
| 6 | — | - | - | - | unknown VIA result | — | Catch-all for null VIA result |

Ablation Eligibility
Hit policy: U (Unique)

| | | | | | |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | true | - | true | excision (LEEP/LLETZ) — ablation contraindicated | CQL: "Has Known Contraindication To Ablation" = Common."Has Cervical Cancer Diagnosis". Only checks cancer; TZ assessment deferred to clinician. See Interpretation Register #24. |
| 2 | false | true | false | consider excision — CIN2+ diagnosed; ablation may be acceptable if TZ fully visible | CQL: "Has CIN2 Or Higher Diagnosis" — CQL infers excision preference for higher-grade lesions. Not in WHO Algorithm 5 diagram. See Interpretation Register #22. |
| 3 | false | false | false | assess TZ at point of care — if TZ Type 1 or 2: ablation; if Type 3: excision | CQL: "Ablation Eligibility Checklist" — presents criteria for point-of-care assessment rather than automating. TZ Type 1/2 eligible, Type 3 not. See Interpretation Register #23. |
| 4 | — | - | false | insufficient data for ablation assessment | Catch-all for null inputs |

Treatment Decision
Hit policy: U (Unique)

| | | | | | |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | - | - | true | already treated — see follow-up | CQL: "Treatment Is Indicated" requires not Common."Has Been Treated". Not in textualist. See Interpretation Register #21. |
| 2 | refer to oncology | - | false | refer to oncology | CQL: cancer exclusion handled by Triage Decision routing to oncology. |
| 3 | VIA positive — proceed to treatment | assess TZ at point of care — if TZ Type 1 or 2: ablation; if Type 3: excision | false | assess TZ — ablation (thermal preferred) or excision per eligibility | CQL: ablation-eligible → "thermal ablation (preferred) or cryotherapy". WHO preference: thermal ablation over cryotherapy. |
| 4 | VIA positive — proceed to treatment | consider excision — CIN2+ diagnosed; ablation may be acceptable if TZ fully visible | false | consider excision (LEEP/LLETZ) — CIN2+ diagnosed | CQL: "Has CIN2 Or Higher Diagnosis" shifts preference toward excision. |
| 5 | VIA positive — proceed to treatment | excision (LEEP/LLETZ) — ablation contraindicated | false | excision (LEEP/LLETZ) | CQL: Known contraindication → excision (LEEP/LLETZ). |
| 6 | VIA negative — repeat HPV test in 24 months | - | false | no treatment — repeat HPV in 24 months | CQL: "Proceed To Follow Up Retest". VIA negative routes to follow-up, not treatment. |
| 7 | VIA negative — repeat HPV test in 12 months | - | false | no treatment — repeat HPV in 12 months | CQL: VIA negative WLHIV path. |
| 8 | awaiting VIA triage | - | false | awaiting VIA triage — no treatment decision | VIA not yet performed — no treatment decision. |
| 9 | — | - | - | unknown triage status | Catch-all |

Follow-up Decision
Hit policy: U (Unique)

| | | | | | | | | | |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | - | - | - | true | - | true | re-enter triage/treatment pathway | retest-positive-reenter | CQL: "Post Treatment Retest Is Positive". WHO Rec 13/33. |
| 2 | - | true | - | true | >=2 | false | return to routine screening every 3-5 years | return-to-routine | CQL: "WLHIV Double Follow Up Complete" — 2+ post-treatment tests, most recent negative. WHO Rec 33. |
| 3 | - | false | - | true | >=1 | false | return to routine screening every 5-10 years | return-to-routine | CQL: "Post Treatment Retest Is Negative" and not "Is WLHIV". WHO Rec 13. |
| 4 | - | true | - | true | 1 | false | WLHIV double follow-up — second HPV retest at 12 months after first | wlhiv-awaiting-second-retest | CQL: "WLHIV Needs Second Follow Up Test" — 1 post-treatment test, negative. WHO Rec 33. Not in textualist. |
| 5 | - | - | >=12 | false | 0 | - | post-treatment HPV retest due (12 months) | post-treatment-retest-due | CQL: "Post Treatment Retest Is Due" — Months Since Treatment >= 12. WHO Rec 13/33. |
| 6 | - | - | [10,12) | false | 0 | - | post-treatment HPV retest approaching | post-treatment-retest-approaching | CQL: "Post Treatment Retest Is Approaching" — 10-12 months. 2-month advance window is CQL addition. See Interpretation Register #26. |
| 7 | - | - | [0,10) | false | 0 | - | post-treatment — HPV retest at 12 months | post-treatment-waiting | CQL: "Is In Post Treatment Follow Up Window" and not "Has HPV Test After Treatment". |
| 8 | no treatment — repeat HPV in 24 months | false | - | - | - | - | repeat HPV test after 24 months | post-triage-negative-waiting | CQL: "Is Post Triage Negative". WHO Rec 11. |
| 9 | no treatment — repeat HPV in 12 months | true | - | - | - | - | repeat HPV test after 12 months | post-triage-negative-waiting | CQL: "Is Post Triage Negative" WLHIV. WHO Rec 31. |
| 10 | refer to oncology | - | - | - | - | - | oncology management | refer-oncology | CQL: Cervical cancer diagnosis → oncology management. |
| 11 | — | - | - | - | - | - | no follow-up action indicated | no-follow-up | Catch-all |

