#!/bin/bash
# Debug script: Why can't we see the tables?
set -euo pipefail

echo "🔍 Klarpakke Table Diagnostics"
echo "=============================="
echo ""

# Load .env
if [ -f ".env" ]; then
    source .env
else
    echo "❌ .env not found"
    exit 1
fi

echo "[1] Testing with ANON key..."
echo "URL: $SUPABASE_URL"
echo ""

for table in positions signals daily_risk_meter ai_calls; do
    echo "Testing table: $table"
    
    RESPONSE=$(curl -s -w "\n%{http_code}" \
        -H "apikey: $SUPABASE_ANON_KEY" \
        -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
        "$SUPABASE_URL/rest/v1/$table?limit=1" 2>&1)
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    BODY=$(echo "$RESPONSE" | head -n-1)
    
    echo "  HTTP Code: $HTTP_CODE"
    echo "  Response: $BODY"
    echo ""
done

echo ""
echo "[2] Testing with SECRET key..."
echo ""

for table in positions signals daily_risk_meter ai_calls; do
    echo "Testing table: $table"
    
    RESPONSE=$(curl -s -w "\n%{http_code}" \
        -H "apikey: $SUPABASE_SECRET_KEY" \
        -H "Authorization: Bearer $SUPABASE_SECRET_KEY" \
        "$SUPABASE_URL/rest/v1/$table?limit=1" 2>&1)
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    BODY=$(echo "$RESPONSE" | head -n-1)
    
    echo "  HTTP Code: $HTTP_CODE"
    echo "  Response: $BODY"
    echo ""
done

echo ""
echo "[3] Testing REST API root..."
RESPONSE=$(curl -s -w "\n%{http_code}" \
    -H "apikey: $SUPABASE_ANON_KEY" \
    -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
    "$SUPABASE_URL/rest/v1/" 2>&1)

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | head -n-1)

echo "HTTP Code: $HTTP_CODE"
echo "Response: $BODY"
echo ""

echo "[4] Environment check..."
echo "SUPABASE_URL: $SUPABASE_URL"
echo "ANON_KEY (first 20 chars): ${SUPABASE_ANON_KEY:0:20}..."
echo "SECRET_KEY (first 20 chars): ${SUPABASE_SECRET_KEY:0:20}..."
echo ""

echo "[5] Suggested fixes:"
echo "  1. Verify tables exist in Supabase Table Editor:"
echo "     https://supabase.com/dashboard/project/swfyuwkptusceiouqlks/editor"
echo ""
echo "  2. Check RLS policies in Supabase:"
echo "     https://supabase.com/dashboard/project/swfyuwkptusceiouqlks/auth/policies"
echo ""
echo "  3. Re-run SQL deployment:"
echo "     cat DEPLOY-NOW.sql | pbcopy"
echo "     open 'https://supabase.com/dashboard/project/swfyuwkptusceiouqlks/editor'"
echo ""
