#!/usr/bin/env bash
# Get attachments for a supported TestRail entity

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

load_credentials

RESOURCE="${1:?Usage: $0 RESOURCE ID}"

case "$RESOURCE" in
  case)
    CASE_ID="${2:?Usage: $0 case CASE_ID}"
    ENDPOINT="get_attachments_for_case/${CASE_ID}"
    ;;
  test)
    TEST_ID="${2:?Usage: $0 test TEST_ID}"
    ENDPOINT="get_attachments_for_test/${TEST_ID}"
    ;;
  *)
    echo "Error: unsupported resource '${RESOURCE}'" >&2
    echo "Supported resources: case, test" >&2
    exit 1
    ;;
esac

testrail_api GET "$ENDPOINT" \
  -H "Content-Type: application/json"
