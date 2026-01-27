#!/usr/bin/env bash
set -euo pipefail

echo "🔄 Supabase → Webflow CMS Sync"
echo "=============================="
echo ""

# Load .env
if [[ -f .env ]]; then
  set -a && source .env && set +a
fi

# Validate required vars
: "${SUPABASE_URL:?Missing SUPABASE_URL in .env}"
: "${SUPABASE_ANON_KEY:?Missing SUPABASE_ANON_KEY in .env}"
: "${WEBFLOW_API_TOKEN:?Missing WEBFLOW_API_TOKEN in .env}"
: "${WEBFLOW_COLLECTION_ID:?Missing WEBFLOW_COLLECTION_ID in .env}"

# Fetch pending signals from Supabase
echo "Fetching pending signals..."
RESP=$(curl -s -f -w "###HTTP_CODE###%{http_code}" \
  "${SUPABASE_URL}/rest/v1/signals?status=eq.pending&select=*" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Authorization: Bearer ${SUPABASE_ANON_KEY}")

BODY=$(echo "$RESP" | sed 's/###HTTP_CODE###[0-9]*$//')
CODE=$(echo "$RESP" | grep -oE '[0-9]+$')

if [[ "$CODE" != "200" ]]; then
  echo "❌ Supabase API failed with HTTP $CODE"
  exit 1
fi

# Count signals
SIGNAL_COUNT=$(echo "$BODY" | jq -e 'length')
echo "✅ Found $SIGNAL_COUNT pending signals"

if [[ "$SIGNAL_COUNT" == "0" ]]; then
  echo "Nothing to sync - exiting"
  exit 0
fi

echo ""
echo "Syncing to Webflow CMS..."

# Push each signal to Webflow
SYNCED=0
FAILED=0

echo "$BODY" | jq -c '.[]' | while read -r signal; do
  SIGNAL_ID=$(echo "$signal" | jq -r '.id')
  SYMBOL=$(echo "$signal" | jq -r '.symbol')
  DIRECTION=$(echo "$signal" | jq -r '.direction')
  CONFIDENCE=$(echo "$signal" | jq -r '.confidence // 0')
  REASONING=$(echo "$signal" | jq -r '.reasoning // "No reasoning"')
  
  # Generate slug (Webflow requirement)
  SLUG="signal-${SIGNAL_ID:0:8}"
  
  # Create Webflow CMS item
  WEBFLOW_RESP=$(curl -s -o /dev/null -w "%{http_code}" \
    -X POST "https://api.webflow.com/v2/collections/${WEBFLOW_COLLECTION_ID}/items" \
    -H "Authorization: Bearer ${WEBFLOW_API_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "{
      \"fields\": {
        \"name\": \"$SYMBOL $DIRECTION\",
        \"slug\": \"$SLUG\",
        \"signal-id\": \"$SIGNAL_ID\",
        \"symbol\": \"$SYMBOL\",
        \"direction\": \"$DIRECTION\",
        \"confidence\": $CONFIDENCE,
        \"reasoning\": \"$REASONING\",
        \"_archived\": false,
        \"_draft\": false
      }
    }")
  
  if [[ "$WEBFLOW_RESP" =~ ^20[0-9]$ ]]; then
    echo "  ✅ $SYMBOL $DIRECTION (confidence: $CONFIDENCE)"
    SYNCED=$((SYNCED + 1))
  else
    echo "  ❌ $SYMBOL $DIRECTION (HTTP $WEBFLOW_RESP)"
    FAILED=$((FAILED + 1))
  fi
done

echo ""
echo "=============================="
echo "✅ Synced: $SYNCED"
echo "❌ Failed: $FAILED"
echo "=============================="
echo ""

if [[ "$FAILED" -gt 0 ]]; then
  echo "⚠️  Some syncs failed - check Webflow API token & collection ID"
  exit 1
fi

echo "✨ Sync complete!"
