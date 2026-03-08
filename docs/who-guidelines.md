# WHO Cervical Cancer Screening & Treatment Guidelines — CDS Decision Logic Reference

**Source**: WHO guideline for screening and treatment of cervical pre-cancer lesions
for cervical cancer prevention, 2nd edition (2021).
https://www.who.int/publications/i/item/9789240030824

Full text on NCBI Bookshelf: https://www.ncbi.nlm.nih.gov/books/NBK572317/

## Overview

- 23 recommendations total (6 identical for both populations, 12 population-specific)
- 7 good practice statements
- 7 clinical algorithms (Annex 4)
- Two target populations: general population of women, women living with HIV (WLHIV)
- Two approaches: screen-and-treat, screen-triage-treat

## Screening Eligibility & Intervals

### General Population

| Parameter | Value |
|---|---|
| Start screening | Age 30 |
| Stop screening | Age 50, after 2 consecutive negative HPV tests at routine interval |
| Priority age range | 30–49 |
| Preferred primary test | HPV DNA (self- or clinician-collected) |
| Screening interval (HPV DNA) | Every 5–10 years |
| Screening interval (VIA/cytology) | Every 3 years (interim measure if HPV testing unavailable) |
| Approach | Screen-and-treat OR screen-triage-treat (both acceptable) |

### Women Living with HIV (WLHIV)

| Parameter | Value |
|---|---|
| Start screening | Age 25 |
| Stop screening | Age 50, after 2 consecutive negative HPV tests at routine interval |
| Priority age range | 25–49 |
| Preferred primary test | HPV DNA (self- or clinician-collected) |
| Screening interval (HPV DNA) | Every 3–5 years |
| Screening interval (VIA/cytology) | Every 3 years (interim measure) |
| Approach | Screen-triage-treat recommended (screen-and-treat acceptable) |

### Key Differences (WLHIV vs General)

- Earlier start age: 25 vs 30
- Shorter interval: 3–5 years vs 5–10 years
- Triage recommended (not just screen-and-treat)
- Post-triage-negative retest: 12 months (vs 24 months for general)
- Post-treatment: retest at 12 months, then again at 12 months (double follow-up)

## The Seven Clinical Algorithms

### Algorithm 1: Primary VIA — Screen-and-Treat
**Populations**: General + WLHIV
```
VIA performed
├── VIA negative → Return to routine screening
├── VIA positive → Assess ablation eligibility
│   ├── Eligible → Thermal ablation / cryotherapy
│   └── Not eligible → Excision (LEEP/LLETZ)
└── Suspicious for cancer → Refer for diagnosis & management
```

### Algorithm 2: Primary HPV DNA — Screen-and-Treat
**Populations**: General only
```
HPV DNA test (self- or clinician-collected)
├── HPV negative → Return to routine screening
└── HPV positive → VIA assessment for treatment eligibility
    ├── Eligible for ablation → Thermal ablation / cryotherapy
    ├── Not eligible for ablation → Excision (LEEP/LLETZ)
    └── Suspicious for cancer → Refer
```
Note: Even in screen-and-treat, VIA is still done to assess ablation eligibility
(not as a triage test for treatment decision, but for treatment modality selection).

### Algorithm 3: Primary Cytology + Colposcopy Triage — Screen-Triage-Treat
**Populations**: General + WLHIV
```
Cytology
├── Normal / ASCUS / LSIL → Return to routine screening
└── HSIL+ → Colposcopy
    ├── Normal colposcopy → Retest at 12 months
    ├── CIN1+ confirmed → Treat (ablation or excision)
    └── Suspicious for cancer → Refer
```

### Algorithm 4: Primary HPV DNA + HPV16/18 Genotyping Triage
**Populations**: General + WLHIV
```
HPV DNA test
├── HPV negative → Return to routine screening
└── HPV positive → HPV16/18 genotyping
    ├── HPV16/18 positive → Treat (ablation or excision per eligibility)
    └── HPV positive, NOT 16/18 → VIA triage
        ├── VIA positive → Treat
        └── VIA negative → Retest (24 months general, 12 months WLHIV)
```

