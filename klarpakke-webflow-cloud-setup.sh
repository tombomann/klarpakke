#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="${HOME}/klarpakke"
cd "$REPO_ROOT"

echo "🎯 Webflow Cloud + Supabase Setup"

# Installer Webflow CLI
if ! command -v webflow &> /dev/null; then
  echo "📦 Installerer Webflow CLI..."
  npm install -g @webflow/cli
else
  echo "✅ Webflow CLI allerede installert"
fi

# Autentiser
echo "🔐 Kjør: webflow auth login"
echo "⚠️  Dette åpner browser - kjør manuelt etter dette scriptet"
echo ""

# Sjekk om webflow-cloud-app eksisterer
if [[ ! -d "webflow-cloud-app" ]]; then
  echo "🏗️  Opprett Next.js app..."
  
  npx create-next-app@latest webflow-cloud-app \
    --typescript \
    --tailwind \
    --app \
    --no-src-dir \
    --import-alias "@/*" \
    --no-git
  
  cd webflow-cloud-app
  
  # Installer Supabase
  npm install @supabase/supabase-js
  
  # Lag lib directory
  mkdir -p lib
  
  # Lag Supabase client
  cat > lib/supabase.ts <<'EOTS'
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || ''
const supabaseKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || ''

export const supabase = createClient(supabaseUrl, supabaseKey)

export async function getActiveSignals() {
  const { data, error } = await supabase
    .from('signals')
    .select('*')
    .eq('status', 'active')
    .order('created_at', { ascending: false })
    .limit(10)
  
  if (error) throw error
  return data || []
}
EOTS

  # Lag signals page
  mkdir -p app/signals
  cat > app/signals/page.tsx <<'EOTS'
import { getActiveSignals } from '@/lib/supabase'

export const dynamic = 'force-dynamic'

export default async function SignalsPage() {
  const signals = await getActiveSignals()
  
  return (
    <div className="container mx-auto py-8">
      <h1 className="text-3xl font-bold mb-6">Aktive Trading Signals</h1>
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
        {signals.map((signal: any) => (
          <div key={signal.id} className="border rounded-lg p-4">
            <h3 className="text-xl font-semibold">{signal.ticker}</h3>
            <p className="text-gray-600">{signal.strategy}</p>
            <span className="text-green-600">Entry: {signal.entry_price}</span>
          </div>
        ))}
      </div>
    </div>
  )
}
EOTS

  # Lag .env.local template
  cat > .env.local.template <<'EOTS'
NEXT_PUBLIC_SUPABASE_URL=https://xxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJ...
EOTS

  echo ""
  echo "✅ Setup fullført!"
  echo ""
  echo "📋 NESTE STEG:"
  echo "1. cd webflow-cloud-app"
  echo "2. Kopier .env.local.template til .env.local"
  echo "3. Fyll inn Supabase credentials"
  echo "4. npm run dev"
  echo "5. webflow auth login (i ny terminal)"
  echo "6. webflow init"
  
else
  echo "⚠️  webflow-cloud-app eksisterer allerede"
  echo "   Slett den først hvis du vil starte på nytt:"
  echo "   rm -rf webflow-cloud-app"
fi
