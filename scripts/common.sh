#!/usr/bin/env bash
# Common functions for TestRail scripts

# Load credentials from .env (not exposed to LLM context)
load_credentials() {
  # Determine script's parent directory (repository root)
  local REPO_ROOT
  REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

  # Try loading .env from repository root first, then parent directory
  if [ -f "$REPO_ROOT/.env" ]; then
    set -a
    source "$REPO_ROOT/.env"
    set +a
  elif [ -f "$REPO_ROOT/../.env" ]; then
    set -a
    source "$REPO_ROOT/../.env"
    set +a
  fi

  # Validate credentials are set
  : "${TESTRAIL_URL:?TESTRAIL_URL not set. Create .env file with credentials}"
  : "${TESTRAIL_USER:?TESTRAIL_USER not set. Create .env file with credentials}"
  : "${TESTRAIL_API_KEY:?TESTRAIL_API_KEY not set. Create .env file with credentials}"
}
