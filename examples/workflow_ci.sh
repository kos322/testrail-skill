#!/usr/bin/env bash
# Example: Complete CI workflow - create run, push results, close

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/common.sh"

load_credentials

PROJECT_ID="${1:?Usage: $0 PROJECT_ID SUITE_ID}"
SUITE_ID="${2:?}"

echo "=== Creating test run ==="
RUN_PAYLOAD=$(mktemp)
trap "rm -f $RUN_PAYLOAD" EXIT

cat > "$RUN_PAYLOAD" <<EOF
{
  "suite_id": $SUITE_ID,
  "name": "CI Run $(date +%Y-%m-%d_%H:%M:%S)",
  "description": "Automated CI test run",
  "include_all": false,
  "case_ids": [1, 2, 3]
}
EOF

RUN_ID=$(curl -s -X POST -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/add_run/${PROJECT_ID}" \
  -H "Content-Type: application/json" \
  -d @"$RUN_PAYLOAD" | jq -r '.id')

echo "Created run: $RUN_ID"

echo "=== Getting test IDs from run ==="
TEST_IDS=$(curl -s -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/get_tests/${RUN_ID}" \
  -H "Content-Type: application/json" | jq -r '.tests[0:3] | map(.id) | @json')

echo "Test IDs: $TEST_IDS"

echo "=== Running tests (simulated) ==="
sleep 2

echo "=== Pushing results ==="
RESULTS=$(mktemp)
TEST_ID_ARRAY=($(echo "$TEST_IDS" | jq -r '.[]'))
cat > "$RESULTS" <<EOF
{
  "results": [
    {"test_id": ${TEST_ID_ARRAY[0]}, "status_id": 1, "comment": "Passed in CI", "elapsed": "2s"},
    {"test_id": ${TEST_ID_ARRAY[1]}, "status_id": 1, "comment": "Passed in CI", "elapsed": "3s"},
    {"test_id": ${TEST_ID_ARRAY[2]}, "status_id": 5, "comment": "Failed: assertion error", "elapsed": "1s"}
  ]
}
EOF

curl -s -X POST -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/add_results/${RUN_ID}" \
  -H "Content-Type: application/json" \
  -d @"$RESULTS" | jq '{added: length, test_ids: map(.test_id)}'

rm -f "$RESULTS"

echo "=== Closing run ==="
curl -s -X POST -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/close_run/${RUN_ID}" \
  -H "Content-Type: application/json" | jq .

echo "✓ Workflow complete. Run ID: $RUN_ID"
