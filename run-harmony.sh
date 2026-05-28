#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"

DEVECO_HOME_DEFAULT="/Applications/DevEco-Studio.app/Contents"
DEVECO_HOME="${DEVECO_HOME:-$DEVECO_HOME_DEFAULT}"
NODE_BIN="${NODE_BIN:-$DEVECO_HOME/tools/node/bin/node}"
HVIGOR_JS="${HVIGOR_JS:-$DEVECO_HOME/tools/hvigor/bin/hvigorw.js}"
HDC_BIN="${HDC_BIN:-$DEVECO_HOME/sdk/default/openharmony/toolchains/hdc}"

BUNDLE_NAME="${BUNDLE_NAME:-com.hyx.clock}"
ABILITY_NAME="${ABILITY_NAME:-EntryAbility}"
REMOTE_TMP_DIR_BASE="${REMOTE_TMP_DIR_BASE:-/data/local/tmp}"
PRODUCT_NAME="${PRODUCT_NAME:-debug}"
BUILD_MODE="${BUILD_MODE:-debug}"
TARGET="${HDC_TARGET:-}"
CUSTOM_PACKAGE_PATH=""
SKIP_BUILD=0
SKIP_INSTALL=0
SKIP_START=0
LIST_TARGETS=0

usage() {
  cat <<'EOF'
Usage:
  ./run-harmony.sh [options]

Options:
      -t, --target <connectKey>  Use the specified hdc target.
      --hap <path>           Install a prebuilt .hap or .app package.
      --skip-build           Skip hvigor build and reuse the current build output or --hap.
      --skip-install         Skip hdc install.
      --skip-start           Skip app launch after install.
      --list-targets         Print hdc targets and exit.
  -h, --help                 Show this help message.

Environment variables:
  DEVECO_HOME     DevEco Studio Contents directory.
  NODE_BIN        Node executable used to run hvigorw.js.
  HVIGOR_JS       hvigorw.js path.
  HDC_BIN         hdc executable path.
  HDC_TARGET      Default hdc target if --target is not passed.
  BUNDLE_NAME     App bundle name. Default: com.hyx.accountbook
  ABILITY_NAME    App ability name. Default: EntryAbility
  PRODUCT_NAME    Hvigor product name. Default: debug
  BUILD_MODE      Hvigor build mode. Default: debug

Examples:
  ./run-harmony.sh
  ./run-harmony.sh --target 192.168.1.10:10178
  ./run-harmony.sh --skip-build
  ./run-harmony.sh --hap /tmp/entry-default.hap --skip-build
  ./run-harmony.sh --hap /tmp/AccountBook-default-signed.app --skip-build
EOF
}

log() {
  printf '[run-harmony] %s\n' "$*"
}

fail() {
  printf '[run-harmony] %s\n' "$*" >&2
  exit 1
}

require_executable() {
  local path="$1"
  local label="$2"
  [[ -x "$path" ]] || fail "$label not found or not executable: $path"
}

require_file() {
  local path="$1"
  local label="$2"
  [[ -f "$path" ]] || fail "$label not found: $path"
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -t|--target)
        [[ $# -ge 2 ]] || fail "Missing value for $1"
        TARGET="$2"
        shift 2
        ;;
      --hap)
        [[ $# -ge 2 ]] || fail "Missing value for $1"
        CUSTOM_PACKAGE_PATH="$2"
        shift 2
        ;;
      --skip-build)
        SKIP_BUILD=1
        shift
        ;;
      --skip-install)
        SKIP_INSTALL=1
        shift
        ;;
      --skip-start)
        SKIP_START=1
        shift
        ;;
      --list-targets)
        LIST_TARGETS=1
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        fail "Unknown option: $1"
        ;;
    esac
  done
}

resolve_tools() {
  require_executable "$NODE_BIN" "Node"
  require_file "$HVIGOR_JS" "hvigorw.js"
  require_executable "$HDC_BIN" "hdc"
  command -v unzip >/dev/null 2>&1 || fail "unzip is required but was not found in PATH"
}

list_targets() {
  local output

  "$HDC_BIN" start >/dev/null 2>&1 || true
  output="$("$HDC_BIN" list targets 2>&1 || true)"

  if printf '%s' "$output" | grep -q "Connect server failed"; then
    fail "Unable to connect to hdc server. Try running '$HDC_BIN start' manually or reopen DevEco Studio."
  fi

  printf '%s\n' "$output"
}

