#!/usr/bin/env bash
set -euo pipefail
REPO_DIR="${REPO_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
APP_DIR="$REPO_DIR/app"
cd "$APP_DIR"
if [ -f package-lock.json ]; then npm ci; else npm install; fi
npm run build
if ! command -v vercel >/dev/null 2>&1; then
  echo "Install vercel CLI: npm i -g vercel" >&2
  exit 1
fi
if [ ! -f "$REPO_DIR/.vercel" ]; then vercel login || true; vercel link --yes || true; fi
vercel env pull .env.local || true
vercel --prod --yes --force --debug
