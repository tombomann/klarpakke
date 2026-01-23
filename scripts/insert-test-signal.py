#!/usr/bin/env python3
"""Insert a test signal into aisignal table"""
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
print("📥 INSERT TEST SIGNAL")
print("="*70)

# Test signal data
test_signal = {
    "pair": "BTCUSDT",
    "signal_type": "BUY",
    "confidence_score": 80,
    "status": "PENDING"
}

print("\n📊 Test signal data:")
print(json.dumps(test_signal, indent=2))
print()

try:
    url = f"{BASE_URL}/aisignal"
    print(f"🌐 Inserting to: {url}")
    
    response = requests.post(url, headers=HEADERS, json=test_signal)
    
    print(f"\n📊 HTTP Status: {response.status_code}")
    
    if response.status_code in [200, 201]:
        data = response.json()
        print("\n✅ SUCCESS! Signal inserted:")
        print(json.dumps(data, indent=2, default=str))
        
        signal_id = data[0]['id'] if isinstance(data, list) else data['id']
        print(f"\n🎯 Signal ID: {signal_id}")
        
        # Verify it's there
        print("\n🔍 Verifying signal exists...")
        verify_url = f"{BASE_URL}/aisignal?id=eq.{signal_id}"
        verify_response = requests.get(verify_url, headers=HEADERS)
        
        if verify_response.status_code == 200:
            verify_data = verify_response.json()
            if len(verify_data) > 0:
                print("✅ Signal verified in database!")
                print(json.dumps(verify_data[0], indent=2, default=str))
            else:
                print("⚠️  Signal not found in verification")
        
        print("\n" + "="*70)
        print("✅ READY TO TEST!")
        print("="*70)
        print("\nNow run:")
        print("   python3 scripts/analyze_signals.py")
        print()
        
    else:
        print(f"\n❌ Failed to insert signal")
        print(f"Response: {response.text}")
        sys.exit(1)
        
except Exception as e:
    print(f"\n❌ Error: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)
