#!/bin/bash
set -euo pipefail

echo "🔧 Force deploying from /app folder..."

cd app

# Unlink fra feil project hvis det er linket
vercel unlink --yes 2>/dev/null || true

# Link til riktig project
echo "🔗 Linking to project..."
vercel link --project=klarpakke --yes

# Deploy
echo "🚀 Deploying from app folder..."
vercel --prod --yes --force

echo ""
echo "✅ Deployment triggered!"
echo "⏳ Venter 30 sekunder..."
sleep 30

# Test
echo "🧪 Testing..."
RESULT=$(curl -s https://klarpakke.vercel.app | head -20)

if [[ "$RESULT" == *"html"* ]]; then
    echo "✅ SUCCESS!"
    open https://klarpakke.vercel.app
else
    echo "❌ Still 404:"
    echo "$RESULT"
    echo ""
    echo "📖 Opening dashboard..."
    open "https://vercel.com/tom-jensens-projects/klarpakke"
fi
