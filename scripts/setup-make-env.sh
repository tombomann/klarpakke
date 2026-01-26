#!/bin/bash
# Generate Make.com environment variables file
set -euo pipefail

echo "🔧 Make.com Environment Setup"
echo "============================"
echo ""

if [ ! -f ".env" ]; then
  echo "❌ .env not found. Run: bash scripts/quick-fix-env.sh"
  exit 1
fi

source .env

# Create make directory if it doesn't exist
mkdir -p make

# Generate .env file for Make.com
cat > make/.env.make <<EOF
# ============================================
# Make.com Environment Variables
# ============================================
# Copy these values to your Make.com scenario settings:
# Settings (gear icon) → Environment variables
#
# For ALL scenarios (01-04):

SUPABASE_URL=$SUPABASE_URL
SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
SUPABASE_SECRET_KEY=$SUPABASE_SECRET_KEY

# For scenario 01 (Trading Signal Generator):
# Get your Perplexity API key from: https://www.perplexity.ai/settings/api
PERPLEXITY_API_KEY=pplx-your-key-here

# For scenario 04 (Webflow Sync) - OPTIONAL:
# Get Webflow API token from: https://webflow.com/dashboard/account/apps
WEBFLOW_API_TOKEN=your-webflow-token
WEBFLOW_COLLECTION_ID=your-collection-id

# ============================================
# How to use:
# ============================================
# 1. Open Make.com scenario
# 2. Click gear icon (⚙️) → "Scenario settings"
# 3. Go to "Environment variables" tab
# 4. Add each variable above (name + value)
# 5. Save
# 6. Test with "Run once"
EOF

echo "✅ Created: make/.env.make"
echo ""
echo "Next steps:"
echo "1. Get Perplexity API key:"
echo "   https://www.perplexity.ai/settings/api"
echo ""
echo "2. Add to make/.env.make:"
echo "   PERPLEXITY_API_KEY=pplx-..."
echo ""
echo "3. View the file:"
echo "   cat make/.env.make"
echo ""
echo "4. Copy all variables to Make.com scenario settings"
echo ""

# Show the file content
cat make/.env.make
