#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test_helper.sh"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

PROJECT_ID=1
SUITE_ID=1

SECTION_ID=$(bash "$REPO_ROOT/scripts/get_sections.sh" "$PROJECT_ID" "$SUITE_ID" | jq -r '.sections[0].id // .[0].id')
if [[ "$SECTION_ID" == "null" || -z "$SECTION_ID" ]]; then
    SECTION_ID=10
fi

echo "Creating a test case for extended run tests..."
CREATE_OUT=$(bash "$REPO_ROOT/examples/create_case.sh" "$SECTION_ID" "Run Extended Case" "EXT-RUN")
CASE_ID=$(echo "$CREATE_OUT" | jq -r '.id')

echo "Creating a test run with specific case..."
RUN_OUT=$(bash "$REPO_ROOT/scripts/create_run.sh" "$PROJECT_ID" "$SUITE_ID" "Extended Tests" "$CASE_ID")
RUN_ID=$(echo "$RUN_OUT" | jq -r '.id')
assert_success 0 "Run created with ID: $RUN_ID"

echo "Updating run..."
# update_run.sh takes RUN_ID NAME DESCRIPTION
bash "$REPO_ROOT/scripts/update_run.sh" "$RUN_ID" "Updated Extended Tests" "Updated Desc" > /dev/null
# Verify update
RUNS_OUT=$(bash "$REPO_ROOT/scripts/get_runs.sh" "$PROJECT_ID" | jq -r 'if type == "object" and has("runs") then .runs else . end | .[] | select(.id == '"$RUN_ID"') | .name')
assert_eq "Updated Extended Tests" "$RUNS_OUT" "Run name was updated"

echo "Adding result for case..."
# add_result_for_case.sh takes RUN_ID CASE_ID STATUS_ID COMMENT
bash "$REPO_ROOT/scripts/add_result_for_case.sh" "$RUN_ID" "$CASE_ID" 1 "Passed via add_result_for_case" > /dev/null

echo "Getting results for case..."
# get_results_for_case.sh takes RUN_ID CASE_ID
RESULTS_CASE_OUT=$(bash "$REPO_ROOT/scripts/get_results_for_case.sh" "$RUN_ID" "$CASE_ID" | jq -r '.results[0].status_id // .[0].status_id')
assert_eq "1" "$RESULTS_CASE_OUT" "Result listed in get_results_for_case"

echo "Getting results for test..."
# First we need TEST_ID
TESTS_JSON=$(bash -c "source \"$REPO_ROOT/scripts/common.sh\" && load_credentials && testrail_api GET \"get_tests/$RUN_ID\" -H \"Content-Type: application/json\"")
TEST_ID=$(echo "$TESTS_JSON" | jq -r '.tests[0].id // .[0].id')

# get_results.sh takes TEST_ID
RESULTS_TEST_OUT=$(bash "$REPO_ROOT/scripts/get_results.sh" "$TEST_ID" | jq -r '.results[0].status_id // .[0].status_id')
assert_eq "1" "$RESULTS_TEST_OUT" "Result listed in get_results"

echo "Cleaning up..."
set +e
bash "$REPO_ROOT/scripts/delete_case.sh" "$CASE_ID" > /dev/null 2>&1
bash -c "source \"$REPO_ROOT/scripts/common.sh\" && load_credentials && testrail_api POST \"delete_run/$RUN_ID\" -H \"Content-Type: application/json\"" > /dev/null 2>&1
set -e
assert_success 0 "Extended run tests completed successfully"
