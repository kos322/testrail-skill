#!/usr/bin/env bash
# Common functions for TestRail scripts

TESTRAIL_REPO_ROOT=""
TESTRAIL_TEMP_ROOT=""
TESTRAIL_CLEANUP_REGISTERED=0

testrail_repo_root() {
  cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd
}

testrail_require_command() {
  local command_name="${1:?Usage: testrail_require_command COMMAND}"

  command -v "$command_name" >/dev/null 2>&1 || {
    echo "Error: required command '$command_name' not found" >&2
    exit 1
  }
}

testrail_cleanup() {
  local exit_code=$?

  if [[ -n "${TESTRAIL_TEMP_ROOT:-}" && -d "${TESTRAIL_TEMP_ROOT}" ]]; then
    rm -rf -- "${TESTRAIL_TEMP_ROOT}"
  fi

  if [[ -n "${TESTRAIL_REPO_ROOT:-}" && -d "${TESTRAIL_REPO_ROOT}/.testrail-tmp" ]] && \
    [[ -z "$(ls -A "${TESTRAIL_REPO_ROOT}/.testrail-tmp" 2>/dev/null)" ]]; then
    rmdir "${TESTRAIL_REPO_ROOT}/.testrail-tmp" 2>/dev/null || true
  fi

  return "$exit_code"
}

testrail_register_cleanup() {
  if [[ "${TESTRAIL_CLEANUP_REGISTERED}" -eq 0 ]]; then
    trap 'testrail_cleanup' EXIT
    TESTRAIL_CLEANUP_REGISTERED=1
  fi
}

testrail_ensure_temp_root() {
  if [[ -n "${TESTRAIL_TEMP_ROOT:-}" && -d "${TESTRAIL_TEMP_ROOT}" ]]; then
    return 0
  fi

  testrail_register_cleanup

  local temp_parent
  temp_parent="${TESTRAIL_REPO_ROOT}/.testrail-tmp"
  mkdir -p "$temp_parent"
  TESTRAIL_TEMP_ROOT="$(mktemp -d "${temp_parent}/run.XXXXXX")"
}

testrail_make_temp_file() {
  local result_var="${1:?Usage: testrail_make_temp_file RESULT_VAR [PREFIX]}"
  local prefix="${2:-tmp}"
  local file_path

  testrail_ensure_temp_root
  file_path="$(mktemp "${TESTRAIL_TEMP_ROOT}/${prefix}.XXXXXX")"
  printf -v "$result_var" '%s' "$file_path"
}

testrail_error_excerpt() {
  local file_path="${1:?Usage: testrail_error_excerpt FILE}"

  [[ -s "$file_path" ]] || return 0

  tr '\r\n' '  ' < "$file_path" | head -c 400
}

testrail_api() {
  local method="${1:?Usage: testrail_api METHOD ENDPOINT [curl_args...]}"
  local endpoint="${2:?Usage: testrail_api METHOD ENDPOINT [curl_args...]}"
  shift 2

  local response_file curl_error_file url http_code attempt max_attempts status api_error excerpt
  testrail_make_temp_file response_file response
  testrail_make_temp_file curl_error_file curl-error
  url="${TESTRAIL_URL}/index.php?/api/v2/${endpoint}"
  max_attempts="${TESTRAIL_CURL_RETRIES:-3}"
  attempt=1

  while :; do
    : > "$curl_error_file"

    if http_code="$(curl -sS -u "$TESTRAIL_USER:$TESTRAIL_API_KEY" -X "$method" -o "$response_file" -w "%{http_code}" "$@" "$url" 2>"$curl_error_file")"; then
      if [[ "$http_code" =~ ^(429|5[0-9][0-9])$ ]] && (( attempt < max_attempts )); then
        sleep "$((2 ** (attempt - 1)))"
        ((attempt++))
        continue
      fi
      break
    fi

    status=$?
    if (( attempt >= max_attempts )); then
      echo "Error: curl failed for ${method} ${endpoint} (exit ${status})." >&2
      [[ -s "$curl_error_file" ]] && cat "$curl_error_file" >&2
      return "$status"
    fi

    sleep "$((2 ** (attempt - 1)))"
    ((attempt++))
  done

  if [[ ! "$http_code" =~ ^2[0-9][0-9]$ ]]; then
    api_error="$(jq -er '.error // empty' "$response_file" 2>/dev/null || true)"

    echo "TestRail request failed: ${method} ${endpoint} (HTTP ${http_code})." >&2
    if [[ -n "$api_error" ]]; then
      echo "API Error: ${api_error}" >&2
    else
      excerpt="$(testrail_error_excerpt "$response_file")"
      [[ -n "$excerpt" ]] && echo "Response: ${excerpt}" >&2
    fi
    return 1
  fi

  if [[ -s "$response_file" ]]; then
    api_error="$(jq -er 'if type == "object" and has("error") then .error else empty end' "$response_file" 2>/dev/null || true)"
    if [[ -n "$api_error" ]]; then
      echo "TestRail API error for ${method} ${endpoint}: ${api_error}" >&2
      return 1
    fi
  fi

  cat "$response_file"
}

# Load credentials from .env (not exposed to LLM context)
load_credentials() {
  TESTRAIL_REPO_ROOT="$(testrail_repo_root)"

  if [ -f "$TESTRAIL_REPO_ROOT/.env" ]; then
    set -a
    source "$TESTRAIL_REPO_ROOT/.env"
    set +a
  elif [ -f "$TESTRAIL_REPO_ROOT/../.env" ]; then
    set -a
    source "$TESTRAIL_REPO_ROOT/../.env"
    set +a
  fi

  : "${TESTRAIL_URL:?TESTRAIL_URL not set. Create .env file with credentials}"
  : "${TESTRAIL_USER:?TESTRAIL_USER not set. Create .env file with credentials}"
  : "${TESTRAIL_API_KEY:?TESTRAIL_API_KEY not set. Create .env file with credentials}"

  TESTRAIL_URL="${TESTRAIL_URL%/}"

  testrail_require_command curl
  testrail_require_command jq
}
