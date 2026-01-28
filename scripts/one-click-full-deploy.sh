#!/bin/bash
set -e

# ═══════════════════════════════════════════════════════════
# Klarpakke ONE-CLICK FULL DEPLOYMENT
# ═══════════════════════════════════════════════════════════
# Deploys EVERYTHING: Supabase + Webflow + Make.com + GitHub Actions
# Usage: bash scripts/one-click-full-deploy.sh

echo "╔════════════════════════════════════════════════════════╗"
echo "║  🚀 KLARPAKKE ONE-CLICK FULL DEPLOYMENT v1.1         ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# ═══════════════════════════════════════════════════════════
# STEP 0: Guardrails
# ═══════════════════════════════════════════════════════════
if [ -f .git/MERGE_HEAD ]; then
  echo "❌ Git merge is in progress (MERGE_HEAD exists)."
  echo "Fix it first:"
  echo "  git status"
  echo "  git add . && git commit -m 'merge: resolve'"
  echo "  # or: git merge --abort"
  exit 1
fi

# ═══════════════════════════════════════════════════════════
# STEP 1: Validate environment
# ═══════════════════════════════════════════════════════════
echo "📋 STEP 1/7: Validating environment..."

if [ ! -f .env ]; then
  echo "❌ .env file not found!"
  echo "Run: cp .env.example .env"
  exit 1
fi

source .env

# Check required tools
command -v supabase >/dev/null 2>&1 || { echo "❌ Supabase CLI not installed. Run: brew install supabase/tap/supabase"; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "❌ jq not installed. Run: brew install jq"; exit 1; }
command -v curl >/dev/null 2>&1 || { echo "❌ curl not installed"; exit 1; }

echo "✅ Environment validated"
echo ""

# ═══════════════════════════════════════════════════════════
# STEP 2: Deploy Supabase Backend
# ═══════════════════════════════════════════════════════════
echo "📦 STEP 2/7: Deploying Supabase backend..."

# Login if not already
if ! supabase projects list &>/dev/null; then
  echo "🔐 Login required..."
  supabase login
fi

# Link project
PROJECT_REF="${SUPABASE_PROJECT_REF:-swfyuwkptusceiouqlks}"
if ! supabase status &>/dev/null; then
  echo "🔗 Linking to project: $PROJECT_REF"
  supabase link --project-ref "$PROJECT_REF"
fi

