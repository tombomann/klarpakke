#!/bin/bash
set -euo pipefail

# Updated bootstrap with secrets cleanup
DRY_RUN=${1:---dry-run}

if [[ "$DRY_RUN" == "--dry-run" ]]; then
  echo "DRY-RUN: Validating plan..."
  # Clean first (ignore errors)
  bash scripts/clean_secrets.sh || true
  grep -R 'pplx-' . && echo '❌ Secrets found (after cleanup)' || echo '✅ No secrets leaked'
  make ai-test || echo '⚠️ AI test failed - fix PPLX_API_KEY'
  exit 0
fi

# Real run
bash scripts/clean_secrets.sh
make stripe-seed-usd
make ai-test
grep -R 'sk_live' . && exit 1 || true

echo '✅ Bootstrap complete'
