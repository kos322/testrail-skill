#!/usr/bin/env bash
# Delete a TestRail attachment

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

load_credentials

ATTACHMENT_ID="${1:?Usage: $0 ATTACHMENT_ID}"

testrail_api POST "delete_attachment/${ATTACHMENT_ID}" \
  -H "Content-Type: application/json"
