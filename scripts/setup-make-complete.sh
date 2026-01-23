#!/bin/bash
set -euo pipefail

echo "🤖 Klarpakke: Complete Make.com Setup"
echo "======================================"
echo ""

source .env.migration

# Create Scenario 1: Get Signal
echo "📦 Creating: Tool Get Signal..."
GET_SIGNAL=$(curl -s -X POST \
  "https://eu1.make.com/api/v2/organizations/${MAKE_ORG_ID}/scenarios" \
  -H "Authorization: Token ${MAKE_API_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{
    \"teamId\": \"${MAKE_ORG_ID}\",
    \"name\": \"Tool: Get Signal\",
    \"scheduling\": \"{\\\"type\\\":\\\"indefinitely\\\"}\",
    \"blueprint\": \"{\\\"flow\\\":[{\\\"id\\\":1,\\\"module\\\":\\\"gateway:CustomWebHook\\\",\\\"version\\\":1},{\\\"id\\\":2,\\\"module\\\":\\\"http:ActionSendData\\\",\\\"version\\\":3,\\\"mapper\\\":{\\\"url\\\":\\\"https://swfyuwkptusceiouqlks.supabase.co/rest/v1/aisignal?status=eq.pending&order=created_at.desc&limit=1\\\",\\\"method\\\":\\\"get\\\",\\\"headers\\\":[{\\\"name\\\":\\\"apikey\\\",\\\"value\\\":\\\"${SUPABASE_SERVICE_ROLE_KEY}\\\"},{\\\"name\\\":\\\"Authorization\\\",\\\"value\\\":\\\"Bearer ${SUPABASE_SERVICE_ROLE_KEY}\\\"}]}},{\\\"id\\\":3,\\\"module\\\":\\\"gateway:WebhookRespond\\\",\\\"version\\\":1,\\\"mapper\\\":{\\\"status\\\":\\\"200\\\",\\\"body\\\":\\\"{{2.data}}\\\"}}]}\"
  }")

SCENARIO_1_ID=$(echo "$GET_SIGNAL" | jq -r '.scenario.id // empty')
if [[ -n "$SCENARIO_1_ID" ]]; then
  echo "✅ Get Signal: ID $SCENARIO_1_ID"
else
  echo "❌ Failed to create Get Signal"
  echo "$GET_SIGNAL" | jq .
fi

echo ""
echo "📦 Creating: Tool Approve Signal..."
APPROVE_SIGNAL=$(curl -s -X POST \
  "https://eu1.make.com/api/v2/organizations/${MAKE_ORG_ID}/scenarios" \
  -H "Authorization: Token ${MAKE_API_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{
    \"teamId\": \"${MAKE_ORG_ID}\",
    \"name\": \"Tool: Approve Signal\",
    \"scheduling\": \"{\\\"type\\\":\\\"indefinitely\\\"}\",
    \"blueprint\": \"{\\\"flow\\\":[{\\\"id\\\":1,\\\"module\\\":\\\"gateway:CustomWebHook\\\",\\\"version\\\":1},{\\\"id\\\":2,\\\"module\\\":\\\"http:ActionSendData\\\",\\\"version\\\":3,\\\"mapper\\\":{\\\"url\\\":\\\"https://swfyuwkptusceiouqlks.supabase.co/rest/v1/aisignal?id=eq.{{1.signal_id}}\\\",\\\"method\\\":\\\"patch\\\",\\\"headers\\\":[{\\\"name\\\":\\\"apikey\\\",\\\"value\\\":\\\"${SUPABASE_SERVICE_ROLE_KEY}\\\"},{\\\"name\\\":\\\"Content-Type\\\",\\\"value\\\":\\\"application/json\\\"}],\\\"body\\\":\\\"{\\\\\\\"status\\\\\\\":\\\\\\\"approved\\\\\\\",\\\\\\\"approved_by\\\\\\\":\\\\\\\"ai_agent\\\\\\\",\\\\\\\"reasoning\\\\\\\":\\\\\\\"{{1.reasoning}}\\\\\\\"}\\\"}},{\\\"id\\\":3,\\\"module\\\":\\\"gateway:WebhookRespond\\\",\\\"version\\\":1,\\\"mapper\\\":{\\\"status\\\":\\\"200\\\",\\\"body\\\":\\\"{\\\\\\\"success\\\\\\\":true}\\\"}}]}\"
  }")

SCENARIO_2_ID=$(echo "$APPROVE_SIGNAL" | jq -r '.scenario.id // empty')
if [[ -n "$SCENARIO_2_ID" ]]; then
  echo "✅ Approve Signal: ID $SCENARIO_2_ID"
else
  echo "❌ Failed"
  echo "$APPROVE_SIGNAL" | jq .
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ SCENARIOS CREATED!"
echo ""
echo "🔗 View scenarios:"
echo "   https://eu1.make.com/${MAKE_ORG_ID}/scenarios"
echo ""
echo "📋 NEXT: Configure AI Agent"
echo "   https://eu1.make.com/${MAKE_ORG_ID}/agents"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Save IDs
cat > make-scenarios.json << JSON
{
  "get_signal": "$SCENARIO_1_ID",
  "approve_signal": "$SCENARIO_2_ID",
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
JSON

echo ""
echo "✅ Scenario IDs saved to: make-scenarios.json"
