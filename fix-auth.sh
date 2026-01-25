#!/bin/bash
echo "🔧 Opening Vercel settings..."
open "https://vercel.com/tom-jensens-projects/klarpakke/settings/deployment-protection"

echo ""
echo "⚠️  INSTRUKSJONER:"
echo "1. Klikk på BLÅ toggle ved 'Vercel Authentication' (skal bli grå)"
echo "2. Eller endre dropdown til 'Only Preview Deployments'"
echo "3. Scroll ned og klikk Save hvis det finnes"
echo ""
echo "⏳ Venter 10 sekunder mens du gjør endringen..."
sleep 10

echo "🧪 Testing..."
curl -I https://elbatt-chatbot.vercel.app | grep -E "HTTP|Location"

echo ""
echo "✅ Hvis du ser HTTP/2 200, kjør:"
echo "   open https://elbatt-chatbot.vercel.app"
