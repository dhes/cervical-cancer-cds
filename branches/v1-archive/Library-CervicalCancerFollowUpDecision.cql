/*
 * CervicalCancerFollowUpDecision
 *
 * Follow-up scheduling logic for cervical cancer screening CDS,
 * implementing WHO guideline post-treatment and post-triage-negative
 * follow-up intervals.
 *
 * This library determines:
 *   - Post-treatment follow-up timing (12 months for both populations)
 *   - Post-triage-negative follow-up timing (12 months WLHIV, 24 months general)
 *   - WLHIV double follow-up tracking (second retest at 12 months after first)
 *   - Return-to-routine-screening criteria
 *   - Re-entry to triage/treatment if follow-up HPV test is positive
 *
 * Follow-up Cascades:
 *
 *   Post-Treatment (both populations):
 *     Treated → 12 months → HPV retest
 *       ├── Negative (general) → return to routine screening (5-10 years)
 *       ├── Negative (WLHIV) → second retest at 12 months
 *       │     ├── Negative → return to routine screening (3-5 years)
 *       │     └── Positive → re-enter triage/treatment
 *       └── Positive → re-enter triage/treatment
 *
 *   Post-Triage-Negative:
 *     HPV+ but VIA- → retest at 12 months (WLHIV) or 24 months (general)
 *       ├── Negative → return to routine screening
 *       └── Positive → re-enter triage
 *
 * WHO Recommendations covered:
 *   General: 11 (post-triage-negative retest at 24mo), 12 (post-colp-normal), 13 (post-treatment 12mo)
 *   WLHIV: 31 (post-triage-negative retest at 12mo), 32 (post-colp-normal), 33 (post-treatment double)
 *
 * @author  Dan Heslinga / Hopena Health
 * @version 0.1.0
 * @date    2026-03-08
 */

library CervicalCancerFollowUpDecision version '0.1.0'

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'
include CervicalCancerScreeningCommon version '0.1.0' called Common

context Patient

/*
 * =============================================================================
 * POST-TREATMENT FOLLOW-UP
 * =============================================================================
 *
 * @guidance WHO Rec 13/33: Retest with HPV DNA at 12 months post-treatment
 *           WLHIV Rec 33: If negative, retest again at 12 months (double follow-up)
 */

/*
 * @output Boolean — true if patient has been treated and is in the follow-up window
 * @pseudocode Treated within the last 24 months (covers both single and double follow-up)
 */
define "Is In Post Treatment Follow Up Window":
  Common."Has Been Treated"
    and Common."Months Since Treatment" is not null
    and Common."Months Since Treatment" < 24

/*
 * @output Integer — months since most recent treatment
 */
define "Months Since Treatment":
  Common."Months Since Treatment"

/*
 * @output Boolean — true if the 12-month post-treatment HPV retest is due
 * @pseudocode Treated AND >= 12 months elapsed AND no HPV test after treatment
 */
define "Post Treatment Retest Is Due":
  Common."Has Been Treated"
    and Common."Months Since Treatment" >= Common."Post Treatment Retest Months"
    and not "Has HPV Test After Treatment"

/*
 * @output Boolean — true if the 12-month retest is approaching (within 2 months)
 * @pseudocode Treated AND 10-12 months elapsed AND no HPV test after treatment
 * @guidance Use this for early reminders to schedule the follow-up visit
 */
define "Post Treatment Retest Is Approaching":
  Common."Has Been Treated"
    and Common."Months Since Treatment" >= (Common."Post Treatment Retest Months" - 2)
    and Common."Months Since Treatment" < Common."Post Treatment Retest Months"
    and not "Has HPV Test After Treatment"

/*
 * @output Boolean — true if an HPV DNA test was performed after the most recent treatment
 */
define "Has HPV Test After Treatment":
  Common."Has Been Treated"
    and Common."Has Ever Been Screened With HPV"
    and Common."Date Of Most Recent HPV Test" after Common."Date Of Most Recent Treatment"

/*
 * @output Boolean — true if the post-treatment HPV retest was negative
 */
define "Post Treatment Retest Is Negative":
  "Has HPV Test After Treatment"
    and not Common."Most Recent HPV Test Is Positive"

/*
 * @output Boolean — true if the post-treatment HPV retest was positive
 * @guidance Positive → re-enter triage/treatment pathway
 */
define "Post Treatment Retest Is Positive":
  "Has HPV Test After Treatment"
    and Common."Most Recent HPV Test Is Positive"

