### Test Suite Overview

The CQL logic is validated against 14 synthetic test patients covering the
full screening cascade, with 82 assertions across 4 decision libraries.

### Test Patients

| ID | Name | Age | HIV | Scenario | Key Cascade Status |
|---|---|---|---|---|---|
| S1 | Amara Okafor | 34 | No | Eligible, never screened | `due-for-screening` |
| S2 | Blessing Mutua | 34 | No | HPV+ 2 weeks ago | `needs-triage` |
| S3 | Chioma Ndege | 35 | No | HPV+ VIA+ | `needs-treatment` |
| S4 | Deka Abdi | 35 | No | Treated 10 months ago | `post-treatment-follow-up` |
| S5 | Esther Wanjiku | 34 | Yes | WLHIV, never screened | `due-for-screening` |
| S6 | Fatima Keita | 25 | No | Age < 30 (general pop) | `not-eligible` |
| S7 | Grace Achieng | 24 | Yes | Age < 25 (WLHIV) | `not-eligible` |
| S8 | Hana Bekele | 35 | No | HPV+ VIA- (triage negative) | `triage-negative-follow-up` |
| S9 | Ines Diallo | 36 | No | Treated 13 months ago | `post-treatment-follow-up` |
| S10 | Joy Mwangi | 37 | No | HPV- 21 months ago | `routine-recall` |
| S11 | Keza Uwimana | 33 | Yes | WLHIV, triage negative | `triage-negative-follow-up` |
| S12 | Lina Osei | 35 | Yes | WLHIV, first retest negative | `post-treatment-follow-up` |
| S13 | Miriam Tadesse | 35 | No | Post-treatment retest positive | `post-treatment-follow-up` |
| S14 | Naomi Chege | 37 | No | HPV- 6 years ago | `due-for-screening` |

### Running Tests

Prerequisites: Node.js 18+, OpenMRS running locally with synthetic patients loaded.

```bash
npm install
node tests/evaluate-cql.mjs
```

Expected output: `82/82 assertions passed`

### Edge Cases Covered

- **WLHIV double follow-up** (S12): First post-treatment HPV retest negative,
  second retest still needed before return to routine
- **Retest-positive re-entry** (S13): Post-treatment HPV retest is positive,
  patient re-enters triage/treatment pathway
- **Interval-elapsed re-screening** (S14): Previous HPV- result beyond the
  routine screening interval, patient is due again
- **Approaching window** (S4): Post-treatment retest within 2 months of due
  date triggers an "approaching" alert
- **Age thresholds** (S6, S7): Below screening age for general population
  and WLHIV respectively
