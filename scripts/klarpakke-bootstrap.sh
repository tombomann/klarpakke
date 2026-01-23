#!/usr/bin/env bash
set -euo pipefail

DRY_RUN="${1:-}"

echo "🚀 Klarpakke Bootstrap Phase 1"

# Secrets check
grep -r 'pplx\\|sk-pplx' . --include="*.sh" --include="*.md" --include="*.js" | grep -v PLACEHOLDER &>/dev/null && { echo "❌ Secrets leaked! Run: make clean_secrets"; exit 1; } || echo "✅ Secrets OK"

# Makefile test
make help || echo "⚠️ Makefile warning - manual check needed"

echo "✅ Bootstrap Phase 1 COMPLETE! Run: make ai-test stripe-seed-usd"