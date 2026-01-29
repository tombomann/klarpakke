#!/bin/bash
set -e

echo "📥 Pulling secrets from Supabase..."

# Correct syntax (no --format flag)
SECRETS=$(supabase secrets list -o json)

if [ -n "$SECRETS" ]; then
  echo "$SECRETS" | jq -r '.[] | "\(.name)=\(.value)"' > .env.supabase
  echo "✅ Secrets saved to .env.supabase"
  echo "   Review and merge into .env manually"
else
  echo "⚠️  No secrets found or not authenticated"
fi
