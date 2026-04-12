#!/usr/bin/env bash
set -euo pipefail

export PATH="$HOME/.local/bin:$PATH"

echo "Installing dependencies with uv..."
uv venv .venv
source .venv/bin/activate
uv pip install -e .

echo "Done. Virtual environment ready at .venv/"
