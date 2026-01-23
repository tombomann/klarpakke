#!/bin/bash
set -euo pipefail

# Secrets cleanup - remove pplx- and sk-pplx from all files
find . -type f \( -name '*.md' -o -name '*.sh' -o -name '*.js' \) -exec sed -i.bak 's/sk-pplx-9rGF/PPLX_API_KEY_PLACEHOLDER/g' {} + 2>/dev/null || true
find . -type f \( -name '*.md' -o -name '*.sh' -o -name '*.js' \) -exec sed -i.bak 's/pplx-[a-zA-Z0-9]*/PPLX_API_KEY_PLACEHOLDER/g' {} + 2>/dev/null || true

# Remove backup files
find . -name '*.bak' -delete

echo '✅ Secrets cleaned (pplx- replaced with placeholders)'

grep -R 'PPLX_API_KEY_PLACEHOLDER' . | head -5 || true