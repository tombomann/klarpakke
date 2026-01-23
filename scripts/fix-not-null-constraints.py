#!/usr/bin/env python3
"""
Automatically fix NOT NULL constraints that block REST API inserts
"""
import os
import sys
import subprocess

print("="*70)
print("🔧 AUTOMATIC NOT NULL CONSTRAINT FIX")
print("="*70)
print()

# Get database URL from environment
SUPABASE_DB_URL = os.environ.get('SUPABASE_DB_URL')

if not SUPABASE_DB_URL:
    print("❌ Error: SUPABASE_DB_URL not set")
    print("   Run: source .env.migration && export SUPABASE_DB_URL")
    sys.exit(1)

print("✅ Database URL found")
print()

# SQL to fix everything
fix_sql = """
-- 1. Drop NOT NULL constraints that block inserts
ALTER TABLE aisignal ALTER COLUMN entry_price DROP NOT NULL;
ALTER TABLE aisignal ALTER COLUMN stop_loss DROP NOT NULL;
ALTER TABLE aisignal ALTER COLUMN take_profit DROP NOT NULL;

-- 2. Ensure all possible columns exist
ALTER TABLE aisignal ADD COLUMN IF NOT EXISTS symbol TEXT;
ALTER TABLE aisignal ADD COLUMN IF NOT EXISTS direction TEXT;
ALTER TABLE aisignal ADD COLUMN IF NOT EXISTS confidence NUMERIC;
ALTER TABLE aisignal ADD COLUMN IF NOT EXISTS pair TEXT;
ALTER TABLE aisignal ADD COLUMN IF NOT EXISTS signal_type TEXT;
ALTER TABLE aisignal ADD COLUMN IF NOT EXISTS confidence_score INTEGER;

-- 3. Force PostgREST cache refresh
NOTIFY pgrst, 'reload schema';
NOTIFY pgrst, 'reload config';

-- 4. Show current schema
SELECT 
  column_name, 
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_name = 'aisignal'
ORDER BY ordinal_position;
"""

print("📝 Executing SQL fixes...")
print()

try:
    # Execute via psql
    result = subprocess.run(
        ['psql', SUPABASE_DB_URL, '-c', fix_sql],
        capture_output=True,
        text=True,
        timeout=30
    )
    
    print(result.stdout)
    
    if result.returncode == 0:
        print()
        print("="*70)
        print("✅ NOT NULL CONSTRAINTS FIXED!")
        print("="*70)
        print()
        print("Changes made:")
        print("  ✅ entry_price, stop_loss, take_profit → nullable")
        print("  ✅ Added symbol, direction, confidence columns")
        print("  ✅ Added pair, signal_type, confidence_score columns")
        print("  ✅ PostgREST cache refreshed")
        print()
        print("🎯 Next: Test insert")
        print("   python3 scripts/adaptive-insert-signal.py")
        print()
        sys.exit(0)
    else:
        print()
        print("❌ SQL execution failed:")
        print(result.stderr)
        sys.exit(1)
        
except FileNotFoundError:
    print("❌ psql not found!")
    print()
    print("Please install PostgreSQL client:")
    print("  brew install postgresql")
    print()
    sys.exit(1)
    
except subprocess.TimeoutExpired:
    print("❌ SQL execution timed out")
    sys.exit(1)
    
except Exception as e:
    print(f"❌ Error: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)
