#!/usr/bin/env bash
# Bulk upload test results to TestRail

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

load_credentials

RUN_ID="${1:?Usage: $0 RUN_ID RESULTS_FILE}"
RESULTS_FILE="${2:?}"

[[ -f "$RESULTS_FILE" ]] || { echo "Error: $RESULTS_FILE not found"; exit 1; }

curl -s -X POST -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/add_results/${RUN_ID}" \
  -H "Content-Type: application/json" \
  -d @"$RESULTS_FILE"
