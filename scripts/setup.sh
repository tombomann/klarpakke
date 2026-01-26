#!/bin/bash
set -euo pipefail

# Fixed setup for Klarpakke

PROJECT_REF="swfyuwkptusceiouqlks"

if [[ -z ${SUPABASE_PROJECT_ID:-} ]]; then
  export SUPABASE_PROJECT_ID=$PROJECT_REF
fi

echo "→ Using PID: $SUPABASE_PROJECT_ID"

# Git
git checkout main
git pull origin main

# DB
supabase db push

# Keys
echo "→ Fetching keys..."
SUPABASE_URL="https://$SUPABASE_PROJECT_ID.supabase.co"
SUPABASE_ANON_KEY=$(supabase projects api-keys --project-ref "$SUPABASE_PROJECT_ID" --output json | jq -r '.anon')
SUPABASE_SERVICE_KEY=$(supabase projects api-keys --project-ref "$SUPABASE_PROJECT_ID" --output json | jq -r '.service_role')

# Secrets
gh secret set SUPABASE_URL --body "$SUPABASE_URL" --repo tombomann/klarpakke
gh secret set SUPABASE_ANON_KEY --body "$SUPABASE_ANON_KEY" --repo tombomann/klarpakke
gh secret set SUPABASE_SERVICE_ROLE_KEY --body "$SUPABASE_SERVICE_KEY" --repo tombomann/klarpakke

# Next.js (idempotent)
if [[ ! -f package.json || ! grep -q next package.json ]]; then
  rm -rf .next node_modules package-lock.json
  npx create-next-app@latest . --typescript --tailwind --app --no-src-dir --import-alias "@/*" --use-npm --yes
  npm i @supabase/supabase-js
  mkdir -p lib
  cat > lib/supabase.ts << 'LIB'
import { createClient } from '@supabase/supabase-js'
const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
export const supabase = createClient(supabaseUrl, supabaseAnonKey)
LIB
  cat > .env.local << ENV
NEXT_PUBLIC_SUPABASE_URL=$SUPABASE_URL
NEXT_PUBLIC_SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
ENV
fi

# Supabase local
supabase link --project-ref "$SUPABASE_PROJECT_ID"
supabase status

# Webflow
webflow auth login

# RLS Policies
cat > supabase/migrations/20260126_rls.sql << RLS
ALTER TABLE position_tracking ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_risk_meter ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Enable read access for all users" ON ai_signals FOR SELECT USING (true);
CREATE POLICY "Users own positions" ON position_tracking FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users own risk meter" ON daily_risk_meter FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
RLS
supabase db push

npm run dev

echo "✅ Full setup! Visit http://localhost:3000"