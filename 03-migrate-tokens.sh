#!/usr/bin/env bash
set -euo pipefail

echo "🔄 TOKEN MIGRATION"

: "\${BUBBLE_API_TOKEN:?}"

# NULLSTILL TOKENS I BUBBLE (sikkerhet)
curl -s -X PATCH "https://tom-58107.bubbleapps.io/api/1.1/bulk/User" \\
  -H "Authorization: Bearer \$BUBBLE_API_TOKEN" \\
  -d '{"updates":[{"constraints":[{"key":"threecommasapitokentext","constraint_type":"is not empty"}],"changes":[{"key":"threecommasapitokentext","value":""}]}]}'

echo "✅ TOKENS NULLSTILT – SIKKER!"
