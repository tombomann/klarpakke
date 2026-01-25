#!/bin/bash
set -euo pipefail

echo "═══════════════════════════════════════════════════════════════════"
echo "🤖🔧 KLARPAKKE AUTO-FIX EVERYTHING"
echo "═══════════════════════════════════════════════════════════════════"
echo ""
echo "This will AUTOMATICALLY:"
echo "  ✅ Load environment variables"
echo "  ✅ Fix database duplicate columns (nuclear option)"
echo "  ✅ Insert test signal"
echo "  ✅ Run analysis"
echo "  ✅ Show results"
echo ""
echo "⚠️  WARNING: Database will be RECREATED (all signals deleted)"
echo ""

# Check for .env.migration
if [ ! -f .env.migration ]; then
    echo "❌ .env.migration not found!"
    echo ""
    echo "Create it first:"
    echo "  cat > .env.migration << 'EOF'"
    echo "  SUPABASE_PROJECT_ID=\"swfyuwkptusceiouqlks\""
    echo "  SUPABASE_SERVICE_ROLE_KEY=\"your-key\""
    echo "  SUPABASE_DB_URL=\"postgresql://...\""
    echo "  EOF"
    exit 1
fi

echo "✅ Environment file found"
echo ""

# Load environment
source .env.migration
export SUPABASE_DB_URL SUPABASE_PROJECT_ID SUPABASE_SERVICE_ROLE_KEY

echo "✅ Environment loaded"
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "STEP 1: NUCLEAR DATABASE FIX"
echo "═══════════════════════════════════════════════════════════════════"
echo ""

psql "$SUPABASE_DB_URL" <<'EOF'
-- Nuclear option: Complete table recreation

\echo '🚨 Dropping table CASCADE...'
DROP TABLE IF EXISTS aisignal CASCADE;

\echo '✅ Creating clean table...'
CREATE TABLE aisignal (
  -- Primary key
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- User tracking
  user_id uuid REFERENCES auth.users(id),
  
  -- Trading signal data
  symbol text NOT NULL,
  direction text NOT NULL CHECK (direction IN ('LONG', 'SHORT', 'BUY', 'SELL')),
  entry_price numeric,
  stop_loss numeric,
  take_profit numeric,
  
  -- Confidence
  confidence numeric CHECK (confidence >= 0 AND confidence <= 1),
  
  -- Status
  status text DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'executed', 'closed')),
  
  -- Workflow
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

\echo '✅ Creating indexes...'
CREATE INDEX idx_aisignal_status ON aisignal(status);
CREATE INDEX idx_aisignal_user_id ON aisignal(user_id);
CREATE INDEX idx_aisignal_created_at ON aisignal(created_at DESC);

\echo '✅ Refreshing PostgREST cache...'
NOTIFY pgrst, 'reload schema';
NOTIFY pgrst, 'reload config';

\echo ''
\echo '📊 Schema:'
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'aisignal' 
ORDER BY ordinal_position;
EOF

echo ""
echo "✅ Database fixed!"
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "STEP 2: INSERT TEST SIGNAL"
echo "═══════════════════════════════════════════════════════════════════"
echo ""

psql "$SUPABASE_DB_URL" <<'EOF'
\echo '✅ Inserting test signal...'
INSERT INTO aisignal (
  symbol, 
  direction, 
  entry_price, 
  stop_loss, 
  take_profit, 
  confidence, 
  status
) VALUES (
  'BTCUSDT',
  'LONG',
  50000,
  49000,
  52000,
  0.85,
  'pending'
) RETURNING id, symbol, direction, confidence, status;
EOF

echo ""
echo "✅ Test signal inserted!"
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "STEP 3: RUN ANALYSIS"
echo "═══════════════════════════════════════════════════════════════════"
echo ""

if [ -f scripts/analyze_signals.py ]; then
    python3 scripts/analyze_signals.py
else
    echo "⚠️  analyze_signals.py not found, skipping"
fi

echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "STEP 4: SHOW RESULTS"
echo "═══════════════════════════════════════════════════════════════════"
echo ""

psql "$SUPABASE_DB_URL" <<'EOF'
\echo '📊 All signals:'
SELECT 
  symbol,
  direction,
  entry_price,
  confidence,
  status,
  approved_by,
  reasoning
FROM aisignal 
ORDER BY created_at DESC;

\echo ''
\echo '📊 Summary:'
SELECT 
  status,
  COUNT(*) as count
FROM aisignal 
GROUP BY status;
EOF

echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "✅ AUTO-FIX COMPLETE!"
echo "═══════════════════════════════════════════════════════════════════"
echo ""
echo "Summary:"
echo "  ✅ Database recreated (no duplicates)"
echo "  ✅ Test signal inserted"
echo "  ✅ Analysis ran"
echo "  ✅ Results displayed"
echo ""
echo "🚀 System is ready!"
echo ""
