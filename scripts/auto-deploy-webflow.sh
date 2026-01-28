#!/usr/bin/env bash
set -euo pipefail

# ═══════════════════════════════════════════════════════════
# AUTO-DEPLOY WEBFLOW
# Automatically deploys Klarpakke web assets to Webflow
# ═══════════════════════════════════════════════════════════

echo "🚀 Klarpakke Webflow Auto-Deploy"
echo "════════════════════════════════════════════════════════════"

# ───────────────────────────────────────────────────────────
# 1. CHECK ENVIRONMENT
# ───────────────────────────────────────────────────────────
echo "📋 Checking environment..."

if [[ ! -f ".env" ]]; then
  echo "❌ Missing .env file"
  exit 1
fi

source .env

: "${WEBFLOW_API_TOKEN:?❌ Missing WEBFLOW_API_TOKEN in .env}"
: "${WEBFLOW_SITE_ID:?❌ Missing WEBFLOW_SITE_ID in .env}"
: "${SUPABASE_URL:?❌ Missing SUPABASE_URL in .env}"
: "${SUPABASE_ANON_KEY:?❌ Missing SUPABASE_ANON_KEY in .env}"

echo "✅ Environment OK"

# ───────────────────────────────────────────────────────────
# 2. BUILD WEB ASSETS
# ───────────────────────────────────────────────────────────
echo ""
echo "🏗️  Building web assets..."
npm run build:web

if [[ ! -d "web/dist" ]]; then
  echo "❌ Build failed: web/dist not found"
  exit 1
fi

echo "✅ Web assets built"

# ───────────────────────────────────────────────────────────
# 3. GENERATE WEBFLOW LOADER
# ───────────────────────────────────────────────────────────
echo ""
echo "📦 Generating Webflow loader..."

# Get latest commit SHA for CDN URL
COMMIT_SHA=$(git rev-parse HEAD)

# Generate loader HTML
LOADER_HTML=$(cat <<EOF
<script>
// Klarpakke Auto-Loader v2
// Deployed: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
// Commit: ${COMMIT_SHA}

(function() {
  'use strict';
  
  // Config
  window.KLARPAKKE_CONFIG = {
    supabaseUrl: '${SUPABASE_URL}',
    supabaseAnonKey: '${SUPABASE_ANON_KEY}',
    version: '${COMMIT_SHA}',
    debug: false
  };
  
  console.log('[Klarpakke] Config loaded', window.KLARPAKKE_CONFIG.version);
  
  // CDN Base
  const CDN_BASE = 'https://cdn.jsdelivr.net/gh/tombomann/klarpakke@${COMMIT_SHA}/web/dist';
  
  // Load main site script
  const mainScript = document.createElement('script');
  mainScript.src = CDN_BASE + '/klarpakke-site.js';
  mainScript.async = true;
  mainScript.onload = () => console.log('[Klarpakke] Main script loaded');
  mainScript.onerror = () => console.error('[Klarpakke] Failed to load main script');
  document.body.appendChild(mainScript);
  
  // Load calculator (only if on /kalkulator page)
  if (window.location.pathname.includes('/kalkulator')) {
    const calcScript = document.createElement('script');
    calcScript.src = CDN_BASE + '/calculator.js';
    calcScript.async = true;
    calcScript.onload = () => console.log('[Klarpakke] Calculator loaded');
    calcScript.onerror = () => console.error('[Klarpakke] Failed to load calculator');
    document.body.appendChild(calcScript);
  }
})();
</script>
EOF
)

echo "✅ Loader generated"

# ───────────────────────────────────────────────────────────
# 4. UPDATE WEBFLOW CUSTOM CODE
# ───────────────────────────────────────────────────────────
echo ""
echo "🎨 Updating Webflow Custom Code..."

command -v jq >/dev/null || { echo "❌ jq is required. Install: brew install jq"; exit 1; }

# Escape for JSON
LOADER_JSON=$(printf '%s' "$LOADER_HTML" | jq -Rs '.')

PAYLOAD=$(cat <<EOF
{
  "scripts": [
    {
      "location": "footer",
      "code": ${LOADER_JSON}
    }
  ]
}
EOF
)

RESPONSE=$(curl -sS -X PUT "https://api.webflow.com/v2/sites/${WEBFLOW_SITE_ID}/custom_code" \
  -H "Authorization: Bearer ${WEBFLOW_API_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD")

if echo "$RESPONSE" | jq -e '.id' > /dev/null 2>&1; then
  echo "✅ Custom Code updated"
else
  echo "❌ Failed to update Custom Code:"
  echo "$RESPONSE" | jq -r '.message // .'
  exit 1
fi

# ───────────────────────────────────────────────────────────
# 5. PUBLISH WEBFLOW SITE
# ───────────────────────────────────────────────────────────
echo ""
echo "📣 Publishing Webflow site..."

PUBLISH_RESPONSE=$(curl -sS -X POST "https://api.webflow.com/v2/sites/${WEBFLOW_SITE_ID}/publish" \
  -H "Authorization: Bearer ${WEBFLOW_API_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"domains": ["*.webflow.io"]}')

if echo "$PUBLISH_RESPONSE" | jq -e '.publishedAt' > /dev/null 2>&1; then
  PUBLISHED_AT=$(echo "$PUBLISH_RESPONSE" | jq -r '.publishedAt')
  echo "✅ Site published at: $PUBLISHED_AT"
else
  echo "⚠️  Publish may have failed:"
  echo "$PUBLISH_RESPONSE" | jq -r '.message // .'
fi

# ───────────────────────────────────────────────────────────
# 6. DONE
# ───────────────────────────────────────────────────────────
echo ""
echo "════════════════════════════════════════════════════════════"
echo "✅ Webflow Deploy Complete!"
echo ""
echo "📊 Summary:"
echo "   Commit: ${COMMIT_SHA}"
echo "   CDN: https://cdn.jsdelivr.net/gh/tombomann/klarpakke@${COMMIT_SHA}/web/dist"
echo "   Site: https://${WEBFLOW_SITE_ID}.webflow.io"
echo ""
echo "🧪 Test Instructions:"
echo "   1. Open DevTools (F12) → Console"
echo "   2. Look for: [Klarpakke] Config loaded"
echo "   3. Test pages: /, /pricing, /app/dashboard, /kalkulator"
echo "════════════════════════════════════════════════════════════"
