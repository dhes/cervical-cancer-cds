# Cervical Cancer Follow-Up — Post-Treatment and Post-Triage Scheduling - Cervical Cancer Screening CDS for OpenMRS v0.1.0

* [**Table of Contents**](toc.md)
* [**Artifacts Summary**](artifacts.md)
* **Cervical Cancer Follow-Up — Post-Treatment and Post-Triage Scheduling**

## PlanDefinition: Cervical Cancer Follow-Up — Post-Treatment and Post-Triage Scheduling (Experimental) 

| | |
| :--- | :--- |
| *Official URL*:https://hopenahealth.com/fhir/cervical-cancer-cds/PlanDefinition/CervicalCancerFollowUp | *Version*:0.1.0 |
| Draft as of 2026-03-08 | *Computable Name*:CervicalCancerFollowUp |
| **Usage:**Clinical Focus: Cancer cervix screening | |
| **Copyright/Legal**: Copyright 2026 Hopena Health. License: Apache 2.0 | |

 
Clinical decision support rule for follow-up scheduling after cervical cancer treatment or triage-negative result. Manages post-treatment HPV DNA retest timing (12 months for both populations), post-triage-negative retest timing (12 months WLHIV, 24 months general), WLHIV double follow-up tracking (two consecutive negative HPV retests), return-to-routine-screening criteria, and re-entry to triage/treatment when follow-up HPV retest is positive. 

 
To ensure timely follow-up after cervical cancer treatment or triage-negative results, preventing loss to follow-up in the screening cascade. Manages population-specific follow-up intervals and tracks WLHIV double follow-up requirements. 

**Exception generating Narrative: unexpected non-end of element null::a at line 166 column 55**



## Resource Content

