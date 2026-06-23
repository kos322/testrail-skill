#!/usr/bin/env bash
# Common functions for TestRail scripts

TESTRAIL_REPO_ROOT=""
TESTRAIL_TEMP_ROOT=""
TESTRAIL_CLEANUP_REGISTERED=0
TESTRAIL_ENV_FILE_USED=""
TESTRAIL_ENV_SOURCE=""

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

testrail_command_exists() {
  local command_name="${1:?Usage: testrail_command_exists COMMAND}"

  command -v "$command_name" >/dev/null 2>&1
}

testrail_cleanup() {
  local exit_code=$?

  if [[ -n "${TESTRAIL_TEMP_ROOT:-}" && -d "${TESTRAIL_TEMP_ROOT}" ]]; then
    rm -rf -- "${TESTRAIL_TEMP_ROOT}"
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

testrail_normalize_input_path() {
  local input_path="${1:?Usage: testrail_normalize_input_path PATH}"

  if [[ "$input_path" =~ ^[A-Za-z]:[\\/].* ]] && testrail_command_exists cygpath; then
    cygpath -u "$input_path"
    return 0
  fi

  printf '%s\n' "$input_path"
}

testrail_find_ancestor_file() {
  local start_dir="${1:?Usage: testrail_find_ancestor_file START_DIR FILE_NAME}"
  local file_name="${2:?Usage: testrail_find_ancestor_file START_DIR FILE_NAME}"
  local current_dir parent_dir

  current_dir="$(cd "$start_dir" && pwd)"

  while :; do
    if [[ -f "${current_dir}/${file_name}" ]]; then
      printf '%s\n' "${current_dir}/${file_name}"
      return 0
    fi

    parent_dir="$(dirname "$current_dir")"
    if [[ "$parent_dir" == "$current_dir" ]]; then
      return 1
    fi

    current_dir="$parent_dir"
  done
}

testrail_load_env_file() {
  local env_file="${1:?Usage: testrail_load_env_file ENV_FILE [SOURCE_LABEL]}"
  local source_label="${2:-.env}"

  set -a
  # shellcheck disable=SC1090
  source "$env_file"
  set +a

  TESTRAIL_ENV_FILE_USED="$env_file"
  TESTRAIL_ENV_SOURCE="$source_label"
}

testrail_emit_env_source() {
  local show_env_source="${TESTRAIL_SHOW_ENV_SOURCE:-auto}"
  local repo_env_file="${TESTRAIL_REPO_ROOT}/.env"

  if [[ "$show_env_source" == "0" || -z "${TESTRAIL_ENV_FILE_USED:-}" ]]; then
    return 0
  fi

  if [[ "$show_env_source" == "auto" ]] && \
    [[ "${TESTRAIL_ENV_SOURCE:-}" == "ancestor-search" ]] && \
    [[ "${TESTRAIL_ENV_FILE_USED}" == "$repo_env_file" ]]; then
    return 0
  fi

  if [[ -n "${TESTRAIL_ENV_SOURCE:-}" ]]; then
    echo "Using env: ${TESTRAIL_ENV_FILE_USED} (${TESTRAIL_ENV_SOURCE})" >&2
    return 0
  fi

  echo "Using env: ${TESTRAIL_ENV_FILE_USED}" >&2
}

testrail_cases_endpoint() {
  local project_id="${1:?Usage: testrail_cases_endpoint PROJECT_ID [--suite SUITE_ID] [--section SECTION_ID] [--limit LIMIT] [--offset OFFSET]}"
  shift

  local suite_id="" section_id="" limit="" offset="" endpoint
  endpoint="get_cases/${project_id}"

  while (($#)); do
    case "$1" in
      --suite)
        suite_id="${2:?Usage: testrail_cases_endpoint PROJECT_ID [--suite SUITE_ID] [--section SECTION_ID] [--limit LIMIT] [--offset OFFSET]}"
        shift 2
        ;;
      --section)
        section_id="${2:?Usage: testrail_cases_endpoint PROJECT_ID [--suite SUITE_ID] [--section SECTION_ID] [--limit LIMIT] [--offset OFFSET]}"
        shift 2
        ;;
      --limit)
        limit="${2:?Usage: testrail_cases_endpoint PROJECT_ID [--suite SUITE_ID] [--section SECTION_ID] [--limit LIMIT] [--offset OFFSET]}"
        shift 2
        ;;
      --offset)
        offset="${2:?Usage: testrail_cases_endpoint PROJECT_ID [--suite SUITE_ID] [--section SECTION_ID] [--limit LIMIT] [--offset OFFSET]}"
        shift 2
        ;;
      *)
        echo "Error: unsupported get_cases option '$1'" >&2
        return 1
        ;;
    esac
  done

  [[ -n "$suite_id" ]] && endpoint+="&suite_id=${suite_id}"
  [[ -n "$section_id" ]] && endpoint+="&section_id=${section_id}"
  [[ -n "$limit" ]] && endpoint+="&limit=${limit}"
  [[ -n "$offset" ]] && endpoint+="&offset=${offset}"

  printf '%s\n' "$endpoint"
}

