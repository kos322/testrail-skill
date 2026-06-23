#!/usr/bin/env bash
# Get test cases from TestRail project/section

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

load_credentials

PROJECT_ID="${1:?Usage: $0 PROJECT_ID [SECTION_ID]}"
SECTION_ID="${2:-}"

ENDPOINT="${TESTRAIL_URL}/index.php?/api/v2/get_cases/${PROJECT_ID}"
[[ -n "$SECTION_ID" ]] && ENDPOINT+="&section_id=${SECTION_ID}"

curl -s -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" "$ENDPOINT" \
  -H "Content-Type: application/json"
