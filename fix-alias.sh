#!/bin/bash
set -euo pipefail

echo "🔧 Fixing Vercel alias..."

# Get latest deployment
LATEST_DEPLOY=$(vercel ls --json 2>/dev/null | jq -r '.[0].url' || echo "")

if [ -z "$LATEST_DEPLOY" ]; then
    echo "❌ Could not find latest deployment"
    exit 1
fi

echo "📦 Latest deployment: $LATEST_DEPLOY"

# Test if it works
echo "🧪 Testing deployment..."
RESPONSE=$(curl -s "https://$LATEST_DEPLOY" | head -20)

if echo "$RESPONSE" | grep -q "<!DOCTYPE html>"; then
    echo "✅ Deployment works!"
    
    # Set alias
    echo "🔗 Setting alias to elbatt-chatbot.vercel.app..."
    cd app
    vercel alias set "$LATEST_DEPLOY" elbatt-chatbot.vercel.app
    
    echo ""
    echo "✅ Alias updated! Testing..."
    sleep 3
    
    # Test alias
    curl -I https://elbatt-chatbot.vercel.app | grep HTTP
    
    echo ""
    echo "🌐 Opening site..."
    open https://elbatt-chatbot.vercel.app
else
    echo "⚠️  Deployment returned unexpected content"
    echo "$RESPONSE"
fi
