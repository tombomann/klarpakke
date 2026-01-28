#!/usr/bin/env bash
set -euo pipefail

# Interactive Supabase Environment Setup
# Bruker Supabase CLI til å hente alle nødvendige credentials

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "🚀 Klarpakke Supabase Setup"
echo "============================="
echo ""

# Check if Supabase CLI is installed
if ! command -v supabase >/dev/null 2>&1; then
  echo "❌ Supabase CLI er ikke installert!"
  echo ""
  echo "Installer med:"
  echo "  npm install -g supabase"
  echo ""
  echo "Eller (Homebrew):"
  echo "  brew install supabase/tap/supabase"
  exit 1
fi

echo "✓ Supabase CLI funnet: $(supabase --version)"
echo ""

# Load existing .env if present
EXISTING_TOKEN=""
if [[ -f .env ]]; then
  echo "📁 Fant eksisterende .env-fil"
  set +e
  EXISTING_TOKEN=$(grep SUPABASE_ACCESS_TOKEN .env 2>/dev/null | cut -d'=' -f2 | tr -d '"' | tr -d "'" | xargs)
  set -e
  
  if [[ -n "$EXISTING_TOKEN" && "$EXISTING_TOKEN" =~ ^sbp_ ]]; then
    echo "✓ Fant gyldig Access Token i .env"
    echo ""
  fi
fi

# Step 1: Login
echo "📝 Steg 1: Login til Supabase"
echo "-----------------------------"

if [[ -n "$EXISTING_TOKEN" && "$EXISTING_TOKEN" =~ ^sbp_ ]]; then
  echo "Bruker eksisterende token fra .env..."
  if supabase login --token "$EXISTING_TOKEN" 2>/dev/null; then
    echo "✓ Logget inn med eksisterende token!"
  else
    echo "⚠️  Eksisterende token fungerte ikke, prøver interaktiv login..."
    EXISTING_TOKEN=""
  fi
fi

if [[ -z "$EXISTING_TOKEN" ]]; then
  echo "Dette vil åpne nettleseren for innlogging."
  echo "Om du allerede har en Access Token, kan du paste den direkte."
  echo ""
  read -p "Trykk Enter for å fortsette..."

  if ! supabase login; then
    echo ""
    echo "❌ Login feilet. Prøv igjen eller lag Access Token manuelt:"
    echo "   https://supabase.com/dashboard/account/tokens"
    echo ""
    echo "Når du har token (starter med sbp_...), legg den til i .env:"
    echo "   echo 'SUPABASE_ACCESS_TOKEN=sbp_...' >> .env"
    echo ""
    echo "Kjør så dette scriptet igjen."
    exit 1
  fi
fi

echo ""
echo "✓ Logget inn!"
echo ""

# Step 2: List projects
echo "📋 Steg 2: Velg prosjekt"
echo "------------------------"
echo "Henter liste over dine Supabase-prosjekt..."
echo ""

supabase projects list

echo ""
read -p "Skriv inn Project Reference ID (20-tegns ID fra 'Reference ID'-kolonnen): " PROJECT_REF

# Validate Project Ref format
if [[ ! "$PROJECT_REF" =~ ^[a-z]{20}$ ]]; then
  echo "❌ Ugyldig format! Project Ref må være eksakt 20 små bokstaver."
  echo "   Eksempel: abcdefghijklmnopqrst"
  exit 1
fi

echo ""
echo "✓ Project Ref: $PROJECT_REF"
echo ""

# Step 3: Link project
echo "🔗 Steg 3: Kobler til prosjekt..."
echo "----------------------------------"

if ! supabase link --project-ref "$PROJECT_REF"; then
  echo "❌ Kunne ikke koble til prosjekt. Sjekk at Project Ref er korrekt."
  exit 1
fi

echo ""
echo "✓ Koblet til prosjekt!"
echo ""

# Step 4: Get API keys
echo "🔑 Steg 4: Henter API-nøkler..."
echo "-------------------------------"

# Get project URL (derived from Project Ref)
PROJECT_URL="https://${PROJECT_REF}.supabase.co"

# Use Supabase CLI to get API keys
echo "Henter nøkler via CLI..."
KEYS_OUTPUT=$(supabase projects api-keys --project-ref "$PROJECT_REF" 2>&1 || true)

if [[ -z "$KEYS_OUTPUT" ]] || [[ "$KEYS_OUTPUT" =~ "error" ]]; then
  echo "⚠️  Kunne ikke hente nøkler automatisk via CLI."
  echo ""
  echo "Åpner Supabase Dashboard for manuell henting..."
  echo "Gå til: https://supabase.com/dashboard/project/$PROJECT_REF/settings/api"
  echo ""
  
  read -p "Paste ANON key (starter med eyJhbGc...): " ANON_KEY
  read -p "Paste SERVICE_ROLE key (starter med eyJhbGc...): " SERVICE_KEY
