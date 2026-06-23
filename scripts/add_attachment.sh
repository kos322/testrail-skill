#!/usr/bin/env bash
# Add a TestRail attachment to a supported entity

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

load_credentials

RESOURCE="${1:?Usage: $0 RESOURCE ...}"

case "$RESOURCE" in
  case)
    CASE_ID="${2:?Usage: $0 case CASE_ID FILE}"
    FILE_PATH="${3:?Usage: $0 case CASE_ID FILE}"
    ENDPOINT="add_attachment_to_case/${CASE_ID}"
    ;;
  result)
    RESULT_ID="${2:?Usage: $0 result RESULT_ID FILE}"
    FILE_PATH="${3:?Usage: $0 result RESULT_ID FILE}"
    ENDPOINT="add_attachment_to_result/${RESULT_ID}"
    ;;
  plan)
    PLAN_ID="${2:?Usage: $0 plan PLAN_ID FILE}"
    FILE_PATH="${3:?Usage: $0 plan PLAN_ID FILE}"
    ENDPOINT="add_attachment_to_plan/${PLAN_ID}"
    ;;
  plan_entry)
    PLAN_ID="${2:?Usage: $0 plan_entry PLAN_ID ENTRY_ID FILE}"
    ENTRY_ID="${3:?Usage: $0 plan_entry PLAN_ID ENTRY_ID FILE}"
    FILE_PATH="${4:?Usage: $0 plan_entry PLAN_ID ENTRY_ID FILE}"
    ENDPOINT="add_attachment_to_plan_entry/${PLAN_ID}/${ENTRY_ID}"
    ;;
  *)
    echo "Error: unsupported resource '${RESOURCE}'" >&2
    echo "Supported resources: case, result, plan, plan_entry" >&2
    exit 1
    ;;
esac

[[ -f "$FILE_PATH" ]] || {
  echo "Error: attachment file '$FILE_PATH' not found" >&2
  exit 1
}

testrail_api POST "$ENDPOINT" \
  -F "attachment=@${FILE_PATH}"
