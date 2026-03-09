/**
 * Creates Phase 3 synthetic test patients on OpenMRS FHIR endpoint.
 *
 * S8-S14: Edge case scenarios for triage, treatment, and follow-up logic.
 *
 * Usage: node tests/create-phase3-patients.mjs
 */

const FHIR = 'http://localhost/openmrs/ws/fhir2/R4';
const AUTH = 'Basic ' + Buffer.from('admin:Admin123').toString('base64');
const LOCATION_UUID = '1ce1b7d4-c865-4178-82b0-5932e51503d6';
const ID_TYPE_UUID = '05a29f94-c0ed-11e2-94be-8c13b969e334';

async function fhirPost(resourceType, body) {
  const res = await fetch(`${FHIR}/${resourceType}`, {
    method: 'POST',
    headers: {
      Authorization: AUTH,
      'Content-Type': 'application/fhir+json',
      Accept: 'application/fhir+json',
    },
    body: JSON.stringify(body),
  });
  const data = await res.json();
  if (!res.ok) {
    const msg = data.issue?.[0]?.diagnostics || JSON.stringify(data);
    throw new Error(`POST ${resourceType} failed (${res.status}): ${msg}`);
  }
  return data;
}

function patientResource(given, family, gender, birthDate, openmrsId) {
  return {
    resourceType: 'Patient',
    identifier: [
      {
        extension: [
          {
            url: 'http://fhir.openmrs.org/ext/patient/identifier#location',
            valueReference: {
              reference: `Location/${LOCATION_UUID}`,
              type: 'Location',
            },
          },
        ],
        use: 'official',
        type: {
          coding: [{ code: ID_TYPE_UUID }],
          text: 'OpenMRS ID',
        },
        value: openmrsId,
      },
    ],
    name: [{ family, given: [given] }],
    gender,
    birthDate,
  };
}

function observation(patientId, cielCode, snomedCode, snomedDisplay, valueCielCode, date) {
  const obs = {
    resourceType: 'Observation',
    status: 'final',
    code: {
      coding: [
        { system: 'https://cielterminology.org', code: cielCode },
        { system: 'http://snomed.info/sct/', code: snomedCode, display: snomedDisplay },
      ],
    },
    subject: { reference: `Patient/${patientId}`, type: 'Patient' },
    effectiveDateTime: `${date}T00:00:00+00:00`,
  };
  if (valueCielCode) {
    // 703 = Positive, 664 = Negative
    const snomedVal = valueCielCode === '703' ? '10828004' : '260385009';
    const display = valueCielCode === '703' ? 'Positive' : 'Negative';
    obs.valueCodeableConcept = {
      coding: [
        { system: 'https://cielterminology.org', code: valueCielCode, display },
        { system: 'http://snomed.info/sct/', code: snomedVal, display },
      ],
    };
  }
  return obs;
}

function condition(patientId, cielCode, snomedCode, snomedDisplay, icd10Code, onsetDate) {
  return {
    resourceType: 'Condition',
    clinicalStatus: {
      coding: [
        {
          system: 'http://terminology.hl7.org/CodeSystem/condition-clinical',
          code: 'active',
          display: 'Active',
        },
      ],
    },
    code: {
      coding: [
        { system: 'https://cielterminology.org', code: cielCode },
        { system: 'http://snomed.info/sct/', code: snomedCode, display: snomedDisplay },
        { system: 'http://hl7.org/fhir/sid/icd-10', code: icd10Code },
      ],
    },
    subject: { reference: `Patient/${patientId}`, type: 'Patient' },
    onsetDateTime: `${onsetDate}T00:00:00+00:00`,
  };
}

// OpenMRS IDs generated via idgen
const IDS = ['10005GR', '10005HN', '10005JL', '10005KJ', '10005LG', '10005ME', '10005NC'];

