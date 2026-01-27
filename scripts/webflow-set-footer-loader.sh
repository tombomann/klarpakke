#!/usr/bin/env bash
set -euo pipefail

# Pushes the Webflow footer loader into Project Settings → Custom Code → Footer.
# This version uses public-config endpoint so Webflow does NOT store anon key.
#
# Required:
#   WEBFLOW_API_TOKEN
#   WEBFLOW_SITE_ID
#   KLARPAKKE_PUBLIC_CONFIG_URL  (e.g. https://<ref>.supabase.co/functions/v1/public-config)
# Optional:
#   WEBFLOW_PUBLISH_DOMAINS (JSON array string)

TEMPLATE_PATH="web/snippets/webflow-footer-loader.template.html"

if [[ ! -f "$TEMPLATE_PATH" ]]; then
  echo "❌ Missing template: $TEMPLATE_PATH"
  exit 1
fi

: "${WEBFLOW_API_TOKEN:?Missing WEBFLOW_API_TOKEN}"
: "${WEBFLOW_SITE_ID:?Missing WEBFLOW_SITE_ID}"
: "${KLARPAKKE_PUBLIC_CONFIG_URL:?Missing KLARPAKKE_PUBLIC_CONFIG_URL}"

# Daily cache-bust (stable within a day so CDN caching remains effective)
CACHE_BUST="$(date -u +%F)"

echo "🧩 Rendering loader template (public-config)…"
LOADER_HTML=$(cat "$TEMPLATE_PATH")
LOADER_HTML=${LOADER_HTML//__PUBLIC_CONFIG_URL__/$KLARPAKKE_PUBLIC_CONFIG_URL}
LOADER_HTML=${LOADER_HTML//__CACHE_BUST__/$CACHE_BUST}

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
