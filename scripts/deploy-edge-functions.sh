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

FUNCTIONS=("generate-trading-signal" "update-positions" "approve-signal" "serve-signals")

for func in "${FUNCTIONS[@]}"; do
  echo "Deploying $func..."
  if [ -d "supabase/functions/$func" ]; then
    supabase functions deploy "$func" --no-verify-jwt
  else
    echo "⚠️  Function directory not found: supabase/functions/$func"
  fi
  echo ""
done

echo ""
echo "✅ Deployment complete!"
echo ""
echo "Set secrets (one-time):"
echo "  supabase secrets set PERPLEXITY_API_KEY=pplx-..."
echo ""
echo "Test functions:"
echo "  supabase functions invoke generate-trading-signal"
echo "  supabase functions invoke serve-signals"
echo ""
