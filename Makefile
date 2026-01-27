# Klarpakke Makefile - Full Automation
.PHONY: help bootstrap deploy test

.DEFAULT_GOAL := help

# Load .env for all targets
-include .env
export

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-25s\033[0m %s\n", $$1, $$2}'

bootstrap: ## Complete setup from scratch
	@echo "🚀 Klarpakke Full Automation Setup"
	@echo "==================================="
	@bash scripts/quick-fix-env.sh
	@bash scripts/verify-tables.sh
	@bash scripts/smoke-test.sh
	@echo ""
	@echo "✅ Bootstrap complete!"
	@echo ""
	@echo "Next: Deploy Edge Functions"
	@echo "  make edge-deploy"

# Edge Functions
edge-install: ## Install Supabase CLI
	@echo "📦 Installing Supabase CLI..."
	@brew install supabase/tap/supabase || npm install -g supabase
	@echo "✅ Supabase CLI installed"

edge-login: ## Login to Supabase
	@supabase login

edge-deploy: ## Deploy Edge Functions
	@bash scripts/deploy-edge-functions.sh

edge-secrets: ## Setup Edge Function secrets (PERPLEXITY_API_KEY only, Supabase vars auto-injected)
	@bash scripts/setup-secrets.sh

edge-test: ## Test Edge Functions
	@echo "🧪 Testing Edge Functions..."
	@echo ""
	@echo "1. Testing generate-trading-signal..."
	@curl -X POST "$$SUPABASE_URL/functions/v1/generate-trading-signal" \
	  -H "Authorization: Bearer $$SUPABASE_ANON_KEY" \
	  -H "Content-Type: application/json" || echo "Failed - check .env"
	@echo ""
	@echo "2. Testing update-positions..."
	@curl -X POST "$$SUPABASE_URL/functions/v1/update-positions" \
	  -H "Authorization: Bearer $$SUPABASE_ANON_KEY" \
	  -H "Content-Type: application/json" || echo "Failed - check .env"

edge-logs: ## View Edge Function logs
	@echo "Opening Supabase Dashboard..."
	@open "https://supabase.com/dashboard/project/swfyuwkptusceiouqlks/functions"

edge-full: edge-deploy edge-secrets ## Deploy + setup secrets
	@echo ""
	@echo "🎉 Edge Functions deployed!"
	@echo ""
	@echo "View functions:"
	@echo "  https://supabase.com/dashboard/project/swfyuwkptusceiouqlks/functions"
	@echo ""
	@echo "Test manually:"
	@echo "  make edge-test-live"

edge-test-live: ## Test Edge Functions (requires .env)
	@bash scripts/test-edge-functions.sh

# GitHub Actions
gh-secrets: ## Setup GitHub secrets for Actions
	@echo "🔐 Setting GitHub secrets..."
	@set -a && test -f .env && source .env && set +a && \
	gh secret set SUPABASE_URL --body "$$SUPABASE_URL" && \
	gh secret set SUPABASE_ANON_KEY --body "$$SUPABASE_ANON_KEY" && \
	gh secret set SUPABASE_SECRET_KEY --body "$$SUPABASE_SECRET_KEY"
	@echo "✅ GitHub secrets set"

gh-sync-secrets: ## Sync GitHub secrets to Supabase Edge (via Actions)
	@echo "🔄 Triggering Supabase secrets sync workflow..."
	@gh workflow run supabase-sync-secrets.yml
	@echo "✅ Workflow triggered! Monitor at:"
	@echo "  https://github.com/tombomann/klarpakke/actions/workflows/supabase-sync-secrets.yml"

gh-test: ## Trigger GitHub Actions manually
	@gh workflow run scheduled-tasks.yml
	@echo "✅ Workflow triggered! Check:"
	@echo "  https://github.com/tombomann/klarpakke/actions"

# Testing
test: ## Run all tests
	@bash scripts/verify-tables.sh
	@bash scripts/smoke-test.sh

smoke: ## Run smoke tests
	@bash scripts/smoke-test.sh

status: ## Show system status
	@echo "=== Klarpakke Status ==="
	@test -f .env && echo "✅ .env exists" || echo "❌ .env missing"
	@bash scripts/verify-tables.sh 2>/dev/null | grep -E '✅|❌' || echo "⚠️ Unable to check DB"

# Demo/Papertrading
paper-seed: ## Seed demo signals for papertrading
	@set -a && test -f .env && source .env && set +a && bash scripts/paper-seed.sh

webflow-export: ## Export pending signals to CSV for Webflow CMS import
	@set -a && test -f .env && source .env && set +a && bash scripts/webflow-export-csv.sh

# Make.com (requires .env.migration with MAKE_API_TOKEN + MAKE_TEAM_ID)
make-import: ## Import Make.com blueprints (needs .env.migration)
	@bash scripts/import-now.sh

# Quick commands
auto: edge-full gh-secrets ## Full automation setup
	@echo ""
	@echo "🎉 FULL AUTOMATION DEPLOYED!"
	@echo ""
	@echo "What's running:"
	@echo "  ✅ Edge Functions (serverless)"
	@echo "  ✅ GitHub Actions (scheduled)"
	@echo ""
	@echo "Next steps:"
	@echo "  1. Test functions: make edge-test-live"
	@echo "  2. View logs: make edge-logs"
	@echo "  3. Trigger workflow: make gh-test"
	@echo ""
	@echo "Dashboard:"
	@echo "  https://supabase.com/dashboard/project/swfyuwkptusceiouqlks/functions"
