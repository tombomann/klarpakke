#!/bin/bash
# Check if Make.com setup is ready
set -euo pipefail

echo "🔍 Make.com Readiness Check"
echo "============================"
echo ""

if [ ! -f "make/.env.make" ]; then
  echo "❌ make/.env.make not found"
  echo "Run: make make-setup"
  exit 1
fi

source make/.env.make

ERRORS=0

echo "Checking required variables..."
echo ""

# Check Supabase
if [ -z "${SUPABASE_URL:-}" ]; then
  echo "❌ SUPABASE_URL missing"
  ERRORS=$((ERRORS + 1))
else
  echo "✅ SUPABASE_URL: ${SUPABASE_URL:0:30}..."
fi

if [ -z "${SUPABASE_ANON_KEY:-}" ]; then
  echo "❌ SUPABASE_ANON_KEY missing"
  ERRORS=$((ERRORS + 1))
else
  echo "✅ SUPABASE_ANON_KEY: ${SUPABASE_ANON_KEY:0:20}..."
fi

if [ -z "${SUPABASE_SECRET_KEY:-}" ]; then
  echo "❌ SUPABASE_SECRET_KEY missing"
  ERRORS=$((ERRORS + 1))
else
  echo "✅ SUPABASE_SECRET_KEY: ${SUPABASE_SECRET_KEY:0:20}..."
fi

# Check Perplexity
if [ -z "${PERPLEXITY_API_KEY:-}" ]; then
  echo "❌ PERPLEXITY_API_KEY missing"
  ERRORS=$((ERRORS + 1))
elif [ "${PERPLEXITY_API_KEY}" = "pplx-your-key-here" ]; then
  echo "⚠️  PERPLEXITY_API_KEY not set (still placeholder)"
  echo "   Get key from: https://www.perplexity.ai/settings/api"
  ERRORS=$((ERRORS + 1))
else
  echo "✅ PERPLEXITY_API_KEY: ${PERPLEXITY_API_KEY:0:10}..."
fi

echo ""

if [ $ERRORS -eq 0 ]; then
  echo "✅ ALL CHECKS PASSED!"
  echo ""
  echo "You are ready to:"
  echo "1. Import scenario to Make.com"
  echo "2. Add these environment variables"
  echo "3. Test with 'Run once'"
  echo ""
  echo "Next: Open Make.com"
  echo "  open 'https://www.make.com/en/scenarios'"
else
  echo "❌ $ERRORS error(s) found"
  echo ""
  echo "Fix by editing: make/.env.make"
  echo "  nano make/.env.make"
  exit 1
fi
