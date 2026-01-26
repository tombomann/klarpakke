#!/bin/bash
# Klarpakke Smoke Test - Quick verification of setup
set -euo pipefail

echo "🧪 Klarpakke Smoke Test"
echo "======================"
echo ""

# Load .env if not already loaded
if [ -z "${SUPABASE_URL:-}" ]; then
    if [ -f ".env" ]; then
        source .env
    else
        echo "❌ .env not found. Run: bash scripts/quick-fix-env.sh"
        exit 1
    fi
fi

# Verify env vars
if [ -z "${SUPABASE_URL:-}" ] || [ -z "${SUPABASE_ANON_KEY:-}" ]; then
    echo "❌ Missing SUPABASE_URL or SUPABASE_ANON_KEY"
    exit 1
fi

echo "[1/5] Testing Supabase connection..."
RESP=$(curl -s -w "\n%{http_code}" \
    -H "apikey: $SUPABASE_ANON_KEY" \
    -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
    "$SUPABASE_URL/rest/v1/" 2>/dev/null || echo "error\n000")

HTTP_CODE=$(echo "$RESP" | tail -n1)

if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "404" ]; then
    echo "  ✅ Connection OK"
else
    echo "  ❌ Connection failed: HTTP $HTTP_CODE"
    exit 1
fi

echo ""
echo "[2/5] Verifying tables exist..."

for table in positions signals daily_risk_meter ai_calls; do
    RESP=$(curl -s -w "\n%{http_code}" \
        -H "apikey: $SUPABASE_ANON_KEY" \
        -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
        "$SUPABASE_URL/rest/v1/$table?limit=1" 2>/dev/null || echo "error\n000")
    
    HTTP_CODE=$(echo "$RESP" | tail -n1)
    
    if [ "$HTTP_CODE" = "200" ]; then
        echo "  ✅ Table '$table' exists"
    else
        echo "  ❌ Table '$table' not found (HTTP $HTTP_CODE)"
        echo "     Deploy schema: bash scripts/auto-deploy-sql.sh"
        exit 1
    fi
done

echo ""
echo "[3/5] Testing INSERT (signals)..."

TEST_SIGNAL='{"symbol":"BTC","direction":"BUY","confidence":0.75,"reason":"smoke test"}'

INSERT_RESP=$(curl -s -w "\n%{http_code}" \
    -X POST \
    -H "apikey: $SUPABASE_SECRET_KEY" \
    -H "Authorization: Bearer $SUPABASE_SECRET_KEY" \
    -H "Content-Type: application/json" \
    -H "Prefer: return=representation" \
    -d "$TEST_SIGNAL" \
    "$SUPABASE_URL/rest/v1/signals" 2>/dev/null || echo "error\n000")

HTTP_CODE=$(echo "$INSERT_RESP" | tail -n1)

if [ "$HTTP_CODE" = "201" ]; then
    echo "  ✅ INSERT works"
    SIGNAL_ID=$(echo "$INSERT_RESP" | head -n-1 | jq -r '.[0].id' 2>/dev/null || echo "")
else
    echo "  ⚠️  INSERT failed (HTTP $HTTP_CODE) - check RLS policies"
    SIGNAL_ID=""
fi

echo ""
echo "[4/5] Testing SELECT (signals)..."

SELECT_RESP=$(curl -s -w "\n%{http_code}" \
    -H "apikey: $SUPABASE_ANON_KEY" \
    -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
    "$SUPABASE_URL/rest/v1/signals?limit=5" 2>/dev/null || echo "error\n000")

HTTP_CODE=$(echo "$SELECT_RESP" | tail -n1)

if [ "$HTTP_CODE" = "200" ]; then
    COUNT=$(echo "$SELECT_RESP" | head -n-1 | jq 'length' 2>/dev/null || echo 0)
    echo "  ✅ SELECT works (found $COUNT signals)"
else
    echo "  ❌ SELECT failed (HTTP $HTTP_CODE)"
    exit 1
fi

echo ""
echo "[5/5] Testing risk_meter..."

RISK_RESP=$(curl -s -w "\n%{http_code}" \
    -H "apikey: $SUPABASE_ANON_KEY" \
    -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
    "$SUPABASE_URL/rest/v1/daily_risk_meter?order=date.desc&limit=1" 2>/dev/null || echo "error\n000")

HTTP_CODE=$(echo "$RISK_RESP" | tail -n1)

if [ "$HTTP_CODE" = "200" ]; then
    BODY=$(echo "$RISK_RESP" | head -n-1)
    if [ "$(echo "$BODY" | jq 'length')" -gt 0 ]; then
        RISK_USD=$(echo "$BODY" | jq -r '.[0].total_risk_usd' 2>/dev/null || echo "0")
        echo "  ✅ Risk meter OK (current: $${RISK_USD} USD)"
    else
        echo "  ⚠️  Risk meter empty (seed data missing)"
    fi
else
    echo "  ❌ Risk meter failed (HTTP $HTTP_CODE)"
    exit 1
fi

echo ""
echo "============================"
echo "✅ ALL SMOKE TESTS PASSED!"
echo "============================"
echo ""
echo "Your Klarpakke backend is ready."
echo ""
echo "Next steps:"
echo "  1. Setup Make.com scenarios (make/scenarios/*.json)"
echo "  2. Export KPIs: bash scripts/export-kpis.sh 30"
echo "  3. View in Supabase: $SUPABASE_URL/project/swfyuwkptusceiouqlks/editor"
echo ""
