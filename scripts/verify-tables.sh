#!/bin/bash
# Verify that tables actually exist in database
set -euo pipefail

echo "🔍 Verifying Database Tables"
echo "============================"
echo ""

if [ ! -f ".env" ]; then
    echo "❌ .env not found"
    exit 1
fi

source .env

echo "Testing via REST API..."
echo ""

# Get OpenAPI spec
RESPONSE=$(curl -s \
    -H "apikey: $SUPABASE_ANON_KEY" \
    -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
    "$SUPABASE_URL/rest/v1/" | jq -r '.paths | keys[]' 2>/dev/null || echo "error")

echo "Available tables in API:"
echo "$RESPONSE" | grep -v "^/$" | sed 's|^/||' | sort
echo ""

echo "Checking for our tables:"
for table in positions signals daily_risk_meter ai_calls; do
    if echo "$RESPONSE" | grep -q "/$table"; then
        echo "  ✅ $table"
    else
        echo "  ❌ $table (NOT FOUND)"
    fi
done

echo ""
echo "If tables are missing, run:"
echo "  1. cat DEPLOY-NOW.sql | pbcopy"
echo "  2. open 'https://supabase.com/dashboard/project/swfyuwkptusceiouqlks/editor'"
echo "  3. Paste SQL (CMD+V)"
echo "  4. SELECT ALL (CMD+A) <- CRITICAL!"
echo "  5. Click RUN (CMD+ENTER)"
echo ""
