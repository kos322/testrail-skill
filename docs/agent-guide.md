# Guide for AI Agents

Use this file when an agent needs execution guidance, not full API reference.

## Decision tree

1. **Known `PROJECT_ID` + simple read-only query:** call the direct wrapper immediately.
2. **Unknown `PROJECT_ID`:** run `./scripts/get_projects.sh`.
3. **First setup or env/auth error:** run `./scripts/doctor.sh`.

This keeps routine queries on the shortest path and uses discovery only when it is actually needed.

## Direct wrappers for common read intents

```bash
# Total cases
./scripts/count_cases.sh 1

# Full case list (auto-pagination)
./scripts/list_cases.sh 1
./scripts/list_cases.sh 1 --format json

# One raw page of cases
./scripts/get_cases.sh 1 10 --suite 1

# Single case title
./scripts/get_case.sh 93 | jq -r .title

# Single field / precondition
./scripts/get_case_field.sh 2 custom_preconds
./scripts/get_case_precondition.sh 2

# Sections and runs
./scripts/get_sections.sh 1 1
./scripts/get_runs.sh 1
```

## Output contracts

- `count_cases` → plain integer
- `list_cases` → plain text by default (`C{id}: {title}`)
- `list_cases --format json` → JSON object with `count` and `cases`
- `get_case` → JSON object
- `get_case_field` → plain scalar/string or compact JSON
- `get_case_precondition` → plain text/raw field value

## Credentials

- Preferred: put `.env` at the repository root.
- Override: set `TESTRAIL_ENV_FILE` to an existing env file.
- Scripts print `Using env: ...` to **stderr** when using `TESTRAIL_ENV_FILE`, when `.env` was found above the repo root, or when `TESTRAIL_SHOW_ENV_SOURCE=1`.
- Do **not** `source .env` manually in the agent conversation.

## Windows

### Preferred

Use Git Bash or WSL directly.

### PowerShell-only environment

Use the wrappers in `powershell/`:

```powershell
.\powershell\count-cases.ps1 1
.\powershell\list-cases.ps1 1
.\powershell\list-cases.ps1 1 --format json
.\powershell\get-case.ps1 93
.\powershell\get-case-field.ps1 2 custom_preconds
.\powershell\get-case-precondition.ps1 2
.\powershell\get-cases.ps1 1 10 --suite 1
.\powershell\get-sections.ps1 1 1
.\powershell\get-runs.ps1 1
.\powershell\get-projects.ps1
.\powershell\doctor.ps1
```

Wrappers only forward to the bash scripts. They do not parse `.env` or reconstruct auth in PowerShell.

## Pagination

`get_cases`, `get_runs`, `get_results*`, and similar endpoints can be paginated.

- Do **not** treat `.size` as the final total unless `_links.next` is empty.
- Use `./scripts/count_cases.sh` when you need a total.
- Use `./scripts/list_cases.sh` when you need the full list without thinking about pagination.
- Prefer `./scripts/list_cases.sh --format json` when an agent needs structured parsing.
- Keep `./scripts/get_cases.sh` for page inspection and debugging.

## Advanced / custom requests

If no wrapper exists, use the shared harness instead of hand-loading credentials:

```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/common.sh"
load_credentials
testrail_api GET "get_projects" -H "Content-Type: application/json"
```

## When something fails

- Setup/auth/env issues: `docs/troubleshooting.md`
- Payload shapes and endpoint notes: `docs/api-reference.md`
- Verification history / snapshot docs: `docs/maintenance/endpoint-status.md`
