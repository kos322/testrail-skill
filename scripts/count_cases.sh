#!/usr/bin/env bash
# Count cases across paginated TestRail responses

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

load_credentials

usage() {
  echo "Usage: $0 PROJECT_ID [SECTION_ID] [--suite SUITE_ID] [--limit LIMIT]" >&2
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
PAGE_LIMIT="${TESTRAIL_PAGE_LIMIT:-250}"
OFFSET=0
TOTAL_CASES=0

while (($#)); do
  case "$1" in
    --suite)
      SUITE_ID="${2:-}"
      [[ -n "$SUITE_ID" ]] || usage
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

while :; do
  PAGE_ARGS=(--limit "$PAGE_LIMIT" --offset "$OFFSET")
  [[ -n "$SECTION_ID" ]] && PAGE_ARGS+=(--section "$SECTION_ID")
  [[ -n "$SUITE_ID" ]] && PAGE_ARGS+=(--suite "$SUITE_ID")

  ENDPOINT="$(testrail_cases_endpoint "$PROJECT_ID" "${PAGE_ARGS[@]}")"
  PAGE_JSON="$(testrail_api GET "$ENDPOINT" -H "Content-Type: application/json")"

  testrail_make_temp_file PAGE_FILE count-cases-page
  printf '%s\n' "$PAGE_JSON" > "$PAGE_FILE"

  PAGE_CASE_COUNT="$(jq -er '(.cases // []) | length' "$PAGE_FILE")"
  TOTAL_CASES=$((TOTAL_CASES + PAGE_CASE_COUNT))

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

printf '%s\n' "$TOTAL_CASES"
