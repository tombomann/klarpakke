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
  "${SUPABASE_URL}/rest/v1/signals?status=eq.pending&select=*&limit=20" \
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

# Counters (must be in same shell, not subshell)
TEMP_FILE=$(mktemp)

# Push each signal to Webflow
echo "$BODY" | jq -c '.[]' | while read -r signal; do
  SIGNAL_ID=$(echo "$signal" | jq -r '.id')
  SYMBOL=$(echo "$signal" | jq -r '.symbol')
  DIRECTION=$(echo "$signal" | jq -r '.direction')
  CONFIDENCE=$(echo "$signal" | jq -r '.confidence // 0')
  REASONING=$(echo "$signal" | jq -r '.reasoning // "No reasoning"' | sed 's/"/\\"/g')
  
  # Generate slug (Webflow requirement - must be unique)
  SLUG="signal-${SIGNAL_ID:0:8}"
  
  # Webflow API v2 format - MATCH ACTUAL COLLECTION SCHEMA
  # Fields from API: symbol, direction, confidence, reason (not reasoning!), status, name, slug
  PAYLOAD=$(cat <<EOF
{
  "fieldData": {
    "name": "$SYMBOL $DIRECTION",
    "slug": "$SLUG",
    "symbol": "$SYMBOL",
    "direction": "$DIRECTION",
    "confidence": $CONFIDENCE,
    "reason": "$REASONING",
    "status": "pending"
  },
  "isArchived": false,
  "isDraft": false
}
EOF
)
  
  # Create Webflow CMS item
  WEBFLOW_RESP=$(curl -s -w "###HTTP_CODE###%{http_code}" \
    -X POST "https://api.webflow.com/v2/collections/${WEBFLOW_COLLECTION_ID}/items" \
    -H "Authorization: Bearer ${WEBFLOW_API_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "$PAYLOAD")
  
  HTTP_CODE=$(echo "$WEBFLOW_RESP" | grep -oE '[0-9]+$')
  RESPONSE_BODY=$(echo "$WEBFLOW_RESP" | sed 's/###HTTP_CODE###[0-9]*$//')
  
  # 200/201/202 = success
  if [[ "$HTTP_CODE" =~ ^20[0-2]$ ]]; then
    echo "  ✅ $SYMBOL $DIRECTION (confidence: $CONFIDENCE%)"
    echo "success" >> "$TEMP_FILE"
  else
    ERROR_MSG=$(echo "$RESPONSE_BODY" | jq -r '.message // "Unknown error"' 2>/dev/null || echo "Parse error")
    echo "  ❌ $SYMBOL $DIRECTION (HTTP $HTTP_CODE: $ERROR_MSG)"
    echo "fail" >> "$TEMP_FILE"
  fi
done

# Count results from temp file (avoid subshell issues)
SYNCED=$(grep -c "success" "$TEMP_FILE" 2>/dev/null || echo 0)
FAILED=$(grep -c "fail" "$TEMP_FILE" 2>/dev/null || echo 0)
rm -f "$TEMP_FILE"

echo ""
echo "=============================="
echo "✅ Synced: $SYNCED"
echo "❌ Failed: $FAILED"
echo "=============================="
echo ""

if [[ "${FAILED:-0}" -gt 0 ]] 2>/dev/null; then
  echo "⚠️  Some syncs failed - check error messages above"
  echo ""
  echo "Webflow Collection schema (from API):"
  echo "  - name (Plain Text, required)"
  echo "  - slug (Plain Text, required, unique)"
  echo "  - symbol (Plain Text)"
  echo "  - direction (Plain Text)"
  echo "  - confidence (Number)"
  echo "  - reason (Plain Text) ← NOTE: 'reason' not 'reasoning'"
  echo "  - status (Plain Text)"
  exit 1
fi

echo "✨ Sync complete!"
