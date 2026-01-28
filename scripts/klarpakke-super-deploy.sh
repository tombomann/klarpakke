#!/bin/bash
echo "🚀 KLARPAKKE SUPER DEPLOY - FULL AUTO"

# 1. Push lokale changes
git add .
git commit -m "Auto-deploy Webflow DOM fix" || true
git push origin main

# 2. Trigger Webflow builder
curl -X POST \
  -H "Authorization: token \${{ secrets.GITHUB_TOKEN }}" \
  https://api.github.com/repos/tombomann/klarpakke/actions/workflows/webflow-builder.yml/dispatches \
  -d '{"ref":"main"}'

echo "✅ Deploy started! Check: https://github.com/tombomann/klarpakke/actions"
echo "🧪 Live: https://klarpakke-c65071.webflow.io/app/dashboard"
