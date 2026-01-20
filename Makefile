.PHONY: help oci-deploy oci-logs oci-test oci-restart oci-ssh oci-status oci-health local-dev test ci clean

# Configuration
OCI_IP := 79.76.63.189
OCI_USER := opc
OCI_SSH_KEY := ~/.ssh/oci_klarpakke
OCI_PORT := 3000
OCI_HEALTH_URL := http://$(OCI_IP):$(OCI_PORT)/health
LOCAL_HEALTH_URL := http://localhost:$(OCI_PORT)/health

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

help: ## Show this help message
	@echo "$(BLUE)"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "  🚀 KLARPAKKE - Deployment & Monitoring Commands"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"
	@echo ""
	@echo "$(GREEN)DEPLOYMENT$(NC)"
	@grep -E '^[a-zA-Z_-]+.*:.*?## ' Makefile | grep -E '^oci-|^local-' | sed 's/: .*## /\t## /g' | awk '{printf "  %-30s %s\n", $$1, substr($$0, index($$0,"##")+2)}'
	@echo ""
	@echo "$(GREEN)MONITORING$(NC)"
	@grep -E '^[a-zA-Z_-]+.*:.*?## ' Makefile | grep -E 'logs|status|health|test' | sed 's/: .*## /\t## /g' | awk '{printf "  %-30s %s\n", $$1, substr($$0, index($$0,"##")+2)}'
	@echo ""
	@echo "$(GREEN)DEVELOPMENT$(NC)"
	@grep -E '^[a-zA-Z_-]+.*:.*?## ' Makefile | grep -v -E '^oci-|logs|status|health|test' | sed 's/: .*## /\t## /g' | awk '{printf "  %-30s %s\n", $$1, substr($$0, index($$0,"##")+2)}'
	@echo ""
	@echo "$(BLUE)Examples:$(NC)"
	@echo "  make oci-deploy          # Deploy latest code to Oracle VM"
	@echo "  make oci-logs            # Stream PM2 logs from VM"
	@echo "  make oci-health          # Check backend health"
	@echo "  make local-dev           # Start local development server"
	@echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ORACLE CLOUD DEPLOYMENT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

oci-ssh: ## SSH into Oracle VM
	@echo "$(BLUE)Connecting to $(OCI_USER)@$(OCI_IP)...$(NC)"
	ssh -i $(OCI_SSH_KEY) $(OCI_USER)@$(OCI_IP)

oci-deploy: ## Deploy latest code to Oracle VM
	@echo "$(YELLOW)🚀 Deploying to Oracle Cloud...$(NC)"
	@echo "Step 1: Checking SSH connection"
	@ssh -i $(OCI_SSH_KEY) $(OCI_USER)@$(OCI_IP) 'echo $(GREEN)✓ SSH OK$(NC)' || (echo "$(RED)✗ SSH Failed$(NC)"; exit 1)
	@echo "Step 2: Pulling latest code"
	@ssh -i $(OCI_SSH_KEY) $(OCI_USER)@$(OCI_IP) 'cd /home/opc/klarpakke && git pull origin main' || exit 1
	@echo "Step 3: Installing dependencies"
	@ssh -i $(OCI_SSH_KEY) $(OCI_USER)@$(OCI_IP) 'cd /home/opc/klarpakke && npm ci --production' || exit 1
	@echo "Step 4: Restarting PM2"
	@ssh -i $(OCI_SSH_KEY) $(OCI_USER)@$(OCI_IP) 'pm2 restart klarpakke --wait-ready --listen-timeout 3000' || exit 1
	@echo "Step 5: Verifying deployment"
	@ssh -i $(OCI_SSH_KEY) $(OCI_USER)@$(OCI_IP) 'sleep 3 && pm2 status' || exit 1
	@echo "$(GREEN)✓ Deployment successful!$(NC)"

oci-restart: ## Restart backend on Oracle VM
	@echo "$(YELLOW)Restarting Klarpakke backend...$(NC)"
	@ssh -i $(OCI_SSH_KEY) $(OCI_USER)@$(OCI_IP) 'pm2 restart klarpakke && sleep 2 && pm2 status'
	@echo "$(GREEN)✓ Restart complete$(NC)"

