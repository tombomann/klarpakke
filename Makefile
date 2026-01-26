# Klarpakke Makefile - Automation-first DevSecOps
# Usage: make <target>

.PHONY: help bootstrap deploy test kpi clean verify

# Colors
GREEN  := \033[0;32m
YELLOW := \033[0;33m
RED    := \033[0;31m
NC     := \033[0m # No Color

# Default target
.DEFAULT_GOAL := help

help: ## Show this help message
	@echo "${GREEN}Klarpakke Makefile${NC}"
	@echo "${YELLOW}Available targets:${NC}"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  ${GREEN}%-20s${NC} %s\n", $$1, $$2}'

bootstrap: ## Complete setup from scratch (env + deploy + test)
	@echo "${GREEN}[1/4] Setting up environment...${NC}"
	@bash scripts/quick-fix-env.sh
	@echo "${GREEN}[2/4] Deploying database schema...${NC}"
	@bash scripts/auto-deploy-sql.sh || echo "${YELLOW}Manual deploy needed - see DEPLOY-STEP-BY-STEP.md${NC}"
	@echo "${GREEN}[3/4] Verifying tables...${NC}"
	@bash scripts/verify-tables.sh
	@echo "${GREEN}[4/4] Running smoke tests...${NC}"
	@bash scripts/smoke-test.sh
	@echo "${GREEN}✅ Bootstrap complete!${NC}"

deploy: ## Deploy database schema to Supabase
	@echo "${GREEN}Deploying schema...${NC}"
	@bash scripts/auto-deploy-sql.sh || (echo "${RED}Auto-deploy failed. Manual steps:${NC}" && cat DEPLOY-STEP-BY-STEP.md)

test: verify smoke ## Run all tests (verify + smoke)

verify: ## Verify API endpoints exist
	@echo "${GREEN}Verifying database tables...${NC}"
	@bash scripts/verify-tables.sh

smoke: ## Run smoke tests
	@echo "${GREEN}Running smoke tests...${NC}"
	@bash scripts/smoke-test.sh

kpi: ## Export KPIs (last 30 days)
	@echo "${GREEN}Exporting KPIs...${NC}"
	@bash scripts/export-kpis.sh 30

kpi-90: ## Export KPIs (last 90 days)
	@bash scripts/export-kpis.sh 90

clean: ## Clean generated files (backups, logs)
	@echo "${YELLOW}Cleaning temporary files...${NC}"
	@rm -f *.backup.sql
	@rm -f *.log
	@echo "${GREEN}✅ Clean complete${NC}"

status: ## Show current system status
	@echo "${GREEN}=== Klarpakke Status ===${NC}"
	@echo "${YELLOW}Environment:${NC}"
	@test -f .env && echo "  ✅ .env exists" || echo "  ❌ .env missing"
	@echo "${YELLOW}Database:${NC}"
	@bash scripts/verify-tables.sh 2>/dev/null | grep -E '✅|❌' || echo "  ⚠️  Unable to check"
	@echo "${YELLOW}Last deployment:${NC}"
	@git log -1 --format="  %h - %s (%ar)" -- DEPLOY-NOW.sql 2>/dev/null || echo "  No deployment history"

watch: ## Watch for changes and auto-test (requires fswatch)
	@command -v fswatch >/dev/null 2>&1 || (echo "${RED}fswatch not installed. Run: brew install fswatch${NC}" && exit 1)
	@echo "${GREEN}Watching for changes...${NC}"
	@fswatch -o scripts/ DEPLOY-NOW.sql | xargs -n1 -I{} make test

# Development shortcuts
dev: bootstrap ## Alias for bootstrap

ci: test ## Run CI pipeline (verify + smoke)
	@echo "${GREEN}✅ CI passed!${NC}"

# Make.com helpers
make-setup: ## Generate Make.com environment variables file
	@bash scripts/setup-make-env.sh

make-check: ## Verify Make.com environment is ready
	@bash scripts/check-make-ready.sh

make-ready: make-setup make-check ## Setup and verify Make.com environment

make-import: ## Show instructions for importing Make.com scenarios
	@echo "${GREEN}=== Make.com Import Instructions ===${NC}"
	@echo "${YELLOW}1. Verify readiness: make make-check${NC}"
	@echo "${YELLOW}2. Go to: https://www.make.com/en/scenarios${NC}"
	@echo "${YELLOW}3. Click 'Create a new scenario'${NC}"
	@echo "${YELLOW}4. Click '...' → 'Import Blueprint'${NC}"
	@echo "${YELLOW}5. Upload: make/scenarios/01-trading-signal-generator.json${NC}"
	@echo ""
	@echo "${GREEN}Available scenarios:${NC}"
	@ls -1 make/scenarios/*.json 2>/dev/null | sed 's|make/scenarios/||' | sed 's|^|  - |' || echo "  No scenarios found"
	@echo ""
	@echo "${YELLOW}6. Configure environment variables in Make.com:${NC}"
	@echo "   Copy from: make/.env.make"
	@echo ""
	@echo "${RED}Run 'make make-check' first to verify setup!${NC}"

make-config: make-setup ## Alias for make-setup

make-auto: ## Attempt auto-configuration (requires Make.com API token)
	@bash scripts/auto-configure-make.sh

# Database helpers
db-backup: ## Backup current database schema
	@echo "${GREEN}Creating backup...${NC}"
	@cp DEPLOY-NOW.sql DEPLOY-NOW.backup-$$(date +%Y%m%d-%H%M%S).sql
	@echo "${GREEN}✅ Backup created${NC}"

db-logs: ## Show recent database activity (requires Supabase CLI)
	@command -v supabase >/dev/null 2>&1 || (echo "${RED}Supabase CLI not installed${NC}" && exit 1)
	@supabase logs --project-ref swfyuwkptusceiouqlks --limit 20

# Documentation
docs: ## Open key documentation
	@echo "${GREEN}Opening documentation...${NC}"
	@open "https://github.com/tombomann/klarpakke/blob/main/README.md" || cat README.md

quickstart: ## Show quickstart guide
	@cat DEPLOY-STEP-BY-STEP.md

make-guide: ## Show Make.com setup guide
	@cat .github/MAKE_IMPORT_GUIDE.md