/*
 * =============================================================================
 * WLHIV DOUBLE FOLLOW-UP
 * =============================================================================
 *
 * @guidance WHO Rec 33: WLHIV should have TWO consecutive negative HPV tests
 *           at 12-month intervals after treatment before returning to routine
 *           screening. This is because WLHIV have higher rates of persistent
 *           HPV infection and recurrence.
 *
 * Logic:
 *   Treatment → 12mo → HPV retest #1
 *     ├── Negative → 12 more months → HPV retest #2
 *     │     ├── Negative → return to routine (3-5 year interval)
 *     │     └── Positive → re-enter triage/treatment
 *     └── Positive → re-enter triage/treatment
 */

/*
 * @output Boolean — true if patient is WLHIV requiring double follow-up
 */
define "Requires Double Follow Up":
  Common."Is WLHIV"
    and Common."Has Been Treated"

/*
 * @output Integer — how many HPV tests have been done since the most recent treatment
 * @pseudocode Count of HPV DNA tests with effectiveDateTime after treatment date
 */
define "HPV Tests Since Treatment Count":
  if not Common."Has Been Treated"
  then 0
  else Count(
    Common."HPV DNA Test Results" O
      where (O.effective as FHIR.dateTime).value after Common."Date Of Most Recent Treatment"
  )

/*
 * @output Boolean — true if WLHIV has had first post-treatment negative test
 *         but second test is not yet done
 * @pseudocode WLHIV AND treated AND exactly 1 post-treatment HPV test AND it was negative
 */
define "WLHIV Needs Second Follow Up Test":
  "Requires Double Follow Up"
    and "HPV Tests Since Treatment Count" = 1
    and not Common."Most Recent HPV Test Is Positive"

/*
 * @output Boolean — true if WLHIV second follow-up test is due (12 months after first post-tx test)
 * @pseudocode WLHIV AND needs second test AND >= 12 months since the first post-treatment test
 */
define "WLHIV Second Follow Up Test Is Due":
  "WLHIV Needs Second Follow Up Test"
    and months between Common."Date Of Most Recent HPV Test" and Today() >= 12

/*
 * @output Boolean — true if WLHIV has completed both follow-up tests with negative results
 * @pseudocode WLHIV AND treated AND >= 2 post-treatment HPV tests AND most recent is negative
 */
define "WLHIV Double Follow Up Complete":
  "Requires Double Follow Up"
    and "HPV Tests Since Treatment Count" >= 2
    and not Common."Most Recent HPV Test Is Positive"

/*
 * =============================================================================
 * POST-TRIAGE-NEGATIVE FOLLOW-UP
 * =============================================================================
 *
 * @guidance WHO Rec 11 (general): HPV+/VIA- → retest at 24 months
 *           WHO Rec 31 (WLHIV): HPV+/VIA- → retest at 12 months
 */

/*
 * @output Boolean — true if patient is in post-triage-negative follow-up
 * @pseudocode HPV+ AND VIA- AND VIA was after HPV test
 */
define "Is Post Triage Negative":
  Common."Most Recent HPV Test Is Positive"
    and not Common."Most Recent VIA Is Positive"
    and exists(Common."VIA Screening Results")
    and Common."Date Of Most Recent VIA" on or after Common."Date Of Most Recent HPV Test"
    and not Common."Has Been Treated"

/*
 * @output Integer — months since the triage-negative VIA result
 */
define "Months Since Triage Negative VIA":
  if "Is Post Triage Negative"
  then months between Common."Date Of Most Recent VIA" and Today()
  else null

/*
 * @output Boolean — true if the post-triage-negative HPV retest is due
 * @pseudocode Triage-negative AND months elapsed >= retest interval (12 or 24)
 */
define "Post Triage Negative Retest Is Due":
  "Is Post Triage Negative"
    and "Months Since Triage Negative VIA" >= Common."Post Triage Negative Retest Months"

/*
 * @output Boolean — true if the post-triage-negative retest is approaching (within 2 months)
 */
define "Post Triage Negative Retest Is Approaching":
  "Is Post Triage Negative"
    and "Months Since Triage Negative VIA" >= (Common."Post Triage Negative Retest Months" - 2)
    and "Months Since Triage Negative VIA" < Common."Post Triage Negative Retest Months"

/*
 * =============================================================================
 * RETURN TO ROUTINE SCREENING
 * =============================================================================
 *
 * @guidance Patients can return to routine screening interval when:
 *   General: post-treatment HPV retest negative → 5-10 year interval
 *   WLHIV: two consecutive negative post-treatment HPV retests → 3-5 year interval
 *   Both: post-triage-negative HPV retest negative → routine interval
 */

/*
 * @output Boolean — true if patient can return to routine screening
 * @pseudocode
 *   (Post-treatment, general pop, retest negative) OR
 *   (Post-treatment, WLHIV, double follow-up complete) OR
 *   (Post-triage-negative retest was done and was negative)
 */
