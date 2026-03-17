/**
 * WHO Cervical Cancer CDS Demo — Build Script
 *
 * Evaluates CQL against static patient bundles and generates a standalone
 * HTML demo page. No OpenMRS or FHIR server required at runtime.
 *
 * Usage: node demo/build-demo.mjs
 * Output: demo/index.html (open in browser, screenshare on call)
 */

import { readFileSync, writeFileSync } from 'fs';
import { Library, Repository, Executor, CodeService } from 'cql-execution';
import cqlfhir from 'cql-exec-fhir';

// =============================================================================
// STATIC PATIENT BUNDLES
// =============================================================================
// Constructed from the test patient definitions. Each bundle contains exactly
// the FHIR resources that would be returned by OpenMRS for that patient.

function makePatient(id, given, family, gender, birthDate) {
  return {
    resourceType: 'Patient',
    id,
    name: [{ family, given: [given] }],
    gender,
    birthDate,
  };
}

function makeObservation(patientId, cielCode, snomedCode, snomedDisplay, valueCielCode, date) {
  const obs = {
    resourceType: 'Observation',
    id: `obs-${patientId}-${cielCode}-${date}`,
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

function makeCondition(patientId, cielCode, snomedCode, snomedDisplay, icd10Code, onsetDate) {
  return {
    resourceType: 'Condition',
    id: `cond-${patientId}-${cielCode}`,
    clinicalStatus: {
      coding: [{ system: 'http://terminology.hl7.org/CodeSystem/condition-clinical', code: 'active', display: 'Active' }],
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

function makeBundle(patient, observations, conditions) {
  const entries = [{ resource: patient }];
  for (const obs of observations) entries.push({ resource: obs });
  for (const cond of conditions) entries.push({ resource: cond });
  return { resourceType: 'Bundle', type: 'collection', entry: entries };
}

// --- The 5 demo patients: one per cascade stage + one WLHIV ---

const DEMO_PATIENTS = [
  {
    key: 'S1',
    label: 'Amara Okafor',
    age: 34,
    scenario: 'Never screened, eligible for first HPV DNA test',
    narrativeIntro: 'Amara is a 34-year-old woman visiting the health centre for the first time. She has never been screened for cervical cancer.',
    clinicalHistory: [],
    bundle: (() => {
      const id = 'demo-s1';
      return makeBundle(
        makePatient(id, 'Amara', 'Okafor', 'female', '1991-08-15'),
        [],
        []
      );
    })(),
  },
  {
    key: 'S2',
    label: 'Blessing Mutua',
    age: 34,
    scenario: 'HPV-positive, awaiting VIA triage',
    narrativeIntro: 'Blessing is 34 years old. She was screened with an HPV DNA test 2 weeks ago, and the result came back positive. She has returned to the clinic for follow-up.',
    clinicalHistory: [
      { date: '2026-03-03', event: 'HPV DNA test', result: 'Positive' },
    ],
    bundle: (() => {
      const id = 'demo-s2';
      return makeBundle(
        makePatient(id, 'Blessing', 'Mutua', 'female', '1991-05-22'),
        [
          makeObservation(id, '170145', '35904009', 'HPV DNA detection', '703', '2026-03-03'),
        ],
        []
      );
    })(),
  },
  {
    key: 'S3',
    label: 'Chioma Ndege',
    age: 35,
    scenario: 'HPV-positive, VIA-positive — needs treatment',
    narrativeIntro: 'Chioma is 35 years old. She tested HPV-positive and then underwent VIA triage, which was also positive. She needs treatment for precancerous lesions.',
    clinicalHistory: [
      { date: '2026-01-10', event: 'HPV DNA test', result: 'Positive' },
      { date: '2026-01-24', event: 'VIA triage', result: 'Positive' },
    ],
    bundle: (() => {
      const id = 'demo-s3';
      return makeBundle(
        makePatient(id, 'Chioma', 'Ndege', 'female', '1990-11-03'),
        [
          makeObservation(id, '170145', '35904009', 'HPV DNA detection', '703', '2026-01-10'),
          makeObservation(id, '151185', '243877001', 'Cervical screening', '703', '2026-01-24'),
        ],
        []
      );
    })(),
  },
  {
    key: 'S4',
    label: 'Deka Abdi',
    age: 35,
    scenario: 'Treated 10 months ago — in post-treatment follow-up',
    narrativeIntro: 'Deka is 35 years old. She was treated with thermal ablation 10 months ago after a positive HPV and VIA result. She is in the post-treatment follow-up window and approaching her 12-month retest.',
    clinicalHistory: [
      { date: '2025-03-01', event: 'HPV DNA test', result: 'Positive' },
      { date: '2025-03-15', event: 'VIA triage', result: 'Positive' },
      { date: '2025-05-17', event: 'Thermal ablation', result: 'Completed' },
    ],
    bundle: (() => {
      const id = 'demo-s4';
      return makeBundle(
        makePatient(id, 'Deka', 'Abdi', 'female', '1990-09-20'),
        [
          makeObservation(id, '170145', '35904009', 'HPV DNA detection', '703', '2025-03-01'),
          makeObservation(id, '151185', '243877001', 'Cervical screening', '703', '2025-03-15'),
          makeObservation(id, '166706', '1287592000', 'Thermocauterization', '703', '2025-05-17'),
        ],
        []
      );
    })(),
  },
  {
    key: 'S12',
    label: 'Lina Osei',
    age: 35,
    scenario: 'WLHIV — treated, first retest negative, awaiting second retest',
    narrativeIntro: 'Lina is a 35-year-old woman living with HIV. She was treated with thermal ablation over a year ago. Her first post-treatment HPV retest was negative, but because she is WLHIV, the WHO guideline requires a second retest before returning to routine screening.',
    clinicalHistory: [
      { date: '2024-06-01', event: 'HPV DNA test', result: 'Positive' },
      { date: '2024-07-01', event: 'VIA triage', result: 'Positive' },
      { date: '2024-08-08', event: 'Thermal ablation', result: 'Completed' },
      { date: '2025-08-08', event: 'HPV DNA retest (12mo)', result: 'Negative' },
    ],
    hivStatus: 'Positive (diagnosed 2019)',
    bundle: (() => {
      const id = 'demo-s12';
      return makeBundle(
        makePatient(id, 'Lina', 'Osei', 'female', '1991-01-18'),
        [
          makeObservation(id, '170145', '35904009', 'HPV DNA detection', '703', '2024-06-01'),
          makeObservation(id, '151185', '243877001', 'Cervical screening', '703', '2024-07-01'),
          makeObservation(id, '166706', '1287592000', 'Thermocauterization', '703', '2024-08-08'),
          makeObservation(id, '170145', '35904009', 'HPV DNA detection', '664', '2025-08-08'),
        ],
        [
          makeCondition(id, '138405', '86406008', 'HIV disease', 'B24', '2019-01-15'),
        ]
      );
    })(),
  },
];

// =============================================================================
// CQL EVALUATION
// =============================================================================

// Key expressions to extract from each library, with human-readable labels
const DISPLAY_EXPRESSIONS = {
  screening: {
    'Population Classification': 'Population',
    'Is Eligible For Screening': 'Eligible for screening',
    'Is Due For Screening': 'Due for screening',
    'Cascade Status': 'Cascade position',
    'Recommended Action': 'Recommendation',
    'Screening Interval Display': 'Screening interval',
  },
  triage: {
    'Triage Is Indicated': 'Triage indicated',
    'Triage Has Been Performed': 'Triage performed',
    'VIA Triage Is Positive': 'VIA positive',
    'VIA Triage Is Negative': 'VIA negative',
    'Triage Recommended Action': 'Triage recommendation',
    'Triage Status': 'Triage status',
  },
  treatment: {
    'Treatment Is Indicated': 'Treatment indicated',
    'Treatment Recommendation': 'Treatment recommendation',
    'Most Recent Treatment Type': 'Treatment type',
    'Was Treated With Ablation': 'Treated with ablation',
    'Treatment Status': 'Treatment status',
  },
  followUp: {
    'Is In Post Treatment Follow Up Window': 'In follow-up window',
    'Months Since Treatment': 'Months since treatment',
    'Post Treatment Retest Is Due': 'Retest due',
    'Post Treatment Retest Is Approaching': 'Retest approaching',
    'Post Treatment Retest Is Negative': 'Retest negative',
    'Post Treatment Retest Is Positive': 'Retest positive',
    'Requires Double Follow Up': 'Requires double follow-up (WLHIV)',
    'WLHIV Needs Second Follow Up Test': 'Needs second retest',
    'Has Active Follow Up': 'Active follow-up',
    'Follow Up Recommended Action': 'Follow-up recommendation',
    'Follow Up Status': 'Follow-up status',
  },
};

async function evaluatePatient(libs, bundle, patientId) {
  const results = {};

  for (const [libName, lib] of Object.entries(libs)) {
    const patientSource = cqlfhir.PatientSource.FHIRv401();
    patientSource.loadBundles([bundle]);

    const executor = new Executor(lib, new CodeService({}));
    const execResults = await executor.exec(patientSource);
    const pr = execResults.patientResults[patientId];
    if (!pr) continue;

    const expressions = DISPLAY_EXPRESSIONS[libName] || {};
    for (const [expr, label] of Object.entries(expressions)) {
      const val = pr[expr];
      if (val !== undefined && val !== null) {
        results[expr] = { label, value: val, library: libName };
      }
    }
  }

  return results;
}

// =============================================================================
// HTML GENERATION
// =============================================================================

function formatValue(val) {
  if (typeof val === 'boolean') return val ? 'Yes' : 'No';
  if (typeof val === 'number') return String(val);
  if (typeof val === 'string') return val;
  if (typeof val === 'object') return JSON.stringify(val);
  return String(val);
}

function cascadeStatusToStep(status) {
  const map = {
    'due-for-screening': { step: 1, label: 'Screen', color: '#2196F3' },
    'needs-triage': { step: 2, label: 'Triage', color: '#FF9800' },
    'needs-treatment': { step: 3, label: 'Treat', color: '#f44336' },
    'post-treatment-follow-up': { step: 4, label: 'Follow-up', color: '#9C27B0' },
    'triage-negative-follow-up': { step: 4, label: 'Follow-up', color: '#9C27B0' },
    'routine-recall': { step: 5, label: 'Recall', color: '#4CAF50' },
    'not-eligible': { step: 0, label: 'Not eligible', color: '#9E9E9E' },
  };
  return map[status] || { step: 0, label: status, color: '#9E9E9E' };
}

function generatePatientCard(patient, results) {
  const cascadeStatus = results['Cascade Status']?.value || 'unknown';
  const cascade = cascadeStatusToStep(cascadeStatus);
  const recommendation = results['Recommended Action']?.value || '';
  const population = results['Population Classification']?.value || '';
  const followUpStatus = results['Follow Up Status']?.value;
  const treatmentStatus = results['Treatment Status']?.value;
  const triageStatus = results['Triage Status']?.value;
  const followUpRec = results['Follow Up Recommended Action']?.value;
  const triageRec = results['Triage Recommended Action']?.value;
  const treatmentRec = results['Treatment Recommendation']?.value;

  // Use the screening library's Recommended Action as the primary output.
  // Only override with a library-specific recommendation when that library
  // is actively engaged (not "not-indicated" / "no-follow-up").
  let primaryRec = recommendation;
  if (followUpStatus && followUpStatus !== 'no-follow-up' && followUpRec) {
    primaryRec = followUpRec;
  } else if (treatmentStatus && treatmentStatus !== 'not-indicated' && treatmentRec) {
    primaryRec = treatmentRec;
  } else if (triageStatus && triageStatus !== 'not-indicated' && triageRec) {
    primaryRec = triageRec;
  }

  // Clinical history timeline
  const historyHtml = patient.clinicalHistory.length > 0
    ? patient.clinicalHistory.map(h =>
        `<div class="timeline-event">
          <span class="timeline-date">${h.date}</span>
          <span class="timeline-label">${h.event}</span>
          <span class="timeline-result result-${h.result.toLowerCase()}">${h.result}</span>
        </div>`
      ).join('\n')
    : '<div class="timeline-event"><span class="timeline-label">No prior screening history</span></div>';

  // Detail rows — only show relevant non-null values
  const detailRows = [];
  const interestingExprs = [
    'Triage Status', 'Treatment Status', 'Follow Up Status',
    'Months Since Treatment', 'Requires Double Follow Up',
    'WLHIV Needs Second Follow Up Test',
  ];
  for (const expr of interestingExprs) {
    const r = results[expr];
    if (r && r.value !== null && r.value !== undefined
        && r.value !== 'not-indicated' && r.value !== 'no-follow-up') {
      detailRows.push(`<tr><td class="detail-label">${r.label}</td><td class="detail-value">${formatValue(r.value)}</td></tr>`);
    }
  }

  // Cascade step indicator
  const steps = ['Screen', 'Triage', 'Treat', 'Follow-up'];
  const stepsHtml = steps.map((s, i) => {
    const stepNum = i + 1;
    const isActive = stepNum === cascade.step;
    const isPast = stepNum < cascade.step;
    const cls = isActive ? 'step active' : isPast ? 'step past' : 'step';
    return `<div class="${cls}" ${isActive ? `style="--active-color: ${cascade.color}"` : ''}><span class="step-num">${stepNum}</span><span class="step-label">${s}</span></div>`;
  }).join('<div class="step-connector"></div>');

  return `
    <div class="patient-card" id="patient-${patient.key}">
      <div class="card-header">
        <div class="patient-identity">
          <h2>${patient.key}. ${patient.label}</h2>
          <span class="patient-age">${patient.age}yo female</span>
          ${patient.hivStatus ? `<span class="hiv-badge">HIV+</span>` : ''}
        </div>
        <div class="cascade-badge" style="background: ${cascade.color}">${cascade.label}</div>
      </div>

      <div class="cascade-steps">${stepsHtml}</div>

      <div class="card-body">
        <div class="narrative">
          <p>${patient.narrativeIntro}</p>
        </div>

        <div class="columns">
          <div class="column">
            <h3>Clinical History</h3>
            <div class="timeline">${historyHtml}</div>
            ${population ? `<div class="population-tag">${population}</div>` : ''}
          </div>
          <div class="column">
            <h3>CQL Decision Output</h3>
            <div class="recommendation-box">
              <div class="rec-icon">\u27A4</div>
              <div class="rec-text">${primaryRec}</div>
            </div>
            ${detailRows.length > 0 ? `<table class="details-table">${detailRows.join('\n')}</table>` : ''}
          </div>
        </div>
      </div>
    </div>`;
}

function generateHtml(patientCards) {
  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>WHO Cervical Cancer Screening CDS — Clinical Demo</title>
  <style>
    :root {
      --bg: #f5f5f5;
      --card-bg: #ffffff;
      --text: #1a1a1a;
      --text-secondary: #555;
      --border: #e0e0e0;
      --accent: #0077b6;
      --accent-light: #e8f4f8;
    }

    * { margin: 0; padding: 0; box-sizing: border-box; }

    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      background: var(--bg);
      color: var(--text);
      line-height: 1.5;
    }

    .header {
      background: #023047;
      color: white;
      padding: 24px 32px;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }

    .header h1 {
      font-size: 20px;
      font-weight: 600;
    }

    .header-meta {
      font-size: 13px;
      opacity: 0.8;
      text-align: right;
    }

    .header-meta a { color: #8ecae6; }

    .nav {
      background: white;
      border-bottom: 1px solid var(--border);
      padding: 0 32px;
      display: flex;
      gap: 0;
      position: sticky;
      top: 0;
      z-index: 100;
    }

    .nav button {
      padding: 12px 20px;
      background: none;
      border: none;
      border-bottom: 3px solid transparent;
      cursor: pointer;
      font-size: 14px;
      color: var(--text-secondary);
      transition: all 0.2s;
      white-space: nowrap;
    }

    .nav button:hover { color: var(--text); background: #f8f8f8; }
    .nav button.active {
      color: var(--accent);
      border-bottom-color: var(--accent);
      font-weight: 600;
    }

    .content { padding: 24px 32px; max-width: 960px; margin: 0 auto; }

    .patient-card {
      background: var(--card-bg);
      border-radius: 12px;
      box-shadow: 0 1px 3px rgba(0,0,0,0.08), 0 1px 2px rgba(0,0,0,0.04);
      margin-bottom: 24px;
      overflow: hidden;
      display: none;
    }

    .patient-card.visible { display: block; }

    .card-header {
      padding: 20px 24px;
      display: flex;
      justify-content: space-between;
      align-items: center;
      border-bottom: 1px solid var(--border);
    }

    .patient-identity { display: flex; align-items: baseline; gap: 12px; flex-wrap: wrap; }
    .patient-identity h2 { font-size: 20px; font-weight: 600; }
    .patient-age { font-size: 14px; color: var(--text-secondary); }

    .hiv-badge {
      background: #ffb703;
      color: #1a1a1a;
      padding: 2px 10px;
      border-radius: 12px;
      font-size: 12px;
      font-weight: 700;
    }

    .cascade-badge {
      color: white;
      padding: 6px 16px;
      border-radius: 20px;
      font-size: 14px;
      font-weight: 600;
      white-space: nowrap;
    }

    .cascade-steps {
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 16px 24px;
      gap: 0;
      background: #fafafa;
      border-bottom: 1px solid var(--border);
    }

    .step {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 4px;
      opacity: 0.3;
    }

    .step.past { opacity: 0.6; }

    .step.active {
      opacity: 1;
      --active-color: var(--accent);
    }

    .step-num {
      width: 28px;
      height: 28px;
      border-radius: 50%;
      background: #ccc;
      color: white;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 13px;
      font-weight: 700;
    }

    .step.active .step-num { background: var(--active-color, var(--accent)); }
    .step.past .step-num { background: #999; }

    .step-label { font-size: 11px; color: var(--text-secondary); }
    .step.active .step-label { font-weight: 600; color: var(--text); }

    .step-connector {
      width: 40px;
      height: 2px;
      background: #ddd;
      margin: 0 4px;
      margin-bottom: 18px;
    }

    .card-body { padding: 20px 24px; }

    .narrative {
      background: var(--accent-light);
      border-left: 4px solid var(--accent);
      padding: 12px 16px;
      margin-bottom: 20px;
      border-radius: 0 8px 8px 0;
      font-size: 14px;
    }

    .columns { display: grid; grid-template-columns: 1fr 1fr; gap: 24px; }

    .column h3 {
      font-size: 13px;
      text-transform: uppercase;
      letter-spacing: 0.05em;
      color: var(--text-secondary);
      margin-bottom: 12px;
    }

    .timeline { display: flex; flex-direction: column; gap: 8px; }

    .timeline-event {
      display: flex;
      gap: 8px;
      align-items: center;
      font-size: 13px;
      padding: 6px 10px;
      background: #f8f8f8;
      border-radius: 6px;
    }

    .timeline-date {
      font-family: 'SF Mono', SFMono-Regular, monospace;
      font-size: 12px;
      color: var(--text-secondary);
      white-space: nowrap;
    }

    .timeline-label { flex: 1; }

    .timeline-result {
      font-weight: 600;
      font-size: 12px;
      padding: 1px 8px;
      border-radius: 10px;
    }

    .result-positive { background: #fde8e8; color: #c62828; }
    .result-negative { background: #e8f5e9; color: #2e7d32; }
    .result-completed { background: #e3f2fd; color: #1565c0; }

    .population-tag {
      margin-top: 12px;
      font-size: 12px;
      color: var(--text-secondary);
      padding: 6px 10px;
      background: #f0f0f0;
      border-radius: 6px;
    }

    .recommendation-box {
      display: flex;
      gap: 12px;
      padding: 16px;
      background: #fff3e0;
      border: 1px solid #ffe0b2;
      border-radius: 8px;
      margin-bottom: 16px;
    }

    .rec-icon { font-size: 20px; flex-shrink: 0; }
    .rec-text { font-size: 14px; font-weight: 500; line-height: 1.5; }

    .details-table {
      width: 100%;
      font-size: 13px;
      border-collapse: collapse;
    }

    .details-table tr { border-bottom: 1px solid #f0f0f0; }
    .details-table td { padding: 6px 0; }
    .detail-label { color: var(--text-secondary); width: 55%; }
    .detail-value { font-weight: 500; }

    .footer {
      text-align: center;
      padding: 24px;
      font-size: 12px;
      color: #999;
    }

    .footer a { color: var(--accent); }

    @media (max-width: 768px) {
      .columns { grid-template-columns: 1fr; }
      .header { flex-direction: column; gap: 8px; }
      .nav { overflow-x: auto; }
    }
  </style>
</head>
<body>
  <div class="header">
    <div>
      <h1>WHO Cervical Cancer Screening CDS</h1>
      <div style="font-size: 13px; opacity: 0.7; margin-top: 4px;">Algorithm 5: HPV DNA + VIA Triage &mdash; Screen, Triage, and Treat</div>
    </div>
    <div class="header-meta">
      FHIR R4 &middot; CQL &middot; CIEL/OpenMRS<br>
      <a href="https://hopenahealth.com/fhir/cervical-cancer-cds/" target="_blank">Implementation Guide</a>
    </div>
  </div>

  <div class="nav" id="nav">
    ${DEMO_PATIENTS.map((p, i) =>
      `<button data-index="${i}" class="${i === 0 ? 'active' : ''}" onclick="showPatient(${i})">${p.key} ${p.label.split(' ')[0]}</button>`
    ).join('\n    ')}
  </div>

  <div class="content" id="content">
    ${patientCards.join('\n')}
  </div>

  <div class="footer">
    <p>
      Hopena Health &middot; CQL evaluated client-side via
      <a href="https://github.com/cqframework/cql-execution">cql-execution</a>
      &middot; 14 test patients, 82 assertions passing
    </p>
    <p style="margin-top: 4px;">
      Based on <em>WHO guideline for screening and treatment of cervical pre-cancer lesions</em>, 2nd ed. (2021)
    </p>
    <p style="margin-top: 8px; font-size: 11px; color: #bbb;">
      Demo generated ${new Date().toISOString().split('T')[0]} &middot; CQL evaluation date: Today()
    </p>
  </div>

  <script>
    function showPatient(index) {
      document.querySelectorAll('.patient-card').forEach((c, i) => {
        c.classList.toggle('visible', i === index);
      });
      document.querySelectorAll('.nav button').forEach((b, i) => {
        b.classList.toggle('active', i === index);
      });
    }
    // Show first patient on load
    showPatient(0);
  </script>
</body>
</html>`;
}

// =============================================================================
// MAIN
// =============================================================================

async function main() {
  console.log('Building WHO Cervical Cancer CDS Demo...\n');

  // Load ELM
  const load = (name) =>
    JSON.parse(readFileSync(new URL(`../elm/${name}.json`, import.meta.url), 'utf8'));

  const repo = new Repository({
    FHIRHelpers: load('FHIRHelpers'),
    CervicalCancerScreeningCommon: load('CervicalCancerScreeningCommon'),
  });

  const libs = {
    screening: new Library(load('CervicalCancerScreeningDecision'), repo),
    triage: new Library(load('CervicalCancerTriageDecision'), repo),
    treatment: new Library(load('CervicalCancerTreatmentDecision'), repo),
    followUp: new Library(load('CervicalCancerFollowUpDecision'), repo),
  };

  // Evaluate each patient
  const patientCards = [];
  for (const patient of DEMO_PATIENTS) {
    const patientId = patient.bundle.entry[0].resource.id;
    console.log(`  Evaluating ${patient.key} ${patient.label}...`);

    const results = await evaluatePatient(libs, patient.bundle, patientId);

    const cascadeStatus = results['Cascade Status']?.value || 'unknown';
    const recommendation = results['Recommended Action']?.value || 'N/A';
    console.log(`    Cascade: ${cascadeStatus}`);
    console.log(`    Recommendation: ${recommendation}\n`);

    patientCards.push(generatePatientCard(patient, results));
  }

  // Generate HTML
  const html = generateHtml(patientCards);
  const outPath = new URL('index.html', import.meta.url).pathname;
  writeFileSync(outPath, html);
  console.log(`\nDemo written to: ${outPath}`);
  console.log('Open in browser to preview.');
}

main().catch((err) => {
  console.error('Fatal error:', err);
  process.exit(1);
});
