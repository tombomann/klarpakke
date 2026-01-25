#!/bin/bash
set -euo pipefail

echo "═══════════════════════════════════════════════════════════════════"
echo "☢️  NUCLEAR DATABASE FIX"
echo "═══════════════════════════════════════════════════════════════════"
echo ""
echo "⚠️  WARNING: This will COMPLETELY RECREATE the aisignal table!"
echo "⚠️  All existing signals will be DELETED."
echo "⚠️  This is the LAST RESORT fix for duplicate columns."
echo ""
read -p "Type 'YES' to continue: " confirm

if [ "$confirm" != "YES" ]; then
    echo "Aborted."
    exit 1
fi

echo ""
echo "✅ Confirmed. Proceeding with nuclear fix..."
echo ""

# Load environment
if [ -f .env.migration ]; then
    source .env.migration
    export SUPABASE_DB_URL SUPABASE_PROJECT_ID SUPABASE_SERVICE_ROLE_KEY
fi

if [ -z "${SUPABASE_DB_URL:-}" ]; then
    echo "❌ SUPABASE_DB_URL not set!"
    echo ""
    echo "Run:"
    echo "  source .env.migration"
    echo "  export SUPABASE_DB_URL"
    exit 1
fi

echo "📝 Executing nuclear fix via psql..."
echo ""

# Execute SQL directly
psql "$SUPABASE_DB_URL" <<'EOF'
-- Nuclear option: Complete table recreation

\echo '🚨 Step 1: Drop table CASCADE'
DROP TABLE IF EXISTS aisignal CASCADE;

\echo '✅ Step 2: Create clean table'
CREATE TABLE aisignal (
  -- Primary key
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- User tracking
  user_id uuid REFERENCES auth.users(id),
  
  -- Trading signal data (modern schema)
  symbol text NOT NULL,
  direction text NOT NULL CHECK (direction IN ('LONG', 'SHORT', 'BUY', 'SELL')),
  entry_price numeric,
  stop_loss numeric,
  take_profit numeric,
  
  -- Confidence
  confidence numeric CHECK (confidence >= 0 AND confidence <= 1),
  
  -- Status tracking
  status text DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'executed', 'closed')),
  
  -- Approval workflow
  approved_by text,
  approved_at timestamptz,
  rejected_by text,
  rejected_at timestamptz,
  reasoning text,
  
  -- Execution
  executed_at timestamptz,
  closed_at timestamptz,
  
  -- Performance
  profit numeric,
  
  -- Timestamps
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

\echo '✅ Step 3: Create indexes'
CREATE INDEX idx_aisignal_status ON aisignal(status);
CREATE INDEX idx_aisignal_user_id ON aisignal(user_id);
CREATE INDEX idx_aisignal_created_at ON aisignal(created_at DESC);

\echo '✅ Step 4: Refresh PostgREST cache'
NOTIFY pgrst, 'reload schema';
NOTIFY pgrst, 'reload config';

\echo ''
\echo '📊 Verify schema:'
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'aisignal' 
ORDER BY ordinal_position;

\echo ''
\echo '✅ Count rows:'
SELECT COUNT(*) as total_signals FROM aisignal;
EOF

echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "✅ NUCLEAR FIX COMPLETE!"
echo "═══════════════════════════════════════════════════════════════════"
echo ""
echo "What was done:"
echo "  ✅ Dropped aisignal table (CASCADE)"
echo "  ✅ Created clean table with NO DUPLICATES"
echo "  ✅ Created indexes"
echo "  ✅ Refreshed PostgREST cache"
echo ""
echo "📋 Next steps:"
echo "  1. Test insert:"
echo "     python3 scripts/adaptive-insert-signal.py"
echo ""
echo "  2. View table:"
echo "     python3 scripts/debug-aisignal.py"
echo ""
echo "  3. Run analysis:"
echo "     python3 scripts/analyze_signals.py"
echo ""
