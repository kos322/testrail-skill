#!/usr/bin/env bash
# Get results for a TestRail case within a run

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

load_credentials

RUN_ID="${1:?Usage: $0 RUN_ID CASE_ID}"
CASE_ID="${2:?}"

testrail_api GET "get_results_for_case/${RUN_ID}/${CASE_ID}" \
  -H "Content-Type: application/json"
