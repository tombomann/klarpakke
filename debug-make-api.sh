#!/bin/bash
set -euo pipefail

source .env.migration

echo "🔍 Debugging Make.com API"
echo "========================="
echo ""

echo "CREDENTIALS:"
echo "  Org ID: ${MAKE_ORG_ID}"
echo "  API Token: ${MAKE_API_TOKEN:0:20}..."
echo ""

# Test 1: List scenarios (verify API access)
echo "TEST 1: List existing scenarios..."
RESPONSE=$(curl -s -w "\n%{http_code}" \
  "https://eu1.make.com/api/v2/scenarios?organizationId=${MAKE_ORG_ID}" \
  -H "Authorization: Token ${MAKE_API_TOKEN}")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "HTTP Code: $HTTP_CODE"
if [[ "$HTTP_CODE" == "200" ]]; then
  echo "✅ API access OK"
  echo "$BODY" | jq '.scenarios | length' | xargs echo "Existing scenarios:"
else
  echo "❌ API access FAILED"
  echo "$BODY" | jq . 2>/dev/null || echo "$BODY"
fi

echo ""
echo "TEST 2: Get organization info..."
ORG_RESPONSE=$(curl -s -w "\n%{http_code}" \
  "https://eu1.make.com/api/v2/organizations/${MAKE_ORG_ID}" \
  -H "Authorization: Token ${MAKE_API_TOKEN}")

ORG_HTTP=$(echo "$ORG_RESPONSE" | tail -n1)
ORG_BODY=$(echo "$ORG_RESPONSE" | sed '$d')

echo "HTTP Code: $ORG_HTTP"
if [[ "$ORG_HTTP" == "200" ]]; then
  echo "✅ Organization found"
  echo "$ORG_BODY" | jq '{id, name}'
else
  echo "❌ Organization not found"
  echo "$ORG_BODY" | jq . 2>/dev/null || echo "$ORG_BODY"
fi

echo ""
echo "TEST 3: Get teams in organization..."
TEAMS_RESPONSE=$(curl -s -w "\n%{http_code}" \
  "https://eu1.make.com/api/v2/organizations/${MAKE_ORG_ID}/teams" \
  -H "Authorization: Token ${MAKE_API_TOKEN}")

TEAMS_HTTP=$(echo "$TEAMS_RESPONSE" | tail -n1)
TEAMS_BODY=$(echo "$TEAMS_RESPONSE" | sed '$d')

echo "HTTP Code: $TEAMS_HTTP"
if [[ "$TEAMS_HTTP" == "200" ]]; then
  echo "✅ Teams found"
  echo "$TEAMS_BODY" | jq '.teams[] | {id, name}'
  
  # Extract first team ID
  TEAM_ID=$(echo "$TEAMS_BODY" | jq -r '.teams[0].id // empty')
  if [[ -n "$TEAM_ID" ]]; then
    echo ""
    echo "📋 RECOMMENDED: Use Team ID: $TEAM_ID"
    echo ""
    echo "Update .env.migration:"
    echo "  MAKE_TEAM_ID=$TEAM_ID"
  fi
else
  echo "❌ Teams not found"
  echo "$TEAMS_BODY" | jq . 2>/dev/null || echo "$TEAMS_BODY"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "DEBUG COMPLETE"
