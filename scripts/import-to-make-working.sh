#!/bin/bash
set -euo pipefail

source .env.migration || { echo "❌ .env.migration missing"; exit 1; }

echo "🚀 Make.com Scenario Import (Community Solution)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

for blueprint_file in make/flows/*.json; do
  name=$(basename "$blueprint_file" .json)
  echo "📥 Importing: $name"
  
  # Step 1: Read blueprint
  blueprint=$(cat "$blueprint_file")
  
  # Step 2: Convert to JSON string (first encoding)
  blueprint_json=$(echo "$blueprint" | jq -c '.' | jq -Rs .)
  
  # Step 3: Create scheduling JSON string
  scheduling_json='"{\"type\":\"indefinitely\"}"'
  
  # Step 4: POST to Make API
  response=$(curl -s -w "\n%{http_code}" \
    -X POST "https://eu1.make.com/api/v2/scenarios" \
    -H "Authorization: Token $MAKE_API_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
      \"teamId\": $MAKE_TEAM_ID,
      \"blueprint\": $blueprint_json,
      \"scheduling\": $scheduling_json
    }")
  
  http_code=$(echo "$response" | tail -n1)
  body=$(echo "$response" | head -n-1)
  
  if [[ "$http_code" =~ ^20 ]]; then
    scenario_id=$(echo "$body" | jq -r '.scenario.id // .id // empty')
    echo "   ✅ Created! ID: $scenario_id"
    
    # Save webhook URL if available
    webhook=$(echo "$body" | jq -r '.scenario.webhook // empty')
    if [[ -n "$webhook" ]]; then
      echo "   🔗 Webhook: $webhook" | tee -a webhooks.txt
    fi
  else
    echo "   ❌ Failed (HTTP $http_code)"
    echo "$body" | jq . 2>/dev/null || echo "$body"
  fi
  
  echo ""
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Import Complete!"
echo "🔗 View: https://eu1.make.com/organization/$MAKE_TEAM_ID/scenarios"
if [[ -f webhooks.txt ]]; then
  echo "📝 Webhooks saved to: webhooks.txt"
fi
