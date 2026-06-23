#!/usr/bin/env bash
# Example: Complete CI workflow - create run, push results, close

set -euo pipefail

: "${TESTRAIL_URL:?}"
: "${TESTRAIL_USER:?}"
: "${TESTRAIL_API_KEY:?}"

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
  -d @"$RUN_PAYLOAD" | jq -r '.run.id')

echo "Created run: $RUN_ID"

echo "=== Running tests (simulated) ==="
sleep 2

echo "=== Pushing results ==="
RESULTS=$(mktemp)
cat > "$RESULTS" <<EOF
{
  "results": [
    {"test_id": 1, "status_id": 1, "comment": "Passed in CI", "elapsed": "2s"},
    {"test_id": 2, "status_id": 1, "comment": "Passed in CI", "elapsed": "3s"},
    {"test_id": 3, "status_id": 5, "comment": "Failed: assertion error", "elapsed": "1s"}
  ]
}
EOF

curl -s -X POST -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/add_results/${RUN_ID}" \
  -H "Content-Type: application/json" \
  -d @"$RESULTS" | jq '{added: .results | length}'

rm -f "$RESULTS"

echo "=== Closing run ==="
curl -s -X POST -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/close_run/${RUN_ID}" \
  -H "Content-Type: application/json" | jq .

echo "✓ Workflow complete. Run ID: $RUN_ID"
