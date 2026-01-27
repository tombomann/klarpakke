#!/usr/bin/env bash
set -euo pipefail

# Deploy Supabase backend (remote): migrations + secrets + edge functions + basic verify

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

# Load .env if present (local usage). In CI, prefer environment variables.
if [[ -f .env ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi

if ! command -v supabase >/dev/null 2>&1; then
  echo "[deploy-backend] ERROR: supabase CLI not found." >&2
  exit 1
fi

PROJECT_REF="${SUPABASE_PROJECT_REF:-${SUPABASE_PROJECT_ID:-}}"
if [[ -z "${PROJECT_REF}" ]]; then
  echo "[deploy-backend] ERROR: SUPABASE_PROJECT_REF (or SUPABASE_PROJECT_ID) is required." >&2
  exit 1
fi

if [[ -z "${SUPABASE_ACCESS_TOKEN:-}" ]]; then
  echo "[deploy-backend] ERROR: SUPABASE_ACCESS_TOKEN is required." >&2
  exit 1
fi

# Link project
# Note: supabase CLI reads SUPABASE_ACCESS_TOKEN automatically.
echo "[deploy-backend] Linking project: ${PROJECT_REF}"
supabase link --project-ref "$PROJECT_REF"

# Apply migrations
if [[ -d supabase/migrations ]]; then
  echo "[deploy-backend] Deploying database migrations…"
  supabase db deploy
else
  echo "[deploy-backend] WARN: supabase/migrations not found; skipping db deploy."
fi

# Sync secrets
# Keep this intentionally minimal; do NOT dump all .env vars into Supabase.
TMP_ENV_FILE="$(mktemp)"
cleanup() { rm -f "$TMP_ENV_FILE"; }
trap cleanup EXIT

# Map legacy/alternative names safely.
# Prefer SUPABASE_SERVICE_ROLE_KEY; accept SUPABASE_SECRET_KEY as fallback.
if [[ -n "${SUPABASE_SERVICE_ROLE_KEY:-}" ]]; then
  echo "SUPABASE_SERVICE_ROLE_KEY=${SUPABASE_SERVICE_ROLE_KEY}" >> "$TMP_ENV_FILE"
elif [[ -n "${SUPABASE_SECRET_KEY:-}" ]]; then
  echo "SUPABASE_SERVICE_ROLE_KEY=${SUPABASE_SECRET_KEY}" >> "$TMP_ENV_FILE"
fi

[[ -n "${SUPABASE_URL:-}" ]] && echo "SUPABASE_URL=${SUPABASE_URL}" >> "$TMP_ENV_FILE"
[[ -n "${SUPABASE_ANON_KEY:-}" ]] && echo "SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY}" >> "$TMP_ENV_FILE"
[[ -n "${PPLX_API_KEY:-}" ]] && echo "PPLX_API_KEY=${PPLX_API_KEY}" >> "$TMP_ENV_FILE"

if [[ -s "$TMP_ENV_FILE" ]]; then
  echo "[deploy-backend] Setting Supabase secrets…"
  supabase secrets set --env-file "$TMP_ENV_FILE"
else
  echo "[deploy-backend] WARN: No secrets found to set (continuing)."
fi

# Deploy functions
bash scripts/deploy-functions.sh

# Verify (best-effort)
if [[ -n "${SUPABASE_URL:-}" ]]; then
  echo "[deploy-backend] Verifying debug-env…"
  curl -fsS "${SUPABASE_URL%/}/functions/v1/debug-env" >/dev/null || echo "[deploy-backend] WARN: debug-env verify failed (continuing)."
else
  echo "[deploy-backend] WARN: SUPABASE_URL not set; skipping verify."
fi

echo "[deploy-backend] Done."