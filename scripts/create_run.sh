#!/usr/bin/env bash
# Create a test run in TestRail

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

load_credentials

PROJECT_ID="${1:?Usage: $0 PROJECT_ID SUITE_ID NAME [CASE_IDS]}"
SUITE_ID="${2:?}"
NAME="${3:?}"
CASE_IDS="${4:-}"  # Optional: comma-separated like "1,2,3"

testrail_make_temp_file PAYLOAD add-run

if [[ -n "$CASE_IDS" ]]; then
  CASE_ARRAY="$(printf '%s\n' "$CASE_IDS" | jq -Rc 'split(",") | map(gsub("^\\s+|\\s+$"; "")) | map(select(length > 0) | tonumber)')"
  jq -n \
    --argjson suite_id "$SUITE_ID" \
    --arg name "$NAME" \
    --argjson case_ids "$CASE_ARRAY" \
    '{suite_id: $suite_id, name: $name, include_all: false, case_ids: $case_ids}' > "$PAYLOAD"
else
  jq -n \
    --argjson suite_id "$SUITE_ID" \
    --arg name "$NAME" \
    '{suite_id: $suite_id, name: $name, include_all: true}' > "$PAYLOAD"
fi

testrail_api POST "add_run/${PROJECT_ID}" \
  -H "Content-Type: application/json" \
  --data @"$PAYLOAD"
