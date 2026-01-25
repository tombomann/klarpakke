#!/usr/bin/env bash
set -euo pipefail

echo "🎯 Klarpakke: Webflow Data API → Supabase"

# Les credentials fra .env
if [[ -f .env ]]; then
  export $(grep -v '^#' .env | xargs)
fi

WEBFLOW_TOKEN="${WEBFLOW_TOKEN:-}"
SUPABASE_URL="${SUPABASE_URL:-}"

if [[ -z "$WEBFLOW_TOKEN" ]]; then
  echo "❌ WEBFLOW_TOKEN mangler i .env"
  exit 1
fi

# Hent site info
echo "📥 Henter Webflow site info..."
SITE_INFO=$(curl -s -f \
  -H "Authorization: Bearer $WEBFLOW_TOKEN" \
  -H "accept: application/json" \
  "https://api.webflow.com/v2/sites" | jq -r '.sites[0]')

SITE_ID=$(echo "$SITE_INFO" | jq -r '.id')
SITE_NAME=$(echo "$SITE_INFO" | jq -r '.displayName')

echo "✅ Site: $SITE_NAME ($SITE_ID)"

# Hent pages
PAGES=$(curl -s -f \
  -H "Authorization: Bearer $WEBFLOW_TOKEN" \
  "https://api.webflow.com/v2/sites/$SITE_ID/pages" | jq -e '.pages')

echo "📄 Pages funnet: $(echo "$PAGES" | jq 'length')"
echo "$PAGES" | jq -r '.[] | "\(.title) - \(.slug)"'

echo ""
echo "💡 NESTE STEG:"
echo "1. Bruk Webflow Data API til å update page content"
echo "2. Eller bruk Webflow Custom Code til JS injection"
echo "3. Eller bruk manual export + static hosting"
