/*
 * CervicalCancerTreatmentDecision
 *
 * Treatment decision logic for cervical pre-cancer, implementing
 * WHO guideline ablation eligibility criteria and treatment modality selection.
 *
 * This library determines:
 *   - Whether treatment is indicated
 *   - Ablation eligibility (based on transformation zone assessment)
 *   - Recommended treatment modality
 *   - Need for excisional treatment or referral
 *
 * Treatment Decision Cascade:
 *   VIA positive (from TriageDecision) → Assess ablation eligibility
 *     ├── Eligible → Thermal ablation (preferred) or cryotherapy
 *     └── Not eligible → Excision (LEEP/LLETZ)
 *   Suspicious for cancer → Refer (bypasses treatment entirely)
 *
 * Key WHO guidance:
 *   - Ablation (thermal or cryo) is preferred when eligible: simpler, portable,
 *     no anesthesia, suitable for LMIC settings
 *   - LEEP/LLETZ when ablation is not eligible or available
 *   - Cold knife conization when LEEP is unavailable
 *
 * @author  Dan Heslinga / Hopena Health
 * @version 0.1.0
 * @date    2026-03-08
 */

library CervicalCancerTreatmentDecision version '0.1.0'

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'
include CervicalCancerScreeningCommon version '0.1.0' called Common

/*
 * =============================================================================
 * ADDITIONAL CODE DEFINITIONS — Treatment-specific concepts
 * =============================================================================
 *
 * Transformation zone assessment concepts are not yet loaded in OpenMRS.
 * When loaded, uncomment and use these codes.
 *
 * Potential CIEL concepts needed:
 *   - TZ Type 1 (fully ectocervical, visible)
 *   - TZ Type 2 (partially endocervical, fully visible, probe-reachable)
 *   - TZ Type 3 (extends into endocervical canal beyond view)
 *   - Suspicious for invasive/glandular disease
 *   - Lesion extends beyond probe reach
 */

codesystem "CIEL": 'https://cielterminology.org'

// Treatment codes (from Common, redeclared for direct use)
code "Thermal Ablation Code": '166706' from "CIEL" display 'Thermocauterization of cervix'
code "Cryotherapy Code": '162812' from "CIEL" display 'Cryosurgery of lesion of cervix'
code "LEEP Code": '165084' from "CIEL" display 'LEEP of cervix'
code "LEEP Generic Code": '162810' from "CIEL" display 'Loop electrosurgical excision procedure'

context Patient

/*
 * =============================================================================
 * TREATMENT INDICATION
 * =============================================================================
 *
 * @guidance Treatment is indicated when:
 *   - Algorithm 5: HPV+ AND VIA+ (triage positive)
 *   - Algorithm 2 (screen-and-treat): HPV+ (all HPV+ treated)
 *   - Algorithms 4,6,7: HPV+ AND triage-specific positive result
 *
 * Currently implementing Algorithm 5 only.
 */

/*
 * @output Boolean — true if treatment is indicated based on screening/triage results
 * @pseudocode HPV+ AND VIA+ AND no existing cervical cancer diagnosis
 */
define "Treatment Is Indicated":
  Common."Most Recent HPV Test Is Positive"
    and Common."Most Recent VIA Is Positive"
    and Common."Date Of Most Recent VIA" on or after Common."Date Of Most Recent HPV Test"
    and not Common."Has Cervical Cancer Diagnosis"
    and not Common."Has Been Treated"

/*
 * @output Boolean — true if treatment is indicated OR patient has already been treated
 *         for this episode (useful for tracking the full cascade)
 */
define "Treatment Episode Active":
  "Treatment Is Indicated"
    or (
      Common."Has Been Treated"
      and Common."Months Since Treatment" is not null
      and Common."Months Since Treatment" < 24
    )

/*
 * =============================================================================
 * ABLATION ELIGIBILITY
 * =============================================================================
 *
 * WHO criteria for ablation eligibility require a VIA assessment of the
 * transformation zone. This is a clinical judgment that cannot be fully
 * automated — the clinician must assess TZ type and lesion extent at the
 * point of care.
 *
 * What CQL CAN do:
 *   - Check for contraindications in the record (suspicion of cancer)
 *   - Present the eligibility criteria as a checklist to the clinician
 *   - Record and retrieve the ablation eligibility determination
 *
 * What CQL CANNOT do:
 *   - Determine TZ type (requires direct visualization)
 *   - Assess probe reach (requires physical examination)
 *   - Judge suspicion of invasive disease (requires clinical expertise)
 *
 * We model ablation eligibility as a point-of-care decision support
 * checklist rather than a computable determination.
 */

/*
 * @output Boolean — true if there are known contraindications to ablation
 * @pseudocode Patient has cervical cancer or CIN diagnosed
 * @guidance This catches documented contraindications. The clinician must
 *           still assess TZ type and lesion extent at the point of care.
 */