### Algorithm 5: Primary HPV DNA + VIA Triage
**Populations**: General + WLHIV
```
HPV DNA test
├── HPV negative → Return to routine screening
└── HPV positive → VIA triage
    ├── VIA positive → Treat (ablation or excision per eligibility)
    ├── VIA negative → Retest (24 months general, 12 months WLHIV)
    └── Suspicious for cancer → Refer
```

### Algorithm 6: Primary HPV DNA + Colposcopy Triage
**Populations**: General + WLHIV
```
HPV DNA test
├── HPV negative → Return to routine screening
└── HPV positive → Colposcopy
    ├── Normal → Retest at 12 months
    ├── CIN1+ → Treat (ablation or excision per eligibility)
    └── Suspicious for cancer → Refer
```

### Algorithm 7: Primary HPV DNA + Cytology Triage + Colposcopy
**Populations**: General + WLHIV
```
HPV DNA test
├── HPV negative → Return to routine screening
└── HPV positive → Cytology triage
    ├── Normal / ASCUS / LSIL → Retest (24 months general, 12 months WLHIV)
    └── HSIL+ → Colposcopy
        ├── Normal → Retest at 12 months
        ├── CIN1+ → Treat (ablation or excision per eligibility)
        └── Suspicious for cancer → Refer
```

## Treatment Decision Logic

### Ablation Eligibility Criteria

Before treatment, all HPV-positive women (screened by any method other than VIA)
must undergo VIA assessment to determine transformation zone type and ablation
eligibility.

**Eligible for ablation when ALL of the following are true:**
1. No suspicion of invasive or glandular disease
2. Transformation zone is fully visible:
   - Type 1 TZ: entirely on ectocervix (eligible)
   - Type 2 TZ: partially endocervical but fully visible AND probe tip can
     achieve complete ablation of SCJ epithelium (eligible)
3. Lesion does not extend into endocervical canal beyond probe reach

**NOT eligible for ablation (refer for excision) when ANY of the following:**
1. Suspicion of invasive or glandular disease
2. TZ Type 3 (extends into endocervical canal beyond view)
3. TZ Type 2 where SCJ is out of reach of probe tip

### Treatment Options

| Treatment | Method | Specification |
|---|---|---|
| Thermal ablation | Electrically heated probe (~100°C) | Min 100°C for 20–30 seconds, overlapping fields to cover entire TZ |
| Cryotherapy | CO2 or N2O gas-cooled probe | Freeze-thaw-freeze cycle |
| LEEP / LLETZ | Electrosurgical loop excision | Preferred excisional method |
| Cold knife conization | Surgical excision | When LEEP unavailable |

**WHO preference**: Thermal ablation or cryotherapy for eligible lesions (simpler,
portable, no anesthesia needed). LEEP/LLETZ for ineligible lesions or when
available and accessible.

## Post-Treatment Follow-Up

### General Population
- Retest with HPV DNA at **12 months** post-treatment
- If negative → return to routine screening interval (5–10 years)
- If positive → re-enter triage/treatment pathway

### Women Living with HIV
- Retest with HPV DNA at **12 months** post-treatment
- If negative → retest again at **12 months** (double follow-up)
- If second test negative → return to routine screening interval (3–5 years)
- If positive at either test → re-enter triage/treatment pathway

### Post-Triage-Negative Follow-Up (HPV+ but triage-negative)
- General population: retest at **24 months**
- WLHIV: retest at **12 months**

### Post-Normal-Colposcopy Follow-Up (HPV+ but colposcopy normal)
- Both populations: retest at **12 months** with HPV DNA

## Full Recommendation Table

### General Population Recommendations

