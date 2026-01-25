#!/usr/bin/env bash
set -euo pipefail

# Hvis du vil kjøre fra et annet sted, sett REPO_DIR før kjøring:
# REPO_DIR=/path/to/repo ./scripts/force-deploy-from-app.sh
REPO_DIR="${REPO_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
APP_DIR="$REPO_DIR/app"

echo "Working from $APP_DIR"

if [ ! -d "$APP_DIR" ]; then
  echo "ERROR: App-mappe ikke funnet: $APP_DIR"
  exit 1
fi

cd "$APP_DIR"

if [ -f package-lock.json ]; then
  echo "Installerer avhengigheter med npm ci"
  npm ci
else
  echo "Installerer avhengigheter med npm install"
  npm install
fi

echo "Kjører build"
npm run build

if ! command -v vercel >/dev/null 2>&1; then
  echo "Vercel CLI ikke funnet. Installer: npm i -g vercel"
  exit 1
fi

# Link prosjekt interaktivt første gang hvis nødvendig
if [ ! -f "$REPO_DIR/.vercel" ]; then
  echo "Linker prosjekt til Vercel. Følg eventuelle prompts..."
  vercel login || true
  vercel link --yes || true
fi

echo "Henter env fra Vercel (valgfritt)"
vercel env pull .env.local || true

echo "Triggerer force deploy fra app-mappe"
vercel --prod --yes --force --debug

echo "Deploy ferdig. Sjekk Vercel dashboard for detaljer."
