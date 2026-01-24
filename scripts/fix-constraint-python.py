#!/usr/bin/env python3
"""
Fix aisignal direction constraint to be case-insensitive.
Requires: pip install psycopg2-binary

Usage:
    source .env.local
    python3 scripts/fix-constraint-python.py
"""

import os
import sys
from urllib.parse import urlparse

try:
    import psycopg2
except ImportError:
    print("❌ psycopg2 not installed")
    print("Install: pip3 install psycopg2-binary")
    sys.exit(1)

def main():
    print("═" * 64)
    print("🔧 FIXING DIRECTION CONSTRAINT")
    print("═" * 64)
    print()
    
    # Get DB URL from environment
    db_url = os.environ.get('SUPABASE_DB_URL')
    if not db_url:
        print("❌ SUPABASE_DB_URL not set")
        print("Run: source .env.local")
        sys.exit(1)
    
    # Parse connection string
    parsed = urlparse(db_url)
    
    try:
        # Connect to database
        print("🔌 Connecting to database...")
        conn = psycopg2.connect(
            host=parsed.hostname,
            port=parsed.port or 5432,
            database=parsed.path.lstrip('/'),
            user=parsed.username,
            password=parsed.password
        )
        conn.autocommit = True
        cur = conn.cursor()
        print("   ✅ Connected")
        print()
        
        # Check existing constraint
        print("🔍 Checking existing constraint...")
        cur.execute("""
            SELECT pg_get_constraintdef(oid) 
            FROM pg_constraint 
            WHERE conrelid = 'aisignal'::regclass 
              AND conname = 'aisignal_direction_check';
        """)
        result = cur.fetchone()
        if result:
            print(f"   Current: {result[0]}")
        else:
            print("   No existing constraint found")
        print()
        
        # Drop old constraint
        print("🗑️  Dropping old constraint...")
        cur.execute("""
            ALTER TABLE aisignal 
            DROP CONSTRAINT IF EXISTS aisignal_direction_check;
        """)
        print("   ✅ Dropped")
        print()
        
        # Add new case-insensitive constraint
        print("➕ Adding new case-insensitive constraint...")
        cur.execute("""
            ALTER TABLE aisignal 
            ADD CONSTRAINT aisignal_direction_check 
            CHECK (UPPER(direction) IN ('LONG', 'SHORT'));
        """)
        print("   ✅ Constraint added: UPPER(direction) IN ('LONG', 'SHORT')")
        print()
        
        # Notify PostgREST
        print("📡 Notifying PostgREST to reload schema...")
        cur.execute("NOTIFY pgrst, 'reload schema';")
        print("   ✅ Notified")
        print()
        
        # Insert test signal
        print("📊 Inserting test signal...")
        cur.execute("""
            INSERT INTO aisignal (
                symbol, direction, entry_price, stop_loss, take_profit, 
                confidence, status
            ) VALUES (
                'BTCUSDT', 'LONG', 50000, 48000, 52000, 0.85, 'pending'
            )
            ON CONFLICT DO NOTHING
            RETURNING id, symbol, direction, confidence, status;
        """)
        
        result = cur.fetchone()
        if result:
            print(f"   ✅ Signal inserted:")
            print(f"      ID: {result[0]}")
            print(f"      Symbol: {result[1]} {result[2]}")
            print(f"      Confidence: {result[3]}")
            print(f"      Status: {result[4]}")
        else:
            print("   ✅ Signal already exists (conflict ignored)")
        print()
        
        # Verify count
        print("📈 Database status:")
        cur.execute("""
            SELECT 
                COUNT(*) as total,
                COUNT(*) FILTER (WHERE status = 'pending') as pending,
                COUNT(*) FILTER (WHERE status = 'approved') as approved
            FROM aisignal;
        """)
        total, pending, approved = cur.fetchone()
        print(f"   Total signals: {total}")
        print(f"   Pending: {pending}")
        print(f"   Approved: {approved}")
        print()
        
        # Show latest signals
        print("📋 Latest 5 signals:")
        cur.execute("""
            SELECT id, symbol, direction, confidence, status, created_at
            FROM aisignal
            ORDER BY created_at DESC
            LIMIT 5;
        """)
        for row in cur.fetchall():
            print(f"   • {row[1]} {row[2]} ({row[3]*100:.0f}% conf) - {row[4]}")
        print()
        
        # Close connection
        conn.close()
        
        print("═" * 64)
        print("✅ CONSTRAINT FIX COMPLETE!")
        print("═" * 64)
        print()
        print("🔗 Next steps:")
        print("   1. Test insert via REST API")
        print("   2. Run auto-fix: ./scripts/auto-fix-cli.sh")
        print("   3. Trigger workflows: gh workflow run multi-strategy-backtest.yml")
        print()
        
    except psycopg2.Error as e:
        print(f"❌ Database error: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        sys.exit(1)

if __name__ == '__main__':
    main()
