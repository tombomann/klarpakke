#!/bin/bash
set -euo pipefail

MAKE_TOKEN="${MAKE_TOKEN:?Missing}"

raw=$(curl -s -w '\nHTTP:%{http_code}' -H "Authorization: Bearer $MAKE_TOKEN" https://api.make.com/v2/teams)

http_code=$(echo "$raw" | tail -1 | cut -d' ' -f2)
body=$(echo "$raw" | sed '$d')

echo "HTTP: $http_code"
echo "Raw body (first 200 chars): ${body:0:200}"
echo "Valid JSON? "
echo "$body" | jq empty 2>&1 || echo "❌ Invalid JSON - token/endpoint issue"

if [[ $http_code == 200 ]]; then
  team_id=$(echo "$body" | jq -r '.teams[0].id // empty')
  echo "✅ Team ID: $team_id"
  echo "MAKE_TEAM_ID=$team_id" >> .env
fi
