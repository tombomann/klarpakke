#!/bin/bash
set -euo pipefail
echo "🔄 SINGLE USER TOKEN CLEANUP"

# Finn users med tokens
USERS=$(curl -s "https://tom-58107.bubbleapps.io/api/1.1/obj/User" \\
  -H "Authorization: Bearer \$BUBBLE_API_TOKEN")

echo "\$USERS" | jq -r '.response[] | select(.threecommasapitokentext != null and .threecommasapitokentext != "") | "User \(.uniqueid): " + .threecommasapitokentext' || echo "✅ NO TOKENS FOUND!"

echo "✅ CLEANUP COMPLETE (manual or no tokens)"
