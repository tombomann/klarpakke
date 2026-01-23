#!/usr/bin/env python3
"""
Backtest trading strategy against historical data
"""
import os
import sys
import json
import argparse
from datetime import datetime, timedelta, timezone
from typing import Dict, List

print("="*70)
print("📊 KLARPAKKE BACKTEST FRAMEWORK")
print("="*70)
print()

def parse_args():
    parser = argparse.ArgumentParser(description='Backtest trading strategy')
    parser.add_argument('--strategy', required=True, choices=['conservative', 'moderate', 'aggressive'])
    parser.add_argument('--min-confidence', type=float, required=True)
    parser.add_argument('--max-risk', type=float, required=True)
    parser.add_argument('--start-date', required=True)
    parser.add_argument('--end-date', required=True)
    parser.add_argument('--output', required=True)
    parser.add_argument('--initial-capital', type=float, default=10000.0)
    return parser.parse_args()

def fetch_historical_signals(start_date: str, end_date: str) -> List[Dict]:
    """
    Fetch historical signals from Supabase
    In real implementation, this would query the database
    """
    # TODO: Implement real Supabase query
    # For now, return mock data
    print(f"💾 Fetching signals from {start_date} to {end_date}...")
    
    # Mock signals for demonstration
    mock_signals = [
        {
            "id": 1,
            "symbol": "BTCUSDT",
            "direction": "LONG",
            "entry_price": 50000,
            "stop_loss": 49000,
            "take_profit": 52000,
            "confidence": 0.85,
            "status": "closed",
            "outcome": "win",  # Hit TP
            "profit_percent": 4.0,
            "r_multiple": 2.0
        },
        {
            "id": 2,
            "symbol": "ETHUSDT",
            "direction": "SHORT",
            "entry_price": 3000,
            "stop_loss": 3100,
            "take_profit": 2800,
            "confidence": 0.78,
            "status": "closed",
            "outcome": "loss",  # Hit SL
            "profit_percent": -3.3,
            "r_multiple": -1.0
        },
        {
            "id": 3,
            "symbol": "SOLUSDT",
            "direction": "LONG",
            "entry_price": 100,
            "stop_loss": 95,
            "take_profit": 110,
            "confidence": 0.90,
            "status": "closed",
            "outcome": "win",
            "profit_percent": 10.0,
            "r_multiple": 2.0
        },
    ]
    
    # Generate more mock signals (simulate 100 trades)
    all_signals = []
    for i in range(100):
        base_signal = mock_signals[i % len(mock_signals)].copy()
        base_signal['id'] = i + 1
        base_signal['confidence'] = 0.65 + (i % 30) / 100  # Vary confidence
        
        # 65% winrate simulation
        if i % 100 < 65:
            base_signal['outcome'] = 'win'
            base_signal['profit_percent'] = 2.0 + (i % 5)
            base_signal['r_multiple'] = 1.5 + (i % 3) * 0.5
        else:
            base_signal['outcome'] = 'loss'
            base_signal['profit_percent'] = -(1.0 + (i % 3))
            base_signal['r_multiple'] = -1.0
        
        all_signals.append(base_signal)
    
    print(f"  ✅ Fetched {len(all_signals)} historical signals")
    return all_signals

def apply_strategy_filter(signals: List[Dict], min_confidence: float) -> List[Dict]:
    """
    Filter signals based on strategy parameters
    """
    filtered = [s for s in signals if s['confidence'] >= min_confidence]
    print(f"🔍 Filtered to {len(filtered)} signals (min confidence: {min_confidence})")
    return filtered

