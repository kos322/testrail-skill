#!/usr/bin/env bash
# Get test cases from TestRail project/section

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

load_credentials

usage() {
  echo "Usage: $0 PROJECT_ID [SECTION_ID] [--suite SUITE_ID] [--limit LIMIT] [--offset OFFSET]" >&2
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
LIMIT=""
OFFSET=""

while (($#)); do
  case "$1" in
    --suite)
      SUITE_ID="${2:-}"
      [[ -n "$SUITE_ID" ]] || usage
      shift 2
      ;;
    --limit)
      LIMIT="${2:-}"
      [[ -n "$LIMIT" ]] || usage
      shift 2
      ;;
    --offset)
      OFFSET="${2:-}"
      [[ -n "$OFFSET" ]] || usage
      shift 2
      ;;
    *)
      usage
      ;;
  esac
done

ENDPOINT_ARGS=()
[[ -n "$SECTION_ID" ]] && ENDPOINT_ARGS+=(--section "$SECTION_ID")
[[ -n "$SUITE_ID" ]] && ENDPOINT_ARGS+=(--suite "$SUITE_ID")
[[ -n "$LIMIT" ]] && ENDPOINT_ARGS+=(--limit "$LIMIT")
[[ -n "$OFFSET" ]] && ENDPOINT_ARGS+=(--offset "$OFFSET")

ENDPOINT="$(testrail_cases_endpoint "$PROJECT_ID" "${ENDPOINT_ARGS[@]}")"

testrail_api GET "$ENDPOINT" \
  -H "Content-Type: application/json"
