#!/bin/bash
set -euo pipefail

echo "🔍 Diagnosing Vercel 404 issue..."

# 1. Check deployment logs in browser
echo "1. Opening latest deployment logs..."
open "https://vercel.com/tom-jensens-projects/klarpakke"

echo ""
echo "2. Testing if build works locally..."
cd app
npm run build

if [ -d ".next" ]; then
    echo "✅ Local build successful!"
    echo ""
    echo "📂 Checking .next contents..."
    ls -la .next/ | head -20
else
    echo "❌ Build failed locally!"
fi

echo ""
echo "3. Test local dev server..."
echo "📋 I browser, check:"
echo "   - Build logs på Vercel"
echo "   - Er det errors?"
echo "   - Hva er output size?"
echo ""
read -p "Press Enter når du har sjekket logs..."

