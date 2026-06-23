---
name: testrail-api
description: TestRail REST API for test management. Use when user mentions "TestRail",
  "test cases", "test runs", "test results", or test management operations.
---

# TestRail API Integration

**IMPORTANT for Windows:** This skill uses Bash syntax. If running on Windows:
1. **Prefer Bash tool** over PowerShell for these commands
2. All examples work in Git Bash (included with Git for Windows)
3. Alternative: Use WSL (Windows Subsystem for Linux)

Do NOT translate to PowerShell — the Bash tool provides native Bash environment on Windows.

## For AI Agents

**Preferred approach:** Use Bash tool directly (Claude Code) or invoke `bash -c` if available.

**If Bash fails on Windows:**
1. Check common Git Bash paths: `C:\Program Files\Git\bin\bash.exe`
2. Try with explicit path: `/c/Program\ Files/Git/bin/bash.exe -c "..."`
3. Last resort: Translate to PowerShell (see Troubleshooting for examples)

**Loading .env reliably:**
```bash
# Robust .env loading (handles missing file gracefully)
if [ -f .env ]; then
  set -a
  source .env
  set +a
else
  echo "Warning: .env not found, using inline credentials"
fi
```

**Testing before execution:**
```bash
# Quick sanity check
curl --version >/dev/null 2>&1 || echo "curl not available"
[ -z "$TESTRAIL_URL" ] && echo "TESTRAIL_URL not set"
```

## Prerequisites

Configure TestRail credentials using one of these methods:

### Option 1: Project `.env` file (Recommended)

Create `.env` in your project directory:

```bash
cat > .env <<'EOF'
TESTRAIL_URL="https://your-company.testrail.io"
TESTRAIL_USER="your@email.com"
TESTRAIL_API_KEY="your-api-key"
EOF

# Add to .gitignore to avoid committing secrets
echo ".env" >> .gitignore
```

Then source it before running TestRail commands:

```bash
source .env
curl -s -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" "${TESTRAIL_URL}/index.php?/api/v2/get_projects"
```

**Why this approach?**
- Project-specific credentials (different projects = different TestRail instances)
- Easy to `.gitignore` and keep out of version control
- Standard pattern (many tools support `.env`)
- Works across terminal sessions after `source .env`

### Option 2: Global environment variables

Add to `~/.bashrc` or `~/.bash_profile`:

```bash
export TESTRAIL_URL="https://your-company.testrail.io"
export TESTRAIL_USER="your@email.com"
export TESTRAIL_API_KEY="your-api-key"
```

Reload your shell: `source ~/.bashrc`

**Use case:** When you work with one TestRail instance across all projects.

### Option 3: Inline variables (for testing/one-off commands)

```bash
TESTRAIL_URL="https://company.testrail.io" \
TESTRAIL_USER="user@email.com" \
TESTRAIL_API_KEY="your-key" \
curl -s -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" "${TESTRAIL_URL}/index.php?/api/v2/get_projects"
```

**Use case:** Quick testing without persisting credentials.

### Get your API key

1. Login to TestRail
2. Go to **My Settings → API Keys**
3. Click **Add Key**
4. Copy the generated key

**Note:** Ensure API is enabled in **Administration → Site Settings → API**.

Base URL: `${TESTRAIL_URL}/index.php?/api/v2`

## How to Use

All examples assume credentials are set (via `.env`, global export, or inline).

Examples use Basic Auth: `-u "$TESTRAIL_USER:$TESTRAIL_API_KEY"`

### 1. Get Projects

List all projects:

```bash
curl -s -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/get_projects" \
  -H "Content-Type: application/json"
```

### 2. Get Project by ID

Get project details:

```bash
PROJECT_ID="1"

curl -s -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/get_project/${PROJECT_ID}" \
  -H "Content-Type: application/json"
```

### 3. Get Test Suites

List suites in a project:

```bash
PROJECT_ID="1"

curl -s -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/get_suites/${PROJECT_ID}" \
  -H "Content-Type: application/json"
```

### 4. Get Sections

List sections (folders) in a suite:

```bash
PROJECT_ID="1"
SUITE_ID="5"

curl -s -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/get_sections/${PROJECT_ID}&suite_id=${SUITE_ID}" \
  -H "Content-Type: application/json"
```

### 5. Get Test Cases

Get all cases in a project/suite:

```bash
PROJECT_ID="1"
SUITE_ID="5"  # Optional

curl -s -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/get_cases/${PROJECT_ID}&suite_id=${SUITE_ID}" \
  -H "Content-Type: application/json"
```

Filter by section:

```bash
PROJECT_ID="1"
SECTION_ID="10"

curl -s -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/get_cases/${PROJECT_ID}&section_id=${SECTION_ID}" \
  -H "Content-Type: application/json"
```

### 6. Get Single Test Case

Get case details by ID:

