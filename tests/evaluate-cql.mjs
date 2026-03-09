/**
 * CQL Evaluation Test Runner
 *
 * Evaluates all cervical cancer screening CDS CQL libraries against
 * synthetic test patients on the OpenMRS FHIR endpoint.
 *
 * Libraries evaluated:
 *   - CervicalCancerScreeningDecision (screening eligibility, cascade position)
 *   - CervicalCancerTriageDecision (HPV+ triage routing)
 *   - CervicalCancerTreatmentDecision (ablation eligibility, treatment modality)
 *   - CervicalCancerFollowUpDecision (post-treatment/post-triage timing)
 *
 * Usage: node tests/evaluate-cql.mjs
 */

import { readFileSync } from 'fs';
import { Library, Repository, Executor, CodeService } from 'cql-execution';
import cqlfhir from 'cql-exec-fhir';

// --- Configuration ---
const FHIR_BASE = 'http://localhost/openmrs/ws/fhir2/R4';
const AUTH = 'Basic ' + Buffer.from('admin:Admin123').toString('base64');

const PATIENTS = [
  {
    id: '3d8d6e9a-45ed-430f-8716-5fbe90660785',
    name: 'S1 Amara Okafor',
    scenario: '34yo, no HIV, never screened',
    expected: {
      // ScreeningDecision
      'Is Eligible For Screening': true,
      'Is Due For Screening': true,
      'Cascade Status': 'due-for-screening',
      // TriageDecision
      'Triage Status': 'not-indicated',
      // TreatmentDecision
      'Treatment Status': 'not-indicated',
      // FollowUpDecision
      'Follow Up Status': 'no-follow-up',
    },
  },
  {
    id: '2da68420-6f5b-4fee-a341-7ff04c545cdb',
    name: 'S2 Blessing Mutua',
    scenario: '34yo, no HIV, HPV+ 2 weeks ago, no VIA yet',
    expected: {
      'Cascade Status': 'needs-triage',
      'Triage Is Indicated': true,
      'Triage Status': 'awaiting-triage',
      'Treatment Status': 'not-indicated',
      'Follow Up Status': 'no-follow-up',
    },
  },
  {
    id: '5fcb766f-37a4-42ce-8f6e-26baf4d93295',
    name: 'S3 Chioma Ndege',
    scenario: '35yo, no HIV, HPV+ then VIA+',
    expected: {
      'Cascade Status': 'needs-treatment',
      'VIA Triage Is Positive': true,
      'Proceed To Treatment': true,
      'Triage Status': 'triage-positive',
      'Treatment Is Indicated': true,
      'Treatment Status': 'treatment-indicated',
      'Follow Up Status': 'no-follow-up',
    },
  },
  {
    id: '27df8dd2-2264-446b-974b-bd1791c1a502',
    name: 'S4 Deka Abdi',
    scenario: '35yo, no HIV, treated 10 months ago',
    expected: {
      'Cascade Status': 'post-treatment-follow-up',
      'Triage Status': 'triage-positive',
      'Treatment Status': 'treated',
      'Is In Post Treatment Follow Up Window': true,
      'Has Active Follow Up': true,
      'Post Treatment Retest Is Approaching': true,
      'Follow Up Status': 'post-treatment-retest-approaching',
    },
  },
  {
    id: '81a21bdd-bdf3-4314-8a32-d71d0c8078c8',
    name: 'S5 Esther Wanjiku',
    scenario: '34yo, WLHIV, never screened',
    expected: {
      'Is Eligible For Screening': true,
      'Is Due For Screening': true,
      'Cascade Status': 'due-for-screening',
      'Triage Status': 'not-indicated',
      'Treatment Status': 'not-indicated',
      'Follow Up Status': 'no-follow-up',
    },
  },
  {
    id: '556263d5-8a30-4b5b-92ef-76a9b70376e7',
    name: 'S6 Fatima Keita',
    scenario: '25yo, no HIV — not eligible',
    expected: {
      'Is Eligible For Screening': false,
      'Cascade Status': 'not-eligible',
      'Triage Status': 'not-indicated',
      'Treatment Status': 'not-indicated',
      'Follow Up Status': 'no-follow-up',
    },
  },
  {
    id: '4bc736db-70d3-4b6a-9282-87209cae7ed4',
    name: 'S7 Grace Achieng',
    scenario: '24yo, WLHIV — not eligible (even for WLHIV)',
    expected: {
      'Is Eligible For Screening': false,
      'Cascade Status': 'not-eligible',
      'Triage Status': 'not-indicated',
      'Treatment Status': 'not-indicated',
      'Follow Up Status': 'no-follow-up',
    },
  },
  // --- Phase 3: Edge case scenarios ---
  {
    id: '49f9fd5b-4a83-43a2-ae6a-a86512814865',
    name: 'S8 Hana Bekele',
    scenario: '35yo, HPV+ VIA- (triage negative, general pop)',
    expected: {
      'Cascade Status': 'triage-negative-follow-up',
      'VIA Triage Is Negative': true,
      'Proceed To Follow Up Retest': true,
      'Triage Status': 'triage-negative',
      'Treatment Status': 'not-indicated',
      'Is Post Triage Negative': true,
      'Has Active Follow Up': true,
      'Follow Up Status': 'post-triage-negative-waiting',
    },
  },
  {
    id: '7cf601c9-cd37-4f5f-8a36-12e96339a007',
    name: 'S9 Ines Diallo',
    scenario: '36yo, treated 13 months ago (retest due)',
    expected: {
      'Cascade Status': 'post-treatment-follow-up',
      'Treatment Status': 'treated',
      'Was Treated With Ablation': true,
      'Post Treatment Retest Is Due': true,
      'Has Active Follow Up': true,
      'Follow Up Status': 'post-treatment-retest-due',
    },
  },
  {
    id: '5eeb3241-8dc3-4f13-892b-3199c389f6ad',
    name: 'S10 Joy Mwangi',
    scenario: '37yo, HPV- 21 months ago (routine recall)',
    expected: {
      'Is Eligible For Screening': true,
      'Cascade Status': 'routine-recall',
      'Triage Status': 'not-indicated',
      'Treatment Status': 'not-indicated',
      'Follow Up Status': 'no-follow-up',
    },
  },
  {
    id: '7a4319b5-32df-4aed-9bdb-0d2718ef0649',
    name: 'S11 Keza Uwimana',
    scenario: '33yo, WLHIV, HPV+ VIA- (triage negative, 12mo follow-up)',
    expected: {
      'Cascade Status': 'triage-negative-follow-up',
      'VIA Triage Is Negative': true,
      'Triage Status': 'triage-negative',
      'Treatment Status': 'not-indicated',
      'Is Post Triage Negative': true,
      'Has Active Follow Up': true,
      'Follow Up Status': 'post-triage-negative-waiting',
    },
  },
  {
    id: '57b226e1-c7ca-41a0-a96c-42d57d21b64d',
    name: 'S12 Lina Osei',
    scenario: 'WLHIV, treated, first retest negative (needs second)',
    expected: {
      'Treatment Status': 'treated',
      'Was Treated With Ablation': true,
      'Requires Double Follow Up': true,
      'WLHIV Needs Second Follow Up Test': true,
      'Has Active Follow Up': true,
      'Follow Up Status': 'wlhiv-awaiting-second-retest',
    },
  },
  {
    id: '1c8ce8a6-d27d-44da-8837-be4a1d13f778',
    name: 'S13 Miriam Tadesse',
    scenario: 'Treated, post-treatment HPV retest positive (re-enter)',
    expected: {
      'Treatment Status': 'treated',
      'Post Treatment Retest Is Positive': true,
      'Follow Up Status': 'retest-positive-reenter',
    },
  },
  {
    id: '68a545ac-831a-4c36-a779-8baff817dcc3',
    name: 'S14 Naomi Chege',
    scenario: '37yo, HPV- 6 years ago (re-screening due)',
    expected: {
      'Is Eligible For Screening': true,
      'Is Due For Screening': true,
      'Cascade Status': 'due-for-screening',
      'Triage Status': 'not-indicated',
      'Treatment Status': 'not-indicated',
      'Follow Up Status': 'no-follow-up',
    },
  },
];

