#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOOTSTRAP_SCRIPT="${SCRIPT_DIR}/scripts/bootstrap-devcontainer.sh"

if [[ ! -f "${BOOTSTRAP_SCRIPT}" ]]; then
  echo "Missing bootstrap script: ${BOOTSTRAP_SCRIPT}"
  exit 1
fi

# Default behavior mirrors tasks: autoselect profile unless caller overrides mode.
if [[ $# -eq 0 ]]; then
  exec bash "${BOOTSTRAP_SCRIPT}" --auto
else
  exec bash "${BOOTSTRAP_SCRIPT}" "$@"
fi
