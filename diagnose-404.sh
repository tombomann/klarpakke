#!/bin/bash
set -euo pipefail

echo "🔍 Diagnosing 404 issue..."

# Test latest deployment
LATEST="klarpakke-psv7mi7jn-tom-jensens-projects.vercel.app"

echo "1. Testing deployment URL..."
curl -I "https://$LATEST" 2>&1 | grep -E "HTTP|Location|x-vercel"

echo ""
echo "2. Testing with curl verbose..."
curl -v "https://$LATEST" 2>&1 | head -30

echo ""
echo "3. Checking if it's a routing issue..."
curl "https://$LATEST/index.html" 2>&1 | head -10

echo ""
echo "4. Opening deployment logs..."
open "https://vercel.com/tom-jensens-projects/klarpakke/78njmsi3iZPqda3ahdnEMq6PaZGN"

echo ""
echo "📋 Diagnosis complete. Check browser for build logs."
