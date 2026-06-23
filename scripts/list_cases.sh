#!/usr/bin/env bash
# List cases across all pages in plain text or JSON

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

load_credentials

usage() {
  echo "Usage: $0 PROJECT_ID [SECTION_ID] [--suite SUITE_ID] [--format plain|json] [--limit LIMIT]" >&2
  exit 1
}

PROJECT_ID="${1:-}"
[[ -n "$PROJECT_ID" ]] || usage
shift

SECTION_ID=""
if (($#)) && [[ "$1" != --* ]]; then
  SECTION_ID="$1"
  shift
fi

SUITE_ID=""
OUTPUT_FORMAT="plain"
PAGE_LIMIT="${TESTRAIL_PAGE_LIMIT:-250}"

while (($#)); do
  case "$1" in
    --suite)
      SUITE_ID="${2:-}"
      [[ -n "$SUITE_ID" ]] || usage
      shift 2
      ;;
    --format)
      OUTPUT_FORMAT="${2:-}"
      [[ "$OUTPUT_FORMAT" == "plain" || "$OUTPUT_FORMAT" == "json" ]] || usage
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

testrail_make_temp_file CASES_FILE list-cases
testrail_collect_cases "$PROJECT_ID" "${COLLECT_ARGS[@]}" > "$CASES_FILE"

if [[ "$OUTPUT_FORMAT" == "json" ]]; then
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
      cases: ($payload[0].cases | map({id, title}))
    }'
  exit 0
fi

jq -r '.cases[] | "C\(.id): \(.title)"' "$CASES_FILE"
