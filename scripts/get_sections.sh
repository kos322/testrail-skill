#!/usr/bin/env bash
# Get sections from a TestRail suite

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

load_credentials

PROJECT_ID="${1:?Usage: $0 PROJECT_ID SUITE_ID}"
SUITE_ID="${2:?}"

testrail_api GET "get_sections/${PROJECT_ID}&suite_id=${SUITE_ID}" \
  -H "Content-Type: application/json"
