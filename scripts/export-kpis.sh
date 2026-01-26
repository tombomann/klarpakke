#!/bin/bash
# Export KPIs from Supabase: winrate, avg PnL, max drawdown
# Usage: bash scripts/export-kpis.sh [days] [output]

set -euo pipefail

DAYS="${1:-30}"
OUTPUT="${2:-reports/kpis-$(date +%Y-%m-%d).json}"
SUPABASE_URL="${SUPABASE_URL}"
SUPABASE_KEY="${SUPABASE_ANON_KEY}"

if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_KEY" ]; then
    echo "❌ Missing env vars: SUPABASE_URL, SUPABASE_ANON_KEY"
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
  -H "apikey: $SUPABASE_KEY" \
  -H "Authorization: Bearer $SUPABASE_KEY" \
  "$SUPABASE_URL/rest/v1/positions?created_at=gte.$START_DATE&created_at=lte.$END_DATE&select=*")

if [ -z "$POSITIONS" ] || [ "$POSITIONS" = "[]" ]; then
    echo "⚠️  No positions found in date range."
    echo '{"error": "No data"}' > "$OUTPUT"
    exit 0
fi

# Calculate KPIs using jq
echo "🧮 Calculating KPIs..."

TOTAL_TRADES=$(echo "$POSITIONS" | jq 'length')
WINNING_TRADES=$(echo "$POSITIONS" | jq '[.[] | select(.pnl_usd > 0)] | length')
LOSING_TRADES=$(echo "$POSITIONS" | jq '[.[] | select(.pnl_usd < 0)] | length')
WINRATE=$(echo "scale=2; $WINNING_TRADES * 100 / $TOTAL_TRADES" | bc 2>/dev/null || echo "0")

AVG_PNL=$(echo "$POSITIONS" | jq '[.[] | .pnl_usd // 0] | add / length')
TOTAL_PNL=$(echo "$POSITIONS" | jq '[.[] | .pnl_usd // 0] | add')
MAX_WIN=$(echo "$POSITIONS" | jq '[.[] | .pnl_usd // 0] | max')
MAX_LOSS=$(echo "$POSITIONS" | jq '[.[] | .pnl_usd // 0] | min')

# Fetch risk meter
echo "🔄 Fetching risk meter..."
RISK=$(curl -s \
  -H "apikey: $SUPABASE_KEY" \
  -H "Authorization: Bearer $SUPABASE_KEY" \
  "$SUPABASE_URL/rest/v1/daily_risk_meter?date=gte.$START_DATE&date=lte.$END_DATE&select=*")

MAX_DRAWDOWN=$(echo "$RISK" | jq '[.[] | .total_risk_usd // 0] | max')
AVG_RISK=$(echo "$RISK" | jq '[.[] | .risk_percent // 0] | add / length')

# Fetch AI calls
echo "🔄 Fetching AI call stats..."
AI_CALLS=$(curl -s \
  -H "apikey: $SUPABASE_KEY" \
  -H "Authorization: Bearer $SUPABASE_KEY" \
  "$SUPABASE_URL/rest/v1/ai_calls?created_at=gte.$START_DATE&created_at=lte.$END_DATE&select=*")

TOTAL_AI_CALLS=$(echo "$AI_CALLS" | jq 'length')
TOTAL_AI_COST=$(echo "$AI_CALLS" | jq '[.[] | .cost_usd // 0] | add')
AVG_LATENCY=$(echo "$AI_CALLS" | jq '[.[] | .latency_ms // 0] | add / length')

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
echo "📈 Summary:"
cat "$OUTPUT" | jq .
echo ""
echo "📊 View full report:"
echo "   cat $OUTPUT | jq"
