---
name: testrail-api
description: TestRail REST API for test management. Use when user mentions "TestRail",
  "test cases", "test runs", "test results", or test management operations.
---

# TestRail API Skill

Direct TestRail REST API integration through repository-local bash wrappers.

## Setup

1. Copy `.env.example` to `.env`, or set `TESTRAIL_ENV_FILE` to an existing env file.
2. Fill in `TESTRAIL_URL`, `TESTRAIL_USER`, and `TESTRAIL_API_KEY`.
3. Run `./scripts/doctor.sh` only if setup/auth is unknown or failing.

Scripts load credentials internally. They print `Using env: ...` to **stderr** when using `TESTRAIL_ENV_FILE`, when the env file was found above the repo root, or when `TESTRAIL_SHOW_ENV_SOURCE=1`.

## Decision tree

- **Known `PROJECT_ID` + simple read-only question:** call the direct wrapper immediately.
- **Unknown `PROJECT_ID`:** call `./scripts/get_projects.sh`.
- **Env/auth/setup problem or first-time installation:** call `./scripts/doctor.sh`.

## Common queries

```bash
# Known project ID: total case count
./scripts/count_cases.sh PROJECT_ID [SECTION_ID] [--suite SUITE_ID]

# Known project ID: full case list with auto-pagination
./scripts/list_cases.sh PROJECT_ID [SECTION_ID] [--suite SUITE_ID]

# Known project ID: raw paginated case page
./scripts/get_cases.sh PROJECT_ID [SECTION_ID] [--suite SUITE_ID]

# Any time: read one case
./scripts/get_case.sh CASE_ID | jq -r .title

# Single field without manual JSON parsing
./scripts/get_case_field.sh CASE_ID FIELD

# Precondition shortcut
./scripts/get_case_precondition.sh CASE_ID

# Unknown project ID: discover accessible projects
./scripts/get_projects.sh | jq '(.projects // .) | map({id, name})'

# Setup/auth problem: validate env and access
./scripts/doctor.sh
```

## Preferred wrappers

- `scripts/count_cases.sh` — reliable total-case count
- `scripts/list_cases.sh` — full case list with auto-pagination
- `scripts/get_cases.sh` — raw paginated case response
- `scripts/get_case.sh` — single case lookup
- `scripts/get_case_field.sh` — single field lookup
- `scripts/get_case_precondition.sh` — precondition shortcut
- `scripts/get_projects.sh` — discover accessible projects
- `scripts/doctor.sh` — setup/auth smoke check
- `scripts/create_run.sh`, `scripts/add_result*.sh`, `scripts/close_run.sh` — run/result flows
- `scripts/get_reference_data.sh` — statuses, fields, templates, users

## Output contracts

| Intent | Command | Output |
| --- | --- | --- |
| total case count | `count-cases` | plain integer |
| case list | `list-cases` | plain text by default: `C{id}: {title}` |
| structured case list | `list-cases --format json` | JSON object with `count` and `cases` |
| one case | `get-case` | JSON case object |
| one case field | `get-case-field` | plain scalar/string or compact JSON for arrays/objects |
| case precondition | `get-case-precondition` | plain text / raw field value |

## Pagination

- `get_cases`, `get_runs`, `get_results*`, and similar endpoints may be paginated.
- Do **not** assume `.size` is a safe total unless `_links.next` is empty.
- Use `./scripts/count_cases.sh` when the question is “how many cases are there?”

## Windows

- Preferred: Git Bash / WSL.
- PowerShell-only environment: use thin wrappers in `powershell/`.
- PowerShell wrappers only launch bash scripts; they do **not** read `.env` themselves.

```powershell
.\powershell\count-cases.ps1 1
.\powershell\list-cases.ps1 1
.\powershell\list-cases.ps1 1 --format json
.\powershell\get-case.ps1 93
.\powershell\get-case-field.ps1 2 custom_preconds
.\powershell\get-case-precondition.ps1 2
.\powershell\get-cases.ps1 1 10 --suite 1
.\powershell\get-sections.ps1 1 1
.\powershell\get-runs.ps1 1
```

## On-demand docs

- `scripts/README.md` — script-by-script usage
- `docs/api-reference.md` — endpoint notes and payload shapes
- `docs/troubleshooting.md` — setup and auth failures
- `docs/agent-guide.md` — agent-specific execution guidance
- `docs/maintenance/endpoint-status.md` — maintenance snapshot, not runtime guidance

## Examples

- `examples/workflow_ci.sh`
- `examples/workflow_plans_milestones.sh`
- `examples/workflow_attachments.sh`

Official API docs: https://support.testrail.com/hc/en-us/categories/7076541806228-API-Manual
