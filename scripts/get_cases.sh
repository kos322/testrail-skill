#!/usr/bin/env bash
# Get test cases from TestRail project/section

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

load_credentials

PROJECT_ID="${1:?Usage: $0 PROJECT_ID [SECTION_ID]}"
SECTION_ID="${2:-}"

ENDPOINT="get_cases/${PROJECT_ID}"
[[ -n "$SECTION_ID" ]] && ENDPOINT+="&section_id=${SECTION_ID}"

testrail_api GET "$ENDPOINT" \
  -H "Content-Type: application/json"
