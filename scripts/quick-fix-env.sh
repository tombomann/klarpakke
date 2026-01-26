#!/bin/bash
# Quick fix: Update .env with correct anon key format
# Usage: bash scripts/quick-fix-env.sh

set -euo pipefail

echo "🔧 Quick .env Fix"
echo "================"
echo ""
echo "You need to paste the CORRECT anon key (JWT format)."
echo ""
echo "Open this page:"
echo "  https://supabase.com/dashboard/project/swfyuwkptusceiouqlks/settings/api"
echo ""
echo "Look for 'Project API keys' section."
echo "Click 'Copy' next to 'anon' (NOT 'service_role secret')."
echo ""
echo "The key should start with: eyJhbGci..."
echo ""

read -p "Paste the ANON key (JWT format): " ANON_KEY

# Validate format
if [[ ! $ANON_KEY =~ ^eyJ ]]; then
    echo "❌ Invalid format! Key must start with 'eyJ'"
    echo "You pasted: ${ANON_KEY:0:20}..."
    exit 1
fi

echo ""
echo "✅ Key format looks correct"
echo ""

# Update .env
if [ -f ".env" ]; then
    # Backup
    cp .env .env.backup
    
    # Update SUPABASE_ANON_KEY line
    if grep -q "^SUPABASE_ANON_KEY=" .env; then
        sed -i.bak "s|^SUPABASE_ANON_KEY=.*|SUPABASE_ANON_KEY=$ANON_KEY|" .env
        rm .env.bak
        echo "✅ Updated existing SUPABASE_ANON_KEY in .env"
    else
        echo "SUPABASE_ANON_KEY=$ANON_KEY" >> .env
        echo "✅ Added SUPABASE_ANON_KEY to .env"
    fi
else
    echo "❌ .env file not found"
    exit 1
fi

echo ""
echo "Testing connection..."

source .env

RESPONSE=$(curl -s -w "\n%{http_code}" \
    -H "apikey: $SUPABASE_ANON_KEY" \
    -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
    "$SUPABASE_URL/rest/v1/" 2>/dev/null || echo "error\n000")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)

if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "404" ]; then
    echo "✅ Connection successful!"
    echo ""
    echo "Now deploy migrations:"
    echo "  bash scripts/direct-sql-deploy.sh"
else
    echo "❌ Connection failed: HTTP $HTTP_CODE"
    echo "Please verify the key is correct"
fi
