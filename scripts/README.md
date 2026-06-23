# TestRail Scripts

Ready-to-use bash wrappers for common TestRail operations.

## Prerequisites

Create credentials at the **repository root**:

```bash
cp .env.example .env
# Edit .env with your TestRail URL, email, and API key
```

Alternative:

```bash
export TESTRAIL_ENV_FILE=/path/to/.env
```

Scripts load credentials automatically. They print `Using env: ...` to **stderr** for nonstandard env discovery (or when `TESTRAIL_SHOW_ENV_SOURCE=1`) so stdout stays JSON-friendly.

## First commands to run

```bash
./doctor.sh
./get_projects.sh | jq '(.projects // .) | map({id, name})'
./count_cases.sh 1
```

## PowerShell-only environments

If Bash is not your primary shell on Windows, use the thin wrappers in `../powershell/`:

```powershell
.\powershell\doctor.ps1
.\powershell\get-projects.ps1
.\powershell\count-cases.ps1 1
```

The PowerShell wrappers only launch the bash scripts. They do not parse `.env` themselves.

## Helper scripts

### `doctor.sh`

Validate env loading, command availability, and authenticated API access.

```bash
./doctor.sh | jq .
```

### `get_projects.sh`

List projects accessible to the current account.

```bash
./get_projects.sh | jq '(.projects // .) | map({id, name})'
```

### `count_cases.sh`

Count cases safely across paginated responses.

```bash
./count_cases.sh PROJECT_ID [SECTION_ID] [--suite SUITE_ID]
```

Examples:

```bash
./count_cases.sh 1
./count_cases.sh 1 10
./count_cases.sh 1 10 --suite 1
```

## Read scripts

```bash
./get_project.sh PROJECT_ID
./get_sections.sh PROJECT_ID SUITE_ID
./get_case.sh CASE_ID
./get_cases.sh PROJECT_ID [SECTION_ID] [--suite SUITE_ID] [--limit LIMIT] [--offset OFFSET]
./get_runs.sh PROJECT_ID
./get_test.sh TEST_ID
./get_results.sh TEST_ID
./get_results_for_case.sh RUN_ID CASE_ID
./get_results_for_run.sh RUN_ID
./get_plans.sh PROJECT_ID
./get_milestones.sh PROJECT_ID
./get_reference_data.sh RESOURCE [ARG]
./get_attachments.sh case CASE_ID
./get_attachments.sh test TEST_ID
```

### `get_cases.sh`

Returns the raw paginated `get_cases` response.

```bash
./get_cases.sh 1
./get_cases.sh 1 10
./get_cases.sh 1 10 --suite 1
./get_cases.sh 1 --limit 100 --offset 0
```

**Important:** if you need the total number of cases, use `count_cases.sh`. Do not assume `.size` is the final total unless `_links.next` is empty.

### `get_reference_data.sh`

Supported resources:

- `statuses`
- `case_fields`
- `priorities`
- `case_types`
- `templates PROJECT_ID`
- `result_fields`
- `users`
- `user USER_ID`
- `user_by_email EMAIL`

Examples:

```bash
./get_reference_data.sh statuses | jq 'map(.label)'
./get_reference_data.sh templates 1 | jq 'map(.name)'
./get_reference_data.sh user 1 | jq '{id, name, email}'
```

## Write scripts

```bash
./create_run.sh PROJECT_ID SUITE_ID NAME [CASE_IDS]
./close_run.sh RUN_ID
./update_run.sh RUN_ID NAME [DESCRIPTION]
./update_case.sh CASE_ID TITLE [PRIORITY_ID]
./delete_case.sh CASE_ID
./add_result.sh TEST_ID STATUS_ID COMMENT [ELAPSED]
./add_result_for_case.sh RUN_ID CASE_ID STATUS_ID COMMENT [ELAPSED]
./bulk_results.sh RUN_ID RESULTS_FILE
./add_attachment.sh case CASE_ID FILE
./add_attachment.sh result RESULT_ID FILE
./add_attachment.sh plan PLAN_ID FILE
./add_attachment.sh plan_entry PLAN_ID ENTRY_ID FILE
./delete_attachment.sh ATTACHMENT_ID
```

Examples:

```bash
./create_run.sh 1 1 "Sprint 42 Regression"
./update_run.sh 123 "Renamed run"
./add_result.sh 1042 1 "Passed in CI"
./add_result_for_case.sh 123 1 5 "Failed in Firefox" "30s"
```

## Export / workflow scripts

### `import_cases.sh`

Export cases from a section and follow pagination automatically.

```bash
./import_cases.sh PROJECT_ID SECTION_ID [OUTPUT_FILE] [--suite SUITE_ID]
```

Examples:

```bash
./import_cases.sh 1 10
./import_cases.sh 1 10 cases.json --suite 1
```

### Example workflows

```bash
../examples/workflow_ci.sh 1 1
../examples/workflow_plans_milestones.sh 1 1
../examples/workflow_attachments.sh 1 1 10
```

## Error handling

All scripts:

- use `set -euo pipefail`
- exit non-zero on failure
- keep credentials out of stdout

Example:

```bash
if ./create_run.sh 1 1 "Smoke"; then
  echo "Success"
else
  echo "Failed" >&2
fi
```

## See also

- `../SKILL.md` — lean agent entrypoint
- `../README.md` — overview and fast answers
- `../docs/api-reference.md` — payloads and endpoint notes
- `../docs/troubleshooting.md` — setup/auth issues
- `../docs/agent-guide.md` — agent-specific guidance
- `../docs/maintenance/endpoint-status.md` — maintenance snapshot
