#!/bin/bash
set -euo pipefail
source .env.migration

echo "🚀 Importing to Make.com..."
echo ""

for f in make/flows/*.json; do
  name=$(basename "$f" .json)
  echo -n "Importing $name... "
  
  # Double-encode
  bp=$(jq -c '.' < "$f" | jq -Rs .)
  
  # Import with organizationId
  result=$(curl -s -X POST "https://eu1.make.com/api/v2/scenarios" \
    -H "Authorization: Token $MAKE_API_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"organizationId\":$MAKE_ORG_ID,\"blueprint\":$bp,\"scheduling\":\"{\\\"type\\\":\\\"indefinitely\\\"}\"}")
  
  if echo "$result" | jq -e '.scenario.id' >/dev/null 2>&1; then
    id=$(echo "$result" | jq -r '.scenario.id')
    echo "✅ ID: $id"
  else
    error=$(echo "$result" | jq -r '.message')
    echo "❌ $error"
  fi
done

echo ""
echo "✅ Done! View: https://eu1.make.com/organization/733572/scenarios"
