#!/usr/bin/env bash
set -euo pipefail

# -------------------------------------------------------
# 1. Set up Python virtual environment
# -------------------------------------------------------
VENV_DIR=".venv"

if [ -d "$VENV_DIR" ]; then
  echo "📦 Virtual environment already exists. Syncing dependencies..."
  uv sync
else
  echo "🔧 Creating virtual environment and installing dependencies..."
  uv venv "$VENV_DIR"
  uv sync
fi

echo "✅ Environment ready."

# -------------------------------------------------------
# 2. Start Ollama server in the background
# -------------------------------------------------------
if command -v ollama &>/dev/null; then
  if ! pgrep -x ollama &>/dev/null; then
    echo "🦙 Starting Ollama server in the background..."
    nohup ollama serve &>/tmp/ollama.log &
    echo "   Ollama PID: $! — logs at /tmp/ollama.log"
  else
    echo "🦙 Ollama is already running."
  fi
else
  echo "⚠️  Ollama not found. Skipping."
fi
