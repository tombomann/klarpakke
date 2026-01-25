#!/bin/bash
set -euo pipefail

echo "════════════════════════════════════════════════════════════════"
echo "🔐 GITHUB SECRETS SETUP (replacing .env)"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "This will migrate secrets from .env.migration to GitHub Secrets"
echo "Requires: gh CLI (brew install gh)"
echo ""

# Check gh CLI
if ! command -v gh &> /dev/null; then
    echo "❌ gh CLI not found!"
    echo ""
    echo "Install with:"
    echo "  brew install gh"
    echo ""
    exit 1
fi

# Check authentication
if ! gh auth status &> /dev/null; then
    echo "❌ Not authenticated with GitHub!"
    echo ""
    echo "Run: gh auth login"
    echo ""
    exit 1
fi

echo "✅ gh CLI found and authenticated"
echo ""

# Load .env.migration
if [ ! -f .env.migration ]; then
    echo "❌ .env.migration not found!"
    echo ""
    echo "Create it first with your secrets"
    exit 1
fi

source .env.migration

echo "📤 Uploading secrets to GitHub..."
echo ""

# Upload each secret
gh secret set SUPABASE_PROJECT_ID --body "$SUPABASE_PROJECT_ID" && echo "  ✅ SUPABASE_PROJECT_ID"
gh secret set SUPABASE_SERVICE_ROLE_KEY --body "$SUPABASE_SERVICE_ROLE_KEY" && echo "  ✅ SUPABASE_SERVICE_ROLE_KEY"
gh secret set SUPABASE_DB_URL --body "$SUPABASE_DB_URL" && echo "  ✅ SUPABASE_DB_URL"

# Optional: Binance keys (if they exist)
if [ -n "${BINANCE_API_KEY:-}" ]; then
    gh secret set BINANCE_API_KEY --body "$BINANCE_API_KEY" && echo "  ✅ BINANCE_API_KEY"
fi

if [ -n "${BINANCE_SECRET_KEY:-}" ]; then
    gh secret set BINANCE_SECRET_KEY --body "$BINANCE_SECRET_KEY" && echo "  ✅ BINANCE_SECRET_KEY"
fi

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "✅ ALL SECRETS UPLOADED TO GITHUB!"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "🔒 Security improvements:"
echo "  ✅ No more .env files in repo"
echo "  ✅ Secrets encrypted by GitHub"
echo "  ✅ Audit trail of secret access"
echo "  ✅ Auto-available in GitHub Actions"
echo ""
echo "📝 Next steps:"
echo ""
echo "1. Delete .env.migration (recommended):"
echo "   rm .env.migration"
echo ""
echo "2. Add to .gitignore (if not already):"
echo "   echo '.env*' >> .gitignore"
echo ""
echo "3. Update workflows to use:"
echo "   \${{ secrets.SUPABASE_SERVICE_ROLE_KEY }}"
echo ""
echo "4. View secrets:"
echo "   gh secret list"
echo ""
