#!/bin/bash
# Klarpakke Webflow One-Click Deployment
# Injects the "Master Site Engine" into clipboard
set -euo pipefail

UI_FILE="web/klarpakke-site.js"

echo "🚀 Klarpakke Webflow One-Click Deployment"
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
  echo "✅ JavaScript (Landing + Dashboard) copied to clipboard!"
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
echo "┌─ STEP 1: PASTE CODE (Site-wide) ─────────────────────┐"
echo "│                                                      │"
echo "│ 1. Click 'Pages' panel -> 'Home'                     │"
echo "│ 2. Click ⚙️ (Page Settings)                          │"
echo "│ 3. Scroll to 'Custom Code' -> 'Before </body> tag'   │"
echo "│ 4. PASTE the code (Cmd+V)                            │"
echo "│ 5. Save & Publish                                    │"
echo "│                                                      │"
echo "│ (Ideally, paste this in Project Settings -> Custom   │"
echo "│  Code tab to apply to ALL pages automatically)       │"
echo "└──────────────────────────────────────────────────────┘"
echo ""
