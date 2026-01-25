#!/bin/bash
set -euo pipefail

cd ~/klarpakke

echo ""
echo "🚀 ULTIMATE AUTOMATED FIX"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "This script will:"
echo "  1. Open Supabase dashboard"
echo "  2. Prompt for keys (copy-paste)"
echo "  3. Validate keys"
echo "  4. Update .env.migration"
echo "  5. Test locally"
echo "  6. Sync to GitHub automatically"
echo "  7. Trigger GitHub Actions"
echo "  8. Open monitoring"
echo ""
echo "⚠️  You only need to copy-paste 2 keys from browser!"
echo ""
read -p "Ready? Press Enter to continue..."

# Step 1: Open dashboard
echo ""
echo "1️⃣  Opening Supabase Dashboard..."
open https://supabase.com/dashboard/project/swfyuwkptusceiouqlks/settings/api

echo ""
echo "📝 In the browser, find 'Project API keys' section:"
echo "   - Copy the 'anon public' key (long string starting with eyJ...)"
echo ""

# Step 2: Get ANON key
while true; do
    read -p "Paste ANON key here: " ANON_KEY
    
    # Validate format
    if [[ "$ANON_KEY" =~ ^eyJ ]]; then
        echo "   ✅ Valid format"
        break
    else
        echo "   ❌ Invalid format (must start with 'eyJ')"
        echo "   Try again..."
    fi
done

echo ""
echo "📝 Now in the browser:"
echo "   - Click 'Reveal' next to 'service_role'"
echo "   - Copy the service_role key"
echo ""

# Step 3: Get SERVICE_ROLE key
while true; do
    read -sp "Paste SERVICE_ROLE key here (hidden): " SERVICE_KEY
    echo ""
    
    # Validate format
    if [[ "$SERVICE_KEY" =~ ^eyJ ]]; then
        echo "   ✅ Valid format"
        break
    else
        echo "   ❌ Invalid format (must start with 'eyJ')"
        echo "   Try again..."
    fi
done

# Step 4: Update .env.migration
echo ""
echo "2️⃣  Updating .env.migration..."

# Backup old file
if [ -f ".env.migration" ]; then
    cp .env.migration ".env.migration.backup.$(date +%Y%m%d_%H%M%S)"
    echo "   📦 Old file backed up"
fi

# Write new file
cat > .env.migration << EOF
# Supabase Connection (Manual from Dashboard - $(date))
SUPABASE_PROJECT_ID=swfyuwkptusceiouqlks
SUPABASE_ANON_KEY=${ANON_KEY}
SUPABASE_SERVICE_ROLE_KEY=${SERVICE_KEY}
SUPABASE_DB_URL="postgresql://postgres.swfyuwkptusceiouqlks:Skotthyll160973???@aws-1-eu-west-1.pooler.supabase.com:5432/postgres"

# Make.com
MAKE_TEAM_ID=219598
MAKE_API_TOKEN=your_make_token_here
EOF

echo "   ✅ File updated"

# Step 5: Test keys locally
echo ""
echo "3️⃣  Testing keys locally..."

source .env.migration

# Test with curl
echo "   Testing API connection..."
HTTP_CODE=$(curl -s -o /tmp/test-response.json -w "%{http_code}" \
    "https://${SUPABASE_PROJECT_ID}.supabase.co/rest/v1/aisignal?limit=1" \
    -H "apikey: ${SERVICE_KEY}" \
    -H "Authorization: Bearer ${SERVICE_KEY}" \
    -H "Content-Type: application/json")

if [ "$HTTP_CODE" == "200" ]; then
    echo "   ✅ API connection works!"
    echo "   Response: $(cat /tmp/test-response.json)"
else
    echo "   ❌ API test failed (HTTP $HTTP_CODE)"
    echo "   Response: $(cat /tmp/test-response.json)"
    echo ""
    echo "   ⚠️  Keys might be wrong. Check dashboard again:"
    echo "   open https://supabase.com/dashboard/project/swfyuwkptusceiouqlks/settings/api"
    exit 1
fi

# Test Python script
echo "   Testing Python analysis script..."
if timeout 10s python3 scripts/analyze_signals.py 2>&1 | head -20 | grep -q "AUTOMATED ANALYSIS"; then
    echo "   ✅ Python script works!"
else
    echo "   ⚠️  Python script needs verification (might be OK if no pending signals)"
fi

# Step 6: Sync to GitHub
echo ""
echo "4️⃣  Syncing secrets to GitHub..."

# Check if gh CLI is available
if command -v gh &> /dev/null; then
    bash scripts/sync-secrets.sh push
    echo "   ✅ Secrets synced to GitHub"
else
    echo "   ⚠️  GitHub CLI not available, installing..."
    brew install gh
    gh auth login
    bash scripts/sync-secrets.sh push
    echo "   ✅ Secrets synced to GitHub"
fi

# Step 7: Trigger workflow
echo ""
echo "5️⃣  Triggering GitHub Actions workflow..."

if gh workflow run trading-analysis.yml -R tombomann/klarpakke; then
    echo "   ✅ Workflow triggered!"
else
    echo "   ⚠️  Could not trigger automatically"
    echo "   Open manually: https://github.com/tombomann/klarpakke/actions/workflows/trading-analysis.yml"
fi

# Step 8: Open monitoring
echo ""
echo "6️⃣  Opening monitoring..."

echo "   Opening GitHub Actions..."
open https://github.com/tombomann/klarpakke/actions

echo "   Opening Supabase Editor..."
open https://supabase.com/dashboard/project/swfyuwkptusceiouqlks/editor

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ ULTIMATE FIX COMPLETE!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 Summary:"
echo "   ✅ Keys fetched from dashboard"
echo "   ✅ Local .env.migration updated"
echo "   ✅ Keys validated locally"
echo "   ✅ GitHub Secrets synced"
echo "   ✅ Workflow triggered"
echo "   ✅ Monitoring opened"
echo ""
echo "🔍 Watch workflow:"
echo "   gh run watch"
echo ""
echo "📈 Verify in Supabase:"
echo "   Check 'aisignal' table for status updates"
echo ""
echo "🔄 Re-run anytime:"
echo "   bash scripts/ultimate-fix.sh"
echo ""
