#!/bin/bash
set -e

echo "📤 Pushing secrets to Supabase..."

# Load .env
set -a
source .env
set +a

# Push each secret
supabase secrets set \
  WEBFLOW_API_TOKEN="$WEBFLOW_API_TOKEN" \
  WEBFLOW_SITE_ID="$WEBFLOW_SITE_ID" \
  WEBFLOW_SIGNALS_COLLECTION_ID="$WEBFLOW_SIGNALS_COLLECTION_ID"

echo "✅ Secrets pushed to Supabase!"
