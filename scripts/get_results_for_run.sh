#!/usr/bin/env bash
# Get all results for a TestRail run

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

load_credentials

RUN_ID="${1:?Usage: $0 RUN_ID}"

testrail_api GET "get_results_for_run/${RUN_ID}" \
  -H "Content-Type: application/json"
