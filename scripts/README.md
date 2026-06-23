# TestRail Scripts

Ready-to-use bash scripts for common TestRail operations.

## Prerequisites

Load credentials first:
```bash
source .env
```

Make scripts executable:
```bash
chmod +x *.sh
```

## Available Scripts

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
RUN_ID=$(./create_run.sh 1 5 "My Run" | jq -r '.run.id')
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
source .env

# Create run
RUN_ID=$(./create_run.sh 1 5 "Automated" | jq -r '.run.id')
echo "Run ID: $RUN_ID"

# Push results
./bulk_results.sh "$RUN_ID" results.json

# Close run
./close_run.sh "$RUN_ID"
echo "Complete!"
```

## See Also

- **../examples/** — Complete workflow examples
- **../docs/api-reference.md** — Full API documentation
- **../docs/troubleshooting.md** — Common issues