def calculate_metrics(signals: List[Dict], initial_capital: float, max_risk_percent: float) -> Dict:
    """
    Calculate backtest performance metrics
    """
    if not signals:
        return {
            "error": "No signals match strategy criteria",
            "total_trades": 0
        }
    
    total_trades = len(signals)
    wins = len([s for s in signals if s['outcome'] == 'win'])
    losses = total_trades - wins
    
    winrate = wins / total_trades if total_trades > 0 else 0
    
    # Calculate R-multiples
    r_multiples = [s['r_multiple'] for s in signals]
    avg_r = sum(r_multiples) / len(r_multiples) if r_multiples else 0
    
    # Calculate profit/loss
    total_profit_percent = sum([s['profit_percent'] for s in signals])
    
    # Simulate position sizing (1% risk per trade)
    capital = initial_capital
    equity_curve = [capital]
    max_capital = capital
    max_drawdown = 0
    
    for signal in signals:
        risk_amount = capital * (max_risk_percent / 100)
        profit_loss = risk_amount * signal['r_multiple']
        capital += profit_loss
        equity_curve.append(capital)
        
        if capital > max_capital:
            max_capital = capital
        
        drawdown = ((max_capital - capital) / max_capital) * 100 if max_capital > 0 else 0
        if drawdown > max_drawdown:
            max_drawdown = drawdown
    
    final_capital = equity_curve[-1]
    total_profit = final_capital - initial_capital
    total_profit_percent = (total_profit / initial_capital) * 100
    
    return {
        "total_trades": total_trades,
        "wins": wins,
        "losses": losses,
        "winrate": round(winrate, 4),
        "avg_r_multiple": round(avg_r, 2),
        "initial_capital": initial_capital,
        "final_capital": round(final_capital, 2),
        "total_profit": round(total_profit, 2),
        "total_profit_percent": round(total_profit_percent, 2),
        "max_drawdown_percent": round(max_drawdown, 2),
        "equity_curve": [round(e, 2) for e in equity_curve]
    }

def main():
    args = parse_args()
    
    print(f"🎯 Strategy: {args.strategy.upper()}")
    print(f"   Min Confidence: {args.min_confidence}")
    print(f"   Max Risk: {args.max_risk}%")
    print(f"   Period: {args.start_date} → {args.end_date}")
    print(f"   Initial Capital: ${args.initial_capital:,.2f}")
    print()
    
    # Fetch historical signals
    signals = fetch_historical_signals(args.start_date, args.end_date)
    
    # Apply strategy filter
    filtered_signals = apply_strategy_filter(signals, args.min_confidence)
    
    # Calculate metrics
    print()
    print("📊 Calculating performance metrics...")
    metrics = calculate_metrics(filtered_signals, args.initial_capital, args.max_risk)
    
    # Add metadata
    result = {
        "strategy": args.strategy,
        "parameters": {
            "min_confidence": args.min_confidence,
            "max_risk_percent": args.max_risk,
            "start_date": args.start_date,
            "end_date": args.end_date,
            "initial_capital": args.initial_capital
        },
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "metrics": metrics
    }
    
    # Save results - handle both filename and path
    output_dir = os.path.dirname(args.output)
    if output_dir:  # Only create dir if path contains directory
        os.makedirs(output_dir, exist_ok=True)
    
    with open(args.output, 'w') as f:
        json.dump(result, f, indent=2)
    
    print()
    print("="*70)
    print("✅ BACKTEST COMPLETE")
    print("="*70)
    print()
    print(f"📊 Results:")
    print(f"   Total Trades: {metrics['total_trades']}")
    print(f"   Wins: {metrics['wins']} | Losses: {metrics['losses']}")
    print(f"   Winrate: {metrics['winrate']*100:.1f}%")
    print(f"   Avg R-Multiple: {metrics['avg_r_multiple']}x")
    print(f"   Max Drawdown: {metrics['max_drawdown_percent']}%")
    print(f"   Final Capital: ${metrics['final_capital']:,.2f}")
    print(f"   Total Profit: ${metrics['total_profit']:,.2f} ({metrics['total_profit_percent']:+.2f}%)")
    print()
    print(f"💾 Results saved to: {args.output}")
    print()

if __name__ == '__main__':
    main()
