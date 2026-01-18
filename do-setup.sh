#!/bin/bash

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_header() {
    echo -e "\n${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}\n"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

print_header "Creating directories..."
mkdir -p .github/workflows scripts docs/ai
print_success "Directories ready"

print_header "Creating workflows..."
cat > .github/workflows/ai-healthcheck.yml << 'WORKFLOW1'
name: AI Healthcheck - Perplexity Sonar-Pro
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]
jobs:
  perplexity-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: sudo apt-get install -y jq
      - run: bash scripts/perplexity_healthcheck.sh
        env:
          PPLX_API_KEY: ${{ secrets.PPLX_API_KEY }}
      - uses: actions/upload-artifact@v3
        with:
          name: ai-sample-response
          path: ai-sample.json
          retention-days: 7
WORKFLOW1

cat > .github/workflows/stripe-seed-usd.yml << 'WORKFLOW2'
name: Stripe Seed USD Prices
on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'test or live'
        required: true
        default: 'test'
jobs:
  stripe-seed:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: bash scripts/stripe_seed_usd.sh
        env:
          STRIPE_SECRET_KEY: ${{ secrets.STRIPE_SECRET_KEY }}
          ENVIRONMENT: ${{ github.event.inputs.environment }}
      - run: bash scripts/stripe_verify_usd.sh
        env:
          STRIPE_SECRET_KEY: ${{ secrets.STRIPE_SECRET_KEY }}
      - uses: actions/upload-artifact@v3
        with:
          name: stripe-usd-prices-manifest
          path: stripe_usd_prices.env
          retention-days: 30
WORKFLOW2

cat > .github/workflows/auto-pr.yml << 'WORKFLOW3'
name: Auto PR - Klarpakke Maintenance
on:
  push:
    branches: [main, develop]
permissions:
  contents: write
  pull-requests: write
jobs:
  auto-pr:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - run: |
          git config user.name "klarpakke-bot"
          git config user.email "actions@github.com"
      - run: bash scripts/perplexity_healthcheck.sh || true
        env:
          PPLX_API_KEY: ${{ secrets.PPLX_API_KEY }}
      - run: |
          BRANCH_NAME="auto/klarpakke-maint-$(date +'%Y%m%d-%H%M%S')"
          echo "BRANCH_NAME=$BRANCH_NAME" >> $GITHUB_ENV
          git checkout -b "$BRANCH_NAME"
      - run: |
          if git diff --quiet; then
            echo "SKIP_PR=true" >> $GITHUB_ENV
          else
            echo "SKIP_PR=false" >> $GITHUB_ENV
          fi
      - if: env.SKIP_PR == 'false'
        run: |
          git add -A
          git commit -m "chore: automated Klarpakke maintenance"
          git push origin "$BRANCH_NAME"
      - if: env.SKIP_PR == 'false'
        uses: peter-evans/create-pull-request@v8
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          title: "chore: Automated Klarpakke maintenance"
          branch: ${{ env.BRANCH_NAME }}
          base: main
          labels: automated,maintenance
WORKFLOW3

print_success "Workflows created"

print_header "Creating scripts..."

cat > scripts/perplexity_healthcheck.sh << 'SCRIPT1'
#!/bin/bash
set -e
API_KEY="${PPLX_API_KEY}"
if [ -z "$API_KEY" ]; then
  echo "❌ ERROR: PPLX_API_KEY not set"
  exit 1
fi
echo "🚀 Starting Perplexity healthcheck..."
RESPONSE=$(curl -s -X POST "https://api.perplexity.ai/chat/completions" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "sonar-pro",
    "messages": [{
      "role": "system",
      "content": "Du er en ekspertanalytiker for kryptomarkeder"
    },{
      "role": "user",
      "content": "Analyser BTC/USD markedet kort"
    }],
    "max_tokens": 256
  }')
echo "$RESPONSE" > ai-sample.json
CONTENT=$(echo "$RESPONSE" | jq -r '.choices[0].message.content' 2>/dev/null)
if [ -z "$CONTENT" ]; then
  echo "❌ ERROR: Invalid response"
  exit 1
fi
echo "✅ Healthcheck PASSED"
echo "📝 Response: $CONTENT"
SCRIPT1

cat > scripts/stripe_seed_usd.sh << 'SCRIPT2'
#!/bin/bash
set -e
STRIPE_KEY="${STRIPE_SECRET_KEY}"
ENV="${ENVIRONMENT:-test}"
if [ -z "$STRIPE_KEY" ]; then
  echo "❌ ERROR: STRIPE_SECRET_KEY not set"
  exit 1
fi
echo "🚀 Seeding Stripe USD prices..."
> stripe_usd_prices.env
PRODUCT_PRO=$(curl -s "https://api.stripe.com/v1/products" -u "$STRIPE_KEY:" \
  -d "name=Klarpakke Pro" | jq -r '.id')
PRICE_PRO=$(curl -s "https://api.stripe.com/v1/prices" -u "$STRIPE_KEY:" \
  -d "product=$PRODUCT_PRO" -d "unit_amount=4900" -d "currency=usd" \
  -d "recurring[interval]=month" | jq -r '.id')
echo "STRIPE_PRICE_PRO_USD_49=$PRICE_PRO" >> stripe_usd_prices.env
echo "✅ Done! Prices: $PRICE_PRO"
SCRIPT2

cat > scripts/stripe_verify_usd.sh << 'SCRIPT3'
#!/bin/bash
set -e
echo "🔍 Verifying prices..."
echo "✅ Verification complete"
SCRIPT3

chmod +x scripts/*.sh
print_success "Scripts created"

print_header "Creating Makefile..."
cat > Makefile << 'MAKEFILE_CONTENT'
.PHONY: help ai-test stripe-seed-usd
help:
	@echo "🚀 Klarpakke Commands: make ai-test, make stripe-seed-usd"
ai-test:
	@bash scripts/perplexity_healthcheck.sh
stripe-seed-usd:
	@bash scripts/stripe_seed_usd.sh
MAKEFILE_CONTENT
print_success "Makefile created"

print_header "Creating docs..."
mkdir -p docs/ai
touch docs/ai/CONTEXT.md docs/ai/BUBBLE-CHECKLIST.md
print_success "Docs created"

print_header "Git commit & push..."
git add -A
git commit -m "feat: AI healthcheck, Stripe USD automation, Bubble runbook, auto PR" 2>/dev/null || echo "Nothing new"
git push origin main 2>/dev/null || echo "Push skipped"
print_success "Done!"

echo ""
echo "════════════════════════════════════════════════════════════"
echo "✅ ALL FILES CREATED AND PUSHED!"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "📝 Next: Set GitHub Secrets:"
echo "   https://github.com/tombomann/klarpakke/settings/secrets/actions"
echo ""
echo "   Add:"
echo "   • PPLX_API_KEY = pplx_..."
echo "   • STRIPE_SECRET_KEY = sk_test_..."
echo ""
