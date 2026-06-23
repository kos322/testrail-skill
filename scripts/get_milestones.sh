#!/usr/bin/env bash
# Get milestones from a TestRail project

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

load_credentials

PROJECT_ID="${1:?Usage: $0 PROJECT_ID}"

testrail_api GET "get_milestones/${PROJECT_ID}" \
  -H "Content-Type: application/json"
