#!/usr/bin/env bash
set -euo pipefail

echo "🧪 Webflow Single Signal Test"
echo "============================="
echo ""

# Load .env
if [[ -f .env ]]; then
  set -a && source .env && set +a
else
  echo "❌ .env not found"
  exit 1
fi

# Check required vars
if [[ -z "${WEBFLOW_API_TOKEN:-}" ]] || [[ -z "${WEBFLOW_COLLECTION_ID:-}" ]]; then
  echo "❌ Missing WEBFLOW_API_TOKEN or WEBFLOW_COLLECTION_ID in .env"
  exit 1
fi

if [[ -z "${SUPABASE_URL:-}" ]] || [[ -z "${SUPABASE_ANON_KEY:-}" ]]; then
  echo "❌ Missing SUPABASE_URL or SUPABASE_ANON_KEY in .env"
  exit 1
fi

echo "Step 1: Fetch collection schema"
echo ""

# Fetch collection details
COLLECTION=$(curl -s "https://api.webflow.com/v2/collections/${WEBFLOW_COLLECTION_ID}" \
  -H "Authorization: Bearer $WEBFLOW_API_TOKEN" \
  -H "Accept: application/json")

if echo "$COLLECTION" | jq -e '.message' > /dev/null 2>&1; then
  echo "❌ API Error:"
  echo "$COLLECTION" | jq -r '.message'
  exit 1
fi

echo "✅ Collection: $(echo "$COLLECTION" | jq -r '.displayName')"
echo ""

echo "Fields:"
echo "$COLLECTION" | jq -r '.fields[] | "  - \(.slug) (\(.type)) \(if .required then "REQUIRED" else "" end)"'
echo ""

echo "Step 2: Get one pending signal from Supabase"
echo ""

# Get first pending signal
SIGNAL=$(curl -s "${SUPABASE_URL}/rest/v1/signals?status=eq.PENDING&limit=1" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Authorization: Bearer ${SUPABASE_ANON_KEY}" | jq -r '.[0]')

if [[ "$SIGNAL" == "null" ]]; then
  echo "⚠️  No pending signals found"
  echo ""
  echo "Generate demo signals:"
  echo "  make paper-seed"
  exit 0
fi

SYMBOL=$(echo "$SIGNAL" | jq -r '.symbol')
DIRECTION=$(echo "$SIGNAL" | jq -r '.direction')
CONFIDENCE=$(echo "$SIGNAL" | jq -r '.confidence')
REASONING=$(echo "$SIGNAL" | jq -r '.reasoning // "No reasoning provided"')

echo "✅ Signal: $SYMBOL $DIRECTION (confidence: $CONFIDENCE)"
echo ""

echo "Step 3: Build payload with correct field mapping"
echo ""

# Get NAME field (required PlainText field, usually 'name' or 'title')
NAME_FIELD=$(echo "$COLLECTION" | jq -r '.fields[] | select(.type == "PlainText" and .required == true) | .slug' | head -1)
if [[ -z "$NAME_FIELD" ]]; then
  NAME_FIELD="name"
fi

# Get SLUG field (required ItemRef field)
SLUG_FIELD=$(echo "$COLLECTION" | jq -r '.fields[] | select(.slug == "slug") | .slug')
if [[ -z "$SLUG_FIELD" ]]; then
  SLUG_FIELD="slug"
fi

echo "Detected fields:"
echo "  - Name field: $NAME_FIELD"
echo "  - Slug field: $SLUG_FIELD"
echo ""

# Build minimal payload (only required fields)
SLUG_VALUE=$(echo "${SYMBOL}-${DIRECTION}-$(date +%s)" | tr '[:upper:]' '[:lower:]')
NAME_VALUE="${SYMBOL} ${DIRECTION}"

PAYLOAD=$(cat << EOF
{
  "isArchived": false,
  "isDraft": false,
  "fieldData": {
    "$NAME_FIELD": "$NAME_VALUE",
    "$SLUG_FIELD": "$SLUG_VALUE"
  }
}
EOF
)

echo "Payload:"
echo "$PAYLOAD" | jq .
echo ""

echo "Step 4: Send to Webflow CMS"
echo ""

RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" \
  -X POST "https://api.webflow.com/v2/collections/${WEBFLOW_COLLECTION_ID}/items" \
  -H "Authorization: Bearer $WEBFLOW_API_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "$PAYLOAD")

# Extract HTTP code
HTTP_CODE=$(echo "$RESPONSE" | grep -o "HTTP_CODE:[0-9]*" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | sed '/HTTP_CODE:/d')

if [[ "$HTTP_CODE" == "200" ]] || [[ "$HTTP_CODE" == "201" ]]; then
  echo "✅ SUCCESS! Item created in Webflow"
  echo ""
  echo "Item ID: $(echo "$BODY" | jq -r '.id')"
  echo ""
  echo "View in Webflow:"
  echo "  https://webflow.com/dashboard/sites/69743573d50cc16bbbe54344/collections/${WEBFLOW_COLLECTION_ID}"
  echo ""
  echo "✨ Next: Test full sync with all signals"
  echo "  bash scripts/webflow-sync.sh"
else
  echo "❌ FAILED (HTTP $HTTP_CODE)"
  echo ""
  echo "Response:"
  echo "$BODY" | jq .
  echo ""
  echo "🔧 TROUBLESHOOTING:"
  echo ""
  
  if echo "$BODY" | jq -e '.message' > /dev/null 2>&1; then
    ERROR_MSG=$(echo "$BODY" | jq -r '.message')
    
    if [[ "$ERROR_MSG" == *"required"* ]]; then
      echo "  • Missing required field in payload"
      echo "  • Run: bash scripts/debug-webflow-collection.sh"
      echo "  • Check which fields are REQUIRED in collection"
    elif [[ "$ERROR_MSG" == *"slug"* ]]; then
      echo "  • Slug must be unique"
      echo "  • Slug format: lowercase, no spaces, hyphens OK"
      echo "  • Try: $SLUG_VALUE"
    elif [[ "$ERROR_MSG" == *"validation"* ]]; then
      echo "  • Field validation failed"
      echo "  • Check field types match (PlainText, Number, RichText)"
      echo "  • Confidence must be Number (not String)"
    else
      echo "  • Error: $ERROR_MSG"
    fi
  fi
  
  echo ""
  echo "Common fixes:"
  echo "  1. Check collection has minimal required fields (name + slug)"
  echo "  2. Verify API token has 'cms:write' scope"
  echo "  3. Run debug script: bash scripts/debug-webflow-collection.sh"
  echo ""
fi
