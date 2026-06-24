---
name: testrail-api
description: TestRail REST API for test management. Use when user mentions "TestRail",
  "test cases", "test runs", "test results", or test management operations.
---

# TestRail API Skill

Lean marketplace entrypoint for direct TestRail REST API usage.

## Important packaging note

`npx skills add kos322/testrail-skill` installs **this file only**.

It does **not** install repository helpers like `scripts/`, `powershell/`, `examples/`, or `docs/`.
If you want the full wrapper toolkit, clone the repository separately:

```bash
git clone https://github.com/kos322/testrail-skill.git
```

## Setup

Set these environment variables:

- `TESTRAIL_URL`
- `TESTRAIL_USER`
- `TESTRAIL_API_KEY`

Base URL:

```bash
${TESTRAIL_URL}/index.php?/api/v2
```

## Decision tree

- **Known project ID + simple read-only question:** call the needed endpoint directly.
- **Unknown project ID:** call `get_projects`.
- **Run/results workflow:** create run -> get tests -> add results -> close run.
- **Need wrappers, PowerShell helpers, or disposable verification workflows:** clone the repository and use `README.md`.

## Common queries

```bash
# List accessible projects
curl -s -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/get_projects" | jq .

# Get suites in a project
curl -s -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/get_suites/PROJECT_ID" | jq .

# Get sections in a suite
curl -s -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/get_sections/PROJECT_ID&suite_id=SUITE_ID" | jq .

# Get cases (optionally add &section_id=SECTION_ID or &suite_id=SUITE_ID)
curl -s -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/get_cases/PROJECT_ID" | jq .

# Get one case
curl -s -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/get_case/CASE_ID" | jq .

# Get statuses
curl -s -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/get_statuses" | jq .
```

## Run/results workflow

```bash
# 1. Create a run
cat > run.json <<'EOF'
{"suite_id":1,"name":"Automation Run","include_all":false,"case_ids":[1,2,3]}
EOF

RUN_ID="$(
  curl -s -X POST -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
    "${TESTRAIL_URL}/index.php?/api/v2/add_run/PROJECT_ID" \
    -H "Content-Type: application/json" \
    -d @run.json | jq -r '.id'
)"

# 2. Inspect tests created in the run
curl -s -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/get_tests/${RUN_ID}" | jq .

# 3. Add bulk results
cat > results.json <<'EOF'
{"results":[{"test_id":123,"status_id":1,"comment":"Passed"}]}
EOF

curl -s -X POST -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/add_results/${RUN_ID}" \
  -H "Content-Type: application/json" \
  -d @results.json | jq .

# 4. Close the run
curl -s -X POST -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/close_run/${RUN_ID}" | jq .
```

## Notes

- Use Basic Auth with email + API key.
- Many list endpoints are paginated.
- `add_run` returns `.id`, not `.run.id`.
- `test_id` and `case_id` are different identifiers.
- For the full repository-based toolkit, wrapper scripts, PowerShell launchers, and maintenance docs, see:  
  https://github.com/kos322/testrail-skill

Official API docs: https://support.testrail.com/hc/en-us/categories/7076541806228-API-Manual
