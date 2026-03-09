# Synthetic Test Patients — Cervical Cancer Screening CDS

**Created**: 2026-03-08
**OpenMRS instance**: `http://localhost/openmrs/ws/fhir2/R4/`
**Target algorithm**: Algorithm 5 (HPV DNA + VIA triage)

## Patient Summary

| # | Name | DOB | Age | HIV | Clinical Data | Expected CDS Output |
|---|---|---|---|---|---|---|
| S1 | Amara Okafor | 1991-05-14 | 34 | No | None | Eligible, due for screening |
| S2 | Blessing Mutua | 1991-08-22 | 34 | No | HPV+ (2026-02-22) | Needs VIA triage |
| S3 | Chioma Ndege | 1990-11-03 | 35 | No | HPV+ (02-08), VIA+ (02-22) | Needs treatment |
| S4 | Deka Abdi | 1991-02-17 | 35 | No | HPV+ (04-08), VIA+ (04-22), thermal ablation (05-08) | Follow-up due ~2026-05 |
| S5 | Esther Wanjiku | 1991-06-30 | 34 | **Yes** | HIV dx (2020-03-15) | Eligible (WLHIV age 25+), due for screening |
| S6 | Fatima Keita | 2001-01-09 | 25 | No | None | **Not eligible** (age < 30) |
| S7 | Grace Achieng | 2001-04-21 | 24 | **Yes** | HIV dx (2022-09-10) | **Not eligible** (age < 25) |

Note: Ages are as of 2026-03-08. Amara, Blessing, and Esther will turn 35 later
in 2026, so depending on CQL evaluation date, `AgeInYears()` may return 34.

## Patient UUIDs

```
S1  Amara Okafor     3d8d6e9a-45ed-430f-8716-5fbe90660785
S2  Blessing Mutua   2da68420-6f5b-4fee-a341-7ff04c545cdb
S3  Chioma Ndege     5fcb766f-37a4-42ce-8f6e-26baf4d93295
S4  Deka Abdi        27df8dd2-2264-446b-974b-bd1791c1a502
S5  Esther Wanjiku   81a21bdd-bdf3-4314-8a32-d71d0c8078c8
S6  Fatima Keita     556263d5-8a30-4b5b-92ef-76a9b70376e7
S7  Grace Achieng    4bc736db-70d3-4b6a-9282-87209cae7ed4
```

## Detailed Scenario Descriptions

### S1: Amara Okafor — Eligible, never screened

- Female, age 34 (turns 35 in May 2026), no HIV
- No observations, no conditions
- **Expected**: `IsEligibleForScreening` = true (age ≥ 30, female)
- **Expected**: `IsDueForScreening` = true (never screened)
- **Expected**: `RecommendedAction` = "Screen with HPV DNA test"

### S2: Blessing Mutua — HPV-positive, needs triage

- Female, age 34, no HIV
- HPV DNA test = **Positive** on 2026-02-22
- **Expected**: `HasPositiveHPVTest` = true
- **Expected**: `NeedsTriageAfterPositiveHPV` = true
- **Expected**: `RecommendedAction` = "Perform VIA triage"

### S3: Chioma Ndege — HPV+ and VIA+, needs treatment

- Female, age 35, no HIV
- HPV DNA test = **Positive** on 2026-02-08
- VIA screening = **Positive** on 2026-02-22
- **Expected**: `HasPositiveHPVTest` = true
- **Expected**: `HasPositiveTriageResult` = true
- **Expected**: `NeedsTreatment` = true
- **Expected**: `RecommendedAction` = "Assess ablation eligibility and treat"

### S4: Deka Abdi — Treated, follow-up approaching

- Female, age 35, no HIV
- HPV DNA test = **Positive** on 2025-04-08
- VIA screening = **Positive** on 2025-04-22
- Thermocauterization of cervix on 2025-05-08 (10 months ago)
- **Expected**: `HasBeenTreated` = true
- **Expected**: `IsPostTreatmentFollowUpDue` = true (or approaching — 12 months post = 2026-05-08)
- **Expected**: `RecommendedAction` = "Retest with HPV DNA at 12 months post-treatment"

### S5: Esther Wanjiku — WLHIV, never screened

- Female, age 34, **HIV positive** since 2020-03-15
- No screening observations
- **Expected**: `IsWLHIV` = true
- **Expected**: `IsEligibleForScreening` = true (WLHIV age ≥ 25)
- **Expected**: `IsDueForScreening` = true (never screened)
- **Expected**: `RecommendedAction` = "Screen with HPV DNA test"
- **Expected**: `ScreeningInterval` = "3-5 years" (WLHIV interval)

