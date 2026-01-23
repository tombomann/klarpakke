#!/usr/bin/env python3
"""Debug script to inspect aisignal table contents"""
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
print("🔍 AISIGNAL TABLE DEBUG")
print("="*70)

print(f"\n📍 Project ID: {SUPABASE_PROJECT_ID}")
print(f"🔑 API Key: {SUPABASE_SERVICE_ROLE_KEY[:20]}...")
print(f"\n🌐 Base URL: {BASE_URL}")

# Test 1: Get ALL rows
print("\n" + "="*70)
print("TEST 1: Fetch ALL rows from aisignal table")
print("="*70)

try:
    url = f"{BASE_URL}/aisignal?order=created_at.desc&limit=100"
    print(f"URL: {url}")
    
    response = requests.get(url, headers=HEADERS)
    print(f"HTTP Status: {response.status_code}")
    
    if response.status_code == 200:
        data = response.json()
        print(f"\n✅ Found {len(data)} total rows\n")
        
        if len(data) == 0:
            print("⚠️  TABLE IS EMPTY!")
            print("\nTo add a test signal, run this SQL in Supabase:")
            print("-" * 70)
            print("INSERT INTO aisignal (pair, signal_type, confidence_score, status)")
            print("VALUES ('BTCUSDT', 'BUY', 80, 'PENDING');")
            print("-" * 70)
        else:
            for idx, row in enumerate(data, 1):
                print(f"Row {idx}:")
                print(json.dumps(row, indent=2, default=str))
                print()
    else:
        print(f"❌ Failed: {response.text}")
except Exception as e:
    print(f"❌ Error: {e}")
    import traceback
    traceback.print_exc()

# Test 2: Get PENDING rows specifically
print("\n" + "="*70)
print("TEST 2: Fetch only PENDING rows")
print("="*70)

try:
    url = f"{BASE_URL}/aisignal?status=eq.PENDING&order=created_at.desc"
    print(f"URL: {url}")
    
    response = requests.get(url, headers=HEADERS)
    print(f"HTTP Status: {response.status_code}")
    
    if response.status_code == 200:
        data = response.json()
        print(f"\n✅ Found {len(data)} PENDING rows\n")
        
        if len(data) == 0:
            print("⚠️  No PENDING signals found")
        else:
            for idx, row in enumerate(data, 1):
                print(f"Pending Signal {idx}:")
                print(json.dumps(row, indent=2, default=str))
                print()
    else:
        print(f"❌ Failed: {response.text}")
except Exception as e:
    print(f"❌ Error: {e}")

# Test 3: Check table columns
print("\n" + "="*70)
print("TEST 3: Check table schema (if accessible)")
print("="*70)

# Try to get one row to see column structure
try:
    url = f"{BASE_URL}/aisignal?limit=1"
    response = requests.get(url, headers=HEADERS)
    
    if response.status_code == 200:
        data = response.json()
        if len(data) > 0:
            print("\n📋 Available columns:")
            for col in data[0].keys():
                print(f"   - {col}")
        else:
            print("\n⚠️  Cannot determine columns (table empty)")
            print("\nExpected columns:")
            print("   - id, user_id, pair, signal_type, confidence_score")
            print("   - status, risk_usd, created_at")
            print("   - entry_price, stop_loss, take_profit (if migrated)")
            print("   - approved_by, approved_at, rejected_by, rejected_at, reasoning (if migrated)")
except Exception as e:
    print(f"❌ Error checking schema: {e}")

print("\n" + "="*70)
print("✅ DEBUG COMPLETE")
print("="*70)
print("\n📝 Next steps:")
print("   1. If table is empty → Insert test signal in SQL Editor")
print("   2. If signals exist but not PENDING → Check status values")
print("   3. If PENDING found → analyze_signals.py should work!")
print()
