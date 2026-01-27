#!/usr/bin/env bash
set -euo pipefail

# Pushes the Webflow footer loader into Project Settings → Custom Code → Footer.
# Requires: WEBFLOW_API_TOKEN, WEBFLOW_SITE_ID, SUPABASE_URL, SUPABASE_ANON_KEY
# Optional: KLARPAKKE_ASSET_BASE, KLARPAKKE_DEBUG, WEBFLOW_PUBLISH_DOMAINS

TEMPLATE_PATH="web/snippets/webflow-footer-loader.template.html"

if [[ ! -f "$TEMPLATE_PATH" ]]; then
  echo "❌ Missing template: $TEMPLATE_PATH"
  exit 1
fi

: "${WEBFLOW_API_TOKEN:?Missing WEBFLOW_API_TOKEN}"
: "${WEBFLOW_SITE_ID:?Missing WEBFLOW_SITE_ID}"
: "${SUPABASE_URL:?Missing SUPABASE_URL}"
: "${SUPABASE_ANON_KEY:?Missing SUPABASE_ANON_KEY}"

ASSET_BASE="${KLARPAKKE_ASSET_BASE:-https://cdn.jsdelivr.net/gh/tombomann/klarpakke@main/web}"
DEBUG_BOOL="false"
if [[ "${KLARPAKKE_DEBUG:-}" == "1" || "${KLARPAKKE_DEBUG:-}" == "true" ]]; then
  DEBUG_BOOL="true"
fi

# Daily cache-bust (stable within a day so CDN caching remains effective)
CACHE_BUST="$(date -u +%F)"

echo "🧩 Rendering loader template…"
LOADER_HTML=$(cat "$TEMPLATE_PATH")
LOADER_HTML=${LOADER_HTML//__SUPABASE_URL__/$SUPABASE_URL}
LOADER_HTML=${LOADER_HTML//__SUPABASE_ANON_KEY__/$SUPABASE_ANON_KEY}
LOADER_HTML=${LOADER_HTML//__ASSET_BASE__/$ASSET_BASE}
LOADER_HTML=${LOADER_HTML//__DEBUG_BOOL__/$DEBUG_BOOL}
LOADER_HTML=${LOADER_HTML//__CACHE_BUST__/$CACHE_BUST}

# Escape for JSON safely using jq
JSON_CODE=$(printf '%s' "$LOADER_HTML" | jq -Rs '.')

PAYLOAD=$(cat <<EOF
{
  "scripts": [
    { "location": "footer", "code": ${JSON_CODE} }
  ]
}
EOF
)

echo "🚀 Updating Webflow site custom code (footer)…"
curl -sS -X PUT "https://api.webflow.com/v2/sites/${WEBFLOW_SITE_ID}/custom_code" \
  -H "Authorization: Bearer ${WEBFLOW_API_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" \
  | jq -r '.id // .message // "(no response body)"' || true

echo "📣 Publishing…"
PUBLISH_DOMAINS="${WEBFLOW_PUBLISH_DOMAINS:-["*.webflow.io"]}"

curl -sS -X POST "https://api.webflow.com/v2/sites/${WEBFLOW_SITE_ID}/publish" \
  -H "Authorization: Bearer ${WEBFLOW_API_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{\"domains\": ${PUBLISH_DOMAINS}}" \
  | jq -r '.publishedAt // .message // "(no response body)"' || true

echo "✅ Webflow footer loader deployed and published"
