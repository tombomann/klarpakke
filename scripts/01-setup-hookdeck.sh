#!/bin/bash
set -euo pipefail

echo "🔐 HOOKDECK FIX"

export HOOKDECK_API_KEY=${HOOKDECK_API_KEY:-hkdk_live_xxx}
export STRIPE_WEBHOOK_SECRET=${STRIPE_WEBHOOK_SECRET:-whsec_test}
export BUBBLE_API_URL=https://tom-58107.bubbleapps.io
export BUBBLE_API_TOKEN=${BUBBLE_API_TOKEN:-your_token}

echo "SOURCE URL: https://hooks.hookdeck.com/sources/hkdk_live_xxx?key=\$HOOKDECK_API_KEY"
echo "📋 STRIPE: Add webhook: https://hooks.hookdeck.com/sources/hkdk_live_xxx"
echo "✅ HOOKDECK READY!"