ensure_target_ready() {
  local targets
  targets="$(list_targets | sed '/^[[:space:]]*$/d;/^\[Empty\]$/d;/^Empty$/d')"
  [[ -n "$targets" ]] || fail "No Harmony device detected. Connect a device first or run with --list-targets."

  local target_count
  target_count="$(printf '%s\n' "$targets" | awk 'NF {count++} END {print count + 0}')"

  if [[ -z "$TARGET" && "$target_count" -gt 1 ]]; then
    printf '[run-harmony] Multiple devices detected:\n%s\n' "$targets" >&2
    fail "Use --target <connectKey> to choose one device."
  fi

  if [[ -z "$TARGET" ]]; then
    TARGET="$(printf '%s\n' "$targets" | awk 'NF {print $1; exit}')"
    log "Using hdc target: ${TARGET}"
  fi
}

run_hdc() {
  local cmd=("$HDC_BIN")
  if [[ -n "$TARGET" ]]; then
    cmd+=("-t" "$TARGET")
  fi
  cmd+=("$@")
  "${cmd[@]}"
}

remote_install_dir() {
  printf '%s\n' "${REMOTE_TMP_DIR_BASE}/accountbook_install_$(date +%s)"
}

install_package() {
  local package_path="$1"
  local package_name
  local remote_dir
  local remote_path
  local install_output

  package_name="$(basename "$package_path")"
  remote_dir="$(remote_install_dir)"
  remote_path="${remote_dir}/${package_name}"

  log "Preparing remote install directory: ${remote_dir}"
  run_hdc shell mkdir -p "$remote_dir"

  log "Uploading ${package_name}"
  run_hdc file send "$package_path" "$remote_path"

  log "Installing ${package_name}"
  install_output="$(run_hdc shell bm install -p "$remote_path" -r 2>&1 || true)"
  printf '%s\n' "$install_output"

  run_hdc shell rm -rf "$remote_dir" >/dev/null 2>&1 || true

  if printf '%s' "$install_output" | grep -qiE 'success|successfully'; then
    return 0
  fi

  fail "Install failed for ${package_name}"
}

build_app() {
  log "Building Harmony hap with hvigor (product=${PRODUCT_NAME}, buildMode=${BUILD_MODE})"
  (
    cd "$PROJECT_DIR"
    "$NODE_BIN" "$HVIGOR_JS" assembleHap --mode module -p module=entry@default -p product="${PRODUCT_NAME}" -p buildMode="${BUILD_MODE}" --no-daemon
  )
}

resolve_signed_hap() {
  local haps=(
    "$PROJECT_DIR"/entry/build/"${PRODUCT_NAME}"/outputs/default/*-signed.hap
    "$PROJECT_DIR"/entry/build/"${PRODUCT_NAME}"/outputs/default/app/*.hap
    "$PROJECT_DIR"/entry/build/"${PRODUCT_NAME}"/outputs/"${PRODUCT_NAME}"/*-signed.hap
    "$PROJECT_DIR"/entry/build/"${PRODUCT_NAME}"/outputs/"${PRODUCT_NAME}"/app/*.hap
    "$PROJECT_DIR"/entry/build/default/outputs/default/*-signed.hap
    "$PROJECT_DIR"/entry/build/default/outputs/default/app/*.hap
  )
  local path=""
  for candidate in "${haps[@]}"; do
    if [[ -e "$candidate" ]]; then
      path="$candidate"
      break
    fi
  done
  [[ -n "$path" ]] || fail "No signed .hap package found under entry/build/${PRODUCT_NAME}/outputs/default. Run a build first."
  printf '%s\n' "$path"
}

resolve_install_path() {
  if [[ -n "$CUSTOM_PACKAGE_PATH" ]]; then
    require_file "$CUSTOM_PACKAGE_PATH" "App package"
    printf '%s\n' "$CUSTOM_PACKAGE_PATH"
    return
  fi

  resolve_signed_hap
}

main() {
  parse_args "$@"
  resolve_tools

  if [[ "$LIST_TARGETS" -eq 1 ]]; then
    list_targets
    exit 0
  fi

  if [[ "$SKIP_BUILD" -eq 0 ]]; then
    build_app
  else
    log "Skipping build"
  fi

  if [[ "$SKIP_INSTALL" -eq 0 || "$SKIP_START" -eq 0 ]]; then
    ensure_target_ready
  fi

  local package_path=""
  if [[ "$SKIP_INSTALL" -eq 0 ]]; then
    package_path="$(resolve_install_path)"
    install_package "$package_path"
  else
    log "Skipping install"
  fi

  if [[ "$SKIP_START" -eq 0 ]]; then
    log "Starting ${BUNDLE_NAME}/${ABILITY_NAME}"
    run_hdc shell aa start -a "$ABILITY_NAME" -b "$BUNDLE_NAME"
  else
    log "Skipping start"
  fi
}

main "$@"
