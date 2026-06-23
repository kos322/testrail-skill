---
name: testrail-api
description: TestRail REST API for test management. Use when user mentions "TestRail",
  "test cases", "test runs", "test results", or test management operations.
---

# TestRail API Skill

Direct TestRail REST API integration without external dependencies. Uses curl + bash.

## Quick Start

**Windows:** Use Bash tool (Git Bash/WSL). Don't translate to PowerShell.

**Setup credentials:**
1. Copy `.env.example` to `.env`
2. Fill in your TestRail URL, email, and API key
3. Scripts load `.env` automatically (credentials never exposed to LLM)

**Enable API:** TestRail → Administration → Site Settings → API → Enable API  
**Get API Key:** My Settings → API Keys → Add Key

## Security Note

**Credentials are isolated:** Scripts load `.env` internally. LLM never sees credentials in context. This prevents:
- Credential leaks in logs
- Accidental exposure in responses
- Credentials in API request history

## Core Operations

### Projects & Structure
```bash
# List projects
curl -s -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/get_projects"

# Get suites in project
curl -s -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/get_suites/PROJECT_ID"

# Get sections (folders) in suite
curl -s -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/get_sections/PROJECT_ID&suite_id=SUITE_ID"
```

### Test Cases
```bash
# Get cases in project
./scripts/get_cases.sh PROJECT_ID

# Get single case
./scripts/get_case.sh CASE_ID

# Create/update case
./examples/create_case.sh SECTION_ID
./scripts/update_case.sh CASE_ID "Updated title" 4
```

### Test Runs & Results
```bash
# Create/update runs
./scripts/create_run.sh PROJECT_ID SUITE_ID "Run name" "1,2,3"
./scripts/update_run.sh RUN_ID "Renamed run" "Updated description"

# Add results
./scripts/add_result.sh TEST_ID 1 "Passed"
./scripts/add_result_for_case.sh RUN_ID CASE_ID 1 "Passed"
./scripts/bulk_results.sh RUN_ID results.json
```

### Attachments
```bash
./scripts/add_attachment.sh case CASE_ID evidence.txt
./scripts/get_attachments.sh case CASE_ID
./scripts/delete_attachment.sh ATTACHMENT_ID
```

## Ready-to-Use Scripts

Located in `scripts/` directory. **No need to `source .env`** — scripts load credentials automatically.

- `scripts/get_case.sh CASE_ID` — Get a single case
- `scripts/get_cases.sh PROJECT_ID [SECTION_ID]` — Get test cases
- `scripts/get_project.sh PROJECT_ID` — Get a single project
- `scripts/get_sections.sh PROJECT_ID SUITE_ID` — Get sections
- `scripts/get_runs.sh PROJECT_ID` — Get project runs
- `scripts/get_test.sh TEST_ID` — Get a single test instance
- `scripts/get_results.sh TEST_ID` — Get results for a test
- `scripts/get_results_for_case.sh RUN_ID CASE_ID` — Get results for a case in a run
- `scripts/get_results_for_run.sh RUN_ID` — Get all results for a run
- `scripts/get_reference_data.sh RESOURCE [ARG]` — Get statuses, fields, priorities, templates, or user metadata
- `scripts/create_run.sh PROJECT_ID SUITE_ID NAME [CASE_IDS]` — Create test run
- `scripts/update_run.sh RUN_ID NAME [DESCRIPTION]` — Update an open run
- `scripts/close_run.sh RUN_ID` — Close completed run
- `scripts/add_result.sh TEST_ID STATUS COMMENT [ELAPSED]` — Add single result
- `scripts/add_result_for_case.sh RUN_ID CASE_ID STATUS COMMENT [ELAPSED]` — Add single result by case
- `scripts/bulk_results.sh RUN_ID RESULTS_FILE` — Bulk upload results
- `scripts/update_case.sh CASE_ID TITLE [PRIORITY_ID]` — Update a case
- `scripts/import_cases.sh PROJECT_ID SECTION_ID [OUTPUT]` — Export cases to JSON
- `scripts/add_attachment.sh RESOURCE ...` — Upload an attachment
- `scripts/get_attachments.sh RESOURCE ID` — List attachments for a case or test
- `scripts/delete_attachment.sh ATTACHMENT_ID` — Delete an attachment

**Usage:**
```bash
./scripts/get_cases.sh 1 10  # Get cases from project 1, section 10
# No source .env needed - credentials loaded inside script
```

## Status IDs

- 1 = Passed
- 2 = Blocked  
- 3 = Untested
- 4 = Retest
- 5 = Failed

Check custom statuses: `curl ... /api/v2/get_statuses`

## Common Patterns

**Create payload files:**
```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/scripts/common.sh"
load_credentials

testrail_make_temp_file PAYLOAD payload
jq -n '{field: "value"}' > "$PAYLOAD"
testrail_api POST "endpoint" -H "Content-Type: application/json" --data @"$PAYLOAD"
```

**Parse with jq:**
```bash
curl ... | jq '.cases[] | {id, title, priority_id}'
```

**Extract run ID:**
```bash
RUN_ID=$(./scripts/create_run.sh 1 5 "My Run" | jq -r '.id')
```

## More Resources

- **Detailed Examples:** `examples/` directory
  - `examples/create_case.sh` — Full case creation with custom fields
  - `examples/workflow_ci.sh` — CI integration workflow
  - `examples/workflow_plans_milestones.sh` — Disposable plan + milestone lifecycle
  - `examples/workflow_attachments.sh` — Disposable attachment lifecycle

- **API Reference:** `docs/api-reference.md` — All 50 tracked endpoints documented

- **Troubleshooting:** `docs/troubleshooting.md` — Common issues & solutions

- **For AI Agents:** `docs/agent-guide.md` — Fallback strategies, .env loading

## Guidelines

1. Always use Basic Auth: `-u "$TESTRAIL_USER:$TESTRAIL_API_KEY"`
2. URL format: `${TESTRAIL_URL}/index.php?/api/v2/ENDPOINT`
3. Custom fields: prefix with `custom_` (e.g., `custom_steps`)
4. Pagination: add `&limit=X&offset=Y`
5. Bulk operations: Use `add_results` (plural) for efficiency

## Quick Troubleshooting

```bash
# Verify credentials loaded
echo $TESTRAIL_URL

# Test API connectivity
curl -s -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/get_projects" | jq .

# Common errors:
# - "Authentication failed" → Check API key
# - "API is disabled" → Enable in Site Settings
# - "No host part in URL" → TESTRAIL_URL must include https://
```

**Full docs:** https://support.testrail.com/hc/en-us/categories/7076541806228-API-Manual
