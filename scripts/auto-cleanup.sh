#!/bin/bash
set -euo pipefail

echo "🧹 Klarpakke Auto-Cleanup Starting..."

# 1️⃣ Navigate to repo
REPO_DIR="/Users/taj/klarpakke"
cd "$REPO_DIR" || {
  echo "❌ Repo not found at $REPO_DIR"
  exit 1
}

# 2️⃣ Auto-add generated files
echo "📦 Adding generated artifacts..."
git add -A ai-sample.json stripe_usd_prices.env 2>/dev/null || echo "⚠️  No new artifacts"

# 3️⃣ Commit if changes
if ! git diff --cached --quiet; then
  git commit -m "chore: auto-cleanup generated artifacts [skip ci]" || echo "⚠️  No changes to commit"
  echo "📤 Pushing to origin main..."
  git push origin main || echo "⚠️  Already up to date"
else
  echo "✅ No changes to commit"
fi

# 4️⃣ Status check
echo ""
echo "📊 Workflow Status:"
gh run list --repo tombomann/klarpakke --limit 10

echo ""
echo "🔧 All Workflows:"
gh workflow list --repo tombomann/klarpakke

# 5️⃣ Open dashboard
echo ""
echo "🌐 Opening GitHub Actions dashboard..."
open "https://github.com/tombomann/klarpakke/actions"

echo ""
echo "✅ Auto-cleanup complete!"
