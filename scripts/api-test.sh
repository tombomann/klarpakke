#!/bin/bash
set -euo pipefail

# WORKING CURL HELPER (no fancy parse)
api_get() {
  local url="$1" token="$2"
  curl -s -H "Authorization: Bearer $token" "$url" | jq .
}

# TEST
echo "1. Httpbin test:"
curl -s https://httpbin.org/json | jq .slideshow

echo "2. Bubble users (set token first):"
# export BUBBLE_API_TOKEN="..."
# api_get "https://tom-58107.bubbleapps.io/api/1.1/obj/User" "$BUBBLE_API_TOKEN"

echo "✅ Use RAW curl -s | jq for now. No wrapper needed."
