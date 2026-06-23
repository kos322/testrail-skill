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
3. Run `./scripts/doctor.sh`.

Scripts load credentials internally. They print `Using env: ...` to **stderr** when using `TESTRAIL_ENV_FILE`, when the env file was found above the repo root, or when `TESTRAIL_SHOW_ENV_SOURCE=1`.

## Fast path

```bash
# Validate toolchain, env loading, and API access
./scripts/doctor.sh

# List accessible projects
./scripts/get_projects.sh | jq '(.projects // .) | map({id, name})'

# Count cases safely across paginated responses
./scripts/count_cases.sh PROJECT_ID [SECTION_ID] [--suite SUITE_ID]

# Read one page of cases
./scripts/get_cases.sh PROJECT_ID [SECTION_ID] [--suite SUITE_ID]

# Read one case
./scripts/get_case.sh CASE_ID | jq -r .title
```

## Preferred wrappers

- `scripts/doctor.sh` — setup/auth smoke check
- `scripts/get_projects.sh` — discover accessible projects
- `scripts/count_cases.sh` — reliable total-case count
- `scripts/get_cases.sh` — raw paginated case response
- `scripts/create_run.sh`, `scripts/add_result*.sh`, `scripts/close_run.sh` — run/result flows
- `scripts/get_reference_data.sh` — statuses, fields, templates, users

## Pagination

- `get_cases`, `get_runs`, `get_results*`, and similar endpoints may be paginated.
- Do **not** assume `.size` is a safe total unless `_links.next` is empty.
- Use `./scripts/count_cases.sh` when the question is “how many cases are there?”

## Windows

- Preferred: Git Bash / WSL.
- PowerShell-only environment: use thin wrappers in `powershell/` (`doctor.ps1`, `get-projects.ps1`, `count-cases.ps1`).
- PowerShell wrappers only launch bash scripts; they do **not** read `.env` themselves.

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
