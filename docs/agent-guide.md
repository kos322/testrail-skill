# Guide for AI Agents

Instructions for AI agents using this skill on different platforms.

## Preferred Approach

**Use Bash tool directly.** Examples in SKILL.md work as-is in:
- Claude Code (Bash tool)
- Linux/macOS terminal
- Windows Git Bash
- WSL

## Windows: Finding Bash

If `bash` command fails:

1. **Check common paths:**
```bash
which bash || where.exe bash
```

2. **Standard Git Bash locations:**
- `C:\Program Files\Git\bin\bash.exe`
- `C:\Program Files\Git\usr\bin\bash.exe`

3. **Try explicit path:**
```bash
"/c/Program Files/Git/bin/bash.exe" script.sh
```

## Loading .env Reliably

**Robust pattern:**
```bash
if [ -f .env ]; then
  set -a        # Auto-export variables
  source .env
  set +a        # Stop auto-export
else
  echo "Error: .env not found" >&2
  exit 1
fi
```

**Validation:**
```bash
: "${TESTRAIL_URL:?TESTRAIL_URL not set}"
: "${TESTRAIL_USER:?TESTRAIL_USER not set}"
: "${TESTRAIL_API_KEY:?TESTRAIL_API_KEY not set}"
```

## Pre-execution Checks

Before running TestRail commands:

```bash
# Check curl available
curl --version >/dev/null 2>&1 || {
  echo "Error: curl not found" >&2
  exit 1
}

# Check credentials loaded
[ -z "$TESTRAIL_URL" ] && echo "TESTRAIL_URL not set" >&2 && exit 1

# Test API connectivity
RESPONSE=$(curl -s -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/get_projects")

echo "$RESPONSE" | grep -q '"error"' && {
  echo "API Error: $RESPONSE" >&2
  exit 1
}
```

## Handling Script Execution

**Make executable:**
```bash
chmod +x scripts/*.sh
```

**Or invoke with bash:**
```bash
bash scripts/get_cases.sh 1
```

## Error Handling

**Check exit codes:**
```bash
if ! ./scripts/create_run.sh 1 5 "Test Run"; then
  echo "Failed to create run" >&2
  exit 1
fi
```

**Capture and parse errors:**
```bash
RESPONSE=$(curl ...)
if echo "$RESPONSE" | jq -e '.error' >/dev/null 2>&1; then
  ERROR=$(echo "$RESPONSE" | jq -r '.error')
  echo "TestRail API error: $ERROR" >&2
  exit 1
fi
```

## PowerShell Fallback (Last Resort)

If Bash truly unavailable on Windows, translate commands:

**Parse .env in PowerShell:**
```powershell
Get-Content .env | ForEach-Object {
  if ($_ -match '^\s*#' -or $_ -match '^\s*$') { return }
  $parts = $_ -split '=', 2
  $key = $parts[0].Trim()
  $value = $parts[1].Trim().Trim('"')
  Set-Variable -Name $key -Value $value -Scope Global
}
```

**curl.exe (not Invoke-RestMethod):**
```powershell
curl.exe -s -u "$($env:TESTRAIL_USER):$($env:TESTRAIL_API_KEY)" `
  "$($env:TESTRAIL_URL)/index.php?/api/v2/get_projects"
```

**But prefer Bash tool** — it's simpler and already works.

## Debugging Commands

**Verbose curl:**
```bash
curl -v -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/get_projects"
```

**Save response:**
```bash
curl ... -o debug.json
cat debug.json | jq .
```

**Check HTTP status:**
```bash
STATUS=$(curl -w "%{http_code}" -o response.json ...)
echo "HTTP Status: $STATUS"
```

## Token Optimization

When generating commands for users:
1. Reference script paths: `./scripts/get_cases.sh` not full curl commands
2. Point to docs: "See docs/api-reference.md" not repeating API details
3. Use examples: "Like examples/create_case.sh" not writing from scratch
4. Keep responses concise: script name + brief explanation

This keeps token usage low while maintaining full functionality.
