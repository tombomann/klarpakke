#!/usr/bin/env bash
set -euo pipefail
export BUBBLE_KEY="fc7c7e5cad372044d6809137dabdfab4FULLKEYHERE"

URL="https://tom-58107.bubbleapps.io/version-test/api/1.1/obj/portfolio"

resp=$(curl -s -w '\nHTTP: %{http_code}' -H "X-User-Agent: $BUBBLE_KEY" "$URL")

http_code=$(echo "$resp" | tail -1)
json=$(echo "$resp" | sed '$d')

echo "HTTP: $http_code"
if [[ $http_code == "200" ]]; then
  echo "$json" | jq .
elif [[ $json == *'Data API'* ]]; then
  echo "❌ Data API DISABLED - Admin → Settings → API → Enable"
else
  echo "$json"
fi