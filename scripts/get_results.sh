#!/usr/bin/env bash
# Get results for a single TestRail test

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

load_credentials

TEST_ID="${1:?Usage: $0 TEST_ID}"

testrail_api GET "get_results/${TEST_ID}" \
  -H "Content-Type: application/json"
