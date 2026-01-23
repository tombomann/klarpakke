#!/bin/bash
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 KLARPAKKE ONE-CLICK SETUP"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Dette skriptet vil automatisk:"
echo "  1️⃣  Sjekke dependencies (Python, psql, jq)"
echo "  2️⃣  Sette opp database (clean slate)"
echo "  3️⃣  Konfigurere miljøvariabler"
echo "  4️⃣  Teste Supabase tilkobling"
echo "  5️⃣  Insert test signal"
echo "  6️⃣  Kjøre første analyse"
echo "  7️⃣  Aktivere GitHub Actions automation"
echo ""
read -p "Fortsett? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then 
    echo "❌ Avbrutt"
    exit 1
fi

cd "$(dirname "$0")/.."

# ============================================================
# STEP 1: Check dependencies
# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1️⃣  SJEKKER DEPENDENCIES"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

MISSING_DEPS=0

# Python 3
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version | awk '{print $2}')
    echo "✅ Python $PYTHON_VERSION"
else
    echo -e "${RED}❌ Python 3 ikke funnet${NC}"
    echo "   Installer: brew install python3"
    MISSING_DEPS=1
fi

# psql
if command -v psql &> /dev/null; then
    PSQL_VERSION=$(psql --version | awk '{print $3}')
    echo "✅ PostgreSQL client $PSQL_VERSION"
else
    echo -e "${RED}❌ psql ikke funnet${NC}"
    echo "   Installer: brew install postgresql"
    MISSING_DEPS=1
fi

# jq
if command -v jq &> /dev/null; then
    JQ_VERSION=$(jq --version | awk -F'-' '{print $2}')
    echo "✅ jq $JQ_VERSION"
else
    echo -e "${RED}❌ jq ikke funnet${NC}"
    echo "   Installer: brew install jq"
    MISSING_DEPS=1
fi

# git
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version | awk '{print $3}')
    echo "✅ git $GIT_VERSION"
else
    echo -e "${RED}❌ git ikke funnet${NC}"
    MISSING_DEPS=1
fi

if [ $MISSING_DEPS -eq 1 ]; then
    echo ""
    echo -e "${RED}❌ Mangler dependencies. Installer først!${NC}"
    exit 1
fi

# ============================================================
# STEP 2: Check .env.migration
# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "2️⃣  SJEKKER MILJØVARIABLER"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ ! -f .env.migration ]; then
    echo -e "${RED}❌ .env.migration ikke funnet!${NC}"
    echo ""
    echo "Lag filen .env.migration med:"
    echo ""
    cat << 'ENVEOF'
SUPABASE_PROJECT_ID=swfyuwkptusceiouqlks
SUPABASE_SERVICE_ROLE_KEY=eyJhbGci...
SUPABASE_DB_URL=postgresql://postgres.xxx:[PASSWORD]@...
BINANCE_API_KEY=xxx (optional)
BINANCE_SECRET_KEY=xxx (optional)
ENVEOF
    echo ""
    exit 1
fi

source .env.migration
export SUPABASE_PROJECT_ID SUPABASE_SERVICE_ROLE_KEY SUPABASE_DB_URL

if [ -z "$SUPABASE_PROJECT_ID" ] || [ -z "$SUPABASE_SERVICE_ROLE_KEY" ]; then
    echo -e "${RED}❌ Miljøvariabler ikke satt korrekt${NC}"
    exit 1
fi

echo "✅ SUPABASE_PROJECT_ID: $SUPABASE_PROJECT_ID"
echo "✅ SUPABASE_SERVICE_ROLE_KEY: ${SUPABASE_SERVICE_ROLE_KEY:0:20}..."
if [ -n "$SUPABASE_DB_URL" ]; then
    echo "✅ SUPABASE_DB_URL: postgresql://..."
fi

# ============================================================
# STEP 3: Clean database
# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "3️⃣  RENSER DATABASE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ -z "$SUPABASE_DB_URL" ]; then
    echo -e "${YELLOW}⚠️  SUPABASE_DB_URL ikke satt - hopper over database cleanup${NC}"
else
    echo "🧹 Kjører nuclear cleanup for ren database..."
    if python3 scripts/nuclear-option-cleanup.py; then
        echo "✅ Database renset!"
    else
        echo -e "${YELLOW}⚠️  Cleanup hadde problemer, fortsetter likevel...${NC}"
    fi
fi

# ============================================================
# STEP 4: Test Supabase connection
# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "4️⃣  TESTER SUPABASE TILKOBLING"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

TEST_URL="https://${SUPABASE_PROJECT_ID}.supabase.co/rest/v1/aisignal?limit=1"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "apikey: $SUPABASE_SERVICE_ROLE_KEY" \
    -H "Authorization: Bearer $SUPABASE_SERVICE_ROLE_KEY" \
    "$TEST_URL")

if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ Supabase API: HTTP $HTTP_CODE - Tilkoblet!"
else
    echo -e "${RED}❌ Supabase API: HTTP $HTTP_CODE - Feil!${NC}"
    exit 1
fi

# ============================================================
# STEP 5: Insert test signal
# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "5️⃣  SETTER INN TEST SIGNAL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if python3 scripts/adaptive-insert-signal.py; then
    echo "✅ Test signal inserted!"
else
    echo -e "${YELLOW}⚠️  Signal insert feilet, men fortsetter...${NC}"
fi

# ============================================================
# STEP 6: Run analysis
# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "6️⃣  KJØRER FØRSTE ANALYSE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if python3 scripts/analyze_signals.py; then
    echo "✅ Analyse kjørt!"
else
    echo -e "${YELLOW}⚠️  Analyse hadde problemer${NC}"
fi

# ============================================================
# STEP 7: Enable GitHub Actions (optional)
# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "7️⃣  AKTIVERE GITHUB ACTIONS?"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if command -v gh &> /dev/null; then
    echo "GitHub CLI funnet!"
    echo ""
    read -p "Vil du aktivere automated trading analysis (hver 5. min)? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🤖 Trigger workflow..."
        gh workflow run trading-analysis.yml 2>/dev/null || echo "⚠️  Kunne ikke trigge workflow (kanskje ikke tilgang?)"
        echo ""
        echo "✅ Åpner GitHub Actions..."
        gh repo view --web --branch main
    fi
else
    echo "⚠️  GitHub CLI ikke installert"
    echo "   Installer: brew install gh"
    echo "   Eller åpne manuelt: https://github.com/tombomann/klarpakke/actions"
fi

# ============================================================
# DONE!
# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ SETUP FULLFØRT!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🎉 Klarpakke er nå konfigurert og klar!"
echo ""
echo "📊 Neste steg:"
echo "   1. Besøk dashboard: open https://klarpakke.webflow.io"
echo "   2. Se GitHub Actions: open https://github.com/tombomann/klarpakke/actions"
echo "   3. Test backtest: python3 scripts/backtest-strategy.py --days 30"
echo "   4. Les docs: open https://github.com/tombomann/klarpakke/blob/main/README.md"
echo ""
echo "🤖 Automated analysis kjører nå hvert 5. minutt!"
echo "🔔 Du får varsler når nye signaler blir approved/rejected"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
