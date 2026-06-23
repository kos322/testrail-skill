#!/usr/bin/env bash
# Close a test run in TestRail

set -euo pipefail

RUN_ID="${1:?Usage: $0 RUN_ID}"

: "${TESTRAIL_URL:?TESTRAIL_URL not set}"
: "${TESTRAIL_USER:?TESTRAIL_USER not set}"
: "${TESTRAIL_API_KEY:?TESTRAIL_API_KEY not set}"

curl -s -X POST -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/close_run/${RUN_ID}" \
  -H "Content-Type: application/json"
