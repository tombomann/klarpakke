#!/usr/bin/env python3
import os
import sys
import requests
from datetime import datetime

SUPABASE_PROJECT_ID = os.environ.get('SUPABASE_PROJECT_ID', 'swfyuwkptusceiouqlks')
SUPABASE_SERVICE_ROLE_KEY = os.environ.get('SUPABASE_SERVICE_ROLE_KEY')

if not SUPABASE_SERVICE_ROLE_KEY:
    print("❌ Error: SUPABASE_SERVICE_ROLE_KEY not set")
    sys.exit(1)

BASE_URL = f"https://{SUPABASE_PROJECT_ID}.supabase.co/rest/v1"
HEADERS = {
    "apikey": SUPABASE_SERVICE_ROLE_KEY,
    "Authorization": f"Bearer {SUPABASE_SERVICE_ROLE_KEY}",
    "Content-Type": "application/json"
}

def fetch_pending_signals():
    url = f"{BASE_URL}/aisignal?status=eq.pending&order=created_at.desc&limit=10"
    response = requests.get(url, headers=HEADERS)
    response.raise_for_status()
    return response.json()

def analyze_signal(signal):
    entry = signal['entry_price']
    stop_loss = signal['stop_loss']
    take_profit = signal['take_profit']
    confidence = signal['confidence']
    
    risk = abs(entry - stop_loss)
    reward = abs(take_profit - entry)
    rr_ratio = reward / risk if risk > 0 else 0
    
    print(f"\n📊 Signal {signal['id']}: {signal['symbol']} {signal['direction']}")
    print(f"   R:R: {rr_ratio:.2f} | Confidence: {confidence:.2%}")
    
    if rr_ratio >= 2.0 and confidence >= 0.75:
        decision = "approved"
        reasoning = f"Strong signal: R:R={rr_ratio:.2f}, conf={confidence:.2%}"
    elif rr_ratio < 1.5:
        decision = "rejected"
        reasoning = f"Poor R:R ratio: {rr_ratio:.2f}"
    elif confidence < 0.70:
        decision = "rejected"
        reasoning = f"Low confidence: {confidence:.2%}"
    else:
        decision = "pending"
        reasoning = "Marginal signal"
    
    print(f"   Decision: {decision.upper()}")
    return decision, reasoning, rr_ratio

def update_signal(signal_id, decision, reasoning):
    url = f"{BASE_URL}/aisignal?id=eq.{signal_id}"
    update_data = {
        "status": decision,
        "reasoning": reasoning,
        f"{decision}_by": "github_actions",
        f"{decision}_at": datetime.utcnow().isoformat()
    }
    response = requests.patch(url, headers=HEADERS, json=update_data)
    return response.status_code in [200, 204]

def main():
    print("=" * 60)
    print("🤖 KLARPAKKE AUTOMATED ANALYSIS")
    print("=" * 60)
    
    try:
        signals = fetch_pending_signals()
        print(f"\n📥 Found {len(signals)} pending signals")
        
        if not signals:
            print("✅ No pending signals")
            return
        
        for signal in signals:
            decision, reasoning, rr_ratio = analyze_signal(signal)
            
            if decision != 'pending':
                if update_signal(signal['id'], decision, reasoning):
                    print(f"   ✅ Updated to {decision}")
                else:
                    print(f"   ❌ Failed to update")
        
        print("\n" + "=" * 60)
        print("✅ Analysis complete")
    except Exception as e:
        print(f"❌ Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()

