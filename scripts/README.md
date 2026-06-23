# TestRail Scripts

Ready-to-use bash scripts for common TestRail operations.

## Prerequisites

**1. Create `.env` file:**
```bash
cp ../.env.example .env
# Edit .env with your credentials
```

**2. Make scripts executable:**
```bash
chmod +x *.sh
```

**Note:** Scripts load `.env` automatically. No need to `source .env` manually.
This keeps credentials isolated from LLM context for security.

## Available Scripts

### Core read scripts

These wrappers are useful for repeated inspection/debugging of live TestRail data:

```bash
./get_project.sh PROJECT_ID
./get_sections.sh PROJECT_ID SUITE_ID
./get_case.sh CASE_ID
./get_runs.sh PROJECT_ID
./get_test.sh TEST_ID
./get_results.sh TEST_ID
./get_results_for_case.sh RUN_ID CASE_ID
./get_results_for_run.sh RUN_ID
```

### Core write scripts

These wrappers cover the remaining commonly-used mutation paths:

```bash
./update_case.sh CASE_ID TITLE [PRIORITY_ID]
./update_run.sh RUN_ID NAME [DESCRIPTION]
./add_result_for_case.sh RUN_ID CASE_ID STATUS_ID COMMENT [ELAPSED]
```

### Attachment scripts

These wrappers cover upload/list/delete for attachment endpoints:

```bash
./add_attachment.sh case CASE_ID FILE
./add_attachment.sh result RESULT_ID FILE
./add_attachment.sh plan PLAN_ID FILE
./add_attachment.sh plan_entry PLAN_ID ENTRY_ID FILE
./get_attachments.sh case CASE_ID
./get_attachments.sh test TEST_ID
./delete_attachment.sh ATTACHMENT_ID
```

### get_reference_data.sh
Get reusable reference data and user metadata.

**Usage:**
```bash
./get_reference_data.sh RESOURCE [ARG]
```

**Supported resources:**
- `statuses`
- `case_fields`
- `priorities`
- `case_types`
- `templates PROJECT_ID`
- `result_fields`
- `users`
- `user USER_ID`
- `user_by_email EMAIL`

**Examples:**
```bash
./get_reference_data.sh statuses | jq 'map(.label)'
./get_reference_data.sh templates 1 | jq 'map(.name)'
./get_reference_data.sh user 1 | jq '{id, name, email}'
```

### get_cases.sh
Get test cases from project/section.

**Usage:**
```bash
./get_cases.sh PROJECT_ID [SECTION_ID]
```

**Examples:**
```bash
# All cases in project
./get_cases.sh 1

# Cases in specific section
./get_cases.sh 1 10

# Parse with jq
./get_cases.sh 1 | jq '.cases[] | {id, title}'
```

### get_plans.sh
Get test plans in a project.

**Usage:**
```bash
./get_plans.sh PROJECT_ID
```

**Example:**
```bash
./get_plans.sh 1 | jq '.plans[] | {id, name, is_completed}'
```

### get_milestones.sh
Get milestones in a project.

**Usage:**
```bash
./get_milestones.sh PROJECT_ID
```

**Example:**
```bash
./get_milestones.sh 1 | jq '.milestones[] | {id, name, is_completed}'
```

### create_run.sh
Create a test run.

**Usage:**
```bash
./create_run.sh PROJECT_ID SUITE_ID NAME [CASE_IDS]
```

**Examples:**
```bash
# Include all cases
./create_run.sh 1 5 "Sprint 42 Regression"

# Specific cases
./create_run.sh 1 5 "Smoke Tests" "1,2,3,5"

# Capture run ID
RUN_ID=$(./create_run.sh 1 5 "My Run" | jq -r '.id')
```

### add_result.sh
Add single test result.

**Usage:**
```bash
./add_result.sh TEST_ID STATUS_ID COMMENT [ELAPSED]
```

**Status IDs:** 1=Passed, 2=Blocked, 3=Untested, 4=Retest, 5=Failed

