#!/usr/bin/env bash
# Get the precondition field from a TestRail case

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"$SCRIPT_DIR/get_case_field.sh" "${1:?Usage: $0 CASE_ID}" custom_preconds
