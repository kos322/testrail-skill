#!/usr/bin/env bash
# Example: Create a test case with all fields

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/common.sh"

load_credentials

SECTION_ID="${1:-10}"
CASE_TITLE="${2:-[DISPOSABLE] Verify login with valid credentials $(date +%Y-%m-%d_%H-%M-%S)}"
CASE_REFS="${3:-DISPOSABLE-$(date +%s)}"

testrail_make_temp_file PAYLOAD add-case

jq -n \
  --arg title "$CASE_TITLE" \
  --arg refs "$CASE_REFS" \
  '{
    title: $title,
    template_id: 2,
    type_id: 6,
    priority_id: 2,
    estimate: "5m",
    refs: $refs,
    custom_steps_separated: [
      {
        content: "Navigate to login page",
        expected: "Login page loads successfully"
      },
      {
        content: "Enter valid username and password",
        expected: "Credentials are accepted"
      },
      {
        content: "Click Login button",
        expected: "User is redirected to dashboard"
      }
    ],
    custom_preconds: "User must be registered in the system"
  }' > "$PAYLOAD"

testrail_api POST "add_case/${SECTION_ID}" \
  -H "Content-Type: application/json" \
  --data @"$PAYLOAD" | jq .
