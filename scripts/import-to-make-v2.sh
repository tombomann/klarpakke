#!/bin/bash
set -euo pipefail

source .env.migration || { echo "❌ .env.migration missing"; exit 1; }

echo "🚀 Importing scenarios to Make (v2)..."
echo "Team ID: $MAKE_TEAM_ID"
echo ""

# Test API connectivity first
echo "Testing API..."
response=$(curl -s -H "Authorization: Token $MAKE_API_TOKEN" \
  "https://eu1.make.com/api/v2/scenarios?teamId=$MAKE_TEAM_ID")

if echo "$response" | jq -e '.scenarios' >/dev/null 2>&1; then
  echo "✅ API connected"
else
  echo "❌ API test failed:"
  echo "$response" | jq .
  exit 1
fi

echo ""
echo "Note: Automatic import may not work with Make API."
echo "Please use manual import via Make dashboard."
echo ""
echo "📖 See: docs/migration/IMPORT-CHECKLIST.md"
