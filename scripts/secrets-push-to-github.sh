#!/bin/bash
set -e

echo "📤 Pushing secrets to GitHub..."

# Load .env
set -a
source .env
set +a

# Push each secret to GitHub
gh secret set SUPABASE_URL -b"$SUPABASE_URL"
gh secret set SUPABASE_ANON_KEY -b"$SUPABASE_ANON_KEY"
gh secret set SUPABASE_SERVICE_KEY -b"$SUPABASE_SERVICE_KEY"
gh secret set WEBFLOW_API_TOKEN -b"$WEBFLOW_API_TOKEN"
gh secret set WEBFLOW_SITE_ID -b"$WEBFLOW_SITE_ID"
gh secret set WEBFLOW_SIGNALS_COLLECTION_ID -b"$WEBFLOW_SIGNALS_COLLECTION_ID"

echo "✅ Secrets pushed to GitHub!"
