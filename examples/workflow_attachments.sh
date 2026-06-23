#!/usr/bin/env bash
# Exercise TestRail attachment endpoints with disposable fixtures

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
source "${REPO_ROOT}/scripts/common.sh"

load_credentials

PROJECT_ID="${1:?Usage: $0 PROJECT_ID SUITE_ID SECTION_ID}"
SUITE_ID="${2:?Usage: $0 PROJECT_ID SUITE_ID SECTION_ID}"
SECTION_ID="${3:?Usage: $0 PROJECT_ID SUITE_ID SECTION_ID}"

CASE_ID=""
RUN_ID=""
TEST_ID=""
RESULT_ID=""
PLAN_ID=""
ENTRY_ID=""
CASE_ATTACHMENT_ID=""
RESULT_ATTACHMENT_ID=""
PLAN_ATTACHMENT_ID=""
PLAN_ENTRY_ATTACHMENT_ID=""

attachment_items_filter='if type == "object" and has("attachments") then .attachments else . end'

cleanup() {
  local exit_code=$?

  set +e

  for attachment_id in "${PLAN_ENTRY_ATTACHMENT_ID:-}" "${PLAN_ATTACHMENT_ID:-}" "${RESULT_ATTACHMENT_ID:-}" "${CASE_ATTACHMENT_ID:-}"; do
    if [[ -n "$attachment_id" ]]; then
      /usr/bin/bash "${REPO_ROOT}/scripts/delete_attachment.sh" "$attachment_id" >/dev/null 2>&1 || true
    fi
  done

  if [[ -n "${PLAN_ID:-}" ]]; then
    testrail_api POST "delete_plan/${PLAN_ID}" -H "Content-Type: application/json" >/dev/null 2>&1 || true
  fi

  if [[ -n "${RUN_ID:-}" ]]; then
    testrail_api POST "delete_run/${RUN_ID}" -H "Content-Type: application/json" >/dev/null 2>&1 || true
  fi

  if [[ -n "${CASE_ID:-}" ]]; then
    testrail_api POST "delete_case/${CASE_ID}" -H "Content-Type: application/json" >/dev/null 2>&1 || true
  fi

  testrail_cleanup
  return "$exit_code"
}

trap cleanup EXIT

testrail_make_temp_file ATTACHMENT_FILE attachment
printf 'attachment verification fixture %s\n' "$(date +%s)" > "$ATTACHMENT_FILE"

created_case="$(
  /usr/bin/bash "${REPO_ROOT}/examples/create_case.sh" \
    "$SECTION_ID" \
    "[DISPOSABLE] attachment-case $(date +%s)" \
    "AUTO-ATTACH-CASE-$(date +%s)"
)"
CASE_ID="$(printf '%s\n' "$created_case" | jq -r '.id')"

case_attachment="$(
  /usr/bin/bash "${REPO_ROOT}/scripts/add_attachment.sh" \
    case "$CASE_ID" "$ATTACHMENT_FILE"
)"
CASE_ATTACHMENT_ID="$(printf '%s\n' "$case_attachment" | jq -r '.attachment_id // .id')"
printf '%s\n' "$case_attachment" | jq -e --argjson id "$CASE_ATTACHMENT_ID" '(.attachment_id // .id) == $id' >/dev/null

case_attachments="$(
  /usr/bin/bash "${REPO_ROOT}/scripts/get_attachments.sh" case "$CASE_ID"
)"
printf '%s\n' "$case_attachments" | jq -e --argjson id "$CASE_ATTACHMENT_ID" \
  "${attachment_items_filter} | any(.id == \$id)" >/dev/null

run_json="$(
  /usr/bin/bash "${REPO_ROOT}/scripts/create_run.sh" \
    "$PROJECT_ID" "$SUITE_ID" "[DISPOSABLE] attachment-run $(date +%s)" "1,2"
)"
RUN_ID="$(printf '%s\n' "$run_json" | jq -r '.id')"
tests_json="$(testrail_api GET "get_tests/${RUN_ID}" -H "Content-Type: application/json")"
TEST_ID="$(printf '%s\n' "$tests_json" | jq -r '.tests[0].id')"
RESULT_ID="$(
  /usr/bin/bash "${REPO_ROOT}/scripts/add_result.sh" \
    "$TEST_ID" 1 "Attachment verification result" "5s" | jq -r '.id'
)"

result_attachment="$(
  /usr/bin/bash "${REPO_ROOT}/scripts/add_attachment.sh" \
    result "$RESULT_ID" "$ATTACHMENT_FILE"
)"
RESULT_ATTACHMENT_ID="$(printf '%s\n' "$result_attachment" | jq -r '.attachment_id // .id')"

