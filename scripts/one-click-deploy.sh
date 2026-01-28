#!/usr/bin/env bash
set -euo pipefail

# Klarpakke One-Click Deploy (prod/staging)
# Goal: from local machine → GitHub Secrets synced → run deploy workflows → watch until done.
#
# Requirements:
# - gh (GitHub CLI) authenticated to repo
# - .env present (or exported env vars)
#
# It intentionally does NOT print secret values.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || { echo "❌ Missing dependency: $1"; exit 1; }
}

need_cmd gh
need_cmd jq

# Load .env if present
if [[ -f .env ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi

# --- Derive/normalize env vars ---

# PROJECT_REF: prefer explicit, accept legacy SUPABASE_PROJECT_ID, derive from SUPABASE_URL if needed
PROJECT_REF="${SUPABASE_PROJECT_REF:-${SUPABASE_PROJECT_ID:-}}"
if [[ -z "${PROJECT_REF}" && -n "${SUPABASE_URL:-}" ]]; then
  # https://<ref>.supabase.co → <ref>
  tmp="${SUPABASE_URL#https://}"; tmp="${tmp#http://}"; tmp="${tmp%%.*}"
  PROJECT_REF="$tmp"
fi

if [[ -z "${PROJECT_REF}" ]]; then
  echo "❌ Missing SUPABASE_PROJECT_REF (or SUPABASE_PROJECT_ID) and could not derive from SUPABASE_URL"
  exit 1
fi

# Service role: prefer SERVICE_ROLE_KEY; accept SECRET_KEY fallback
SUPABASE_SERVICE_ROLE_KEY="${SUPABASE_SERVICE_ROLE_KEY:-${SUPABASE_SECRET_KEY:-}}"

# public-config URL
KLARPAKKE_PUBLIC_CONFIG_URL="${KLARPAKKE_PUBLIC_CONFIG_URL:-https://${PROJECT_REF}.supabase.co/functions/v1/public-config}"

# --- Validate required values (non-empty) ---

req() {
  local name="$1"
  local val="${!name:-}"
  if [[ -z "${val}" ]]; then
    echo "❌ Missing required env var in .env (or shell): ${name}"
    exit 1
  fi
}

# Required for backend deploy workflow
req SUPABASE_ACCESS_TOKEN
req SUPABASE_URL
req SUPABASE_ANON_KEY
req SUPABASE_SERVICE_ROLE_KEY
req PPLX_API_KEY

# Required for webflow deploy workflow
req WEBFLOW_API_TOKEN
req WEBFLOW_SITE_ID

# --- Sync GitHub Actions secrets (allowlist) ---

TMP_ENV_FILE="$(mktemp)"
cleanup() { rm -f "$TMP_ENV_FILE"; }
trap cleanup EXIT

cat > "$TMP_ENV_FILE" <<EOF
SUPABASE_PROJECT_REF=${PROJECT_REF}
SUPABASE_ACCESS_TOKEN=${SUPABASE_ACCESS_TOKEN}
SUPABASE_URL=${SUPABASE_URL}
SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY}
SUPABASE_SERVICE_ROLE_KEY=${SUPABASE_SERVICE_ROLE_KEY}
PPLX_API_KEY=${PPLX_API_KEY}
WEBFLOW_API_TOKEN=${WEBFLOW_API_TOKEN}
WEBFLOW_SITE_ID=${WEBFLOW_SITE_ID}
KLARPAKKE_PUBLIC_CONFIG_URL=${KLARPAKKE_PUBLIC_CONFIG_URL}
EOF

echo "🔐 Syncing GitHub Actions secrets (allowlist)…"
# gh supports dotenv env-file loading
# Note: values are read from file; nothing is printed.
while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  name="${line%%=*}"
  echo "  - ${name}"
done < "$TMP_ENV_FILE"

gh secret set -f "$TMP_ENV_FILE"

echo "✅ Secrets synced"

# --- Trigger workflows ---

trigger_and_watch() {
  local workflow="$1"
  echo "🚀 Trigger: $workflow"
  gh workflow run "$workflow" --ref main

  # give GitHub a moment to register the run
  sleep 2

  # get latest run id
  local run_id
  run_id=$(gh run list --workflow "$workflow" --limit 1 --json databaseId --jq '.[0].databaseId' 2>/dev/null || true)
  if [[ -z "$run_id" ]]; then
    echo "⚠️  Could not resolve run id for $workflow (gh version?). Open Actions UI or run: gh run list --workflow=\"$workflow\""
    return 1
  fi

  echo "👀 Watching run: $run_id"
  gh run watch "$run_id" --exit-status
}

# Order matters: backend first, then webflow, then healthcheck
trigger_and_watch ".github/workflows/supabase-backend-deploy.yml"
trigger_and_watch ".github/workflows/webflow-deploy.yml"
trigger_and_watch ".github/workflows/healthcheck-webflow-loader.yml"

echo "✅ One-click deploy complete"
