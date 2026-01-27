#!/usr/bin/env bash
set -euo pipefail

# Deploy all Supabase Edge Functions found in supabase/functions/*

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if ! command -v supabase >/dev/null 2>&1; then
  echo "[deploy-functions] ERROR: supabase CLI not found." >&2
  exit 1
fi

if [[ ! -d supabase/functions ]]; then
  echo "[deploy-functions] ERROR: supabase/functions/ not found." >&2
  exit 1
fi

echo "[deploy-functions] Deploying functions…"
found_any=false
for dir in supabase/functions/*; do
  [[ -d "$dir" ]] || continue
  name="$(basename "$dir")"
  found_any=true
  echo "[deploy-functions] → $name"
  supabase functions deploy "$name" --no-verify-jwt
done

if [[ "$found_any" == false ]]; then
  echo "[deploy-functions] WARN: no functions found under supabase/functions/*"
fi

echo "[deploy-functions] Done."