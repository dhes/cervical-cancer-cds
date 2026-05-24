# Cervical Cancer Screening DAK (Working Draft)

## Status

**v2 scaffold-restart, in progress (2026-05).** v1 work — an OpenMRS-targeted CDS implementation with 5 CQL libraries, 4 PlanDefinitions, and 82/82 passing assertions — is preserved on the `v1-archive` branch (`git checkout v1-archive`). The `main` branch has been rescaffolded against the WHO `smart-dak-empty` template (CC BY 4.0) with Hopena Health identity and a non-endorsement disclaimer; v2 content authoring is the next phase.

This is an **unofficial**, in-progress draft. Not WHO-endorsed.

## Where the project context lives

Persistent project context (role framing, scope decisions, L4 direction, trajectory with WHO contacts, methodology references) is maintained in the user's Claude memory directory, not in this file:

```
~/.claude/projects/-Users-danheslinga-projects/memory/
```

See `MEMORY.md` in that directory for the index. Read those files at the start of any session involving this repo.

## v2 scope (first pass)

- **L1:** WHO cervical cancer screening guideline (2021 + updates), Algorithm 5 (HPV DNA + VIA triage), narrowed to **Eligibility Decision** and **Needs Screening Decision** only.
- **L2:** Minimal-upfront — single persona (CHW/facility nurse, OpenSRP-shaped, registration assumed done), two decision tables (Markdown, not DMN), authored data dictionary patterned on WHO HIV DAK shape (no published WHO cervical cancer DAK to inherit from).
- **L3:** FHIR profiles, ValueSets, Questionnaires, PlanDefinitions, CQL libraries authored against the v1 scope.
- **L4:** Open Health Stack (OHS) / OpenSRP Android FHIR SDK. (v1 work targeted OpenMRS; the L4 pivot is one of the central reasons for v2.)

## Repo layout (post-scaffold-restart)

The directory structure now follows `smart-dak-empty` conventions:

- `sushi-config.yaml` — IG configuration. Identity fields (id, canonical, publisher, title) customized for Hopena Health; structural conformance to smart-dak-empty preserved (page set, dependency on `smart.who.int.base`).
- `ig.ini` — IG Publisher entry point.
- `input/pagecontent/*.md` — narrative pages (index, personas, scenarios, business-processes, dictionary, decision-logic, etc.). Most still contain smart-dak-empty placeholders; v1 work fills them in.
- `input/fsh/` — FSH source skeleton (profiles, valuesets, libraries, plandefinitions, questionnaires, etc.).
- `input/cql/` — CQL libraries (currently empty; gitignored placeholder).
- `_gencontinuous.sh`, `_genonce.sh`, `_updatePublisher.sh` — IG build scripts.
- `.github/workflows/` — current CI/CD workflows; gh-pages deployment is moot (GitHub Pages is unpublished while v2 is in flight).

## Build

```bash
./_updatePublisher.sh -y
./_genonce.sh
```

Output: `output/index.html`.

## Important context for Claude sessions

- **GitHub Pages is intentionally unpublished** (Settings → Pages, Source = None). Do not propose re-enabling without explicit user direction; rendered IG output appearing on the public web is what creates WHO-endorsement-confusion risk. Re-enable only after v2 content is properly disclaimed and branded.
- **`publisher` is Hopena Health, not WHO**, and `canonical` is `hopena.info`, not `smart.who.int`. These identity changes are deliberate (structural-vs-identity separation). Do not "fix" them back to WHO defaults.
- **v1 work is on `v1-archive` branch** — when prior CQL or PlanDefinition logic would be useful as reference, `git show v1-archive:path/to/file` retrieves it without merging. Do not propose merging v1-archive into main.
- See `~/.claude/projects/-Users-danheslinga-projects/memory/` for full project context, scope discipline, WHO contacts, and methodology decisions.
