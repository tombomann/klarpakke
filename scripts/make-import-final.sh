#!/bin/bash
set -euo pipefail

source .env.migration || { echo "❌ Missing .env.migration"; exit 1; }

echo "🚀 Make.com Import (Double-Encoded JSON)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Validate token first
echo "🔐 Testing API token..."
test_response=$(curl -s -o /dev/null -w "%{http_code}" \
  -H "Authorization: Token $MAKE_API_TOKEN" \
  "https://eu1.make.com/api/v2/scenarios?teamId=$MAKE_TEAM_ID")

if [[ "$test_response" != "200" ]]; then
  echo "❌ API Token failed (HTTP $test_response)"
  echo "   Go to: https://eu1.make.com/organization/$MAKE_TEAM_ID/api-tokens"
  echo "   Create NEW token with scenarios:write scope"
  exit 1
fi

echo "✅ Token valid"
echo ""

# Import each scenario
for blueprint_file in make/flows/*.json; do
  name=$(basename "$blueprint_file" .json)
  echo "📥 Importing: $name"
  
  # Step 1: Minify JSON (remove whitespace)
  minified=$(jq -c '.' < "$blueprint_file")
  
  # Step 2: Double-encode as JSON string
  encoded=$(printf '%s' "$minified" | jq -Rs .)
  
  # Step 3: Build request payload
  payload=$(cat <<EOF
{
  "teamId": $MAKE_TEAM_ID,
  "blueprint": $encoded,
  "scheduling": "{\"type\":\"indefinitely\"}"
}
EOF
)
  
  # Step 4: POST to Make API
  response=$(curl -s -X POST \
    "https://eu1.make.com/api/v2/scenarios" \
    -H "Authorization: Token $MAKE_API_TOKEN" \
    -H "Content-Type: application/json" \
    -d "$payload")
  
  # Step 5: Parse response
  if echo "$response" | jq -e '.scenario.id' >/dev/null 2>&1; then
    scenario_id=$(echo "$response" | jq -r '.scenario.id')
    echo "   ✅ Created! ID: $scenario_id"
    
    # Save webhook if available
    webhook=$(echo "$response" | jq -r '.scenario.webhook // empty')
    if [[ -n "$webhook" ]]; then
      echo "   🔗 Webhook: $webhook"
      echo "$name: $webhook" >> webhooks.log
    fi
  else
    error=$(echo "$response" | jq -r '.message // .error // "Unknown error"')
    echo "   ❌ Failed: $error"
    echo "$response" | jq . 2>/dev/null
  fi
  
  echo ""
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Import complete!"
echo "🔗 View: https://eu1.make.com/organization/$MAKE_TEAM_ID/scenarios"
[[ -f webhooks.log ]] && echo "📝 Webhooks: webhooks.log"
