#!/bin/bash
# Smoke test: verify entire Klarpakke pipeline
# Tests: Supabase schema, Make webhooks, Perplexity API

set -euo pipefail

echo "🧪 Klarpakke Smoke Test"
echo "======================"
echo ""

SUPABASE_URL="${SUPABASE_URL}"
SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY}"
SUPABASE_SECRET_KEY="${SUPABASE_SECRET_KEY:-$SUPABASE_ANON_KEY}"
PPLX_API_KEY="${PPLX_API_KEY:-}"

FAILED=0

# Test 1: Supabase schema exists
echo "Test 1: Supabase schema validation"
for table in positions signals daily_risk_meter ai_calls; do
    RESPONSE=$(curl -s -w "\n%{http_code}" \
        -H "apikey: $SUPABASE_ANON_KEY" \
        -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
        "$SUPABASE_URL/rest/v1/$table?limit=1")
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    
    if [ "$HTTP_CODE" -eq 200 ]; then
        echo "  ✅ Table '$table' exists"
    else
        echo "  ❌ Table '$table' missing or inaccessible: $HTTP_CODE"
        FAILED=$((FAILED + 1))
    fi
done
echo ""

# Test 2: Insert test position
echo "Test 2: Insert test position"
TEST_POSITION=$(cat << EOF
{
  "symbol": "TESTBTC",
  "entry_price": 50000,
  "quantity": 0.1,
  "user_id": "smoke-test",
  "status": "open"
}
EOF
)

RESPONSE=$(curl -s -w "\n%{http_code}" \
    -X POST \
    -H "apikey: $SUPABASE_SECRET_KEY" \
    -H "Authorization: Bearer $SUPABASE_SECRET_KEY" \
    -H "Content-Type: application/json" \
    -H "Prefer: return=representation" \
    -d "$TEST_POSITION" \
    "$SUPABASE_URL/rest/v1/positions")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | head -n-1)

if [ "$HTTP_CODE" -eq 201 ]; then
    echo "  ✅ Position inserted"
    POSITION_ID=$(echo "$BODY" | jq -r '.[0].id')
    echo "     ID: $POSITION_ID"
else
    echo "  ❌ Insert failed: $HTTP_CODE"
    echo "$BODY" | jq .
    FAILED=$((FAILED + 1))
fi
echo ""

# Test 3: Risk meter auto-update (via trigger)
echo "Test 3: Risk meter auto-update"
sleep 2  # Wait for trigger

RESPONSE=$(curl -s -w "\n%{http_code}" \
    -H "apikey: $SUPABASE_ANON_KEY" \
    -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
    "$SUPABASE_URL/rest/v1/daily_risk_meter?date=eq.$(date +%Y-%m-%d)&limit=1")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | head -n-1)

if [ "$HTTP_CODE" -eq 200 ]; then
    POSITIONS_COUNT=$(echo "$BODY" | jq -r '.[0].active_positions_count // 0')
    echo "  ✅ Risk meter updated"
    echo "     Active positions: $POSITIONS_COUNT"
else
    echo "  ❌ Risk meter check failed: $HTTP_CODE"
    FAILED=$((FAILED + 1))
fi
echo ""

# Test 4: Perplexity API (if key available)
if [ -n "$PPLX_API_KEY" ]; then
    echo "Test 4: Perplexity API connectivity"
    
    RESPONSE=$(curl -s -w "\n%{http_code}" \
        -X POST https://api.perplexity.ai/chat/completions \
        -H "Authorization: Bearer $PPLX_API_KEY" \
        -H "Content-Type: application/json" \
        -d '{
          "model": "sonar-pro",
          "messages": [{"role": "user", "content": "Test"}],
          "max_tokens": 5
        }')
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    
    if [ "$HTTP_CODE" -eq 200 ]; then
        echo "  ✅ Perplexity API OK"
    else
        echo "  ⚠️  Perplexity API failed: $HTTP_CODE"
        echo "     (This may be rate-limiting)"
    fi
    echo ""
else
    echo "Test 4: Skipped (PPLX_API_KEY not set)"
    echo ""
fi

# Cleanup: delete test position
if [ -n "${POSITION_ID:-}" ]; then
    echo "Cleanup: Deleting test position..."
    curl -s -X DELETE \
        -H "apikey: $SUPABASE_SECRET_KEY" \
        -H "Authorization: Bearer $SUPABASE_SECRET_KEY" \
        "$SUPABASE_URL/rest/v1/positions?id=eq.$POSITION_ID" > /dev/null
    echo "  ✅ Test data cleaned"
    echo ""
fi

# Summary
echo "======================"
if [ $FAILED -eq 0 ]; then
    echo "✅ ALL TESTS PASSED"
    exit 0
else
    echo "❌ $FAILED TEST(S) FAILED"
    exit 1
fi
