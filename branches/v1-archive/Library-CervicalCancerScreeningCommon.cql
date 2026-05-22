/*
 * CervicalCancerScreeningCommon
 *
 * Shared definitions for cervical cancer screening CDS, implementing
 * WHO guideline for screening and treatment of cervical pre-cancer lesions
 * for cervical cancer prevention, 2nd edition (2021).
 *
 * This library provides:
 *   - Value set definitions (inline, using CIEL terminology)
 *   - Patient demographic expressions
 *   - HIV status determination
 *   - Screening history retrieval
 *   - Treatment history retrieval
 *   - Shared helper functions
 *
 * @author  Dan Heslinga / Hopena Health
 * @version 0.1.0
 * @date    2026-03-08
 *
 * Code system note:
 *   OpenMRS FHIR2 emits SNOMED CT with a trailing slash (http://snomed.info/sct/)
 *   which is non-standard. We use CIEL (https://cielterminology.org) as the
 *   primary code system for value sets, since every OpenMRS concept has a CIEL
 *   mapping and the URI is consistent.
 */

library CervicalCancerScreeningCommon version '0.1.0'

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'

/*
 * =============================================================================
 * CODE SYSTEMS
 * =============================================================================
 */

codesystem "CIEL": 'https://cielterminology.org'
codesystem "SNOMED": 'http://snomed.info/sct/'   // Note trailing slash (OpenMRS quirk)
codesystem "LOINC": 'http://loinc.org'
codesystem "ConditionClinicalStatusCodes": 'http://terminology.hl7.org/CodeSystem/condition-clinical'

/*
 * =============================================================================
 * CODES — Individual concept codes referenced directly in expressions
 * =============================================================================
 */

// Observation answer codes
code "Positive": '703' from "CIEL" display 'Positive'
code "Negative": '664' from "CIEL" display 'Negative'

// Condition clinical status
code "active": 'active' from "ConditionClinicalStatusCodes"

/*
 * =============================================================================
 * VALUE SETS — Inline definitions using CIEL codes
 * =============================================================================
 *
 * Note: These are defined inline rather than as external FHIR ValueSet resources.
 * When we package as an IG (Phase 4), these will be promoted to proper ValueSets
 * authored in FSH.
 */

// --- Screening Tests ---

/*
 * @description HPV DNA / NAT test observation codes
 *   CIEL 170145: Human papillomavirus (HPV) DNA detection (SNOMED 35904009)
 *   CIEL 159859: PCR, human papilloma virus, qualitative (legacy, SNOMED 9718006)
 */
valueset "HPV DNA Test Codes": 'urn:oid:cervical-cds:vs:hpv-dna-test'
// Expanded inline as concept list since we don't have a terminology server:
// 170145, 159859

/*
 * @description VIA / cervical screening observation codes
 *   CIEL 151185: Screening for malignant neoplasm of cervix (SNOMED 243877001)
 */
valueset "VIA Test Codes": 'urn:oid:cervical-cds:vs:via-test'
// Expanded inline: 151185

// --- Diagnoses ---

/*
 * @description HIV diagnosis codes for identifying WLHIV
 *   CIEL 138405: Human immunodeficiency virus (HIV) disease (SNOMED 86406008)
 */
valueset "HIV Diagnosis Codes": 'urn:oid:cervical-cds:vs:hiv-diagnosis'
// Expanded inline: 138405

/*
 * @description CIN diagnosis codes (all grades)
 *   CIEL 145809: CIN grade 1 (SNOMED 285836003)
 *   CIEL 145807: CIN grade 2 (SNOMED 285838002)
 *   CIEL 145806: CIN grade 3 (SNOMED 285636001)
 *   CIEL 120780: CIN general (SNOMED 285636001)
 */
valueset "CIN Diagnosis Codes": 'urn:oid:cervical-cds:vs:cin-diagnosis'
// Expanded inline: 145809, 145807, 145806, 120780

/*
 * @description Cervical cancer diagnosis
 *   CIEL 116023: Malignant neoplasm of cervix uteri (SNOMED 363354003)
 */
valueset "Cervical Cancer Diagnosis Codes": 'urn:oid:cervical-cds:vs:cervical-cancer'
// Expanded inline: 116023

// --- Treatments (recorded as Observations, since OpenMRS lacks Procedure resource) ---

/*
 * @description Treatment procedure codes (thermal ablation, cryotherapy, LEEP)
 *   CIEL 166706: Thermocauterization of cervix (SNOMED 1287592000)
 *   CIEL 162812: Cryosurgery of lesion of cervix (SNOMED 78203001)
 *   CIEL 165084: LEEP of cervix (SNOMED 23140002)
 *   CIEL 162810: Loop electrosurgical excision procedure (SNOMED 36899001)
 */
