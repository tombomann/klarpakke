#!/bin/bash
set -euo pipefail

PROJECT_REF="swfyuwkptusceiouqlks"
ENV_FILE=".env.migration"

echo ""
echo "🚀 ULTRA-QUICK KEY FIX"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🎯 Opening Supabase dashboard..."
open "https://supabase.com/dashboard/project/${PROJECT_REF}/settings/api"

echo ""
echo "📝 Copy keys from the browser and paste here:"
echo ""

# Get ANON key
read -p "1️⃣  Paste ANON key (anon public): " ANON_KEY

# Get SERVICE_ROLE key
echo ""
read -sp "2️⃣  Paste SERVICE_ROLE key (click 'Reveal' first): " SERVICE_KEY
echo ""
echo ""

# Validate format
if [[ ! "$ANON_KEY" =~ ^eyJ ]]; then
    echo "❌ Invalid ANON key format (must start with 'eyJ')"
    exit 1
fi

if [[ ! "$SERVICE_KEY" =~ ^eyJ ]]; then
    echo "❌ Invalid SERVICE_ROLE key format (must start with 'eyJ')"
    exit 1
fi

echo "🧪 Testing SERVICE_ROLE key..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
    "https://${PROJECT_REF}.supabase.co/rest/v1/" \
    -H "apikey: ${SERVICE_KEY}" \
    -H "Authorization: Bearer ${SERVICE_KEY}")

if [ "$HTTP_CODE" != "200" ] && [ "$HTTP_CODE" != "404" ]; then
    echo "❌ Key test failed (HTTP $HTTP_CODE)"
    echo "   Try copying the key again from dashboard"
    exit 1
fi

echo "✅ Keys validated!"
echo ""

# Backup
if [ -f "$ENV_FILE" ]; then
    cp "$ENV_FILE" "${ENV_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
    echo "📦 Old .env backed up"
fi

# Update env file
cat > "$ENV_FILE" << EOF
# Supabase Connection (Updated: $(date))
SUPABASE_PROJECT_ID=${PROJECT_REF}
SUPABASE_ANON_KEY=${ANON_KEY}
SUPABASE_SERVICE_ROLE_KEY=${SERVICE_KEY}
SUPABASE_DB_URL="postgresql://postgres.${PROJECT_REF}:Skotthyll160973???@aws-1-eu-west-1.pooler.supabase.com:5432/postgres"

# Make.com
MAKE_TEAM_ID=219598
MAKE_API_TOKEN=your_make_token_here
EOF

echo "✅ .env.migration updated"
echo ""

# Test local script
echo "🧪 Testing local script..."
source "$ENV_FILE"
export SUPABASE_PROJECT_ID
export SUPABASE_SERVICE_ROLE_KEY

if timeout 10s python3 scripts/analyze_signals.py 2>&1 | head -20 | grep -q "AUTOMATED ANALYSIS"; then
    echo "✅ Local script works!"
else
    echo "⚠️  Check output manually if needed"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ DONE! Now update GitHub Secrets:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Run these commands:"
echo ""
echo "# Copy SERVICE_ROLE key to clipboard:"
echo "grep SUPABASE_SERVICE_ROLE_KEY .env.migration | cut -d'=' -f2 | pbcopy"
echo ""
echo "# Open GitHub Secrets page:"
echo "open https://github.com/tombomann/klarpakke/settings/secrets/actions"
echo ""
echo "# Then in GitHub:"
echo "1. Update SUPABASE_PROJECT_ID = ${PROJECT_REF}"
echo "2. Update SUPABASE_SERVICE_ROLE_KEY = <paste from clipboard>"
echo ""
echo "# Test workflow:"
echo "open https://github.com/tombomann/klarpakke/actions/workflows/trading-analysis.yml"
echo ""
