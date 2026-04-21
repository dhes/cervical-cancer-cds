/*
 * CervicalCancerTriageDecision
 *
 * Triage pathway logic for HPV-positive women, implementing
 * WHO guideline Algorithm 5 (HPV DNA + VIA triage) with
 * extension points for Algorithms 3, 4, 6, 7.
 *
 * This library determines:
 *   - Whether triage is indicated
 *   - The appropriate triage method for the active algorithm
 *   - Interpretation of triage results
 *   - Routing to treatment vs follow-up vs referral
 *
 * Algorithm 5 cascade after HPV+:
 *   HPV positive → VIA triage
 *     ├── VIA positive → Treat (→ TreatmentDecision)
 *     ├── VIA negative → Retest at 12/24 months (→ FollowUpDecision)
 *     └── Suspicious for cancer → Refer to oncology
 *
 * WHO Recommendations covered:
 *   General population: 3b (screen-triage-treat), 11 (post-triage-negative retest)
 *   WLHIV: 22 (triage recommended), 23 (screen-triage-treat), 31 (retest timing)
 *
 * @author  Dan Heslinga / Hopena Health
 * @version 0.1.0
 * @date    2026-03-08
 */

library CervicalCancerTriageDecision version '0.1.0'

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'
include CervicalCancerScreeningCommon version '0.1.0' called Common

context Patient

/*
 * =============================================================================
 * TRIAGE INDICATION
 * =============================================================================
 *
 * @guidance Triage is indicated when the primary HPV DNA test is positive.
 *           In Algorithm 5, VIA is the triage method.
 *           In screen-and-treat approaches (Algorithm 2), VIA is still done
 *           but for treatment modality selection rather than triage.
 */

/*
 * @output Boolean — true if triage is indicated (HPV+ without subsequent triage)
 * @pseudocode HPV test positive AND no VIA result after the HPV test
 */
define "Triage Is Indicated":
  Common."Most Recent HPV Test Is Positive"
    and (
      not exists(Common."VIA Screening Results")
      or Common."Date Of Most Recent VIA" before Common."Date Of Most Recent HPV Test"
    )

/*
 * @output Boolean — true if triage has been performed (VIA done after HPV+ result)
 */
define "Triage Has Been Performed":
  Common."Most Recent HPV Test Is Positive"
    and exists(Common."VIA Screening Results")
    and Common."Date Of Most Recent VIA" on or after Common."Date Of Most Recent HPV Test"

/*
 * =============================================================================
 * TRIAGE RESULT INTERPRETATION
 * =============================================================================
 */

/*
 * @output Boolean — true if VIA triage was positive
 * @guidance VIA positive → proceed to treatment assessment
 */
define "VIA Triage Is Positive":
  "Triage Has Been Performed"
    and Common."Most Recent VIA Is Positive"

/*
 * @output Boolean — true if VIA triage was negative
 * @guidance VIA negative → schedule follow-up HPV retest
 *           General: 24 months (WHO Rec 11)
 *           WLHIV: 12 months (WHO Rec 31)
 */
define "VIA Triage Is Negative":
  "Triage Has Been Performed"
    and not Common."Most Recent VIA Is Positive"

/*
 * =============================================================================
 * SUSPICIOUS FOR CANCER — Referral pathway
 * =============================================================================
 *
 * @guidance In all algorithms, if VIA or colposcopy reveals findings
 *           suspicious for invasive cancer, the patient must be referred
 *           for definitive diagnosis and staging. This bypasses triage/treatment.
 *
 * Note: "Suspicious for cancer" is a clinical judgment during VIA. In OpenMRS,
 * this would be recorded as a separate observation or as a specific coded value
 * on the VIA result. We model it as a distinct observation concept.
 *
 * CIEL concept needed (not yet loaded):
 *   - CIEL 159393: Cervical cancer screening outcome
 *     or a custom concept for "suspicious for cancer" finding
 *
 * For now, we check for an active cervical cancer condition as a proxy.
 * When the concept is loaded, this definition will be updated to check
 * the VIA observation value directly.
 */

/*
 * @output Boolean — true if findings are suspicious for cancer
 * @pseudocode Currently uses cervical cancer diagnosis as proxy;
 *             will be refined when suspicious-for-cancer observation concept is loaded
 */
define "Suspicious For Cancer":
  Common."Has Cervical Cancer Diagnosis"

/*
 * =============================================================================
 * TRIAGE ROUTING — Where does the patient go next?
 * =============================================================================
 */

/*
 * @output Boolean — true if patient should proceed to treatment assessment
 * @pseudocode VIA triage positive AND not suspicious for cancer
 */
define "Proceed To Treatment":
  "VIA Triage Is Positive"
    and not "Suspicious For Cancer"

/*
 * @output Boolean — true if patient should be scheduled for follow-up retest
 * @pseudocode VIA triage negative AND not suspicious for cancer
 */
define "Proceed To Follow Up Retest":
  "VIA Triage Is Negative"
    and not "Suspicious For Cancer"

/*
 * @output Boolean — true if patient needs oncology referral
 */
define "Needs Referral":
  "Suspicious For Cancer"

/*
 * =============================================================================
 * RECOMMENDED ACTION — Triage-specific guidance
 * =============================================================================
 */

/*
 * @output String — the recommended triage action
 */
define "Triage Recommended Action":
  case
    when "Suspicious For Cancer"
      then 'Findings suspicious for invasive cancer — refer for diagnosis and staging'

    when "Triage Is Indicated"
      then 'Perform VIA triage assessment'

    when "Proceed To Treatment"
      then 'VIA positive — proceed to treatment eligibility assessment (see TreatmentDecision)'

    when "Proceed To Follow Up Retest"
      then 'VIA negative — schedule HPV DNA retest in '
           + ToString(Common."Post Triage Negative Retest Months")
           + ' months'

    when not Common."Most Recent HPV Test Is Positive"
      then 'No triage indicated — HPV test is not positive'

    else 'Unable to determine triage recommendation'
  end

/*
 * @output String — triage status for downstream routing
 */
define "Triage Status":
  case
    when "Suspicious For Cancer" then 'refer-oncology'
    when "Triage Is Indicated" then 'awaiting-triage'
    when "Proceed To Treatment" then 'triage-positive'
    when "Proceed To Follow Up Retest" then 'triage-negative'
    when not Common."Most Recent HPV Test Is Positive" then 'not-indicated'
    else 'unknown'
  end

/*
 * =============================================================================
 * ALGORITHM EXTENSION POINTS
 * =============================================================================
 *
 * The following definitions are stubs for future multi-algorithm support.
 * Currently only Algorithm 5 (VIA triage) is implemented.
 *
 * Algorithm 4: HPV16/18 genotyping triage
 *   - Requires: HPV genotyping observation concepts
 *   - Logic: HPV16/18+ → treat directly; other HPV+ → VIA triage
 *
 * Algorithm 6: Colposcopy triage
 *   - Requires: Colposcopy finding observation concepts
 *   - Logic: CIN1+ → treat; normal colposcopy → retest at 12 months
 *
 * Algorithm 7: Cytology + colposcopy triage
 *   - Requires: Cytology result concepts (ASCUS, LSIL, HSIL+)
 *   - Logic: HSIL+ → colposcopy → CIN1+ → treat
 */

/*
 * @output String — which triage algorithm is active
 * @guidance Currently hardcoded to Algorithm 5; will be parameterized
 *           when multi-algorithm support is added
 */
define "Active Triage Algorithm":
  'Algorithm 5 — HPV DNA + VIA Triage'
