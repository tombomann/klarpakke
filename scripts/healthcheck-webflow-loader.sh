#!/usr/bin/env bash
set -euo pipefail

# Healthcheck for Webflow loader stack:
# - public-config endpoint must be reachable and return expected fields
# - assetBase must have klarpakke-site.js (calculator.js optional)
#
# Required env:
#   KLARPAKKE_PUBLIC_CONFIG_URL
# Optional env:
#   KLARPAKKE_EXPECT_CALCULATOR=1  (treat missing calculator.js as failure)

: "${KLARPAKKE_PUBLIC_CONFIG_URL:?Missing KLARPAKKE_PUBLIC_CONFIG_URL}"

command -v jq >/dev/null || { echo "❌ jq is required"; exit 1; }
command -v curl >/dev/null || { echo "❌ curl is required"; exit 1; }

EXPECT_CALC="${KLARPAKKE_EXPECT_CALCULATOR:-0}"

http_ok() {
  local code="$1"
  [[ "$code" =~ ^2[0-9][0-9]$ || "$code" =~ ^3[0-9][0-9]$ ]]
}

check_url() {
  local url="$1"
  local label="$2"

  local code
  code=$(curl -sS -o /dev/null -w "%{http_code}" -L "$url" || echo "000")

  if http_ok "$code"; then
    echo "✅ $label ($code)"
    return 0
  fi

  echo "❌ $label ($code) → $url"
  return 1
}

echo "🔎 Klarpakke healthcheck"
echo "- Config: $KLARPAKKE_PUBLIC_CONFIG_URL"

cfg=$(curl -sS -f -L "$KLARPAKKE_PUBLIC_CONFIG_URL")

supabase_url=$(printf '%s' "$cfg" | jq -r '.supabaseUrl // empty')
anon_key=$(printf '%s' "$cfg" | jq -r '.supabaseAnonKey // empty')
asset_base=$(printf '%s' "$cfg" | jq -r '.assetBase // empty')

if [[ -z "$supabase_url" || -z "$anon_key" ]]; then
  echo "❌ public-config JSON missing fields (supabaseUrl/supabaseAnonKey)"
  echo "$cfg" | jq -c '.' || true
  exit 1
fi

if [[ -z "$asset_base" ]]; then
  asset_base="https://cdn.jsdelivr.net/gh/tombomann/klarpakke@main/web"
fi

echo "✅ public-config JSON OK"
echo "- assetBase: $asset_base"

check_url "$asset_base/klarpakke-site.js" "asset klarpakke-site.js" || exit 1

if check_url "$asset_base/calculator.js" "asset calculator.js"; then
  true
else
  if [[ "$EXPECT_CALC" == "1" ]]; then
    echo "❌ calculator.js missing and KLARPAKKE_EXPECT_CALCULATOR=1"
    exit 1
  fi
  echo "⚠️  calculator.js missing (kalkulator page may break)"
fi

echo "✅ Healthcheck OK"
