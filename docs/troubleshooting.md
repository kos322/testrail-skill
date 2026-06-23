# Troubleshooting

## Bash not found on Windows

**Symptom:** `bash: command not found` or exit code 1

**Solution:**
```bash
# Check if bash is in PATH
which bash || where.exe bash

# Common Git Bash locations:
# C:\Program Files\Git\bin\bash.exe
# C:\Program Files\Git\usr\bin\bash.exe

# Add to PATH or use full path
/c/Program\ Files/Git/bin/bash.exe script.sh
```

## Credentials not loading

**Symptom:** Variables are empty

**Diagnose:**
```bash
# Verify .env exists
ls -la .env

# Check format (no spaces around =)
cat .env

# Test loading through the shared harness
./scripts/get_cases.sh 1 | jq '.cases | length'
```

**Fix:**
- Ensure no spaces: `TESTRAIL_URL="..."` not `TESTRAIL_URL = "..."`
- Use double quotes, not single quotes for values
- No trailing spaces after closing quote
- Keep using the shared `load_credentials` flow from `scripts/common.sh`

## Authentication failed

**Symptom:** `"Authentication failed: invalid or missing user/password"`

**Solutions:**
1. Check API key is correct (regenerate if needed)
2. Ensure API is enabled: Administration → Site Settings → API
3. Verify email is correct (not username)
4. Check for trailing spaces in credentials

**Test:**
```bash
curl -v -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/get_projects"
```

## API is disabled

**Symptom:** `"The API is disabled for your installation"`

**Solution:**
1. Login as administrator
2. Go to Administration → Site Settings
3. Click API tab
4. Check "Enable API"
5. Save settings

## No host part in URL

**Symptom:** `curl: (3) URL rejected: No host part in the URL`

**Solution:**
- Check `TESTRAIL_URL` includes `https://`
- Remove trailing slash: `https://company.testrail.io` not `https://company.testrail.io/`

**Test:**
```bash
echo $TESTRAIL_URL
# Should print: https://company.testrail.io
```

## curl not available

**Symptom:** `curl: command not found`

**Solution (Windows):**
```bash
# Check curl
which curl

# Git Bash should have curl built-in
# If not, check Git for Windows installation
```

**Solution (Linux/macOS):**
```bash
# Ubuntu/Debian
sudo apt-get install curl

# macOS
brew install curl
```

## jq not available

**Symptom:** `jq: command not found`

**Solution:**
```bash
# Windows (via scoop)
scoop install jq

# Ubuntu/Debian
sudo apt-get install jq

# macOS
brew install jq

# Or parse without jq
curl ... | grep -o '"id":[0-9]*'
```

## Script permission denied

**Symptom:** `Permission denied: ./scripts/get_cases.sh`

**Solution:**
```bash
chmod +x scripts/*.sh

# Or run with bash
bash scripts/get_cases.sh 1
```

## Empty response

**Symptom:** Curl returns nothing

**Diagnose:**
```bash
# Add verbose flag
curl -v -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" ...

# Check HTTP status
curl -w "\nHTTP: %{http_code}\n" ...

# Save response to file
curl ... -o response.json && cat response.json
```

## Rate limiting

**Symptom:** HTTP 429 Too Many Requests

**Solution:**
```bash
# Add exponential backoff
for i in 1 2 4 8; do
  RESPONSE=$(curl ...)
  [[ "$RESPONSE" != *"429"* ]] && break
  echo "Rate limited, waiting ${i}s..."
  sleep $i
done
```

## For AI Agents

### Robust .env loading
```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/common.sh"
load_credentials
```

### Pre-flight checks
```bash
: "${TESTRAIL_URL:?TESTRAIL_URL not set}"
: "${TESTRAIL_USER:?TESTRAIL_USER not set}"
: "${TESTRAIL_API_KEY:?TESTRAIL_API_KEY not set}"
```

### Fallback for Windows
If Bash unavailable, check paths:
```bash
/c/Program\ Files/Git/bin/bash.exe
C:/Program\ Files/Git/usr/bin/bash.exe
```

Last resort: translate to PowerShell (see agent-guide.md)
