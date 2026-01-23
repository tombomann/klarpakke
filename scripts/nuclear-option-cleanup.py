#!/usr/bin/env python3
"""
NUCLEAR OPTION: Drop entire api schema and recreate clean
"""
import os
import sys
import subprocess

print("="*70)
print("💣 NUCLEAR OPTION: COMPLETE SCHEMA RESET")
print("="*70)
print()
print("⚠️  WARNING: This will DROP THE ENTIRE 'api' SCHEMA!")
print("⚠️  All tables in 'api' schema will be DELETED.")
print("⚠️  This is the ONLY way to fix the duplicate columns.")
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
print("⏸️  Press Ctrl+C to cancel, or Enter to continue...")
try:
    input()
except KeyboardInterrupt:
    print("\n❌ Cancelled")
    sys.exit(0)

print()

# Nuclear SQL - drop and recreate entire api schema
nuclear_sql = """
-- 1. DROP ENTIRE API SCHEMA
DROP SCHEMA IF EXISTS api CASCADE;

-- 2. CREATE FRESH API SCHEMA
CREATE SCHEMA api;

-- 3. CREATE CLEAN aisignal TABLE
CREATE TABLE api.aisignal (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID,
  
  -- Core signal fields (support both schemas)
  symbol TEXT,
  direction TEXT,
  pair TEXT,
  signal_type TEXT,
  
  -- Price fields (ALL NULLABLE)
  entry_price NUMERIC,
  stop_loss NUMERIC,
  take_profit NUMERIC,
  
  -- Confidence (both formats)
  confidence NUMERIC,
  confidence_score INTEGER,
  
  -- Status
  status TEXT DEFAULT 'pending',
  
  -- Risk
  risk_usd NUMERIC,
  
  -- Approval tracking
  approved_by TEXT,
  approved_at TIMESTAMPTZ,
  rejected_by TEXT,
  rejected_at TIMESTAMPTZ,
  reasoning TEXT,
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Create indexes
CREATE INDEX idx_aisignal_status ON api.aisignal(status);
CREATE INDEX idx_aisignal_created_at ON api.aisignal(created_at DESC);
CREATE INDEX idx_aisignal_user_id ON api.aisignal(user_id);

-- 5. Grant permissions
GRANT ALL ON SCHEMA api TO postgres, anon, authenticated, service_role;
GRANT ALL ON api.aisignal TO postgres, anon, authenticated, service_role;
GRANT USAGE ON SCHEMA api TO postgres, anon, authenticated, service_role;

-- 6. Force PostgREST cache refresh
NOTIFY pgrst, 'reload schema';
NOTIFY pgrst, 'reload config';

-- 7. Show clean schema
SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_schema = 'api' AND table_name = 'aisignal'
ORDER BY ordinal_position;
"""

print("💣 Executing nuclear cleanup...")
print()

try:
    result = subprocess.run(
        ['psql', SUPABASE_DB_URL, '-c', nuclear_sql],
        capture_output=True,
        text=True,
        timeout=60
    )
    
    print(result.stdout)
    
    if result.returncode == 0:
        print()
        print("="*70)
        print("✅ NUCLEAR CLEANUP COMPLETE!")
        print("="*70)
        print()
        print("What was done:")
        print("  ✅ Dropped entire 'api' schema (CASCADE)")
        print("  ✅ Created fresh 'api' schema")
        print("  ✅ Created clean aisignal table")
        print("  ✅ Set proper permissions")
        print("  ✅ Created indexes")
        print("  ✅ Refreshed PostgREST cache")
        print()
        print("📋 Schema info:")
        print("  - 0 duplicate columns (guaranteed!)")
        print("  - All price fields nullable")
        print("  - No check constraints")
        print("  - Clean slate!")
        print()
        print("⏳ Wait 5 seconds for PostgREST cache...")
        import time
        time.sleep(5)
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
