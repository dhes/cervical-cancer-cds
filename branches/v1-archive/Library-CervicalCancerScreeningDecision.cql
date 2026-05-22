/*
 * CervicalCancerScreeningDecision
 *
 * Screening eligibility and scheduling logic for cervical cancer CDS,
 * implementing WHO guideline Algorithm 5 (HPV DNA + VIA triage).
 *
 * This library determines:
 *   - Whether a patient is eligible for cervical cancer screening
 *   - Whether screening is currently due
 *   - The patient's current position in the screening cascade
 *   - The recommended next action
 *
 * WHO Recommendations covered:
 *   General population: 1, 2, 5, 6, 7, 8, 14
 *   WLHIV: 21, 22, 25, 26, 27, 28, 34
 *
 * @author  Dan Heslinga / Hopena Health
 * @version 0.1.0
 * @date    2026-03-08
 */

library CervicalCancerScreeningDecision version '0.1.0'

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'
include CervicalCancerScreeningCommon version '0.1.0' called Common

/*
 * =============================================================================
 * SCREENING ELIGIBILITY
 * =============================================================================
 *
 * @guidance WHO Rec 5 (general): Start at age 30
 *           WHO Rec 25 (WLHIV): Start at age 25
 *           WHO Rec 6/26: Stop after age 50 with adequate prior screening
 *           WHO Rec 7/27: Prioritize ages 30-49 (general) / 25-49 (WLHIV)
 */

context Patient

/*
 * @output Boolean — true if patient meets basic demographic criteria
 * @pseudocode Patient is female AND age >= minimum screening age
 */
define "Meets Age Criteria":
  Common."Is Female"
    and Common."Age In Years" >= Common."Minimum Screening Age"

/*
 * @output Boolean — true if patient is within the target screening age range
 * @pseudocode Patient age <= maximum screening age (50)
 */
define "Is Within Screening Age Range":
  Common."Age In Years" <= Common."Maximum Screening Age"

/*
 * @output Boolean — true if patient is eligible for cervical cancer screening
 * @pseudocode Patient is female, meets age criteria, no cervical cancer diagnosis
 * @guidance Patients with known cervical cancer should be managed through
 *           oncology, not the screening pathway.
 */
define "Is Eligible For Screening":
  "Meets Age Criteria"
    and not Common."Has Cervical Cancer Diagnosis"

/*
 * =============================================================================
 * SCREENING DUE DETERMINATION
 * =============================================================================
 *
 * @guidance WHO Rec 8 (general): Every 5-10 years with HPV DNA
 *           WHO Rec 28 (WLHIV): Every 3-5 years with HPV DNA
 *           Using lower bound (most conservative) for "due" calculation
 */

/*
 * @output Integer — years since most recent HPV DNA test, or null if never screened
 */
define "Years Since Last HPV Test":
  if Common."Has Ever Been Screened With HPV"
  then years between Common."Date Of Most Recent HPV Test" and Today()
  else null

/*
 * @output Boolean — true if patient has never been screened with HPV DNA
 */
define "Has Never Been Screened":
  not Common."Has Ever Been Screened With HPV"

/*
 * @output Boolean — true if screening interval has elapsed since last HPV test
 * @pseudocode Years since last test >= screening interval for this population
 */
define "Screening Interval Has Elapsed":
  Common."Has Ever Been Screened With HPV"
    and "Years Since Last HPV Test" >= Common."Screening Interval Years"

/*
 * @output Boolean — true if patient is due for routine screening
 * @pseudocode Patient is eligible AND (never screened OR interval elapsed)
 */
define "Is Due For Screening":
  "Is Eligible For Screening"
    and ("Has Never Been Screened" or "Screening Interval Has Elapsed")

/*
 * =============================================================================
 * CASCADE POSITION — Where is the patient in the screening pathway?
 * =============================================================================
 *
 * Algorithm 5 cascade:
 *   1. Not yet screened → Screen
 *   2. HPV negative, interval not elapsed → Routine recall
 *   3. HPV negative, interval elapsed → Re-screen
 *   4. HPV positive, no VIA yet → Needs VIA triage
 *   5. HPV positive, VIA negative → Follow-up retest (12/24 months)
 *   6. HPV positive, VIA positive → Needs treatment
 *   7. Treated → Post-treatment follow-up
 *   8. Cervical cancer → Refer to oncology
 *
 * This library determines cascade position; downstream libraries
 * (TriageDecision, TreatmentDecision, FollowUpDecision) handle
 * the detailed logic for positions 4-7.
 */

/*
 * @output Boolean — true if most recent HPV test was negative
 */
define "Most Recent HPV Test Is Negative":
  Common."Has Ever Been Screened With HPV"
    and not Common."Most Recent HPV Test Is Positive"

/*
 * @output Boolean — true if patient has a positive HPV result that
 *         has not yet been followed up with VIA triage
 * @pseudocode HPV+ AND (no VIA result OR most recent VIA is before the HPV test)
 */
define "Needs Triage After Positive HPV":
  Common."Most Recent HPV Test Is Positive"
    and (
      not exists(Common."VIA Screening Results")
      or Common."Date Of Most Recent VIA" before Common."Date Of Most Recent HPV Test"
    )

/*
 * @output Boolean — true if HPV+ and VIA triage was positive (needs treatment)
 * @pseudocode HPV+ AND VIA+ AND VIA was after HPV test
 */
