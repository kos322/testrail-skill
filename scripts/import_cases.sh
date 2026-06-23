#!/usr/bin/env bash
# Export test cases from TestRail to JSON

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

load_credentials

PROJECT_ID="${1:?Usage: $0 PROJECT_ID SECTION_ID [OUTPUT_FILE]}"
SECTION_ID="${2:?}"
OUTPUT_FILE="${3:-cases_export.json}"

curl -s -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/get_cases/${PROJECT_ID}&section_id=${SECTION_ID}" \
  -H "Content-Type: application/json" \
  -o "$OUTPUT_FILE"

echo "Exported cases to $OUTPUT_FILE"
jq '.cases | length' "$OUTPUT_FILE" | xargs echo "Total cases:"
