#!/usr/bin/env bash
# Common functions for TestRail scripts

# Load credentials from .env (not exposed to LLM context)
load_credentials() {
  if [ -f .env ]; then
    set -a
    source .env
    set +a
  elif [ -f ../.env ]; then
    set -a
    source ../.env
    set +a
  fi

  # Validate credentials are set
  : "${TESTRAIL_URL:?TESTRAIL_URL not set. Create .env file with credentials}"
  : "${TESTRAIL_USER:?TESTRAIL_USER not set. Create .env file with credentials}"
  : "${TESTRAIL_API_KEY:?TESTRAIL_API_KEY not set. Create .env file with credentials}"
}
