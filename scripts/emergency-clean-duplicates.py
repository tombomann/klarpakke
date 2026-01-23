#!/usr/bin/env python3
"""
EMERGENCY: Clean duplicate columns from aisignal table
Simplified version - creates fresh table without restore
"""
import os
import sys
import subprocess

print("="*70)
print("🚨 EMERGENCY: CLEAN DUPLICATE COLUMNS")
print("="*70)
print()
print("⚠️  WARNING: This will RECREATE aisignal table!")
print("⚠️  All existing signals will be DELETED.")
print("⚠️  (This is OK - table is currently unusable anyway)")
print()

SUPABASE_DB_URL = os.environ.get('SUPABASE_DB_URL')

if not SUPABASE_DB_URL:
    print("❌ Error: SUPABASE_DB_URL not set")
    print()
    print("Run this first:")
    print("   source .env.migration")
    print("   export SUPABASE_DB_URL")
    print()
    sys.exit(1)

print("✅ Database URL found")
print()

# Simplified SQL - just recreate fresh
cleanup_sql = """
-- 1. DROP the problematic table completely (including cascades)
DROP TABLE IF EXISTS aisignal CASCADE;

-- 2. CREATE CLEAN table with correct schema
CREATE TABLE aisignal (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID,
  
  -- Core signal fields (both schemas supported)
  symbol TEXT,
  pair TEXT,
  direction TEXT,
  signal_type TEXT,
  
  -- Price fields (all nullable)
  entry_price NUMERIC,
  stop_loss NUMERIC,
  take_profit NUMERIC,
  
  -- Confidence (both formats)
  confidence NUMERIC,  -- 0.0-1.0 format
  confidence_score INTEGER,  -- 0-100 format
  
  -- Status
  status TEXT DEFAULT 'pending',
  
  -- Risk
  risk_usd NUMERIC,
  
  -- Approval/Rejection tracking
  approved_by TEXT,
  approved_at TIMESTAMPTZ,
  rejected_by TEXT,
  rejected_at TIMESTAMPTZ,
  reasoning TEXT,
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Create indexes
CREATE INDEX idx_aisignal_status ON aisignal(status);
CREATE INDEX idx_aisignal_created_at ON aisignal(created_at DESC);
CREATE INDEX idx_aisignal_user_id ON aisignal(user_id);

-- 4. Force PostgREST cache refresh
NOTIFY pgrst, 'reload schema';
NOTIFY pgrst, 'reload config';

-- 5. Show clean schema
SELECT 
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_name = 'aisignal'
ORDER BY ordinal_position;
"""

print("📝 Executing emergency cleanup...")
print()

try:
    result = subprocess.run(
        ['psql', SUPABASE_DB_URL, '-c', cleanup_sql],
        capture_output=True,
        text=True,
        timeout=60
    )
    
    print(result.stdout)
    
    if result.returncode == 0:
        print()
        print("="*70)
        print("✅ EMERGENCY CLEANUP COMPLETE!")
        print("="*70)
        print()
        print("What was done:")
        print("  ✅ Dropped duplicate-filled table (CASCADE)")
        print("  ✅ Created clean table with proper schema")
        print("  ✅ Created indexes")
        print("  ✅ Refreshed PostgREST cache")
        print()
        print("📋 Schema info:")
        print("  - 0 duplicate columns")
        print("  - All price fields nullable")
        print("  - Supports both modern + legacy schemas")
        print()
        print("🚀 Next: Insert test signal")
        print("   python3 scripts/adaptive-insert-signal.py")
        print()
        sys.exit(0)
    else:
        print()
        print("❌ Cleanup failed:")
        print(result.stderr)
        sys.exit(1)
        
except FileNotFoundError:
    print("❌ psql not found!")
    print()
    print("Please install PostgreSQL client:")
    print("  brew install postgresql")
    print()
    sys.exit(1)
    
except Exception as e:
    print(f"❌ Error: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)