testrail_next_offset() {
  local response_file="${1:?Usage: testrail_next_offset RESPONSE_FILE}"

  jq -er '._links.next // empty | capture("(^|[?&])offset=(?<offset>[0-9]+)") | .offset' "$response_file" 2>/dev/null || true
}

testrail_collect_cases() {
  local project_id="${1:?Usage: testrail_collect_cases PROJECT_ID [--suite SUITE_ID] [--section SECTION_ID] [--limit LIMIT]}"
  shift

  local suite_id="" section_id="" page_limit="${TESTRAIL_PAGE_LIMIT:-250}"
  local offset=0 total_cases=0
  local page_json page_case_count next_offset page_size endpoint
  local cases_file page_file merged_file

  while (($#)); do
    case "$1" in
      --suite)
        suite_id="${2:?Usage: testrail_collect_cases PROJECT_ID [--suite SUITE_ID] [--section SECTION_ID] [--limit LIMIT]}"
        shift 2
        ;;
      --section)
        section_id="${2:?Usage: testrail_collect_cases PROJECT_ID [--suite SUITE_ID] [--section SECTION_ID] [--limit LIMIT]}"
        shift 2
        ;;
      --limit)
        page_limit="${2:?Usage: testrail_collect_cases PROJECT_ID [--suite SUITE_ID] [--section SECTION_ID] [--limit LIMIT]}"
        shift 2
        ;;
      *)
        echo "Error: unsupported collect_cases option '$1'" >&2
        return 1
        ;;
    esac
  done

  testrail_make_temp_file cases_file collect-cases
  printf '[]\n' > "$cases_file"

  while :; do
    local page_args=(--limit "$page_limit" --offset "$offset")
    [[ -n "$section_id" ]] && page_args+=(--section "$section_id")
    [[ -n "$suite_id" ]] && page_args+=(--suite "$suite_id")

    endpoint="$(testrail_cases_endpoint "$project_id" "${page_args[@]}")"
    page_json="$(testrail_api GET "$endpoint" -H "Content-Type: application/json")"

    testrail_make_temp_file page_file collect-cases-page
    testrail_make_temp_file merged_file collect-cases-merged
    printf '%s\n' "$page_json" > "$page_file"

    page_case_count="$(jq -er '(.cases // []) | length' "$page_file")"
    total_cases=$((total_cases + page_case_count))

    jq -s '.[0] + (.[1].cases // [])' "$cases_file" "$page_file" > "$merged_file"
    mv "$merged_file" "$cases_file"

    next_offset="$(testrail_next_offset "$page_file")"
    if [[ -n "$next_offset" ]]; then
      offset="$next_offset"
      continue
    fi

    page_size="$(jq -r '.size // empty' "$page_file")"
    if [[ "$page_size" =~ ^[0-9]+$ ]] && (( offset + page_case_count < page_size )); then
      offset=$((offset + page_case_count))
      continue
    fi

    break
  done

  jq -n \
    --argjson count "$total_cases" \
    --slurpfile cases "$cases_file" \
    '{
      count: $count,
      cases: $cases[0]
    }'
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
  local env_override env_file

  TESTRAIL_REPO_ROOT="$(testrail_repo_root)"
  TESTRAIL_ENV_FILE_USED=""
  TESTRAIL_ENV_SOURCE=""

  if [[ -n "${TESTRAIL_ENV_FILE:-}" ]]; then
    env_override="$(testrail_normalize_input_path "$TESTRAIL_ENV_FILE")"

    if [[ ! -f "$env_override" ]]; then
      echo "Error: TESTRAIL_ENV_FILE points to missing file '$TESTRAIL_ENV_FILE'" >&2
      exit 1
    fi

    testrail_load_env_file "$env_override" "TESTRAIL_ENV_FILE"
  else
    env_file="$(testrail_find_ancestor_file "$TESTRAIL_REPO_ROOT" ".env" || true)"
    if [[ -n "$env_file" ]]; then
      testrail_load_env_file "$env_file" "ancestor-search"
    fi
  fi

  : "${TESTRAIL_URL:?TESTRAIL_URL not set. Create .env file with credentials or set TESTRAIL_ENV_FILE}"
  : "${TESTRAIL_USER:?TESTRAIL_USER not set. Create .env file with credentials or set TESTRAIL_ENV_FILE}"
  : "${TESTRAIL_API_KEY:?TESTRAIL_API_KEY not set. Create .env file with credentials or set TESTRAIL_ENV_FILE}"

  TESTRAIL_URL="${TESTRAIL_URL%/}"

  testrail_require_command curl
  testrail_require_command jq
  testrail_emit_env_source
}
