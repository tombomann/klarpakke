#!/usr/bin/env bash
set -euo pipefail

echo "🔍 Webflow Collection Schema Debugger"
echo "======================================"
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

echo "📊 Fetching collection schema..."
echo ""

# Fetch collection details
RESPONSE=$(curl -s "https://api.webflow.com/v2/collections/${WEBFLOW_COLLECTION_ID}" \
  -H "Authorization: Bearer $WEBFLOW_API_TOKEN" \
  -H "Accept: application/json")

# Check for errors
if echo "$RESPONSE" | jq -e '.message' > /dev/null 2>&1; then
  echo "❌ API Error:"
  echo "$RESPONSE" | jq -r '.message'
  exit 1
fi

echo "✅ Collection found!"
echo ""
echo "Collection Name: $(echo "$RESPONSE" | jq -r '.displayName')"
echo "Collection ID: $(echo "$RESPONSE" | jq -r '.id')"
echo ""

echo "📋 FIELDS IN WEBFLOW COLLECTION:"
echo "================================"
echo ""

# List all fields
echo "$RESPONSE" | jq -r '.fields[] | "  - \(.slug) (\(.type)) \(if .required then "REQUIRED" else "optional" end)"'

echo ""
echo "📊 SUPABASE SIGNAL DATA STRUCTURE:"
echo "=================================="
echo ""

# Show what we're trying to send
cat << 'EOF'
From Supabase 'signals' table:
  - id (uuid) 
  - symbol (text) REQUIRED
  - direction (text) REQUIRED (BUY/SELL)
  - confidence (numeric) REQUIRED (0.0-1.0)
  - reasoning (text) optional
  - status (text) REQUIRED (PENDING/APPROVED/REJECTED)
  - created_at (timestamp)
  - source (text) optional
EOF

echo ""
echo "🔧 FIELD MAPPING REQUIRED:"
echo "========================="
echo ""
echo "We need to map Supabase fields → Webflow CMS fields:"
echo ""
echo "  Supabase          →  Webflow CMS Field"
echo "  ----------------     -------------------"
echo "  symbol            →  [name/slug field]"
echo "  direction         →  [plain text field]"
echo "  confidence        →  [number field]"
echo "  reasoning         →  [rich text field]"
echo "  status            →  [option field?]"
echo ""

echo "📝 EXAMPLE PAYLOAD TO CREATE ITEM:"
echo "=================================="
echo ""

# Get first pending signal from Supabase
SIGNAL=$(curl -s "${SUPABASE_URL}/rest/v1/signals?status=eq.PENDING&limit=1" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Authorization: Bearer ${SUPABASE_ANON_KEY}" | jq -r '.[0]')

if [[ "$SIGNAL" == "null" ]]; then
  echo "⚠️  No pending signals in Supabase"
  echo ""
  echo "Generate demo signals:"
  echo "  make paper-seed"
  exit 0
fi

echo "From Supabase signal:"
echo "$SIGNAL" | jq '{
  id,
  symbol,
  direction,
  confidence,
  reasoning: (.reasoning // "No reasoning provided"),
  status,
  created_at
}'

echo ""
echo "🔄 TRYING TO MAP TO WEBFLOW..."
echo ""

# Get field slugs from collection
NAME_FIELD=$(echo "$RESPONSE" | jq -r '.fields[] | select(.type == "PlainText" and .required == true) | .slug' | head -1)
if [[ -z "$NAME_FIELD" ]]; then
  NAME_FIELD="name"
fi

echo "Detected 'name' field slug: $NAME_FIELD"
echo ""

# Try to create test payload
SYMBOL=$(echo "$SIGNAL" | jq -r '.symbol')
DIRECTION=$(echo "$SIGNAL" | jq -r '.direction')
CONFIDENCE=$(echo "$SIGNAL" | jq -r '.confidence')

cat << EOF
Proposed Webflow CMS item payload:
{
  "isArchived": false,
  "isDraft": false,
  "fieldData": {
    "$NAME_FIELD": "${SYMBOL} ${DIRECTION}",
    "slug": "$(echo ${SYMBOL}-${DIRECTION} | tr '[:upper:]' '[:lower:]')"
  }
}
EOF

echo ""
echo "🧪 NEXT STEPS:"
echo "=============="
echo ""
echo "1. Review field list above"
echo "2. Map Supabase fields to correct Webflow field slugs"
echo "3. Update scripts/webflow-sync.sh with correct mapping"
echo "4. Test with single signal:"
echo "   bash scripts/webflow-test-single.sh"
echo ""
echo "🔗 View collection in Webflow:"
echo "   https://webflow.com/dashboard/sites/${SITE_ID:-}/collections/${WEBFLOW_COLLECTION_ID}"
echo ""
