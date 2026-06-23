#!/usr/bin/env bash
# Bulk upload test results to TestRail

set -euo pipefail

RUN_ID="${1:?Usage: $0 RUN_ID RESULTS_FILE}"
RESULTS_FILE="${2:?}"

: "${TESTRAIL_URL:?TESTRAIL_URL not set}"
: "${TESTRAIL_USER:?TESTRAIL_USER not set}"
: "${TESTRAIL_API_KEY:?TESTRAIL_API_KEY not set}"

[[ -f "$RESULTS_FILE" ]] || { echo "Error: $RESULTS_FILE not found"; exit 1; }

curl -s -X POST -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/add_results/${RUN_ID}" \
  -H "Content-Type: application/json" \
  -d @"$RESULTS_FILE"
