#!/bin/bash
set -euo pipefail

MAKE_TOKEN="${MAKE:-$MAKE_TOKEN}"  # GitHub secret or env

if [[ -z "$MAKE_TOKEN" ]]; then
  echo "❌ MAKE_TOKEN missing. Set GitHub secret or env."
  exit 1
fi

resp=$(curl -s -w '\nHTTP: %{http_code}' -H "Authorization: Bearer $MAKE_TOKEN" \
  https://api.make.com/v2/teams | jq -e '.')

if [[ $? -ne 0 ]]; then
  echo "❌ Make API error"
  exit 1
fi

team_id=$(echo "$resp" | jq -r '.teams[0].id')
http_code=$(echo "$resp" | tail -1 | sed 's/HTTP: //')

echo "✅ Team ID: $team_id (HTTP $http_code)"
echo "MAKE_TEAM_ID=$team_id" >> .env
export MAKE_TEAM_ID

cat .env | grep MAKE