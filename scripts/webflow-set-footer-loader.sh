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

command -v jq >/dev/null || { echo "❌ jq is required"; exit 1; }
command -v curl >/dev/null || { echo "❌ curl is required"; exit 1; }

http_ok() {
  # Treat any 2xx/3xx as OK
  local code="$1"
  [[ "$code" =~ ^2[0-9][0-9]$ || "$code" =~ ^3[0-9][0-9]$ ]]
}

check_url() {
  local url="$1"
  local label="$2"

  local code
  code=$(curl -sS -o /dev/null -w "%{http_code}" -L "$url" || echo "000")

  if http_ok "$code"; then
    echo "  ✅ $label ($code)"
    return 0
  fi

  echo "  ❌ $label ($code) → $url"
  return 1
}

preflight() {
  echo "🧪 Preflight: verifying public-config + asset URLs…"

  # 1) public-config endpoint reachable + returns expected json
  local cfg
  cfg=$(curl -sS -f -L "$KLARPAKKE_PUBLIC_CONFIG_URL")

  local supabase_url anon_key asset_base
  supabase_url=$(printf '%s' "$cfg" | jq -r '.supabaseUrl // empty')
  anon_key=$(printf '%s' "$cfg" | jq -r '.supabaseAnonKey // empty')
  asset_base=$(printf '%s' "$cfg" | jq -r '.assetBase // empty')

  if [[ -z "$supabase_url" || -z "$anon_key" ]]; then
    echo "❌ public-config returned missing supabaseUrl/supabaseAnonKey"
    echo "$cfg" | jq -c '.' || true
    exit 1
  fi

  if [[ -z "$asset_base" ]]; then
    asset_base="https://cdn.jsdelivr.net/gh/tombomann/klarpakke@main/web"
  fi

  echo "  ✅ public-config JSON OK"
  echo "  → assetBase: $asset_base"

  # 2) Ensure critical assets resolve (prevents publishing a broken loader)
  check_url "$asset_base/klarpakke-site.js" "asset klarpakke-site.js" || exit 1

  # calculator.js is optional, but warn if missing
  if ! check_url "$asset_base/calculator.js" "asset calculator.js"; then
    echo "  ⚠️  calculator.js not reachable (kalkulator page may break)"
  fi

  echo "✅ Preflight OK"
}

preflight

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
