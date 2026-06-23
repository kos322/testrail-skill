---
name: testrail-api-powershell
description: TestRail REST API for PowerShell/Windows. Use when user mentions "TestRail" 
  on Windows, "test cases", "test runs", "test results", or test management operations.
---

# TestRail API - PowerShell Edition

PowerShell-compatible version for Windows 11. All examples use native Windows paths and syntax.

## Prerequisites

Set these environment variables:

```powershell
$env:TESTRAIL_URL = "https://company.testrail.io"
$env:TESTRAIL_USER = "your@email.com"
$env:TESTRAIL_API_KEY = "your-api-key"
```

## PowerShell-Specific Notes

1. **Use `curl.exe`** not `curl` (PowerShell alias conflicts)
2. **Temp files**: Use `$env:TEMP` instead of `/tmp/`
3. **Here-strings**: Use `@'...'@` instead of `<<EOF`
4. **File encoding**: Always specify `-Encoding utf8`

## How to Use

All examples use `curl.exe` with `-u "$env:TESTRAIL_USER:$env:TESTRAIL_API_KEY"`

### 1. Get Projects

```powershell
curl.exe -s -u "$($env:TESTRAIL_USER):$($env:TESTRAIL_API_KEY)" `
  "$($env:TESTRAIL_URL)/index.php?/api/v2/get_projects" `
  -H "Content-Type: application/json"
```

### 2. Get Project by ID

```powershell
$PROJECT_ID = "1"

curl.exe -s -u "$($env:TESTRAIL_USER):$($env:TESTRAIL_API_KEY)" `
  "$($env:TESTRAIL_URL)/index.php?/api/v2/get_project/$PROJECT_ID" `
  -H "Content-Type: application/json"
```

### 3. Get Test Suites

```powershell
$PROJECT_ID = "1"

curl.exe -s -u "$($env:TESTRAIL_USER):$($env:TESTRAIL_API_KEY)" `
  "$($env:TESTRAIL_URL)/index.php?/api/v2/get_suites/$PROJECT_ID" `
  -H "Content-Type: application/json"
```

### 4. Get Sections

```powershell
$PROJECT_ID = "1"
$SUITE_ID = "5"

curl.exe -s -u "$($env:TESTRAIL_USER):$($env:TESTRAIL_API_KEY)" `
  "$($env:TESTRAIL_URL)/index.php?/api/v2/get_sections/${PROJECT_ID}&suite_id=$SUITE_ID" `
  -H "Content-Type: application/json"
```

### 5. Get Test Cases

```powershell
$PROJECT_ID = "1"
$SUITE_ID = "5"

curl.exe -s -u "$($env:TESTRAIL_USER):$($env:TESTRAIL_API_KEY)" `
  "$($env:TESTRAIL_URL)/index.php?/api/v2/get_cases/${PROJECT_ID}&suite_id=$SUITE_ID" `
  -H "Content-Type: application/json"
```

Filter by section:

```powershell
$PROJECT_ID = "1"
$SECTION_ID = "10"

curl.exe -s -u "$($env:TESTRAIL_USER):$($env:TESTRAIL_API_KEY)" `
  "$($env:TESTRAIL_URL)/index.php?/api/v2/get_cases/${PROJECT_ID}&section_id=$SECTION_ID" `
  -H "Content-Type: application/json"
```

### 6. Get Single Test Case

```powershell
$CASE_ID = "12345"

curl.exe -s -u "$($env:TESTRAIL_USER):$($env:TESTRAIL_API_KEY)" `
  "$($env:TESTRAIL_URL)/index.php?/api/v2/get_case/$CASE_ID" `
  -H "Content-Type: application/json"
```

### 7. Create Test Case

Create temp file with payload:

```powershell
$requestFile = "$env:TEMP\testrail_request.json"

@'
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
'@ | Out-File -FilePath $requestFile -Encoding utf8

$SECTION_ID = "10"

curl.exe -s -X POST -u "$($env:TESTRAIL_USER):$($env:TESTRAIL_API_KEY)" `
  "$($env:TESTRAIL_URL)/index.php?/api/v2/add_case/$SECTION_ID" `
  -H "Content-Type: application/json" `
  --data-binary "@$requestFile"

Remove-Item $requestFile
```

### 8. Update Test Case

```powershell
$requestFile = "$env:TEMP\testrail_request.json"