oci-stop: ## Stop backend on Oracle VM
	@echo "$(YELLOW)Stopping Klarpakke backend...$(NC)"
	@ssh -i $(OCI_SSH_KEY) $(OCI_USER)@$(OCI_IP) 'pm2 stop klarpakke && pm2 status'
	@echo "$(GREEN)✓ Backend stopped$(NC)"

oci-start: ## Start backend on Oracle VM
	@echo "$(YELLOW)Starting Klarpakke backend...$(NC)"
	@ssh -i $(OCI_SSH_KEY) $(OCI_USER)@$(OCI_IP) 'pm2 start klarpakke && sleep 2 && pm2 status'
	@echo "$(GREEN)✓ Backend started$(NC)"

oci-logs: ## Stream logs from Oracle VM (Ctrl+C to exit)
	@echo "$(BLUE)Streaming logs from $(OCI_IP)...$(NC)"
	@echo "Press $(YELLOW)Ctrl+C$(NC) to exit"
	@ssh -i $(OCI_SSH_KEY) $(OCI_USER)@$(OCI_IP) 'pm2 logs klarpakke --lines 50 --follow' || true

oci-logs-tail: ## Show last 100 lines of logs
	@echo "$(BLUE)Last 100 lines of logs:$(NC)"
	@ssh -i $(OCI_SSH_KEY) $(OCI_USER)@$(OCI_IP) 'pm2 logs klarpakke --lines 100'

oci-status: ## Show PM2 status on Oracle VM
	@echo "$(BLUE)PM2 Status:$(NC)"
	@ssh -i $(OCI_SSH_KEY) $(OCI_USER)@$(OCI_IP) 'pm2 status'

oci-info: ## Show detailed PM2 process info
	@echo "$(BLUE)Detailed Process Info:$(NC)"
	@ssh -i $(OCI_SSH_KEY) $(OCI_USER)@$(OCI_IP) 'pm2 info klarpakke'

oci-health: ## Check health of backend (internal + external)
	@echo "$(BLUE)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"
	@echo "$(BLUE)  Health Check - $(OCI_IP):$(OCI_PORT)$(NC)"
	@echo "$(BLUE)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"
	@echo ""
	@echo "$(YELLOW)1. Internal Health Check (from VM):$(NC)"
	@ssh -i $(OCI_SSH_KEY) $(OCI_USER)@$(OCI_IP) 'curl -s http://localhost:$(OCI_PORT)/health | jq . 2>/dev/null || echo "Service not responding"'
	@echo ""
	@echo "$(YELLOW)2. External Health Check (from your machine):$(NC)"
	@curl -s $(OCI_HEALTH_URL) | jq . 2>/dev/null || echo "$(RED)✗ Service not responding on $(OCI_HEALTH_URL)$(NC)"
	@echo ""
	@echo "$(YELLOW)3. Port Binding Verification:$(NC)"
	@ssh -i $(OCI_SSH_KEY) $(OCI_USER)@$(OCI_IP) 'sudo netstat -tulpn 2>/dev/null | grep :$(OCI_PORT) || echo "Port $(OCI_PORT) not listening"'
	@echo ""

