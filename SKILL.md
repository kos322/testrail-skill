---
name: testrail-api
description: TestRail REST API for test management. Use when user mentions "TestRail",
  "test cases", "test runs", "test results", or test management operations.
---

# TestRail API Skill

Direct TestRail REST API integration without external dependencies. Uses curl + bash.

## Quick Start

**Windows:** Use Bash tool (Git Bash/WSL). Don't translate to PowerShell.

**Setup credentials** (one of):
1. **Recommended:** Create `.env` in project, then `source .env`
2. Global: `export` in `~/.bashrc`
3. Inline: `TESTRAIL_URL="..." curl ...`

See `.env.example` for template.

**Enable API:** TestRail → Administration → Site Settings → API → Enable API  
**Get API Key:** My Settings → API Keys → Add Key

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
curl -s -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/get_cases/PROJECT_ID"

# Get single case
curl -s -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/get_case/CASE_ID"

# Create case (see examples/create_case.sh)
# Update case (see examples/update_case.sh)
```

### Test Runs & Results
```bash
# Create test run (see scripts/create_run.sh)
# Add result by test_id (see scripts/add_result.sh)
# Bulk add results (see scripts/bulk_results.sh)

# Get tests in run
curl -s -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/get_tests/RUN_ID"
```

## Ready-to-Use Scripts

Located in `scripts/` directory:

- `scripts/get_cases.sh PROJECT_ID [SECTION_ID]` — Get test cases
- `scripts/create_run.sh PROJECT_ID SUITE_ID NAME` — Create test run
- `scripts/add_result.sh TEST_ID STATUS COMMENT` — Add single result
- `scripts/bulk_results.sh RUN_ID RESULTS_FILE` — Bulk upload results
- `scripts/import_cases.sh PROJECT_ID SECTION_ID` — Export cases to JSON
- `scripts/close_run.sh RUN_ID` — Close completed run

**Usage:**
```bash
source .env  # Load credentials
./scripts/get_cases.sh 1 10  # Get cases from project 1, section 10
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
cat > /tmp/payload.json <<'EOF'
{"field": "value"}
EOF
curl ... -d @/tmp/payload.json
```

**Parse with jq:**
```bash
curl ... | jq '.cases[] | {id, title, priority_id}'
```

**Extract run ID:**
```bash
RUN_ID=$(curl ... | jq -r '.run.id')
```

## More Resources

- **Detailed Examples:** `examples/` directory
  - `examples/create_case.sh` — Full case creation with custom fields
  - `examples/workflow_ci.sh` — CI integration workflow
  - `examples/playwright_sync.sh` — Sync Playwright test results

- **API Reference:** `docs/api-reference.md` — All 20+ endpoints documented

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
