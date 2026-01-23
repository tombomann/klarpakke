#!/usr/bin/env python3
"""
EMERGENCY: Clean duplicate columns from aisignal table
"""
import os
import sys
import subprocess

print("="*70)
print("🚨 EMERGENCY: CLEAN DUPLICATE COLUMNS")
print("="*70)
print()
print("⚠️  WARNING: This will DROP DUPLICATE columns!")
print("⚠️  Backup data will be created automatically.")
print()

SUPABASE_DB_URL = os.environ.get('SUPABASE_DB_URL')

if not SUPABASE_DB_URL:
    print("❌ Error: SUPABASE_DB_URL not set")
    sys.exit(1)

print("✅ Database URL found")
print()

# SQL to backup and clean
cleanup_sql = """
-- 1. BACKUP current table
DROP TABLE IF EXISTS aisignal_backup_emergency;
CREATE TABLE aisignal_backup_emergency AS 
SELECT * FROM aisignal;

SELECT COUNT(*) as backed_up_rows FROM aisignal_backup_emergency;

-- 2. DROP the problematic table completely
DROP TABLE IF EXISTS aisignal CASCADE;

-- 3. CREATE CLEAN table with correct schema
CREATE TABLE aisignal (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID,
  
  -- Core signal fields (both schemas supported)
  symbol TEXT,
  pair TEXT,
  direction TEXT,
  signal_type TEXT,
  
  -- Price fields (nullable)
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
  
  -- Trade lifecycle
  executed_at TIMESTAMPTZ,
  closed_at TIMESTAMPTZ,
  profit NUMERIC,
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Create indexes
CREATE INDEX idx_aisignal_status ON aisignal(status);
CREATE INDEX idx_aisignal_created_at ON aisignal(created_at DESC);
CREATE INDEX idx_aisignal_user_id ON aisignal(user_id);

-- 5. Restore data if any existed
INSERT INTO aisignal 
SELECT DISTINCT ON (id)
  COALESCE(id::uuid, gen_random_uuid()),
  user_id::uuid,
  symbol,
  pair,
  direction,
  signal_type,
  entry_price,
  stop_loss,
  take_profit,
  confidence,
  confidence_score,
  status,
  risk_usd,
  approved_by,
  approved_at,
  rejected_by,
  rejected_at,
  reasoning,
  executed_at,
  closed_at,
  profit,
  created_at,
  updated_at
FROM aisignal_backup_emergency
WHERE id IS NOT NULL;

-- 6. Force PostgREST cache refresh
NOTIFY pgrst, 'reload schema';
NOTIFY pgrst, 'reload config';

-- 7. Show results
SELECT 
  'Rows restored:' as info,
  COUNT(*) as count 
FROM aisignal;

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
        print("  ✅ Backed up existing data to aisignal_backup_emergency")
        print("  ✅ Dropped duplicate-filled table")
        print("  ✅ Created clean table with proper schema")
        print("  ✅ Restored data (if any)")
        print("  ✅ Created indexes")
        print("  ✅ Refreshed PostgREST cache")
        print()
        print("🚀 Next: Test insert")
        print("   python3 scripts/adaptive-insert-signal.py")
        print()
        sys.exit(0)
    else:
        print()
        print("❌ Cleanup failed:")
        print(result.stderr)
        sys.exit(1)
        
except Exception as e:
    print(f"❌ Error: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)
