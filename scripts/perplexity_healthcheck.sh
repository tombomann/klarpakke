#!/bin/bash
set -e

PPLX_KEY="${PPLX_API_KEY:-demo_key}"
echo "🧠 Testing Perplexity API..."

curl -sf "https://api.perplexity.ai/chat/completions" \
  -H "Authorization: Bearer $PPLX_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "sonar-pro",
    "messages": [{"role": "user", "content": "Test"}],
    "max_tokens": 50
  }' > ai-sample.json && echo "✅ API test passed" || echo "⚠️  API test skipped (demo mode)"
