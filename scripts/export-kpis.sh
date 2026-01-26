#!/bin/bash
# Export KPIs from Supabase: winrate, avg PnL, max drawdown
# Usage: bash scripts/export-kpis.sh [days] [output]

set -euo pipefail

DAYS="${1:-30}"
OUTPUT="${2:-reports/kpis-$(date +%Y-%m-%d).json}"

# Check for required env vars
if [ -z "${SUPABASE_URL:-}" ]; then
    echo "❌ Missing SUPABASE_URL environment variable"
    echo ""
    echo "Set it with:"
    echo "  export SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co"
    echo ""
    echo "Or create .env file (see .env.example)"
    exit 1
fi

if [ -z "${SUPABASE_ANON_KEY:-}" ]; then
    echo "❌ Missing SUPABASE_ANON_KEY environment variable"
    echo ""
    echo "Find your anon key at:"
    echo "  https://supabase.com/dashboard/project/_/settings/api"
    echo ""
    echo "Set it with:"
    echo "  export SUPABASE_ANON_KEY=eyJ..."
    exit 1
fi

mkdir -p "$(dirname "$OUTPUT")"

echo "📊 Exporting KPIs from Supabase..."
echo "Period: Last $DAYS days"
echo "Output: $OUTPUT"
echo ""

# Calculate date range
START_DATE=$(date -u -d "$DAYS days ago" +%Y-%m-%d 2>/dev/null || date -u -v-"${DAYS}d" +%Y-%m-%d)
END_DATE=$(date -u +%Y-%m-%d)

echo "📅 Date range: $START_DATE to $END_DATE"

# Fetch positions
echo "🔄 Fetching positions..."
POSITIONS=$(curl -s \
  -H "apikey: $SUPABASE_ANON_KEY" \
  -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
  "$SUPABASE_URL/rest/v1/positions?created_at=gte.$START_DATE&created_at=lte.$END_DATE&select=*")

if [ -z "$POSITIONS" ] || [ "$POSITIONS" = "[]" ]; then
    echo "⚠️  No positions found in date range."
    cat > "$OUTPUT" << EOF
{
  "error": "No data available",
  "period": {
    "start_date": "$START_DATE",
    "end_date": "$END_DATE"
  }
}
EOF
    cat "$OUTPUT" | jq .
    exit 0
fi

# Calculate KPIs using jq
echo "🧮 Calculating KPIs..."

TOTAL_TRADES=$(echo "$POSITIONS" | jq 'length')
WINNING_TRADES=$(echo "$POSITIONS" | jq '[.[] | select(.pnl_usd > 0)] | length')
LOSING_TRADES=$(echo "$POSITIONS" | jq '[.[] | select(.pnl_usd < 0)] | length')

# Calculate winrate with bc or awk
if command -v bc &> /dev/null; then
    WINRATE=$(echo "scale=2; $WINNING_TRADES * 100 / $TOTAL_TRADES" | bc 2>/dev/null || echo "0")
else
    WINRATE=$(awk "BEGIN {printf \"%.2f\", $WINNING_TRADES * 100 / $TOTAL_TRADES}" 2>/dev/null || echo "0")
fi

AVG_PNL=$(echo "$POSITIONS" | jq '[.[] | .pnl_usd // 0] | add / length')
TOTAL_PNL=$(echo "$POSITIONS" | jq '[.[] | .pnl_usd // 0] | add')
MAX_WIN=$(echo "$POSITIONS" | jq '[.[] | .pnl_usd // 0] | max')
MAX_LOSS=$(echo "$POSITIONS" | jq '[.[] | .pnl_usd // 0] | min')

# Fetch risk meter
echo "🔄 Fetching risk meter..."
RISK=$(curl -s \
  -H "apikey: $SUPABASE_ANON_KEY" \
  -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
  "$SUPABASE_URL/rest/v1/daily_risk_meter?date=gte.$START_DATE&date=lte.$END_DATE&select=*")

MAX_DRAWDOWN=$(echo "$RISK" | jq '[.[] | .total_risk_usd // 0] | max')
AVG_RISK=$(echo "$RISK" | jq 'if length > 0 then ([.[] | .risk_percent // 0] | add / length) else 0 end')

# Fetch AI calls
echo "🔄 Fetching AI call stats..."
AI_CALLS=$(curl -s \
  -H "apikey: $SUPABASE_ANON_KEY" \
  -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
  "$SUPABASE_URL/rest/v1/ai_calls?created_at=gte.$START_DATE&created_at=lte.$END_DATE&select=*")

TOTAL_AI_CALLS=$(echo "$AI_CALLS" | jq 'length')
TOTAL_AI_COST=$(echo "$AI_CALLS" | jq '[.[] | .cost_usd // 0] | add')
AVG_LATENCY=$(echo "$AI_CALLS" | jq 'if length > 0 then ([.[] | .latency_ms // 0] | add / length) else 0 end')

# Generate JSON report
cat > "$OUTPUT" << EOF
{
  "period": {
    "start_date": "$START_DATE",
    "end_date": "$END_DATE",
    "days": $DAYS
  },
  "trading": {
    "total_trades": $TOTAL_TRADES,
    "winning_trades": $WINNING_TRADES,
    "losing_trades": $LOSING_TRADES,
    "winrate_percent": $WINRATE,
    "avg_pnl_usd": $AVG_PNL,
    "total_pnl_usd": $TOTAL_PNL,
    "max_win_usd": $MAX_WIN,
    "max_loss_usd": $MAX_LOSS
  },
  "risk": {
    "max_drawdown_usd": $MAX_DRAWDOWN,
    "avg_risk_percent": $AVG_RISK
  },
  "ai": {
    "total_calls": $TOTAL_AI_CALLS,
    "total_cost_usd": $TOTAL_AI_COST,
    "avg_latency_ms": $AVG_LATENCY
  },
  "generated_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

echo ""
echo "✅ KPIs exported to: $OUTPUT"
echo ""
echo "📊 Summary:"
cat "$OUTPUT" | jq .
