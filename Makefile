.PHONY: help ai-test stripe-seed-usd
help:
	@echo "🚀 Klarpakke Commands: make ai-test, make stripe-seed-usd"
ai-test:
	@bash scripts/perplexity_healthcheck.sh
stripe-seed-usd:
	@bash scripts/stripe_seed_usd.sh