```json
{
  "resourceType" : "PlanDefinition",
  "id" : "CervicalCancerFollowUp",
  "url" : "https://hopenahealth.com/fhir/cervical-cancer-cds/PlanDefinition/CervicalCancerFollowUp",
  "version" : "0.1.0",
  "name" : "CervicalCancerFollowUp",
  "title" : "Cervical Cancer Follow-Up — Post-Treatment and Post-Triage Scheduling",
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
  "description" : "Clinical decision support rule for follow-up scheduling after cervical cancer treatment or triage-negative result. Manages post-treatment HPV DNA retest timing (12 months for both populations), post-triage-negative retest timing (12 months WLHIV, 24 months general), WLHIV double follow-up tracking (two consecutive negative HPV retests), return-to-routine-screening criteria, and re-entry to triage/treatment when follow-up HPV retest is positive.",
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
  }],
  "jurisdiction" : [{
    "coding" : [{
      "system" : "http://unstats.un.org/unsd/methods/m49/m49.htm",
      "code" : "001"
    }]
  }],
  "purpose" : "To ensure timely follow-up after cervical cancer treatment or triage-negative results, preventing loss to follow-up in the screening cascade. Manages population-specific follow-up intervals and tracks WLHIV double follow-up requirements.",
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
    "display" : "General: Recs 11 (post-triage-neg 24mo), 12 (post-colp-normal), 13 (post-treatment 12mo). WLHIV: Recs 31 (post-triage-neg 12mo), 32 (post-colp-normal), 33 (post-treatment double follow-up).",
    "url" : "https://www.who.int/publications/i/item/9789240030824",
    "document" : {
      "url" : "https://www.who.int/publications/i/item/9789240030824"
    }
  },
  {
    "type" : "composed-of",
    "display" : "Upstream: Treated patients enter post-treatment follow-up",
    "resource" : "https://hopenahealth.com/fhir/cervical-cancer-cds/PlanDefinition/CervicalCancerTreatment|0.1.0"
  },
  {
    "type" : "composed-of",
    "display" : "Upstream: Triage-negative patients enter post-triage follow-up",
    "resource" : "https://hopenahealth.com/fhir/cervical-cancer-cds/PlanDefinition/CervicalCancerTriage|0.1.0"
  }],
  "library" : ["https://hopenahealth.com/fhir/cervical-cancer-cds/Library/CervicalCancerFollowUpDecision|0.1.0"],
  "action" : [{
    "title" : "Follow-Up Assessment",
    "description" : "Evaluate follow-up status for women with active post-treatment or post-triage-negative follow-up",
    "trigger" : [{
      "type" : "named-event",
      "name" : "patient-view"
    }],
    "condition" : [{
      "kind" : "applicability",
      "expression" : {
        "language" : "text/cql-identifier",
        "expression" : "Has Active Follow Up",
        "reference" : "Library/CervicalCancerFollowUpDecision"
      }
    }],
    "action" : [{
      "id" : "retest-positive-reenter",
      "title" : "Follow-Up HPV Retest Positive — Re-enter Cascade",
      "description" : "Post-treatment or post-triage HPV retest is positive — patient must re-enter the triage/treatment pathway",
      "priority" : "urgent",
      "condition" : [{
        "kind" : "applicability",
        "expression" : {
          "language" : "text/cql-identifier",
          "expression" : "Post Treatment Retest Is Positive",
          "reference" : "Library/CervicalCancerFollowUpDecision"
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
          "expression" : "Follow Up Recommended Action",
          "reference" : "Library/CervicalCancerFollowUpDecision"
        }
      }]
    },
    {
      "id" : "post-treatment-retest-due",
      "title" : "Post-Treatment HPV Retest Due",
      "description" : "12 months have elapsed since treatment — HPV DNA retest is now due",
      "priority" : "routine",
      "condition" : [{
        "kind" : "applicability",
        "expression" : {
          "language" : "text/cql-identifier",
          "expression" : "Post Treatment Retest Is Due",
          "reference" : "Library/CervicalCancerFollowUpDecision"
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
          "expression" : "Follow Up Recommended Action",
          "reference" : "Library/CervicalCancerFollowUpDecision"
        }
      }]
    },
    {
      "id" : "post-treatment-retest-approaching",
      "title" : "Post-Treatment HPV Retest Approaching",
      "description" : "Post-treatment retest is approaching (within 2 months) — schedule the follow-up visit",
      "priority" : "routine",
      "condition" : [{
        "kind" : "applicability",
        "expression" : {
          "language" : "text/cql-identifier",
          "expression" : "Post Treatment Retest Is Approaching",
          "reference" : "Library/CervicalCancerFollowUpDecision"
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
          "expression" : "Follow Up Recommended Action",
          "reference" : "Library/CervicalCancerFollowUpDecision"
        }
      }]
    },
    {
      "id" : "wlhiv-second-retest",
      "title" : "WLHIV Double Follow-Up — Second Retest Needed",
      "description" : "WLHIV patient had first negative post-treatment HPV retest — second retest at 12 months required before return to routine screening (WHO Rec 33)",
      "priority" : "routine",
      "condition" : [{
        "kind" : "applicability",
        "expression" : {
          "language" : "text/cql-identifier",
          "expression" : "WLHIV Needs Second Follow Up Test",
          "reference" : "Library/CervicalCancerFollowUpDecision"
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
          "expression" : "Follow Up Recommended Action",
          "reference" : "Library/CervicalCancerFollowUpDecision"
        }
      }]
    },
    {
      "id" : "post-triage-negative-retest-due",
      "title" : "Post-Triage-Negative HPV Retest Due",
      "description" : "HPV+/VIA- patient's follow-up interval has elapsed — HPV DNA retest is due (12 months WLHIV, 24 months general)",
      "priority" : "routine",
      "condition" : [{
        "kind" : "applicability",
        "expression" : {
          "language" : "text/cql-identifier",
          "expression" : "Post Triage Negative Retest Is Due",
          "reference" : "Library/CervicalCancerFollowUpDecision"
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
          "expression" : "Follow Up Recommended Action",
          "reference" : "Library/CervicalCancerFollowUpDecision"
        }
      }]
    },
    {
      "id" : "post-triage-negative-waiting",
      "title" : "Post-Triage-Negative — Awaiting Retest Interval",
      "description" : "HPV+/VIA- patient is in the waiting period before follow-up HPV retest is due",
      "priority" : "routine",
      "condition" : [{
        "kind" : "applicability",
        "expression" : {
          "language" : "text/cql-identifier",
          "expression" : "Is Post Triage Negative",
          "reference" : "Library/CervicalCancerFollowUpDecision"
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
          "expression" : "Follow Up Recommended Action",
          "reference" : "Library/CervicalCancerFollowUpDecision"
        }
      }]
    },
    {
      "id" : "return-to-routine",
      "title" : "Return to Routine Screening",
      "description" : "Follow-up complete — patient can return to routine screening interval",
      "condition" : [{
        "kind" : "applicability",
        "expression" : {
          "language" : "text/cql-identifier",
          "expression" : "Can Return To Routine Screening",
          "reference" : "Library/CervicalCancerFollowUpDecision"
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
          "expression" : "Follow Up Recommended Action",
          "reference" : "Library/CervicalCancerFollowUpDecision"
        }
      }]
    }]
  }]
}

```