define "Has Known Contraindication To Ablation":
  Common."Has Cervical Cancer Diagnosis"

/*
 * @output Boolean — true if patient has a CIN2+ diagnosis (may influence
 *         treatment modality preference toward excision)
 * @guidance CIN2+ lesions may be better managed with excision in some
 *           clinical contexts, even if TZ is ablation-eligible
 */
define "Has CIN2 Or Higher Diagnosis":
  exists(
    [Condition] C
      where (C.code.coding.code contains '145807'    // CIN2
             or C.code.coding.code contains '145806') // CIN3
        and C.clinicalStatus.coding.code contains 'active'
  )

/*
 * @output String — ablation eligibility checklist for clinician display
 * @guidance This is NOT a computable determination. It presents the WHO
 *           criteria for the clinician to assess at the point of care.
 */
define "Ablation Eligibility Checklist":
  if "Treatment Is Indicated"
  then 'Assess ablation eligibility — ALL must be true:' +
       '\n1. No suspicion of invasive or glandular disease' +
       '\n2. Transformation zone fully visible (TZ Type 1 or 2)' +
       '\n3. Lesion does not extend into endocervical canal beyond probe reach' +
       '\n\nIf ALL criteria met → Thermal ablation or cryotherapy' +
       '\nIf ANY criterion NOT met → Excision (LEEP/LLETZ)'
  else null

/*
 * =============================================================================
 * TREATMENT MODALITY RECOMMENDATION
 * =============================================================================
 *
 * @guidance WHO preference order for ablation-eligible lesions:
 *   1. Thermal ablation (simpler, portable, battery-operated available)
 *   2. Cryotherapy (requires gas supply — CO2 or N2O)
 *
 * For ablation-ineligible lesions:
 *   1. LEEP/LLETZ (preferred excisional method)
 *   2. Cold knife conization (when LEEP unavailable)
 */

/*
 * @output String — recommended treatment modality based on available data
 * @pseudocode Decision tree incorporating known contraindications
 */
define "Treatment Recommendation":
  case
    when Common."Has Cervical Cancer Diagnosis"
      then 'Refer to oncology — cervical cancer diagnosed'

    when not "Treatment Is Indicated" and not "Treatment Episode Active"
      then 'Treatment not indicated at this time'

    when Common."Has Been Treated"
      then 'Treatment already performed — see FollowUpDecision for retest timing'

    when "Has Known Contraindication To Ablation"
      then 'Ablation contraindicated — recommend excision (LEEP/LLETZ)'

    when "Has CIN2 Or Higher Diagnosis"
      then 'CIN2+ diagnosed — consider excision (LEEP/LLETZ). ' +
           'Ablation may be acceptable if transformation zone is fully visible ' +
           'and lesion is within probe reach.'

    when "Treatment Is Indicated"
      then 'Assess transformation zone to determine ablation eligibility. ' +
           'If eligible: thermal ablation (preferred) or cryotherapy. ' +
           'If not eligible: excision (LEEP/LLETZ).'

    else 'Unable to determine treatment recommendation'
  end

/*
 * =============================================================================
 * TREATMENT HISTORY — What treatment was performed?
 * =============================================================================
 */

/*
 * @output String — the type of treatment that was most recently performed
 */
define "Most Recent Treatment Type":
  if not Common."Has Been Treated"
  then null
  else
    case
      when Common."Most Recent Treatment".code.coding.code contains '166706'
        then 'Thermal ablation (thermocauterization)'
      when Common."Most Recent Treatment".code.coding.code contains '162812'
        then 'Cryotherapy'
      when Common."Most Recent Treatment".code.coding.code contains '165084'
        then 'LEEP (loop electrosurgical excision procedure)'
      when Common."Most Recent Treatment".code.coding.code contains '162810'
        then 'Loop excision procedure'
      else 'Unknown treatment type'
    end

/*
 * @output Boolean — true if an ablative method was used (thermal ablation or cryo)
 */
define "Was Treated With Ablation":
  Common."Has Been Treated"
    and (
      Common."Most Recent Treatment".code.coding.code contains '166706'
      or Common."Most Recent Treatment".code.coding.code contains '162812'
    )

/*
 * @output Boolean — true if an excisional method was used (LEEP)
 */
define "Was Treated With Excision":
  Common."Has Been Treated"
    and (
      Common."Most Recent Treatment".code.coding.code contains '165084'
      or Common."Most Recent Treatment".code.coding.code contains '162810'
    )

/*
 * =============================================================================
 * TREATMENT STATUS — For downstream integration
 * =============================================================================
 */

/*
 * @output String — coded treatment status for integration
 */
define "Treatment Status":
  case
    when Common."Has Cervical Cancer Diagnosis" then 'refer-oncology'
    when Common."Has Been Treated" then 'treated'
    when "Treatment Is Indicated" then 'treatment-indicated'
    else 'not-indicated'
  end
