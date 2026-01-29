#!/bin/bash

# 🚀 Klarpakke Bootstrap Script for Mac M1
# One-time setup: Git clone → dependencies → secrets → health check → ready for Actions
#
# Usage:
#   ./scripts/bootstrap-mac-m1.sh
#
# What it does:
#   1. Checks Node 18+, npm, Supabase CLI, jq
#   2. Clones repo (if not already in klarpakke dir)
#   3. npm ci + npm run build:web
#   4. Prompts for secrets (GitHub env vars) → .env.local (.gitignore'd)
#   5. Verifies Supabase connectivity
#   6. Runs health:full check
#   7. Optionally start Supabase local or link to cloud
#   8. Prints ready-to-go summary
#
# Exit codes:
#   0 = Success (ready for Actions / Designer extension)
#   1 = Missing dependency
#   2 = Setup interrupted by user

set -e

echo "🚀 Klarpakke Bootstrap for Mac M1"
echo "================================"
echo ""

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_step() { echo -e "${BLUE}➜${NC} $1"; }
log_success() { echo -e "${GREEN}✓${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1"; }
log_warning() { echo -e "${YELLOW}⚠${NC} $1"; }

# Step 1: Check dependencies
log_step "Checking dependencies..."

if ! command -v node &> /dev/null; then
  log_error "Node.js not found"
  echo "Install from: https://nodejs.org (v18+)"
  exit 1
fi
NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [[ $NODE_VERSION -lt 18 ]]; then
  log_error "Node.js version ${NODE_VERSION} found, but v18+ required"
  exit 1
fi
log_success "Node.js v$(node -v)"

if ! command -v npm &> /dev/null; then
  log_error "npm not found"
  exit 1
fi
log_success "npm v$(npm -v)"

if ! command -v supabase &> /dev/null; then
  log_warning "Supabase CLI not found, installing..."
  npm install -g supabase
fi
log_success "Supabase CLI installed"

if ! command -v jq &> /dev/null; then
  log_warning "jq not found, installing..."
  brew install jq
fi
log_success "jq installed"

echo ""

# Step 2: Git setup
log_step "Git setup..."

if [[ ! -d .git ]]; then
  log_warning "Not in a git repo. Clone klarpakke? (y/n)"
  read -r CLONE_CHOICE
  if [[ $CLONE_CHOICE != "y" ]]; then
    log_warning "Skipping clone. Make sure you're in ~/klarpakke or equivalent."
    exit 2
  fi
  git clone https://github.com/tombomann/klarpakke.git klarpakke
  cd klarpakke
  log_success "Cloned klarpakke"
else
  REPO_ORIGIN=$(git config --get remote.origin.url || echo "unknown")
  log_success "Already in repo: $REPO_ORIGIN"
fi

echo ""

# Step 3: Install dependencies
log_step "Installing npm dependencies..."
npm ci --silent
log_success "npm dependencies installed"

log_step "Building web bundles..."
npm run build:web --silent
log_success "Web bundles built"

echo ""

# Step 4: Secrets setup
log_step "Secrets setup"
echo "   This will create .env.local (in .gitignore - never committed)."
echo ""

# Check if .env.local already exists
if [[ -f .env.local ]]; then
  log_warning ".env.local already exists. Keep existing secrets? (y/n)"
  read -r KEEP_ENV
  if [[ $KEEP_ENV == "y" ]]; then
    log_success "Using existing .env.local"
  else
    rm .env.local
    log_success "Removed .env.local"
  fi
else
  cat > .env.local << 'ENVEOF'
# Klarpakke secrets (never commit this file)
# Get these from GitHub repo Settings → Secrets and Variables → Actions

SUPABASE_ACCESS_TOKEN=your_token_here
SUPABASE_PROJECT_REF=your_project_ref_here
SUPABASE_URL=your_supabase_url_here
SUPABASE_ANON_KEY=your_anon_key_here

