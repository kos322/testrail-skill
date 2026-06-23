#!/usr/bin/env bash
# Validate the local TestRail skill setup and API access

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

load_credentials

PROJECTS_JSON="$(testrail_api GET "get_projects" -H "Content-Type: application/json")"

PROJECT_COUNT="$(printf '%s\n' "$PROJECTS_JSON" | jq '(.projects // .) | length')"
CURL_VERSION="$(curl --version | head -n 1)"
JQ_VERSION="$(jq --version)"
ENV_FILE_LABEL="${TESTRAIL_ENV_FILE_USED:-environment variables only}"
ENV_SOURCE_LABEL="${TESTRAIL_ENV_SOURCE:-environment}"

jq -n \
  --arg ok "true" \
  --arg repo_root "$TESTRAIL_REPO_ROOT" \
  --arg env_file "$ENV_FILE_LABEL" \
  --arg env_source "$ENV_SOURCE_LABEL" \
  --arg api_url "$TESTRAIL_URL" \
  --arg bash_version "${BASH_VERSION:-unknown}" \
  --arg curl_version "$CURL_VERSION" \
  --arg jq_version "$JQ_VERSION" \
  --argjson projects "$PROJECTS_JSON" \
  --argjson project_count "$PROJECT_COUNT" \
  '{
    ok: ($ok == "true"),
    repo_root: $repo_root,
    env: {
      source: $env_source,
      file: $env_file
    },
    tools: {
      bash: $bash_version,
      curl: $curl_version,
      jq: $jq_version
    },
    api: {
      url: $api_url,
      authenticated: true,
      project_count: $project_count,
      project_ids: (($projects.projects // $projects) | map(.id)),
      projects: (($projects.projects // $projects) | map({id, name}))
    }
  }'
