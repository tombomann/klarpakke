#!/bin/bash
set -euo pipefail

echo "🚀 KLARPAKKE SUPER DEPLOY - FULL AUTO"

# This script is meant to run locally.
# Do NOT use ${{ secrets.* }} here; that syntax only works in GitHub Actions.

# 1) Push local changes (optional)
if git diff --quiet && git diff --cached --quiet; then
  echo "No local changes to commit."
else
  git add .
  git commit -m "Auto-deploy" || true
fi

git push origin HEAD

# 2) Trigger 1-click deploy workflow on main
if command -v gh >/dev/null 2>&1; then
  gh workflow run klarpakke-deploy.yml --ref main --field target=staging
  echo "✅ Deploy triggered. Check: https://github.com/tombomann/klarpakke/actions"
else
  echo "❌ GitHub CLI (gh) not found. Install it, then run:"
  echo "   gh workflow run klarpakke-deploy.yml --ref main --field target=staging"
  exit 1
fi
