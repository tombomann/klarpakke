#!/bin/bash
# Generate Webflow Custom Code with correct config
# Usage: bash scripts/generate-webflow-loader.sh [staging|production]

set -e

ENV=${1:-staging}
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Generating Webflow Custom Code for: ${ENV}${NC}"

# Load environment variables
if [ -f "$ROOT_DIR/.env" ]; then
    source "$ROOT_DIR/.env"
else
    echo -e "${RED}❌ .env file not found. Copy .env.example to .env and fill in values.${NC}"
    exit 1
fi

# Validate required variables
if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_ANON_KEY" ]; then
    echo -e "${RED}❌ Missing SUPABASE_URL or SUPABASE_ANON_KEY in .env${NC}"
    exit 1
fi

# Set debug mode based on environment
if [ "$ENV" = "production" ]; then
    DEBUG="false"
else
    DEBUG="true"
fi

# Generate the code
OUTPUT_FILE="$ROOT_DIR/web/snippets/webflow-footer-loader-${ENV}.html"

cat > "$OUTPUT_FILE" << EOF
<!-- Klarpakke Custom Code for ${ENV} -->
<!-- Generated: $(date +"%Y-%m-%d %H:%M:%S") -->
<!-- DO NOT EDIT MANUALLY - Use: npm run gen:webflow-loader -->

<script>
  // Runtime config injected by Webflow
  window.KLARPAKKE_CONFIG = {
    supabaseUrl: "${SUPABASE_URL}",
    supabaseAnonKey: "${SUPABASE_ANON_KEY}",
    debug: ${DEBUG}
  };
</script>
<script src="https://cdn.jsdelivr.net/gh/tombomann/klarpakke@main/web/klarpakke-site.js"></script>
EOF

echo -e "${GREEN}✅ Generated: ${OUTPUT_FILE}${NC}"
echo ""
echo -e "${YELLOW}📋 Next steps:${NC}"
echo "1. Copy the content below"
echo "2. Go to Webflow: Project Settings → Custom Code → Footer Code"
echo "3. Paste and Save"
echo "4. Publish to ${ENV}"
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════${NC}"
cat "$OUTPUT_FILE"
echo -e "${GREEN}═══════════════════════════════════════════════════${NC}"
echo ""

# Copy to clipboard if pbcopy is available (macOS)
if command -v pbcopy &> /dev/null; then
    cat "$OUTPUT_FILE" | pbcopy
    echo -e "${GREEN}✅ Copied to clipboard! (Cmd+V to paste)${NC}"
fi

echo ""
echo -e "${YELLOW}🔗 Webflow Dashboard:${NC}"
echo "https://webflow.com/dashboard/sites/klarpakke-c65071/settings/custom-code"
