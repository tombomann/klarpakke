#!/usr/bin/env python3
"""Automated database migration via PostgreSQL connection"""
import os
import sys
import subprocess
from urllib.parse import urlparse

SUPABASE_PROJECT_ID = os.environ.get('SUPABASE_PROJECT_ID', 'swfyuwkptusceiouqlks')
SUPABASE_DB_URL = os.environ.get('SUPABASE_DB_URL', '')

# Migration SQL
MIGRATION_SQL = """
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
"""

VERIFY_SQL = """
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'aisignal'
ORDER BY ordinal_position;
"""

INSERT_TEST_SQL = """
INSERT INTO aisignal (pair, signal_type, confidence_score, status)
VALUES ('BTCUSDT', 'BUY', 80, 'PENDING')
ON CONFLICT DO NOTHING;
"""

print("="*70)
print("🤖 AUTOMATED DATABASE MIGRATION (Python)")
print("="*70)
print()

def run_with_psycopg2():
    """Try using psycopg2 if available"""
    try:
        import psycopg2
        from psycopg2 import sql
        
        print("🔑 Connecting via psycopg2...")
        conn = psycopg2.connect(SUPABASE_DB_URL)
        cur = conn.cursor()
        
        print("🚀 Executing migration...")
        cur.execute(MIGRATION_SQL)
        conn.commit()
        print("✅ Migration executed!")
        
        print("\n🔍 Verifying columns...")
        cur.execute(VERIFY_SQL)
        columns = cur.fetchall()
        print(f"\n📋 Found {len(columns)} columns:")
        for col_name, col_type in columns:
            print(f"   - {col_name}: {col_type}")
        
        # Check if confidence_score exists
        col_names = [col[0] for col in columns]
        if 'confidence_score' in col_names:
            print("\n✅ confidence_score column exists!")
            
            print("\n📥 Inserting test signal...")
            cur.execute(INSERT_TEST_SQL)
            conn.commit()
            print("✅ Test signal inserted!")
        else:
            print("\n❌ confidence_score column NOT found!")
        
        cur.close()
        conn.close()
        return True
        
    except ImportError:
        print("⚠️  psycopg2 not installed")
        print("   Install: pip install psycopg2-binary")
        return False
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def run_with_psql():
    """Fallback to psql command"""
    try:
        print("🔑 Using psql command...")
        
        # Write SQL to temp file
        with open('/tmp/migration.sql', 'w') as f:
            f.write(MIGRATION_SQL)
            f.write(VERIFY_SQL)
            f.write(INSERT_TEST_SQL)
        
        # Parse DB URL for password
        parsed = urlparse(SUPABASE_DB_URL)
        
        # Set PGPASSWORD environment variable
        env = os.environ.copy()
        if parsed.password:
            env['PGPASSWORD'] = parsed.password
        
        # Run psql
        result = subprocess.run(
            ['psql', SUPABASE_DB_URL, '-f', '/tmp/migration.sql'],
            env=env,
            capture_output=True,
            text=True
        )
        
        if result.returncode == 0:
            print("✅ Migration executed via psql!")
            print(result.stdout)
            return True
        else:
            print(f"❌ psql failed: {result.stderr}")
            return False
            
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def manual_fallback():
    """Show manual instructions"""
    print("\n" + "="*70)
    print("⚠️  AUTOMATIC MIGRATION FAILED")
    print("="*70)
    print("\n📝 Manual steps:")
    print("\n1. Open Supabase SQL Editor:")
    print(f"   https://supabase.com/dashboard/project/{SUPABASE_PROJECT_ID}/sql/new")
    print("\n2. Copy and run this SQL:")
    print("-"*70)
    print(MIGRATION_SQL)
    print(INSERT_TEST_SQL)
    print("-"*70)
    print("\n3. Then test:")
    print("   python3 scripts/analyze_signals.py")
    print()

if __name__ == "__main__":
    if not SUPABASE_DB_URL:
        print("❌ SUPABASE_DB_URL not set")
        print("\nLoad from .env.migration:")
        print("   source .env.migration")
        print("   export SUPABASE_DB_URL")
        manual_fallback()
        sys.exit(1)
    
    print(f"📍 Project: {SUPABASE_PROJECT_ID}")
    print(f"🔗 Database: {SUPABASE_DB_URL.split('@')[1] if '@' in SUPABASE_DB_URL else 'hidden'}")
    print()
    
    # Try psycopg2 first, then psql, then show manual steps
    if not run_with_psycopg2():
        if not run_with_psql():
            manual_fallback()
            sys.exit(1)
    
    print("\n" + "="*70)
    print("✅ MIGRATION COMPLETE!")
    print("="*70)
    print("\n📋 Next steps:")
    print("   python3 scripts/analyze_signals.py")
    print()
