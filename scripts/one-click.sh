#!/usr/bin/env bash
set -euo pipefail

# Klarpakke One-Click (local dev)
# - Starts local Supabase stack
# - Resets DB (runs migrations)
# - Optionally seeds demo data

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [[ -f .env ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi

if ! command -v supabase >/dev/null 2>&1; then
  echo "[one-click] ERROR: supabase CLI not found. Install it first (see docs/ONE-CLICK-DEPLOY.md)." >&2
  exit 1
fi

echo "[one-click] Starting local Supabase…"
supabase start

echo "[one-click] Resetting local database (migrations)…"
supabase db reset

if [[ -x scripts/paper-seed.sh ]]; then
  echo "[one-click] Seeding demo data…"
  bash scripts/paper-seed.sh || echo "[one-click] WARN: paper-seed failed (continuing)."
fi

echo "[one-click] Done. Local Supabase should be ready."