// Libraries and their key expressions to display
const LIBRARY_EXPRESSIONS = {
  screening: [
    'Meets Age Criteria',
    'Is Eligible For Screening',
    'Is Due For Screening',
    'Recommended Action',
    'Cascade Status',
    'Population Classification',
  ],
  triage: [
    'Triage Is Indicated',
    'Triage Has Been Performed',
    'VIA Triage Is Positive',
    'VIA Triage Is Negative',
    'Proceed To Treatment',
    'Proceed To Follow Up Retest',
    'Triage Recommended Action',
    'Triage Status',
  ],
  treatment: [
    'Treatment Is Indicated',
    'Treatment Episode Active',
    'Has Known Contraindication To Ablation',
    'Has CIN2 Or Higher Diagnosis',
    'Treatment Recommendation',
    'Most Recent Treatment Type',
    'Was Treated With Ablation',
    'Treatment Status',
  ],
  followUp: [
    'Is In Post Treatment Follow Up Window',
    'Months Since Treatment',
    'Post Treatment Retest Is Due',
    'Post Treatment Retest Is Approaching',
    'Has HPV Test After Treatment',
    'Post Treatment Retest Is Negative',
    'Post Treatment Retest Is Positive',
    'Requires Double Follow Up',
    'WLHIV Needs Second Follow Up Test',
    'Is Post Triage Negative',
    'Has Active Follow Up',
    'Follow Up Recommended Action',
    'Follow Up Status',
  ],
};

// --- Helper: fetch from OpenMRS FHIR ---
async function fhirFetch(path) {
  const url = `${FHIR_BASE}/${path}`;
  const res = await fetch(url, {
    headers: { Authorization: AUTH, Accept: 'application/fhir+json' },
  });
  if (!res.ok) {
    throw new Error(`FHIR fetch failed: ${res.status} ${res.statusText} for ${url}`);
  }
  return res.json();
}

