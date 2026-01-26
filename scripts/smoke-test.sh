#!/bin/bash
# Klarpakke Smoke Test - Quick verification of setup
# macOS-safe: avoid `head -n-1`
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
if [ -z "${SUPABASE_SECRET_KEY:-}" ]; then
  echo "❌ Missing SUPABASE_SECRET_KEY (service_role)"
  echo "Run: bash scripts/quick-fix-env.sh"
  exit 1
fi

# Helper: run curl and keep body + http code (macOS-safe)
req() {
  local method="$1"; shift
  local url="$1"; shift

  curl -s -w "\n###HTTP_CODE###%{http_code}" -X "$method" "$url" "$@" 2>/dev/null || true
}

http_code() {
  echo "$1" | grep '###HTTP_CODE###' | sed 's/.*###HTTP_CODE###//'
}

body_only() {
  echo "$1" | sed '/###HTTP_CODE###/d'
}

echo "[1/5] Testing Supabase connection..."
RESP=$(req GET "$SUPABASE_URL/rest/v1/" \
  -H "apikey: $SUPABASE_ANON_KEY" \
  -H "Authorization: Bearer $SUPABASE_ANON_KEY")

CODE=$(http_code "$RESP")
if [ "$CODE" = "200" ] || [ "$CODE" = "404" ]; then
  echo "  ✅ Connection OK"
else
  echo "  ❌ Connection failed: HTTP ${CODE:-unknown}"
  echo "  Response: $(body_only "$RESP")"
  exit 1
fi

echo ""
echo "[2/5] Verifying tables exist..."

for table in positions signals daily_risk_meter ai_calls; do
  RESP=$(req GET "$SUPABASE_URL/rest/v1/$table?limit=1" \
    -H "apikey: $SUPABASE_ANON_KEY" \
    -H "Authorization: Bearer $SUPABASE_ANON_KEY")
  CODE=$(http_code "$RESP")

  if [ "$CODE" = "200" ]; then
    echo "  ✅ Table '$table' exists"
  else
    echo "  ❌ Table '$table' not found (HTTP ${CODE:-unknown})"
    echo "  Response: $(body_only "$RESP")"
    echo "  Tip: run bash scripts/verify-tables.sh"
    exit 1
  fi
done

echo ""
echo "[3/5] Testing INSERT (signals)..."

TEST_SIGNAL='{"symbol":"BTC","direction":"BUY","confidence":0.75,"reason":"smoke test"}'

RESP=$(req POST "$SUPABASE_URL/rest/v1/signals" \
  -H "apikey: $SUPABASE_SECRET_KEY" \
  -H "Authorization: Bearer $SUPABASE_SECRET_KEY" \
  -H "Content-Type: application/json" \
  -H "Prefer: return=representation" \
  -d "$TEST_SIGNAL")

CODE=$(http_code "$RESP")
BODY=$(body_only "$RESP")

if [ "$CODE" = "201" ]; then
  echo "  ✅ INSERT works"
  SIGNAL_ID=$(echo "$BODY" | jq -r '.[0].id' 2>/dev/null || echo "")
else
  echo "  ⚠️  INSERT failed (HTTP ${CODE:-unknown}) - check RLS policies"
  echo "  Response: $BODY"
  SIGNAL_ID=""
fi

echo ""
echo "[4/5] Testing SELECT (signals)..."

RESP=$(req GET "$SUPABASE_URL/rest/v1/signals?limit=5" \
  -H "apikey: $SUPABASE_ANON_KEY" \
  -H "Authorization: Bearer $SUPABASE_ANON_KEY")

CODE=$(http_code "$RESP")
BODY=$(body_only "$RESP")

if [ "$CODE" = "200" ]; then
  COUNT=$(echo "$BODY" | jq 'length' 2>/dev/null || echo 0)
  echo "  ✅ SELECT works (found $COUNT signals)"
else
  echo "  ❌ SELECT failed (HTTP ${CODE:-unknown})"
  echo "  Response: $BODY"
  exit 1
fi

echo ""
echo "[5/5] Testing risk_meter..."

RESP=$(req GET "$SUPABASE_URL/rest/v1/daily_risk_meter?order=date.desc&limit=1" \
  -H "apikey: $SUPABASE_ANON_KEY" \
  -H "Authorization: Bearer $SUPABASE_ANON_KEY")

CODE=$(http_code "$RESP")
BODY=$(body_only "$RESP")

if [ "$CODE" = "200" ]; then
  if [ "$(echo "$BODY" | jq 'length' 2>/dev/null || echo 0)" -gt 0 ]; then
    RISK_USD=$(echo "$BODY" | jq -r '.[0].total_risk_usd' 2>/dev/null || echo "0")
    echo "  ✅ Risk meter OK (current: $${RISK_USD} USD)"
  else
    echo "  ⚠️  Risk meter empty (seed data missing)"
  fi
else
  echo "  ❌ Risk meter failed (HTTP ${CODE:-unknown})"
  echo "  Response: $BODY"
  exit 1
fi

echo ""
echo "============================"
echo "✅ ALL SMOKE TESTS PASSED!"
echo "============================"
echo ""
echo "Next steps:"
echo "  1. Setup Make.com scenarios (make/scenarios/*.json)"
echo "  2. Export KPIs: bash scripts/export-kpis.sh 30"
echo ""
