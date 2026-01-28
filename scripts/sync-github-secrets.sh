#!/usr/bin/env bash
set -euo pipefail

# Sync .env to GitHub Secrets
# Requires: gh CLI authenticated

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "🔐 Syncing .env to GitHub Secrets"
echo "===================================="
echo ""

# Check if gh CLI is installed
if ! command -v gh >/dev/null 2>&1; then
  echo "❌ GitHub CLI (gh) er ikke installert!"
  echo ""
  echo "Installer med:"
  echo "  brew install gh"
  echo "Eller:"
  echo "  https://cli.github.com/"
  exit 1
fi

# Check if .env exists
if [[ ! -f .env ]]; then
  echo "❌ .env ikke funnet!"
  echo ""
  echo "Kjør først:"
  echo "  bash scripts/setup-supabase-env.sh"
  exit 1
fi

# Load .env
set -a
source .env
set +a

echo "Validerer verdier..."

# Validate required vars
REQUIRED_VARS=(
  "SUPABASE_PROJECT_REF"
  "SUPABASE_URL"
  "SUPABASE_ANON_KEY"
  "SUPABASE_SERVICE_ROLE_KEY"
  "SUPABASE_ACCESS_TOKEN"
)

for var in "${REQUIRED_VARS[@]}"; do
  if [[ -z "${!var:-}" ]]; then
    echo "❌ Mangler: $var"
    exit 1
  fi
  echo "  ✓ $var"
done

echo ""
echo "Syncer til GitHub Secrets..."
echo ""

# Set each secret
gh secret set SUPABASE_PROJECT_REF -b "$SUPABASE_PROJECT_REF"
gh secret set SUPABASE_URL -b "$SUPABASE_URL"
gh secret set SUPABASE_ANON_KEY -b "$SUPABASE_ANON_KEY"
gh secret set SUPABASE_SERVICE_ROLE_KEY -b "$SUPABASE_SERVICE_ROLE_KEY"
gh secret set SUPABASE_ACCESS_TOKEN -b "$SUPABASE_ACCESS_TOKEN"

# Optional: Set other vars if present
if [[ -n "${PPLX_API_KEY:-}" ]]; then
  echo "Setter PPLX_API_KEY..."
  gh secret set PPLX_API_KEY -b "$PPLX_API_KEY"
fi

if [[ -n "${WEBFLOW_API_TOKEN:-}" ]]; then
  echo "Setter WEBFLOW_API_TOKEN..."
  gh secret set WEBFLOW_API_TOKEN -b "$WEBFLOW_API_TOKEN"
fi

echo ""
echo "✓ Alle secrets synkronisert!"
echo ""
echo "Verifiser:"
echo "  gh secret list"
echo ""
echo "Trigger deploy:"
echo "  gh workflow run '🚀 Auto-Deploy Pipeline' --ref main -f environment=staging"
echo ""