valueset "Cervical Treatment Codes": 'urn:oid:cervical-cds:vs:cervical-treatment'
// Expanded inline: 166706, 162812, 165084, 162810

/*
 * =============================================================================
 * CONCEPT DEFINITIONS — For direct code matching in retrieves
 * =============================================================================
 *
 * Since we're using inline value sets that aren't backed by a terminology
 * server, we define individual codes and use them in expressions with
 * explicit code matching.
 */

// Screening test codes
code "HPV DNA Detection Code": '170145' from "CIEL" display 'HPV DNA detection'
code "HPV PCR Qualitative Code": '159859' from "CIEL" display 'HPV PCR qualitative'
code "Cervical Screening Code": '151185' from "CIEL" display 'Screening for malignant neoplasm of cervix'

// Diagnosis codes
code "HIV Disease Code": '138405' from "CIEL" display 'HIV disease'
code "Cervical Cancer Code": '116023' from "CIEL" display 'Malignant neoplasm of cervix uteri'
code "CIN1 Code": '145809' from "CIEL" display 'CIN grade 1'
code "CIN2 Code": '145807' from "CIEL" display 'CIN grade 2'
code "CIN3 Code": '145806' from "CIEL" display 'CIN grade 3'

// Treatment codes
code "Thermal Ablation Code": '166706' from "CIEL" display 'Thermocauterization of cervix'
code "Cryotherapy Code": '162812' from "CIEL" display 'Cryosurgery of lesion of cervix'
code "LEEP Code": '165084' from "CIEL" display 'LEEP of cervix'
code "LEEP Generic Code": '162810' from "CIEL" display 'Loop electrosurgical excision procedure'

/*
 * =============================================================================
 * PATIENT DEMOGRAPHICS
 * =============================================================================
 */

context Patient

/*
 * @input Patient.gender
 * @pseudocode Patient is female
 */
define "Is Female":
  Patient.gender = 'female'

/*
 * @input Patient.birthDate
 * @pseudocode Patient age in years at time of evaluation
 */
define "Age In Years":
  AgeInYears()

/*
 * =============================================================================
 * HIV STATUS
 * =============================================================================
 *
 * @guidance WHO Recommendations 21-34 apply to WLHIV. HIV status determines:
 *   - Screening start age (25 vs 30)
 *   - Screening interval (3-5 years vs 5-10 years)
 *   - Triage recommendation (screen-triage-treat preferred for WLHIV)
 *   - Follow-up intervals (12 months vs 24 months post-triage-negative)
 *   - Post-treatment follow-up (double follow-up for WLHIV)
 */

/*
 * @input Condition where code in HIV Diagnosis Codes and clinicalStatus = active
 * @pseudocode Active HIV conditions for this patient
 */
define "Active HIV Conditions":
  [Condition] C
    where C.code.coding.code contains '138405'
      and C.clinicalStatus.coding.code contains 'active'

/*
 * @output Boolean — true if patient has active HIV diagnosis
 * @pseudocode Patient is a woman living with HIV
 */
define "Is WLHIV":
  exists("Active HIV Conditions")

/*
 * =============================================================================
 * SCREENING PARAMETERS — Population-specific thresholds
 * =============================================================================
 */

/*
 * @guidance WHO Recommendation 5 (general): start at age 30
 *           WHO Recommendation 25 (WLHIV): start at age 25
 */
define "Minimum Screening Age":
  if "Is WLHIV" then 25 else 30

/*
 * @guidance WHO Recommendation 6/26: stop after age 50 with 2 consecutive negatives
 */
define "Maximum Screening Age":
  49

/*
 * @guidance WHO Recommendation 8 (general): every 5-10 years
 *           WHO Recommendation 28 (WLHIV): every 3-5 years
 *           Using lower bound for "due" calculation (most conservative)
 */
define "Screening Interval Years":
  if "Is WLHIV" then 3 else 5

/*
 * @guidance WHO Recommendation 11 (general): retest at 24 months post-triage-negative
 *           WHO Recommendation 31 (WLHIV): retest at 12 months post-triage-negative
 */
define "Post Triage Negative Retest Months":
  if "Is WLHIV" then 12 else 24

/*
 * @guidance WHO Recommendation 13/33: retest at 12 months post-treatment (both populations)
 */
define "Post Treatment Retest Months":
  12

/*
 * =============================================================================
 * SCREENING HISTORY
 * =============================================================================
 */

