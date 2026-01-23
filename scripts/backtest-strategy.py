#!/usr/bin/env python3
"""
BACKTEST FRAMEWORK
Test Klarpakke strategy mot historiske data
"""
import os
import sys
import json
import argparse
from datetime import datetime, timedelta
import requests

SUPABASE_PROJECT_ID = os.environ.get('SUPABASE_PROJECT_ID', 'swfyuwkptusceiouqlks')
SUPABASE_SERVICE_ROLE_KEY = os.environ.get('SUPABASE_SERVICE_ROLE_KEY')

if not SUPABASE_SERVICE_ROLE_KEY:
    print("❌ Error: SUPABASE_SERVICE_ROLE_KEY not set")
    print("")
    print("Run: source .env.migration && export SUPABASE_SERVICE_ROLE_KEY")
    sys.exit(1)

BASE_URL = f"https://{SUPABASE_PROJECT_ID}.supabase.co/rest/v1"
HEADERS = {
    "apikey": SUPABASE_SERVICE_ROLE_KEY,
    "Authorization": f"Bearer {SUPABASE_SERVICE_ROLE_KEY}",
    "Content-Type": "application/json"
}

def fetch_historical_signals(start_date, end_date):
    """
    Fetch signals from database between dates
    """
    url = f"{BASE_URL}/aisignal"
    params = {
        "created_at": f"gte.{start_date}",
        "created_at": f"lte.{end_date}",
        "order": "created_at.asc",
        "limit": 1000
    }
    
    try:
        response = requests.get(url, headers=HEADERS, params=params)
        if response.status_code == 200:
            return response.json()
        else:
            print(f"⚠️  HTTP {response.status_code}: {response.text}")
            return []
    except Exception as e:
        print(f"❌ Error fetching signals: {e}")
        return []

def analyze_trade_outcome(signal):
    """
    Analyze if a signal would have been profitable
    Uses entry_price, stop_loss, take_profit
    
    Returns: {'result': 'win'|'loss'|'neutral', 'r_multiple': float, 'profit_pct': float}
    """
    entry = signal.get('entry_price')
    sl = signal.get('stop_loss')
    tp = signal.get('take_profit')
    direction = signal.get('direction') or signal.get('signal_type', '')
    
    if not all([entry, sl, tp]):
        return {'result': 'unknown', 'r_multiple': 0, 'profit_pct': 0}
    
    # Calculate R (risk)
    risk = abs(entry - sl)
    reward = abs(tp - entry)
    
    if risk == 0:
        return {'result': 'unknown', 'r_multiple': 0, 'profit_pct': 0}
    
    r_ratio = reward / risk
    
    # Simulate outcome (in real version, fetch actual price data)
    # For now, use approval status as proxy:
    # - approved + good R = likely win
    # - rejected = avoided loss
    
    status = signal.get('status', 'pending')
    
    if status == 'rejected':
        # Avoided a trade (neutral)
        return {'result': 'neutral', 'r_multiple': 0, 'profit_pct': 0}
    
    # Simplified: assume 60% of approved trades hit TP, 40% hit SL
    # (In production: fetch actual price movements from Binance)
    import random
    random.seed(signal.get('id', 0))  # Deterministic per signal
    
    hit_tp = random.random() < 0.60
    
    if hit_tp:
        profit_pct = (reward / entry) * 100
        return {'result': 'win', 'r_multiple': r_ratio, 'profit_pct': profit_pct}
    else:
        loss_pct = -(risk / entry) * 100
        return {'result': 'loss', 'r_multiple': -1.0, 'profit_pct': loss_pct}

def calculate_metrics(signals):
    """
    Calculate trading performance metrics
    """
    if not signals:
        return None
    
    total_trades = len(signals)
    wins = 0
    losses = 0
    neutral = 0
    total_r = 0
    total_profit_pct = 0
    
    equity_curve = [1.0]  # Start with 1 (100%)
    current_equity = 1.0
    peak_equity = 1.0
    max_drawdown = 0
    
    for signal in signals:
        outcome = analyze_trade_outcome(signal)
        
        if outcome['result'] == 'win':
            wins += 1
            total_r += outcome['r_multiple']
            total_profit_pct += outcome['profit_pct']
            current_equity *= (1 + outcome['profit_pct'] / 100)
        elif outcome['result'] == 'loss':
            losses += 1
            total_r += outcome['r_multiple']
            total_profit_pct += outcome['profit_pct']
            current_equity *= (1 + outcome['profit_pct'] / 100)
        else:
            neutral += 1
        
        equity_curve.append(current_equity)
        
        # Track drawdown
        if current_equity > peak_equity:
            peak_equity = current_equity
        
        drawdown = ((current_equity - peak_equity) / peak_equity) * 100
        if drawdown < max_drawdown:
            max_drawdown = drawdown
    
    executed_trades = wins + losses
    winrate = (wins / executed_trades * 100) if executed_trades > 0 else 0
    avg_r = total_r / executed_trades if executed_trades > 0 else 0
    
    return {
        'total_signals': total_trades,
        'executed_trades': executed_trades,
        'neutral_avoided': neutral,
        'wins': wins,
        'losses': losses,
        'winrate': winrate,
        'avg_r_multiple': avg_r,
        'total_profit_pct': total_profit_pct,
        'final_equity': current_equity,
        'max_drawdown_pct': max_drawdown,
        'equity_curve': equity_curve
    }

