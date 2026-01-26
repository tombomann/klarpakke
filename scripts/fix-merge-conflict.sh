#!/bin/bash
# Fix merge conflicts - safe pull latest changes
set -euo pipefail

echo "🔧 Fixing merge conflict..."
echo ""

# Check if we have uncommitted changes
if ! git diff-index --quiet HEAD --; then
  echo "📦 Stashing local changes..."
  git stash push -m "Auto-stash before pull $(date +%Y%m%d-%H%M%S)"
  echo "✅ Changes stashed"
  echo ""
fi

echo "⬇️  Pulling latest from main..."
git pull origin main
echo "✅ Pull complete"
echo ""

echo "📋 To restore your stashed changes later:"
echo "   git stash list"
echo "   git stash pop"
echo ""
echo "✅ Ready! Run: make help"
