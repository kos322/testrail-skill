#!/usr/bin/env bash
# Get a single field from a TestRail case

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

load_credentials

CASE_ID="${1:?Usage: $0 CASE_ID FIELD}"
FIELD="${2:?Usage: $0 CASE_ID FIELD}"

CASE_JSON="$(testrail_api GET "get_case/${CASE_ID}" -H "Content-Type: application/json")"

printf '%s\n' "$CASE_JSON" | jq -er --arg field "$FIELD" '
  if has($field) then
    .[$field]
  else
    error("Field not found: \($field)")
  end
  | if type == "string" then .
    elif type == "number" or type == "boolean" then tostring
    elif type == "null" then "null"
    else tojson
    end
'