define "Can Return To Routine Screening":
  // General population: single negative post-treatment test
  (Common."Has Been Treated"
    and not Common."Is WLHIV"
    and "Post Treatment Retest Is Negative")
  or
  // WLHIV: double follow-up complete
  "WLHIV Double Follow Up Complete"

/*
 * =============================================================================
 * RECOMMENDED ACTION — Follow-up-specific guidance
 * =============================================================================
 */

/*
 * @output String — the recommended follow-up action
 */
define "Follow Up Recommended Action":
  case
    // Post-treatment: retest was positive → re-enter screening cascade
    when "Post Treatment Retest Is Positive"
      then 'Post-treatment HPV retest is POSITIVE — re-enter triage/treatment pathway'

    // WLHIV: double follow-up complete → return to routine
    when "WLHIV Double Follow Up Complete"
      then 'Two consecutive negative HPV tests after treatment — return to routine screening every '
           + ToString(Common."Screening Interval Years") + ' years'

    // General pop: post-treatment retest negative → return to routine
    when "Post Treatment Retest Is Negative" and not Common."Is WLHIV"
      then 'Post-treatment HPV retest is negative — return to routine screening every '
           + ToString(Common."Screening Interval Years") + ' years'

    // WLHIV: first post-treatment test negative, second test due
    when "WLHIV Second Follow Up Test Is Due"
      then 'First post-treatment HPV retest was negative — second retest now due (WLHIV double follow-up)'

    // WLHIV: first post-treatment test negative, waiting for second
    when "WLHIV Needs Second Follow Up Test"
      then 'First post-treatment HPV retest was negative — schedule second retest in '
           + ToString(12 - (months between Common."Date Of Most Recent HPV Test" and Today()))
           + ' months (WLHIV double follow-up)'

    // Post-treatment: retest is due
    when "Post Treatment Retest Is Due"
      then 'Post-treatment HPV DNA retest is due (12 months post-treatment)'

    // Post-treatment: retest approaching
    when "Post Treatment Retest Is Approaching"
      then 'Post-treatment HPV DNA retest approaching — due in '
           + ToString(Common."Post Treatment Retest Months" - Common."Months Since Treatment")
           + ' months'

    // Post-treatment: waiting for retest interval
    when "Is In Post Treatment Follow Up Window" and not "Has HPV Test After Treatment"
      then 'Post-treatment — HPV DNA retest scheduled at 12 months. '
           + ToString(Common."Post Treatment Retest Months" - Common."Months Since Treatment")
           + ' months remaining'

    // Post-triage-negative: retest due
    when "Post Triage Negative Retest Is Due"
      then 'Post-triage-negative HPV DNA retest is due'

    // Post-triage-negative: retest approaching
    when "Post Triage Negative Retest Is Approaching"
      then 'Post-triage-negative HPV DNA retest approaching — due in '
           + ToString(Common."Post Triage Negative Retest Months" - "Months Since Triage Negative VIA")
           + ' months'

    // Post-triage-negative: waiting
    when "Is Post Triage Negative"
      then 'HPV-positive but VIA-negative — HPV DNA retest in '
           + ToString(Common."Post Triage Negative Retest Months" - "Months Since Triage Negative VIA")
           + ' months'

    else 'No follow-up action indicated'
  end

/*
 * @output String — coded follow-up status for integration
 */
define "Follow Up Status":
  case
    when "Post Treatment Retest Is Positive" then 'retest-positive-reenter'
    when "Can Return To Routine Screening" then 'return-to-routine'
    when "WLHIV Second Follow Up Test Is Due" then 'wlhiv-second-retest-due'
    when "WLHIV Needs Second Follow Up Test" then 'wlhiv-awaiting-second-retest'
    when "Post Treatment Retest Is Due" then 'post-treatment-retest-due'
    when "Post Treatment Retest Is Approaching" then 'post-treatment-retest-approaching'
    when "Is In Post Treatment Follow Up Window" then 'post-treatment-waiting'
    when "Post Triage Negative Retest Is Due" then 'post-triage-negative-retest-due'
    when "Post Triage Negative Retest Is Approaching" then 'post-triage-negative-retest-approaching'
    when "Is Post Triage Negative" then 'post-triage-negative-waiting'
    else 'no-follow-up'
  end

/*
 * @output Boolean — overall flag: does this patient have an active follow-up action?
 */
define "Has Active Follow Up":
  "Is In Post Treatment Follow Up Window"
    or "Is Post Triage Negative"
    or "WLHIV Needs Second Follow Up Test"
