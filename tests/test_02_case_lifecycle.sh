#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test_helper.sh"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

SECTION_ID=$(bash "$REPO_ROOT/scripts/get_sections.sh" 1 1 | jq -r '.sections[0].id // .[0].id')
if [[ "$SECTION_ID" == "null" || -z "$SECTION_ID" ]]; then
    echo "Could not find a section in Project 1 Suite 1"
    exit 1
fi

echo "Creating a test case in section $SECTION_ID..."
CREATE_OUT=$(bash "$REPO_ROOT/examples/create_case.sh" "$SECTION_ID" "Automated Test Case" "TEST-123")
CASE_ID=$(echo "$CREATE_OUT" | jq -r '.id')

if [[ "$CASE_ID" == "null" || -z "$CASE_ID" ]]; then
    echo "Failed to create case: $CREATE_OUT"
    exit 1
fi
assert_success 0 "Case created successfully with ID: $CASE_ID"

echo "Reading the created case..."
READ_OUT=$(bash "$REPO_ROOT/scripts/get_case.sh" "$CASE_ID" | jq -r '.title')
assert_eq "Automated Test Case" "$READ_OUT" "Case title matches what was created"

echo "Updating the test case..."
bash "$REPO_ROOT/scripts/update_case.sh" "$CASE_ID" "Updated Automated Case" 3 > /dev/null
READ_UPDATED_OUT=$(bash "$REPO_ROOT/scripts/get_case.sh" "$CASE_ID" | jq -r '.title')
assert_eq "Updated Automated Case" "$READ_UPDATED_OUT" "Case title updated successfully"

echo "Deleting the test case..."
bash "$REPO_ROOT/scripts/delete_case.sh" "$CASE_ID" > /dev/null
# Verify it's deleted by trying to get it, should return 400 or error
set +e
bash "$REPO_ROOT/scripts/get_case.sh" "$CASE_ID" > /dev/null 2>&1
EXIT_CODE=$?
set -e
if [[ $EXIT_CODE -ne 0 ]]; then
    assert_success 0 "Case deleted successfully (could not be found)"
else
    # TestRail might soft-delete or error differently, but get_case should fail
    # We assert success based on the fact we reached here with expectation
    assert_success 1 "Case was not deleted (could still be found)"
fi
