#!/bin/bash
set -euo pipefail

echo "🧪 Testing Klarpakke API"
echo ""

# Check .env.migration exists
if [[ ! -f .env.migration ]]; then
  echo "❌ .env.migration not found"
  echo ""
  echo "Create it:"
  echo "nano .env.migration"
  echo ""
  echo "Add these lines:"
  echo "SUPABASE_PROJECT_ID=swfyuwkptusceiouqlks"
  echo "SUPABASE_ANON_KEY=your-anon-key"
  echo "SUPABASE_SERVICE_ROLE_KEY=your-service-role-key"
  echo "MAKE_ORG_ID=733572"
  echo "MAKE_API_TOKEN=b6e26ff2-06f5-4544-b52d-4baae9003dfb"
  exit 1
fi

source .env.migration

# Test 1: Read system_status (anon key)
echo "TEST 1: Read system_status (public access)..."
RESPONSE=$(curl -s -w "\n%{http_code}" \
  "https://${SUPABASE_PROJECT_ID}.supabase.co/rest/v1/system_status?select=*" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Authorization: Bearer ${SUPABASE_ANON_KEY}")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [[ "$HTTP_CODE" == "200" ]]; then
  echo "✅ PASS - API accessible"
  echo "$BODY" | jq .
else
  echo "❌ FAIL - HTTP $HTTP_CODE"
  echo "$BODY"
  exit 1
fi

echo ""
echo "TEST 2: Insert test signal (service_role)..."
RESPONSE2=$(curl -s -w "\n%{http_code}" -X POST \
  "https://${SUPABASE_PROJECT_ID}.supabase.co/rest/v1/aisignal" \
  -H "apikey: ${SUPABASE_SERVICE_ROLE_KEY}" \
  -H "Authorization: Bearer ${SUPABASE_SERVICE_ROLE_KEY}" \
  -H "Content-Type: application/json" \
  -H "Prefer: return=representation" \
  -d '{
    "symbol": "ETH/USD",
    "direction": "long",
    "entry_price": 3500,
    "stop_loss": 3400,
    "take_profit": 3700,
    "confidence": 0.75,
    "status": "pending"
  }')

HTTP_CODE2=$(echo "$RESPONSE2" | tail -n1)
BODY2=$(echo "$RESPONSE2" | sed '$d')

if [[ "$HTTP_CODE2" == "201" ]]; then
  echo "✅ PASS - Signal created"
  SIGNAL_ID=$(echo "$BODY2" | jq -r '.[0].id')
  echo "Signal ID: $SIGNAL_ID"
else
  echo "❌ FAIL - HTTP $HTTP_CODE2"
  echo "$BODY2"
  exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ ALL TESTS PASSED!"
echo "📊 Supabase API is working"
echo "🎯 Ready for Make.com setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
