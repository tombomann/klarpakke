#!/bin/bash
set -e
API_KEY="${PPLX_API_KEY}"
if [ -z "$API_KEY" ]; then
  echo "❌ ERROR: PPLX_API_KEY not set"
  exit 1
fi
echo "🚀 Starting Perplexity healthcheck..."
RESPONSE=$(curl -s -X POST "https://api.perplexity.ai/chat/completions" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "sonar-pro",
    "messages": [{
      "role": "system",
      "content": "Du er en ekspertanalytiker for kryptomarkeder"
    },{
      "role": "user",
      "content": "Analyser BTC/USD markedet kort"
    }],
    "max_tokens": 256
  }')
echo "$RESPONSE" > ai-sample.json
CONTENT=$(echo "$RESPONSE" | jq -r '.choices[0].message.content' 2>/dev/null)
if [ -z "$CONTENT" ]; then
  echo "❌ ERROR: Invalid response"
  exit 1
fi
echo "✅ Healthcheck PASSED"
echo "📝 Response: $CONTENT"