else
  # Parse keys from output
  ANON_KEY=$(echo "$KEYS_OUTPUT" | grep -i "anon" | awk '{print $NF}' | tr -d '\n')
  SERVICE_KEY=$(echo "$KEYS_OUTPUT" | grep -i "service" | awk '{print $NF}' | tr -d '\n')
  
  echo "✓ Anon key: ${ANON_KEY:0:20}..."
  echo "✓ Service role key: ${SERVICE_KEY:0:20}..."
fi

echo ""

# Step 5: Get Access Token
echo "🎫 Steg 5: Henter Access Token..."
echo "---------------------------------"

ACCESS_TOKEN="$EXISTING_TOKEN"

if [[ -z "$ACCESS_TOKEN" ]]; then
  if [[ -f ~/.supabase/access-token ]]; then
    ACCESS_TOKEN=$(cat ~/.supabase/access-token)
    echo "✓ Fant Access Token fra CLI: ${ACCESS_TOKEN:0:10}..."
  else
    echo "⚠️  Access Token ikke funnet lokalt."
    echo ""
    echo "Hent den fra: https://supabase.com/dashboard/account/tokens"
    read -p "Paste Access Token (starter med sbp_...): " ACCESS_TOKEN
  fi
else
  echo "✓ Bruker Access Token fra .env: ${ACCESS_TOKEN:0:10}..."
fi

echo ""

# Validate Access Token format
if [[ ! "$ACCESS_TOKEN" =~ ^sbp_ ]]; then
  echo "❌ Ugyldig Access Token format! Må starte med 'sbp_'"
  echo "   Hent ny token fra: https://supabase.com/dashboard/account/tokens"
  exit 1
fi

echo "✓ Access Token: ${ACCESS_TOKEN:0:10}..."
echo ""

# Step 6: Write .env file
echo "💾 Steg 6: Lagrer til .env"
echo "--------------------------"

# Backup existing .env if it exists
if [[ -f .env ]]; then
  cp .env .env.backup.$(date +%Y%m%d_%H%M%S)
  echo "✓ Backup av eksisterende .env opprettet"
fi

cat > .env << EOF
# Supabase Configuration
# Generated by setup-supabase-env.sh on $(date)

# Project Settings
SUPABASE_PROJECT_REF=$PROJECT_REF
SUPABASE_URL=$PROJECT_URL

# API Keys
SUPABASE_ANON_KEY=$ANON_KEY
SUPABASE_SERVICE_ROLE_KEY=$SERVICE_KEY

# CLI Access Token (for deployment)
SUPABASE_ACCESS_TOKEN=$ACCESS_TOKEN

# Optional: Add other keys below
# PPLX_API_KEY=
# WEBFLOW_API_TOKEN=
EOF

echo ""
echo "✓ .env opprettet!"
echo ""

# Step 7: Verify setup
echo "✅ Steg 7: Verifiserer setup..."
echo "--------------------------------"

# Load .env
set -a
source .env
set +a

echo "Sjekker Project Ref lengde..."
if [[ ${#SUPABASE_PROJECT_REF} -eq 20 ]]; then
  echo "  ✓ PROJECT_REF: $SUPABASE_PROJECT_REF (lengde: 20)"
else
  echo "  ❌ PROJECT_REF har feil lengde: ${#SUPABASE_PROJECT_REF} (skal være 20)"
fi

echo "Sjekker Access Token format..."
if [[ "$SUPABASE_ACCESS_TOKEN" =~ ^sbp_ ]]; then
  echo "  ✓ ACCESS_TOKEN starter med 'sbp_'"
else
  echo "  ❌ ACCESS_TOKEN har feil format (skal starte med 'sbp_')"
fi

echo "Tester Supabase connectivity..."
if curl -fsS -H "apikey: $SUPABASE_ANON_KEY" "$SUPABASE_URL/rest/v1/" >/dev/null 2>&1; then
  echo "  ✓ API-tilkobling fungerer!"
else
  echo "  ⚠️  Kunne ikke koble til API (kan være RLS-policy)"
fi

echo ""
echo "============================="
echo "✅ Setup fullført!"
echo "============================="
echo ""
echo "📋 Neste steg:"
echo ""
echo "1. Test lokal deploy:"
echo "   npm run ci:all"
echo ""
echo "2. Oppdater GitHub Secrets:"
echo "   bash scripts/sync-github-secrets.sh"
echo ""
echo "3. Trigger CI/CD pipeline:"
echo "   gh workflow run '🚀 Auto-Deploy Pipeline' --ref main -f environment=staging"
echo ""
echo "📁 .env-fil lagret i: $ROOT_DIR/.env"
echo ""
