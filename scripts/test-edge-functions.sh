#!/bin/bash
# Test Edge Functions
set -euo pipefail

echo "🧪 Testing Edge Functions"
echo "======================="
echo ""

if [ ! -f ".env" ]; then
  echo "❌ .env not found"
  exit 1
fi

source .env

if [ -z "${SUPABASE_URL:-}" ] || [ -z "${SUPABASE_ANON_KEY:-}" ]; then
  echo "❌ Missing SUPABASE_URL or SUPABASE_ANON_KEY"
  exit 1
fi

echo "Testing against: $SUPABASE_URL"
echo ""

# Test 1: Generate Trading Signal
echo "[1/2] Testing generate-trading-signal..."
RESPONSE=$(curl -s -X POST "$SUPABASE_URL/functions/v1/generate-trading-signal" \
  -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
  -H "Content-Type: application/json")

if echo "$RESPONSE" | jq -e '.success' > /dev/null 2>&1; then
  echo "✅ Success!"
  echo "$RESPONSE" | jq '.'
else
  echo "❌ Failed or no 'success' field"
  echo "Response: $RESPONSE"
fi

echo ""

# Test 2: Update Positions
echo "[2/2] Testing update-positions..."
RESPONSE=$(curl -s -X POST "$SUPABASE_URL/functions/v1/update-positions" \
  -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
  -H "Content-Type: application/json")

if echo "$RESPONSE" | jq -e '.' > /dev/null 2>&1; then
  echo "✅ Success!"
  echo "$RESPONSE" | jq '.'
else
  echo "❌ Failed"
  echo "Response: $RESPONSE"
fi

echo ""
echo "✅ Tests complete!"
echo ""
echo "View logs in dashboard:"
echo "  https://supabase.com/dashboard/project/swfyuwkptusceiouqlks/functions"
echo ""
