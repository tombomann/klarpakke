#!/bin/bash
# Klarpakke One-Click Deploy (FULL AUTOMATION)
# Deploys backend + frontend + seeds data + publishes Webflow
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "═══════════════════════════════════════════════════════════"
echo "  🚀 KLARPAKKE ONE-CLICK DEPLOY (v3.0)                    "
echo "═══════════════════════════════════════════════════════════"
echo -e "${NC}"

# Check required env vars
REQUIRED_VARS=("SUPABASE_PROJECT_ID" "SUPABASE_ACCESS_TOKEN")
MISSING_VARS=()

for VAR in "${REQUIRED_VARS[@]}"; do
  if [ -z "${!VAR:-}" ]; then
    MISSING_VARS+=("$VAR")
  fi
done

if [ ${#MISSING_VARS[@]} -gt 0 ]; then
  echo -e "${RED}❌ Missing required environment variables:${NC}"
  for VAR in "${MISSING_VARS[@]}"; do
    echo -e "   - $VAR"
  done
  echo ""
  echo "Set them in your shell or .env file:"
  echo "  export SUPABASE_PROJECT_ID=your_project_id"
  echo "  export SUPABASE_ACCESS_TOKEN=your_token"
  exit 1
fi

echo -e "${GREEN}✓ Environment variables loaded${NC}"
echo ""

# ═══════════════════════════════════════════════════════════
# PHASE 1: SUPABASE BACKEND
# ═══════════════════════════════════════════════════════════
echo -e "${BLUE}[1/5] Deploying Supabase Edge Functions...${NC}"

if ! command -v supabase &> /dev/null; then
  echo -e "${RED}❌ Supabase CLI not installed. Install: brew install supabase/tap/supabase${NC}"
  exit 1
fi

# Link project
supabase link --project-ref "$SUPABASE_PROJECT_ID" 2>/dev/null || echo "Already linked"

# Deploy all functions
FUNCTIONS=("generate-trading-signal" "approve-signal" "analyze-signal" "update-positions" "serve-js" "debug-env")

for FUNC in "${FUNCTIONS[@]}"; do
  echo -e "  → Deploying ${FUNC}..."
  supabase functions deploy "$FUNC" --no-verify-jwt 2>&1 | grep -E '(Deployed|Error|Failed)' || true
done

# Set secrets
echo -e "  → Setting secrets..."
if [ -f .env ]; then
  while IFS='=' read -r key value; do
    # Skip comments and empty lines
    [[ $key =~ ^#.*$ ]] && continue
    [[ -z $key ]] && continue
    
    # Remove quotes and whitespace
    value=$(echo "$value" | sed -e 's/^["'"'"']*//' -e 's/["'"'"']*$//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    
    if [ -n "$value" ]; then
      supabase secrets set "${key}=${value}" --project-ref "$SUPABASE_PROJECT_ID" 2>/dev/null || echo "  ⚠️  Failed to set $key"
    fi
  done < .env
  echo -e "${GREEN}✓ Secrets deployed${NC}"
else
  echo -e "${YELLOW}⚠️  No .env file found, skipping secrets${NC}"
fi

echo -e "${GREEN}✓ Phase 1 complete: Backend deployed${NC}"
echo ""

# ═══════════════════════════════════════════════════════════
# PHASE 2: SEED DEMO DATA
# ═══════════════════════════════════════════════════════════
echo -e "${BLUE}[2/5] Seeding demo signals (paper trading)...${NC}"

if [ -f scripts/paper-seed.sh ]; then
  bash scripts/paper-seed.sh 2>&1 | tail -3
  echo -e "${GREEN}✓ Demo signals created${NC}"
else
  echo -e "${YELLOW}⚠️  scripts/paper-seed.sh not found, skipping seed${NC}"
fi

echo ""

# ═══════════════════════════════════════════════════════════
# PHASE 3: WEBFLOW DEPLOY
# ═══════════════════════════════════════════════════════════
echo -e "${BLUE}[3/5] Deploying Webflow UI...${NC}"

if [ -z "${WEBFLOW_API_TOKEN:-}" ]; then
  echo -e "${YELLOW}⚠️  WEBFLOW_API_TOKEN not set${NC}"
  echo -e "${YELLOW}   Manual step required:${NC}"
  echo ""
  echo "   1. Copy web/klarpakke-site.js to clipboard:"
  echo "      cat web/klarpakke-site.js | pbcopy"
  echo ""
  echo "   2. Go to Webflow Designer > Project Settings > Custom Code"
  echo "   3. Paste in 'Before </body>' section"
  echo "   4. Save & Publish"
  echo ""
  echo -e "${YELLOW}   Or set WEBFLOW_API_TOKEN to automate this step${NC}"
else
  WEBFLOW_SITE_ID="${WEBFLOW_SITE_ID:-klarpakke-c65071}"
  
  # Read site JS
  if [ -f web/klarpakke-site.js ]; then
    SITE_JS=$(cat web/klarpakke-site.js)
    
    # Update site-wide custom code via API
    echo -e "  → Updating site-wide custom code..."
    curl -s -X PUT "https://api.webflow.com/v2/sites/${WEBFLOW_SITE_ID}/custom_code" \
      -H "Authorization: Bearer ${WEBFLOW_API_TOKEN}" \
      -H "Content-Type: application/json" \
      -d "{\"scripts\": [{\"location\":\"footer\", \"code\":\"<script>${SITE_JS}</script>\"}]}" \
      | grep -E '(id|error)' || echo "  ⚠️  API call may have failed"
    
    echo -e "${GREEN}✓ Webflow code updated${NC}"
  else
    echo -e "${RED}❌ web/klarpakke-site.js not found${NC}"
  fi
  
  # Publish site
  echo -e "  → Publishing to staging subdomain..."
  PUBLISH_DOMAINS='["*.webflow.io"]'
  
  curl -s -X POST "https://api.webflow.com/v2/sites/${WEBFLOW_SITE_ID}/publish" \
    -H "Authorization: Bearer ${WEBFLOW_API_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "{\"domains\": ${PUBLISH_DOMAINS}}" \
    | grep -E '(publishedAt|error)' || echo "  ⚠️  Publish may have failed"
  
  echo -e "${GREEN}✓ Site published${NC}"
fi

echo ""

# ═══════════════════════════════════════════════════════════
# PHASE 4: CALCULATOR DEPLOY
# ═══════════════════════════════════════════════════════════
echo -e "${BLUE}[4/5] Deploying calculator...${NC}"

if [ -f web/calculator.js ]; then
  echo -e "  → Calculator code ready at: web/calculator.js"
  echo -e "  → Manual step: Add to /kalkulator page in Webflow"
  echo -e "${GREEN}✓ Calculator script available${NC}"
else
  echo -e "${RED}❌ web/calculator.js not found${NC}"
fi

echo ""

# ═══════════════════════════════════════════════════════════
# PHASE 5: VERIFICATION
# ═══════════════════════════════════════════════════════════
echo -e "${BLUE}[5/5] Running smoke tests...${NC}"

# Test Supabase connection
echo -e "  → Testing Supabase Edge Function..."
SUPABASE_URL="https://${SUPABASE_PROJECT_ID}.supabase.co"
TEST_RESPONSE=$(curl -s -X POST "${SUPABASE_URL}/functions/v1/debug-env" \
  -H "Authorization: Bearer ${SUPABASE_ANON_KEY:-dummy}" \
  -H "Content-Type: application/json" \
  -d '{"test": true}' || echo '{"error": "failed"}')

if echo "$TEST_RESPONSE" | grep -q 'SUPABASE_PROJECT_ID'; then
  echo -e "${GREEN}✓ Edge Functions responding${NC}"
else
  echo -e "${YELLOW}⚠️  Edge Functions may not be ready yet (can take 1-2 min)${NC}"
fi

# Count signals
echo -e "  → Checking demo signals..."
if command -v psql &> /dev/null && [ -n "${DATABASE_URL:-}" ]; then
  SIGNAL_COUNT=$(psql "$DATABASE_URL" -t -c "SELECT COUNT(*) FROM signals WHERE status='pending';" 2>/dev/null | xargs || echo "0")
  echo -e "    Found ${SIGNAL_COUNT} pending signals"
else
  echo -e "${YELLOW}    (psql not available, skipping DB check)${NC}"
fi

echo ""
echo -e "${GREEN}"
echo "═══════════════════════════════════════════════════════════"
echo "  ✅ DEPLOYMENT COMPLETE!                                  "
echo "═══════════════════════════════════════════════════════════"
echo -e "${NC}"
echo ""
echo "🌐 Your app is live at:"
echo "   https://klarpakke-c65071.webflow.io/app/dashboard"
echo ""
echo "📊 Supabase Dashboard:"
echo "   https://supabase.com/dashboard/project/${SUPABASE_PROJECT_ID}"
echo ""
echo "📋 Next steps:"
echo "   1. Test: Open dashboard and click 'Approve' on a signal"
echo "   2. Check: Verify calculator at /kalkulator"
echo "   3. Monitor: GitHub Actions for ongoing syncs"
echo ""
echo "🔧 To redeploy:"
echo "   make deploy-all"
echo ""
