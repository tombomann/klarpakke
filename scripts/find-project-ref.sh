#!/usr/bin/env bash
set -euo pipefail

# Find Supabase Project Ref using Management API
# Bypasses Supabase CLI issues

echo "🔍 Finding your Supabase Project Reference"
echo "=========================================="
echo ""

# Check if .env exists and has ACCESS_TOKEN
if [[ -f .env ]]; then
  set +e
  ACCESS_TOKEN=$(grep SUPABASE_ACCESS_TOKEN .env 2>/dev/null | cut -d'=' -f2 | tr -d '"' | tr -d "'" | xargs)
  set -e
fi

# Prompt for token if not found
if [[ -z "$ACCESS_TOKEN" ]]; then
  echo "🔐 Access Token kreves"
  echo ""
  echo "Hvor: https://supabase.com/dashboard/account/tokens"
  echo "Klikk 'Generate new token' om du ikke har det"
  echo ""
  read -p "Paste Access Token (sbp_...): " ACCESS_TOKEN
  echo ""
fi

# Validate token format
if [[ ! "$ACCESS_TOKEN" =~ ^sbp_ ]]; then
  echo "❌ Ugyldig token! Må starte med 'sbp_'"
  exit 1
fi

echo "✓ Token: ${ACCESS_TOKEN:0:10}..."
echo ""
echo "🚀 Henter prosjekter fra Supabase API..."
echo ""

# Call Supabase Management API
RESPONSE=$(curl -fsS \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  "https://api.supabase.com/v1/projects" 2>&1)

RESULT=$?

if [[ $RESULT -ne 0 ]]; then
  echo "❌ API-kall feilet!"
  echo ""
  echo "Mulige årsaker:"
  echo "  1. Ugyldig Access Token"
  echo "  2. Token har utløpt"
  echo "  3. Nettverksproblem"
  echo ""
  echo "Prøv å generere nytt token:"
  echo "https://supabase.com/dashboard/account/tokens"
  exit 1
fi

# Parse response (assumes jq is available, fallback to manual parsing)
if command -v jq &> /dev/null; then
  # Use jq if available
  PROJECT_COUNT=$(echo "$RESPONSE" | jq 'length')
  
  if [[ $PROJECT_COUNT -eq 0 ]]; then
    echo "⚠️  Ingen prosjekter funnet!"
    echo ""
    echo "Opprett et nytt prosjekt på:"
    echo "https://supabase.com/dashboard/new"
    exit 1
  fi
  
  echo "📋 Funnet $PROJECT_COUNT prosjekt(er):"
  echo ""
  echo "====================================="
  
  for i in $(seq 0 $((PROJECT_COUNT - 1))); do
    NAME=$(echo "$RESPONSE" | jq -r ".[$i].name")
    REF=$(echo "$RESPONSE" | jq -r ".[$i].id")
    REGION=$(echo "$RESPONSE" | jq -r ".[$i].region")
    STATUS=$(echo "$RESPONSE" | jq -r ".[$i].status")
    
    echo "Prosjekt $((i + 1)): $NAME"
    echo "  Project Ref: $REF"
    echo "  Region: $REGION"
    echo "  Status: $STATUS"
    echo ""
  done
  
  # If only one project, auto-select it
  if [[ $PROJECT_COUNT -eq 1 ]]; then
    SELECTED_REF=$(echo "$RESPONSE" | jq -r '.[0].id')
    SELECTED_NAME=$(echo "$RESPONSE" | jq -r '.[0].name')
    
    echo "====================================="
    echo "✅ Auto-selected: $SELECTED_NAME"
    echo "   Project Ref: $SELECTED_REF"
    echo ""
    
    # Update .env
    if [[ -f .env ]]; then
      # Backup
      cp .env .env.backup.$(date +%Y%m%d_%H%M%S)
      
      # Update or add PROJECT_REF
      if grep -q "SUPABASE_PROJECT_REF=" .env; then
        # Use | as delimiter to avoid issues with / in sed
        sed -i.bak "s|SUPABASE_PROJECT_REF=.*|SUPABASE_PROJECT_REF=$SELECTED_REF|" .env
        rm -f .env.bak
      else
        echo "SUPABASE_PROJECT_REF=$SELECTED_REF" >> .env
      fi
      
      echo "💾 .env oppdatert med riktig Project Ref"
      echo ""
    else
      echo "📝 Lag .env-fil med:"
      echo "   SUPABASE_PROJECT_REF=$SELECTED_REF"
      echo ""
    fi
    
    # Update GitHub Secret
    read -p "Vil du oppdatere GitHub Secret SUPABASE_PROJECT_REF? (y/n): " UPDATE_GH
    if [[ "$UPDATE_GH" == "y" ]]; then
      echo "$SELECTED_REF" | gh secret set SUPABASE_PROJECT_REF
      echo "✓ GitHub Secret oppdatert!"
    fi
    
    echo ""
    echo "====================================="
    echo "✅ Setup fullført!"
    echo "====================================="
    echo ""
    echo "Nå kan du kjøre:"
    echo "  npm run ci:all"
    echo "  gh workflow run '🚀 Auto-Deploy Pipeline' --ref main -f environment=staging"
    echo ""
  else
    echo "====================================="
    echo ""
    read -p "Velg prosjektnummer (1-$PROJECT_COUNT): " CHOICE
    
    INDEX=$((CHOICE - 1))
    SELECTED_REF=$(echo "$RESPONSE" | jq -r ".[$INDEX].id")
    SELECTED_NAME=$(echo "$RESPONSE" | jq -r ".[$INDEX].name")
    
    echo ""
    echo "✓ Valgt: $SELECTED_NAME"
    echo "  Project Ref: $SELECTED_REF"
    echo ""
    
    # Update .env
    if [[ -f .env ]]; then
      cp .env .env.backup.$(date +%Y%m%d_%H%M%S)
      
      if grep -q "SUPABASE_PROJECT_REF=" .env; then
        sed -i.bak "s|SUPABASE_PROJECT_REF=.*|SUPABASE_PROJECT_REF=$SELECTED_REF|" .env
        rm -f .env.bak
      else
        echo "SUPABASE_PROJECT_REF=$SELECTED_REF" >> .env
      fi
      
      echo "💾 .env oppdatert"
    fi
    
    # Update GitHub Secret
    read -p "Oppdater GitHub Secret? (y/n): " UPDATE_GH
    if [[ "$UPDATE_GH" == "y" ]]; then
      echo "$SELECTED_REF" | gh secret set SUPABASE_PROJECT_REF
      echo "✓ GitHub Secret oppdatert!"
    fi
  fi
  
else
  # Fallback: manual parsing without jq
  echo "⚠️  jq ikke funnet, viser raw response:"
  echo ""
  echo "$RESPONSE"
  echo ""
  echo "Finn 'id' feltet i JSON-en ovenfor."
  echo "Dette er din PROJECT_REF (20 bokstaver)."
  echo ""
  echo "Legg den til i .env:"
  echo "  echo 'SUPABASE_PROJECT_REF=<din-ref>' >> .env"
  echo ""
  echo "Og i GitHub Secrets:"
  echo "  gh secret set SUPABASE_PROJECT_REF"
fi
