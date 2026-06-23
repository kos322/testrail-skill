#!/usr/bin/env bash
# Get a single TestRail case by ID

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

load_credentials

CASE_ID="${1:?Usage: $0 CASE_ID}"

testrail_api GET "get_case/${CASE_ID}" \
  -H "Content-Type: application/json"
