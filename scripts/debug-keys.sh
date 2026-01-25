#!/bin/bash
set -euo pipefail

echo "🔍 DEBUG: Testing Supabase API keys"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Load from .env.migration
if [ -f ".env.migration" ]; then
    source .env.migration
else
    echo "❌ .env.migration not found"
    exit 1
fi

echo "📋 Environment Variables:"
echo "SUPABASE_PROJECT_ID: ${SUPABASE_PROJECT_ID:-NOT SET}"
echo "SUPABASE_SERVICE_ROLE_KEY: ${SUPABASE_SERVICE_ROLE_KEY:0:20}..." # Only show first 20 chars
echo ""

# Test 1: Root endpoint
echo "🧪 Test 1: Root endpoint (/rest/v1/)"
HTTP_CODE=$(curl -s -o /tmp/response.json -w "%{http_code}" \
    "https://${SUPABASE_PROJECT_ID}.supabase.co/rest/v1/" \
    -H "apikey: ${SUPABASE_SERVICE_ROLE_KEY}" \
    -H "Authorization: Bearer ${SUPABASE_SERVICE_ROLE_KEY}")

echo "HTTP Status: $HTTP_CODE"
if [ "$HTTP_CODE" == "200" ] || [ "$HTTP_CODE" == "404" ]; then
    echo "✅ Root endpoint accessible"
else
    echo "❌ Root endpoint failed"
    cat /tmp/response.json
fi
echo ""

# Test 2: aisignal table
echo "🧪 Test 2: aisignal table"
HTTP_CODE=$(curl -s -o /tmp/response.json -w "%{http_code}" \
    "https://${SUPABASE_PROJECT_ID}.supabase.co/rest/v1/aisignal?limit=1" \
    -H "apikey: ${SUPABASE_SERVICE_ROLE_KEY}" \
    -H "Authorization: Bearer ${SUPABASE_SERVICE_ROLE_KEY}" \
    -H "Content-Type: application/json")

echo "HTTP Status: $HTTP_CODE"
if [ "$HTTP_CODE" == "200" ]; then
    echo "✅ aisignal table accessible"
    echo "Response:"
    cat /tmp/response.json | jq .
else
    echo "❌ aisignal table failed"
    echo "Response:"
    cat /tmp/response.json
fi
echo ""

# Test 3: Decode JWT to check expiry
echo "🧪 Test 3: JWT Token Info"
JWT_PAYLOAD=$(echo "${SUPABASE_SERVICE_ROLE_KEY}" | cut -d'.' -f2)
# Add padding if needed
case $((${#JWT_PAYLOAD} % 4)) in
    2) JWT_PAYLOAD="${JWT_PAYLOAD}==" ;;
    3) JWT_PAYLOAD="${JWT_PAYLOAD}=" ;;
esac

echo "$JWT_PAYLOAD" | base64 -d 2>/dev/null | jq . || echo "⚠️  Could not decode JWT"
echo ""

# Test 4: Check if table exists
echo "🧪 Test 4: List all tables"
curl -s "https://${SUPABASE_PROJECT_ID}.supabase.co/rest/v1/" \
    -H "apikey: ${SUPABASE_SERVICE_ROLE_KEY}" \
    -H "Authorization: Bearer ${SUPABASE_SERVICE_ROLE_KEY}" | jq -r 'keys[]' 2>/dev/null || echo "Could not list tables"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Debug complete"
