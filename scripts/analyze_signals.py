#!/usr/bin/env python3
"""Adaptive signal analysis - works with any schema variation"""
import os
import sys
import requests
from datetime import datetime
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

def get_field(signal, field_variations):
    """Get field value, trying multiple variations"""
    for field in field_variations:
        if field in signal:
            return signal[field]
    return None

def fetch_pending_signals():
    """Fetch pending signals, trying multiple status formats"""
    # Try different status values
    for status_value in ['PENDING', 'pending', 'Pending']:
        url = f"{BASE_URL}/aisignal?status=eq.{status_value}&order=created_at.desc&limit=10"
        try:
            response = requests.get(url, headers=HEADERS)
            if response.status_code == 200:
                data = response.json()
                if len(data) > 0:
                    return data, status_value
        except:
            continue
    
    # If no pending found with any status, return empty
    return [], 'PENDING'

def analyze_signal(signal):
    """
    Adaptive signal analysis - works with multiple schema variations
    """
    signal_id = signal['id']
    
    # Get pair/symbol (try both)
    pair = get_field(signal, ['pair', 'symbol']) or 'UNKNOWN'
    
    # Get signal_type/direction (try both)
    signal_type = get_field(signal, ['signal_type', 'direction']) or 'UNKNOWN'
    
    # Get confidence (try both formats: 0-100 or 0-1)
    confidence_score = get_field(signal, ['confidence_score', 'confidence'])
    if confidence_score is not None:
        # Normalize to 0-100 scale
        if confidence_score < 1.5:  # Assume 0-1 format
            confidence_score = int(confidence_score * 100)
        else:
            confidence_score = int(confidence_score)
    else:
        confidence_score = 50  # Default if missing
    
    print(f"\n📊 Signal {signal_id[:8] if isinstance(signal_id, str) else signal_id}: {pair} {signal_type}")
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

def update_signal(signal_id, decision, reasoning, status_format='PENDING'):
    """Update signal status - adapts to available columns"""
    url = f"{BASE_URL}/aisignal?id=eq.{signal_id}"
    
    timestamp = datetime.utcnow().isoformat()
    
    # Match status format (UPPER, lower, or Title)
    if status_format == status_format.upper():
        status_value = decision.upper()
    elif status_format == status_format.lower():
        status_value = decision.lower()
    else:
        status_value = decision.title()
    
    update_data = {
        "status": status_value
    }
    
    # Try to add metadata fields if they exist
    if decision == "APPROVED":
        update_data["approved_by"] = "github_actions"
        update_data["approved_at"] = timestamp
    elif decision == "REJECTED":
        update_data["rejected_by"] = "github_actions"
        update_data["rejected_at"] = timestamp
    
    # Try to add reasoning if column exists
    update_data["reasoning"] = reasoning
    
    try:
        response = requests.patch(url, headers=HEADERS, json=update_data)
        
        if response.status_code in [200, 204]:
            return True
        elif response.status_code == 400:
            # Column might not exist, try without optional fields
            update_data_minimal = {"status": status_value}
            response = requests.patch(url, headers=HEADERS, json=update_data_minimal)
            return response.status_code in [200, 204]
        else:
            return False
    except Exception as e:
        print(f"   ⚠️  Update error: {e}")
        return False

def main():
    print("="*60)
    print("🤖 KLARPAKKE AUTOMATED ANALYSIS")
    print("="*60)
    
    try:
        signals, status_format = fetch_pending_signals()
        print(f"\n📥 Found {len(signals)} pending signals")
        
        if not signals:
            print("✅ No pending signals to analyze")
            return
        
        # Debug: Show first signal structure
        if len(signals) > 0:
            print(f"\n🔍 Signal structure (first signal):")
            print(f"   Columns: {list(signals[0].keys())}")
        
        approved_count = 0
        rejected_count = 0
        pending_count = 0
        
        for signal in signals:
            decision, reasoning = analyze_signal(signal)
            
            if decision != 'PENDING':
                if update_signal(signal['id'], decision, reasoning, status_format):
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
        
        print("\n" + "="*60)
        print(f"✅ Analysis complete")
        print(f"   Approved: {approved_count}")
        print(f"   Rejected: {rejected_count}")
        print(f"   Pending: {pending_count}")
        print("="*60)
        
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()
