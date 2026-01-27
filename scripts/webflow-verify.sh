#!/usr/bin/env bash
set -euo pipefail

echo "🧪 Webflow Deployment Verification"
echo "===================================="
echo ""

SITE_URL="https://klarpakke-c65071.webflow.io/app/dashboard"

# Test 1: Site responds
echo "Test 1: Site accessibility..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$SITE_URL" || echo "000")

if [[ "$HTTP_CODE" == "401" ]]; then
  echo "✅ Password protection active"
elif [[ "$HTTP_CODE" == "200" ]]; then
  echo "⚠️  Site accessible without password"
else
  echo "❌ Site unreachable (HTTP $HTTP_CODE)"
fi
echo ""

# Test 2: Edge Function reachable from external
echo "Test 2: Edge Function connectivity..."
if [[ -f .env ]]; then
  set -a && source .env && set +a
fi

EDGE_URL="${SUPABASE_URL}/functions/v1/approve-signal"
EDGE_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
  -X OPTIONS "$EDGE_URL" || echo "000")

if [[ "$EDGE_CODE" == "200" || "$EDGE_CODE" == "204" ]]; then
  echo "✅ Edge Function reachable"
else
  echo "⚠️  Edge Function returned HTTP $EDGE_CODE"
fi
echo ""

# Test 3: CORS headers
echo "Test 3: CORS configuration..."
CORS_HEADERS=$(curl -s -I -X OPTIONS "$EDGE_URL" | grep -i "access-control" || echo "")

if [[ -n "$CORS_HEADERS" ]]; then
  echo "✅ CORS headers present"
  echo "$CORS_HEADERS" | sed 's/^/   /'
else
  echo "⚠️  No CORS headers detected"
fi
echo ""

echo "Summary:"
echo "  Site: $SITE_URL"
echo "  API:  $EDGE_URL"
echo ""
echo "Manual test:"
echo "  1. Open site + enter password: tom"
echo "  2. F12 Console → look for [Klarpakke] messages"
echo "  3. Click Approve → verify status update"
