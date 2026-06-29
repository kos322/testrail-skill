#!/usr/bin/env bash

# Colors
export GREEN='\033[0;32m'
export RED='\033[0;31m'
export NC='\033[0m'

assert_eq() {
    local expected="$1"
    local actual="$2"
    local msg="${3:-}"
    
    if [ "$expected" == "$actual" ]; then
        echo -e "${GREEN}✓ PASS${NC}: $msg"
    else
        echo -e "${RED}✗ FAIL${NC}: $msg"
        echo "  Expected: '$expected'"
        echo "  Actual:   '$actual'"
        exit 1
    fi
}

assert_contains() {
    local full_string="$1"
    local search="$2"
    local msg="${3:-}"
    
    if [[ "$full_string" == *"$search"* ]]; then
        echo -e "${GREEN}✓ PASS${NC}: $msg"
    else
        echo -e "${RED}✗ FAIL${NC}: $msg"
        echo "  Expected string to contain: '$search'"
        echo "  Actual string:   '$full_string'"
        exit 1
    fi
}

assert_success() {
    local exit_code="$1"
    local msg="${2:-}"
    
    if [ "$exit_code" -eq 0 ]; then
        echo -e "${GREEN}✓ PASS${NC}: $msg"
    else
        echo -e "${RED}✗ FAIL${NC}: $msg (Exit code $exit_code)"
        exit 1
    fi
}
