.PHONY: help ai-test ai-health stripe-seed-usd stripe-verify-usd docs-ai

help:
	@echo "Klarpakke Automation Commands"
	@echo ""
	@echo "AI Commands:"
	@echo "  make ai-test     Run Perplexity healthcheck"
	@echo "  make ai-health   Alias for ai-test"
	@echo ""
	@echo "Stripe Commands (TEST MODE FIRST!):"
	@echo "  make stripe-seed-usd     Create USD prices (Free, Pro, Elite)"
	@echo "  make stripe-verify-usd   Verify USD prices exist"
	@echo ""
	@echo "Documentation:"
	@echo "  make docs-ai    Generate AI context docs"

ai-test:
	@echo "Running Perplexity healthcheck..."
	bash scripts/perplexityhealthcheck.sh

ai-health: ai-test

stripe-seed-usd:
	@echo "Seeding Stripe USD prices (TEST MODE)..."
	bash scripts/stripeseedusd.sh

stripe-verify-usd:
	@echo "Verifying Stripe USD prices..."
	bash scripts/stripeverifyusd.sh

docs-ai:
	@echo "Generating AI documentation..."
	@echo "Docs available in docs/ai/"
bubble-log:
	psql $$DATABASE_URL -c "INSERT INTO AICallLog (pair, signal) VALUES (\"BTCUSD\", \"test\");"
