#!/usr/bin/env bash
# Bulk upload test results to TestRail

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

load_credentials

RUN_ID="${1:?Usage: $0 RUN_ID RESULTS_FILE}"
RESULTS_FILE="${2:?}"

[[ -f "$RESULTS_FILE" ]] || { echo "Error: $RESULTS_FILE not found"; exit 1; }
jq -e '.results and (.results | type == "array")' "$RESULTS_FILE" >/dev/null || {
  echo "Error: $RESULTS_FILE must contain a JSON object with a results array" >&2
  exit 1
}

testrail_api POST "add_results/${RUN_ID}" \
  -H "Content-Type: application/json" \
  --data @"$RESULTS_FILE"