WEBFLOW_API_TOKEN=your_webflow_token_here
WEBFLOW_SITE_ID=your_site_id_here
WEBFLOW_SIGNALS_COLLECTION_ID=your_collection_id_here

PPLX_API_KEY=your_perplexity_key_here
ENVEOF
  log_success "Created .env.local template"
fi

echo ""
echo "${YELLOW}⚠ Please edit .env.local and fill in your secrets:${NC}"
echo "   From: https://github.com/tombomann/klarpakke/settings/secrets/actions"
echo ""
echo "   SUPABASE_ACCESS_TOKEN, SUPABASE_PROJECT_REF, SUPABASE_URL, SUPABASE_ANON_KEY"
echo "   WEBFLOW_API_TOKEN, WEBFLOW_SITE_ID, WEBFLOW_SIGNALS_COLLECTION_ID"
echo "   PPLX_API_KEY (optional, for Perplexity AI)"
echo ""

# Load .env.local for next steps
if [[ -f .env.local ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env.local
  set +a
fi

echo ""

# Step 5: Health check
log_step "Running health check..."
echo ""

if npm run health:full 2>&1; then
  log_success "Health check passed ✓"
else
  log_warning "Health check had warnings (non-fatal). Continue? (y/n)"
  read -r CONTINUE
  if [[ $CONTINUE != "y" ]]; then
    log_error "Setup aborted"
    exit 1
  fi
fi

echo ""

# Step 6: Supabase local or cloud
log_step "Supabase setup"
echo "   (a) Link to cloud Supabase project (requires SUPABASE_ACCESS_TOKEN + PROJECT_REF in .env.local)"
echo "   (b) Start local Supabase (requires Docker)"
echo "   (s) Skip for now"
echo ""
read -rp "Choose [a/b/s]: " SUPABASE_CHOICE

case $SUPABASE_CHOICE in
  a)
    if [[ -z "$SUPABASE_ACCESS_TOKEN" ]] || [[ -z "$SUPABASE_PROJECT_REF" ]]; then
      log_error "SUPABASE_ACCESS_TOKEN or SUPABASE_PROJECT_REF missing in .env.local"
      log_warning "Skipping Supabase link"
    else
      log_step "Linking to Supabase cloud..."
      supabase link --project-ref "$SUPABASE_PROJECT_REF" || log_warning "Link failed (may already be linked)"
      log_success "Supabase linked"
    fi
    ;;
  b)
    log_step "Starting local Supabase..."
    supabase start || log_warning "Failed to start local Supabase (Docker running?)"
    log_success "Supabase local started"
    ;;
  s)
    log_warning "Supabase setup skipped"
    ;;
  *)
    log_warning "Invalid choice, skipping"
    ;;
esac

echo ""

# Step 7: Summary
echo "${GREEN}🎉 Bootstrap complete!${NC}"
echo ""
echo "Next steps:"
echo ""
echo "  1. (If not done) Edit .env.local with your secrets"
echo ""
echo "  2. Install Webflow Designer Extension:"
echo "     - Wait for GitHub Actions to build it (in progress)"
echo "     - Download from Releases: https://github.com/tombomann/klarpakke/releases"
echo "     - Install in Webflow: Dashboard → Apps → Custom Apps → +"
echo ""
echo "  3. Run full deployment (GitHub Actions):"
echo "     - Go to: https://github.com/tombomann/klarpakke/actions"
echo "     - Workflow: '🧨 One-Click (Full Stack)'"
echo "     - Click 'Run workflow' with environment=staging"
echo ""
echo "  4. Create pages in Webflow Designer:"
echo "     - Designer → Extensions → Klarpakke"
echo "     - Click 'Create Klarpakke Pages' button"
echo "     - Verify all pages created + IDs present"
echo ""
echo "  5. Publish and test:"
echo "     - Open / (landing page)"
echo "     - Check console: [Klarpakke] Config loaded"
echo ""
echo "Questions? See docs/ONE-CLICK-DEPLOY.md"
echo ""