| # | Recommendation | Strength | Evidence |
|---|---|---|---|
| 1 | HPV DNA detection as primary screening test (over VIA/cytology) | Strong | Moderate |
| 2 | HPV DNA screening with or without triage | Conditional | Moderate |
| 3a | Screen-and-treat: treat HPV-positive women | Conditional | Moderate |
| 3b | Screen-triage-treat: use genotyping, colposcopy, VIA, or cytology | Conditional | Moderate |
| 4 | Self-collected or provider-collected samples both acceptable | Conditional | Low |
| 5 | Start screening at age 30 | Strong | Moderate |
| 6 | Stop after age 50 with 2 consecutive negatives | Conditional | Low |
| 7 | Prioritize ages 30–49 (good practice statement) | GPS | — |
| 8 | Screening interval 5–10 years with HPV DNA | Conditional | Low |
| 9 | Every 3 years with VIA/cytology (interim) | Conditional | Low |
| 10 | Even 2 lifetime screenings are beneficial (GPS) | GPS | — |
| 11 | HPV+/triage-negative: retest at 24 months | Conditional | Low |
| 12 | HPV+/colposcopy-normal: retest at 12 months | Conditional | Low |
| 13 | Post-treatment: retest at 12 months with HPV DNA | Conditional | Low |
| 14 | Switch to HPV DNA at next routine screening (GPS) | GPS | — |

### WLHIV Recommendations

| # | Recommendation | Strength | Evidence |
|---|---|---|---|
| 21 | HPV DNA detection as primary test | Strong | Moderate |
| 22 | HPV DNA screening with triage (triage recommended) | Conditional | Moderate |
| 23 | Screen-triage-treat approach | Conditional | Moderate |
| 24 | Self- or provider-collected samples acceptable | Conditional | Low |
| 25 | Start screening at age 25 | Conditional | Low |
| 26 | Stop after age 50 with 2 consecutive negatives | Conditional | Very low |
| 27 | Prioritize ages 25–49 (GPS) | GPS | — |
| 28 | Screening interval 3–5 years with HPV DNA | Conditional | Low |
| 29 | Every 3 years with VIA/cytology (interim) | Conditional | Low |
| 30 | Even 2 lifetime screenings beneficial (GPS) | GPS | — |
| 31 | HPV+/triage-negative: retest at 12 months | Conditional | Low |
| 32 | HPV+/colposcopy-normal: retest at 12 months | Conditional | Low |
| 33 | Post-treatment: retest at 12 months, then again at 12 months | Conditional | Low |
| 34 | Switch to HPV DNA at next routine screening (GPS) | GPS | — |

## Mapping to CQL Libraries

| CQL Library | Decision Points Covered | Algorithms |
|---|---|---|
| CervicalCancerScreeningCommon | Patient demographics, HIV status, screening history retrieval | All |
| CervicalCancerScreeningDecision | Screening eligibility (age, sex, interval), due-for-screening | All |
| CervicalCancerTriageDecision | HPV+ triage pathway (VIA, genotyping, cytology, colposcopy) | 3–7 |
| CervicalCancerTreatmentDecision | Ablation eligibility, treatment selection, referral triggers | All |
| CervicalCancerFollowUpDecision | Post-treatment retest timing, post-triage-negative retest | All |
| CervicalCancerIndicators | Population-level: % screened, % HPV+, % treated, % followed up | All |

### CQL Library Not in Original Plan: CervicalCancerFollowUpDecision

The follow-up logic is complex enough to warrant its own library rather than being
folded into ScreeningDecision. Key expressions:

- Is post-treatment follow-up due? (12 months post-treatment)
- Is post-triage-negative follow-up due? (12 or 24 months depending on HIV status)
- Is post-normal-colposcopy follow-up due? (12 months)
- Has second post-treatment follow-up been done? (WLHIV only)
- Can patient return to routine screening interval?

## Scope Decisions for This Project

### Which algorithms to implement first?

**Recommendation: Start with Algorithm 5 (HPV DNA + VIA Triage).**

Rationale:
- HPV DNA is the WHO-preferred primary test
- VIA triage is the most widely available triage method in LMIC settings
- Screen-triage-treat is recommended for WLHIV (the higher-risk population)
- Algorithm 5 covers both general population and WLHIV
- VIA assessment is also needed for ablation eligibility in ALL algorithms

After Algorithm 5 is working, extend to:
- Algorithm 2 (HPV screen-and-treat, general population only) — subset of 5
- Algorithm 4 (HPV + HPV16/18 genotyping) — adds genotyping layer
- Algorithm 1 (primary VIA) — for settings without HPV testing

### What about Algorithm 3, 6, 7 (cytology/colposcopy triage)?

Lower priority for LMIC OpenMRS deployments where cytology and colposcopy capacity
is limited. These can be added later as the CQL library matures.
