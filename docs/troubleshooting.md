# Troubleshooting

## Start with `doctor.sh`

```bash
./scripts/doctor.sh | jq .
```

This is the fastest way to check:

- env loading
- `curl` / `jq` availability
- URL formatting
- authenticated API access
- accessible project IDs

## Bash not found on Windows

**Symptom:** `bash: command not found`

**Fix:**

```bash
which bash || where.exe bash
```

Common locations:

- `C:\Program Files\Git\bin\bash.exe`
- `C:\Program Files\Git\usr\bin\bash.exe`

PowerShell-only environment:

```powershell
.\powershell\doctor.ps1
```

## Credentials not loading

**Symptoms:**

- `TESTRAIL_URL not set`
- `TESTRAIL_USER not set`
- `TESTRAIL_API_KEY not set`

**Fixes:**

1. Put `.env` at the repository root, or
2. Set `TESTRAIL_ENV_FILE=/path/to/.env`

Scripts search for `.env` in the repository directory and its ancestor directories. For nonstandard env discovery they print:

```text
Using env: /path/to/.env
```

If `TESTRAIL_ENV_FILE` is set, it must point to an existing file. Set `TESTRAIL_SHOW_ENV_SOURCE=1` if you want the env source echoed on every script run.

## Authentication failed

**Symptom:** `"Authentication failed: invalid or missing user/password"`

Check:

1. API key is valid
2. Email is correct
3. API is enabled in TestRail
4. `.env` values have no trailing spaces

Quick verification:

```bash
./scripts/get_projects.sh | jq '(.projects // .) | length'
```

## API is disabled

**Symptom:** `"The API is disabled for your installation"`

Enable it in TestRail:

1. Administration
2. Site Settings
3. API
4. Enable API

## No host part in URL

**Symptom:** `curl: (3) URL rejected: No host part in the URL`

Use:

```text
TESTRAIL_URL="https://company.testrail.io"
```

Not:

```text
TESTRAIL_URL="company.testrail.io"
```

## `curl` or `jq` missing

**Symptoms:**

- `curl: command not found`
- `jq: command not found`

Git Bash usually ships with `curl`. Install `jq` via your package manager if needed.

## Pagination confusion

**Symptom:** case totals look wrong

Do not assume:

- `.size` is always the total you want
- one page equals the whole dataset

Use:

```bash
./scripts/count_cases.sh 1
./scripts/count_cases.sh 1 10 --suite 1
```

Use `get_cases.sh` only when you want the raw page payload.

## Empty response or unexpected shape

Save the raw JSON and inspect it:

```bash
./scripts/get_cases.sh 1 > response.json
cat response.json | jq .
```

If the endpoint is paginated, also inspect:

```bash
jq '{offset, limit, size, next: ._links.next}' response.json
```

## Rate limiting

The shared `testrail_api()` helper already retries `429` and `5xx` responses with exponential backoff. If you still hit limits repeatedly, reduce the request rate or rerun later.
