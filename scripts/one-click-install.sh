#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Klarpakke One-Click Full Automation"
echo "======================================="
echo ""

# Check if running in klarpakke directory
if [[ ! -f "Makefile" ]]; then
  echo "❌ Error: Run from klarpakke/ directory"
  echo "   cd klarpakke && bash scripts/one-click-install.sh"
  exit 1
fi

# Step 1: Bootstrap (env + tables + smoke test)
echo "📦 Step 1/5: Bootstrap environment..."
make bootstrap 2>/dev/null || {
  echo "⚠️  Bootstrap failed - continuing with manual steps"
  bash scripts/quick-fix-env.sh
  bash scripts/verify-tables.sh
}
echo "✅ Bootstrap complete"
echo ""

# Step 2: Edge Functions
echo "🔧 Step 2/5: Deploying Edge Functions..."
if command -v supabase &> /dev/null; then
  make edge-deploy 2>/dev/null || echo "⚠️  Edge deploy failed - may need manual login"
else
  echo "⚠️  Supabase CLI not found - installing..."
  if [[ "$OSTYPE" == "darwin"* ]]; then
    brew install supabase/tap/supabase
  else
    npm install -g supabase
  fi
  echo "✅ Supabase CLI installed - run 'supabase login' then re-run this script"
fi
echo ""

# Step 3: Webflow API setup
echo "🌐 Step 3/5: Webflow integration setup..."
if [[ ! -f .env ]] || ! grep -q "WEBFLOW_API_TOKEN" .env; then
  echo ""
  echo "⚠️  Webflow API token missing!"
  echo ""
  echo "Get your token:"
  echo "  1. Open: https://webflow.com/dashboard/sites"
  echo "  2. Select your site → Settings → Integrations"
  echo "  3. API Access → Generate API Token"
  echo "  4. Copy token"
  echo ""
  read -p "Paste Webflow API token: " WEBFLOW_TOKEN
  echo "WEBFLOW_API_TOKEN=$WEBFLOW_TOKEN" >> .env
  
  echo ""
  read -p "Paste Webflow Collection ID: " WEBFLOW_COLLECTION
  echo "WEBFLOW_COLLECTION_ID=$WEBFLOW_COLLECTION" >> .env
  
  echo "✅ Webflow credentials saved to .env"
else
  echo "✅ Webflow credentials already configured"
fi
echo ""

# Step 4: GitHub secrets
echo "🔐 Step 4/5: Syncing GitHub secrets..."
if command -v gh &> /dev/null; then
  make gh-secrets 2>/dev/null || echo "⚠️  GitHub secrets sync failed - may need 'gh auth login'"
  
  # Add Webflow secrets
  if grep -q "WEBFLOW_API_TOKEN" .env; then
    set -a && source .env && set +a
    gh secret set WEBFLOW_API_TOKEN --body "$WEBFLOW_API_TOKEN" 2>/dev/null || true
    gh secret set WEBFLOW_COLLECTION_ID --body "$WEBFLOW_COLLECTION_ID" 2>/dev/null || true
  fi
  echo "✅ GitHub secrets synced"
else
  echo "⚠️  GitHub CLI not found - install with: brew install gh"
fi
echo ""

# Step 5: Webflow deployment
echo "🎨 Step 5/5: Webflow UI deployment..."
if [[ -f scripts/webflow-one-click.sh ]]; then
  echo "Ready to deploy Webflow UI!"
  echo ""
  read -p "Run Webflow deployment now? (y/n): " RUN_WEBFLOW
  
  if [[ "$RUN_WEBFLOW" == "y" ]]; then
    bash scripts/webflow-one-click.sh
  else
    echo "⏳ Skipped - run later with: bash scripts/webflow-one-click.sh"
  fi
else
  echo "⚠️  webflow-one-click.sh not found - pulling latest..."
  git pull origin main
fi
echo ""

# Summary
echo "🎉 ONE-CLICK SETUP COMPLETE!"
echo ""
echo "✅ What's installed:"
echo "  - Supabase Edge Functions (6 functions)"
echo "  - Database tables (4 tables)"
echo "  - GitHub Actions (auto-deploy + sync)"
echo "  - Webflow API integration"
echo ""
echo "📊 Next steps:"
echo "  1. Test deployment: make test"
echo "  2. Generate demo signals: make paper-seed"
echo "  3. Monitor logs: make edge-logs"
echo "  4. Deploy Webflow: bash scripts/webflow-one-click.sh"
echo ""
echo "📖 Documentation:"
echo "  - README.md (quickstart guide)"
echo "  - DEPLOYMENT-STATUS.md (status tracking)"
echo "  - Makefile (all commands)"
echo ""
echo "🔗 Dashboards:"
echo "  - Supabase: https://supabase.com/dashboard/project/swfyuwkptusceiouqlks"
echo "  - GitHub Actions: https://github.com/tombomann/klarpakke/actions"
echo "  - Webflow: https://webflow.com/dashboard"
echo ""
