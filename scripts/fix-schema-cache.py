#!/usr/bin/env python3
"""Automatically fix Supabase schema cache issues"""
import os
import sys
import requests
import time

SUPABASE_PROJECT_ID = os.environ.get('SUPABASE_PROJECT_ID', 'swfyuwkptusceiouqlks')
SUPABASE_SERVICE_ROLE_KEY = os.environ.get('SUPABASE_SERVICE_ROLE_KEY')
SUPABASE_DB_URL = os.environ.get('SUPABASE_DB_URL', '')

if not SUPABASE_SERVICE_ROLE_KEY:
    print("❌ SUPABASE_SERVICE_ROLE_KEY not set")
    sys.exit(1)

BASE_URL = f"https://{SUPABASE_PROJECT_ID}.supabase.co/rest/v1"
HEADERS = {
    "apikey": SUPABASE_SERVICE_ROLE_KEY,
    "Authorization": f"Bearer {SUPABASE_SERVICE_ROLE_KEY}",
    "Content-Type": "application/json",
    "Prefer": "return=representation"
}

print("="*70)
print("🔧 SUPABASE SCHEMA CACHE FIX")
print("="*70)
print()

# Step 1: Refresh PostgREST schema cache via SQL
print("1️⃣  Refreshing PostgREST schema cache...")

if SUPABASE_DB_URL:
    try:
        import subprocess
        sql = "NOTIFY pgrst, 'reload schema';"
        result = subprocess.run(
            ['psql', SUPABASE_DB_URL, '-c', sql],
            capture_output=True,
            text=True,
            env={**os.environ, 'PGPASSWORD': SUPABASE_DB_URL.split(':')[-1].split('@')[0]}
        )
        if result.returncode == 0:
            print("✅ Schema cache refreshed via SQL!")
        else:
            print(f"⚠️  SQL refresh failed: {result.stderr}")
    except Exception as e:
        print(f"⚠️  Could not refresh via psql: {e}")
else:
    print("⚠️  SUPABASE_DB_URL not set, skipping SQL refresh")

print()

# Step 2: Wait for cache to refresh
print("2️⃣  Waiting for cache propagation...")
time.sleep(2)
print("✅ Done")
print()

# Step 3: Try different column combinations to find what works
print("3️⃣  Testing column combinations...")

test_combinations = [
    # Most complete
    {
        "pair": "BTCUSDT",
        "signal_type": "BUY",
        "confidence_score": 80,
        "status": "PENDING"
    },
    # Without confidence_score
    {
        "pair": "BTCUSDT",
        "signal_type": "BUY",
        "confidence": 0.80,  # Try old format
        "status": "PENDING"
    },
    # Minimal
    {
        "pair": "BTCUSDT",
        "signal_type": "BUY",
        "status": "PENDING"
    },
    # With symbol instead of pair
    {
        "symbol": "BTCUSDT",
        "direction": "LONG",
        "status": "pending"
    }
]

working_schema = None

for idx, combo in enumerate(test_combinations, 1):
    print(f"\n   Testing combo {idx}: {list(combo.keys())}")
    
    try:
        response = requests.post(
            f"{BASE_URL}/aisignal",
            headers=HEADERS,
            json=combo
        )
        
        if response.status_code in [200, 201]:
            print(f"   ✅ SUCCESS! This schema works:")
            print(f"      {combo}")
            working_schema = combo
            break
        else:
            error = response.json() if response.text else {}
            if 'message' in error and 'column' in error['message']:
                missing_col = error['message'].split("'")[1] if "'" in error['message'] else "unknown"
                print(f"   ❌ Missing column: {missing_col}")
            else:
                print(f"   ❌ Failed: {response.status_code}")
    except Exception as e:
        print(f"   ❌ Error: {e}")

print()

# Step 4: Get actual working columns from REST API
print("4️⃣  Discovering actual table schema via REST API...")

try:
    # Try to get empty result set to see column structure
    response = requests.get(
        f"{BASE_URL}/aisignal?limit=0",
        headers=HEADERS
    )
    
    if response.status_code == 200:
        print("✅ REST API accessible")
        
        # Try getting one row to see structure
        response = requests.get(
            f"{BASE_URL}/aisignal?limit=1",
            headers=HEADERS
        )
        
        if response.status_code == 200:
            data = response.json()
            if len(data) > 0:
                print("\n📋 Available columns in REST API:")
                for col in sorted(data[0].keys()):
                    print(f"   - {col}")
                    
                # Save working schema
                working_schema = {
                    k: v for k, v in {
                        "pair": "BTCUSDT",
                        "signal_type": "BUY",
                        "status": "PENDING"
                    }.items() if k in data[0]
                }
except Exception as e:
    print(f"⚠️  Could not discover schema: {e}")

print()

# Step 5: Save working schema to file
if working_schema:
    print("5️⃣  Saving working schema...")
    
    schema_file = "/tmp/klarpakke_working_schema.json"
    import json
    with open(schema_file, 'w') as f:
        json.dump(working_schema, f, indent=2)
    
    print(f"✅ Saved to: {schema_file}")
    print()
    print("📋 Working schema:")
    print(json.dumps(working_schema, indent=2))
else:
    print("⚠️  Could not determine working schema")

print()
print("="*70)
print("✅ SCHEMA CACHE FIX COMPLETE")
print("="*70)
print()
print("📝 Next steps:")
print("   1. Use working schema for inserts")
print("   2. Update analyze_signals.py to use working columns")
print("   3. Re-run: python3 scripts/insert-test-signal.py")
print()
