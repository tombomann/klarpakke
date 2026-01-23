#!/bin/bash
set -euo pipefail

# Fixed Makefile - Klarpakke Commands
.PHONY: help ai-test stripe-seed-usd stripe-verify-usd

help:
	@echo "🚀 Klarpakke Commands:"
	@echo "  make ai-test              # Run Perplexity healthcheck"
	@echo "  make stripe-seed-usd      # Create USD prices (TEST MODE FIRST)"
	@echo "  make stripe-verify-usd    # Verify USD prices exist"

ai-test:
	@echo "🧪 Running Perplexity healthcheck..."
	@bash scripts/perplexity_healthcheck.sh

stripe-seed-usd:
	@echo "💳 Seeding Stripe USD prices..."
	@bash scripts/stripe_seed_usd.sh

stripe-verify-usd:
	@echo "✅ Verifying Stripe USD prices..."
	@bash scripts/stripe_verify_usd.sh
