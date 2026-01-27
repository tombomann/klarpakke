#!/bin/bash
set -euo pipefail

if [[ ! -f .env.migration ]]; then
  echo "❌ .env.migration not found. Create it with:"
  echo "cat > .env.migration <<'EOF'"
  echo "MAKE_API_TOKEN=your_token"
  echo "MAKE_TEAM_ID=your_team_id"
  echo "EOF"
  exit 1
fi

source .env.migration

echo "🚀 Importing to Make.com..."
echo ""

for f in make/flows/*.json; do
  name=$(basename "$f" .json)
  echo -n "Importing $name... "
  
  # Read blueprint as string (no double-encoding, Make v2 expects plain JSON string)
  bp=$(jq -c '.' < "$f" | jq -Rs .)
  
  # Import with teamId (not organizationId)
  result=$(curl -s -X POST "https://eu1.make.com/api/v2/scenarios" \
    -H "Authorization: Token $MAKE_API_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"teamId\":$MAKE_TEAM_ID,\"blueprint\":$bp,\"scheduling\":\"{\\\"type\\\":\\\"indefinitely\\\"}\"}")  if echo "$result" | jq -e '.scenario.id' >/dev/null 2>&1; then
    id=$(echo "$result" | jq -r '.scenario.id')
    echo "✅ ID: $id"
  else
    error=$(echo "$result" | jq -r '.message // "Unknown error"')
    echo "❌ $error"
    # Debug: print full response
    echo "   Response: $(echo "$result" | jq -c .)" >&2
  fi
done

echo ""
echo "✅ Done! View: https://eu1.make.com/organization/$MAKE_TEAM_ID/scenarios"
