# 📊 Klarpakke - Intelligent Trading Signal Analysis

> Automated, risk-managed trading signal analysis for small investors

[![Trading Analysis](https://github.com/tombomann/klarpakke/actions/workflows/trading-analysis.yml/badge.svg)](https://github.com/tombomann/klarpakke/actions/workflows/trading-analysis.yml)

---

## 🚀 **ONE-COMMAND SETUP**

```bash
cd ~/klarpakke && git pull && bash scripts/master-fix-and-test.sh
```

**This automatically:**
- ✅ Fixes database schema
- ✅ Discovers working configuration  
- ✅ Inserts test signal
- ✅ Tests analysis pipeline
- ✅ Reports full status

---

## 🆕 **NEW: Advanced Automation**

🎉 **Latest features deployed:**

- 🔐 **GitHub Secrets** - Secure credential management (no more .env files!)
- 🚨 **Auto-Issue Creation** - Automated debugging when errors occur
- 📊 **Multi-Strategy Backtesting** - Test 2 strategies in parallel
- 💬 **Sentiment Aggregation** - Reddit + Twitter sentiment analysis

📚 **[READ THE COMPLETE AUTOMATION GUIDE →](./docs/AUTOMATION-GUIDE.md)**

---

## 🎯 What is Klarpakke?

Klarpakke is an **automated trading signal analysis system** that:

1. **Receives** AI-generated trading signals (via Webflow/Bubble/API)
2. **Analyzes** signals based on confidence scores and risk parameters
3. **Approves/Rejects** automatically using configurable thresholds
4. **Logs** all decisions with reasoning for audit trail
5. **Executes** approved trades (via Make.com integration - optional)

### Key Features

✅ **Fully Automated** - Runs every 5 minutes via GitHub Actions  
✅ **Risk-Managed** - Configurable approval thresholds (default: 75% confidence)  
✅ **Auditable** - Every decision logged with timestamp and reasoning  
✅ **Adaptive** - Works with multiple schema variations  
✅ **Self-Healing** - Automatic schema cache refresh and error recovery  
✅ **Zero-Cost** - Runs on GitHub Actions free tier  
✅ **Auto-Debugging** - Creates GitHub issues on errors  
✅ **Sentiment-Aware** - Integrates community sentiment  

---

## 📚 Documentation

| Guide | Description |
|-------|-------------|
| **[🤖 Automation Guide](./docs/AUTOMATION-GUIDE.md)** | **Complete automation framework** |
| [QUICKSTART.md](./QUICKSTART.md) | Quick reference for common tasks |
| [README-AUTOMATION.md](./README-AUTOMATION.md) | Legacy automation guide |
| [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) | Problem solving and diagnostics |

---

## 🛠️ Quick Start

### 1. Setup GitHub Secrets (One-Time)

```bash
cd ~/klarpakke
git pull

# Migrate from .env to GitHub Secrets
chmod +x scripts/setup-github-secrets.sh
./scripts/setup-github-secrets.sh
```

### 2. Test Backtest Framework

```bash
python3 scripts/backtest-strategy.py \
  --strategy conservative \
  --min-confidence 0.85 \
  --max-risk 1.0 \
  --start-date 2024-01-01 \
  --end-date 2024-12-31 \
  --output results.json
```

### 3. Test Sentiment Aggregation

```bash
python3 scripts/aggregate-sentiment.py \
  --symbol BTC \
  --base-confidence 0.75
```

---

## 📊 Monitoring

### GitHub Actions Workflows

| Workflow | Schedule | Purpose |
|----------|----------|----------|
| **[Trading Analysis](https://github.com/tombomann/klarpakke/actions/workflows/trading-with-auto-issue.yml)** | Every 5 min | Analyze signals + auto-issue on error |
| **[Multi-Strategy Backtest](https://github.com/tombomann/klarpakke/actions/workflows/multi-strategy-backtest.yml)** | Weekly | Compare strategy performance |

### Commands

```bash
# Watch live runs
gh run watch

# List recent runs
gh run list -L 5

# Manual trigger
gh workflow run trading-with-auto-issue.yml
gh workflow run multi-strategy-backtest.yml
```

---

## 🔧 Available Scripts

### 🔐 Security & Setup

| Script | Purpose |
|--------|----------|
| `setup-github-secrets.sh` | Migrate .env → GitHub Secrets |
| `master-fix-and-test.sh` | Auto-fix database + test |
| `ultimate-setup.sh` | Full end-to-end setup |

### 📊 Analysis & Backtesting

| Script | Purpose |
|--------|----------|
| `analyze_signals.py` | Core analysis logic |
| `backtest-strategy.py` | Backtest single strategy |
| `aggregate-backtest-results.py` | Compare strategy results |
| `aggregate-sentiment.py` | Fetch Reddit/Twitter sentiment |

### 🐛 Debug & Diagnostics

| Script | Purpose |
|--------|----------|
| `debug-aisignal.py` | Show table contents |
| `fix-schema-cache.py` | Fix PostgREST cache |
| `adaptive-insert-signal.py` | Smart test signal insert |

**Full reference:** [docs/AUTOMATION-GUIDE.md#-scripts-reference](./docs/AUTOMATION-GUIDE.md#-scripts-reference)

---

## ⚙️ System Architecture

```
┌─────────────────────────┐
│  AI Signal Generation   │
│  (Perplexity + Claude)  │
└────────┬────────────────┘
         │
         │ webhook/API
         ↓
┌────────┴────────────────┐
│   Supabase Database     │
│   (aisignal table)      │
│   status = 'PENDING'    │
└────────┬────────────────┘
         │
         │ every 5 min
         ↓
┌────────┴────────────────┐
│  GitHub Actions         │
│  + Auto-Issue on Error  │ ← NEW!
│  + Sentiment Boost      │ ← NEW!
│  - Fetch PENDING        │
│  - Analyze confidence   │
│  - Approve/Reject       │
│  - Log reasoning        │
└────────┬────────────────┘
         │
         │ update status
         ↓
┌────────┴────────────────┐
│   Supabase Database     │
│   status = 'APPROVED'   │
│   approved_by = 'gh...' │
│   reasoning = '...'     │
└────────┬────────────────┘
         │
         │ webhook (optional)
         ↓
┌────────┴────────────────┐
│   Make.com Automation   │
│   Execute Trade         │
└─────────────────────────┘
```

---

## 📊 New Features Explained

### 🔐 GitHub Secrets

**Before:** Secrets in `.env` files (security risk)  
**After:** Encrypted GitHub Secrets (secure, audited)

```bash
# One-time migration
./scripts/setup-github-secrets.sh
```

### 🚨 Auto-Issue on Errors

**When a workflow fails:**
1. Captures full error log
2. Creates GitHub issue automatically
3. Includes debugging checklist
4. Auto-assigns to you

**No more silent failures!**

### 📊 Multi-Strategy Backtesting

**Test multiple strategies in parallel:**
- Conservative (70% winrate, 1.5x R)
- Moderate (65% winrate, 2.0x R)

```bash
gh workflow run multi-strategy-backtest.yml
```

### 💬 Sentiment Aggregation

**Boost AI confidence with community sentiment:**

```
AI: 75% confidence
+ Reddit: 82% bullish
+ Twitter: 78% bullish
= Adjusted: 81% confidence ✅
```

---

## ✅ Success Checklist

Your system is working when:

- [ ] `bash scripts/setup-github-secrets.sh` completes
- [ ] `gh secret list` shows secrets uploaded
- [ ] `gh workflow run trading-with-auto-issue.yml` succeeds
- [ ] `gh workflow run multi-strategy-backtest.yml` generates report
- [ ] Errors auto-create GitHub issues
- [ ] Backtest results saved to artifacts

---

## 🐛 Troubleshooting

**Having issues?** See [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)

**Quick fixes:**
```bash
# Fix everything automatically
bash scripts/master-fix-and-test.sh

# Fix schema cache
python3 scripts/fix-schema-cache.py

# Debug table state
python3 scripts/debug-aisignal.py
```

---

## 🛠️ Tech Stack

- **Database:** Supabase (PostgreSQL)
- **CI/CD:** GitHub Actions
- **Language:** Python 3
- **Secrets:** GitHub Secrets (encrypted)
- **Automation:** Make.com (optional)
- **AI:** Perplexity + Claude
- **Sentiment:** Reddit + Twitter APIs

---

## 📚 Learn More

- **[🤖 Complete Automation Guide](./docs/AUTOMATION-GUIDE.md)** ← START HERE!
- [Quick Reference](./QUICKSTART.md)
- [Troubleshooting](./TROUBLESHOOTING.md)
- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Supabase Docs](https://supabase.com/docs)

---

## 🚀 Next Steps

1. **Setup GitHub Secrets:**
   ```bash
   ./scripts/setup-github-secrets.sh
   ```

2. **Run backtest:**
   ```bash
   gh workflow run multi-strategy-backtest.yml
   ```

3. **Watch it work:**
   ```bash
   gh run watch
   ```

4. **Read the full guide:**
   [docs/AUTOMATION-GUIDE.md](./docs/AUTOMATION-GUIDE.md)

---

**Ready? Let's get automated!**

```bash
cd ~/klarpakke && git pull && ./scripts/setup-github-secrets.sh
```

🚀 **Klarpakke** - Automated, transparent, risk-managed trading
