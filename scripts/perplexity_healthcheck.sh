#!/usr/bin/env bash
set -euo pipefail
: "${PPLX_API_KEY:?PPLX_API_KEY is required}"

payload='{
  "model": "sonar-pro",
  "messages": [
    {"role":"user","content":"Healthcheck: return only JSON {\"ok\":true} with no extra text."}
  ],
  "max_tokens": 32,
  "temperature": 0.0
}'

resp="$(curl -sS -X POST https://api.perplexity.ai/chat/completions \
  -H "Authorization: Bearer ${PPLX_API_KEY}" \
  -H "Content-Type: application/json" \
  -d "$payload")"

content="$(echo "$resp" | jq -r '.choices[0].message.content // empty')"
[[ "$content" =~ \"ok\"\:\ *true ]] || { echo "Bad content: $content"; exit 2; }
echo "Perplexity OK"
