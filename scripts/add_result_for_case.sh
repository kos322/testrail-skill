#!/usr/bin/env bash
# Add a single test result to TestRail by run/case

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

load_credentials

RUN_ID="${1:?Usage: $0 RUN_ID CASE_ID STATUS_ID COMMENT [ELAPSED]}"
CASE_ID="${2:?Usage: $0 RUN_ID CASE_ID STATUS_ID COMMENT [ELAPSED]}"
STATUS_ID="${3:?Usage: $0 RUN_ID CASE_ID STATUS_ID COMMENT [ELAPSED]}"
COMMENT="${4:?Usage: $0 RUN_ID CASE_ID STATUS_ID COMMENT [ELAPSED]}"
ELAPSED="${5:-}"

testrail_make_temp_file PAYLOAD add-result-for-case

if [[ -n "$ELAPSED" ]]; then
  jq -n \
    --argjson status_id "$STATUS_ID" \
    --arg comment "$COMMENT" \
    --arg elapsed "$ELAPSED" \
    '{status_id: $status_id, comment: $comment, elapsed: $elapsed}' > "$PAYLOAD"
else
  jq -n \
    --argjson status_id "$STATUS_ID" \
    --arg comment "$COMMENT" \
    '{status_id: $status_id, comment: $comment}' > "$PAYLOAD"
fi

testrail_api POST "add_result_for_case/${RUN_ID}/${CASE_ID}" \
  -H "Content-Type: application/json" \
  --data @"$PAYLOAD"
