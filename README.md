# TestRail API Skill

AI agent skill for TestRail REST API — zero dependencies, security-friendly alternative to MCP servers.

## Features

- ✅ **Zero dependencies** — pure curl + TestRail REST API
- ✅ **Ready-to-use scripts** — read, write, metadata, and attachment helpers included
- ✅ **Production-ready** — follows TestRail API best practices
- ✅ **Cross-platform** — Linux, macOS, Windows (Git Bash/WSL)
- ✅ **Token-efficient** — modular structure, load only what you need

## Installation

```bash
npx skills add kos322/testrail-skill -g -y
```

## Quick Start

**1. Configure credentials:**
```bash
cp .env.example .env
# Edit .env with your TestRail URL, email, and API key
```

Or point at an existing env file:
```bash
export TESTRAIL_ENV_FILE=/path/to/.env
```

**2. Run the built-in health check:**
```bash
./scripts/doctor.sh | jq .
```

**3. Use scripts directly** (no `source .env` needed):
```bash
# List accessible projects
./scripts/get_projects.sh | jq '(.projects // .) | map({id, name})'

# Count total cases safely
./scripts/count_cases.sh 1

# Read one page of cases
./scripts/get_cases.sh 1 10 --suite 1
```

## Security

- ✅ **Credentials isolated** — Scripts load `.env` internally, never exposed to LLM
- ✅ **No credential leaks** — API keys don't appear in agent context or logs
- ✅ **Environment variables** — Standard `.env` file, easy to manage
- ✅ **Git-safe** — `.env` in `.gitignore` by default

## Structure

```
testrail-skill/
├── SKILL.md              # Lean agent entrypoint
├── scripts/              # Ready-to-use bash scripts
│   ├── doctor.sh         # Env/auth/access health check
│   ├── get_projects.sh   # List accessible projects
│   ├── count_cases.sh    # Count cases with pagination
│   ├── get_*.sh          # Read wrappers (projects, cases, runs, results, metadata)
│   ├── create_run.sh     # Create test run
│   ├── update_run.sh     # Update test run
│   ├── add_result*.sh    # Add single results by test or case
│   ├── add_attachment.sh # Upload attachments
│   ├── get_attachments.sh # List case/test attachments
│   ├── delete_attachment.sh # Delete attachment
│   └── close_run.sh      # Close test run
├── examples/             # Complete workflow examples
│   ├── create_case.sh                 # Create case with all fields
│   ├── workflow_ci.sh                 # Full CI integration
│   ├── workflow_plans_milestones.sh   # Plan + milestone lifecycle
│   └── workflow_attachments.sh        # Attachment lifecycle
├── powershell/           # Thin wrappers for PowerShell-only environments
│   ├── doctor.ps1
│   ├── get-projects.ps1
│   └── count-cases.ps1
└── docs/                 # Detailed documentation
    ├── api-reference.md      # API notes and payload shapes
    ├── troubleshooting.md    # Common issues & solutions
    ├── agent-guide.md        # For AI agents
    └── maintenance/          # Snapshot/verification docs
```

## Prerequisites

**Windows Users:** Use **Git Bash** ([Git for Windows](https://git-scm.com/download/win)) or **WSL**.  
If you only have PowerShell, use the thin wrappers in `powershell/`.

**Get API Key:**
1. TestRail → My Settings → API Keys → Add Key
2. Enable API: Administration → Site Settings → API → Enable API

## Documentation

- **[SKILL.md](./SKILL.md)** — Lean runtime skill entrypoint
- **[scripts/README.md](./scripts/README.md)** — Script usage guide
- **[docs/api-reference.md](./docs/api-reference.md)** — Complete API reference
- **[docs/troubleshooting.md](./docs/troubleshooting.md)** — Common issues
- **[docs/agent-guide.md](./docs/agent-guide.md)** — For AI agents
- **[docs/maintenance/endpoint-status.md](./docs/maintenance/endpoint-status.md)** — Maintenance snapshot

## Fast Answers

```bash
# How many cases are there?
./scripts/count_cases.sh 1

# What projects can I access?
./scripts/get_projects.sh | jq '(.projects // .) | map({id, name})'

# What is the case title?
./scripts/get_case.sh 1 | jq -r .title

# Does my setup actually work?
./scripts/doctor.sh | jq '{ok, project_count: .api.project_count}'
```

## Example Workflows

### Get Cases and Parse

```bash
./scripts/get_cases.sh 1 10 --suite 1 | jq '.cases[] | {id, title, priority_id}'
```

### CI Integration

```bash
# Create run
RUN_ID=$(./scripts/create_run.sh 1 5 "CI Run" | jq -r '.id')

# Run tests (your CI)
pytest --json-report

# Push results
./scripts/bulk_results.sh "$RUN_ID" test-results.json

# Close run
./scripts/close_run.sh "$RUN_ID"
```

**Security:** Scripts load credentials internally — they never appear in LLM context.

See [examples/workflow_ci.sh](./examples/workflow_ci.sh) for complete example.

### Full Lifecycle Verification

```bash
./examples/workflow_plans_milestones.sh 1 1
./examples/workflow_attachments.sh 1 1 10
```

## Why This Approach?

Many teams cannot use community MCP servers due to security policies. This skill:

1. **No external dependencies** — only official TestRail REST API
2. **Full visibility** — plain bash scripts, easy to audit
3. **Modular** — load only what you need (token-efficient)
4. **Customizable** — scripts are templates, adapt to your needs

## Token Efficiency

The skill is designed to minimize token usage:

- **SKILL.md:** kept as the lean runtime entrypoint
- **Scripts:** Loaded by reference, not inline
- **Docs:** Loaded on-demand when needed
- **Maintenance snapshots:** kept out of the main skill path
- **Examples:** Separate directory, explicit reference

AI agents should load `SKILL.md` first, then pull only the specific script/doc they need.

## Compatible Agents

- Claude Code ✅
- Cursor
- Windsurf  
- Codex
- Cline
- 60+ other MCP-compatible agents

## Security

- Never stores credentials
- Uses environment variables
- Direct HTTPS to your TestRail instance
- No telemetry, no external services

## Contributing

PRs welcome! See useful TestRail patterns? Add a script or example.

## License

MIT — see [LICENSE](./LICENSE)

## Links

- **Repository:** https://github.com/kos322/testrail-skill
- **TestRail API Docs:** https://support.testrail.com/hc/en-us/categories/7076541806228-API-Manual
- **Skills Marketplace:** https://skills.sh
