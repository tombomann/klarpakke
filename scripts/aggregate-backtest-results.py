#!/usr/bin/env python3
"""
Aggregate backtest results from multiple strategies
"""
import os
import sys
import json
import argparse
from pathlib import Path
from typing import List, Dict

def parse_args():
    parser = argparse.ArgumentParser(description='Aggregate backtest results')
    parser.add_argument('--input-dir', required=True, help='Directory with backtest results')
    parser.add_argument('--output', required=True, help='Output markdown file')
    return parser.parse_args()

def load_results(input_dir: str) -> List[Dict]:
    """
    Load all JSON results from directory
    """
    results = []
    input_path = Path(input_dir)
    
    print(f"💾 Loading results from {input_dir}...")
    
    # Recursively find all .json files
    for json_file in input_path.rglob('*.json'):
        try:
            with open(json_file, 'r') as f:
                data = json.load(f)
                results.append(data)
                print(f"  ✅ Loaded: {json_file.name}")
        except Exception as e:
            print(f"  ⚠️  Skipped {json_file.name}: {e}")
    
    print(f"\n✅ Loaded {len(results)} backtest results\n")
    return results

def generate_markdown_report(results: List[Dict]) -> str:
    """
    Generate markdown comparison report
    """
    if not results:
        return "## ⚠️ No Results Found\n\nNo backtest results were found to aggregate."
    
    # Sort by total profit
    results_sorted = sorted(results, key=lambda x: x['metrics'].get('total_profit_percent', 0), reverse=True)
    
    report = []
    report.append("# 📊 Backtest Comparison Report")
    report.append("")
    report.append(f"**Generated:** {results[0].get('timestamp', 'N/A')}")
    report.append(f"**Strategies Tested:** {len(results)}")
    report.append("")
    
    # Summary table
    report.append("## 🏆 Performance Ranking")
    report.append("")
    report.append("| Rank | Strategy | Winrate | Avg R | Profit | Max DD |")
    report.append("|------|----------|---------|-------|--------|--------|")
    
    medals = ["🥇", "🥈", "🥉"]
    
    for idx, result in enumerate(results_sorted):
        strategy = result['strategy'].capitalize()
        metrics = result['metrics']
        
        medal = medals[idx] if idx < 3 else f"#{idx+1}"
        winrate = f"{metrics.get('winrate', 0)*100:.1f}%"
        avg_r = f"{metrics.get('avg_r_multiple', 0):.2f}x"
        profit = f"+{metrics.get('total_profit_percent', 0):.1f}%"
        dd = f"{metrics.get('max_drawdown_percent', 0):.1f}%"
        
        report.append(f"| {medal} | {strategy} | {winrate} | {avg_r} | {profit} | {dd} |")
    
    report.append("")
    
    # Detailed results
    report.append("## 📊 Detailed Results")
    report.append("")
    
    for idx, result in enumerate(results_sorted):
        strategy = result['strategy'].capitalize()
        params = result['parameters']
        metrics = result['metrics']
        
        medal = medals[idx] if idx < 3 else f"Strategy {idx+1}"
        
        report.append(f"### {medal} {strategy}")
        report.append("")
        
        # Parameters
        report.append("**Parameters:**")
        report.append(f"- Min Confidence: {params.get('min_confidence', 0)}")
        report.append(f"- Max Risk: {params.get('max_risk_percent', 0)}%")
        report.append(f"- Period: {params.get('start_date', 'N/A')} → {params.get('end_date', 'N/A')}")
        report.append(f"- Initial Capital: ${params.get('initial_capital', 0):,.2f}")
        report.append("")
        
        # Metrics
        report.append("**Performance:**")
        report.append(f"- Total Trades: {metrics.get('total_trades', 0)}")
        report.append(f"- Wins: {metrics.get('wins', 0)} | Losses: {metrics.get('losses', 0)}")
        report.append(f"- Winrate: {metrics.get('winrate', 0)*100:.1f}%")
        report.append(f"- Avg R-Multiple: {metrics.get('avg_r_multiple', 0):.2f}x")
        report.append(f"- Max Drawdown: {metrics.get('max_drawdown_percent', 0):.1f}%")
        report.append(f"- Final Capital: ${metrics.get('final_capital', 0):,.2f}")
        report.append(f"- Total Profit: ${metrics.get('total_profit', 0):,.2f} ({metrics.get('total_profit_percent', 0):+.1f}%)")
        report.append("")
    
    # Recommendations
    report.append("## 🎯 Recommendations")
    report.append("")
    
    best = results_sorted[0]
    best_strategy = best['strategy'].capitalize()
    best_winrate = best['metrics'].get('winrate', 0) * 100
    best_profit = best['metrics'].get('total_profit_percent', 0)
    
    report.append(f"✅ **Best Overall:** {best_strategy} strategy")
    report.append(f"  - Achieved {best_profit:+.1f}% profit with {best_winrate:.1f}% winrate")
    report.append("")
    
    # Find highest winrate
    highest_winrate = max(results, key=lambda x: x['metrics'].get('winrate', 0))
    report.append(f"🛡️ **Safest:** {highest_winrate['strategy'].capitalize()} strategy")
    report.append(f"  - Highest winrate: {highest_winrate['metrics'].get('winrate', 0)*100:.1f}%")
    report.append("")
    
    # Find highest R
    highest_r = max(results, key=lambda x: x['metrics'].get('avg_r_multiple', 0))
    report.append(f"🚀 **Most Aggressive:** {highest_r['strategy'].capitalize()} strategy")
    report.append(f"  - Highest avg R: {highest_r['metrics'].get('avg_r_multiple', 0):.2f}x")
    report.append("")
    
    report.append("---")
    report.append("")
    report.append("*Generated by Klarpakke Backtest Framework*")
    
    return "\n".join(report)

def main():
    args = parse_args()
    
    print("="*70)
    print("📊 AGGREGATE BACKTEST RESULTS")
    print("="*70)
    print()
    
    # Load results
    results = load_results(args.input_dir)
    
    if not results:
        print("⚠️  No results found!")
        sys.exit(1)
    
    # Generate report
    print("📝 Generating markdown report...")
    report = generate_markdown_report(results)
    
    # Save report
    with open(args.output, 'w') as f:
        f.write(report)
    
    print(f"✅ Report saved to: {args.output}")
    print()
    print("="*70)
    print("✅ AGGREGATION COMPLETE")
    print("="*70)
    print()

if __name__ == '__main__':
    main()
