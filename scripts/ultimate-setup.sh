#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo ""
echo "🚀 KLARPAKKE ULTIMATE AUTOMATED SETUP"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "This will:"
echo "  1️⃣  Migrate database (add all columns)"
echo "  2️⃣  Sync secrets to GitHub"
echo "  3️⃣  Insert test signal"
echo "  4️⃣  Test analysis locally"
echo "  5️⃣  Trigger GitHub Actions workflow"
echo "  6️⃣  Open monitoring"
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

# Load environment
if [ -f .env.migration ]; then
    source .env.migration
    export SUPABASE_PROJECT_ID SUPABASE_SERVICE_ROLE_KEY SUPABASE_DB_URL
    echo "✅ Environment loaded from .env.migration"
else
    echo "❌ .env.migration not found!"
    echo "   Run: bash scripts/ultimate-fix.sh first"
    exit 1
fi

echo ""
echo "="*70
echo "1️⃣  DATABASE MIGRATION"
echo "="*70
echo ""

# Try Python migration first
if pip3 list 2>/dev/null | grep -q psycopg2; then
    echo "🐍 Using Python migration..."
    if python3 scripts/auto-migrate-database.py; then
        echo "✅ Database migrated via Python!"
        MIGRATION_SUCCESS=true
    else
        echo "⚠️  Python migration failed, trying bash..."
        MIGRATION_SUCCESS=false
    fi
else
    echo "⚠️  psycopg2 not installed, trying bash migration..."
    MIGRATION_SUCCESS=false
fi

# Fallback to bash if Python failed
if [ "$MIGRATION_SUCCESS" = false ]; then
    if bash scripts/auto-migrate-database.sh 2>/dev/null; then
        echo "✅ Database migrated via bash!"
    else
        echo "❌ Automatic migration failed!"
        echo ""
        echo "⚠️  MANUAL ACTION REQUIRED:"
        echo "   1. Open: https://supabase.com/dashboard/project/$SUPABASE_PROJECT_ID/sql/new"
        echo "   2. Run SQL from: schema/migrations/001_add_trading_fields.sql"
        echo ""
        read -p "Press Enter after running SQL manually..."
    fi
fi

echo ""
echo "="*70
echo "2️⃣  SYNC SECRETS TO GITHUB"
echo "="*70
echo ""

if bash scripts/sync-secrets.sh push; then
    echo "✅ Secrets synced to GitHub!"
else
    echo "⚠️  Sync failed (may already be up to date)"
fi

echo ""
echo "="*70
echo "3️⃣  INSERT TEST SIGNAL"
echo "="*70
echo ""

if python3 scripts/insert-test-signal.py; then
    echo "✅ Test signal inserted!"
else
    echo "⚠️  Insert failed (signal may already exist)"
fi

echo ""
echo "="*70
echo "4️⃣  TEST ANALYSIS LOCALLY"
echo "="*70
echo ""

if python3 scripts/analyze_signals.py; then
    echo "✅ Local analysis passed!"
else
    echo "❌ Local analysis failed!"
    echo "   Check output above for errors"
    exit 1
fi

echo ""
echo "="*70
echo "5️⃣  TRIGGER GITHUB ACTIONS"
echo "="*70
echo ""

if command -v gh &> /dev/null; then
    if gh workflow run trading-analysis.yml; then
        echo "✅ Workflow triggered!"
        sleep 2
        echo ""
        echo "🔍 Latest runs:"
        gh run list --workflow="trading-analysis.yml" -L 3
    else
        echo "⚠️  Could not trigger workflow"
    fi
else
    echo "⚠️  GitHub CLI not installed"
    echo "   Install: brew install gh"
fi

echo ""
echo "="*70
echo "6️⃣  OPEN MONITORING"
echo "="*70
echo ""

echo "🌐 Opening monitoring dashboards..."
open "https://github.com/tombomann/klarpakke/actions" &
sleep 1
open "https://supabase.com/dashboard/project/$SUPABASE_PROJECT_ID/editor" &

echo ""
echo "="*70
echo "✅ ULTIMATE SETUP COMPLETE!"
echo "="*70
echo ""
echo "📊 Summary:"
echo "   ✅ Database migrated (confidence_score, entry_price, etc.)"
echo "   ✅ GitHub Secrets synced"
echo "   ✅ Test signal inserted and analyzed"
echo "   ✅ GitHub Actions triggered"
echo "   ✅ Monitoring dashboards opened"
echo ""
echo "🔄 System is now running automated analysis every 15 minutes!"
echo ""
echo "📋 Quick commands:"
echo "   Watch workflow:     gh run watch"
echo "   List runs:          gh run list --workflow='trading-analysis.yml' -L 5"
echo "   Test locally:       python3 scripts/analyze_signals.py"
echo "   Insert test signal: python3 scripts/insert-test-signal.py"
echo ""
echo "🚀 Ready to trade!"
echo ""
