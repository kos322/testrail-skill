#!/usr/bin/env bash
# Update a TestRail run

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

load_credentials

RUN_ID="${1:?Usage: $0 RUN_ID NAME [DESCRIPTION]}"
NAME="${2:?Usage: $0 RUN_ID NAME [DESCRIPTION]}"
DESCRIPTION="${3:-}"

testrail_make_temp_file PAYLOAD update-run

if [[ -n "$DESCRIPTION" ]]; then
  jq -n \
    --arg name "$NAME" \
    --arg description "$DESCRIPTION" \
    '{name: $name, description: $description}' > "$PAYLOAD"
else
  jq -n \
    --arg name "$NAME" \
    '{name: $name}' > "$PAYLOAD"
fi

testrail_api POST "update_run/${RUN_ID}" \
  -H "Content-Type: application/json" \
  --data @"$PAYLOAD"