**Examples:**
```bash
# Simple pass
./add_result.sh 1042 1 "Test passed"

# With elapsed time
./add_result.sh 1042 1 "Passed on Chrome" "5m"

# Failed test
./add_result.sh 1043 5 "Timeout after 30s" "30s"
```

### bulk_results.sh
Upload multiple results at once.

**Usage:**
```bash
./bulk_results.sh RUN_ID RESULTS_FILE
```

**Results file format:**
```json
{
  "results": [
    {"test_id": 1, "status_id": 1, "comment": "Passed"},
    {"test_id": 2, "status_id": 5, "comment": "Failed"}
  ]
}
```

**Example:**
```bash
cat > results.json <<'EOF'
{
  "results": [
    {"test_id": 1042, "status_id": 1, "comment": "Passed"},
    {"test_id": 1043, "status_id": 1, "comment": "Passed"},
    {"test_id": 1044, "status_id": 5, "comment": "Failed: timeout"}
  ]
}
EOF

./bulk_results.sh 123 results.json
```

### add_result_for_case.sh
Add a single result by run/case instead of test instance id.

**Usage:**
```bash
./add_result_for_case.sh RUN_ID CASE_ID STATUS_ID COMMENT [ELAPSED]
```

**Example:**
```bash
./add_result_for_case.sh 123 1 1 "Passed via case path" "7s"
```

### import_cases.sh
Export test cases to JSON file.

**Usage:**
```bash
./import_cases.sh PROJECT_ID SECTION_ID [OUTPUT_FILE]
```

**Examples:**
```bash
# Export to default file (cases_export.json)
./import_cases.sh 1 10

# Custom output file
./import_cases.sh 1 10 my_cases.json
```

### close_run.sh
Close a completed test run.

**Usage:**
```bash
./close_run.sh RUN_ID
```

**Example:**
```bash
./close_run.sh 123
```

### update_case.sh
Update a case title and optionally its priority.

**Usage:**
```bash
./update_case.sh CASE_ID TITLE [PRIORITY_ID]
```

**Examples:**
```bash
./update_case.sh 42 "Updated disposable title"
./update_case.sh 42 "Updated disposable title" 4
```

### update_run.sh
Update an open run name and optionally its description.

**Usage:**
```bash
./update_run.sh RUN_ID NAME [DESCRIPTION]
```

**Examples:**
```bash
./update_run.sh 123 "Renamed run"
./update_run.sh 123 "Renamed run" "Updated by verification flow"
```

### add_attachment.sh
Upload a file to a case, result, plan, or plan entry.

**Examples:**
```bash
./add_attachment.sh case 42 evidence.txt
./add_attachment.sh result 107 screenshot.png
./add_attachment.sh plan 58 report.txt
./add_attachment.sh plan_entry 58 ENTRY_ID trace.zip
```

### get_attachments.sh
List attachments for a case or test.

**Examples:**
```bash
./get_attachments.sh case 42 | jq '.attachments[] | {id, filename}'
./get_attachments.sh test 227 | jq '.[] | {id, filename}'
```

### delete_attachment.sh
Delete an attachment by id.

**Example:**
```bash
./delete_attachment.sh 3
```

## Error Handling

All scripts:
- Exit with code 1 on error
- Require credentials to be set
- Use `set -euo pipefail` for safety

Check exit codes:
```bash
if ./create_run.sh 1 5 "Test"; then
  echo "Success"
else
  echo "Failed"
fi
```

## Chaining Scripts

```bash
#!/usr/bin/env bash
set -euo pipefail

# Create run
RUN_ID=$(./create_run.sh 1 5 "Automated" | jq -r '.id')
echo "Run ID: $RUN_ID"

# Push results
./bulk_results.sh "$RUN_ID" results.json

# Close run
./close_run.sh "$RUN_ID"
echo "Complete!"
```

## See Also

- **../examples/** — Complete workflow examples
- **../examples/workflow_plans_milestones.sh** — Disposable plan + milestone lifecycle verification
- **../examples/workflow_attachments.sh** — Disposable attachment lifecycle verification
- **../docs/api-reference.md** — Full API documentation
- **../docs/troubleshooting.md** — Common issues