const PATIENTS = [
  {
    num: 'S8',
    given: 'Hana',
    family: 'Bekele',
    dob: '1990-07-20',
    openmrsId: IDS[0],
    scenario: 'HPV+ VIA- (triage negative, general pop)',
    observations: [
      // HPV+ on 2026-01-15
      { ciel: '170145', snomed: '35904009', display: 'HPV DNA detection', value: '703', date: '2026-01-15' },
      // VIA- on 2026-01-29
      { ciel: '151185', snomed: '243877001', display: 'Cervical screening', value: '664', date: '2026-01-29' },
    ],
    conditions: [],
  },
  {
    num: 'S9',
    given: 'Ines',
    family: 'Diallo',
    dob: '1989-09-12',
    openmrsId: IDS[1],
    scenario: 'Treated 13 months ago (general pop, retest due)',
    observations: [
      // HPV+ on 2024-12-01
      { ciel: '170145', snomed: '35904009', display: 'HPV DNA detection', value: '703', date: '2024-12-01' },
      // VIA+ on 2024-12-15
      { ciel: '151185', snomed: '243877001', display: 'Cervical screening', value: '703', date: '2024-12-15' },
      // Thermal ablation on 2025-02-08
      { ciel: '166706', snomed: '1287592000', display: 'Thermocauterization', value: '703', date: '2025-02-08' },
    ],
    conditions: [],
  },
  {
    num: 'S10',
    given: 'Joy',
    family: 'Mwangi',
    dob: '1988-11-05',
    openmrsId: IDS[2],
    scenario: 'HPV negative 21 months ago (routine recall)',
    observations: [
      // HPV- on 2024-06-15
      { ciel: '170145', snomed: '35904009', display: 'HPV DNA detection', value: '664', date: '2024-06-15' },
    ],
    conditions: [],
  },
  {
    num: 'S11',
    given: 'Keza',
    family: 'Uwimana',
    dob: '1992-03-25',
    openmrsId: IDS[3],
    scenario: 'WLHIV, HPV+ VIA- (triage negative, 12mo follow-up)',
    observations: [
      // HPV+ on 2025-12-01
      { ciel: '170145', snomed: '35904009', display: 'HPV DNA detection', value: '703', date: '2025-12-01' },
      // VIA- on 2025-12-15
      { ciel: '151185', snomed: '243877001', display: 'Cervical screening', value: '664', date: '2025-12-15' },
    ],
    conditions: [
      // HIV diagnosed 2021-06-01
      { ciel: '138405', snomed: '86406008', display: 'HIV disease', icd10: 'B24', onset: '2021-06-01' },
    ],
  },
  {
    num: 'S12',
    given: 'Lina',
    family: 'Osei',
    dob: '1991-01-18',
    openmrsId: IDS[4],
    scenario: 'WLHIV, treated, first retest negative (needs second)',
    observations: [
      // HPV+ on 2024-06-01
      { ciel: '170145', snomed: '35904009', display: 'HPV DNA detection', value: '703', date: '2024-06-01' },
      // VIA+ on 2024-07-01
      { ciel: '151185', snomed: '243877001', display: 'Cervical screening', value: '703', date: '2024-07-01' },
      // Thermal ablation on 2024-08-08
      { ciel: '166706', snomed: '1287592000', display: 'Thermocauterization', value: '703', date: '2024-08-08' },
      // Post-treatment HPV retest NEGATIVE on 2025-08-08
      { ciel: '170145', snomed: '35904009', display: 'HPV DNA detection', value: '664', date: '2025-08-08' },
    ],
    conditions: [
      { ciel: '138405', snomed: '86406008', display: 'HIV disease', icd10: 'B24', onset: '2019-01-15' },
    ],
  },
  {
    num: 'S13',
    given: 'Miriam',
    family: 'Tadesse',
    dob: '1990-04-30',
    openmrsId: IDS[5],
    scenario: 'Treated, post-treatment HPV retest positive (re-enter cascade)',
    observations: [
      // HPV+ on 2024-10-01
      { ciel: '170145', snomed: '35904009', display: 'HPV DNA detection', value: '703', date: '2024-10-01' },
      // VIA+ on 2024-11-01
      { ciel: '151185', snomed: '243877001', display: 'Cervical screening', value: '703', date: '2024-11-01' },
      // Cryotherapy on 2024-12-08
      { ciel: '162812', snomed: '78203001', display: 'Cryosurgery of cervix', value: '703', date: '2024-12-08' },
      // Post-treatment HPV retest POSITIVE on 2026-01-08
      { ciel: '170145', snomed: '35904009', display: 'HPV DNA detection', value: '703', date: '2026-01-08' },
    ],
    conditions: [],
  },
  {
    num: 'S14',
    given: 'Naomi',
    family: 'Chege',
    dob: '1988-06-14',
    openmrsId: IDS[6],
    scenario: 'HPV negative 6 years ago (re-screening due, interval elapsed)',
    observations: [
      // HPV- on 2020-03-01 (6 years ago)
      { ciel: '170145', snomed: '35904009', display: 'HPV DNA detection', value: '664', date: '2020-03-01' },
    ],
    conditions: [],
  },
];

async function main() {
  console.log('=== Creating Phase 3 Test Patients ===\n');

  const results = [];

  for (const pt of PATIENTS) {
    console.log(`--- ${pt.num} ${pt.given} ${pt.family}: ${pt.scenario} ---`);

    // Create patient
    try {
      const patientData = patientResource(pt.given, pt.family, 'female', pt.dob, pt.openmrsId);
      const created = await fhirPost('Patient', patientData);
      const patientId = created.id;
      console.log(`  Patient created: ${patientId}`);

      // Create conditions
      for (const cond of pt.conditions) {
        const condResource = condition(patientId, cond.ciel, cond.snomed, cond.display, cond.icd10, cond.onset);
        const createdCond = await fhirPost('Condition', condResource);
        console.log(`  Condition: ${cond.display} → ${createdCond.id}`);
      }

      // Create observations
      for (const obs of pt.observations) {
        const obsResource = observation(patientId, obs.ciel, obs.snomed, obs.display, obs.value, obs.date);
        const createdObs = await fhirPost('Observation', obsResource);
        console.log(`  Observation: ${obs.display} (${obs.value === '703' ? 'Positive' : 'Negative'}) ${obs.date} → ${createdObs.id}`);
      }

      results.push({ num: pt.num, name: `${pt.given} ${pt.family}`, id: patientId, scenario: pt.scenario });
    } catch (err) {
      console.log(`  ERROR: ${err.message}`);
      results.push({ num: pt.num, name: `${pt.given} ${pt.family}`, id: 'FAILED', scenario: pt.scenario });
    }
    console.log('');
  }

  // Print summary for copy-paste into test runner
  console.log('=== Patient UUIDs for test runner ===\n');
  for (const r of results) {
    console.log(`${r.num}  ${r.name.padEnd(20)} ${r.id}`);
  }
}

main().catch((err) => {
  console.error('Fatal:', err);
  process.exit(1);
});
