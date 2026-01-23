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
    "Content-Type": "application/json",
    "Prefer": "return=representation"
}

def fetch_pending_signals():
    """Fetch signals with status='PENDING' from aisignal table"""
    url = f"{BASE_URL}/aisignal?status=eq.PENDING&order=created_at.desc&limit=10"
    response = requests.get(url, headers=HEADERS)
    response.raise_for_status()
    return response.json()

def analyze_signal(signal):
    """
    Analyze signal based on confidence_score.
    Since table doesn't have entry_price/stop_loss/take_profit,
    we use confidence_score as main decision factor.
    """
    signal_id = signal['id']
    pair = signal['pair']
    signal_type = signal['signal_type']
    confidence_score = signal.get('confidence_score', 0)  # 0-100
    
    print(f"\n📊 Signal {signal_id[:8]}: {pair} {signal_type}")
    print(f"   Confidence: {confidence_score}%")
    
    # Decision logic based on confidence score
    if confidence_score >= 75:
        decision = "APPROVED"
        reasoning = f"High confidence: {confidence_score}%"
    elif confidence_score >= 60:
        decision = "PENDING"
        reasoning = f"Medium confidence: {confidence_score}% - needs review"
    else:
        decision = "REJECTED"
        reasoning = f"Low confidence: {confidence_score}%"
    
    print(f"   Decision: {decision}")
    print(f"   Reasoning: {reasoning}")
    
    return decision, reasoning

def update_signal(signal_id, decision, reasoning):
    """Update signal status in database"""
    url = f"{BASE_URL}/aisignal?id=eq.{signal_id}"
    
    timestamp = datetime.utcnow().isoformat()
    update_data = {
        "status": decision
    }
    
    # Add approved/rejected metadata if not pending
    if decision == "APPROVED":
        update_data["approved_by"] = "github_actions"
        update_data["approved_at"] = timestamp
    elif decision == "REJECTED":
        update_data["rejected_by"] = "github_actions"
        update_data["rejected_at"] = timestamp
    
    # Note: 'reasoning' column doesn't exist in schema, so we skip it
    # If you want to add it, run: ALTER TABLE aisignal ADD COLUMN reasoning TEXT;
    
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
            print("✅ No pending signals to analyze")
            return
        
        approved_count = 0
        rejected_count = 0
        pending_count = 0
        
        for signal in signals:
            decision, reasoning = analyze_signal(signal)
            
            if decision != 'PENDING':
                if update_signal(signal['id'], decision, reasoning):
                    print(f"   ✅ Updated to {decision}")
                    if decision == "APPROVED":
                        approved_count += 1
                    elif decision == "REJECTED":
                        rejected_count += 1
                else:
                    print(f"   ❌ Failed to update")
            else:
                pending_count += 1
                print(f"   ⏸️  Kept as PENDING")
        
        print("\n" + "=" * 60)
        print(f"✅ Analysis complete")
        print(f"   Approved: {approved_count}")
        print(f"   Rejected: {rejected_count}")
        print(f"   Pending: {pending_count}")
        print("=" * 60)
        
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()
