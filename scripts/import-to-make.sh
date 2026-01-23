#!/bin/bash
set -euo pipefail

source .env.migration || { echo "❌ .env.migration missing"; exit 1; }

echo "🚀 Importing scenarios to Make..."

for blueprint in make/flows/*.json; do
  name=$(basename "$blueprint" .json)
  echo -n "Importing $name... "
  
  response=$(curl -s -X POST \
    "https://eu1.make.com/api/v2/scenarios/import" \
    -H "Authorization: Token $MAKE_API_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
      \"teamId\": $MAKE_TEAM_ID,
      \"blueprint\": $(cat "$blueprint" | jq -c '.')
    }")
  
  if echo "$response" | jq -e '.scenario.id' >/dev/null 2>&1; then
    scenario_id=$(echo "$response" | jq -r '.scenario.id')
    echo "✅ ID: $scenario_id"
  else
    echo "❌ Failed"
    echo "$response" | jq .
  fi
done

echo ""
echo "✅ Import complete!"
echo "🔗 View: https://eu1.make.com/organization/733572/scenarios"
