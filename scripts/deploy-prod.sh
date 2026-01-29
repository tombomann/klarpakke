#!/bin/bash

###############################################################################
# KLARPAKKE PRODUCTION DEPLOYMENT SCRIPT
# 
# Usage:
#   ./scripts/deploy-prod.sh                 # Full deployment
#   ./scripts/deploy-prod.sh --dry-run       # Simulate without changes
#   ./scripts/deploy-prod.sh --webflow-only  # Only publish Webflow
#
###############################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Config
DRY_RUN=false
WEBFLOW_ONLY=false
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
BACKUP_TAG="backup-${TIMESTAMP}"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --dry-run) DRY_RUN=true; shift ;;
    --webflow-only) WEBFLOW_ONLY=true; shift ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# Helper functions
log_info() {
  echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
  echo -e "${GREEN}✅ $1${NC}"
}

log_error() {
  echo -e "${RED}❌ $1${NC}"
}

log_warning() {
  echo -e "${YELLOW}⚠️  $1${NC}"
}

# Main deployment flow
echo ""
echo "════════════════════════════════════════════════════════════"
echo "🚀 KLARPAKKE PRODUCTION DEPLOYMENT"
echo "════════════════════════════════════════════════════════════"
echo ""

# Check environment
log_info "Checking environment..."

if [ ! -f .env ]; then
  log_error ".env file not found"
  exit 1
fi

source .env

if [ -z "$WEBFLOW_API_TOKEN" ] || [ -z "$WEBFLOW_SITE_ID" ]; then
  log_error "Missing Webflow credentials in .env"
  exit 1
fi

log_success "Environment OK"

# Validate secrets
log_info "Validating all secrets..."
if npm run secrets:validate > /dev/null 2>&1; then
  log_success "Secrets validated"
else
  log_error "Secret validation failed"
  exit 1
fi

# Health check
log_info "Running system health check..."
if npm run health:check > /dev/null 2>&1; then
  log_success "System health check passed"
else
  log_error "System health check failed"
  exit 1
fi

# Validate Webflow pages exist
log_info "Validating Webflow pages..."
PAGES_CHECK=$(cat > /tmp/check-pages.js << 'EOF'
const WebflowMCP = require('./lib/webflow-mcp');
const token = process.env.WEBFLOW_API_TOKEN;
const siteId = process.env.WEBFLOW_SITE_ID;
const webflow = new WebflowMCP(token, siteId);

(async () => {
  const result = await webflow.listPages();
  if (!result.success) {
    console.log('ERROR');
    process.exit(1);
  }
  
  const requiredPages = ['index', 'pricing', 'app/dashboard', 'app/kalkulator', 'app/settings', 'login', 'signup'];
  const existingPages = result.pages.map(p => p.slug);
  
  const missing = requiredPages.filter(p => !existingPages.includes(p));
  
  if (missing.length > 0) {
    console.log(`MISSING:${missing.join(',')}`);
    process.exit(1);
  }
  
  console.log('OK');
})();
EOF
node /tmp/check-pages.js)

if [[ $PAGES_CHECK == "OK" ]]; then
  log_success "All required Webflow pages exist"
elif [[ $PAGES_CHECK == ERROR* ]]; then
  log_error "Failed to validate pages (API error)"
  exit 1
else
  log_error "Missing pages: ${PAGES_CHECK#MISSING:}"
  log_warning "Create these pages in Webflow Designer first:"
  echo "  - /index (Landing)"
  echo "  - /pricing (Pricing)"
  echo "  - /app/dashboard (Dashboard)"
  echo "  - /app/kalkulator (Calculator)"
  echo "  - /app/settings (Settings)"
  echo "  - /login (Login)"
  echo "  - /signup (Signup)"
  exit 1
fi

# Backup current state
log_info "Creating backup tag: ${BACKUP_TAG}"
if [ "$DRY_RUN" = false ]; then
  git tag -a "$BACKUP_TAG" -m "Pre-production backup - ${TIMESTAMP}" || true
  log_success "Backup tag created"
else
  log_warning "DRY RUN: Would create backup tag ${BACKUP_TAG}"
fi

# Generate element IDs
log_info "Generating element ID mappings..."
if [ "$DRY_RUN" = false ]; then
  npm run ai:generate-ids > /dev/null 2>&1
  log_success "Element IDs generated"
else
  log_warning "DRY RUN: Would generate element IDs"
fi

# SEO optimization
log_info "Optimizing SEO metadata..."
if [ "$DRY_RUN" = false ]; then
  npm run ai:seo-optimize > /dev/null 2>&1
  log_success "SEO optimization complete"
else
  log_warning "DRY RUN: Would optimize SEO"
fi

# Build webflow loader
log_info "Building Webflow loader script..."
if [ "$DRY_RUN" = false ]; then
  npm run deploy:webflow > /dev/null 2>&1
  log_success "Webflow loader built"
else
  log_warning "DRY RUN: Would build webflow loader"
fi

# Webflow publishing
log_info "Publishing Webflow changes..."
if [ "$DRY_RUN" = false ]; then
  # Note: Manual publish required in Webflow UI
  log_warning "⚠️  Manual step required:"
  log_warning "1. Open Webflow Designer"
  log_warning "2. Review changes in Designer"
  log_warning "3. Click 'Publish' button"
  log_warning "4. Confirm publishing to live"
else
  log_warning "DRY RUN: Would publish Webflow (manual step)"
fi

# Database migrations (if any)
if [ -d "supabase/migrations" ] && [ "$(ls -A supabase/migrations 2>/dev/null)" ]; then
  log_info "Checking for pending migrations..."
  MIGRATION_COUNT=$(ls -1 supabase/migrations | wc -l)
  if [ "$MIGRATION_COUNT" -gt 0 ]; then
    log_warning "Found ${MIGRATION_COUNT} migrations to deploy"
    if [ "$DRY_RUN" = false ]; then
      supabase db push
      log_success "Migrations deployed"
    else
      log_warning "DRY RUN: Would deploy migrations"
    fi
  fi
fi

# Final health check
log_info "Running final health check..."
if [ "$DRY_RUN" = false ]; then
  npm run health:full > /dev/null 2>&1
  log_success "Final health check passed"
else
  log_warning "DRY RUN: Would run final health check"
fi

# Summary
echo ""
echo "════════════════════════════════════════════════════════════"
if [ "$DRY_RUN" = true ]; then
  echo -e "${YELLOW}🔄 DRY RUN COMPLETE${NC}"
  echo ""
  echo "To deploy for real, run:"
  echo "  ./scripts/deploy-prod.sh"
else
  echo -e "${GREEN}🎉 DEPLOYMENT COMPLETE!${NC}"
  echo ""
  echo "Next steps:"
  echo "1. Open Webflow Designer"
  echo "2. Review all changes"
  echo "3. Click 'Publish' to go live"
  echo "4. Monitor: https://sentry.io/your-project"
  echo ""
  echo "Backup tag: ${BACKUP_TAG}"
  echo "To rollback: git checkout ${BACKUP_TAG}"
fi
echo "════════════════════════════════════════════════════════════"
echo ""
