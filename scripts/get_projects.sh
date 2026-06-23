#!/usr/bin/env bash
# List projects accessible to the authenticated TestRail user

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

load_credentials

testrail_api GET "get_projects" \
  -H "Content-Type: application/json"
