#!/usr/bin/env bash
# Get reusable TestRail reference data and user metadata

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

load_credentials

RESOURCE="${1:-}"

if [[ -z "$RESOURCE" ]]; then
  echo "Usage: $0 RESOURCE [ARG]" >&2
  echo "Supported resources: statuses, case_fields, priorities, case_types, templates, result_fields, users, user, user_by_email" >&2
  exit 1
fi

case "$RESOURCE" in
  statuses)
    ENDPOINT="get_statuses"
    ;;
  case_fields)
    ENDPOINT="get_case_fields"
    ;;
  priorities)
    ENDPOINT="get_priorities"
    ;;
  case_types)
    ENDPOINT="get_case_types"
    ;;
  templates)
    PROJECT_ID="${2:?Usage: $0 templates PROJECT_ID}"
    ENDPOINT="get_templates/${PROJECT_ID}"
    ;;
  result_fields)
    ENDPOINT="get_result_fields"
    ;;
  users)
    ENDPOINT="get_users"
    ;;
  user)
    USER_ID="${2:?Usage: $0 user USER_ID}"
    ENDPOINT="get_user/${USER_ID}"
    ;;
  user_by_email)
    EMAIL="${2:?Usage: $0 user_by_email EMAIL}"
    EMAIL_ENCODED="$(jq -nr --arg value "$EMAIL" '$value|@uri')"
    ENDPOINT="get_user_by_email&email=${EMAIL_ENCODED}"
    ;;
  *)
    echo "Error: unsupported resource '$RESOURCE'" >&2
    echo "Supported resources: statuses, case_fields, priorities, case_types, templates, result_fields, users, user, user_by_email" >&2
    exit 1
    ;;
esac

testrail_api GET "$ENDPOINT" \
  -H "Content-Type: application/json"
