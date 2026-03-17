# Cervical Cancer Screening Eligibility and Cascade Routing - Cervical Cancer Screening CDS for OpenMRS v0.1.0

* [**Table of Contents**](toc.md)
* [**Artifacts Summary**](artifacts.md)
* **Cervical Cancer Screening Eligibility and Cascade Routing**

## PlanDefinition: Cervical Cancer Screening Eligibility and Cascade Routing (Experimental) 

| | |
| :--- | :--- |
| *Official URL*:https://hopenahealth.com/fhir/cervical-cancer-cds/PlanDefinition/CervicalCancerScreening | *Version*:0.1.0 |
| Draft as of 2026-03-08 | *Computable Name*:CervicalCancerScreening |
| **Usage:**Clinical Focus: Cancer cervix screening, Gender: Female, Age Range: 25 to 50 years | |
| **Copyright/Legal**: Copyright 2026 Hopena Health. License: Apache 2.0 | |

 
Clinical decision support rule for cervical cancer screening eligibility, scheduling, and cascade routing. Implements WHO Algorithm 5 (HPV DNA + VIA triage) screening entry point for both general population and women living with HIV (WLHIV). Evaluates patient demographics, HIV status, and screening history to determine eligibility, due status, and the patient's current position in the screening cascade. 

 
To identify women eligible for cervical cancer screening and determine their current position in the WHO screening cascade, enabling timely initiation and continuity of screening services. 

**Exception generating Narrative: unexpected non-end of element null::a at line 176 column 55**



## Resource Content

