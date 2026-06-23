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

COLLECT_ARGS=(--limit "$PAGE_LIMIT")
[[ -n "$SECTION_ID" ]] && COLLECT_ARGS+=(--section "$SECTION_ID")
[[ -n "$SUITE_ID" ]] && COLLECT_ARGS+=(--suite "$SUITE_ID")

testrail_collect_cases "$PROJECT_ID" "${COLLECT_ARGS[@]}" | jq -r '.count'
