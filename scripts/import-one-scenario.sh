#!/bin/bash
set -euo pipefail
source .env.migration

echo "🧪 Testing API import for signal-approve..."

# Read and escape blueprint
blueprint=$(cat make/flows/signal-approve.json | jq -c '.')

# Try import with correct format
curl -v -X POST "https://eu1.make.com/api/v2/scenarios" \
  -H "Authorization: Token $MAKE_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"teamId\": $MAKE_TEAM_ID,
    \"name\": \"Klarpakke: Signal Approve\",
    \"blueprint\": $(echo "$blueprint" | jq -Rs .),
    \"scheduling\": \"{\\\"type\\\": \\\"indefinitely\\\"}\"
  }" | jq .

echo ""
echo "Check result above ⬆️"
