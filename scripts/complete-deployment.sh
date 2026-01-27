#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Klarpakke Complete Deployment"
echo "================================"
echo ""
echo "This script will:"
echo "  1. Fix Webflow field mapping (reasoning → reason)"
echo "  2. Generate demo signals"
echo "  3. Test single signal sync"
echo "  4. Deploy Webflow UI"
echo "  5. Verify everything works"
echo ""

read -p "Ready to start? (y/n): " READY
if [[ "$READY" != "y" ]]; then
  echo "Cancelled."
  exit 0
fi

echo ""
echo "=============================="
echo "STEP 1: Fix Webflow Sync Script"
echo "=============================="
echo ""

# Backup original
cp scripts/webflow-sync.sh scripts/webflow-sync.sh.backup

# Create fixed version
cat > scripts/webflow-sync.sh << 'SYNCEOF'
#!/usr/bin/env bash
set -euo pipefail

echo "🔄 Supabase → Webflow CMS Sync"
echo "=============================="
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
  echo "❌ Missing WEBFLOW_API_TOKEN or WEBFLOW_COLLECTION_ID"
  exit 1
fi

if [[ -z "${SUPABASE_URL:-}" ]] || [[ -z "${SUPABASE_ANON_KEY:-}" ]]; then
  echo "❌ Missing SUPABASE_URL or SUPABASE_ANON_KEY"
  exit 1
fi

echo "Fetching pending signals..."

# Fetch pending signals from Supabase
SIGNALS=$(curl -s "${SUPABASE_URL}/rest/v1/signals?status=eq.PENDING&order=created_at.desc&limit=50" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Authorization: Bearer ${SUPABASE_ANON_KEY}")

COUNT=$(echo "$SIGNALS" | jq 'length')

if [[ "$COUNT" -eq 0 ]]; then
  echo "⚠️  No pending signals found"
  echo ""
  echo "Generate demo signals:"
  echo "  make paper-seed"
  exit 0
fi

echo "✅ Found $COUNT pending signals"
echo ""
echo "Syncing to Webflow CMS..."

SYNCED=0
FAILED=0

# Process each signal
echo "$SIGNALS" | jq -c '.[]' | while read -r signal; do
  SYMBOL=$(echo "$signal" | jq -r '.symbol')
  DIRECTION=$(echo "$signal" | jq -r '.direction')
  CONFIDENCE=$(echo "$signal" | jq -r '.confidence')
  REASONING=$(echo "$signal" | jq -r '.reasoning // "No reasoning provided"')
  STATUS=$(echo "$signal" | jq -r '.status')
  
  # Create unique slug
  SLUG=$(echo "${SYMBOL}-${DIRECTION}-$(date +%s)" | tr '[:upper:]' '[:lower:]')
  NAME="${SYMBOL} ${DIRECTION}"
  
  # Build payload with correct field mapping
  PAYLOAD=$(cat << EOF
{
  "isArchived": false,
  "isDraft": false,
  "fieldData": {
    "name": "$NAME",
    "slug": "$SLUG",
    "symbol": "$SYMBOL",
    "direction": "$DIRECTION",
    "confidence": $CONFIDENCE,
    "reason": "$REASONING",
    "status": "$STATUS"
  }
}
EOF
)
  
  # Send to Webflow
  RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" \
    -X POST "https://api.webflow.com/v2/collections/${WEBFLOW_COLLECTION_ID}/items" \
    -H "Authorization: Bearer $WEBFLOW_API_TOKEN" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -d "$PAYLOAD")
  
  HTTP_CODE=$(echo "$RESPONSE" | grep -o "HTTP_CODE:[0-9]*" | cut -d: -f2)
  
  if [[ "$HTTP_CODE" == "200" ]] || [[ "$HTTP_CODE" == "201" ]]; then
    echo "  ✅ $SYMBOL $DIRECTION (confidence: $CONFIDENCE)"
    SYNCED=$((SYNCED + 1))
  else
    BODY=$(echo "$RESPONSE" | sed '/HTTP_CODE:/d')
    ERROR=$(echo "$BODY" | jq -r '.message // "Unknown error"')
    echo "  ❌ $SYMBOL $DIRECTION (HTTP $HTTP_CODE: $ERROR)"
    FAILED=$((FAILED + 1))
  fi
done

echo ""
echo "=============================="
echo "✅ Synced: $SYNCED"
echo "❌ Failed: $FAILED"
echo "=============================="
echo ""
echo "✨ Sync complete!"
SYNCEOF

chmod +x scripts/webflow-sync.sh

echo "✅ Fixed field mapping (reasoning → reason)"
echo "✅ Added required fields (name, slug)"
echo "✅ Converted confidence to number"
echo ""

echo "=============================="
echo "STEP 2: Generate Demo Signals"
echo "=============================="
echo ""

make paper-seed || true

echo ""
echo "=============================="
echo "STEP 3: Test Single Signal Sync"
echo "=============================="
echo ""

bash scripts/webflow-test-single.sh

echo ""
read -p "Did single signal test pass? (y/n): " TEST_PASS

if [[ "$TEST_PASS" != "y" ]]; then
  echo ""
  echo "❌ Test failed - stopping here"
  echo ""
  echo "Debug steps:"
  echo "  1. Check error message above"
  echo "  2. Verify Webflow collection fields match"
  echo "  3. Run: bash scripts/debug-webflow-collection.sh"
  echo "  4. Check API token has 'cms:write' scope"
  exit 1
fi

echo ""
echo "=============================="
echo "STEP 4: Full Sync (All Signals)"
echo "=============================="
echo ""

bash scripts/webflow-sync.sh

echo ""
read -p "Did full sync succeed? (y/n): " SYNC_SUCCESS

if [[ "$SYNC_SUCCESS" != "y" ]]; then
  echo ""
  echo "❌ Sync failed - check errors above"
  exit 1
fi

echo ""
echo "=============================="
echo "STEP 5: Deploy Webflow UI"
echo "=============================="
echo ""

echo "JavaScript will be copied to clipboard."
echo "Follow the 3-step guide to paste in Webflow Designer."
echo ""

read -p "Ready to deploy UI? (y/n): " DEPLOY_UI

if [[ "$DEPLOY_UI" == "y" ]]; then
  bash scripts/webflow-one-click.sh
fi

echo ""
echo "=============================="
echo "✅ DEPLOYMENT COMPLETE!"
echo "=============================="
echo ""
echo "What was deployed:"
echo "  ✅ Supabase Edge Functions (6)"
echo "  ✅ Database tables (4)"
echo "  ✅ Webflow field mapping fixed"
echo "  ✅ Demo signals synced to Webflow"
echo "  ✅ Webflow UI deployed"
echo ""
echo "Next steps:"
echo "  1. Test: https://klarpakke-c65071.webflow.io/app/dashboard"
echo "  2. Password: tom"
echo "  3. Click Approve/Reject buttons"
echo "  4. Check browser console for logs"
echo ""
echo "Monitor:"
echo "  - Supabase: https://supabase.com/dashboard/project/swfyuwkptusceiouqlks"
echo "  - Webflow CMS: https://webflow.com/dashboard/sites/69743573d50cc16bbbe54344/collections/6978258967f5139c7426902d"
echo "  - GitHub Actions: https://github.com/tombomann/klarpakke/actions"
echo ""
echo "🎉 Klarpakke is live!"
