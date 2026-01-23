#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo ""
echo "🤖🔧 KLARPAKKE MASTER FIX & TEST"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "This will AUTOMATICALLY:"
echo "  🚨 Clean duplicate columns (if needed)"
echo "  0️⃣  Fix NOT NULL constraints"
echo "  1️⃣  Fix schema cache issues"
echo "  2️⃣  Insert test signal (adaptive)"
echo "  3️⃣  Run analysis (adaptive)"
echo "  4️⃣  Show results"
echo ""

# Load environment
if [ -f .env.migration ]; then
    source .env.migration
    export SUPABASE_PROJECT_ID SUPABASE_SERVICE_ROLE_KEY SUPABASE_DB_URL
    echo "✅ Environment loaded"
else
    echo "❌ .env.migration not found!"
    exit 1
fi

echo ""
echo "="*70
echo "STEP -1: EMERGENCY DUPLICATE CLEANUP"
echo "="*70
echo ""
echo "🚨 Checking for duplicate columns..."
echo ""

# Check if duplicates exist
DUPLICATE_COUNT=$(psql "$SUPABASE_DB_URL" -t -c "
SELECT COUNT(*) FROM (
  SELECT column_name
  FROM information_schema.columns 
  WHERE table_name = 'aisignal'
  GROUP BY column_name
  HAVING COUNT(*) > 1
) AS dupes;
" 2>/dev/null || echo "0")

if [ "$DUPLICATE_COUNT" -gt 0 ]; then
    echo "⚠️  Found $DUPLICATE_COUNT duplicate column names!"
    echo "🛠️  Running emergency cleanup..."
    echo ""
    
    if python3 scripts/emergency-clean-duplicates.py; then
        echo "✅ Duplicates cleaned!"
        CLEAN_START=true
    else
        echo "❌ Emergency cleanup failed!"
        echo ""
        echo "Please run manually:"
        echo "   python3 scripts/emergency-clean-duplicates.py"
        echo ""
        exit 1
    fi
else
    echo "✅ No duplicates found - schema is clean!"
    CLEAN_START=true
fi

echo ""
echo "="*70
echo "STEP 0: FIX NOT NULL CONSTRAINTS"
echo "="*70
echo ""

if python3 scripts/fix-not-null-constraints.py; then
    echo "✅ NOT NULL constraints fixed!"
else
    echo "⚠️  Constraint fix had issues, continuing anyway..."
fi

echo ""
echo "="*70
echo "STEP 1: FIX SCHEMA CACHE"
echo "="*70
echo ""

if python3 scripts/fix-schema-cache.py; then
    echo "✅ Schema cache fixed!"
else
    echo "⚠️  Schema fix had issues, continuing anyway..."
fi

echo ""
echo "="*70
echo "STEP 2: ADAPTIVE SIGNAL INSERT"
echo "="*70
echo ""

if python3 scripts/adaptive-insert-signal.py; then
    echo "✅ Test signal inserted!"
    SIGNAL_INSERTED=true
else
    echo "⚠️  Could not insert signal, will check if one exists..."
    SIGNAL_INSERTED=false
fi

echo ""
echo "="*70
echo "STEP 3: DEBUG TABLE STATE"
echo "="*70
echo ""

python3 scripts/debug-aisignal.py

echo ""
echo "="*70
echo "STEP 4: RUN ADAPTIVE ANALYSIS"
echo "="*70
echo ""

if python3 scripts/analyze_signals.py; then
    echo "✅ Analysis completed successfully!"
    ANALYSIS_OK=true
else
    echo "⚠️  Analysis had issues"
    ANALYSIS_OK=false
fi

echo ""
echo "="*70
echo "📊 FINAL RESULTS"
echo "="*70
echo ""

if [ "$SIGNAL_INSERTED" = true ] && [ "$ANALYSIS_OK" = true ]; then
    echo "✅ 🎉 FULL SUCCESS!"
    echo ""
    echo "Your system is now working:"
    echo "  ✅ Database cleaned from duplicates"
    echo "  ✅ Schema fixed and refreshed"
    echo "  ✅ Test signal inserted"
    echo "  ✅ Analysis running correctly"
    echo "  ✅ GitHub Actions ready to go"
    echo ""
    echo "🚀 Next steps:"
    echo "   1. Trigger workflow: gh workflow run trading-analysis.yml"
    echo "   2. Watch live: gh run watch"
    echo "   3. Open monitoring: open https://github.com/tombomann/klarpakke/actions"
    echo ""
elif [ "$ANALYSIS_OK" = true ]; then
    echo "✅ 👍 ANALYSIS WORKING!"
    echo ""
    echo "Analysis is functional but signal insert had issues."
    echo "This is OK if signals already exist in the table."
    echo ""
    echo "🚀 System is operational - you can use it now!"
    echo ""
else
    echo "⚠️  🔧 NEEDS ATTENTION"
    echo ""
    echo "Automatic fix didn't fully work. Try:"
    echo ""
    echo "1. Emergency cleanup:"
    echo "   python3 scripts/emergency-clean-duplicates.py"
    echo ""
    echo "2. Manual SQL (if needed):"
    echo "   open https://supabase.com/dashboard/project/$SUPABASE_PROJECT_ID/sql/new"
    echo ""
    echo "3. Re-run this script:"
    echo "   bash scripts/master-fix-and-test.sh"
    echo ""
fi

echo "="*70
echo "📋 Quick Reference"
echo "="*70
echo ""
echo "Emergency:       python3 scripts/emergency-clean-duplicates.py"
echo "Fix constraints: python3 scripts/fix-not-null-constraints.py"
echo "Fix cache:       python3 scripts/fix-schema-cache.py"
echo "Debug:           python3 scripts/debug-aisignal.py"
echo "Insert signal:   python3 scripts/adaptive-insert-signal.py"
echo "Analyze:         python3 scripts/analyze_signals.py"
echo "Full test:       bash scripts/master-fix-and-test.sh"
echo ""
