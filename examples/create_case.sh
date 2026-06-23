#!/usr/bin/env bash
# Example: Create a test case with all fields

set -euo pipefail

: "${TESTRAIL_URL:?}"
: "${TESTRAIL_USER:?}"
: "${TESTRAIL_API_KEY:?}"

SECTION_ID="${1:-10}"

PAYLOAD=$(mktemp)
trap "rm -f $PAYLOAD" EXIT

cat > "$PAYLOAD" <<'EOF'
{
  "title": "Verify login with valid credentials",
  "template_id": 1,
  "type_id": 1,
  "priority_id": 2,
  "estimate": "5m",
  "refs": "JIRA-123",
  "custom_steps": [
    {
      "content": "Navigate to login page",
      "expected": "Login page loads successfully"
    },
    {
      "content": "Enter valid username and password",
      "expected": "Credentials are accepted"
    },
    {
      "content": "Click Login button",
      "expected": "User is redirected to dashboard"
    }
  ],
  "custom_preconds": "User must be registered in the system"
}
EOF

curl -s -X POST -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" \
  "${TESTRAIL_URL}/index.php?/api/v2/add_case/${SECTION_ID}" \
  -H "Content-Type: application/json" \
  -d @"$PAYLOAD" | jq .
