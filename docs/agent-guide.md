# Guide for AI Agents

Use this file when an agent needs execution guidance, not full API reference.

## Recommended flow

1. Run `./scripts/doctor.sh`
2. Run `./scripts/get_projects.sh`
3. Use `./scripts/count_cases.sh` for totals
4. Use `./scripts/get_cases.sh` for raw paginated responses

This avoids the most common failures: missing env files, unknown project IDs, and misread pagination.

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
.\powershell\doctor.ps1
.\powershell\get-projects.ps1
.\powershell\count-cases.ps1 1
```

Wrappers only forward to the bash scripts. They do not parse `.env` or reconstruct auth in PowerShell.

## Pagination

`get_cases`, `get_runs`, `get_results*`, and similar endpoints can be paginated.

- Do **not** treat `.size` as the final total unless `_links.next` is empty.
- Use `./scripts/count_cases.sh` when you need a total.
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
