#!/bin/bash
# Klarpakke Webflow One-Click Deployment v2.0
# Injects the "Master Site Engine" into clipboard
set -euo pipefail

UI_FILE="web/klarpakke-site.js"

echo "🚀 Klarpakke Webflow One-Click Deployment v2.0"
echo "=========================================="
echo ""

# Check if file exists
if [ ! -f "$UI_FILE" ]; then
  echo "❌ Error: $UI_FILE not found."
  exit 1
fi

# Read and minify/prepare content
# Wrap in <script> tags for Webflow Custom Code box
CONTENT="<script>
$(cat "$UI_FILE")
</script>"

# Copy to clipboard (OS specific)
if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "$CONTENT" | pbcopy
  echo "✅ JavaScript (Landing + Dashboard + Settings + Pricing) copied to clipboard!"
else
  echo "⚠️  Linux/Windows detected. Please copy content manually from $UI_FILE"
  echo "$CONTENT"
fi

# Open Webflow
echo ""
echo "🌐 Opening Webflow Designer..."
open "https://webflow.com/dashboard/sites/klarpakke-c65071/designer" || true

echo ""
echo "📋 FOLLOW THESE STEPS:"
echo ""
echo "┌─ STEP 1: UPDATE CODE (Site-wide) ────────────────────┐"
echo "│                                                      │"
echo "│ 1. Go to Project Settings -> Custom Code -> Footer   │"
echo "│ 2. DELETE existing code                              │"
echo "│ 3. PASTE the new v2.0 code (Cmd+V)                   │"
echo "│ 4. Save & Publish                                    │"
echo "└──────────────────────────────────────────────────────┘"
echo ""
echo "┌─ STEP 2: CREATE PAGES (If missing) ──────────────────┐"
echo "│                                                      │"
echo "│ 1. Create page: 'settings' (Slug: app/settings)      │"
echo "│ 2. Create page: 'pricing'  (Slug: app/pricing)       │"
echo "│    (Use folder 'app' if possible, or just flat)      │"
echo "└──────────────────────────────────────────────────────┘"