@'
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
'@ | Out-File -FilePath $requestFile -Encoding utf8

$CASE_ID = "12345"

curl.exe -s -X POST -u "$($env:TESTRAIL_USER):$($env:TESTRAIL_API_KEY)" `
  "$($env:TESTRAIL_URL)/index.php?/api/v2/update_case/$CASE_ID" `
  -H "Content-Type: application/json" `
  --data-binary "@$requestFile"

Remove-Item $requestFile
```

### 9. Get Test Runs

```powershell
$PROJECT_ID = "1"

curl.exe -s -u "$($env:TESTRAIL_USER):$($env:TESTRAIL_API_KEY)" `
  "$($env:TESTRAIL_URL)/index.php?/api/v2/get_runs/$PROJECT_ID" `
  -H "Content-Type: application/json"
```

### 10. Create Test Run

```powershell
$requestFile = "$env:TEMP\testrail_request.json"

@'
{
  "suite_id": 5,
  "name": "Sprint 42 Regression",
  "description": "Full regression for Sprint 42",
  "include_all": false,
  "case_ids": [1, 2, 3, 5, 8],
  "assignedto_id": 1
}
'@ | Out-File -FilePath $requestFile -Encoding utf8

$PROJECT_ID = "1"

curl.exe -s -X POST -u "$($env:TESTRAIL_USER):$($env:TESTRAIL_API_KEY)" `
  "$($env:TESTRAIL_URL)/index.php?/api/v2/add_run/$PROJECT_ID" `
  -H "Content-Type: application/json" `
  --data-binary "@$requestFile"

Remove-Item $requestFile
```

### 11. Get Tests in a Run

```powershell
$RUN_ID = "123"

curl.exe -s -u "$($env:TESTRAIL_USER):$($env:TESTRAIL_API_KEY)" `
  "$($env:TESTRAIL_URL)/index.php?/api/v2/get_tests/$RUN_ID" `
  -H "Content-Type: application/json"
```

### 12. Add Test Result

```powershell
$requestFile = "$env:TEMP\testrail_request.json"

@'
{
  "status_id": 1,
  "comment": "Test passed successfully on Chrome 120",
  "elapsed": "5m",
  "version": "v2.1.0",
  "defects": "JIRA-456"
}
'@ | Out-File -FilePath $requestFile -Encoding utf8

$TEST_ID = "1042"

curl.exe -s -X POST -u "$($env:TESTRAIL_USER):$($env:TESTRAIL_API_KEY)" `
  "$($env:TESTRAIL_URL)/index.php?/api/v2/add_result/$TEST_ID" `
  -H "Content-Type: application/json" `
  --data-binary "@$requestFile"

Remove-Item $requestFile
```

Status IDs:
- 1 = Passed
- 2 = Blocked
- 3 = Untested
- 4 = Retest
- 5 = Failed

### 13. Add Result for Case

```powershell
$requestFile = "$env:TEMP\testrail_request.json"

@'
{
  "status_id": 5,
  "comment": "Login button not responding on iOS 17",
  "elapsed": "3m",
  "defects": "JIRA-789"
}
'@ | Out-File -FilePath $requestFile -Encoding utf8

$RUN_ID = "123"
$CASE_ID = "456"

curl.exe -s -X POST -u "$($env:TESTRAIL_USER):$($env:TESTRAIL_API_KEY)" `
  "$($env:TESTRAIL_URL)/index.php?/api/v2/add_result_for_case/$RUN_ID/$CASE_ID" `
  -H "Content-Type: application/json" `
  --data-binary "@$requestFile"

Remove-Item $requestFile
```

### 14. Add Results in Bulk

```powershell
$requestFile = "$env:TEMP\testrail_request.json"

@'
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
'@ | Out-File -FilePath $requestFile -Encoding utf8

$RUN_ID = "123"

curl.exe -s -X POST -u "$($env:TESTRAIL_USER):$($env:TESTRAIL_API_KEY)" `
  "$($env:TESTRAIL_URL)/index.php?/api/v2/add_results/$RUN_ID" `
  -H "Content-Type: application/json" `
  --data-binary "@$requestFile"

Remove-Item $requestFile
```

### 15. Get Results for Test

