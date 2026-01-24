#!/bin/bash
set -euo pipefail

source .env.migration

echo "🚀 Klarpakke: Simplified Make.com Setup"
echo "========================================"
echo ""

# Get existing scenarios to understand structure
echo "📋 Fetching existing scenarios..."
EXISTING=$(curl -s "https://eu1.make.com/api/v2/scenarios?organizationId=${MAKE_ORG_ID}" \
  -H "Authorization: Token ${MAKE_API_TOKEN}")

echo "$EXISTING" | jq '.scenarios[] | {id, name, teamId}'

# Extract teamId from first scenario
TEAM_ID=$(echo "$EXISTING" | jq -r '.scenarios[0].teamId // empty')

if [[ -z "$TEAM_ID" ]]; then
  echo "❌ Could not find teamId. Create a scenario manually first."
  exit 1
fi

echo ""
echo "✅ Found Team ID: $TEAM_ID"
echo ""

# Create minimal scenario
echo "📦 Creating: Tool Get Signal (minimal)..."

CREATE_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
  "https://eu1.make.com/api/v2/scenarios" \
  -H "Authorization: Token ${MAKE_API_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "teamId": '${TEAM_ID}',
    "name": "Klarpakke: Get Signal",
    "flow": []
  }')

HTTP_CODE=$(echo "$CREATE_RESPONSE" | tail -n1)
BODY=$(echo "$CREATE_RESPONSE" | sed '$d')

echo "HTTP Code: $HTTP_CODE"

if [[ "$HTTP_CODE" == "200" ]] || [[ "$HTTP_CODE" == "201" ]]; then
  SCENARIO_ID=$(echo "$BODY" | jq -r '.scenario.id // .id // empty')
  echo "✅ Scenario created: ID $SCENARIO_ID"
  echo ""
  echo "🔗 Configure manually:"
  echo "   https://eu1.make.com/${MAKE_ORG_ID}/scenarios/${SCENARIO_ID}/edit"
else
  echo "❌ Failed to create"
  echo "$BODY" | jq . 2>/dev/null || echo "$BODY"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ NEXT: Manual configuration required"
echo ""
echo "1. Open scenario editor"
echo "2. Add Webhooks → Custom Webhook (trigger)"
echo "3. Add HTTP → Make a request:"
echo "   URL: https://swfyuwkptusceiouqlks.supabase.co/rest/v1/aisignal"
echo "   Method: GET"
echo "   Query: status=eq.pending&order=created_at.desc&limit=1"
echo "   Headers:"
echo "     apikey: ${SUPABASE_SERVICE_ROLE_KEY}"
echo "     Authorization: Bearer ${SUPABASE_SERVICE_ROLE_KEY}"
echo "4. Add Webhooks → Webhook Response"
echo "   Body: {{2.data}}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
