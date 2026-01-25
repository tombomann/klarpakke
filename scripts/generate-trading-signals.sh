#!/bin/bash
set -euo pipefail

echo "📊 Generating trading signal..."

# Default demo response if no API key
if [ -z "${PPLX_API_KEY:-}" ]; then
  cat > latest-signal.json << 'DEMO'
{
  "pair": "BTC/USD",
  "direction": "BUY", 
  "confidence": 78.5,
  "reasoning": "BTC/USD breaking resistance at $68k, strong volume, RSI oversold. Target $72k, SL $66k",
  "entry": 68250,
  "stop_loss": 66000,
  "take_profit": 72000
}
DEMO
  echo "✅ Demo signal created (no API key)"
  exit 0
fi

# Real Perplexity call
RESPONSE=$(curl -s -X POST "https://api.perplexity.ai/chat/completions" \
  -H "Authorization: Bearer \$PPLX_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "sonar-pro",
    "messages": [{
      "role": "system", 
      "content": "Return ONLY valid JSON trading signal: {\"pair\":\"BTC/USD\",\"direction\":\"BUY|SELL|HOLD\",\"confidence\":0-100,\"reasoning\":\"brief\",\"entry\":price,\"stop_loss\":price,\"take_profit\":price}"
    }, {
      "role": "user",
      "content": "Analyze BTC/USD now"
    }]
  }')

echo "$RESPONSE" | jq . > latest-signal.json 2>/dev/null || echo "⚠️ Invalid JSON response"
echo "✅ Signal generated: latest-signal.json"
