#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test_helper.sh"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source .env for user email
if [ -f "$REPO_ROOT/.env" ]; then
  source "$REPO_ROOT/.env"
fi

echo "Testing get_suites (using direct API)..."
SUITES_OUT=$(bash -c "source \"$REPO_ROOT/scripts/common.sh\" && load_credentials && testrail_api GET \"get_suites/1\" -H \"Content-Type: application/json\"" | jq -r 'if type == "object" and has("suites") then "array" elif type == "array" then "array" else "other" end')
assert_eq "array" "$SUITES_OUT" "get_suites returns an array or wrapped array"

echo "Testing users endpoints..."
USERS_OUT=$(bash "$REPO_ROOT/scripts/get_reference_data.sh" users | jq -r '.users[0].id // .[0].id')
assert_eq "1" "$USERS_OUT" "users list contains user ID 1"

USER_OUT=$(bash "$REPO_ROOT/scripts/get_reference_data.sh" user 1 | jq -r '.id')
assert_eq "1" "$USER_OUT" "get_user returns correct ID"

if [[ -n "${TESTRAIL_USER:-}" ]]; then
  USER_BY_EMAIL_OUT=$(bash "$REPO_ROOT/scripts/get_reference_data.sh" user_by_email "$TESTRAIL_USER" | jq -r '.email')
  assert_eq "$TESTRAIL_USER" "$USER_BY_EMAIL_OUT" "get_user_by_email matches provided email"
fi

echo "Testing metadata fields..."
CASE_FIELDS_OUT=$(bash "$REPO_ROOT/scripts/get_reference_data.sh" case_fields | jq -r 'type')
assert_eq "array" "$CASE_FIELDS_OUT" "case_fields returns an array"

PRIORITIES_OUT=$(bash "$REPO_ROOT/scripts/get_reference_data.sh" priorities | jq -r 'type')
assert_eq "array" "$PRIORITIES_OUT" "priorities returns an array"

CASE_TYPES_OUT=$(bash "$REPO_ROOT/scripts/get_reference_data.sh" case_types | jq -r 'type')
assert_eq "array" "$CASE_TYPES_OUT" "case_types returns an array"

TEMPLATES_OUT=$(bash "$REPO_ROOT/scripts/get_reference_data.sh" templates 1 | jq -r 'type')
assert_eq "array" "$TEMPLATES_OUT" "templates returns an array"

RESULT_FIELDS_OUT=$(bash "$REPO_ROOT/scripts/get_reference_data.sh" result_fields | jq -r 'type')
assert_eq "array" "$RESULT_FIELDS_OUT" "result_fields returns an array"

assert_success 0 "Metadata endpoints tested successfully"
