#!/bin/bash
set -euo pipefail

echo "🔧 Fixing Vercel Deployment Protection..."

# Åpne settings i browser
echo "📖 Åpner Vercel settings..."
open "https://vercel.com/tom-jensens-projects/klarpakke/settings/deployment-protection"

echo ""
echo "⚠️  MANUAL STEG I BROWSER:"
echo "1. Finn 'Vercel Authentication' eller 'Deployment Protection'"
echo "2. Sett til: 'Only Preview Deployments' eller 'Disabled'"
echo "3. Klikk 'Save'"
echo ""
echo "⏳ Venter 10 sekunder..."
sleep 10

# Test production URL
echo ""
echo "🧪 Testing production URL..."
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" https://elbatt-chatbot.vercel.app)

if [ "$RESPONSE" = "200" ]; then
    echo "✅ SUCCESS! Site is live!"
    echo "🌐 Opening: https://elbatt-chatbot.vercel.app"
    open "https://elbatt-chatbot.vercel.app"
elif [ "$RESPONSE" = "401" ]; then
    echo "⚠️  Still protected. Please disable protection in browser."
    echo "📖 Settings: https://vercel.com/tom-jensens-projects/klarpakke/settings/deployment-protection"
else
    echo "⚠️  HTTP $RESPONSE - Unexpected response"
fi

echo ""
echo "🎉 Done!"
