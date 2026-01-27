#!/usr/bin/env bash
set -euo pipefail

# Always load .env to ensure all vars are set
if [[ -f .env ]]; then
  set -a
  source .env
  set +a
else
  echo "❌ .env not found. Run 'make bootstrap' first."
  exit 1
fi

# Validate required vars
if [[ -z "${SUPABASE_URL:-}" || -z "${SUPABASE_SECRET_KEY:-}" ]]; then
  echo "❌ Missing SUPABASE_URL or SUPABASE_SECRET_KEY in .env"
  echo "Run: make bootstrap"
  exit 1
fi

echo "🌱 Seeding paper trading signals..."
echo "================================="
echo ""

BASE_URL="${SUPABASE_URL}/rest/v1"
HEADERS=(
  -H "apikey: ${SUPABASE_SECRET_KEY}"
  -H "Authorization: Bearer ${SUPABASE_SECRET_KEY}"
  -H "Content-Type: application/json"
  -H "Prefer: return=representation"
)

# 5 demo signals (mix BUY/SELL, high confidence)
SIGNALS='[
  {
    "symbol": "BTC",
    "direction": "BUY",
    "confidence": 0.85,
    "reason": "Strong bullish momentum above $95k, tight Bollinger Bands squeeze signals imminent breakout. Institutional inflows +$1.9B.",
    "ai_model": "perplexity-sonar-pro",
    "status": "pending"
  },
  {
    "symbol": "ETH",
    "direction": "BUY",
    "confidence": 0.78,
    "reason": "ETH/BTC ratio recovering, staking yields attractive at 3.2%, upgrade narrative building for Q2 2026.",
    "ai_model": "perplexity-sonar-pro",
    "status": "pending"
  },
  {
    "symbol": "SOL",
    "direction": "SELL",
    "confidence": 0.72,
    "reason": "Overbought RSI >75, network congestion rising, DeFi TVL declining 12% WoW. Take profit at resistance.",
    "ai_model": "perplexity-sonar-pro",
    "status": "pending"
  },
  {
    "symbol": "AAPL",
    "direction": "BUY",
    "confidence": 0.81,
    "reason": "AI services revenue +28% YoY, Vision Pro 2.0 launch Q2, strong guidance above estimates.",
    "ai_model": "perplexity-sonar-pro",
    "status": "pending"
  },
  {
    "symbol": "TSLA",
    "direction": "SELL",
    "confidence": 0.69,
    "reason": "Valuation stretched at 85x P/E, production misses Q1 targets, competitive pressure from BYD.",
    "ai_model": "perplexity-sonar-pro",
    "status": "pending"
  }
]'

RESP=$(curl -s -w "###HTTP_CODE###%{http_code}" \
  -X POST "${BASE_URL}/signals" \
  "${HEADERS[@]}" \
  -d "${SIGNALS}")

BODY=$(echo "$RESP" | sed 's/###HTTP_CODE###.*//')
CODE=$(echo "$RESP" | sed -n 's/.*###HTTP_CODE###//p')

if [[ "$CODE" == "201" ]]; then
  COUNT=$(echo "$BODY" | jq '. | length')
  echo "✅ Inserted ${COUNT} signals"
  echo ""
  echo "View in Supabase:"
  echo "  ${SUPABASE_URL/https:\/\//https://supabase.com/dashboard/project/}/editor"
  echo ""
  echo "Query:"
  echo "  SELECT * FROM signals WHERE status='pending' ORDER BY created_at DESC LIMIT 5;"
else
  echo "❌ Failed (HTTP $CODE)"
  echo "$BODY" | jq -e . || echo "$BODY"
  exit 1
fi
