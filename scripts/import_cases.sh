#!/usr/bin/env bash
# Export test cases from TestRail to JSON

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

load_credentials

usage() {
  echo "Usage: $0 PROJECT_ID [SECTION_ID] [OUTPUT_FILE] [--section SECTION_ID] [--suite SUITE_ID] [--output OUTPUT_FILE]" >&2
  exit 1
}

PROJECT_ID="${1:-}"
[[ -n "$PROJECT_ID" ]] || usage
shift

SECTION_ID=""
OUTPUT_FILE="cases_export.json"

if (($#)) && [[ "$1" != --* ]]; then
  SECTION_ID="$1"
  shift
fi

if (($#)) && [[ "$1" != --* ]]; then
  OUTPUT_FILE="$1"
  shift
fi

SUITE_ID=""
PAGE_LIMIT="${TESTRAIL_PAGE_LIMIT:-250}"
while (($#)); do
  case "$1" in
    --section)
      SECTION_ID="${2:-}"
      [[ -n "$SECTION_ID" ]] || usage
      shift 2
      ;;
    --suite)
      SUITE_ID="${2:-}"
      [[ -n "$SUITE_ID" ]] || usage
      shift 2
      ;;
    --output)
      OUTPUT_FILE="${2:-}"
      [[ -n "$OUTPUT_FILE" ]] || usage
      shift 2
      ;;
    --limit)
      PAGE_LIMIT="${2:-}"
      [[ -n "$PAGE_LIMIT" ]] || usage
      shift 2
      ;;
    *)
      usage
      ;;
  esac
done

COLLECT_ARGS=(--limit "$PAGE_LIMIT")
[[ -n "$SECTION_ID" ]] && COLLECT_ARGS+=(--section "$SECTION_ID")
[[ -n "$SUITE_ID" ]] && COLLECT_ARGS+=(--suite "$SUITE_ID")

testrail_make_temp_file CASES_FILE import-cases
testrail_collect_cases "$PROJECT_ID" "${COLLECT_ARGS[@]}" > "$CASES_FILE"

jq -n \
  --argjson project_id "$PROJECT_ID" \
  --arg section_id "${SECTION_ID:-}" \
  --arg suite_id "${SUITE_ID:-}" \
  --slurpfile payload "$CASES_FILE" \
  '{
    project_id: $project_id,
    section_id: (if $section_id == "" then null else ($section_id | tonumber) end),
    suite_id: (if $suite_id == "" then null else ($suite_id | tonumber) end),
    count: $payload[0].count,
    cases: $payload[0].cases
  }' > "$OUTPUT_FILE"

echo "Exported cases to $OUTPUT_FILE"
jq '.cases | length' "$OUTPUT_FILE" | xargs echo "Total cases:"
