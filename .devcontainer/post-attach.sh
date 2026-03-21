#!/usr/bin/env bash
set -euo pipefail

# -------------------------------------------------------
# 1. Validate .env file exists and has required variables
# -------------------------------------------------------
echo "🔍 Checking environment configuration..."
bash .devcontainer/check-env.sh

# -------------------------------------------------------
# 2. Set up Python virtual environment
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
