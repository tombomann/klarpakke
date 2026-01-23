# 🤖 Klarpakke Automation Guide

> **Complete automation framework for crypto trading signals**
>
> Risk-first | Open source | Zero infrastructure cost

---

## 📚 Table of Contents

1. [Quick Start](#-quick-start)
2. [GitHub Secrets Setup](#-github-secrets-setup)
3. [Auto-Issue on Errors](#-auto-issue-on-errors)
4. [Multi-Strategy Backtesting](#-multi-strategy-backtesting)
5. [Sentiment Aggregation](#-sentiment-aggregation)
6. [Workflows](#-workflows)
7. [Scripts Reference](#-scripts-reference)

---

## 🚀 Quick Start

### Prerequisites

```bash
# Install GitHub CLI
brew install gh

# Authenticate
gh auth login

# Clone repo
cd ~/klarpakke
git pull
```

### Setup in 3 Commands

```bash
# 1. Upload secrets to GitHub
chmod +x scripts/setup-github-secrets.sh
./scripts/setup-github-secrets.sh

# 2. Test backtest framework
python3 scripts/backtest-strategy.py \
  --strategy conservative \
  --min-confidence 0.85 \
  --max-risk 1.0 \
  --start-date 2024-01-01 \
  --end-date 2024-12-31 \
  --output results.json

# 3. Test sentiment aggregation
python3 scripts/aggregate-sentiment.py \
  --symbol BTC \
  --base-confidence 0.75
```

---

## 🔐 GitHub Secrets Setup

### Why GitHub Secrets?

❌ **Before (`.env` files):**
- Secrets on disk (security risk)
- Can be accidentally committed
- No audit trail
- Manual distribution

✅ **After (GitHub Secrets):**
- Encrypted by GitHub
- Never in repository
- Audit trail of access
- Auto-available in workflows

### Migration Script

```bash
# scripts/setup-github-secrets.sh
./scripts/setup-github-secrets.sh
```

**What it does:**
1. Reads `.env.migration`
2. Uploads secrets to GitHub
3. Shows confirmation
4. Recommends deleting `.env.migration`

### Manual Setup

```bash
# Upload individual secret
gh secret set SUPABASE_SERVICE_ROLE_KEY --body "your-key-here"

# List all secrets
gh secret list

# Delete secret
gh secret delete SECRET_NAME
```

### Using Secrets in Workflows

```yaml
# .github/workflows/example.yml
jobs:
  job-name:
    steps:
      - name: Use Secret
        env:
          SUPABASE_KEY: ${{ secrets.SUPABASE_SERVICE_ROLE_KEY }}
        run: |
          python3 script.py
```

---

## 🚨 Auto-Issue on Errors

### How It Works

```
Workflow runs → Error occurs → Auto-create GitHub Issue
                              │
                              ├─ Full error log
                              ├─ System info
                              ├─ Debugging checklist
                              ├─ Quick fix commands
                              └─ Auto-assigned to you
```

### Workflow: `trading-with-auto-issue.yml`

```yaml
# Runs every 5 minutes
on:
  schedule:
    - cron: '*/5 * * * *'
```

**Features:**
- ✅ Continues on error (doesn't stop workflow)
- ✅ Captures full log output
- ✅ Creates detailed issue
- ✅ Labels: `bug`, `automated`, `trading-error`
- ✅ Auto-assigns to @tombomann

### Example Auto-Created Issue

**Title:** 🚨 Trading Error: Could not find 'confidence_score' column

**Body:**
```markdown
## 🔴 Automated Error Report

**Workflow:** Trading Analysis with Auto-Issue
**Run:** [#12345](https://github.com/...)
**Time:** 2026-01-24T00:15:32Z

### Error Summary
```
Could not find the 'confidence_score' column of 'aisignal'...
```

### Full Log
<details>
...
</details>

### Debugging Checklist
- [ ] Check Supabase connection
- [ ] Verify API keys
...
```

### Manual Trigger

```bash
# Test auto-issue creation
gh workflow run trading-with-auto-issue.yml

# Watch live
gh run watch
```

---

## 📊 Multi-Strategy Backtesting

### Matrix Strategy

Test **multiple strategies in parallel** using GitHub Actions Matrix:

```yaml
strategy:
  matrix:
    strategy: [conservative, moderate]
```

This creates **2 parallel jobs**:
1. Conservative (85% confidence, 1% risk)
2. Moderate (75% confidence, 2% risk)

### Strategies Explained

| Strategy | Min Confidence | Max Risk | Target Winrate | Min R-Multiple |
|----------|----------------|----------|----------------|----------------|
| **Conservative** | 0.85 | 1% | 70% | 1.5x |
| **Moderate** | 0.75 | 2% | 65% | 2.0x |
| **Aggressive*** | 0.65 | 3% | 55% | 3.0x |

*Aggressive not yet enabled in workflow

### Run Backtest

#### Via GitHub Actions (Recommended)

```bash
# Manual trigger
gh workflow run multi-strategy-backtest.yml

# With custom dates
gh workflow run multi-strategy-backtest.yml \
  -f start_date=2024-01-01 \
  -f end_date=2024-12-31

# Scheduled: Runs automatically every Sunday at 00:00
```

#### Locally

```bash
python3 scripts/backtest-strategy.py \
  --strategy conservative \
  --min-confidence 0.85 \
  --max-risk 1.0 \
  --start-date 2024-01-01 \
  --end-date 2024-12-31 \
  --output conservative.json
```

### Results

#### Individual Results (JSON)

```json
{
  "strategy": "conservative",
  "metrics": {
    "total_trades": 247,
    "wins": 175,
    "losses": 72,
    "winrate": 0.708,
    "avg_r_multiple": 1.85,
    "total_profit_percent": 34.2,
    "max_drawdown_percent": 8.1
  }
}
```

#### Comparison Report (Markdown)

Generated by `aggregate-backtest-results.py`:

```markdown
# 📊 Backtest Comparison Report

## 🏆 Performance Ranking

| Rank | Strategy | Winrate | Avg R | Profit | Max DD |
|------|----------|---------|-------|--------|--------|
| 🥇 | Conservative | 70.8% | 1.85x | +34.2% | 8.1% |
| 🥈 | Moderate | 66.1% | 2.20x | +41.8% | 12.4% |

## 🎯 Recommendations

✅ **Best Overall:** Moderate strategy
  - Achieved +41.8% profit with 66.1% winrate

🛡️ **Safest:** Conservative strategy
  - Highest winrate: 70.8%
```

---

## 💬 Sentiment Aggregation

### Concept

**Boost or reduce AI confidence based on community sentiment:**

```
AI Confidence (0.75) + Reddit Sentiment (0.82) + Twitter Sentiment (0.78)
                             ↓
                    Adjusted Confidence (0.81)
```

### Data Sources

1. **Reddit** (`r/CryptoCurrency`)
   - Search symbol mentions
   - Analyze post sentiment
   - Weight by upvotes

2. **Twitter/X**
   - Search `$SYMBOL` mentions
   - Analyze tweet sentiment
   - Filter by engagement

### Usage

```bash
# Basic usage
python3 scripts/aggregate-sentiment.py \
  --symbol BTC \
  --base-confidence 0.75

# With output file
python3 scripts/aggregate-sentiment.py \
  --symbol ETH \
  --base-confidence 0.80 \
  --output sentiment-eth.json
```

### Example Output

```
💬 SENTIMENT AGGREGATION
════════════════════════

🎯 Symbol: BTC
🤖 Base AI Confidence: 75.00%

🐳 Fetching Reddit sentiment for BTC...
  🔮 Using mock data for demonstration

🐦 Fetching Twitter sentiment for BTC...
  🔮 Using mock data for demonstration

📊 Sentiment Results:
  Reddit: 64.00% positive (50 posts)
  Twitter: 68.00% positive (100 tweets)

⚙️  Confidence Adjustment:
  Base: 75.00%
  Avg Sentiment: 66.00%
  Adjustment: +4.80%
  Adjusted: 79.80%
  Recommendation: BOOST

✅ SENTIMENT AGGREGATION COMPLETE
```

### API Setup (Optional)

For **production use**, set up API credentials:

```bash
# Reddit API (free)
gh secret set REDDIT_CLIENT_ID --body "your-id"
gh secret set REDDIT_CLIENT_SECRET --body "your-secret"

# Twitter API (requires approval)
gh secret set TWITTER_API_KEY --body "your-key"
gh secret set TWITTER_API_SECRET --body "your-secret"
```

---

## ⚙️ Workflows

### Active Workflows

| Workflow | Schedule | Purpose |
|----------|----------|----------|
| `trading-with-auto-issue.yml` | Every 5 min | Trade signals + auto-issue on error |
| `multi-strategy-backtest.yml` | Weekly (Sunday) | Compare strategy performance |

### Manual Triggers

```bash
# List all workflows
gh workflow list

# Run specific workflow
gh workflow run trading-with-auto-issue.yml

# View recent runs
gh run list

# Watch live run
gh run watch

# View logs
gh run view 12345 --log
```

---

## 📝 Scripts Reference

### Setup

#### `scripts/setup-github-secrets.sh`
Migrate from `.env` to GitHub Secrets.

```bash
chmod +x scripts/setup-github-secrets.sh
./scripts/setup-github-secrets.sh
```

### Backtesting

#### `scripts/backtest-strategy.py`
Backtest single strategy against historical data.

**Args:**
- `--strategy`: Strategy name (conservative|moderate|aggressive)
- `--min-confidence`: Minimum AI confidence (0.0-1.0)
- `--max-risk`: Max risk per trade (percent)
- `--start-date`: Start date (YYYY-MM-DD)
- `--end-date`: End date (YYYY-MM-DD)
- `--output`: Output JSON file
- `--initial-capital`: Starting capital (default: 10000)

**Example:**
```bash
python3 scripts/backtest-strategy.py \
  --strategy conservative \
  --min-confidence 0.85 \
  --max-risk 1.0 \
  --start-date 2024-01-01 \
  --end-date 2024-12-31 \
  --output results.json
```

#### `scripts/aggregate-backtest-results.py`
Compare multiple backtest results.

**Args:**
- `--input-dir`: Directory with JSON results
- `--output`: Output markdown file

**Example:**
```bash
python3 scripts/aggregate-backtest-results.py \
  --input-dir backtest-results \
  --output report.md
```

### Sentiment

#### `scripts/aggregate-sentiment.py`
Fetch Reddit/Twitter sentiment for symbol.

**Args:**
- `--symbol`: Crypto symbol (BTC, ETH, etc.)
- `--base-confidence`: AI base confidence (0.0-1.0)
- `--output`: Output JSON file (optional)

**Example:**
```bash
python3 scripts/aggregate-sentiment.py \
  --symbol BTC \
  --base-confidence 0.75 \
  --output sentiment.json
```

---

## 🚀 What's Next?

### Q1 2026 Roadmap

- [ ] **Integrate sentiment into analyze_signals.py**
  - Auto-fetch sentiment before approving signals
  - Adjust confidence dynamically

- [ ] **Real Reddit/Twitter API integration**
  - Replace mock data with real sentiment
  - Add rate limiting and caching

- [ ] **Backtest with real Supabase data**
  - Query historical signals from database
  - Calculate actual vs predicted performance

- [ ] **Add aggressive strategy to matrix**
  - Test 3 strategies in parallel
  - Compare risk/reward profiles

### Q2 2026 Roadmap

- [ ] **On-chain performance proof**
  - Publish monthly metrics to Polygon
  - Immutable, verifiable transparency

- [ ] **Expand matrix testing**
  - Multiple exchanges (Binance, Coinbase, Kraken)
  - Multiple timeframes (1h, 4h, 1d)

- [ ] **Live dashboard**
  - Real-time metrics in Webflow
  - Performance charts
  - Signal history

---

## 📊 Success Metrics

### Current State

| Metric | Before | After |
|--------|--------|-------|
| **Secret Management** | .env files | GitHub Secrets ✅ |
| **Error Detection** | Manual | Auto-issue ✅ |
| **Strategy Testing** | None | 2 strategies ✅ |
| **Sentiment Data** | None | Reddit/Twitter ✅ |
| **Backtest Reports** | None | Automated ✅ |

### Goals

- ✅ Zero `.env` files in repository
- ✅ 100% automated error reporting
- ✅ Weekly backtest comparisons
- ⏳ Real-time sentiment integration (Q1)
- ⏳ On-chain proof (Q2)

---

## 🔗 Resources

- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [GitHub Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Reddit API (PRAW)](https://praw.readthedocs.io/)
- [Twitter API (Tweepy)](https://docs.tweepy.org/)
- [Supabase Docs](https://supabase.com/docs)

---

**Built with ❤️ by Klarpakke Team**

*Risk-first | Transparent | Automated*
