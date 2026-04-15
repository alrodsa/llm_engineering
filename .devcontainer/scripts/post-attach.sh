#!/usr/bin/env bash
set -euo pipefail

log_info() {
  echo "ℹ️  $1"
}

log_ok() {
  echo "✅ $1"
}

log_warn() {
  echo "⚠️  $1"
}

# -------------------------------------------------------
# 0. Conditionally install nvidia-smi in NVIDIA containers
# -------------------------------------------------------
if [[ -e /dev/nvidiactl || -e /proc/driver/nvidia/version || "${DEVCONTAINER_GPU_PROFILE:-}" == "nvidia" ]]; then
  if ! command -v nvidia-smi &>/dev/null; then
    log_info "NVIDIA container detected. Installing nvidia-smi..."

    # Debian slim images usually enable only main. nvidia-smi is in non-free.
    if [[ -f /etc/apt/sources.list.d/debian.sources ]]; then
      sudo sed -i 's/^Components: main$/Components: main contrib non-free non-free-firmware/g' /etc/apt/sources.list.d/debian.sources
    fi

    export DEBIAN_FRONTEND=noninteractive
    sudo apt-get update -y
    if apt-cache policy nvidia-smi | grep -q 'Candidate: (none)'; then
      log_warn "nvidia-smi package is not available in configured repositories."
      log_info "Ensure NVIDIA runtime and Debian non-free repositories are available on this host."
    else
      sudo apt-get install -y --no-install-recommends nvidia-smi
      log_ok "nvidia-smi installed successfully."
    fi
  else
    log_ok "nvidia-smi already installed."
  fi
fi

# -------------------------------------------------------
# 1. Set up Python virtual environment
# -------------------------------------------------------
VENV_DIR=".venv"

if [ -d "$VENV_DIR" ]; then
  log_info "Virtual environment already exists. Syncing dependencies..."
  uv sync
else
  log_info "Creating virtual environment and installing dependencies..."
  uv venv "$VENV_DIR"
  uv sync
fi

log_ok "Environment ready."

# -------------------------------------------------------
# 2. Start Ollama server in the background
# -------------------------------------------------------
if command -v ollama &>/dev/null; then
  if ! pgrep -x ollama &>/dev/null; then
    log_info "Starting Ollama server in the background..."
    nohup ollama serve &>/tmp/ollama.log &
    log_ok "Ollama PID: $! (logs at /tmp/ollama.log)"
  else
    log_ok "Ollama is already running."
  fi
else
  log_warn "Ollama not found. Skipping."
fi
