# Artifacts Summary - Cervical Cancer Screening CDS for OpenMRS v0.1.0

* [**Table of Contents**](toc.md)
* **Artifacts Summary**

## Artifacts Summary

This page provides a list of the FHIR artifacts defined as part of this implementation guide.

### Knowledge Artifacts: Plan Definitions 

These define workflows, rules, strategies, or protocols as part of content in this implementation guide.

| | |
| :--- | :--- |
| [Cervical Cancer Follow-Up — Post-Treatment and Post-Triage Scheduling](PlanDefinition-CervicalCancerFollowUp.md) | Clinical decision support rule for follow-up scheduling after cervical cancer treatment or triage-negative result. Manages post-treatment HPV DNA retest timing (12 months for both populations), post-triage-negative retest timing (12 months WLHIV, 24 months general), WLHIV double follow-up tracking (two consecutive negative HPV retests), return-to-routine-screening criteria, and re-entry to triage/treatment when follow-up HPV retest is positive. |
| [Cervical Cancer Screening Eligibility and Cascade Routing](PlanDefinition-CervicalCancerScreening.md) | Clinical decision support rule for cervical cancer screening eligibility, scheduling, and cascade routing. Implements WHO Algorithm 5 (HPV DNA + VIA triage) screening entry point for both general population and women living with HIV (WLHIV). Evaluates patient demographics, HIV status, and screening history to determine eligibility, due status, and the patient's current position in the screening cascade. |
| [Cervical Cancer Treatment — Ablation Eligibility and Modality Selection](PlanDefinition-CervicalCancerTreatment.md) | Clinical decision support rule for treatment of cervical pre-cancer lesions. Implements WHO ablation eligibility criteria and treatment modality selection. Presents the clinician with a point-of-care ablation eligibility checklist (transformation zone type, lesion extent, suspicion of cancer) and recommends thermal ablation, cryotherapy, or excision (LEEP/LLETZ) based on eligibility and available data. |
| [Cervical Cancer Triage — HPV-Positive VIA Assessment](PlanDefinition-CervicalCancerTriage.md) | Clinical decision support rule for triage of HPV-positive women using VIA (visual inspection with acetic acid). Implements WHO Algorithm 5 triage pathway: HPV+ -> VIA triage -> route to treatment (VIA+), follow-up retest (VIA-), or oncology referral (suspicious for cancer). Applies to both general population and WLHIV with population-specific follow-up intervals. |

### Knowledge Artifacts: Libraries 

These define logic, asset collections and other libraries as part of content in this implementation guide.

| |
| :--- |
| [Cervical Cancer Follow-Up Decision Logic](Library-CervicalCancerFollowUpDecision.md) |
| [Cervical Cancer Screening Common Definitions](Library-CervicalCancerScreeningCommon.md) |
| [Cervical Cancer Screening Decision Logic](Library-CervicalCancerScreeningDecision.md) |
| [Cervical Cancer Treatment Decision Logic](Library-CervicalCancerTreatmentDecision.md) |
| [Cervical Cancer Triage Decision Logic](Library-CervicalCancerTriageDecision.md) |

