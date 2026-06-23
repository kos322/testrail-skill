# TestRail API Reference

Complete reference for all TestRail REST API v2 endpoints.

Base URL: `${TESTRAIL_URL}/index.php?/api/v2`

## Authentication

All requests use Basic Auth:
```bash
-u "$TESTRAIL_USER:$TESTRAIL_API_KEY"
```

## Projects

### GET /get_projects
List all projects accessible to user.

### GET /get_project/:id
Get project details by ID.

## Suites & Sections

### GET /get_suites/:project_id
List suites in project.

### GET /get_sections/:project_id&suite_id=:suite_id
List sections (folders) in suite.

## Test Cases

### GET /get_cases/:project_id[&suite_id=:id][&section_id=:id]
Get test cases. Optional filters: suite_id, section_id.

### GET /get_case/:id
Get single test case by ID.

### POST /add_case/:section_id
Create test case in section.

**Payload:**
```json
{
  "title": "Test title",
  "template_id": 1,
  "type_id": 1,
  "priority_id": 2,
  "estimate": "5m",
  "refs": "JIRA-123",
  "custom_steps": [
    {"content": "Step", "expected": "Result"}
  ]
}
```

### POST /update_case/:id
Update existing test case.

## Test Runs

### GET /get_runs/:project_id
List test runs in project.

### POST /add_run/:project_id
Create test run.

**Payload:**
```json
{
  "suite_id": 5,
  "name": "Run name",
  "include_all": false,
  "case_ids": [1, 2, 3]
}
```

### GET /get_tests/:run_id
Get all tests (instances) in run.

### POST /close_run/:run_id
Close test run.

## Results

### POST /add_result/:test_id
Add result for single test.

**Payload:**
```json
{
  "status_id": 1,
  "comment": "Passed",
  "elapsed": "5m",
  "version": "v1.0"
}
```

### POST /add_result_for_case/:run_id/:case_id
Add result by case_id instead of test_id.

### POST /add_results/:run_id
Bulk add results.

**Payload:**
```json
{
  "results": [
    {"test_id": 1, "status_id": 1, "comment": "Passed"},
    {"test_id": 2, "status_id": 5, "comment": "Failed"}
  ]
}
```

### GET /get_results/:test_id
Get all results for test.

### GET /get_results_for_case/:run_id/:case_id
Get results for case across runs.

## Metadata

### GET /get_users
List all users (admin required).

### GET /get_statuses
Get available result statuses.

### GET /get_case_fields
Get custom field definitions.

### GET /get_priorities
Get available priorities.

### GET /get_case_types
Get available case types.

## Status IDs

Standard statuses:
- 1 = Passed
- 2 = Blocked
- 3 = Untested (retest)
- 4 = Retest
- 5 = Failed

Use `get_statuses` to check for custom statuses.

## Custom Fields

Custom fields are prefixed with `custom_`:
- `custom_steps` - test steps
- `custom_preconds` - preconditions
- `custom_expected` - expected result

## Pagination

Add to URL: `&limit=250&offset=0`

Default limit: 250 (max)

## Rate Limiting

TestRail has rate limits. Implement exponential backoff for 429 responses.

## Common Patterns

**Extract ID from response:**
```bash
RUN_ID=$(curl ... | jq -r '.run.id')
```

**Parse list:**
```bash
curl ... | jq '.cases[] | {id, title, priority_id}'
```

**Check for errors:**
```bash
RESPONSE=$(curl ...)
echo "$RESPONSE" | jq -e '.error' && echo "API Error" && exit 1
```

**Official docs:** https://support.testrail.com/hc/en-us/categories/7076541806228-API-Manual
