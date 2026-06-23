#!/usr/bin/env bash
# Export test cases from TestRail to JSON

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

load_credentials

usage() {
  echo "Usage: $0 PROJECT_ID SECTION_ID [OUTPUT_FILE] [--suite SUITE_ID]" >&2
  exit 1
}

PROJECT_ID="${1:-}"
SECTION_ID="${2:-}"
OUTPUT_FILE="${3:-cases_export.json}"
[[ -n "$PROJECT_ID" && -n "$SECTION_ID" ]] || usage
shift 3 || true

SUITE_ID=""
while (($#)); do
  case "$1" in
    --suite)
      SUITE_ID="${2:-}"
      [[ -n "$SUITE_ID" ]] || usage
      shift 2
      ;;
    *)
      usage
      ;;
  esac
done

PAGE_LIMIT="${TESTRAIL_PAGE_LIMIT:-250}"
OFFSET=0
TOTAL_CASES=0

testrail_make_temp_file CASES_FILE import-cases
printf '[]\n' > "$CASES_FILE"

while :; do
  PAGE_ARGS=(--section "$SECTION_ID" --limit "$PAGE_LIMIT" --offset "$OFFSET")
  [[ -n "$SUITE_ID" ]] && PAGE_ARGS+=(--suite "$SUITE_ID")

  ENDPOINT="$(testrail_cases_endpoint "$PROJECT_ID" "${PAGE_ARGS[@]}")"
  PAGE_JSON="$(testrail_api GET "$ENDPOINT" -H "Content-Type: application/json")"

  testrail_make_temp_file PAGE_FILE import-cases-page
  testrail_make_temp_file MERGED_FILE import-cases-merged
  printf '%s\n' "$PAGE_JSON" > "$PAGE_FILE"

  PAGE_CASE_COUNT="$(jq -er '(.cases // []) | length' "$PAGE_FILE")"
  TOTAL_CASES=$((TOTAL_CASES + PAGE_CASE_COUNT))

  jq -s '.[0] + (.[1].cases // [])' "$CASES_FILE" "$PAGE_FILE" > "$MERGED_FILE"
  mv "$MERGED_FILE" "$CASES_FILE"

  NEXT_OFFSET="$(testrail_next_offset "$PAGE_FILE")"
  if [[ -n "$NEXT_OFFSET" ]]; then
    OFFSET="$NEXT_OFFSET"
    continue
  fi

  PAGE_SIZE="$(jq -r '.size // empty' "$PAGE_FILE")"
  if [[ "$PAGE_SIZE" =~ ^[0-9]+$ ]] && (( OFFSET + PAGE_CASE_COUNT < PAGE_SIZE )); then
    OFFSET=$((OFFSET + PAGE_CASE_COUNT))
    continue
  fi

  break
done

jq -n \
  --argjson project_id "$PROJECT_ID" \
  --argjson section_id "$SECTION_ID" \
  --arg suite_id "${SUITE_ID:-}" \
  --argjson count "$TOTAL_CASES" \
  --slurpfile cases "$CASES_FILE" \
  '{
    project_id: $project_id,
    section_id: $section_id,
    suite_id: (if $suite_id == "" then null else ($suite_id | tonumber) end),
    count: $count,
    cases: $cases[0]
  }' > "$OUTPUT_FILE"

echo "Exported cases to $OUTPUT_FILE"
jq '.cases | length' "$OUTPUT_FILE" | xargs echo "Total cases:"
