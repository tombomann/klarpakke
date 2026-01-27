#!/usr/bin/env bash
set -euo pipefail

echo "📊 Exporting signals to CSV for Webflow CMS import"
echo "================================================="
echo ""

if [[ -z "${SUPABASE_URL:-}" ]]; then
  source .env
fi

BASE_URL="${SUPABASE_URL}/rest/v1"
OUTPUT="webflow-signals.csv"

# Fetch pending signals
RESP=$(curl -s \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Authorization: Bearer ${SUPABASE_ANON_KEY}" \
  "${BASE_URL}/signals?status=eq.pending&order=created_at.desc&limit=10")

if ! echo "$RESP" | jq -e . >/dev/null 2>&1; then
  echo "❌ Invalid JSON response"
  exit 1
fi

# Convert to CSV (Name, Slug, Symbol, Direction, Confidence, Reason)
echo "Name,Slug,Symbol,Direction,Confidence,Reason" > "$OUTPUT"
echo "$RESP" | jq -r '.[] | [(.symbol + " " + .direction), (.symbol + "-" + .direction + "-" + (.created_at | split("T")[0])), .symbol, .direction, .confidence, .reason] | @csv' >> "$OUTPUT"

COUNT=$(tail -n +2 "$OUTPUT" | wc -l | tr -d ' ')

echo "✅ Exported ${COUNT} signals to ${OUTPUT}"
echo ""
echo "Import to Webflow:"
echo "  1. Go to CMS Collections in Webflow"
echo "  2. Create 'Signals' collection (if not exists)"
echo "  3. Import → Upload ${OUTPUT}"
echo "  4. Map: Name→Name, Slug→Slug, Symbol→Symbol, etc."
