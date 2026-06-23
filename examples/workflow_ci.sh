#!/usr/bin/env bash
# Example: Complete CI workflow - create run, push results, close

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/common.sh"

load_credentials

PROJECT_ID="${1:?Usage: $0 PROJECT_ID SUITE_ID}"
SUITE_ID="${2:?}"

echo "=== Creating test run ==="
testrail_make_temp_file RUN_PAYLOAD workflow-run

jq -n \
  --argjson suite_id "$SUITE_ID" \
  --arg name "CI Run $(date +%Y-%m-%d_%H:%M:%S)" \
  --arg description "Automated CI test run" \
  '{suite_id: $suite_id, name: $name, description: $description, include_all: false, case_ids: [1, 2, 3]}' > "$RUN_PAYLOAD"

RUN_ID="$(testrail_api POST "add_run/${PROJECT_ID}" \
  -H "Content-Type: application/json" \
  --data @"$RUN_PAYLOAD" | jq -er '.id')"

echo "Created run: $RUN_ID"

echo "=== Getting test IDs from run ==="
TEST_IDS="$(testrail_api GET "get_tests/${RUN_ID}" \
  -H "Content-Type: application/json" | jq -cer '.tests[0:3] | map(.id)')"
[[ "$(printf '%s' "$TEST_IDS" | jq 'length')" -eq 3 ]] || {
  echo "Error: expected at least 3 tests in run $RUN_ID" >&2
  exit 1
}

echo "Test IDs: $TEST_IDS"

echo "=== Running tests (simulated) ==="
sleep 2

echo "=== Pushing results ==="
testrail_make_temp_file RESULTS workflow-results
jq -n \
  --argjson test_ids "$TEST_IDS" \
  '{
    results: [
      {test_id: $test_ids[0], status_id: 1, comment: "Passed in CI", elapsed: "2s"},
      {test_id: $test_ids[1], status_id: 1, comment: "Passed in CI", elapsed: "3s"},
      {test_id: $test_ids[2], status_id: 5, comment: "Failed: assertion error", elapsed: "1s"}
    ]
  }' > "$RESULTS"

testrail_api POST "add_results/${RUN_ID}" \
  -H "Content-Type: application/json" \
  --data @"$RESULTS" | jq '{added: length, test_ids: map(.test_id)}'

echo "=== Closing run ==="
testrail_api POST "close_run/${RUN_ID}" \
  -H "Content-Type: application/json" | jq .

echo "✓ Workflow complete. Run ID: $RUN_ID"
