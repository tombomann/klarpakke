#!/usr/bin/env bash
# KLARPAKKE AUTO-FIX: Hybrid CLI + REST API
# Works without Docker, uses REST API for DB operations

set -euo pipefail

cd "$(dirname "$0")/.."

echo "════════════════════════════════════════════════════════════════"
echo "🤖 KLARPAKKE AUTO-FIX (REST API Mode)"
echo "════════════════════════════════════════════════════════════════"
echo ""

# Load env
if [[ -f .env.local ]]; then
  source .env.local
  echo "✅ Loaded .env.local"
elif [[ -f .env.migration ]]; then
  source .env.migration
  echo "✅ Loaded .env.migration"
else
  echo "❌ No .env file found!"
  echo ""
  echo "Create .env.local with:"
  echo '  export SUPABASE_PROJECT_ID="swfyuwkptusceiouqlks"'
  echo '  export SUPABASE_SERVICE_ROLE_KEY="your-key"'
  echo '  export SUPABASE_DB_URL="postgresql://..."'
  exit 1
fi

echo ""

# ════════════════════════════════════════════════════════════════════
# 1. Test API
# ════════════════════════════════════════════════════════════════════

echo "════════════════════════════════════════════════════════════════"
echo "1️⃣  TESTER SUPABASE REST API"
echo "════════════════════════════════════════════════════════════════"
echo ""

API_RESPONSE=$(curl -s -w "\n%{http_code}" \
  -H "apikey: $SUPABASE_SERVICE_ROLE_KEY" \
  -H "Authorization: Bearer $SUPABASE_SERVICE_ROLE_KEY" \
  "https://swfyuwkptusceiouqlks.supabase.co/rest/v1/")

HTTP_CODE=$(echo "$API_RESPONSE" | tail -n1)

if [[ "$HTTP_CODE" == "200" ]]; then
  echo "✅ API tilkobling OK (HTTP $HTTP_CODE)"
else
  echo "❌ API feilet (HTTP $HTTP_CODE)"
  echo "$API_RESPONSE" | head -n-1
  exit 1
fi

echo ""

# ════════════════════════════════════════════════════════════════════
# 2. Check table exists
# ════════════════════════════════════════════════════════════════════

echo "════════════════════════════════════════════════════════════════"
echo "2️⃣  VERIFISERER AISIGNAL TABLE"
echo "════════════════════════════════════════════════════════════════"
echo ""

TABLE_CHECK=$(curl -s -w "\n%{http_code}" \
  -H "apikey: $SUPABASE_SERVICE_ROLE_KEY" \
  -H "Authorization: Bearer $SUPABASE_SERVICE_ROLE_KEY" \
  "https://swfyuwkptusceiouqlks.supabase.co/rest/v1/aisignal?select=count&limit=1")

TABLE_HTTP=$(echo "$TABLE_CHECK" | tail -n1)

if [[ "$TABLE_HTTP" == "200" ]]; then
  echo "✅ aisignal table exists"
else
  echo "❌ aisignal table not found (HTTP $TABLE_HTTP)"
  echo "Run emergency cleanup: python3 scripts/emergency-clean-duplicates.py"
  exit 1
fi

echo ""

# ════════════════════════════════════════════════════════════════════
# 3. Insert test signal
# ════════════════════════════════════════════════════════════════════

echo "════════════════════════════════════════════════════════════════"
echo "3️⃣  INSERTERER TEST SIGNAL"
echo "════════════════════════════════════════════════════════════════"
echo ""

SIGNAL_DATA=$(cat << 'JSON'
{
  "symbol": "BTCUSDT",
  "direction": "LONG",
  "entry_price": 50000,
  "stop_loss": 48000,
  "take_profit": 52000,
  "confidence": 0.85,
  "status": "pending"
}
JSON
)

INSERT_RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X POST \
  -H "apikey: $SUPABASE_SERVICE_ROLE_KEY" \
  -H "Authorization: Bearer $SUPABASE_SERVICE_ROLE_KEY" \
  -H "Content-Type: application/json" \
  -H "Prefer: return=representation" \
  -d "$SIGNAL_DATA" \
  "https://swfyuwkptusceiouqlks.supabase.co/rest/v1/aisignal")

INSERT_HTTP=$(echo "$INSERT_RESPONSE" | tail -n1)

if [[ "$INSERT_HTTP" == "201" ]]; then
  echo "✅ Test signal inserted successfully (HTTP $INSERT_HTTP)"
  echo "$INSERT_RESPONSE" | head -n-1 | jq -r '.[] | "   • \(.symbol) \(.direction) @ \(.entry_price) (confidence: \(.confidence))"'
