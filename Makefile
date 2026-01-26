# Klarpakke Makefile - Full Automation
.PHONY: help bootstrap deploy test

.DEFAULT_GOAL := help

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

edge-secrets: ## Setup secrets (PERPLEXITY_API_KEY)
	@bash scripts/setup-secrets.sh

edge-test: ## Test Edge Functions locally
	@supabase functions invoke generate-trading-signal --project-ref swfyuwkptusceiouqlks

edge-logs: ## View Edge Function logs
	@supabase functions logs generate-trading-signal --project-ref swfyuwkptusceiouqlks

edge-full: edge-deploy edge-secrets edge-test ## Deploy + setup secrets + test

# GitHub Actions
gh-secrets: ## Setup GitHub secrets for Actions
	@echo "Setting GitHub secrets..."
	@gh secret set SUPABASE_URL < .env
	@gh secret set SUPABASE_ANON_KEY < .env
	@echo "✅ GitHub secrets set"

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

# Quick commands
auto: edge-full gh-secrets ## Full automation setup
	@echo ""
	@echo "🎉 FULL AUTOMATION DEPLOYED!"
	@echo ""
	@echo "What's running:"
	@echo "  ✅ Edge Functions (serverless)"
	@echo "  ✅ GitHub Actions (scheduled)"
	@echo ""
	@echo "Manual trigger:"
	@echo "  gh workflow run scheduled-tasks.yml"