```bash
CASE_ID="12345"

curl -s -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/get_case/${CASE_ID}" \
  -H "Content-Type: application/json"
```

### 7. Create Test Case

Add a new test case:

Write to `/tmp/testrail_request.json`:

```json
{
  "title": "Verify login with valid credentials",
  "template_id": 1,
  "type_id": 1,
  "priority_id": 2,
  "estimate": "5m",
  "refs": "JIRA-123",
  "custom_steps": [
    {
      "content": "Navigate to login page",
      "expected": "Login page loads successfully"
    },
    {
      "content": "Enter valid username and password",
      "expected": "Credentials are accepted"
    },
    {
      "content": "Click Login button",
      "expected": "User is redirected to dashboard"
    }
  ],
  "custom_preconds": "User must be registered in the system"
}
```

Then run:

```bash
SECTION_ID="10"

curl -s -X POST -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/add_case/${SECTION_ID}" \
  -H "Content-Type: application/json" \
  -d @/tmp/testrail_request.json
```

### 8. Update Test Case

Update existing case:

Write to `/tmp/testrail_request.json`:

```json
{
  "title": "Updated: Verify login with valid credentials",
  "priority_id": 4,
  "custom_steps": [
    {
      "content": "Navigate to login page",
      "expected": "Login page loads successfully"
    },
    {
      "content": "Enter valid username and password",
      "expected": "Credentials are accepted"
    },
    {
      "content": "Click Login button",
      "expected": "User is redirected to dashboard"
    }
  ]
}
```

Then run:

```bash
CASE_ID="12345"

curl -s -X POST -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/update_case/${CASE_ID}" \
  -H "Content-Type: application/json" \
  -d @/tmp/testrail_request.json
```

### 9. Get Test Runs

List test runs in a project:

```bash
PROJECT_ID="1"

curl -s -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/get_runs/${PROJECT_ID}" \
  -H "Content-Type: application/json"
```

### 10. Create Test Run

Create a new test run:

Write to `/tmp/testrail_request.json`:

```json
{
  "suite_id": 5,
  "name": "Sprint 42 Regression",
  "description": "Full regression for Sprint 42",
  "include_all": false,
  "case_ids": [1, 2, 3, 5, 8],
  "assignedto_id": 1
}
```

Then run:

```bash
PROJECT_ID="1"

curl -s -X POST -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/add_run/${PROJECT_ID}" \
  -H "Content-Type: application/json" \
  -d @/tmp/testrail_request.json
```

Returns the created run with `id` field.

### 11. Get Tests in a Run

Get all tests (instances) in a run:

```bash
RUN_ID="123"

curl -s -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/get_tests/${RUN_ID}" \
  -H "Content-Type: application/json"
```

### 12. Add Test Result

Add result for a single test:

Write to `/tmp/testrail_request.json`:

```json
{
  "status_id": 1,
  "comment": "Test passed successfully on Chrome 120",
  "elapsed": "5m",
  "version": "v2.1.0",
  "defects": "JIRA-456"
}
```

Status IDs (standard):
- 1 = Passed
- 2 = Blocked
- 3 = Untested (retest)
- 4 = Retest
- 5 = Failed

Then run:

```bash
TEST_ID="1042"  # Get from get_tests endpoint

curl -s -X POST -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/add_result/${TEST_ID}" \
  -H "Content-Type: application/json" \
  -d @/tmp/testrail_request.json
```

### 13. Add Result for Case

Add result by case_id (instead of test_id):

Write to `/tmp/testrail_request.json`:

```json
{
  "status_id": 5,
  "comment": "Login button not responding on iOS 17",
  "elapsed": "3m",
  "defects": "JIRA-789"
}
```

Then run:

```bash
RUN_ID="123"
CASE_ID="456"

curl -s -X POST -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/add_result_for_case/${RUN_ID}/${CASE_ID}" \
  -H "Content-Type: application/json" \
  -d @/tmp/testrail_request.json
```

### 14. Add Results in Bulk

Add multiple results at once:

Write to `/tmp/testrail_request.json`:

```json
{
  "results": [
    {
      "test_id": 1042,
      "status_id": 1,
      "comment": "Passed"
    },
    {
      "test_id": 1043,
      "status_id": 5,
      "comment": "Failed: timeout",
      "defects": "JIRA-790"
    },
    {
      "test_id": 1044,
      "status_id": 1,
      "comment": "Passed"
    }
  ]
}
```

Then run:

```bash
RUN_ID="123"

curl -s -X POST -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/add_results/${RUN_ID}" \
  -H "Content-Type: application/json" \
  -d @/tmp/testrail_request.json
```

### 15. Get Results for Test

Get all results for a specific test:

```bash
TEST_ID="1042"

curl -s -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/get_results/${TEST_ID}" \
  -H "Content-Type: application/json"
```

