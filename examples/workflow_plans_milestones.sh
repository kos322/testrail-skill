#!/usr/bin/env bash
# Exercise TestRail plan and milestone endpoints with disposable fixtures

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
source "${REPO_ROOT}/scripts/common.sh"

load_credentials

PROJECT_ID="${1:?Usage: $0 PROJECT_ID SUITE_ID [PLAN_CASE_IDS] [ENTRY_CASE_IDS]}"
SUITE_ID="${2:?Usage: $0 PROJECT_ID SUITE_ID [PLAN_CASE_IDS] [ENTRY_CASE_IDS]}"
PLAN_CASE_IDS="${3:-1,2}"
ENTRY_CASE_IDS="${4:-3,5}"

PLAN_ID=""
MILESTONE_ID=""
DELETED_PLAN_ID=""
DELETED_MILESTONE_ID=""
CLOSED_PLAN_ID=""
DELETE_COMPLETED_PLAN_ALLOWED=false
DELETE_COMPLETED_PLAN_EVIDENCE=""

csv_to_json_array() {
  local csv="${1:?Usage: csv_to_json_array CSV}"

  printf '%s\n' "$csv" | jq -Rc 'split(",")
    | map(gsub("^\\s+|\\s+$"; ""))
    | map(select(length > 0) | tonumber)'
}

cleanup() {
  local exit_code=$?

  set +e

  if [[ -n "${PLAN_ID:-}" ]]; then
    testrail_api POST "delete_plan/${PLAN_ID}" \
      -H "Content-Type: application/json" >/dev/null 2>&1 || true
  fi

  if [[ -n "${MILESTONE_ID:-}" ]]; then
    testrail_api POST "delete_milestone/${MILESTONE_ID}" \
      -H "Content-Type: application/json" >/dev/null 2>&1 || true
  fi

  testrail_cleanup
  return "$exit_code"
}

trap cleanup EXIT

testrail_make_temp_file milestone_payload add-milestone
testrail_make_temp_file update_milestone_payload update-milestone
testrail_make_temp_file plan_payload add-plan
testrail_make_temp_file update_plan_payload update-plan
testrail_make_temp_file entry_payload add-plan-entry
testrail_make_temp_file update_entry_payload update-plan-entry

initial_case_ids_json="$(csv_to_json_array "$PLAN_CASE_IDS")"
entry_case_ids_json="$(csv_to_json_array "$ENTRY_CASE_IDS")"
updated_entry_case_ids_json="$(printf '%s\n' "$entry_case_ids_json" | jq '.[0:1]')"

fixture_suffix="$(date +%s)"
fixture_name="autotest-plan-milestone-${fixture_suffix}"

plans_before="$(testrail_api GET "get_plans/${PROJECT_ID}" -H "Content-Type: application/json")"
milestones_before="$(testrail_api GET "get_milestones/${PROJECT_ID}" -H "Content-Type: application/json")"

jq -n \
  --arg name "${fixture_name}-milestone" \
  --arg description "Disposable milestone fixture for plan endpoint coverage" \
  '{name: $name, description: $description}' > "$milestone_payload"

created_milestone="$(testrail_api POST "add_milestone/${PROJECT_ID}" \
  -H "Content-Type: application/json" \
  --data @"$milestone_payload")"
MILESTONE_ID="$(printf '%s\n' "$created_milestone" | jq -r '.id')"

milestones_after_create="$(testrail_api GET "get_milestones/${PROJECT_ID}" -H "Content-Type: application/json")"
printf '%s\n' "$milestones_after_create" | jq -e --argjson id "$MILESTONE_ID" \
  '(.milestones // .) | any(.id == $id)' >/dev/null

loaded_milestone="$(testrail_api GET "get_milestone/${MILESTONE_ID}" -H "Content-Type: application/json")"
printf '%s\n' "$loaded_milestone" | jq -e --argjson id "$MILESTONE_ID" '.id == $id' >/dev/null

jq -n \
  --arg description "Updated disposable milestone fixture" \
  --arg refs "AUTO-PLAN-${fixture_suffix}" \
  '{description: $description, refs: $refs}' > "$update_milestone_payload"

updated_milestone="$(testrail_api POST "update_milestone/${MILESTONE_ID}" \
  -H "Content-Type: application/json" \
  --data @"$update_milestone_payload")"
printf '%s\n' "$updated_milestone" | jq -e \
  --arg description "Updated disposable milestone fixture" \
  --arg refs "AUTO-PLAN-${fixture_suffix}" \
  '.description == $description and .refs == $refs' >/dev/null

