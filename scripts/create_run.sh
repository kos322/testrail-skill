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

PAYLOAD=$(mktemp)
trap "rm -f $PAYLOAD" EXIT

if [[ -n "$CASE_IDS" ]]; then
  # Convert "1,2,3" to [1,2,3]
  CASE_ARRAY=$(echo "[$CASE_IDS]")
  cat > "$PAYLOAD" <<EOF
{
  "suite_id": $SUITE_ID,
  "name": "$NAME",
  "include_all": false,
  "case_ids": $CASE_ARRAY
}
EOF
else
  cat > "$PAYLOAD" <<EOF
{
  "suite_id": $SUITE_ID,
  "name": "$NAME",
  "include_all": true
}
EOF
fi

curl -s -X POST -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/add_run/${PROJECT_ID}" \
  -H "Content-Type: application/json" \
  -d @"$PAYLOAD"
