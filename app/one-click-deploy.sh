#!/usr/bin/env bash
set -euo pipefail

echo "🚀 ONE-CLICK VERCEL DEPLOYMENT"
echo ""

# 1. Installer Vercel CLI
if ! command -v vercel &> /dev/null; then
  npm install -g vercel@latest
fi

# 2. Login (åpner browser)
echo "🔐 Logging in to Vercel..."
vercel login

# 3. Link project
echo ""
echo "🔗 Linking project (følg prompts)..."
vercel link

# 4. Deploy
echo ""
echo "🚀 Deploying..."
vercel --prod

# 5. Hent credentials
echo ""
if [[ -f .vercel/project.json ]]; then
  PROJECT_ID=$(cat .vercel/project.json | jq -r '.projectId')
  ORG_ID=$(cat .vercel/project.json | jq -r '.orgId')
  
  cat > ../VERCEL_SECRETS.txt <<EOF
VERCEL_PROJECT_ID=$PROJECT_ID
VERCEL_ORG_ID=$ORG_ID
VERCEL_TOKEN=[Get from https://vercel.com/account/tokens]
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
EOF
  
  echo "✅ Credentials saved to: ~/klarpakke/VERCEL_SECRETS.txt"
  cat ../VERCEL_SECRETS.txt
fi

echo ""
echo "=============================="
echo "✅ DEPLOYED TO VERCEL!"
echo "=============================="
echo ""
echo "📋 NESTE STEG:"
echo "1. Hent Vercel token: https://vercel.com/account/tokens"
echo "2. Sett GitHub secrets: https://github.com/tombomann/klarpakke/settings/secrets/actions"
echo "3. Se ~/klarpakke/VERCEL_SECRETS.txt for verdier"
echo ""
echo "🌐 Live: https://klarpakke.vercel.app"
echo ""

open https://vercel.com/account/tokens
open https://github.com/tombomann/klarpakke/settings/secrets/actions