test_attachments="$(
  /usr/bin/bash "${REPO_ROOT}/scripts/get_attachments.sh" test "$TEST_ID"
)"
printf '%s\n' "$test_attachments" | jq -e --argjson id "$RESULT_ATTACHMENT_ID" \
  "${attachment_items_filter} | any(.id == \$id)" >/dev/null

testrail_make_temp_file PLAN_PAYLOAD attachment-plan
jq -n \
  --arg name "[DISPOSABLE] attachment-plan $(date +%s)" \
  --arg description "Disposable plan for attachment verification" \
  --argjson suite_id "$SUITE_ID" \
  '{
    name: $name,
    description: $description,
    entries: [
      {
        suite_id: $suite_id,
        name: "attachment-entry",
        include_all: false,
        case_ids: [1, 2]
      }
    ]
  }' > "$PLAN_PAYLOAD"

plan_json="$(testrail_api POST "add_plan/${PROJECT_ID}" -H "Content-Type: application/json" --data @"$PLAN_PAYLOAD")"
PLAN_ID="$(printf '%s\n' "$plan_json" | jq -r '.id')"
ENTRY_ID="$(printf '%s\n' "$plan_json" | jq -r '.entries[0].id')"

plan_attachment="$(
  /usr/bin/bash "${REPO_ROOT}/scripts/add_attachment.sh" \
    plan "$PLAN_ID" "$ATTACHMENT_FILE"
)"
PLAN_ATTACHMENT_ID="$(printf '%s\n' "$plan_attachment" | jq -r '.attachment_id // .id')"

plan_entry_attachment="$(
  /usr/bin/bash "${REPO_ROOT}/scripts/add_attachment.sh" \
    plan_entry "$PLAN_ID" "$ENTRY_ID" "$ATTACHMENT_FILE"
)"
PLAN_ENTRY_ATTACHMENT_ID="$(printf '%s\n' "$plan_entry_attachment" | jq -r '.attachment_id // .id')"

/usr/bin/bash "${REPO_ROOT}/scripts/delete_attachment.sh" "$CASE_ATTACHMENT_ID" >/dev/null
deleted_case_attachment_id="$CASE_ATTACHMENT_ID"
CASE_ATTACHMENT_ID=""
case_attachments_after_delete="$(
  /usr/bin/bash "${REPO_ROOT}/scripts/get_attachments.sh" case "$CASE_ID"
)"
printf '%s\n' "$case_attachments_after_delete" | jq -e --argjson id "$deleted_case_attachment_id" \
  "(${attachment_items_filter} | any(.id == \$id)) | not" >/dev/null

/usr/bin/bash "${REPO_ROOT}/scripts/delete_attachment.sh" "$RESULT_ATTACHMENT_ID" >/dev/null
deleted_result_attachment_id="$RESULT_ATTACHMENT_ID"
RESULT_ATTACHMENT_ID=""
test_attachments_after_delete="$(
  /usr/bin/bash "${REPO_ROOT}/scripts/get_attachments.sh" test "$TEST_ID"
)"
printf '%s\n' "$test_attachments_after_delete" | jq -e --argjson id "$deleted_result_attachment_id" \
  "(${attachment_items_filter} | any(.id == \$id)) | not" >/dev/null

/usr/bin/bash "${REPO_ROOT}/scripts/delete_attachment.sh" "$PLAN_ATTACHMENT_ID" >/dev/null
PLAN_ATTACHMENT_ID=""
/usr/bin/bash "${REPO_ROOT}/scripts/delete_attachment.sh" "$PLAN_ENTRY_ATTACHMENT_ID" >/dev/null
PLAN_ENTRY_ATTACHMENT_ID=""

jq -n \
  --argjson case_id "$CASE_ID" \
  --argjson test_id "$TEST_ID" \
  --argjson result_id "$RESULT_ID" \
  --argjson plan_id "$PLAN_ID" \
  --arg entry_id "$ENTRY_ID" \
  '{
    fixtures: {
      case_id: $case_id,
      test_id: $test_id,
      result_id: $result_id,
      plan_id: $plan_id,
      entry_id: $entry_id
    },
    coverage: {
      add_attachment_to_case: true,
      add_attachment_to_result: true,
      add_attachment_to_plan: true,
      add_attachment_to_plan_entry: true,
      get_attachments_for_case: true,
      get_attachments_for_test: true,
      delete_attachment: true
    }
  }'