```powershell
$TEST_ID = "1042"

curl.exe -s -u "$($env:TESTRAIL_USER):$($env:TESTRAIL_API_KEY)" `
  "$($env:TESTRAIL_URL)/index.php?/api/v2/get_results/$TEST_ID" `
  -H "Content-Type: application/json"
```

### 16. Close Test Run

```powershell
$requestFile = "$env:TEMP\testrail_request.json"

@'
{
  "name": "Sprint 42 Regression [COMPLETED]"
}
'@ | Out-File -FilePath $requestFile -Encoding utf8

$RUN_ID = "123"

curl.exe -s -X POST -u "$($env:TESTRAIL_USER):$($env:TESTRAIL_API_KEY)" `
  "$($env:TESTRAIL_URL)/index.php?/api/v2/close_run/$RUN_ID" `
  -H "Content-Type: application/json" `
  --data-binary "@$requestFile"

Remove-Item $requestFile
```

## Common Workflows

### Workflow 1: Import Cases and Parse with jq

```powershell
$PROJECT_ID = "1"
$SECTION_ID = "10"
$outputFile = "$env:TEMP\cases.json"

curl.exe -s -u "$($env:TESTRAIL_USER):$($env:TESTRAIL_API_KEY)" `
  "$($env:TESTRAIL_URL)/index.php?/api/v2/get_cases/${PROJECT_ID}&section_id=$SECTION_ID" `
  -o $outputFile

# Parse with jq
Get-Content $outputFile | jq -r '.cases[] | "Case ID: \(.id)\nTitle: \(.title)\nSteps: \(.custom_steps)"'

Remove-Item $outputFile
```

### Workflow 2: Create Run and Push Results

```powershell
# 1. Create test run
$PROJECT_ID = "1"
$requestFile = "$env:TEMP\run.json"

@"
{
  "suite_id": 5,
  "name": "Automated Run $(Get-Date -Format 'yyyy-MM-dd')",
  "include_all": false,
  "case_ids": [1, 2, 3]
}
"@ | Out-File -FilePath $requestFile -Encoding utf8

$response = curl.exe -s -X POST -u "$($env:TESTRAIL_USER):$($env:TESTRAIL_API_KEY)" `
  "$($env:TESTRAIL_URL)/index.php?/api/v2/add_run/$PROJECT_ID" `
  -H "Content-Type: application/json" `
  --data-binary "@$requestFile"

$RUN_ID = ($response | ConvertFrom-Json).run.id
Write-Output "Created run: $RUN_ID"

Remove-Item $requestFile

# 2. Push results
$resultsFile = "$env:TEMP\results.json"

@'
{
  "results": [
    {"test_id": 1042, "status_id": 1, "comment": "Passed"},
    {"test_id": 1043, "status_id": 5, "comment": "Failed: assertion error"}
  ]
}
'@ | Out-File -FilePath $resultsFile -Encoding utf8

curl.exe -s -X POST -u "$($env:TESTRAIL_USER):$($env:TESTRAIL_API_KEY)" `
  "$($env:TESTRAIL_URL)/index.php?/api/v2/add_results/$RUN_ID" `
  -H "Content-Type: application/json" `
  --data-binary "@$resultsFile"

Remove-Item $resultsFile
```

## PowerShell Tips

1. **Backtick for line continuation**: Use `` ` `` at end of line (not `\`)
2. **Variable expansion**: Use `$($variable)` in double-quoted strings
3. **Temp directory**: Always use `$env:TEMP` instead of hardcoded paths
4. **File cleanup**: Always `Remove-Item` temp files after use
5. **curl.exe**: Always specify `.exe` to avoid PowerShell alias

## Guidelines

1. **Authentication**: Always use Basic Auth with email + API key
2. **URL format**: All endpoints require `/index.php?/api/v2` prefix
3. **Rate limiting**: Implement exponential backoff for 429 responses
4. **Custom fields**: Prefixed with `custom_` (e.g., `custom_steps`)
5. **Pagination**: Use `&limit=X&offset=Y` for large result sets
6. **Bulk operations**: Use `add_results` (plural) — much faster

## Reference

- Official API Manual: https://support.testrail.com/hc/en-us/categories/7076541806228-API-Manual
- API Reference: https://support.testrail.com/hc/en-us/sections/7077185274644-API-reference
- Cases API: https://support.testrail.com/hc/en-us/articles/7077292642580-Cases
- Results API: https://support.testrail.com/hc/en-us/articles/7077819312404-Results
