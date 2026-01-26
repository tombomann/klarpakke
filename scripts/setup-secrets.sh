#!/bin/bash
# Setup Supabase secrets from .env
set -euo pipefail

echo "🔐 Setting up Supabase secrets"
echo "=============================="
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

echo "Setting secrets..."
supabase secrets set PERPLEXITY_API_KEY="$PERPLEXITY_API_KEY" --project-ref swfyuwkptusceiouqlks

echo ""
echo "✅ Secrets configured!"
echo ""
echo "Verify with:"
echo "  supabase secrets list --project-ref swfyuwkptusceiouqlks"
echo ""