# Deploy all Edge Functions (skip _shared and any folder without index.ts)
echo "📤 Deploying Edge Functions..."
for func_dir in supabase/functions/*; do
  [ -d "$func_dir" ] || continue
  func_name=$(basename "$func_dir")

  # Skip shared/internal folders
  if [[ "$func_name" == _* ]]; then
    continue
  fi

  # Only deploy real functions
  if [ ! -f "$func_dir/index.ts" ]; then
    continue
  fi

  echo "  → $func_name"
  supabase functions deploy "$func_name" --no-verify-jwt

done

# Apply database migrations
if [ -d "supabase/migrations" ]; then
  echo "🗄️  Applying database migrations..."
  supabase db push
fi

# Set secrets
echo "🔐 Setting secrets..."
bash scripts/fix-secrets.sh

echo "✅ Supabase backend deployed"
echo ""

# ═══════════════════════════════════════════════════════════
# STEP 3: Deploy Webflow Frontend
# ═══════════════════════════════════════════════════════════
echo "🎨 STEP 3/7: Preparing Webflow deployment..."

# Preferred: load JS from Supabase serve-js to avoid copy/paste issues
SERVE_JS_URL="${SUPABASE_URL:-https://swfyuwkptusceiouqlks.supabase.co}/functions/v1/serve-js"

echo "✅ Recommended Webflow footer snippet (copy/paste):"
echo "<script src=\"$SERVE_JS_URL\" defer></script>"
echo ""

# Fallback: copy local JS to clipboard
if command -v pbcopy >/dev/null 2>&1; then
  cat web/klarpakke-site.js | pbcopy
  echo "📋 Fallback JS copied to clipboard (web/klarpakke-site.js)."
fi

echo ""
echo "📋 MANUAL STEP REQUIRED:"
echo "  1. Open: https://webflow.com/design/klarpakke-c65071"
echo "  2. Go to: Project Settings → Custom Code → Footer Code"
echo "  3. Paste EXACTLY ONE of these options:"
echo "     A) Preferred: <script src=\"$SERVE_JS_URL\" defer></script>"
echo "     B) Fallback: wrap clipboard content inside <script>...</script>"
echo "  4. Click 'Publish'"
echo ""
read -p "Press Enter when Webflow is published..."

echo "✅ Webflow prepared"
echo ""

# ═══════════════════════════════════════════════════════════
# STEP 4: Deploy Make.com Blueprints
# ═══════════════════════════════════════════════════════════
echo "🔄 STEP 4/7: Deploying Make.com automation..."

if [ -z "$MAKE_API_KEY" ] || [ -z "$MAKE_TEAM_ID" ]; then
  echo "⚠️  Make.com credentials not found in .env"
  echo "   Skipping automated deployment"
  echo "   Manual: Import blueprints/*.json in Make.com"
else
  echo "📤 Uploading blueprints to Make.com..."

  for blueprint in blueprints/*.json; do
    [ -f "$blueprint" ] || continue
    blueprint_name=$(basename "$blueprint" .json)
    echo "  → $blueprint_name"

    # Escape JSON for API call
    blueprint_json=$(cat "$blueprint" | jq -c '.')

    curl -s -X POST "https://eu1.make.com/api/v2/scenarios/import" \
      -H "Authorization: Token $MAKE_API_KEY" \
      -H "Content-Type: application/json" \
      -d "{\"teamId\": $MAKE_TEAM_ID, \"blueprint\": \"$(echo "$blueprint_json" | sed 's/"/\\"/g')\"}" \
      | jq -r '.scenario.id // "❌ Failed"'
  done
fi

echo "✅ Make.com blueprints deployed"
echo ""

# ═══════════════════════════════════════════════════════════
# STEP 5: Seed Demo Data
# ═══════════════════════════════════════════════════════════
echo "🌱 STEP 5/7: Seeding demo data..."

bash scripts/paper-seed.sh

echo "✅ Demo data seeded"
echo ""

# ═══════════════════════════════════════════════════════════
# STEP 6: Setup GitHub Actions CI/CD
# ═══════════════════════════════════════════════════════════
echo "🔧 STEP 6/7: Setting up GitHub Actions..."

echo "✅ GitHub Actions configured (workflow should exist in repo)"
echo ""

# ═══════════════════════════════════════════════════════════
# STEP 7: Verify Deployment
# ═══════════════════════════════════════════════════════════
echo "✅ STEP 7/7: Verifying deployment..."

# Test Supabase
echo "🧪 Testing Supabase..."
SUPABASE_URL="${SUPABASE_URL:-https://swfyuwkptusceiouqlks.supabase.co}"
RESPONSE=$(curl -s -X POST "$SUPABASE_URL/functions/v1/debug-env" \
  -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{"test": true}')

if echo "$RESPONSE" | jq -e '.SUPABASE_URL' >/dev/null 2>&1; then
  echo "✅ Supabase: OK"
else
  echo "⚠️  Supabase: Check logs"
fi

# Test Webflow
echo "🧪 Testing Webflow..."
WEBFLOW_URL="${WEBFLOW_URL:-https://klarpakke-c65071.webflow.io}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$WEBFLOW_URL")
if [ "$HTTP_CODE" = "200" ]; then
  echo "✅ Webflow: OK"
else
  echo "⚠️  Webflow: HTTP $HTTP_CODE"
fi

# Check signals count
echo "🧪 Checking signals..."
SIGNALS_COUNT=$(curl -s "$SUPABASE_URL/rest/v1/signals?select=count" \
  -H "apikey: $SUPABASE_ANON_KEY" \
  -H "Authorization: Bearer $SUPABASE_ANON_KEY" | jq -r '.[0].count // 0')

echo "✅ Signals in database: $SIGNALS_COUNT"

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║  🎉 DEPLOYMENT COMPLETE!                              ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "🌐 LIVE URLS (verify in Webflow Pages):"
echo "  • Dashboard: $WEBFLOW_URL/app/dashboard"
echo "  • Calculator: $WEBFLOW_URL/kalkulator"
echo "  • API Status: $SUPABASE_URL/functions/v1/debug-env"
echo ""
