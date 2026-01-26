#!/bin/bash
# Deploy Supabase Edge Functions
set -euo pipefail

echo "🚀 Deploying Supabase Edge Functions"
echo "===================================="
echo ""

# Check if Supabase CLI is installed
if ! command -v supabase &> /dev/null; then
  echo "❌ Supabase CLI not installed"
  echo ""
  echo "Install with:"
  echo "  brew install supabase/tap/supabase"
  echo ""
  echo "Or:"
  echo "  npm install -g supabase"
  exit 1
fi

# Check if logged in
if ! supabase projects list &> /dev/null; then
  echo "❌ Not logged in to Supabase"
  echo ""
  echo "Login with:"
  echo "  supabase login"
  exit 1
fi

# Link to project
echo "🔗 Linking to Supabase project..."
supabase link --project-ref swfyuwkptusceiouqlks

# Deploy functions
echo ""
echo "📦 Deploying Edge Functions..."
echo ""

echo "1. generate-trading-signal"
supabase functions deploy generate-trading-signal

echo ""
echo "2. update-positions"
supabase functions deploy update-positions

echo ""
echo "✅ Deployment complete!"
echo ""
echo "Set secrets (one-time):"
echo "  supabase secrets set PERPLEXITY_API_KEY=pplx-..."
echo ""
echo "Test functions:"
echo "  supabase functions invoke generate-trading-signal"
echo "  supabase functions invoke update-positions"
echo ""