/*
 * @input Observation where code matches HPV DNA test codes
 * @pseudocode All HPV DNA test results for this patient, any time
 */
define "HPV DNA Test Results":
  [Observation] O
    where O.code.coding.code contains '170145'
       or O.code.coding.code contains '159859'

/*
 * @pseudocode Most recent HPV DNA test result, by effective date
 */
define "Most Recent HPV DNA Test":
  Last(
    "HPV DNA Test Results" O
      sort by Coalesce(
        (effective as FHIR.dateTime).value,
        (effective as FHIR.Period)."start".value
      )
  )

/*
 * @output Boolean — true if most recent HPV DNA test was positive
 */
define "Most Recent HPV Test Is Positive":
  "Most Recent HPV DNA Test".value.coding.code contains '703'

/*
 * @output Date of most recent HPV DNA test
 */
define "Date Of Most Recent HPV Test":
  date from ("Most Recent HPV DNA Test".effective as FHIR.dateTime).value

/*
 * @pseudocode True if patient has ever had any HPV DNA test
 */
define "Has Ever Been Screened With HPV":
  exists("HPV DNA Test Results")

/*
 * =============================================================================
 * VIA / TRIAGE HISTORY
 * =============================================================================
 */

/*
 * @input Observation where code matches VIA/cervical screening codes
 * @pseudocode All VIA screening results for this patient
 */
define "VIA Screening Results":
  [Observation] O
    where O.code.coding.code contains '151185'

/*
 * @pseudocode Most recent VIA screening result
 */
define "Most Recent VIA Result":
  Last(
    "VIA Screening Results" O
      sort by Coalesce(
        (effective as FHIR.dateTime).value,
        (effective as FHIR.Period)."start".value
      )
  )

/*
 * @output Boolean — true if most recent VIA was positive
 */
define "Most Recent VIA Is Positive":
  "Most Recent VIA Result".value.coding.code contains '703'

/*
 * @output Date of most recent VIA
 */
define "Date Of Most Recent VIA":
  date from ("Most Recent VIA Result".effective as FHIR.dateTime).value

/*
 * =============================================================================
 * TREATMENT HISTORY
 * =============================================================================
 *
 * Treatments are stored as Observations (OpenMRS FHIR2 has no Procedure resource).
 * The Observation.code is the treatment SNOMED/CIEL code.
 */

/*
 * @input Observation where code matches cervical treatment codes
 * @pseudocode All cervical treatment events for this patient
 */
define "Cervical Treatments":
  [Observation] O
    where O.code.coding.code contains '166706'   // Thermal ablation
       or O.code.coding.code contains '162812'   // Cryotherapy
       or O.code.coding.code contains '165084'   // LEEP (cervix)
       or O.code.coding.code contains '162810'   // LEEP (generic)

/*
 * @pseudocode Most recent cervical treatment event
 */
define "Most Recent Treatment":
  Last(
    "Cervical Treatments" O
      sort by Coalesce(
        (effective as FHIR.dateTime).value,
        (effective as FHIR.Period)."start".value
      )
  )

/*
 * @output Boolean — true if patient has ever received cervical treatment
 */
define "Has Been Treated":
  exists("Cervical Treatments")

/*
 * @output Date of most recent treatment
 */
define "Date Of Most Recent Treatment":
  date from ("Most Recent Treatment".effective as FHIR.dateTime).value

/*
 * @output Number of months since most recent treatment
 */
define "Months Since Treatment":
  if "Has Been Treated"
  then months between "Date Of Most Recent Treatment" and Today()
  else null

/*
 * =============================================================================
 * CERVICAL CANCER DIAGNOSIS
 * =============================================================================
 */

/*
 * @input Condition where code matches cervical cancer codes
 * @pseudocode True if patient has a cervical cancer diagnosis
 * @guidance Patients with known cervical cancer should be referred for
 *           oncology management, not managed through screening pathway
 */
define "Has Cervical Cancer Diagnosis":
  exists(
    [Condition] C
      where C.code.coding.code contains '116023'
        and C.clinicalStatus.coding.code contains 'active'
  )

/*
 * =============================================================================
 * HELPER FUNCTIONS
 * =============================================================================
 */

/*
 * @pseudocode True if a coded value contains CIEL code 703 (Positive)
 */
define function IsPositive(value FHIR.CodeableConcept):
  value.coding.code contains '703'

/*
 * @pseudocode True if a coded value contains CIEL code 664 (Negative)
 */
define function IsNegative(value FHIR.CodeableConcept):
  value.coding.code contains '664'