### S6: Fatima Keita — Too young (general population)

- Female, age 25, no HIV
- No observations, no conditions
- **Expected**: `IsEligibleForScreening` = **false** (age 25 < 30 threshold)
- **Expected**: `RecommendedAction` = "Not yet eligible for screening"

### S7: Grace Achieng — Too young (even for WLHIV)

- Female, age 24 (turns 25 in April 2026), **HIV positive** since 2022-09-10
- **Expected**: `IsWLHIV` = true
- **Expected**: `IsEligibleForScreening` = **false** (age 24 < 25 WLHIV threshold)
- **Expected**: `RecommendedAction` = "Not yet eligible for screening"

Note: Grace turns 25 in April 2026, so if CQL is evaluated after 2026-04-21,
she becomes eligible. This is a useful edge case for testing.

### S8: Hana Bekele — HPV-positive, VIA-negative (triage negative)

- Female, age 35, no HIV
- HPV DNA test = **Positive** on 2026-01-15
- VIA screening = **Negative** on 2026-01-29
- **Expected**: `VIA Triage Is Negative` = true, `Is Post Triage Negative` = true
- **Expected**: `Follow Up Status` = `post-triage-negative-waiting`
- **Expected**: Retest with HPV DNA in 24 months (general population)

### S9: Ines Diallo — Treated 13 months ago, retest due

- Female, age 36, no HIV
- HPV DNA test = **Positive** on 2024-12-01
- VIA screening = **Positive** on 2024-12-15
- Thermal ablation on 2025-02-08 (13 months ago)
- No post-treatment HPV retest yet
- **Expected**: `Post Treatment Retest Is Due` = true
- **Expected**: `Follow Up Status` = `post-treatment-retest-due`

### S10: Joy Mwangi — HPV-negative 21 months ago (routine recall)

- Female, age 37, no HIV
- HPV DNA test = **Negative** on 2024-06-15
- **Expected**: `Is Eligible For Screening` = true
- **Expected**: `Cascade Status` = `routine-recall` (21 months < 5 year interval)

### S11: Keza Uwimana — WLHIV, triage negative (12-month follow-up)

- Female, age 33, **HIV positive** since 2021-06-01
- HPV DNA test = **Positive** on 2025-12-01
- VIA screening = **Negative** on 2025-12-15
- **Expected**: `Is Post Triage Negative` = true
- **Expected**: `Follow Up Status` = `post-triage-negative-waiting`
- **Expected**: Retest with HPV DNA in 12 months (WLHIV, not 24)

### S12: Lina Osei — WLHIV, treated, first retest negative (needs second)

- Female, age 35, **HIV positive** since 2019-01-15
- HPV+ 2024-06-01, VIA+ 2024-07-01, thermal ablation 2024-08-08
- Post-treatment HPV retest = **Negative** on 2025-08-08
- **Expected**: `WLHIV Needs Second Follow Up Test` = true
- **Expected**: `Follow Up Status` = `wlhiv-awaiting-second-retest`
- **Expected**: Second HPV DNA retest due 12 months after first (2026-08-08)

### S13: Miriam Tadesse — Treated, post-treatment retest positive

- Female, age 35, no HIV
- HPV+ 2024-10-01, VIA+ 2024-11-01, cryotherapy 2024-12-08
- Post-treatment HPV retest = **Positive** on 2026-01-08
- **Expected**: `Post Treatment Retest Is Positive` = true
- **Expected**: `Follow Up Status` = `retest-positive-reenter`
- **Expected**: Re-enter triage/treatment pathway

### S14: Naomi Chege — HPV-negative 6 years ago (re-screening due)

- Female, age 37, no HIV
- HPV DNA test = **Negative** on 2020-03-01 (6 years ago)
- **Expected**: `Is Due For Screening` = true (6 years ≥ 5 year interval)
- **Expected**: `Cascade Status` = `due-for-screening`

## Patient UUIDs

