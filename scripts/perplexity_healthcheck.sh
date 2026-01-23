#!/bin/bash
set -euo pipefail

API_KEY="${PPLX_API_KEY}"

if [ -z "$API_KEY" ]; then
  echo "❌ ERROR: PPLX_API_KEY not set"
  exit 1
fi

echo "🚀 Perplexity Healthcheck (sonar-pro)" 

RESPONSE=$(curl -s -X POST https://api.perplexity.ai/chat/completions \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model": "sonar-pro", "messages": [{"role": "user", "content": "BTCUSD signal?"}], "max_tokens": 64}')

echo "$RESPONSE" > ai-sample.json

CONTENT=$(echo "$RESPONSE" | jq -r '.choices[0].message.content // empty')

if [ -z "$CONTENT" ]; then
  echo "❌ Invalid response"
  exit 1
fi

echo "✅ Healthcheck PASSED: $CONTENT"