#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEVCONTAINER_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
PROJECT_ROOT="$(cd "${DEVCONTAINER_DIR}/.." && pwd)"

CPU_PROFILE="${DEVCONTAINER_DIR}/profiles/devcontainer.cpu.json"
NVIDIA_PROFILE="${DEVCONTAINER_DIR}/profiles/devcontainer.gpu.json"
ACTIVE_CONFIG="${DEVCONTAINER_DIR}/devcontainer.json"
HOST_GPU_ENV="${DEVCONTAINER_DIR}/variables/.host-gpu.env"

MODE="auto"
DRY_RUN=false
REBUILD=false

log_info() {
    echo "ℹ️  $1"
}

log_ok() {
    echo "✅ $1"
}

log_warn() {
    echo "⚠️  $1"
}

usage() {
    cat <<'EOF'
Usage: .devcontainer/scripts/bootstrap-devcontainer.sh [options]

Options:
  --auto           Auto-select profile (default)
  --cpu            Force CPU profile
  --nvidia         Force NVIDIA profile
  --dry-run        Show selected profile without copying files
    --rebuild        Try to rebuild using Dev Container CLI after applying profile
  -h, --help       Show this help

Examples:
    bash .devcontainer/scripts/bootstrap-devcontainer.sh --auto
    bash .devcontainer/scripts/bootstrap-devcontainer.sh --nvidia
    bash .devcontainer/scripts/bootstrap-devcontainer.sh --cpu --dry-run
    bash .devcontainer/scripts/bootstrap-devcontainer.sh --auto --rebuild
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --auto)
            MODE="auto"
            ;;
        --cpu)
            MODE="cpu"
            ;;
        --nvidia)
            MODE="nvidia"
            ;;
        --dry-run)
            DRY_RUN=true
            ;;
        --rebuild)
            REBUILD=true
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            log_warn "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
    shift
done

if [[ ! -f "$CPU_PROFILE" ]]; then
    log_warn "Missing CPU profile: $CPU_PROFILE"
    exit 1
fi

if [[ ! -f "$NVIDIA_PROFILE" ]]; then
    log_warn "Missing NVIDIA profile: $NVIDIA_PROFILE"
    exit 1
fi

SELECTED_PROFILE=""
REASON=""

if [[ "$MODE" == "cpu" ]]; then
    SELECTED_PROFILE="$CPU_PROFILE"
    REASON="forced by --cpu"
elif [[ "$MODE" == "nvidia" ]]; then
    SELECTED_PROFILE="$NVIDIA_PROFILE"
    REASON="forced by --nvidia"
else
    log_info "Auto-detecting best container profile..."
    bash "${SCRIPT_DIR}/detect-host-gpu.sh"

    if [[ ! -f "$HOST_GPU_ENV" ]]; then
        log_warn "GPU detection did not create $HOST_GPU_ENV"
        exit 1
    fi

    # shellcheck disable=SC1090
    source "$HOST_GPU_ENV"

    if [[ "${DEVCONTAINER_HAS_NVIDIA_GPU:-false}" == "true" && "${DEVCONTAINER_HAS_NVIDIA_RUNTIME:-false}" == "true" ]]; then
        SELECTED_PROFILE="$NVIDIA_PROFILE"
        REASON="NVIDIA GPU + runtime detected"
    else
        SELECTED_PROFILE="$CPU_PROFILE"
        REASON="GPU/runtime not fully available"
    fi
fi

log_ok "Selected profile: $SELECTED_PROFILE"
log_info "Reason: $REASON"

if [[ "$DRY_RUN" == true ]]; then
    log_info "Dry run enabled. No files were changed."
    exit 0
fi

cp "$SELECTED_PROFILE" "$ACTIVE_CONFIG"

if [[ "$SELECTED_PROFILE" == "$NVIDIA_PROFILE" ]]; then
    log_ok "Applied NVIDIA profile to $ACTIVE_CONFIG"
else
    log_ok "Applied CPU profile to $ACTIVE_CONFIG"
fi

if [[ "$REBUILD" == true ]]; then
    if command -v devcontainer >/dev/null 2>&1; then
        log_info "Dev Container CLI found. Running rebuild..."
        devcontainer up --workspace-folder "$PROJECT_ROOT"
        log_ok "Rebuild completed by Dev Container CLI."
        log_info "If VS Code is still on the host window, use: Dev Containers: Reopen in Container"
    else
        log_warn "Dev Container CLI is not installed on this host."
        log_info "Automatic rebuild was skipped."
        log_info "Install the CLI and retry, or run: Dev Containers: Rebuild and Reopen in Container"
    fi
else
    log_info "Next step: Rebuild and reopen the dev container from $PROJECT_ROOT"
fi