// --- Helper: get all data for a patient as a FHIR Bundle ---
async function getPatientBundle(patientId) {
  const [patient, obsBundle, condBundle] = await Promise.all([
    fhirFetch(`Patient/${patientId}`),
    fhirFetch(`Observation?patient=${patientId}&_count=100`),
    fhirFetch(`Condition?patient=${patientId}&_count=100`),
  ]);

  const entries = [{ resource: patient }];
  if (obsBundle.entry) {
    for (const e of obsBundle.entry) entries.push({ resource: e.resource });
  }
  if (condBundle.entry) {
    for (const e of condBundle.entry) entries.push({ resource: e.resource });
  }

  return { resourceType: 'Bundle', type: 'collection', entry: entries };
}

// --- Helper: format a value for display ---
function fmt(val) {
  if (val === null || val === undefined) return 'null';
  if (typeof val === 'object') return JSON.stringify(val).substring(0, 80);
  return String(val);
}

// --- Main ---
async function main() {
  console.log('=== Cervical Cancer Screening CDS — Full CQL Evaluation ===\n');

  // Load all ELM JSON
  const load = (name) =>
    JSON.parse(readFileSync(new URL(`../elm/${name}.json`, import.meta.url), 'utf8'));

  const fhirHelpersElm = load('FHIRHelpers');
  const commonElm = load('CervicalCancerScreeningCommon');
  const screeningElm = load('CervicalCancerScreeningDecision');
  const triageElm = load('CervicalCancerTriageDecision');
  const treatmentElm = load('CervicalCancerTreatmentDecision');
  const followUpElm = load('CervicalCancerFollowUpDecision');

  // Shared repository
  const repo = new Repository({
    FHIRHelpers: fhirHelpersElm,
    CervicalCancerScreeningCommon: commonElm,
  });

  // Build libraries
  const libs = {
    screening: new Library(screeningElm, repo),
    triage: new Library(triageElm, repo),
    treatment: new Library(treatmentElm, repo),
    followUp: new Library(followUpElm, repo),
  };

  const codeService = new CodeService({});

  let passCount = 0;
  let failCount = 0;
  let totalAssertions = 0;

  for (const pt of PATIENTS) {
    console.log(`\n${'='.repeat(70)}`);
    console.log(`${pt.name} — ${pt.scenario}`);
    console.log(`${'='.repeat(70)}`);

    try {
      const bundle = await getPatientBundle(pt.id);
      const obsCount = bundle.entry.filter((e) => e.resource.resourceType === 'Observation').length;
      const condCount = bundle.entry.filter((e) => e.resource.resourceType === 'Condition').length;
      console.log(`  Resources: ${bundle.entry.length} total (${obsCount} obs, ${condCount} cond)`);

      // Evaluate each library
      const allResults = {};

      for (const [libName, lib] of Object.entries(libs)) {
        const patientSource = cqlfhir.PatientSource.FHIRv401();
        patientSource.loadBundles([bundle]);

        const executor = new Executor(lib, codeService);
        const results = await executor.exec(patientSource);
        const pr = results.patientResults[pt.id];

        if (!pr) {
          console.log(`  ⚠️  No results from ${libName} library`);
          continue;
        }

        // Display key expressions for this library
        console.log(`\n  📋 ${libName.toUpperCase()}:`);
        for (const expr of LIBRARY_EXPRESSIONS[libName] || []) {
          const val = pr[expr];
          console.log(`    ${expr}: ${fmt(val)}`);
          allResults[expr] = val;
        }
      }

      // Check assertions across all libraries
      if (pt.expected && Object.keys(pt.expected).length > 0) {
        console.log(`\n  🧪 ASSERTIONS:`);
        for (const [key, expectedVal] of Object.entries(pt.expected)) {
          totalAssertions++;
          const actualVal = allResults[key];
          const pass = actualVal === expectedVal;
          if (pass) {
            passCount++;
            console.log(`    ✅ ${key} = ${fmt(actualVal)}`);
          } else {
            failCount++;
            console.log(`    ❌ ${key}: expected ${fmt(expectedVal)}, got ${fmt(actualVal)}`);
          }
        }
      }
    } catch (err) {
      console.log(`  ERROR: ${err.message}`);
      failCount++;
    }
  }

  // Summary
  console.log(`\n${'='.repeat(70)}`);
  console.log('SUMMARY');
  console.log(`${'='.repeat(70)}`);
  console.log(`  Patients evaluated: ${PATIENTS.length}`);
  console.log(`  Libraries evaluated: 4 (Screening, Triage, Treatment, FollowUp)`);
  console.log(`  Assertions: ${passCount}/${totalAssertions} passed`);
  if (failCount > 0) {
    console.log(`  ❌ ${failCount} failures`);
    process.exit(1);
  } else {
    console.log('  ✅ All assertions passed!');
  }
}

main().catch((err) => {
  console.error('Fatal error:', err);
  process.exit(1);
});
