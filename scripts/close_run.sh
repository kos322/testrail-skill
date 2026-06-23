#!/usr/bin/env bash
# Close a test run in TestRail

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

load_credentials

RUN_ID="${1:?Usage: $0 RUN_ID}"

curl -s -X POST -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/close_run/${RUN_ID}" \
  -H "Content-Type: application/json"
