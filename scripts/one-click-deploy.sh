#!/bin/bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "🚀 ONE-CLICK DEPLOY (Fixed)"

cd /Users/taj/klarpakke

# Fix artifacts first
find .github/workflows -name "*.yml" -exec sed -i '' 's/upload-artifact@v3/upload-artifact@v4/g' {} + 2>/dev/null || true

# Commit fixes
git add -A 2>/dev/null || true
git commit -m "fix: one-click deploy artifacts + scripts [skip ci]" || true
git push origin main || true

# Trigger workflows
echo "🔄 Triggering 5 workflows..."
gh workflow run deploy-complete.yml --repo tombomann/klarpakke &
gh workflow run auto-cleanup.yml --repo tombomann/klarpakke &
gh workflow run ai-healthcheck.yml --repo tombomann/klarpakke &
gh workflow run webflow-deploy.yml --repo tombomann/klarpakke &
gh workflow run one-click-deploy.yml --repo tombomann/klarpakke &

wait

sleep 10
echo ""
echo "📊 Status:"
gh run list --repo tombomann/klarpakke --limit 10

echo ""
echo -e "${GREEN}✅ ONE-CLICK COMPLETE!${NC}"
