#!/bin/bash
set -euo pipefail

echo "🔧 Auto-fixing Supabase API keys..."
echo ""

PROJECT_REF="swfyuwkptusceiouqlks"

# Hent keys via Supabase CLI
echo "📡 Fetching API keys from Supabase..."
KEYS_OUTPUT=$(npx -y supabase projects api-keys --project-ref $PROJECT_REF 2>&1)

# Extract anon key
ANON_KEY=$(echo "$KEYS_OUTPUT" | grep -i "anon" | grep -oE 'eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+' | head -1)

# Extract service_role key
SERVICE_KEY=$(echo "$KEYS_OUTPUT" | grep -i "service" | grep -oE 'eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+' | head -1)

if [[ -z "$ANON_KEY" ]] || [[ -z "$SERVICE_KEY" ]]; then
  echo "❌ Failed to fetch keys. Manual fix needed."
  echo ""
  echo "Run this command and copy keys manually:"
  echo "npx supabase projects api-keys --project-ref $PROJECT_REF"
  exit 1
fi

echo "✅ Keys fetched successfully"
echo ""
echo "📝 Updating .env.migration..."

# Backup existing file
cp .env.migration .env.migration.backup 2>/dev/null || true

# Create new .env.migration
cat > .env.migration << EOF
# Supabase Configuration
SUPABASE_PROJECT_ID=$PROJECT_REF
SUPABASE_ANON_KEY=$ANON_KEY
SUPABASE_SERVICE_ROLE_KEY=$SERVICE_KEY

# Make.com Configuration
MAKE_ORG_ID=733572
MAKE_TEAM_ID=447181
MAKE_API_TOKEN=b6e26ff2-06f5-4544-b52d-4baae9003dfb
EOF

echo "✅ .env.migration updated"
echo ""
echo "🧪 Testing API connection..."

source .env.migration

# Test connection
TEST_RESPONSE=$(curl -s -w "\n%{http_code}" \
  "https://${SUPABASE_PROJECT_ID}.supabase.co/rest/v1/system_status" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Authorization: Bearer ${SUPABASE_ANON_KEY}")

HTTP_CODE=$(echo "$TEST_RESPONSE" | tail -n1)

if [[ "$HTTP_CODE" == "200" ]]; then
  echo "✅ API connection successful!"
  echo ""
  echo "📊 Running analysis test..."
  python3 scripts/analyze_signals.py
else
  echo "❌ API test failed (HTTP $HTTP_CODE)"
  BODY=$(echo "$TEST_RESPONSE" | sed '$d')
  echo "$BODY" | jq . 2>/dev/null || echo "$BODY"
  exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ AUTO-FIX COMPLETE!"
echo ""
echo "📋 Next steps:"
echo "1. Add GitHub Secrets:"
echo "   open https://github.com/tombomann/klarpakke/settings/secrets/actions"
echo ""
echo "   SUPABASE_PROJECT_ID = $PROJECT_REF"
echo "   SUPABASE_SERVICE_ROLE_KEY = $SERVICE_KEY"
echo ""
echo "2. Trigger GitHub Actions:"
echo "   open https://github.com/tombomann/klarpakke/actions"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
