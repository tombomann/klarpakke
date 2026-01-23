#!/bin/bash
set -euo pipefail
source .env.migration

echo "🚀 Quick Import..."

for f in make/flows/*.json; do
  name=$(basename "$f" .json)
  echo -n "Importing $name... "
  
  # Double-encode blueprint
  bp=$(jq -Rs . < "$f")
  
  curl -s -X POST "https://eu1.make.com/api/v2/scenarios" \
    -H "Authorization: Token $MAKE_API_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"teamId\":$MAKE_TEAM_ID,\"blueprint\":$bp,\"scheduling\":\"{\\\"type\\\":\\\"indefinitely\\\"}\"}" \
    | jq -r 'if .scenario.id then "✅ ID: \(.scenario.id)" else "❌ \(.message)" end'
done

echo "Done! Check: https://eu1.make.com/organization/$MAKE_TEAM_ID/scenarios"