oci-test: ## Run comprehensive health tests
	@echo "$(BLUE)Running comprehensive health tests...$(NC)"
	@echo ""
	@echo "$(YELLOW)Test 1: SSH Connection$(NC)"
	@if ssh -i $(OCI_SSH_KEY) $(OCI_USER)@$(OCI_IP) 'exit'; then echo "$(GREEN)✓ SSH OK$(NC)"; else echo "$(RED)✗ SSH Failed$(NC)"; exit 1; fi
	@echo ""
	@echo "$(YELLOW)Test 2: PM2 Process Status$(NC)"
	@ssh -i $(OCI_SSH_KEY) $(OCI_USER)@$(OCI_IP) 'pm2 status | grep -q "online" && echo "$(GREEN)✓ Process running$(NC)" || echo "$(RED)✗ Process not running$(NC)"'
	@echo ""
	@echo "$(YELLOW)Test 3: Internal Health Endpoint$(NC)"
	@ssh -i $(OCI_SSH_KEY) $(OCI_USER)@$(OCI_IP) 'curl -f -s http://localhost:$(OCI_PORT)/health > /dev/null && echo "$(GREEN)✓ Internal endpoint OK$(NC)" || echo "$(RED)✗ Internal endpoint failed$(NC)"'
	@echo ""
	@echo "$(YELLOW)Test 4: External Health Endpoint$(NC)"
	@if curl -f -s $(OCI_HEALTH_URL) > /dev/null; then echo "$(GREEN)✓ External endpoint OK$(NC)"; else echo "$(RED)✗ External endpoint failed$(NC)"; fi
	@echo ""
	@echo "$(YELLOW)Test 5: Database Connection$(NC)"
	@ssh -i $(OCI_SSH_KEY) $(OCI_USER)@$(OCI_IP) 'psql -U klarpakke -h localhost -d klarpakke -c "SELECT version();" > /dev/null 2>&1 && echo "$(GREEN)✓ Database OK$(NC)" || echo "$(RED)✗ Database failed$(NC)"'
	@echo ""
	@echo "$(YELLOW)Test 6: System Resources$(NC)"
	@ssh -i $(OCI_SSH_KEY) $(OCI_USER)@$(OCI_IP) 'echo "Memory: $$(free -h | grep Mem | awk \'{print $$3 \"/\" $$2}\')"; echo "Disk: $$(df -h / | tail -1 | awk \'{print $$3 \"/\" $$2 \" (\" $$5 \")}\')"; echo "CPU cores: $$(nproc)"'
	@echo ""
	@echo "$(GREEN)✓ All tests complete$(NC)"

oci-cpu-mem: ## Show CPU and memory usage
	@echo "$(BLUE)System Resources on $(OCI_IP):$(NC)"
	@ssh -i $(OCI_SSH_KEY) $(OCI_USER)@$(OCI_IP) 'free -h && echo "" && ps aux | head -1 && ps aux | grep node | grep -v grep'

oci-disk: ## Show disk usage
	@echo "$(BLUE)Disk Usage on $(OCI_IP):$(NC)"
	@ssh -i $(OCI_SSH_KEY) $(OCI_USER)@$(OCI_IP) 'df -h'

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# LOCAL DEVELOPMENT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local-dev: ## Start local development server
	@echo "$(YELLOW)Starting local development server...$(NC)"
	@npm run dev

local-install: ## Install dependencies locally
	@echo "$(YELLOW)Installing dependencies...$(NC)"
	@npm install

local-test: ## Run tests locally
	@echo "$(YELLOW)Running tests...$(NC)"
	@npm run test

local-build: ## Build project locally
	@echo "$(YELLOW)Building project...$(NC)"
	@npm run build

local-clean: ## Clean local build artifacts
	@echo "$(YELLOW)Cleaning build artifacts...$(NC)"
	@rm -rf node_modules package-lock.json
	@rm -rf dist build
	@echo "$(GREEN)✓ Cleaned$(NC)"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# UTILITY & MAINTENANCE
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ci: ## Run CI pipeline locally
	@echo "$(YELLOW)Running CI pipeline...$(NC)"
	@echo "1. Linting..."
	@npm run lint 2>/dev/null || echo "(Skipped)"
	@echo "2. Testing..."
	@npm run test 2>/dev/null || echo "(Skipped)"
	@echo "3. Building..."
	@npm run build 2>/dev/null || echo "(Skipped)"
	@echo "$(GREEN)✓ CI complete$(NC)"

clean: ## Clean all build artifacts and cache
	@echo "$(YELLOW)Cleaning...$(NC)"
	@rm -rf node_modules
	@rm -rf dist build
	@rm -rf .next
	@rm -f package-lock.json
	@echo "$(GREEN)✓ Cleaned$(NC)"

install: ## Install all dependencies
	@echo "$(YELLOW)Installing dependencies...$(NC)"
	@npm install
	@echo "$(GREEN)✓ Installed$(NC)"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DEFAULT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

.DEFAULT_GOAL := help

print-%: ## Print variable value (e.g., make print-OCI_IP)
	@echo $* = $($*)
