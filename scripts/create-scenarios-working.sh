#!/bin/bash
set -euo pipefail

source .env.migration

echo "🚀 Klarpakke: Create Make.com Scenarios (Working)"
echo "=================================================="
echo ""

# Use MAKE_TEAM_ID (447181) instead of MAKE_ORG_ID
TEAM_ID="${MAKE_TEAM_ID:-447181}"

echo "Using Team ID: $TEAM_ID"
echo ""

# Scenario 1: Get Signal
echo "📦 Creating: Tool Get Signal..."

BLUEPRINT_GET='{"name":"Klarpakke: Get Signal","flow":[{"id":1,"module":"gateway:CustomWebHook","version":1,"parameters":{"hook":"auto"},"mapper":{},"metadata":{"designer":{"x":0,"y":0}}},{"id":2,"module":"http:ActionSendData","version":3,"parameters":{},"mapper":{"url":"https://swfyuwkptusceiouqlks.supabase.co/rest/v1/aisignal","method":"get","headers":[{"name":"apikey","value":"'"${SUPABASE_SERVICE_ROLE_KEY}"'"},{"name":"Authorization","value":"Bearer '"${SUPABASE_SERVICE_ROLE_KEY}"'"}],"qs":[{"name":"status","value":"eq.pending"},{"name":"order","value":"created_at.desc"},{"name":"limit","value":"1"}]},"metadata":{"designer":{"x":300,"y":0}}},{"id":3,"module":"gateway:WebhookRespond","version":1,"parameters":{},"mapper":{"status":"200","body":"{{2.data}}","headers":[{"name":"Content-Type","value":"application/json"}]},"metadata":{"designer":{"x":600,"y":0}}}]}'

SCHEDULING='{"type":"indefinitely"}'

CREATE_1=$(curl -s -X POST \
  "https://eu1.make.com/api/v2/scenarios" \
  -H "Authorization: Token ${MAKE_API_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "teamId": '${TEAM_ID}',
    "name": "Klarpakke: Get Signal",
    "blueprint": "'"$(echo "$BLUEPRINT_GET" | sed 's/"/\\"/g')"'",
    "scheduling": "'"$(echo "$SCHEDULING" | sed 's/"/\\"/g')"'"
  }')

SCENARIO_1_ID=$(echo "$CREATE_1" | jq -r '.scenario.id // .id // empty')

if [[ -n "$SCENARIO_1_ID" ]]; then
  echo "✅ Get Signal created: ID $SCENARIO_1_ID"
  echo "   https://eu1.make.com/${TEAM_ID}/scenarios/${SCENARIO_1_ID}"
else
  echo "❌ Failed to create Get Signal"
  echo "$CREATE_1" | jq .
fi

echo ""
echo "📦 Creating: Tool Approve Signal..."

BLUEPRINT_APPROVE='{"name":"Klarpakke: Approve Signal","flow":[{"id":1,"module":"gateway:CustomWebHook","version":1},{"id":2,"module":"http:ActionSendData","version":3,"mapper":{"url":"https://swfyuwkptusceiouqlks.supabase.co/rest/v1/aisignal?id=eq.{{1.signal_id}}","method":"patch","headers":[{"name":"apikey","value":"'"${SUPABASE_SERVICE_ROLE_KEY}"'"},{"name":"Authorization","value":"Bearer '"${SUPABASE_SERVICE_ROLE_KEY}"'"},{"name":"Content-Type","value":"application/json"}],"body":"{\\"status\\":\\"approved\\",\\"approved_by\\":\\"ai_agent\\",\\"reasoning\\":\\"{{1.reasoning}}\\"}"}},{"id":3,"module":"gateway:WebhookRespond","version":1,"mapper":{"status":"200","body":"{\\"success\\":true}"}}]}'

CREATE_2=$(curl -s -X POST \
  "https://eu1.make.com/api/v2/scenarios" \
  -H "Authorization: Token ${MAKE_API_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "teamId": '${TEAM_ID}',
    "name": "Klarpakke: Approve Signal",
    "blueprint": "'"$(echo "$BLUEPRINT_APPROVE" | sed 's/"/\\"/g')"'",
    "scheduling": "'"$(echo "$SCHEDULING" | sed 's/"/\\"/g')"'"
  }')

SCENARIO_2_ID=$(echo "$CREATE_2" | jq -r '.scenario.id // .id // empty')

if [[ -n "$SCENARIO_2_ID" ]]; then
  echo "✅ Approve Signal created: ID $SCENARIO_2_ID"
  echo "   https://eu1.make.com/${TEAM_ID}/scenarios/${SCENARIO_2_ID}"
else
  echo "❌ Failed to create Approve Signal"
  echo "$CREATE_2" | jq .
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ SCENARIOS CREATED!"
echo ""
echo "📋 Save IDs to file..."

cat > make-scenarios.json << JSON
{
  "get_signal": "$SCENARIO_1_ID",
  "approve_signal": "$SCENARIO_2_ID",
  "team_id": $TEAM_ID,
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
JSON

echo "✅ Saved to: make-scenarios.json"
echo ""
echo "🔗 View scenarios: https://eu1.make.com/${TEAM_ID}/scenarios"
echo "🤖 Configure AI Agent: https://eu1.make.com/${TEAM_ID}/agents"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