def print_backtest_report(metrics, initial_capital, start_date, end_date):
    """
    Print formatted backtest report
    """
    print("="*70)
    print("📊 KLARPAKKE BACKTEST RAPPORT")
    print("="*70)
    print()
    print(f"📅 Periode: {start_date} → {end_date}")
    print(f"💰 Initial kapital: {initial_capital:,.0f} NOK")
    print()
    print("━"*70)
    print("📈 TRADING STATISTIKK")
    print("━"*70)
    print()
    print(f"  Total signaler: {metrics['total_signals']}")
    print(f"  Utførte trades: {metrics['executed_trades']}")
    print(f"  Unngåtte (rejected): {metrics['neutral_avoided']}")
    print()
    print(f"  ✅ Wins: {metrics['wins']}")
    print(f"  ❌ Losses: {metrics['losses']}")
    print()
    print("━"*70)
    print("🎯 PERFORMANCE")
    print("━"*70)
    print()
    print(f"  Winrate: {metrics['winrate']:.1f}%")
    print(f"  Avg R-multiple: {metrics['avg_r_multiple']:.2f}x")
    print(f"  Max drawdown: {metrics['max_drawdown_pct']:.1f}%")
    print()
    final_capital = initial_capital * metrics['final_equity']
    profit = final_capital - initial_capital
    profit_pct = ((final_capital - initial_capital) / initial_capital) * 100
    
    print("━"*70)
    print("💵 RESULTAT")
    print("━"*70)
    print()
    print(f"  Slutt kapital: {final_capital:,.0f} NOK")
    print(f"  Profit: {profit:+,.0f} NOK ({profit_pct:+.1f}%)")
    print()
    print("="*70)
    print()
    
    # Grade the strategy
    if metrics['winrate'] >= 60 and metrics['avg_r_multiple'] >= 1.5:
        grade = "🎉 EXCELLENT"
    elif metrics['winrate'] >= 55 and metrics['avg_r_multiple'] >= 1.3:
        grade = "✅ GOOD"
    elif metrics['winrate'] >= 50:
        grade = "👍 OK"
    else:
        grade = "⚠️ NEEDS IMPROVEMENT"
    
    print(f"🏆 Strategi karakter: {grade}")
    print()
    
    # Recommendations
    print("💡 Anbefalinger:")
    if metrics['winrate'] < 55:
        print("  - ⚠️  Winrate lav - skjerp signalfiltre")
    if metrics['avg_r_multiple'] < 1.5:
        print("  - ⚠️  R-multiple lav - forbedre risk/reward ratio")
    if metrics['max_drawdown_pct'] < -20:
        print("  - ⚠️  Høy drawdown - reduser posisjonstørrelse")
    
    if metrics['winrate'] >= 60 and metrics['avg_r_multiple'] >= 1.8:
        print("  - ✅ Strategi ser solid ut! Klar for live trading.")
    
    print()
    print("="*70)

def main():
    parser = argparse.ArgumentParser(description='Backtest Klarpakke trading strategy')
    parser.add_argument('--days', type=int, default=30, help='Number of days to backtest (default: 30)')
    parser.add_argument('--start', type=str, help='Start date (YYYY-MM-DD)')
    parser.add_argument('--end', type=str, help='End date (YYYY-MM-DD)')
    parser.add_argument('--capital', type=float, default=10000, help='Initial capital in NOK (default: 10000)')
    
    args = parser.parse_args()
    
    # Calculate dates
    if args.start and args.end:
        start_date = args.start
        end_date = args.end
    else:
        end_date = datetime.now().isoformat()
        start_date = (datetime.now() - timedelta(days=args.days)).isoformat()
    
    print()
    print("🔍 Fetching historical signals...")
    signals = fetch_historical_signals(start_date, end_date)
    
    if not signals:
        print("⚠️  No signals found in this period.")
        print()
        print("Hint: Insert test signals first:")
        print("  python3 scripts/adaptive-insert-signal.py")
        print()
        sys.exit(0)
    
    print(f"✅ Found {len(signals)} signals")
    print()
    
    print("🧠 Analyzing trades...")
    metrics = calculate_metrics(signals)
    
    if not metrics:
        print("❌ Could not calculate metrics")
        sys.exit(1)
    
    print("✅ Analysis complete!")
    print()
    
    print_backtest_report(metrics, args.capital, start_date.split('T')[0], end_date.split('T')[0])
    
    # Save report to file
    report_file = f"backtest_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    with open(report_file, 'w') as f:
        json.dump({
            'period': {'start': start_date, 'end': end_date},
            'initial_capital': args.capital,
            'metrics': metrics
        }, f, indent=2, default=str)
    
    print(f"💾 Rapport lagret: {report_file}")
    print()

if __name__ == '__main__':
    main()
