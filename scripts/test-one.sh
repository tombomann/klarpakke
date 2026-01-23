#!/bin/bash
set -euo pipefail
source .env.migration

echo "🧪 Testing double-encoded import..."
echo ""

# Read and double-encode
blueprint=$(jq -c '.' < make/flows/signal-approve.json)
encoded=$(printf '%s' "$blueprint" | jq -Rs .)

echo "📦 Blueprint size: $(echo "$blueprint" | wc -c) bytes"
echo "📦 Encoded size: $(echo "$encoded" | wc -c) bytes"
echo ""

# Build payload
payload=$(cat <<EOF
{
  "teamId": $MAKE_TEAM_ID,
  "blueprint": $encoded,
  "scheduling": "{\"type\":\"indefinitely\"}"
}
EOF
)

echo "📤 Sending to Make API..."
response=$(curl -s -w "\n%{http_code}" -X POST \
  "https://eu1.make.com/api/v2/scenarios" \
  -H "Authorization: Token $MAKE_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d "$payload")

http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

echo "📥 Response: HTTP $http_code"
echo "$body" | jq .

if [[ "$http_code" =~ ^20 ]]; then
  echo ""
  echo "✅ SUCCESS! Scenario imported!"
  scenario_id=$(echo "$body" | jq -r '.scenario.id')
  echo "🆔 Scenario ID: $scenario_id"
else
  echo ""
  echo "❌ FAILED"
  if [[ "$http_code" == "403" ]]; then
    echo "   → Token missing permissions"
    echo "   → Go to: https://eu1.make.com/organization/$MAKE_TEAM_ID/api-tokens"
    echo "   → Create NEW token with scenarios:write"
  fi
fi
