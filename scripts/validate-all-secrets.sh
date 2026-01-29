#!/bin/bash

echo "🔐 KLARPAKKE SECRET VALIDATION"
echo "════════════════════════════════════════════════════"
echo ""

# Counters
ERRORS=0
WARNINGS=0
SUCCESS=0

check_secret() {
  local name=$1
  local value=$2
  local required=${3:-true}
  
  if [ -z "$value" ]; then
    if [ "$required" = "true" ]; then
      echo "❌ MISSING: $name"
      ((ERRORS++))
    else
      echo "⚠️  OPTIONAL: $name (not set)"
      ((WARNINGS++))
    fi
  else
    local masked="${value:0:20}..."
    echo "✅ FOUND: $name = $masked"
    ((SUCCESS++))
  fi
}

echo "📋 PHASE 1: LOCAL .env FILE"
echo "────────────────────────────────────────────────────"

if [ ! -f .env ]; then
  echo "❌ CRITICAL: .env file not found!"
  exit 1
fi

# Load .env
set -a
source .env 2>/dev/null || true
set +a

# Check critical secrets
check_secret "SUPABASE_URL" "$SUPABASE_URL" true
check_secret "SUPABASE_ANON_KEY" "$SUPABASE_ANON_KEY" true
check_secret "SUPABASE_SERVICE_KEY" "$SUPABASE_SERVICE_KEY" false
check_secret "WEBFLOW_API_TOKEN" "$WEBFLOW_API_TOKEN" true
check_secret "WEBFLOW_SITE_ID" "$WEBFLOW_SITE_ID" true
check_secret "WEBFLOW_SIGNALS_COLLECTION_ID" "$WEBFLOW_SIGNALS_COLLECTION_ID" true

echo ""
echo "📋 PHASE 2: CONNECTION TESTS"
echo "────────────────────────────────────────────────────"

# Test Supabase
echo "Testing Supabase connection..."
SUPABASE_TEST=$(curl -s -o /dev/null -w "%{http_code}" \
  -H "apikey: $SUPABASE_ANON_KEY" \
  -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
  "$SUPABASE_URL/rest/v1/" 2>/dev/null || echo "000")

if [ "$SUPABASE_TEST" = "200" ]; then
  echo "✅ Supabase API: Connected"
  ((SUCCESS++))
else
  echo "❌ Supabase API: Failed (HTTP $SUPABASE_TEST)"
  ((ERRORS++))
fi

# Test Webflow
echo "Testing Webflow connection..."
WEBFLOW_TEST=$(curl -s -o /dev/null -w "%{http_code}" \
  -H "Authorization: Bearer $WEBFLOW_API_TOKEN" \
  "https://api.webflow.com/v2/sites/$WEBFLOW_SITE_ID" 2>/dev/null || echo "000")

if [ "$WEBFLOW_TEST" = "200" ]; then
  echo "✅ Webflow API: Connected"
  ((SUCCESS++))
else
  echo "❌ Webflow API: Failed (HTTP $WEBFLOW_TEST)"
  ((ERRORS++))
fi

echo ""
echo "════════════════════════════════════════════════════"
echo "📊 SUMMARY"
echo "════════════════════════════════════════════════════"
echo "✅ Success: $SUCCESS"
echo "⚠️  Warnings: $WARNINGS"
echo "❌ Errors: $ERRORS"
echo ""

if [ $ERRORS -gt 0 ]; then
  echo "❌ VALIDATION FAILED"
  exit 1
else
  echo "✅ ALL SYSTEMS GO!"
  exit 0
fi
