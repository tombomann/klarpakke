#!/bin/bash
# Fikser Supabase secrets deployment
set -euo pipefail

if [ ! -f .env ]; then
  echo "❌ .env mangler!"
  exit 1
fi

echo "🔐 Setter Supabase secrets..."

# Les hver linje og sett secret riktig
while IFS='=' read -r key value; do
  [[ $key =~ ^#.*$ ]] && continue
  [[ -z $key ]] && continue
  
  # Strip quotes og whitespace
  value=$(echo "$value" | sed -e 's/^["'"'"']*//' -e 's/["'"'"']*$//' | xargs)
  
  # Skip placeholder-verdier
  if [ -n "$value" ] && [[ ! "$value" =~ \.\.\. ]] && [[ ! "$value" =~ ^din_ ]] && [[ ! "$value" =~ ^YOUR_ ]]; then
    echo "→ Setting $key"
    supabase secrets set "$key=$value" --project-ref "$SUPABASE_PROJECT_REF" 2>&1 | grep -v "secret" || true
  fi
done < .env

echo "✅ Secrets oppdatert!"
