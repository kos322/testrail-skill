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
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/common.sh"
load_credentials
```

## Pre-execution Checks

Before running TestRail commands:

```bash
testrail_api GET "get_projects" -H "Content-Type: application/json" \
  | jq '.projects | length'
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
if ! RESPONSE="$(testrail_api GET "get_projects" -H "Content-Type: application/json")"; then
  echo "TestRail request failed" >&2
  exit 1
fi
```

## PowerShell Fallback (Last Resort)

Do **not** parse or `source` `.env` in PowerShell. If the default `bash` command resolves to WSL or fails,
call Git Bash explicitly so the repository scripts can continue loading credentials internally:

```powershell
& "C:\Program Files\Git\usr\bin\bash.exe" -lc 'cd /c/1/testrail-skill && /usr/bin/bash scripts/get_cases.sh 1'
```

If Git Bash is unavailable, install Git for Windows instead of rewriting the authenticated flows in PowerShell.

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
