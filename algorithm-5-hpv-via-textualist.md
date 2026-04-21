# Algorithm 5: Textualist L2 — DMN Viewer

# Algorithm 5: Textualist L2

Rendered from algorithm-5-hpv-via-textualist.dmn

## Decision Requirements Diagram

Information Requirement

Authority Requirement

Association

## Decision Tables

Eligible For Screening
Hit policy: U (Unique)

| | | | | | | |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | true | [30,49] | false | true | every 5 to 10 years | Rec 1; GPS 7 prioritizes age 30–49 |
| 2 | true | <30 | false | false | — | Below general population screening age |
| 3 | true | >49 | - | false | — | Above screening age range (both populations) |
| 4 | true | [25,49] | true | true | every 3 to 5 years | Rec 21; WLHIV screening starts at age 25 |
| 5 | true | <25 | true | false | — | Below WLHIV screening age |
| 6 | false | - | - | false | — | Per L1 terminology; see Interpretation Register |
| 7 | true | — | - | false | — | Catch-all: woman with null age |
| 8 | true | not(null) | — | false | — | Catch-all: woman with valid age but null HIV status |
| 9 | — | - | - | false | — | Catch-all: null Client Is Woman |

Due for Screening
Hit policy: U (Unique)

| | | | | | |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | true | - | — | - | never screened — screen now |
| 2 | true | every 5 to 10 years | <5 | negative | not yet due |
| 3 | true | every 5 to 10 years | [5,10] | negative | within screening window |
| 4 | true | every 5 to 10 years | >10 | negative | past screening window |
| 5 | true | every 3 to 5 years | <3 | negative | not yet due |
| 6 | true | every 3 to 5 years | [3,5] | negative | within screening window |
| 7 | true | every 3 to 5 years | >5 | negative | past screening window |
| 8 | true | - | - | positive | prior positive — enter triage pathway |
| 9 | false | - | - | - | not eligible |

Triage Decision
Hit policy: U (Unique)

| | | | | |
| :--- | :--- | :--- | :--- | :--- |
| 1 | positive | - | VIA positive — eligible for treatment | VIA positive — proceed to treatment eligibility assessment |
| 2 | negative | false | VIA negative — repeat HPV test in 2 years | VIA negative, general population — repeat HPV in 2 years |
| 3 | negative | true | VIA negative — repeat HPV test in 1 year | VIA negative, WLHIV — repeat HPV in 1 year |
| 4 | suspected cancer | - | suspected cancer — refer for evaluation and biopsy | Suspected cancer — refer for evaluation and biopsy |
| 5 | — | - | unknown VIA result | Catch-all: unrecognized VIA result |

Ablation Eligibility
Hit policy: U (Unique)

| | | | | |
| :--- | :--- | :--- | :--- | :--- |
| 1 | true | - | false | Suspected cancer — not eligible for ablation |
| 2 | false | Type 1 | true | TZ Type 1 — eligible for ablation |
| 3 | false | Type 2 | true | TZ Type 2 — eligible for ablation |
| 4 | false | Type 3 | false | TZ Type 3 — not eligible for ablation, requires excision |
| 5 | — | - | false | Catch-all: null suspicion of cancer |
| 6 | false | — | false | Catch-all: null TZ type |

Treatment Decision
Hit policy: U (Unique)

| | | | | |
| :--- | :--- | :--- | :--- | :--- |
| 1 | VIA positive — eligible for treatment | true | ablative treatment | VIA positive, eligible for ablation — ablative treatment |
| 2 | VIA positive — eligible for treatment | false | LLETZ | VIA positive, not eligible for ablation — LLETZ |
| 3 | VIA negative — repeat HPV test in 2 years | - | no treatment — repeat HPV in 2 years | VIA negative, general population — no treatment, repeat HPV |
| 4 | VIA negative — repeat HPV test in 1 year | - | no treatment — repeat HPV in 1 year | VIA negative, WLHIV — no treatment, repeat HPV |
| 5 | suspected cancer — refer for evaluation and biopsy | - | refer for evaluation, biopsy and further management | Suspected cancer — refer for evaluation |
| 6 | — | - | unknown triage status | Catch-all: unrecognized triage status |

Follow-up Decision
Hit policy: U (Unique)

| | | | | |
| :--- | :--- | :--- | :--- | :--- |
| 1 | ablative treatment | CIN3 or less | post-treatment follow-up after 1 year | Ablative treatment, histology CIN3 or less — follow-up after 1 year |
| 2 | ablative treatment | cancer | cancer — further management | Ablative treatment, histology shows cancer |
| 3 | LLETZ | CIN3 or less | post-treatment follow-up after 1 year | LLETZ, histology CIN3 or less — follow-up after 1 year |
| 4 | LLETZ | cancer | cancer — further management | LLETZ, histology shows cancer |
| 5 | no treatment — repeat HPV in 2 years | - | repeat HPV test after 2 years | No treatment, repeat HPV in 2 years (general population) |
| 6 | no treatment — repeat HPV in 1 year | - | repeat HPV test after 1 year | No treatment, repeat HPV in 1 year (WLHIV) |
| 7 | refer for evaluation, biopsy and further management | - | evaluation, biopsy and further management | Referred for evaluation — follow management pathway |
| 8 | — | - | unknown treatment plan | Catch-all: unrecognized treatment plan |

