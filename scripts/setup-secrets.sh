#!/bin/bash
# Setup Supabase secrets from .env
set -euo pipefail

echo "🔐 Setting up Supabase secrets"
echo "============================="
echo ""

if [ ! -f ".env" ]; then
  echo "❌ .env not found"
  exit 1
fi

source .env

if [ -z "${PERPLEXITY_API_KEY:-}" ]; then
  echo "❌ PERPLEXITY_API_KEY not found in .env"
  echo ""
  echo "Add it with:"
  echo "  echo 'PERPLEXITY_API_KEY=pplx-...' >> .env"
  exit 1
fi

if [ -z "${SUPABASE_URL:-}" ]; then
  echo "❌ SUPABASE_URL not found in .env"
  exit 1
fi

if [ -z "${SUPABASE_SECRET_KEY:-}" ]; then
  echo "❌ SUPABASE_SECRET_KEY (service_role) not found in .env"
  echo ""
  echo "Get it from:"
  echo "  https://supabase.com/dashboard/project/swfyuwkptusceiouqlks/settings/api"
  exit 1
fi

echo "Setting secrets for Edge Functions..."
echo ""
echo "1/3 PERPLEXITY_API_KEY"
supabase secrets set PERPLEXITY_API_KEY="$PERPLEXITY_API_KEY" --project-ref swfyuwkptusceiouqlks

echo ""
echo "2/3 SUPABASE_URL"
supabase secrets set SUPABASE_URL="$SUPABASE_URL" --project-ref swfyuwkptusceiouqlks

echo ""
echo "3/3 SUPABASE_SERVICE_ROLE_KEY"
supabase secrets set SUPABASE_SERVICE_ROLE_KEY="$SUPABASE_SECRET_KEY" --project-ref swfyuwkptusceiouqlks

echo ""
echo "✅ Secrets configured!"
echo ""
echo "Verify with:"
echo "  supabase secrets list --project-ref swfyuwkptusceiouqlks"
echo ""
echo "Test Edge Functions:"
echo "  make edge-test-live"
echo ""
