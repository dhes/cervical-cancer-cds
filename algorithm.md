# Clinical Algorithm - Cervical Cancer Screening CDS for OpenMRS v0.1.0

* [**Table of Contents**](toc.md)
* **Clinical Algorithm**

## Clinical Algorithm

### WHO Algorithm 5: HPV DNA + VIA Triage

This IG implements Algorithm 5 from the WHO cervical cancer screening guideline. It applies to both the general population and women living with HIV (WLHIV), with population-specific parameters at each decision point.

### Screening Cascade

```
HPV DNA test (self- or clinician-collected)
+-- HPV negative --> Return to routine screening
+-- HPV positive --> VIA triage
    +-- VIA positive --> Assess ablation eligibility --> Treat
    +-- VIA negative --> Schedule follow-up HPV retest
    +-- Suspicious for cancer --> Refer to oncology

```

### Population Parameters

| | | |
| :--- | :--- | :--- |
| Start screening age | 30 | 25 |
| Stop screening age | 50 (after 2 consecutive negatives) | 50 (after 2 consecutive negatives) |
| Screening interval (HPV DNA) | 5-10 years | 3-5 years |
| Post-triage-negative retest | 24 months | 12 months |
| Post-treatment retest | 12 months | 12 months, then 12 months again |

### CQL Library Mapping

| | | |
| :--- | :--- | :--- |
| Screening eligibility and scheduling | CervicalCancerScreeningDecision | CervicalCancerScreening |
| HPV-positive triage | CervicalCancerTriageDecision | CervicalCancerTriage |
| Treatment modality selection | CervicalCancerTreatmentDecision | CervicalCancerTreatment |
| Follow-up scheduling | CervicalCancerFollowUpDecision | CervicalCancerFollowUp |
| Shared definitions | CervicalCancerScreeningCommon | (included by all) |

### WHO Recommendations Covered

**General population**: Recs 1, 2, 3b, 5, 6, 7, 8, 11, 13, 14

**WLHIV**: Recs 21, 22, 23, 25, 26, 27, 28, 31, 33, 34

### Cascade Statuses

The Screening Decision library assigns each patient a machine-readable `Cascade Status` value indicating their current position:

| | |
| :--- | :--- |
| `not-eligible` | Does not meet age/sex criteria for screening |
| `due-for-screening` | Eligible and screening is currently due |
| `needs-triage` | HPV-positive, awaiting VIA triage |
| `needs-treatment` | HPV+ and VIA+, treatment indicated |
| `triage-negative-follow-up` | HPV+ VIA-, in follow-up retest window |
| `post-treatment-follow-up` | Treated, in post-treatment retest window |
| `routine-recall` | Last HPV negative, next screening not yet due |
| `assess-cessation` | Age 50+ with 2 consecutive negatives |

### WLHIV Double Follow-Up (WHO Rec 33)

Women living with HIV require two consecutive negative HPV retests at 12-month intervals after treatment before returning to routine screening. The Follow-Up Decision library tracks the count of post-treatment HPV tests to manage this requirement.

