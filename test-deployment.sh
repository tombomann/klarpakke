#!/bin/bash
echo "🔍 Testing Klarpakke deployment..."

# Test 1: Lokal build
cd app
echo "1. Testing local build..."
npm run build > /tmp/build.log 2>&1 && echo "✅ Local build success" || echo "❌ Local build failed"

# Test 2: Sjekk Vercel status
echo -e "\n2. Checking Vercel deployments..."
vercel ls 2>/dev/null | grep -A5 "klarpakke" || echo "⚠️  No Vercel deployments found"

# Test 3: Curl primary domain
echo -e "\n3. Testing klarpakke.vercel.app..."
STATUS=$(curl -o /dev/null -s -w "%{http_code}\n" "https://klarpakke.vercel.app")
if [ "$STATUS" = "200" ]; then
    echo "✅ HTTP 200 - Success!"
    open "https://klarpakke.vercel.app"
elif [ "$STATUS" = "404" ]; then
    echo "❌ HTTP 404 - Page not found"
    echo "   Sjekk: https://vercel.com/tom-jensens-projects/klarpakke/settings"
elif [ "$STATUS" = "000" ]; then
    echo "⚠️  No response - DNS or deployment issue"
else
    echo "⚠️  HTTP $STATUS - Unexpected status"
fi

echo -e "\n📋 Quick fixes to try:"
echo "   A. Åpne Vercel Dashboard: open https://vercel.com/tom-jensens-projects/klarpakke"
echo "   B. Sjekk Root Directory er '/app' i project settings"
echo "   C. Trykk 'Redeploy' på siste deployment"
