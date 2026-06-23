# TestRail API Skill

AI agent skill for TestRail REST API integration without external dependencies.

## Overview

This skill provides ready-to-use curl examples for TestRail API operations. No MCP servers, no third-party packages — just direct REST API calls that work with any AI agent supporting the open agent skills protocol.

## Features

- ✅ **Zero dependencies** — pure curl + TestRail REST API
- ✅ **20+ tested examples** — projects, cases, runs, results
- ✅ **Production-ready** — follows TestRail API best practices
- ✅ **Bulk operations** — efficient batch result uploads
- ✅ **Complete workflows** — import cases → generate tests → push results

## Installation

```bash
npx skills add KanstantsinSudzilous/testrail-skill
```

Or for global installation:

```bash
npx skills add KanstantsinSudzilous/testrail-skill -g -y
```

## Prerequisites

Set these environment variables:

```bash
export TESTRAIL_URL="https://your-company.testrail.io"
export TESTRAIL_USER="your@email.com"
export TESTRAIL_API_KEY="your-api-key"
```

Get your API key from TestRail: **My Settings → API Keys**

## Usage

Once installed, your AI agent will automatically use this skill when you mention TestRail operations:

```
"Get all test cases from project 1, section 10"
"Create a test run named 'Sprint 42 Regression' with cases [1, 2, 3]"
"Add passed result for test ID 1042"
"Upload bulk results from my test execution"
```

## What's Included

### Test Case Management
- Get projects, suites, sections
- List/get test cases with filters
- Create/update test cases with custom fields
- Get case field definitions

### Test Run Management
- List test runs
- Create test runs (all cases or specific IDs)
- Get tests in a run
- Close test runs

### Results Management
- Add result by test_id
- Add result by case_id
- Bulk add results (array)
- Get result history

### Common Workflows
1. **Import cases → generate tests**: Fetch TestRail cases and generate automated test code
2. **Execute → push results**: Create run, execute tests, upload results in bulk

## Why This Approach?

Many teams cannot use community MCP servers due to security policies. This skill:

1. Uses only official TestRail REST API
2. No external dependencies to audit
3. Full visibility into every API call
4. Easy to customize for your use cases

## Example: Create Test Run and Push Results

```bash
# Agent uses skill template to create run
curl -s -X POST -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/add_run/1" \
  -H "Content-Type: application/json" \
  -d '{"suite_id": 5, "name": "Automated Run", "case_ids": [1,2,3]}'

# Then pushes results in bulk
curl -s -X POST -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/add_results/123" \
  -H "Content-Type: application/json" \
  -d '{"results": [{"test_id": 1042, "status_id": 1, "comment": "Passed"}]}'
```

## Compatible Agents

Works with any agent supporting the open skills protocol:
- Claude Code
- Cursor
- Windsurf
- Codex
- Cline
- And 60+ more

## Documentation

Full API reference and examples: see [SKILL.md](./SKILL.md)

Official TestRail API docs: https://support.testrail.com/hc/en-us/articles/7077196481428

## Security

This skill:
- Never stores credentials
- Uses environment variables for auth
- Makes direct HTTPS calls to your TestRail instance
- No telemetry, no external services

## Contributing

Found a useful TestRail API pattern? PRs welcome!

## License

MIT License - see [LICENSE](./LICENSE)

## Author

Created for teams that need TestRail integration without external MCP dependencies.
