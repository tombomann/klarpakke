# 📊 Klarpakke - Intelligent Trading Signal Analysis

> Automated, risk-managed trading signal analysis for small investors

[![Trading Analysis](https://github.com/tombomann/klarpakke/actions/workflows/trading-analysis.yml/badge.svg)](https://github.com/tombomann/klarpakke/actions/workflows/trading-analysis.yml)

---

## 🆘 **AUTOMATISK OPPSETT - ETT KOMMANDO**

```bash
cd ~/klarpakke && git pull && chmod +x scripts/quick-constraint-fix.sh && ./scripts/quick-constraint-fix.sh
```

**Fikser automatisk:**
- ✅ Direction constraint (case-insensitive)
- ✅ Tester API & DB tilkobling
- ✅ Inserterer test signal
- ✅ Starter workflows

**🚨 Getting constraint errors?** → **[Constraint Fix Guide](./CONSTRAINT-FIX-README.md)**

---

## 🆕 **NEW: Advanced Automation**

🎉 **Latest features deployed:**

- 🔧 **Quick Constraint Fix** - Interactive script to fix direction constraint
- 🔐 **GitHub Secrets** - Secure credential management (no more .env files!)
- 🚨 **Auto-Issue Creation** - Automated debugging when errors occur
- 📊 **Multi-Strategy Backtesting** - Test 2 strategies in parallel
- 💬 **Sentiment Aggregation** - Reddit + Twitter sentiment analysis
- 🤖 **Auto-Fix CLI** - REST API-based setup (no Docker needed)

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
✅ **Auto-Fix** - One command repairs all issues (no Docker!)  

---

## 📚 Documentation

| Guide | Description |
|-------|-------------|
| **[🔧 Constraint Fix](./CONSTRAINT-FIX-README.md)** | **Fix direction constraint errors** |
| **[🆘 Auto-Fix CLI Guide](./AUTO-FIX-README.md)** | **Fix all issues automatically** |
| **[🤖 Automation Guide](./docs/AUTOMATION-GUIDE.md)** | **Complete automation framework** |
| [QUICKSTART.md](./QUICKSTART.md) | Quick reference for common tasks |
| [README-AUTOMATION.md](./README-AUTOMATION.md) | Legacy automation guide |
| [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) | Problem solving and diagnostics |

---

## 🛠️ Quick Start

### 1. Fix Direction Constraint (CRITICAL)

**If you get constraint errors:**

```bash
cd ~/klarpakke
git pull
chmod +x scripts/quick-constraint-fix.sh
./scripts/quick-constraint-fix.sh
```

**This opens an interactive menu** with 3 options:
1. SQL Editor (opens in browser) - **RECOMMENDED**
2. Python script (automatic)
3. Show SQL only

📚 **[Full Constraint Fix Guide →](./CONSTRAINT-FIX-README.md)**

---

### 2. Setup .env.local (One-Time)

```bash
cd ~/klarpakke

# Create .env.local
cat > .env.local << 'EOF'
export SUPABASE_PROJECT_ID="swfyuwkptusceiouqlks"
export SUPABASE_SERVICE_ROLE_KEY="your-service-role-key-here"
export SUPABASE_DB_URL="postgresql://postgres.swfyuwkptusceiouqlks:PASSWORD@aws-0-eu-central-1.pooler.supabase.com:6543/postgres"
EOF

# Get keys from:
# API Key: https://supabase.com/dashboard/project/swfyuwkptusceiouqlks/settings/api
# DB Password: https://supabase.com/dashboard/project/swfyuwkptusceiouqlks/settings/database
```

---

### 3. Run Auto-Fix

```bash
chmod +x scripts/auto-fix-cli.sh
./scripts/auto-fix-cli.sh
```

---

### 4. Watch Workflows

```bash
# Install GitHub CLI if needed
brew install gh
gh auth login

# Watch live runs
gh run watch

# List recent runs
gh run list -L 5
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

### 🔧 Fix & Setup

| Script | Purpose |
|--------|----------|
| `quick-constraint-fix.sh` | **Fix direction constraint (interactive)** |
| `fix-constraint-python.py` | Fix constraint via Python |
| `fix-direction-constraint.sql` | SQL to fix constraint |
| `auto-fix-cli.sh` | **Auto-fix via REST API (no Docker)** |
| `setup-github-secrets.sh` | Migrate .env → GitHub Secrets |

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
│  + Auto-Fix CLI         │ ← NEW!
│  + Constraint Fix       │ ← NEW!
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

## ✅ Success Checklist

Your system is working when:

- [ ] Direction constraint fixed (run `quick-constraint-fix.sh`)
- [ ] `.env.local` created with real credentials
- [ ] `./scripts/auto-fix-cli.sh` completes successfully
- [ ] Database has test signal inserted
- [ ] `gh workflow run multi-strategy-backtest.yml` succeeds
- [ ] Errors auto-create GitHub issues
- [ ] Backtest results saved to artifacts

---

## 🐛 Troubleshooting

**Having issues?**

1. **Constraint errors?** → [Constraint Fix Guide](./CONSTRAINT-FIX-README.md)
2. **Database errors?** → [Auto-Fix Guide](./AUTO-FIX-README.md)
3. **Other issues?** → [Troubleshooting](./TROUBLESHOOTING.md)

**Quick fixes:**
```bash
# Fix constraint
./scripts/quick-constraint-fix.sh

# Fix everything else
./scripts/auto-fix-cli.sh

# Check API directly
source .env.local
curl -H "apikey: $SUPABASE_SERVICE_ROLE_KEY" \
  "https://swfyuwkptusceiouqlks.supabase.co/rest/v1/aisignal?limit=5"
```

---

## 🛠️ Tech Stack

- **Database:** Supabase (PostgreSQL)
- **CI/CD:** GitHub Actions
- **Language:** Python 3 + Bash
- **API:** REST (PostgREST)
- **Secrets:** GitHub Secrets (encrypted)
- **Automation:** Make.com (optional)
- **AI:** Perplexity + Claude
- **Sentiment:** Reddit + Twitter APIs

---

## 📚 Learn More

- **[🔧 Constraint Fix Guide](./CONSTRAINT-FIX-README.md)** ← CONSTRAINT ERRORS? START HERE!
- **[🆘 Auto-Fix CLI Guide](./AUTO-FIX-README.md)** ← DATABASE ISSUES? GO HERE!
- **[🤖 Complete Automation Guide](./docs/AUTOMATION-GUIDE.md)**
- [Quick Reference](./QUICKSTART.md)
- [Troubleshooting](./TROUBLESHOOTING.md)
- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Supabase Docs](https://supabase.com/docs)

---

## 🚀 Next Steps

1. **Fix constraint** (if needed):
   ```bash
   ./scripts/quick-constraint-fix.sh
   ```

2. **Create .env.local** (see Quick Start above)

3. **Run auto-fix:**
   ```bash
   cd ~/klarpakke && git pull && ./scripts/auto-fix-cli.sh
   ```

4. **Watch it work:**
   ```bash
   gh run watch
   ```

5. **Read the full guide:**
   [docs/AUTOMATION-GUIDE.md](./docs/AUTOMATION-GUIDE.md)

---

**Ready? Let's get automated!**

```bash
cd ~/klarpakke && git pull && ./scripts/quick-constraint-fix.sh
```

🚀 **Klarpakke** - Automated, transparent, risk-managed trading
