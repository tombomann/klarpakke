#!/bin/bash
set -euo pipefail

PROJECT_REF="swfyuwkptusceiouqlks"
ENV_FILE=".env.migration"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔧 SUPABASE API KEY FIX"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "⚠️  Gamle keys er ugyldige. Hent nye fra:"
echo "   https://supabase.com/dashboard/project/${PROJECT_REF}/settings/api"
echo ""
echo "Du trenger:"
echo "   1. anon/public key"
echo "   2. service_role key (🔴 SECRET! Never expose publicly)"
echo ""

# Prompt for keys
read -p "📝 Lime inn ANON key: " ANON_KEY
echo ""
read -sp "📝 Lime inn SERVICE_ROLE key (hidden): " SERVICE_KEY
echo ""
echo ""

# Validate keys format (JWT structure)
if [[ ! "$ANON_KEY" =~ ^eyJ ]]; then
    echo "❌ Invalid ANON_KEY format (må starte med 'eyJ')"
    exit 1
fi

if [[ ! "$SERVICE_KEY" =~ ^eyJ ]]; then
    echo "❌ Invalid SERVICE_ROLE_KEY format (må starte med 'eyJ')"
    exit 1
fi

# Test keys
echo "🧪 Testing ANON key..."
ANON_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
  "https://${PROJECT_REF}.supabase.co/rest/v1/" \
  -H "apikey: ${ANON_KEY}" \
  -H "Authorization: Bearer ${ANON_KEY}")

if [ "$ANON_STATUS" != "200" ]; then
    echo "❌ ANON key test failed (HTTP $ANON_STATUS)"
    exit 1
fi
echo "✅ ANON key works"

echo "🧪 Testing SERVICE_ROLE key..."
SERVICE_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
  "https://${PROJECT_REF}.supabase.co/rest/v1/aisignal?limit=1" \
  -H "apikey: ${SERVICE_KEY}" \
  -H "Authorization: Bearer ${SERVICE_KEY}")

if [ "$SERVICE_STATUS" != "200" ]; then
    echo "❌ SERVICE_ROLE key test failed (HTTP $SERVICE_STATUS)"
    exit 1
fi
echo "✅ SERVICE_ROLE key works"

# Backup old env
if [ -f "$ENV_FILE" ]; then
    cp "$ENV_FILE" "${ENV_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
    echo "📦 Backed up old $ENV_FILE"
fi

# Update .env.migration
cat > "$ENV_FILE" << EOF
# Supabase Connection
SUPABASE_PROJECT_ID=${PROJECT_REF}
SUPABASE_ANON_KEY=${ANON_KEY}
SUPABASE_SERVICE_ROLE_KEY=${SERVICE_KEY}
SUPABASE_DB_URL="postgresql://postgres.${PROJECT_REF}:Skotthyll160973???@aws-1-eu-west-1.pooler.supabase.com:5432/postgres"

# Make.com
MAKE_TEAM_ID=219598
MAKE_API_TOKEN=your_make_token_here
EOF

echo "✅ Updated $ENV_FILE"

# Test local script
echo ""
echo "🧪 Testing local analysis script..."
source "$ENV_FILE"
export SUPABASE_PROJECT_ID
export SUPABASE_SERVICE_ROLE_KEY

if python3 scripts/analyze_signals.py 2>&1 | grep -q "AUTOMATED ANALYSIS"; then
    echo "✅ Local analysis script works!"
else
    echo "⚠️  Script ran but check output"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ KEYS VERIFIED AND UPDATED"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 NESTE STEG - Oppdater GitHub Secrets:"
echo ""
echo "1. Åpne: https://github.com/tombomann/klarpakke/settings/secrets/actions"
echo ""
echo "2. Oppdater disse secrets:"
echo "   SUPABASE_PROJECT_ID = ${PROJECT_REF}"
echo "   SUPABASE_SERVICE_ROLE_KEY = <lime inn SERVICE_ROLE key>"
echo ""
echo "3. Test workflow:"
echo "   https://github.com/tombomann/klarpakke/actions/workflows/trading-analysis.yml"
echo "   → Klikk 'Run workflow' → 'Run workflow'"
echo ""
echo "4. Verifiser i Supabase:"
echo "   https://supabase.com/dashboard/project/${PROJECT_REF}/editor"
echo "   → Sjekk aisignal tabell for oppdateringer"
echo ""
