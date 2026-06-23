# TestRail API Reference

Working reference for the TestRail REST API v2 endpoints used or tracked by this skill.

Base URL: `${TESTRAIL_URL}/index.php?/api/v2`

## Authentication

All requests use Basic Auth:
```bash
-u "$TESTRAIL_USER:$TESTRAIL_API_KEY"
```

## Projects

### GET /get_projects
List all projects accessible to user.

Helper script: `./scripts/get_projects.sh`

### GET /get_project/:id
Get project details by ID.

Returns a project object directly.

## Suites & Sections

### GET /get_suites/:project_id
List suites in project.

### GET /get_sections/:project_id&suite_id=:suite_id
List sections (folders) in suite.

Returns a paginated object with a `sections` array plus `offset`, `limit`, `size`, and `_links`.

## Test Cases

### GET /get_cases/:project_id[&suite_id=:id][&section_id=:id]
Get test cases. Optional filters: suite_id, section_id.

Helper script:

```bash
./scripts/get_cases.sh PROJECT_ID [SECTION_ID] [--suite SUITE_ID]
```

Use `./scripts/count_cases.sh` for totals.

### GET /get_case/:id
Get single test case by ID.

### POST /add_case/:section_id
Create test case in section.

**Payload:**
```json
{
  "title": "Test title",
  "template_id": 2,
  "type_id": 6,
  "priority_id": 2,
  "estimate": "5m",
  "refs": "JIRA-123",
  "custom_steps_separated": [
    {"content": "Step", "expected": "Result"}
  ],
  "custom_preconds": "Preconditions"
}
```

For the default field configuration in this project:
- `template_id: 2` = `Test Case (Steps)`
- `custom_steps_separated` is the structured steps field
- `custom_steps` is a markdown text field, not a JSON array

### POST /update_case/:id
Update existing test case.

Common disposable verification path:
- create a case with `examples/create_case.sh`
- update it with `scripts/update_case.sh`
- verify the new title/priority via `scripts/get_case.sh`
- remove the fixture with `delete_case`

### POST /delete_case/:id
Delete test case.

Helper script: `./scripts/delete_case.sh CASE_ID`

## Test Runs

### GET /get_runs/:project_id
List test runs in project.

Returns a paginated object with a `runs` array plus `offset`, `limit`, `size`, and `_links`.

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

Returns a paginated object with a `tests` array plus pagination metadata.

### GET /get_test/:id
Get a single test instance by ID.

### POST /close_run/:run_id
Close test run.

### POST /delete_run/:id
Delete test run permanently.

### POST /update_run/:id
Update an open run.

Common disposable verification path:
- create a run with `scripts/create_run.sh`
- update its name/description with `scripts/update_run.sh`
- verify the updated name through `scripts/get_runs.sh`
- delete the open run with `delete_run`

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

Verified using a disposable run plus `scripts/add_result_for_case.sh`, then read back through both
`get_results_for_case` and `get_results_for_run`.

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
Get all results for test. Returns a paginated object with a `.results` array.

Untested tests return `size: 0` with an empty `.results` array.

### GET /get_results_for_case/:run_id/:case_id
Get results for case within a run. Returns a paginated object with a `.results` array.

### GET /get_results_for_run/:run_id
Get all results in a run. Returns a paginated object with a `.results` array.

Runs with no recorded results return `size: 0` with an empty `.results` array.

## Plans

### GET /get_plans/:project_id
List test plans in project.

### GET /get_plan/:id
Get a single test plan, including plan entries and generated runs.

### POST /add_plan/:project_id
Create a test plan.

**Payload:**
```json
{
  "name": "Release v5.68 regression",
  "description": "Disposable verification plan",
  "milestone_id": 12,
  "entries": [
    {
      "suite_id": 1,
      "name": "Smoke entry",
      "include_all": false,
      "case_ids": [1, 2]
    }
  ]
}
```

### POST /add_plan_entry/:plan_id
Add a new entry (generated run) to an existing test plan.

**Payload:**
```json
{
  "suite_id": 1,
  "name": "Focused entry",
  "include_all": false,
  "case_ids": [3, 5]
}
```

### POST /update_plan/:id
Update plan metadata.

**Payload:**
```json
{
  "name": "Release v5.68 regression [updated]",
  "description": "Updated plan metadata"
}
```

### POST /update_plan_entry/:plan_id/:entry_id
Update an existing plan entry.

**Payload:**
```json
{
  "name": "Focused entry [updated]",
  "include_all": false,
  "case_ids": [3]
}
```

### POST /close_plan/:id
Close a test plan.

### POST /delete_plan/:id
Delete a test plan.

## Milestones

### GET /get_milestones/:project_id
List milestones in project.

### GET /get_milestone/:id
Get a single milestone.

### POST /add_milestone/:project_id
Create a milestone.

**Payload:**
```json
{
  "name": "Release v5.68",
  "description": "Disposable verification milestone",
  "refs": "AUTO-123"
}
```

### POST /update_milestone/:id
Update milestone fields.

**Payload:**
```json
{
  "description": "Updated verification milestone",
  "refs": "AUTO-456"
}
```

### POST /delete_milestone/:id
Delete a milestone.

## Attachments

### POST /add_attachment_to_case/:case_id
Upload a file to a case.

Returns an object with `attachment_id`.

### POST /add_attachment_to_result/:result_id
Upload a file to a specific test result.

Returns an object with `attachment_id`.

### POST /add_attachment_to_plan/:plan_id
Upload a file to a plan.

Returns an object with `attachment_id`.

### POST /add_attachment_to_plan_entry/:plan_id/:entry_id
Upload a file to a specific plan entry.

Returns an object with `attachment_id`.

### GET /get_attachments_for_case/:case_id
List attachments for a case.

Returns a paginated object with an `.attachments` array.

### GET /get_attachments_for_test/:test_id
List attachments associated with a test/result history.

Returns a raw array on this server, not a paginated object.

### POST /delete_attachment/:attachment_id
Delete an attachment.

Returns an empty success body.

## Metadata

### GET /get_users
List all users (admin required). Returns a paginated object with a `users` array.

### GET /get_user/:id
Get a single user by ID.

### GET /get_user_by_email&email=:email
Get a single user by email address.

### GET /get_statuses
Get available result statuses.

### GET /get_case_fields
Get custom field definitions.

### GET /get_priorities
Get available priorities.

### GET /get_case_types
Get available case types.

### GET /get_templates/:project_id
Get case templates available in a project.

### GET /get_result_fields
Get result field definitions.

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

**Important:** do not treat `.size` as a safe grand total unless `_links.next` is empty.

Preferred counting path:

```bash
./scripts/count_cases.sh 1
./scripts/count_cases.sh 1 10 --suite 1
```

## Rate Limiting

TestRail has rate limits. Implement exponential backoff for 429 responses.

## Common Patterns

**Extract ID from response:**
```bash
RUN_ID=$(./scripts/create_run.sh 1 5 "My Run" | jq -r '.id')
```

**Parse list:**
```bash
curl ... | jq '.cases[] | {id, title, priority_id}'
```

**Parse paginated results:**
```bash
./scripts/get_runs.sh 1 | jq '.runs[] | {id, name, is_completed}'
./scripts/get_results_for_run.sh 20 | jq '.results[] | {test_id, status_id, comment}'
```

**Check for errors:**
```bash
RESPONSE=$(curl ...)
echo "$RESPONSE" | jq -e '.error' && echo "API Error" && exit 1
```

**Official docs:** https://support.testrail.com/hc/en-us/categories/7076541806228-API-Manual