### 16. Get Results for Case

Get results for a case across all runs:

```bash
RUN_ID="123"
CASE_ID="456"

curl -s -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/get_results_for_case/${RUN_ID}/${CASE_ID}" \
  -H "Content-Type: application/json"
```

### 17. Close Test Run

Close a test run after completion:

Write to `/tmp/testrail_request.json`:

```json
{
  "name": "Sprint 42 Regression [COMPLETED]"
}
```

Then run:

```bash
RUN_ID="123"

curl -s -X POST -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/close_run/${RUN_ID}" \
  -H "Content-Type: application/json" \
  -d @/tmp/testrail_request.json
```

### 18. Get Users

List all users (requires admin):

```bash
curl -s -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/get_users" \
  -H "Content-Type: application/json"
```

### 19. Get Case Fields

Get custom field definitions:

```bash
curl -s -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/get_case_fields" \
  -H "Content-Type: application/json"
```

### 20. Get Statuses

Get available result statuses:

```bash
curl -s -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/get_statuses" \
  -H "Content-Type: application/json"
```

## Common Workflows

### Workflow 1: Import Cases and Generate Tests

```bash
# 1. Get cases from section
PROJECT_ID="1"
SECTION_ID="10"
curl -s -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/get_cases/${PROJECT_ID}&section_id=${SECTION_ID}" \
  -o /tmp/cases.json

# 2. Parse and generate test code
jq -r '.cases[] | "Case ID: \(.id)\nTitle: \(.title)\nSteps: \(.custom_steps)"' /tmp/cases.json
```

### Workflow 2: Create Run and Push Results

```bash
# 1. Create test run
PROJECT_ID="1"
cat > /tmp/run.json <<EOF
{
  "suite_id": 5,
  "name": "Automated Run $(date +%Y-%m-%d)",
  "include_all": false,
  "case_ids": [1, 2, 3]
}
EOF

RUN_ID=$(curl -s -X POST -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/add_run/${PROJECT_ID}" \
  -H "Content-Type: application/json" \
  -d @/tmp/run.json | jq -r '.run.id')

echo "Created run: $RUN_ID"

# 2. Push results
cat > /tmp/results.json <<EOF
{
  "results": [
    {"test_id": 1042, "status_id": 1, "comment": "Passed"},
    {"test_id": 1043, "status_id": 5, "comment": "Failed: assertion error"}
  ]
}
EOF

curl -s -X POST -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/add_results/${RUN_ID}" \
  -H "Content-Type: application/json" \
  -d @/tmp/results.json
```

## Troubleshooting

### Bash not found on Windows

If running `bash` fails, verify Git Bash installation:

```bash
# Check if bash is in PATH
which bash || where.exe bash

# Common Git Bash locations:
# C:\Program Files\Git\bin\bash.exe
# C:\Program Files\Git\usr\bin\bash.exe
```

### Credentials not loading

Test `.env` file manually:

```bash
# Verify .env exists
ls -la .env

# Check contents (without exposing secrets)
head -1 .env

# Test sourcing
source .env && echo "TESTRAIL_URL is set: ${TESTRAIL_URL:0:20}..."
```

### curl command fails

```bash
# Test curl is available
curl --version

# Test basic connectivity
curl -v https://your-instance.testrail.io/

# Test authentication (should NOT return "Authentication failed")
curl -s -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/get_projects"
```

Common errors:
- `Authentication failed` → Check API key, ensure API is enabled in TestRail
- `API is disabled` → Enable in Administration → Site Settings → API
- `No host part in URL` → Check `TESTRAIL_URL` format (must include `https://`)

## Guidelines

1. **Authentication**: Always use Basic Auth with email + API key
2. **URL format**: All endpoints require `/index.php?/api/v2` prefix
3. **Rate limiting**: TestRail has rate limits; implement exponential backoff for 429 responses
4. **Custom fields**: Custom fields are prefixed with `custom_` (e.g., `custom_steps`, `custom_preconds`)
5. **Pagination**: Use `&limit=X&offset=Y` for large result sets
6. **Test vs Case**: `test_id` is an instance in a run, `case_id` is the master test case
7. **Status IDs**: Standard statuses are 1-5, but check `get_statuses` for custom ones
8. **Bulk operations**: Use `add_results` (plural) for bulk inserts — much faster than individual calls

## Reference

- Official API Manual: https://support.testrail.com/hc/en-us/categories/7076541806228-API-Manual
- API Reference: https://support.testrail.com/hc/en-us/sections/7077185274644-API-reference
- Cases API: https://support.testrail.com/hc/en-us/articles/7077292642580-Cases
- Results API: https://support.testrail.com/hc/en-us/articles/7077819312404-Results
- Introduction to TestRail API: https://support.testrail.com/hc/en-us/articles/7077083596436-Introduction-to-the-TestRail-API