```
S1  Amara Okafor     3d8d6e9a-45ed-430f-8716-5fbe90660785
S2  Blessing Mutua   2da68420-6f5b-4fee-a341-7ff04c545cdb
S3  Chioma Ndege     5fcb766f-37a4-42ce-8f6e-26baf4d93295
S4  Deka Abdi        27df8dd2-2264-446b-974b-bd1791c1a502
S5  Esther Wanjiku   81a21bdd-bdf3-4314-8a32-d71d0c8078c8
S6  Fatima Keita     556263d5-8a30-4b5b-92ef-76a9b70376e7
S7  Grace Achieng    4bc736db-70d3-4b6a-9282-87209cae7ed4
S8  Hana Bekele      49f9fd5b-4a83-43a2-ae6a-a86512814865
S9  Ines Diallo      7cf601c9-cd37-4f5f-8a36-12e96339a007
S10 Joy Mwangi       5eeb3241-8dc3-4f13-892b-3199c389f6ad
S11 Keza Uwimana     7a4319b5-32df-4aed-9bdb-0d2718ef0649
S12 Lina Osei        57b226e1-c7ca-41a0-a96c-42d57d21b64d
S13 Miriam Tadesse   1c8ce8a6-d27d-44da-8837-be4a1d13f778
S14 Naomi Chege      68a545ac-831a-4c36-a779-8baff817dcc3
```

## FHIR Resource Details

### Observations

| Patient | Code (SNOMED) | Code (CIEL) | Value | Date |
|---|---|---|---|---|
| S2 Blessing | 35904009 (HPV DNA) | 170145 | Positive | 2026-02-22 |
| S3 Chioma | 35904009 (HPV DNA) | 170145 | Positive | 2026-02-08 |
| S3 Chioma | 243877001 (Screening) | 151185 | Positive | 2026-02-22 |
| S4 Deka | 35904009 (HPV DNA) | 170145 | Positive | 2025-04-08 |
| S4 Deka | 243877001 (Screening) | 151185 | Positive | 2025-04-22 |
| S4 Deka | 1287592000 (Thermal ablation) | 166706 | Positive (= completed) | 2025-05-08 |
| S8 Hana | 35904009 (HPV DNA) | 170145 | Positive | 2026-01-15 |
| S8 Hana | 243877001 (Screening) | 151185 | Negative | 2026-01-29 |
| S9 Ines | 35904009 (HPV DNA) | 170145 | Positive | 2024-12-01 |
| S9 Ines | 243877001 (Screening) | 151185 | Positive | 2024-12-15 |
| S9 Ines | 1287592000 (Thermal ablation) | 166706 | Positive (= completed) | 2025-02-08 |
| S10 Joy | 35904009 (HPV DNA) | 170145 | Negative | 2024-06-15 |
| S11 Keza | 35904009 (HPV DNA) | 170145 | Positive | 2025-12-01 |
| S11 Keza | 243877001 (Screening) | 151185 | Negative | 2025-12-15 |
| S12 Lina | 35904009 (HPV DNA) | 170145 | Positive | 2024-06-01 |
| S12 Lina | 243877001 (Screening) | 151185 | Positive | 2024-07-01 |
| S12 Lina | 1287592000 (Thermal ablation) | 166706 | Positive (= completed) | 2024-08-08 |
| S12 Lina | 35904009 (HPV DNA) | 170145 | Negative | 2025-08-08 |
| S13 Miriam | 35904009 (HPV DNA) | 170145 | Positive | 2024-10-01 |
| S13 Miriam | 243877001 (Screening) | 151185 | Positive | 2024-11-01 |
| S13 Miriam | 78203001 (Cryotherapy) | 162812 | Positive (= completed) | 2024-12-08 |
| S13 Miriam | 35904009 (HPV DNA) | 170145 | Positive | 2026-01-08 |
| S14 Naomi | 35904009 (HPV DNA) | 170145 | Negative | 2020-03-01 |

### Conditions

| Patient | Code (SNOMED) | Code (CIEL) | ICD-10 | Status | Onset |
|---|---|---|---|---|---|
| S5 Esther | 86406008 (HIV) | 138405 | B24 | active | 2020-03-15 |
| S7 Grace | 86406008 (HIV) | 138405 | B24 | active | 2022-09-10 |
| S11 Keza | 86406008 (HIV) | 138405 | B24 | active | 2021-06-01 |
| S12 Lina | 86406008 (HIV) | 138405 | B24 | active | 2019-01-15 |

## CQL Verification Queries

```bash
# Retrieve all observations for a patient
curl -u admin:Admin123 "http://localhost/openmrs/ws/fhir2/R4/Observation?patient=<uuid>&_sort=-date"

# Retrieve HPV test results specifically
curl -u admin:Admin123 "http://localhost/openmrs/ws/fhir2/R4/Observation?patient=<uuid>&code=http://snomed.info/sct|35904009"

# Retrieve conditions for a patient
curl -u admin:Admin123 "http://localhost/openmrs/ws/fhir2/R4/Condition?patient=<uuid>"

# Retrieve treatment observations
curl -u admin:Admin123 "http://localhost/openmrs/ws/fhir2/R4/Observation?patient=<uuid>&code=http://snomed.info/sct|1287592000"
```
