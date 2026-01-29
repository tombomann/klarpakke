#!/bin/bash
set -e

echo "📥 Pulling secrets from Supabase..."

# Get secrets from Supabase
SECRETS=$(supabase secrets list --format json)

echo "$SECRETS" | jq -r '.[] | "\(.name)=\(.value)"' > .env.supabase

echo "✅ Secrets saved to .env.supabase"
echo "   Review and merge into .env manually"
