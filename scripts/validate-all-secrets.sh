#!/bin/bash
set -e

echo "🔐 KLARPAKKE SECRET VALIDATION"
echo "════════════════════════════════════════════════════"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

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
      echo -e "${RED}❌ MISSING:${NC} $name"
      ((ERRORS++))
    else
      echo -e "${YELLOW}⚠️  OPTIONAL:${NC} $name (not set)"
      ((WARNINGS++))
    fi
  else
    # Mask value
    local masked="${value:0:20}..."
    echo -e "${GREEN}✅ FOUND:${NC} $name = $masked"
    ((SUCCESS++))
  fi
}

echo "📋 PHASE 1: LOCAL .env FILE"
echo "────────────────────────────────────────────────────"

if [ ! -f .env ]; then
  echo -e "${RED}❌ CRITICAL: .env file not found!${NC}"
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
echo "📋 PHASE 2: SUPABASE SECRETS (Remote)"
echo "────────────────────────────────────────────────────"

# Check Supabase secrets
if command -v supabase &> /dev/null; then
  echo "Fetching Supabase secrets..."
  
  SUPABASE_SECRETS=$(supabase secrets list 2>/dev/null || echo "")
  
  if [ -n "$SUPABASE_SECRETS" ]; then
    echo "$SUPABASE_SECRETS"
    echo -e "${GREEN}✅ Supabase CLI connected${NC}"
  else
    echo -e "${YELLOW}⚠️  No secrets found or not authenticated${NC}"
    echo "   Run: supabase link --project-ref $SUPABASE_PROJECT_REF"
    ((WARNINGS++))
  fi
else
  echo -e "${YELLOW}⚠️  Supabase CLI not installed${NC}"
  ((WARNINGS++))
fi

echo ""
echo "📋 PHASE 3: GITHUB SECRETS"
echo "────────────────────────────────────────────────────"

if command -v gh &> /dev/null; then
  echo "Checking GitHub repository secrets..."
  
  # List repo secrets (doesn't show values, just names)
  GH_SECRETS=$(gh secret list 2>/dev/null || echo "")
  
  if [ -n "$GH_SECRETS" ]; then
    echo "$GH_SECRETS"
    echo -e "${GREEN}✅ GitHub CLI connected${NC}"
    
    # Check for required secrets
    REQUIRED_GH_SECRETS=(
      "SUPABASE_URL"
      "SUPABASE_ANON_KEY"
      "SUPABASE_SERVICE_KEY"
      "WEBFLOW_API_TOKEN"
      "WEBFLOW_SITE_ID"
      "WEBFLOW_SIGNALS_COLLECTION_ID"
    )
    
    for secret in "${REQUIRED_GH_SECRETS[@]}"; do
      if echo "$GH_SECRETS" | grep -q "$secret"; then
        echo -e "${GREEN}✅${NC} $secret exists in GitHub"
      else
        echo -e "${RED}❌ MISSING:${NC} $secret in GitHub Secrets"
        ((ERRORS++))
      fi
    done
  else
    echo -e "${YELLOW}⚠️  Could not list GitHub secrets${NC}"
    echo "   Run: gh auth login"
    ((WARNINGS++))
  fi
else
  echo -e "${YELLOW}⚠️  GitHub CLI not installed${NC}"
  ((WARNINGS++))
fi

echo ""
echo "📋 PHASE 4: CONNECTION TESTS"
echo "────────────────────────────────────────────────────"

# Test Supabase
echo "Testing Supabase connection..."
SUPABASE_TEST=$(curl -s -o /dev/null -w "%{http_code}" \
  -H "apikey: $SUPABASE_ANON_KEY" \
  -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
  "$SUPABASE_URL/rest/v1/" 2>/dev/null || echo "000")

if [ "$SUPABASE_TEST" = "200" ]; then
  echo -e "${GREEN}✅ Supabase API: Connected${NC}"
  ((SUCCESS++))
else
  echo -e "${RED}❌ Supabase API: Failed (HTTP $SUPABASE_TEST)${NC}"
  echo "   Check SUPABASE_URL and SUPABASE_ANON_KEY"
  ((ERRORS++))
fi

# Test Webflow
echo "Testing Webflow connection..."
WEBFLOW_TEST=$(curl -s -o /dev/null -w "%{http_code}" \
  -H "Authorization: Bearer $WEBFLOW_API_TOKEN" \
  "https://api.webflow.com/v2/sites/$WEBFLOW_SITE_ID" 2>/dev/null || echo "000")

if [ "$WEBFLOW_TEST" = "200" ]; then
  echo -e "${GREEN}✅ Webflow API: Connected${NC}"
  ((SUCCESS++))
else
  echo -e "${RED}❌ Webflow API: Failed (HTTP $WEBFLOW_TEST)${NC}"
  echo "   Check WEBFLOW_API_TOKEN and WEBFLOW_SITE_ID"
  ((ERRORS++))
fi

echo ""
echo "════════════════════════════════════════════════════"
echo "📊 SUMMARY"
echo "════════════════════════════════════════════════════"
echo -e "${GREEN}✅ Success: $SUCCESS${NC}"
echo -e "${YELLOW}⚠️  Warnings: $WARNINGS${NC}"
echo -e "${RED}❌ Errors: $ERRORS${NC}"
echo ""

if [ $ERRORS -gt 0 ]; then
  echo -e "${RED}❌ VALIDATION FAILED${NC}"
  echo ""
  echo "🔧 FIXES:"
  echo "1. Update .env with correct values"
  echo "2. Sync to Supabase: npm run secrets:push"
  echo "3. Sync to GitHub: npm run secrets:sync-github"
  exit 1
else
  echo -e "${GREEN}✅ ALL SYSTEMS GO!${NC}"
  exit 0
fi
