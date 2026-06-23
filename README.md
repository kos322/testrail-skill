# TestRail API Skill

AI agent skill for TestRail REST API — zero dependencies, security-friendly alternative to MCP servers.

## Features

- ✅ **Zero dependencies** — pure curl + TestRail REST API
- ✅ **Ready-to-use scripts** — 6 common operations pre-built
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

**2. Use scripts directly** (no `source .env` needed):
```bash
# Get test cases
./scripts/get_cases.sh 1 10

# Create test run
./scripts/create_run.sh 1 5 "Sprint 42 Regression"

# Add test result
./scripts/add_result.sh 1042 1 "Passed in CI"
```

## Security

- ✅ **Credentials isolated** — Scripts load `.env` internally, never exposed to LLM
- ✅ **No credential leaks** — API keys don't appear in agent context or logs
- ✅ **Environment variables** — Standard `.env` file, easy to manage
- ✅ **Git-safe** — `.env` in `.gitignore` by default

## Structure

```
testrail-skill/
├── SKILL.md              # Main skill file (~150 lines)
├── scripts/              # Ready-to-use bash scripts
│   ├── get_cases.sh      # Get test cases
│   ├── create_run.sh     # Create test run
│   ├── add_result.sh     # Add single result
│   ├── bulk_results.sh   # Bulk upload results
│   ├── import_cases.sh   # Export cases to JSON
│   └── close_run.sh      # Close test run
├── examples/             # Complete workflow examples
│   ├── create_case.sh    # Create case with all fields
│   └── workflow_ci.sh    # Full CI integration
└── docs/                 # Detailed documentation
    ├── api-reference.md  # All 20+ API endpoints
    ├── troubleshooting.md # Common issues & solutions
    └── agent-guide.md    # For AI agents
```

## Prerequisites

**Windows Users:** Use **Git Bash** ([Git for Windows](https://git-scm.com/download/win)) or **WSL**.  
Claude Code's Bash tool works seamlessly with Git Bash.

**Get API Key:**
1. TestRail → My Settings → API Keys → Add Key
2. Enable API: Administration → Site Settings → API → Enable API

## Documentation

- **[SKILL.md](./SKILL.md)** — Core skill (150 lines, token-efficient)
- **[scripts/README.md](./scripts/README.md)** — Script usage guide
- **[docs/api-reference.md](./docs/api-reference.md)** — Complete API reference
- **[docs/troubleshooting.md](./docs/troubleshooting.md)** — Common issues
- **[docs/agent-guide.md](./docs/agent-guide.md)** — For AI agents

## Example Workflows

### Get Cases and Parse

```bash
./scripts/get_cases.sh 1 10 | jq '.cases[] | {id, title, priority_id}'
```

### CI Integration

```bash
# Create run
RUN_ID=$(./scripts/create_run.sh 1 5 "CI Run" | jq -r '.run.id')

# Run tests (your CI)
pytest --json-report

# Push results
./scripts/bulk_results.sh "$RUN_ID" test-results.json

# Close run
./scripts/close_run.sh "$RUN_ID"
```

**Security:** Scripts load credentials internally — they never appear in LLM context.

See [examples/workflow_ci.sh](./examples/workflow_ci.sh) for complete example.

## Why This Approach?

Many teams cannot use community MCP servers due to security policies. This skill:

1. **No external dependencies** — only official TestRail REST API
2. **Full visibility** — plain bash scripts, easy to audit
3. **Modular** — load only what you need (token-efficient)
4. **Customizable** — scripts are templates, adapt to your needs

## Token Efficiency

The skill is designed to minimize token usage:

- **SKILL.md:** ~150 lines (was 635) — 76% reduction
- **Scripts:** Loaded by reference, not inline
- **Docs:** Loaded on-demand when needed
- **Examples:** Separate directory, explicit reference

AI agents load SKILL.md (~3K tokens) and reference scripts/docs as needed.

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