DELETED_MILESTONE_ID="$MILESTONE_ID"
testrail_api POST "delete_milestone/${MILESTONE_ID}" -H "Content-Type: application/json" >/dev/null
MILESTONE_ID=""

milestones_after_delete="$(testrail_api GET "get_milestones/${PROJECT_ID}" -H "Content-Type: application/json")"
printf '%s\n' "$milestones_after_delete" | jq -e --argjson id "$DELETED_MILESTONE_ID" \
  '((.milestones // .) | any(.id == $id)) | not' >/dev/null

jq -n \
  --arg name "${fixture_name}-plan" \
  --arg description "Disposable plan fixture for endpoint coverage" \
  --argjson suite_id "$SUITE_ID" \
  --argjson case_ids "$initial_case_ids_json" \
  '{
    name: $name,
    description: $description,
    entries: [
      {
        suite_id: $suite_id,
        name: "fixture-entry-a",
        include_all: false,
        case_ids: $case_ids
      }
    ]
  }' > "$plan_payload"

created_plan="$(testrail_api POST "add_plan/${PROJECT_ID}" \
  -H "Content-Type: application/json" \
  --data @"$plan_payload")"
PLAN_ID="$(printf '%s\n' "$created_plan" | jq -r '.id')"
ENTRY1_ID="$(printf '%s\n' "$created_plan" | jq -r '.entries[0].id')"
RUN1_ID="$(printf '%s\n' "$created_plan" | jq -r '.entries[0].runs[0].id')"

plans_after_create="$(testrail_api GET "get_plans/${PROJECT_ID}" -H "Content-Type: application/json")"
printf '%s\n' "$plans_after_create" | jq -e --argjson id "$PLAN_ID" \
  '(.plans // .) | any(.id == $id)' >/dev/null

loaded_plan="$(testrail_api GET "get_plan/${PLAN_ID}" -H "Content-Type: application/json")"
printf '%s\n' "$loaded_plan" | jq -e --argjson id "$PLAN_ID" --arg entry_id "$ENTRY1_ID" \
  '.id == $id and (.entries | any(.id == $entry_id))' >/dev/null

jq -n \
  --arg name "${fixture_name}-plan-updated" \
  --arg description "Updated disposable plan fixture" \
  '{name: $name, description: $description}' > "$update_plan_payload"

updated_plan="$(testrail_api POST "update_plan/${PLAN_ID}" \
  -H "Content-Type: application/json" \
  --data @"$update_plan_payload")"
printf '%s\n' "$updated_plan" | jq -e \
  --arg name "${fixture_name}-plan-updated" \
  --arg description "Updated disposable plan fixture" \
  '.name == $name and .description == $description' >/dev/null

jq -n \
  --argjson suite_id "$SUITE_ID" \
  --argjson case_ids "$entry_case_ids_json" \
  '{
    suite_id: $suite_id,
    name: "fixture-entry-b",
    include_all: false,
    case_ids: $case_ids
  }' > "$entry_payload"

added_entry="$(testrail_api POST "add_plan_entry/${PLAN_ID}" \
  -H "Content-Type: application/json" \
  --data @"$entry_payload")"
ENTRY2_ID="$(printf '%s\n' "$added_entry" | jq -r '.id')"
RUN2_ID="$(printf '%s\n' "$added_entry" | jq -r '.runs[0].id')"

jq -n \
  --argjson case_ids "$updated_entry_case_ids_json" \
  '{
    name: "fixture-entry-b-updated",
    include_all: false,
    case_ids: $case_ids
  }' > "$update_entry_payload"

updated_entry="$(testrail_api POST "update_plan_entry/${PLAN_ID}/${ENTRY2_ID}" \
  -H "Content-Type: application/json" \
  --data @"$update_entry_payload")"
printf '%s\n' "$updated_entry" | jq -e --arg name "fixture-entry-b-updated" \
  '.name == $name and (.runs | length) == 1' >/dev/null

run1_tests="$(testrail_api GET "get_tests/${RUN1_ID}" -H "Content-Type: application/json")"
run2_tests="$(testrail_api GET "get_tests/${RUN2_ID}" -H "Content-Type: application/json")"

printf '%s\n' "$run1_tests" | jq -e --argjson case_ids "$initial_case_ids_json" \
  '[.tests[].case_id] == $case_ids' >/dev/null
printf '%s\n' "$run2_tests" | jq -e --argjson case_ids "$updated_entry_case_ids_json" \
  '[.tests[].case_id] == $case_ids' >/dev/null

DELETED_PLAN_ID="$PLAN_ID"
testrail_api POST "delete_plan/${PLAN_ID}" -H "Content-Type: application/json" >/dev/null
PLAN_ID=""

