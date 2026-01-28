#!/usr/bin/env bash
set -euo pipefail

# Auto-setup GitHub Secrets from .env
# Requires: GitHub CLI (gh)

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"
cd "$ROOT_DIR"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo ""
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo -e "${GREEN}🔐 GitHub Secrets Setup${NC}"
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo ""

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ GitHub CLI not found${NC}"
    echo ""
    echo "Install it:"
    echo "  macOS: brew install gh"
    echo "  Linux: https://github.com/cli/cli/blob/trunk/docs/install_linux.md"
    echo ""
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo -e "${YELLOW}⚠️  Not authenticated with GitHub${NC}"
    echo ""
    echo "Run: gh auth login"
    echo ""
    exit 1
fi

echo -e "${GREEN}✅ GitHub CLI authenticated${NC}"
echo ""

# Load .env
if [[ ! -f .env ]]; then
    echo -e "${RED}❌ .env file not found${NC}"
    echo ""
    echo "Create it first with your secrets"
    exit 1
fi

# Source .env with safe defaults
set +u  # Temporarily disable unbound variable check
source .env
set -u  # Re-enable

# Define secrets with safe defaults
SUPABASE_ACCESS_TOKEN="${SUPABASE_ACCESS_TOKEN:-}"
SUPABASE_PROJECT_REF="${SUPABASE_PROJECT_REF:-}"
SUPABASE_URL="${SUPABASE_URL:-}"
SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY:-}"
SUPABASE_SECRET_KEY="${SUPABASE_SECRET_KEY:-}"
WEBFLOW_API_TOKEN="${WEBFLOW_API_TOKEN:-}"
WEBFLOW_SITE_ID="${WEBFLOW_SITE_ID:-}"
PPLX_API_KEY="${PPLX_API_KEY:-}"

# Secrets to sync
declare -A SECRETS=(
    ["SUPABASE_ACCESS_TOKEN"]="$SUPABASE_ACCESS_TOKEN"
    ["SUPABASE_PROJECT_REF"]="$SUPABASE_PROJECT_REF"
    ["SUPABASE_URL"]="$SUPABASE_URL"
    ["SUPABASE_ANON_KEY"]="$SUPABASE_ANON_KEY"
    ["SUPABASE_SECRET_KEY"]="$SUPABASE_SECRET_KEY"
    ["WEBFLOW_API_TOKEN"]="$WEBFLOW_API_TOKEN"
    ["WEBFLOW_SITE_ID"]="$WEBFLOW_SITE_ID"
    ["PPLX_API_KEY"]="$PPLX_API_KEY"
)

echo -e "${BLUE}Setting secrets for repository: tombomann/klarpakke${NC}"
echo ""

SUCCESS_COUNT=0
SKIP_COUNT=0
ERROR_COUNT=0

for SECRET_NAME in "${!SECRETS[@]}"; do
    SECRET_VALUE="${SECRETS[$SECRET_NAME]}"
    
    if [[ -z "$SECRET_VALUE" ]]; then
        echo -e "${YELLOW}⏭  Skipping ${SECRET_NAME} (empty)${NC}"
        ((SKIP_COUNT++))
        continue
    fi
    
    echo -n "Setting ${SECRET_NAME}... "
    
    if echo "$SECRET_VALUE" | gh secret set "$SECRET_NAME" --repo tombomann/klarpakke 2>/dev/null; then
        echo -e "${GREEN}✓${NC}"
        ((SUCCESS_COUNT++))
    else
        echo -e "${RED}✗${NC}"
        ((ERROR_COUNT++))
    fi
done

echo ""
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo -e "${GREEN}📊 Summary${NC}"
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo -e "✅ Success: ${SUCCESS_COUNT}"
echo -e "⏭  Skipped: ${SKIP_COUNT}"
echo -e "❌ Errors:  ${ERROR_COUNT}"
echo ""

if [[ $SUCCESS_COUNT -gt 0 ]]; then
    echo -e "${GREEN}✅ Secrets synced to GitHub!${NC}"
    echo ""
    echo "Verify at:"
    echo "  https://github.com/tombomann/klarpakke/settings/secrets/actions"
    echo ""
fi
