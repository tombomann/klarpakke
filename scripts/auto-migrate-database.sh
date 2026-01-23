#!/bin/bash
set -euo pipefail

echo "="*70
echo "🤖 AUTOMATED DATABASE MIGRATION"
echo "="*70
echo ""

# Check if Supabase CLI is installed
if ! command -v supabase &> /dev/null; then
    echo "⚠️  Supabase CLI not found. Installing..."
    brew install supabase/tap/supabase
    echo "✅ Supabase CLI installed"
else
    echo "✅ Supabase CLI found"
fi

# Check if logged in
if ! supabase projects list &> /dev/null; then
    echo "\n🔐 Not logged in. Logging in..."
    supabase login
fi

PROJECT_ID="swfyuwkptusceiouqlks"

echo "\n📋 Running migration SQL..."
echo ""

# Create temporary SQL file
cat > /tmp/klarpakke_migration.sql << 'EOF'
-- KLARPAKKE DATABASE MIGRATION
-- Add all required columns for trading analysis

-- Add missing columns to aisignal table
ALTER TABLE aisignal 
ADD COLUMN IF NOT EXISTS confidence_score INT CHECK (confidence_score BETWEEN 0 AND 100),
ADD COLUMN IF NOT EXISTS entry_price NUMERIC(18,8),
ADD COLUMN IF NOT EXISTS stop_loss NUMERIC(18,8),
ADD COLUMN IF NOT EXISTS take_profit NUMERIC(18,8),
ADD COLUMN IF NOT EXISTS approved_by TEXT,
ADD COLUMN IF NOT EXISTS approved_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS rejected_by TEXT,
ADD COLUMN IF NOT EXISTS rejected_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS reasoning TEXT;

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_aisignal_status ON aisignal(status);
CREATE INDEX IF NOT EXISTS idx_aisignal_created_at ON aisignal(created_at DESC);

-- Verify columns
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'aisignal'
ORDER BY ordinal_position;
EOF

echo "📄 Migration SQL created: /tmp/klarpakke_migration.sql"
echo ""

# Execute SQL via Supabase CLI
echo "🚀 Executing migration..."
echo ""

if supabase db remote commit --project-ref "$PROJECT_ID" --file /tmp/klarpakke_migration.sql 2>/dev/null; then
    echo "✅ Migration executed successfully!"
else
    echo "⚠️  Direct commit failed, trying psql approach..."
    
    # Alternative: Use db push
    if supabase db push --project-ref "$PROJECT_ID" --file /tmp/klarpakke_migration.sql 2>/dev/null; then
        echo "✅ Migration pushed successfully!"
    else
        echo "⚠️  CLI approach failed. Using direct SQL execution..."
        
        # Fallback: Direct SQL via API
        source "$(dirname "$0")/../.env.migration" 2>/dev/null || true
        
        if [ -n "${SUPABASE_SERVICE_ROLE_KEY:-}" ]; then
            echo "🔑 Using service role key from .env.migration"
            
            # Execute via psql if DB_URL is available
            if [ -n "${SUPABASE_DB_URL:-}" ]; then
                echo "📡 Executing via PostgreSQL..."
                PGPASSWORD="${SUPABASE_DB_URL##*:}" psql "${SUPABASE_DB_URL}" < /tmp/klarpakke_migration.sql
                echo "✅ Migration executed via psql!"
            else
                echo "❌ No database URL found"
                echo "\n⚠️  Manual fallback required:"
                echo "   1. Open: https://supabase.com/dashboard/project/$PROJECT_ID/sql/new"
                echo "   2. Copy contents of: /tmp/klarpakke_migration.sql"
                echo "   3. Run in SQL Editor"
                exit 1
            fi
        else
            echo "❌ No credentials found"
            echo "\n⚠️  Manual fallback required:"
            echo "   1. Open: https://supabase.com/dashboard/project/$PROJECT_ID/sql/new"
            echo "   2. Copy contents of: /tmp/klarpakke_migration.sql"
            echo "   3. Run in SQL Editor"
            exit 1
        fi
    fi
fi

echo ""
echo "="*70
echo "✅ MIGRATION COMPLETE!"
echo "="*70
echo ""
echo "📋 Next steps:"
echo "   1. Insert test signal: python3 scripts/insert-test-signal.py"
echo "   2. Run analysis: python3 scripts/analyze_signals.py"
echo ""

# Cleanup
rm -f /tmp/klarpakke_migration.sql