define "Has Positive Triage Result":
  Common."Most Recent HPV Test Is Positive"
    and Common."Most Recent VIA Is Positive"
    and Common."Date Of Most Recent VIA" on or after Common."Date Of Most Recent HPV Test"

/*
 * @output Boolean — true if HPV+ but VIA triage was negative (needs follow-up retest)
 * @pseudocode HPV+ AND VIA- AND VIA was after HPV test
 */
define "Triage Was Negative":
  Common."Most Recent HPV Test Is Positive"
    and not Common."Most Recent VIA Is Positive"
    and Common."Date Of Most Recent VIA" on or after Common."Date Of Most Recent HPV Test"

/*
 * @output Boolean — true if patient is in post-treatment follow-up window
 * @pseudocode Patient has been treated AND months since treatment < 24
 *             (covers both 12-month and 12+12-month WLHIV windows)
 */
define "Is In Post Treatment Follow Up":
  Common."Has Been Treated"
    and Common."Months Since Treatment" is not null
    and Common."Months Since Treatment" < 24

/*
 * =============================================================================
 * RECOMMENDED ACTION — Clinician-facing guidance
 * =============================================================================
 *
 * @guidance These are the primary outputs consumed by CDS hooks / alerts.
 *           Each returns a human-readable recommendation string.
 */

/*
 * @output String — the recommended next action for this patient
 * @pseudocode Decision tree based on cascade position
 */
define "Recommended Action":
  case
    // Exclusion: cervical cancer diagnosed
    when Common."Has Cervical Cancer Diagnosis"
      then 'Refer to oncology for cervical cancer management'

    // Not eligible (wrong sex or too young)
    when not "Meets Age Criteria"
      then 'Not yet eligible for cervical cancer screening'

    // Post-treatment follow-up in progress
    when "Is In Post Treatment Follow Up"
      then 'Post-treatment follow-up: retest with HPV DNA at 12 months post-treatment'

    // HPV+ needs VIA triage
    when "Needs Triage After Positive HPV"
      then 'HPV test is positive — perform VIA triage'

    // HPV+ VIA+ needs treatment
    when "Has Positive Triage Result"
      then 'HPV-positive and VIA-positive — assess ablation eligibility and treat'

    // HPV+ VIA- needs follow-up retest
    when "Triage Was Negative"
      then 'HPV-positive but VIA-negative — retest with HPV DNA in '
           + ToString(Common."Post Triage Negative Retest Months")
           + ' months'

    // Never screened and eligible
    when "Has Never Been Screened" and "Is Eligible For Screening"
      then 'Screen with HPV DNA test'

    // Interval elapsed and eligible
    when "Screening Interval Has Elapsed" and "Is Eligible For Screening"
      then 'Routine re-screening due — screen with HPV DNA test'

    // HPV negative, not yet due
    when "Most Recent HPV Test Is Negative" and not "Screening Interval Has Elapsed"
      then 'Last HPV test was negative — next screening due in '
           + ToString(Common."Screening Interval Years" - "Years Since Last HPV Test")
           + ' years'

    // Over age 50 — evaluate for cessation
    when Common."Age In Years" > Common."Maximum Screening Age"
      then 'Age over 50 — assess for screening cessation (requires 2 consecutive negative HPV tests)'

    else 'Unable to determine recommendation — review patient data'
  end

/*
 * @output String — coded cascade position for downstream logic
 * @pseudocode Returns a machine-readable status for integration
 */
define "Cascade Status":
  case
    when Common."Has Cervical Cancer Diagnosis" then 'cervical-cancer'
    when not "Meets Age Criteria" then 'not-eligible'
    when "Is In Post Treatment Follow Up" then 'post-treatment-follow-up'
    when "Needs Triage After Positive HPV" then 'needs-triage'
    when "Has Positive Triage Result" then 'needs-treatment'
    when "Triage Was Negative" then 'triage-negative-follow-up'
    when "Has Never Been Screened" and "Is Eligible For Screening" then 'due-for-screening'
    when "Screening Interval Has Elapsed" and "Is Eligible For Screening" then 'due-for-screening'
    when "Most Recent HPV Test Is Negative" then 'routine-recall'
    when Common."Age In Years" > Common."Maximum Screening Age" then 'assess-cessation'
    else 'unknown'
  end

/*
 * =============================================================================
 * SCREENING INTERVAL DISPLAY — For clinician-facing display
 * =============================================================================
 */

/*
 * @output String — human-readable screening interval for this patient
 */
define "Screening Interval Display":
  if Common."Is WLHIV"
  then '3-5 years (WLHIV)'
  else '5-10 years (general population)'

/*
 * @output String — human-readable population classification
 */
define "Population Classification":
  if Common."Is WLHIV"
  then 'Woman living with HIV (WLHIV) — WHO Recommendations 21-34'
  else 'General population — WHO Recommendations 1-14'

/*
 * =============================================================================
 * SUMMARY OUTPUTS — Structured data for CDS integration
 * =============================================================================
 */

/*
 * @output Boolean — overall flag: does this patient need clinical attention?
 * @pseudocode True if any action is recommended (screening, triage, treatment, follow-up)
 */
define "Needs Attention":
  "Is Due For Screening"
    or "Needs Triage After Positive HPV"
    or "Has Positive Triage Result"
    or "Is In Post Treatment Follow Up"
    or Common."Has Cervical Cancer Diagnosis"
