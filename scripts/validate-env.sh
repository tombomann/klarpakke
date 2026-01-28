#!/bin/bash
# Validerer .env konfigurasjon
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

if [ ! -f .env ]; then
  echo -e "${RED}❌ .env fil mangler!${NC}"
  echo ""
  echo "Kjør: cp .env.example .env"
  echo "Deretter: nano .env (og fyll inn EKTE verdier)"
  exit 1
fi

echo "🔍 Validerer .env konfigurasjon..."
echo "====================================="
echo ""

# Last .env (safe parser; does not execute .env as shell code)
# shellcheck disable=SC1091
source scripts/load-dotenv.sh .env

# Validate SUPABASE_URL
if [ -z "${SUPABASE_URL:-}" ]; then
  echo -e "${RED}❌ SUPABASE_URL mangler${NC}"
  exit 1
elif [[ "$SUPABASE_URL" == *"YOUR_PROJECT"* ]] || [[ "$SUPABASE_URL" == *"..."* ]]; then
  echo -e "${RED}❌ SUPABASE_URL er placeholder-verdi${NC}"
  echo "   Korrekt format: https://swfyuwkptusceiouqlks.supabase.co"
  exit 1
else
  echo -e "${GREEN}✓ SUPABASE_URL: $SUPABASE_URL${NC}"
fi

# Validate SUPABASE_ANON_KEY
if [ -z "${SUPABASE_ANON_KEY:-}" ]; then
  echo -e "${RED}❌ SUPABASE_ANON_KEY mangler${NC}"
  exit 1
elif [[ "$SUPABASE_ANON_KEY" == "eyJhbGciOiJIUzI1NiI..." ]] || [[ "$SUPABASE_ANON_KEY" == *"..."* ]]; then
  echo -e "${RED}❌ SUPABASE_ANON_KEY er placeholder-verdi${NC}"
  echo "   Må starte med: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9."
  exit 1
elif [[ ! "$SUPABASE_ANON_KEY" =~ ^eyJ ]]; then
  echo -e "${RED}❌ SUPABASE_ANON_KEY har feil format${NC}"
  echo "   Må starte med: eyJ"
  exit 1
else
  echo -e "${GREEN}✓ SUPABASE_ANON_KEY: ${SUPABASE_ANON_KEY:0:30}...${NC}"
fi

# Validate SUPABASE_SECRET_KEY
if [ -z "${SUPABASE_SECRET_KEY:-}" ]; then
  echo -e "${YELLOW}⚠️  SUPABASE_SECRET_KEY mangler (valgfri)${NC}"
elif [[ "$SUPABASE_SECRET_KEY" == *"..."* ]]; then
  echo -e "${YELLOW}⚠️  SUPABASE_SECRET_KEY er placeholder-verdi${NC}"
elif [[ ! "$SUPABASE_SECRET_KEY" =~ ^eyJ ]]; then
  echo -e "${RED}❌ SUPABASE_SECRET_KEY har feil format${NC}"
  exit 1
else
  echo -e "${GREEN}✓ SUPABASE_SECRET_KEY: ${SUPABASE_SECRET_KEY:0:30}...${NC}"
fi

# Validate SUPABASE_ACCESS_TOKEN (for Supabase CLI)
if [ -z "${SUPABASE_ACCESS_TOKEN:-}" ]; then
  echo -e "${RED}❌ SUPABASE_ACCESS_TOKEN mangler${NC}"
  echo "   Generer på: https://supabase.com/dashboard/account/tokens"
  exit 1
elif [[ "$SUPABASE_ACCESS_TOKEN" == "sbp_x"* ]] || [[ "$SUPABASE_ACCESS_TOKEN" == *"..."* ]]; then
  echo -e "${RED}❌ SUPABASE_ACCESS_TOKEN er placeholder-verdi${NC}"
  echo "   Må starte med: sbp_ (etterfulgt av 40+ tegn)"
  exit 1
elif [[ ! "$SUPABASE_ACCESS_TOKEN" =~ ^sbp_ ]]; then
  echo -e "${RED}❌ SUPABASE_ACCESS_TOKEN har feil format${NC}"
  echo "   Må starte med: sbp_"
  exit 1
else
  echo -e "${GREEN}✓ SUPABASE_ACCESS_TOKEN: ${SUPABASE_ACCESS_TOKEN:0:10}...${NC}"
fi

# Validate SUPABASE_PROJECT_REF
if [ -z "${SUPABASE_PROJECT_REF:-}" ]; then
  echo -e "${RED}❌ SUPABASE_PROJECT_REF mangler${NC}"
  exit 1
elif [[ "$SUPABASE_PROJECT_REF" != "swfyuwkptusceiouqlks" ]]; then
  echo -e "${YELLOW}⚠️  SUPABASE_PROJECT_REF: $SUPABASE_PROJECT_REF${NC}"
  echo "   Forventet: swfyuwkptusceiouqlks"
else
  echo -e "${GREEN}✓ SUPABASE_PROJECT_REF: $SUPABASE_PROJECT_REF${NC}"
fi

# Validate PPLX_API_KEY (optional)
if [ -z "${PPLX_API_KEY:-}" ]; then
  echo -e "${YELLOW}⚠️  PPLX_API_KEY mangler (valgfri for AI-analyse)${NC}"
elif [[ "$PPLX_API_KEY" == "pplx-..." ]] || [[ "$PPLX_API_KEY" == *"..."* ]]; then
  echo -e "${YELLOW}⚠️  PPLX_API_KEY er placeholder-verdi${NC}"
elif [[ ! "$PPLX_API_KEY" =~ ^pplx- ]]; then
  echo -e "${RED}❌ PPLX_API_KEY har feil format${NC}"
  echo "   Må starte med: pplx-"
else
  echo -e "${GREEN}✓ PPLX_API_KEY: ${PPLX_API_KEY:0:10}...${NC}"
fi

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}✅ Konfigurasjon ser gyldig ut!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo "Neste steg:"
echo "  1. Test Supabase tilkobling:"
echo "     curl -X POST \"$SUPABASE_URL/functions/v1/debug-env\" \\" 
echo "       -H \"Authorization: Bearer $SUPABASE_ANON_KEY\" \\" 
echo "       -H \"Content-Type: application/json\" \\" 
echo "       -d '{\"test\": true}'"
echo ""
echo "  2. Deploy Edge Functions:"
echo "     npm run deploy:backend"
echo ""
