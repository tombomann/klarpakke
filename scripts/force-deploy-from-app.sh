#!/usr/bin/env bash
set -euo pipefail
REPO_DIR="\$HOME/klarpakke"
APP_DIR="\$REPO_DIR/app"

echo "Working from \$APP_DIR"
cd "\$APP_DIR"

# Ensure dependencies
if [ -f package-lock.json ]; then
  npm ci
else
  npm install
fi

# Link project to Vercel if not linked
if [ ! -f "\$REPO_DIR/.vercel" ]; then
  echo "Linking project to Vercel. Follow prompts if any."
  vercel login || true
  vercel link --yes || true
fi

# Pull env vars from Vercel and update .env.local
vercel env pull .env.local development || true

# Force deploy from app folder
vercel --prod --yes --force --debug

echo "Deploy command finished. Check Vercel dashboard for logs."
