#!/usr/bin/env python3
"""Adaptive signal insert - discovers and uses working schema automatically"""
import os
import sys
import requests
import json

SUPABASE_PROJECT_ID = os.environ.get('SUPABASE_PROJECT_ID', 'swfyuwkptusceiouqlks')
SUPABASE_SERVICE_ROLE_KEY = os.environ.get('SUPABASE_SERVICE_ROLE_KEY')

if not SUPABASE_SERVICE_ROLE_KEY:
    print("❌ Error: SUPABASE_SERVICE_ROLE_KEY not set")
    sys.exit(1)

BASE_URL = f"https://{SUPABASE_PROJECT_ID}.supabase.co/rest/v1"
HEADERS = {
    "apikey": SUPABASE_SERVICE_ROLE_KEY,
    "Authorization": f"Bearer {SUPABASE_SERVICE_ROLE_KEY}",
    "Content-Type": "application/json",
    "Prefer": "return=representation"
}

print("="*70)
print("🤖 ADAPTIVE SIGNAL INSERT")
print("="*70)
print()

# Try to load cached working schema
working_schema = None
try:
    with open('/tmp/klarpakke_working_schema.json', 'r') as f:
        working_schema = json.load(f)
    print("📋 Loaded cached working schema")
except:
    print("🔍 No cached schema, will discover...")

print()

# Step 1: Discover available columns by fetching existing row
print("1️⃣  Discovering table schema...")

available_columns = None

try:
    response = requests.get(f"{BASE_URL}/aisignal?limit=1", headers=HEADERS)
    if response.status_code == 200:
        data = response.json()
        if len(data) > 0:
            available_columns = set(data[0].keys())
            print(f"   ✅ Found {len(available_columns)} columns from existing data")
        else:
            print("   ⚠️  Table is empty, will try all combinations")
except Exception as e:
    print(f"   ⚠️  Could not discover: {e}")

print()

# Step 2: Build signal data based on available columns
print("2️⃣  Building signal data...")

# All possible field mappings
field_options = [
    # Modern schema
    {"pair": "BTCUSDT", "signal_type": "BUY", "confidence_score": 80, "status": "PENDING"},
    # Legacy schema
    {"symbol": "BTCUSDT", "direction": "LONG", "confidence": 0.80, "status": "pending"},
    # Minimal modern
    {"pair": "BTCUSDT", "signal_type": "BUY", "status": "PENDING"},
    # Minimal legacy
    {"symbol": "BTCUSDT", "direction": "LONG", "status": "pending"},
]

# Filter based on available columns
if available_columns:
    print("   📄 Filtering fields based on available columns...")
    filtered_options = []
    for option in field_options:
        if all(key in available_columns for key in option.keys()):
            filtered_options.append(option)
            print(f"   ✅ Schema match: {list(option.keys())}")
    
    if filtered_options:
        field_options = filtered_options
    else:
        print("   ⚠️  No perfect match, will try all combinations")
else:
    print("   🔮 Using all possible schemas (blind mode)")

print()

# Step 3: Try inserting with each schema
print("3️⃣  Attempting insert...")

for idx, test_data in enumerate(field_options, 1):
    print(f"\n   Attempt {idx}/{len(field_options)}: {list(test_data.keys())}")
    
    try:
        response = requests.post(
            f"{BASE_URL}/aisignal",
            headers=HEADERS,
            json=test_data
        )
        
        print(f"   HTTP {response.status_code}")
        
        if response.status_code in [200, 201]:
            result = response.json()
            signal_data = result[0] if isinstance(result, list) else result
            
            print("\n" + "="*70)
            print("✅ SUCCESS! Signal inserted")
            print("="*70)
            print()
            print("📊 Signal data:")
            print(json.dumps(signal_data, indent=2, default=str))
            print()
            
            # Save working schema for future use
            with open('/tmp/klarpakke_working_schema.json', 'w') as f:
                json.dump(test_data, f, indent=2)
            print("💾 Saved working schema to /tmp/klarpakke_working_schema.json")
            
            # Verify signal exists
            signal_id = signal_data.get('id')
            if signal_id:
                verify_url = f"{BASE_URL}/aisignal?id=eq.{signal_id}"
                verify_response = requests.get(verify_url, headers=HEADERS)
                if verify_response.status_code == 200:
                    print("✅ Signal verified in database!")
            
            print()
            print("="*70)
            print("🎯 READY FOR ANALYSIS")
            print("="*70)
            print()
            print("Next: python3 scripts/analyze_signals.py")
            print()
            sys.exit(0)
        
        else:
            error_data = response.json() if response.text else {}
            error_msg = error_data.get('message', str(error_data))
            print(f"   ❌ Failed: {error_msg}")
            
            # Extract useful info from error
            if 'column' in error_msg.lower():
                if "'" in error_msg:
                    missing = error_msg.split("'")[1]
                    print(f"   ⚠️  Missing column: {missing}")
    
    except Exception as e:
        print(f"   ❌ Exception: {e}")

print()
print("="*70)
print("❌ ALL INSERT ATTEMPTS FAILED")
print("="*70)
print()
print("🚨 Manual intervention required:")
print()
print("Option 1 - Run schema fix:")
print("   python3 scripts/fix-schema-cache.py")
print()
print("Option 2 - Manual SQL insert:")
print("   open https://supabase.com/dashboard/project/swfyuwkptusceiouqlks/sql/new")
print()
print("   Run this SQL:")
print("   INSERT INTO aisignal (pair, signal_type, status)")
print("   VALUES ('BTCUSDT', 'BUY', 'PENDING');")
print()
print("Option 3 - Check database schema:")
print("   python3 scripts/debug-aisignal.py")
print()
sys.exit(1)