plans_after_delete="$(testrail_api GET "get_plans/${PROJECT_ID}" -H "Content-Type: application/json")"
printf '%s\n' "$plans_after_delete" | jq -e --argjson id "$DELETED_PLAN_ID" \
  '((.plans // .) | any(.id == $id)) | not' >/dev/null

jq -n \
  --arg name "${fixture_name}-close-only-plan" \
  --arg description "Disposable close-plan fixture (server may block later deletion)" \
  --argjson suite_id "$SUITE_ID" \
  --argjson case_ids "$initial_case_ids_json" \
  '{
    name: $name,
    description: $description,
    entries: [
      {
        suite_id: $suite_id,
        name: "fixture-close-entry",
        include_all: false,
        case_ids: $case_ids
      }
    ]
  }' > "$plan_payload"

closed_plan_created="$(testrail_api POST "add_plan/${PROJECT_ID}" \
  -H "Content-Type: application/json" \
  --data @"$plan_payload")"
CLOSED_PLAN_ID="$(printf '%s\n' "$closed_plan_created" | jq -r '.id')"

closed_plan="$(testrail_api POST "close_plan/${CLOSED_PLAN_ID}" -H "Content-Type: application/json")"
printf '%s\n' "$closed_plan" | jq -e '.is_completed == true' >/dev/null

set +e
DELETE_COMPLETED_PLAN_EVIDENCE="$(
  { testrail_api POST "delete_plan/${CLOSED_PLAN_ID}" -H "Content-Type: application/json" >/dev/null; } 2>&1
)"
delete_completed_plan_status=$?
set -e

if [[ "$delete_completed_plan_status" -eq 0 ]]; then
  DELETE_COMPLETED_PLAN_ALLOWED=true
  CLOSED_PLAN_ID=""
else
  DELETE_COMPLETED_PLAN_ALLOWED=false
fi

jq -n \
  --argjson project_id "$PROJECT_ID" \
  --argjson suite_id "$SUITE_ID" \
  --argjson milestone_id "$DELETED_MILESTONE_ID" \
  --argjson plan_id "$DELETED_PLAN_ID" \
  --argjson closed_plan_id "${CLOSED_PLAN_ID:-null}" \
  --arg entry1_id "$ENTRY1_ID" \
  --arg entry2_id "$ENTRY2_ID" \
  --argjson run1_id "$RUN1_ID" \
  --argjson run2_id "$RUN2_ID" \
  --argjson initial_case_ids "$initial_case_ids_json" \
  --argjson updated_entry_case_ids "$updated_entry_case_ids_json" \
  --arg delete_completed_plan_evidence "$DELETE_COMPLETED_PLAN_EVIDENCE" \
  --argjson delete_completed_plan_allowed "$DELETE_COMPLETED_PLAN_ALLOWED" \
  --argjson plans_before_count "$(printf '%s\n' "$plans_before" | jq '(.plans // .) | length')" \
  --argjson plans_after_create_count "$(printf '%s\n' "$plans_after_create" | jq '(.plans // .) | length')" \
  --argjson milestones_before_count "$(printf '%s\n' "$milestones_before" | jq '(.milestones // .) | length')" \
  --argjson milestones_after_create_count "$(printf '%s\n' "$milestones_after_create" | jq '(.milestones // .) | length')" \
  '{
    fixtures: {
      project_id: $project_id,
      suite_id: $suite_id,
      milestone_id: $milestone_id,
      plan_id: $plan_id,
      closed_plan_id: $closed_plan_id,
      entry_ids: [$entry1_id, $entry2_id],
      run_ids: [$run1_id, $run2_id]
    },
    coverage: {
      get_plans: true,
      get_plan: true,
      add_plan: true,
      add_plan_entry: true,
      update_plan: true,
      update_plan_entry: true,
      close_plan: true,
      delete_plan: true,
      get_milestones: true,
      get_milestone: true,
      add_milestone: true,
      update_milestone: true,
      delete_milestone: true
    },
    lifecycle: {
      plan_deleted: true,
      milestone_deleted: true,
      close_plan_fixture_deleted: $delete_completed_plan_allowed
    },
    evidence: {
      plans_before_count: $plans_before_count,
      plans_after_create_count: $plans_after_create_count,
      milestones_before_count: $milestones_before_count,
      milestones_after_create_count: $milestones_after_create_count,
      run_case_ids: {
        entry_a: $initial_case_ids,
        entry_b_after_update: $updated_entry_case_ids
      },
      api_behavior: "Plan responses did not echo case_ids on generated runs; case selection was verified via get_tests for the plan runs.",
      delete_completed_plan_evidence: $delete_completed_plan_evidence
    }
  }'
