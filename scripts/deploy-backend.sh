#!/usr/bin/env bash
set -euo pipefail

# Deploy Supabase backend (remote): migrations + secrets + edge functions + basic verify

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.."; pwd)"
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

# Apply migrations (use 'db push' to deploy migrations to remote)
if [[ -d supabase/migrations ]]; then
  echo "[deploy-backend] Deploying database migrations…"
  # Use --linked flag to deploy to the linked project
  supabase db push --linked
else
  echo "[deploy-backend] WARN: supabase/migrations not found; skipping db push."
fi

# Sync secrets for Edge Functions
# NOTE: Do NOT include SUPABASE_* vars - those are auto-injected by runtime
# Only include custom secrets needed by your Edge Functions
TMP_ENV_FILE="$(mktemp)"
cleanup() { rm -f "$TMP_ENV_FILE"; }
trap cleanup EXIT

# Add custom API keys and secrets (NOT SUPABASE_* vars)
[[ -n "${PPLX_API_KEY:-}" ]] && echo "PPLX_API_KEY=${PPLX_API_KEY}" >> "$TMP_ENV_FILE"
[[ -n "${STRIPE_SECRET_KEY:-}" ]] && echo "STRIPE_SECRET_KEY=${STRIPE_SECRET_KEY}" >> "$TMP_ENV_FILE"
[[ -n "${WEBFLOW_API_TOKEN:-}" ]] && echo "WEBFLOW_API_TOKEN=${WEBFLOW_API_TOKEN}" >> "$TMP_ENV_FILE"
[[ -n "${MAKE_API_TOKEN:-}" ]] && echo "MAKE_API_TOKEN=${MAKE_API_TOKEN}" >> "$TMP_ENV_FILE"

if [[ -s "$TMP_ENV_FILE" ]]; then
  echo "[deploy-backend] Setting Edge Function secrets…"
  supabase secrets set --env-file "$TMP_ENV_FILE"
else
  echo "[deploy-backend] WARN: No custom secrets found to set (continuing)."
fi

# Deploy Edge Functions
echo "[deploy-backend] Deploying Edge Functions…"
bash scripts/deploy-functions.sh

# Verify (best-effort)
if [[ -n "${SUPABASE_URL:-}" ]]; then
  echo "[deploy-backend] Verifying API endpoint…"
  # Simple connectivity check
  if curl -fsS "${SUPABASE_URL%/}/rest/v1/" -H "apikey: ${SUPABASE_ANON_KEY}" >/dev/null 2>&1; then
    echo "[deploy-backend] ✓ API endpoint responding"
  else
    echo "[deploy-backend] WARN: API verify failed (may be RLS policy - continuing)."
  fi
else
  echo "[deploy-backend] WARN: SUPABASE_URL not set; skipping verify."
fi

echo "[deploy-backend] ✓ Done."
