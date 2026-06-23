#!/usr/bin/env bash
# Update a TestRail case

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

load_credentials

CASE_ID="${1:?Usage: $0 CASE_ID TITLE [PRIORITY_ID]}"
TITLE="${2:?Usage: $0 CASE_ID TITLE [PRIORITY_ID]}"
PRIORITY_ID="${3:-}"

testrail_make_temp_file PAYLOAD update-case

if [[ -n "$PRIORITY_ID" ]]; then
  jq -n \
    --arg title "$TITLE" \
    --argjson priority_id "$PRIORITY_ID" \
    '{title: $title, priority_id: $priority_id}' > "$PAYLOAD"
else
  jq -n \
    --arg title "$TITLE" \
    '{title: $title}' > "$PAYLOAD"
fi

testrail_api POST "update_case/${CASE_ID}" \
  -H "Content-Type: application/json" \
  --data @"$PAYLOAD"
