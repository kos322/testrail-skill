#!/usr/bin/env bash
# Main Test Runner for testrail-skill

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export TEST_DIR="$SCRIPT_DIR"
export REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Globals for test stats
FAILED=0
PASSED=0

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "=========================================="
echo "Starting testrail-skill test suite"
echo "=========================================="

export PASSED=0
export FAILED=0

# Run all test files
for test_file in "$TEST_DIR"/test_*.sh; do
    echo ""
    echo "--- Running $test_file ---"
    
    # Run the test in a subshell, sourcing it to use the assert functions
    # However, to preserve variables we might just source it directly, but 
    # to isolate failures we will run it as a separate process and collect results.
    # To collect results cleanly, tests should just exit 1 on fail or we pass a pipe.
    # Actually, simplest is to just execute the script and check exit code.
    bash "$test_file"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Test file completed successfully${NC}"
    else
        echo -e "${RED}✗ Test file failed${NC}"
        FAILED=$((FAILED+1))
    fi
done

echo ""
echo "=========================================="
if [ "$FAILED" -eq 0 ]; then
    echo -e "${GREEN}All test suites passed!${NC}"
    exit 0
else
    echo -e "${RED}Some test suites failed. Check the output above.${NC}"
    exit 1
fi
