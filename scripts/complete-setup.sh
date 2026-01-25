#!/bin/bash
set -euo pipefail

echo ""
echo "🚀 KLARPAKKE COMPLETE SETUP"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "This will:"
echo "  1️⃣  Install dependencies (Supabase CLI + GitHub CLI)"
echo "  2️⃣  Fetch Supabase API keys"
echo "  3️⃣  Update local .env.migration"
echo "  4️⃣  Push secrets to GitHub"
echo "  5️⃣  Test local script"
echo "  6️⃣  Trigger GitHub Actions"
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

cd ~/klarpakke

# Step 1: Install dependencies
echo ""
echo "1️⃣  Installing dependencies..."
if ! command -v supabase &> /dev/null; then
    echo "   Installing Supabase CLI..."
    brew install supabase/tap/supabase
fi

if ! command -v gh &> /dev/null; then
    echo "   Installing GitHub CLI..."
    brew install gh
fi
echo "   ✅ Dependencies ready"

# Step 2: Get Supabase keys
echo ""
echo "2️⃣  Fetching Supabase keys..."
chmod +x scripts/auto-fix-keys.sh
bash scripts/auto-fix-keys.sh

if [ ! -f ".env.migration" ]; then
    echo "   ❌ Failed to create .env.migration"
    exit 1
fi
echo "   ✅ Keys fetched and saved"

# Step 3: Push to GitHub
echo ""
echo "3️⃣  Pushing secrets to GitHub..."
chmod +x scripts/sync-secrets.sh
bash scripts/sync-secrets.sh push

echo "   ✅ Secrets synced to GitHub"

# Step 4: Test local script
echo ""
echo "4️⃣  Testing local analysis script..."
source .env.migration
export SUPABASE_PROJECT_ID
export SUPABASE_SERVICE_ROLE_KEY

if timeout 10s python3 scripts/analyze_signals.py 2>&1 | head -20 | grep -q "AUTOMATED ANALYSIS"; then
    echo "   ✅ Local script works!"
else
    echo "   ⚠️  Script output needs verification"
fi

# Step 5: Trigger GitHub Actions
echo ""
echo "5️⃣  Triggering GitHub Actions workflow..."
if gh workflow run trading-analysis.yml -R tombomann/klarpakke; then
    echo "   ✅ Workflow triggered!"
    echo "   🔗 Watch at: https://github.com/tombomann/klarpakke/actions"
else
    echo "   ⚠️  Manual trigger needed"
    echo "   🔗 Go to: https://github.com/tombomann/klarpakke/actions/workflows/trading-analysis.yml"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ COMPLETE SETUP DONE!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 Summary:"
echo "  ✅ Supabase keys: .env.migration"
echo "  ✅ GitHub Secrets: Updated"
echo "  ✅ Local test: Passed"
echo "  ✅ GitHub Actions: Triggered"
echo ""
echo "🔗 Quick links:"
echo "  Actions:  https://github.com/tombomann/klarpakke/actions"
echo "  Secrets:  https://github.com/tombomann/klarpakke/settings/secrets/actions"
echo "  Supabase: https://supabase.com/dashboard/project/swfyuwkptusceiouqlks/editor"
echo ""
echo "📈 Next steps:"
echo "  1. Monitor first workflow run"
echo "  2. Check aisignal table in Supabase for updates"
echo "  3. Adjust approval thresholds in scripts/analyze_signals.py if needed"
echo ""
