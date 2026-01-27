#!/usr/bin/env bash
set -euo pipefail

echo "🔧 Klarpakke One-Click Fix & Deploy"
echo "===================================="
echo ""

# 1. Stash everything (including untracked)
echo "1/6 Stashing local changes..."
git stash --include-untracked

# 2. Pull from origin
echo "2/6 Pulling from origin/main..."
git pull origin main

# 3. Load .env
if [[ -f .env ]]; then
  set -a
  source .env
  set +a
  echo "3/6 Loaded .env ✅"
else
  echo "❌ .env missing. Run 'make bootstrap' first."
  exit 1
fi

# 4. Deploy edge functions (serve-js + approve-signal)
echo "4/6 Deploying serve-js + approve-signal..."
cd supabase/functions/serve-js
if [[ -f ../../../web/klarpakke-ui.js ]]; then
  cp ../../../web/klarpakke-ui.js ./klarpakke-ui.js
  echo "  ✅ Copied klarpakke-ui.js"
fi
cd ../../..

supabase functions deploy serve-js
supabase functions deploy approve-signal

echo ""
echo "🧪 Testing serve-js..."
curl -s https://swfyuwkptusceiouqlks.supabase.co/functions/v1/serve-js | head -n 3
echo "..."
echo ""

# 5. Seed demo signals
echo "5/6 Seeding demo signals..."
make paper-seed

# 6. Export to Webflow CSV
echo "6/6 Exporting to Webflow CSV..."
make webflow-export

echo ""
echo "✅ All fixed and deployed!"
echo ""
echo "Files ready:"
echo "  - webflow-signals.csv (import to Webflow CMS)"
echo ""
echo "Next steps:"
echo "  1. Import CSV to Webflow: CMS → Signals → Import"
echo "  2. Add script to Webflow (Project Settings → Custom Code → Before </body>):"
echo "     <script src=\"https://swfyuwkptusceiouqlks.supabase.co/functions/v1/serve-js\"></script>"
echo "  3. Password-protect /app/* with: tom"
echo "  4. Publish to: klarpakke-c65071.webflow.io"
echo ""
echo "Make.com blueprints (if needed):"
echo "  - Fix .env.migration with MAKE_API_TOKEN (teamId-based)"
echo "  - Run: make make-import"
