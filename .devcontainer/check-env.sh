#!/usr/bin/env bash
# =============================
# 🔍 Validates that .devcontainer/.env exists and has required variables
# Called automatically during devcontainer initialization.
# =============================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"
EXAMPLE_FILE="${SCRIPT_DIR}/example.env"

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# -------------------------------------------------------
# 1. Check that .env exists
# -------------------------------------------------------
if [ ! -f "$ENV_FILE" ]; then
    echo ""
    echo -e "${RED}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║  ❌  ERROR: .devcontainer/.env file not found!              ║${NC}"
    echo -e "${RED}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}The devcontainer requires a ${BOLD}.devcontainer/.env${NC}${YELLOW} file to run.${NC}"
    echo ""
    echo -e "To create one, copy the example and fill in your API keys:"
    echo ""
    echo -e "  ${GREEN}cp .devcontainer/example.env .devcontainer/.env${NC}"
    echo ""
    echo -e "Then edit ${BOLD}.devcontainer/.env${NC} and add your keys."
    echo -e "See ${BOLD}.devcontainer/example.env${NC} for all available variables."
    echo ""
    exit 1
fi

# -------------------------------------------------------
# 2. Check that .env is not empty (ignoring comments/blanks)
# -------------------------------------------------------
ACTIVE_LINES=$(grep -cvE '^\s*#|^\s*$' "$ENV_FILE" 2>/dev/null || true)

if [ "$ACTIVE_LINES" -eq 0 ]; then
    echo ""
    echo -e "${RED}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║  ⚠️   WARNING: .devcontainer/.env is empty!                 ║${NC}"
    echo -e "${RED}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}The .env file exists but contains no active variable definitions.${NC}"
    echo -e "Please add at least your ${BOLD}OPENAI_API_KEY${NC} to proceed."
    echo ""
    echo -e "Reference: ${BOLD}.devcontainer/example.env${NC}"
    echo ""
    exit 1
fi

# -------------------------------------------------------
# 3. Warn if OPENAI_API_KEY is missing or empty
# -------------------------------------------------------
OPENAI_KEY=$(grep -E '^OPENAI_API_KEY=' "$ENV_FILE" 2>/dev/null | head -1 | cut -d'=' -f2-)

if [ -z "$OPENAI_KEY" ]; then
    echo ""
    echo -e "${YELLOW}⚠️  WARNING: OPENAI_API_KEY is not set in .devcontainer/.env${NC}"
    echo -e "${YELLOW}   Most exercises require this key. You can add it later, but${NC}"
    echo -e "${YELLOW}   some notebooks will fail without it.${NC}"
    echo ""
else
    echo -e "${GREEN}✅ .env file found with OPENAI_API_KEY configured.${NC}"
fi

# -------------------------------------------------------
# 4. Show summary of configured keys
# -------------------------------------------------------
echo ""
echo -e "${BOLD}📋 Configured environment variables:${NC}"
while IFS='=' read -r key value; do
    # Skip comments and empty lines
    [[ "$key" =~ ^[[:space:]]*# ]] && continue
    [[ -z "$key" ]] && continue
    key=$(echo "$key" | xargs)  # trim whitespace
    if [ -n "$value" ]; then
        echo -e "   ${GREEN}✔${NC} ${key}"
    else
        echo -e "   ${YELLOW}○${NC} ${key} ${YELLOW}(empty)${NC}"
    fi
done < "$ENV_FILE"
echo ""
