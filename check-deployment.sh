#!/bin/bash
set -euo pipefail

echo "🔍 Checking deployment status..."

# Wait for deployment to complete
echo "⏳ Venter 30 sekunder på deployment..."
sleep 30

# Test multiple URLs
echo ""
echo "🧪 Testing deployments..."

# Test default domain
echo "1. Testing klarpakke.vercel.app..."
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" https://klarpakke.vercel.app)
echo "   HTTP $RESPONSE"

# Test alias
echo "2. Testing elbatt-chatbot.vercel.app..."
RESPONSE2=$(curl -s -o /dev/null -w "%{http_code}" https://elbatt-chatbot.vercel.app)
echo "   HTTP $RESPONSE2"

# Get latest deployment URL from vercel
echo ""
echo "3. Getting latest deployment from Vercel..."
cd app
LATEST=$(vercel ls --json 2>/dev/null | jq -r '.[0].url' 2>/dev/null || echo "")

if [ -n "$LATEST" ]; then
    echo "   Latest: https://$LATEST"
    RESPONSE3=$(curl -s "https://$LATEST" | head -20)
    
    if echo "$RESPONSE3" | grep -q "<!DOCTYPE html>" || echo "$RESPONSE3" | grep -q "<html"; then
        echo "   ✅ SUCCESS! Deployment works!"
        echo ""
        echo "🌐 Opening browser..."
        open "https://$LATEST"
    else
        echo "   ❌ Still returning error"
        echo "$RESPONSE3"
    fi
else
    echo "   ⚠️  Could not get deployment URL"
fi

echo ""
echo "🎉 Check complete!"