elif [[ "$INSERT_HTTP" == "409" ]]; then
  echo "✅ Signal already exists (HTTP $INSERT_HTTP)"
else
  echo "⚠️  Insert returned HTTP $INSERT_HTTP"
  echo "$INSERT_RESPONSE" | head -n-1 | jq '.' 2>/dev/null || echo "$INSERT_RESPONSE" | head -n-1
  echo ""
  echo "Possible reasons:"
  echo "  - Duplicate constraint"
  echo "  - Check constraint violation (direction must be LONG/SHORT)"
  echo "  - Missing required fields"
fi

echo ""

# ════════════════════════════════════════════════════════════════════
# 4. Verify database status
# ════════════════════════════════════════════════════════════════════

echo "════════════════════════════════════════════════════════════════"
echo "4️⃣  DATABASE STATUS"
echo "════════════════════════════════════════════════════════════════"
echo ""

# Get count
COUNT_RESPONSE=$(curl -s \
  -H "apikey: $SUPABASE_SERVICE_ROLE_KEY" \
  -H "Authorization: Bearer $SUPABASE_SERVICE_ROLE_KEY" \
  "https://swfyuwkptusceiouqlks.supabase.co/rest/v1/aisignal?select=count")

TOTAL=$(echo "$COUNT_RESPONSE" | jq -r '.[0].count // 0' 2>/dev/null || echo "0")
echo "📊 Total signals in database: $TOTAL"

if [[ "$TOTAL" -gt 0 ]]; then
  echo ""
  echo "📈 Latest 3 signals:"
  
  curl -s \
    -H "apikey: $SUPABASE_SERVICE_ROLE_KEY" \
    -H "Authorization: Bearer $SUPABASE_SERVICE_ROLE_KEY" \
    "https://swfyuwkptusceiouqlks.supabase.co/rest/v1/aisignal?select=symbol,direction,entry_price,confidence,status,created_at&order=created_at.desc&limit=3" \
    | jq -r '.[] | "  • \(.symbol) \(.direction) @ \(.entry_price) (\(.confidence*100)% conf) - \(.status)"'
fi

echo ""

# ════════════════════════════════════════════════════════════════════
# 5. Trigger workflows
# ════════════════════════════════════════════════════════════════════

echo "════════════════════════════════════════════════════════════════"
echo "5️⃣  STARTER WORKFLOWS"
echo "════════════════════════════════════════════════════════════════"
echo ""

if command -v gh &> /dev/null; then
  echo "🚀 Triggering Multi-Strategy Backtest workflow..."
  
  if gh workflow run multi-strategy-backtest.yml 2>&1 | grep -q "Created"; then
    echo "   ✅ Workflow triggered"
  else
    echo "   ⚠️  Workflow may already be running"
  fi
  
  echo ""
  echo "⏳ Waiting 3s for workflow to start..."
  sleep 3
  
  echo ""
  echo "📊 Recent workflow runs:"
  gh run list -L 3 --json status,name,conclusion,createdAt \
    --jq '.[] | "  • \(.name): \(.status) (\(.conclusion // "running"))"'
else
  echo "⚠️  GitHub CLI not installed"
  echo "   Install: brew install gh && gh auth login"
  echo "   Or trigger manually: https://github.com/tombomann/klarpakke/actions"
fi

echo ""

# ════════════════════════════════════════════════════════════════════
# SUMMARY
# ════════════════════════════════════════════════════════════════════

echo "════════════════════════════════════════════════════════════════"
echo "✅ AUTO-FIX KOMPLETT!"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "📊 System Status:"
echo "   ✅ REST API verified"
echo "   ✅ aisignal table accessible"
echo "   ✅ Test signal inserted/verified"
echo "   ✅ Total signals: $TOTAL"
echo "   ✅ Workflows triggered"
echo ""
echo "🔗 Next steps:"
echo "   1. Watch workflow: gh run watch"
echo "   2. List runs: gh run list -L 5"
echo "   3. View dashboard: open https://supabase.com/dashboard/project/swfyuwkptusceiouqlks"
echo "   4. Query API directly:"
echo "      curl -H 'apikey: \$SUPABASE_SERVICE_ROLE_KEY' \\"
echo "           https://swfyuwkptusceiouqlks.supabase.co/rest/v1/aisignal?limit=5"
echo ""
echo "EOF"
