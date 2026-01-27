#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Klarpakke Webflow One-Click Deployment"
echo "=========================================="
echo ""

# Step 1: Copy JavaScript to clipboard (macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
  cat web/klarpakke-ui.js | pbcopy
  echo "✅ JavaScript copied to clipboard!"
else
  echo "⚠️  Manual copy required (Linux detected)"
  echo "   Run: cat web/klarpakke-ui.js"
fi
echo ""

# Step 2: Open Webflow in browser
echo "🌐 Opening Webflow Designer..."
open "https://webflow.com/dashboard/sites/klarpakke/designer" 2>/dev/null || \
  echo "   Manual: Open https://webflow.com/dashboard"
echo ""
sleep 2

# Step 3: Interactive checklist
echo "📋 FOLLOW THESE 3 STEPS (2 min):"
echo ""
echo "┌─ STEP 1: PASTE JAVASCRIPT (45 sec) ─────────────────┐"
echo "│                                                      │"
echo "│ In Webflow Designer:                                │"
echo "│ 1. Click ⚙️ (Project Settings) - top left           │"
echo "│ 2. Click 'Custom Code' tab                          │"
echo "│ 3. Scroll to 'Before </body> tag' section           │"
echo "│ 4. Click inside code box                            │"
echo "│ 5. Paste (Cmd+V) - JavaScript already in clipboard! │"
echo "│ 6. Click 'Save Changes'                             │"
echo "│                                                      │"
echo "└──────────────────────────────────────────────────────┘"
echo ""
read -p "Press ENTER when Step 1 complete..."
echo ""

echo "┌─ STEP 2: PASSWORD PROTECTION (30 sec) ──────────────┐"
echo "│                                                      │"
echo "│ In Webflow Designer:                                │"
echo "│ 1. Click 'Pages' panel (left sidebar)               │"
echo "│ 2. Find '/app/dashboard' page                       │"
echo "│ 3. Click ⚙️ (Page Settings)                          │"
echo "│ 4. Toggle 'Password Protection' → ON                │"
echo "│ 5. Enter password: tom                              │"
echo "│ 6. Click 'Save'                                      │"
echo "│                                                      │"
echo "└──────────────────────────────────────────────────────┘"
echo ""
read -p "Press ENTER when Step 2 complete..."
echo ""

echo "┌─ STEP 3: PUBLISH (30 sec) ───────────────────────────┐"
echo "│                                                      │"
echo "│ In Webflow Designer:                                │"
echo "│ 1. Click 'Publish' button (top right)               │"
echo "│ 2. Select domain: klarpakke-c65071.webflow.io       │"
echo "│ 3. Click 'Publish to Selected Domains'              │"
echo "│ 4. Wait for progress bar (10-15 sec)                │"
echo "│ 5. See 'Successfully published!' message             │"
echo "│                                                      │"
echo "└──────────────────────────────────────────────────────┘"
echo ""
read -p "Press ENTER when Step 3 complete..."
echo ""

# Step 4: Auto-verify
echo "🧪 Running post-deployment verification..."
echo ""
sleep 2

SITE_URL="https://klarpakke-c65071.webflow.io/app/dashboard"
echo "Testing: $SITE_URL"
echo ""

# Check if site responds (with password protection = 401)
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$SITE_URL" || echo "000")

if [[ "$HTTP_CODE" == "401" ]]; then
  echo "✅ Site published successfully!"
  echo "✅ Password protection active (HTTP 401)"
elif [[ "$HTTP_CODE" == "200" ]]; then
  echo "⚠️  Site live but no password protection detected"
elif [[ "$HTTP_CODE" == "404" ]]; then
  echo "❌ Page not found - check Webflow publish status"
else
  echo "⚠️  Unexpected HTTP $HTTP_CODE - verify manually"
fi
echo ""

# Check if JavaScript is embedded (curl won't work with password, so manual test)
echo "🧪 MANUAL TEST REQUIRED:"
echo ""
echo "1. Open: $SITE_URL"
echo "2. Enter password: tom"
echo "3. Open Console (F12 or Cmd+Option+J)"
echo "4. Look for: [Klarpakke] UI script loaded"
echo "5. Click any 'Approve' button"
echo "6. Verify: [Klarpakke] Success: {...}"
echo ""
echo "Expected behavior:"
echo "  - Button text changes to 'Approving...'"
echo "  - Status updates to 'Approved ✅'"
echo "  - Card fades to 50% opacity"
echo ""

read -p "Did the test pass? (y/n): " TEST_RESULT

if [[ "$TEST_RESULT" == "y" ]]; then
  echo ""
  echo "🎉 DEPLOYMENT COMPLETE!"
  echo ""
  echo "✅ JavaScript embedded"
  echo "✅ Password protection active"
  echo "✅ Site published"
  echo "✅ Approve/reject flow working"
  echo ""
  echo "Next steps:"
  echo "  make paper-seed     # Generate demo signals"
  echo "  make edge-logs      # Monitor Edge Functions"
  echo ""
  echo "Dashboard: https://supabase.com/dashboard/project/swfyuwkptusceiouqlks"
else
  echo ""
  echo "⚠️  Test failed - debugging steps:"
  echo ""
  echo "1. Check Console for errors (F12)"
  echo "2. Verify Custom Code saved: Project Settings → Custom Code"
  echo "3. Hard refresh: Cmd+Shift+R (clear cache)"
  echo "4. Check CORS: Supabase Dashboard → Settings → API"
  echo "5. Re-run: bash scripts/webflow-one-click.sh"
fi
echo ""
echo "✨ Deployment script complete!"
