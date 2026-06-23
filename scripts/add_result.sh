#!/usr/bin/env bash
# Add a single test result to TestRail

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

load_credentials

TEST_ID="${1:?Usage: $0 TEST_ID STATUS_ID COMMENT [ELAPSED]}"
STATUS_ID="${2:?}"
COMMENT="${3:?}"
ELAPSED="${4:-}"

PAYLOAD=$(mktemp)
trap "rm -f $PAYLOAD" EXIT

if [[ -n "$ELAPSED" ]]; then
  cat > "$PAYLOAD" <<EOF
{
  "status_id": $STATUS_ID,
  "comment": "$COMMENT",
  "elapsed": "$ELAPSED"
}
EOF
else
  cat > "$PAYLOAD" <<EOF
{
  "status_id": $STATUS_ID,
  "comment": "$COMMENT"
}
EOF
fi

curl -s -X POST -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/add_result/${TEST_ID}" \
  -H "Content-Type: application/json" \
  -d @"$PAYLOAD"