```json
{
  "resourceType" : "PlanDefinition",
  "id" : "CervicalCancerScreening",
  "url" : "https://hopenahealth.com/fhir/cervical-cancer-cds/PlanDefinition/CervicalCancerScreening",
  "version" : "0.1.0",
  "name" : "CervicalCancerScreening",
  "title" : "Cervical Cancer Screening Eligibility and Cascade Routing",
  "type" : {
    "coding" : [{
      "system" : "http://terminology.hl7.org/CodeSystem/plan-definition-type",
      "code" : "eca-rule",
      "display" : "ECA Rule"
    }]
  },
  "status" : "draft",
  "experimental" : true,
  "date" : "2026-03-08",
  "publisher" : "Hopena Health",
  "contact" : [{
    "name" : "Hopena Health",
    "telecom" : [{
      "system" : "url",
      "value" : "https://hopenahealth.com"
    }]
  },
  {
    "name" : "Dan Heslinga",
    "telecom" : [{
      "system" : "url",
      "value" : "https://hopenahealth.com"
    }]
  }],
  "description" : "Clinical decision support rule for cervical cancer screening eligibility, scheduling, and cascade routing. Implements WHO Algorithm 5 (HPV DNA + VIA triage) screening entry point for both general population and women living with HIV (WLHIV). Evaluates patient demographics, HIV status, and screening history to determine eligibility, due status, and the patient's current position in the screening cascade.",
  "useContext" : [{
    "code" : {
      "system" : "http://terminology.hl7.org/CodeSystem/usage-context-type",
      "code" : "focus",
      "display" : "Clinical Focus"
    },
    "valueCodeableConcept" : {
      "coding" : [{
        "system" : "http://snomed.info/sct",
        "code" : "243877001",
        "display" : "Cancer cervix screening"
      }]
    }
  },
  {
    "code" : {
      "system" : "http://terminology.hl7.org/CodeSystem/usage-context-type",
      "code" : "gender",
      "display" : "Gender"
    },
    "valueCodeableConcept" : {
      "coding" : [{
        "system" : "http://hl7.org/fhir/administrative-gender",
        "code" : "female",
        "display" : "Female"
      }]
    }
  },
  {
    "code" : {
      "system" : "http://terminology.hl7.org/CodeSystem/usage-context-type",
      "code" : "age",
      "display" : "Age Range"
    },
    "valueRange" : {
      "low" : {
        "value" : 25,
        "unit" : "years"
      },
      "high" : {
        "value" : 50,
        "unit" : "years"
      }
    }
  }],
  "jurisdiction" : [{
    "coding" : [{
      "system" : "http://unstats.un.org/unsd/methods/m49/m49.htm",
      "code" : "001"
    }]
  }],
  "purpose" : "To identify women eligible for cervical cancer screening and determine their current position in the WHO screening cascade, enabling timely initiation and continuity of screening services.",
  "copyright" : "Copyright 2026 Hopena Health. License: Apache 2.0",
  "relatedArtifact" : [{
    "type" : "derived-from",
    "label" : "WHO Guideline",
    "display" : "WHO guideline for screening and treatment of cervical pre-cancer lesions for cervical cancer prevention, 2nd edition (2021)",
    "url" : "https://www.who.int/publications/i/item/9789240030824",
    "document" : {
      "url" : "https://www.who.int/publications/i/item/9789240030824"
    }
  },
  {
    "type" : "citation",
    "label" : "WHO Recommendations",
    "display" : "General population: Recs 1, 2, 5, 6, 7, 8, 14. WLHIV: Recs 21, 22, 25, 26, 27, 28, 34.",
    "url" : "https://www.who.int/publications/i/item/9789240030824",
    "document" : {
      "url" : "https://www.who.int/publications/i/item/9789240030824"
    }
  }],
  "library" : ["https://hopenahealth.com/fhir/cervical-cancer-cds/Library/CervicalCancerScreeningDecision|0.1.0"],
  "action" : [{
    "title" : "Cervical Cancer Screening Assessment",
    "description" : "Evaluate screening eligibility and cascade position for women presenting for care",
    "trigger" : [{
      "type" : "named-event",
      "name" : "patient-view"
    }],
    "condition" : [{
      "kind" : "applicability",
      "expression" : {
        "language" : "text/cql-identifier",
        "expression" : "Is Eligible For Screening",
        "reference" : "Library/CervicalCancerScreeningDecision"
      }
    }],
    "action" : [{
      "id" : "screening-due",
      "title" : "Screen with HPV DNA Test",
      "description" : "Patient is eligible and due for cervical cancer screening with HPV DNA test",
      "condition" : [{
        "kind" : "applicability",
        "expression" : {
          "language" : "text/cql-identifier",
          "expression" : "Is Due For Screening",
          "reference" : "Library/CervicalCancerScreeningDecision"
        }
      }],
      "type" : {
        "coding" : [{
          "system" : "http://terminology.hl7.org/CodeSystem/action-type",
          "code" : "create"
        }]
      },
      "definitionCanonical" : "#screening-communication",
      "dynamicValue" : [{
        "path" : "payload[0].contentString",
        "expression" : {
          "language" : "text/cql-identifier",
          "expression" : "Recommended Action",
          "reference" : "Library/CervicalCancerScreeningDecision"
        }
      },
      {
        "path" : "payload[1].contentString",
        "expression" : {
          "language" : "text/cql-identifier",
          "expression" : "Population Classification",
          "reference" : "Library/CervicalCancerScreeningDecision"
        }
      },
      {
        "path" : "payload[2].contentString",
        "expression" : {
          "language" : "text/cql-identifier",
          "expression" : "Screening Interval Display",
          "reference" : "Library/CervicalCancerScreeningDecision"
        }
      }]
    },
    {
      "id" : "needs-triage",
      "title" : "HPV-Positive — Needs VIA Triage",
      "description" : "Patient has a positive HPV DNA test and needs VIA triage assessment",
      "condition" : [{
        "kind" : "applicability",
        "expression" : {
          "language" : "text/cql-identifier",
          "expression" : "Needs Triage After Positive HPV",
          "reference" : "Library/CervicalCancerScreeningDecision"
        }
      }],
      "type" : {
        "coding" : [{
          "system" : "http://terminology.hl7.org/CodeSystem/action-type",
          "code" : "create"
        }]
      },
      "dynamicValue" : [{
        "path" : "payload[0].contentString",
        "expression" : {
          "language" : "text/cql-identifier",
          "expression" : "Recommended Action",
          "reference" : "Library/CervicalCancerScreeningDecision"
        }
      }]
    },
    {
      "id" : "needs-treatment",
      "title" : "HPV+ and VIA+ — Needs Treatment",
      "description" : "Patient has positive HPV DNA and positive VIA triage — treatment assessment needed",
      "condition" : [{
        "kind" : "applicability",
        "expression" : {
          "language" : "text/cql-identifier",
          "expression" : "Has Positive Triage Result",
          "reference" : "Library/CervicalCancerScreeningDecision"
        }
      }],
      "type" : {
        "coding" : [{
          "system" : "http://terminology.hl7.org/CodeSystem/action-type",
          "code" : "create"
        }]
      },
      "dynamicValue" : [{
        "path" : "payload[0].contentString",
        "expression" : {
          "language" : "text/cql-identifier",
          "expression" : "Recommended Action",
          "reference" : "Library/CervicalCancerScreeningDecision"
        }
      }]
    },
    {
      "id" : "post-treatment-followup",
      "title" : "Post-Treatment Follow-Up",
      "description" : "Patient has been treated and is in the post-treatment follow-up window",
      "condition" : [{
        "kind" : "applicability",
        "expression" : {
          "language" : "text/cql-identifier",
          "expression" : "Is In Post Treatment Follow Up",
          "reference" : "Library/CervicalCancerScreeningDecision"
        }
      }],
      "type" : {
        "coding" : [{
          "system" : "http://terminology.hl7.org/CodeSystem/action-type",
          "code" : "create"
        }]
      },
      "dynamicValue" : [{
        "path" : "payload[0].contentString",
        "expression" : {
          "language" : "text/cql-identifier",
          "expression" : "Recommended Action",
          "reference" : "Library/CervicalCancerScreeningDecision"
        }
      }]
    },
    {
      "id" : "routine-recall",
      "title" : "Routine Recall",
      "description" : "Patient's last HPV test was negative — next screening not yet due",
      "condition" : [{
        "kind" : "applicability",
        "expression" : {
          "language" : "text/cql-identifier",
          "expression" : "Most Recent HPV Test Is Negative",
          "reference" : "Library/CervicalCancerScreeningDecision"
        }
      }],
      "type" : {
        "coding" : [{
          "system" : "http://terminology.hl7.org/CodeSystem/action-type",
          "code" : "create"
        }]
      },
      "dynamicValue" : [{
        "path" : "payload[0].contentString",
        "expression" : {
          "language" : "text/cql-identifier",
          "expression" : "Recommended Action",
          "reference" : "Library/CervicalCancerScreeningDecision"
        }
      }]
    }]
  }]
}

```
