#!/bin/bash
# Auto-configure Make.com scenarios via API
set -euo pipefail

echo "🤖 Make.com Auto-Configuration"
echo "================================"
echo ""

# Check if .env exists
if [ ! -f ".env" ]; then
  echo "❌ .env not found"
  echo "Run: bash scripts/quick-fix-env.sh"
  exit 1
fi

source .env

# Check for Make.com API token
if [ -z "${MAKE_API_TOKEN:-}" ]; then
  echo "⚠️  MAKE_API_TOKEN not found in .env"
  echo ""
  echo "To get your Make.com API token:"
  echo "1. Go to: https://www.make.com/en/api-documentation/authentication"
  echo "2. Create API token"
  echo "3. Add to .env:"
  echo "   echo 'MAKE_API_TOKEN=your_token_here' >> .env"
  echo ""
  echo "For now, we'll generate setup instructions instead."
  echo ""
  
  # Generate .env template for Make.com
  cat > make/.env.make.example <<EOF
# Make.com Environment Variables
# Add these to your Make.com scenario settings

SUPABASE_URL=$SUPABASE_URL
SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
SUPABASE_SECRET_KEY=$SUPABASE_SECRET_KEY

# Get Perplexity API key from: https://www.perplexity.ai/settings/api
PERPLEXITY_API_KEY=pplx-...

# Optional: For Webflow sync (scenario 04)
WEBFLOW_API_TOKEN=...
WEBFLOW_COLLECTION_ID=...
EOF

  echo "✅ Created: make/.env.make.example"
  echo ""
  echo "Next steps:"
  echo "1. Get Perplexity API key: https://www.perplexity.ai/settings/api"
  echo "2. Copy values from make/.env.make.example to Make.com scenario settings"
  echo ""
  exit 0
fi

# If we have API token, attempt auto-configuration
echo "🚀 Attempting auto-configuration with Make.com API..."
echo ""

# TODO: Implement Make.com API integration
# This requires:
# 1. Make.com API token
# 2. Team/Organization ID
# 3. Scenario creation via API
# 4. Module configuration via API

echo "⚠️  Make.com API auto-configuration not yet implemented."
echo "Manual import required. See: make make-import"
echo ""
