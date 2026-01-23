# Klarpakke Bootstrap Script

set -euo pipefail

# Kjør: bash scripts/klarpakke-bootstrap.sh --dry-run

if [[ "$1" == "--dry-run" ]]; then
  echo "DRY-RUN: Validating plan..."
  grep -R 'pplx-' . && echo '❌ Secrets found' || echo '✅ No secrets leaked'
  make ai-test || echo '⚠️ AI test failed - fix PPLX_API_KEY'
  exit 0
fi

# Real run: generate files, validate
make stripe-seed-usd
make ai-test
grep -R 'sk_live' . && exit 1 || true

echo '✅ Bootstrap complete'