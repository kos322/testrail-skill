#!/usr/bin/env bash
# Delete a disposable TestRail case by id

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

load_credentials

CASE_ID="${1:?Usage: $0 CASE_ID}"

testrail_api POST "delete_case/${CASE_ID}" \
  -H "Content-Type: application/json"
