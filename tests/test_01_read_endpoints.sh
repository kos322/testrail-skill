#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test_helper.sh"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "Testing doctor.sh..."
OUT=$(bash "$REPO_ROOT/scripts/doctor.sh")
assert_contains "$OUT" "\"ok\": true" "Doctor script validates environment successfully"

echo "Testing get_projects.sh..."
OUT=$(bash "$REPO_ROOT/scripts/get_projects.sh" | jq -r '.projects[0].id // .[0].id')
assert_eq "1" "$OUT" "Projects list contains project ID 1"

echo "Testing get_project.sh 1..."
OUT=$(bash "$REPO_ROOT/scripts/get_project.sh" 1 | jq -r .id)
assert_eq "1" "$OUT" "get_project 1 returns correct ID"

echo "Testing get_reference_data.sh statuses..."
OUT=$(bash "$REPO_ROOT/scripts/get_reference_data.sh" statuses | jq -r 'type')
assert_eq "array" "$OUT" "Reference data statuses returns an array"

echo "Testing get_sections.sh 1 1..."
OUT=$(bash "$REPO_ROOT/scripts/get_sections.sh" 1 1 | jq -r '.sections[0].id // .[0].id')
# Check if out is numeric or just not null
if [[ "$OUT" != "null" && "$OUT" != "" ]]; then
    assert_success 0 "get_sections returns a list of sections with ids"
else
    assert_success 1 "get_sections did not return valid sections array"
fi
