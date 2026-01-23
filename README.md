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

## 🎯 What is Klarpakke?

Klarpakke is an **automated trading signal analysis system** that:

1. **Receives** AI-generated trading signals (via Webflow/Bubble/API)
2. **Analyzes** signals based on confidence scores and risk parameters
3. **Approves/Rejects** automatically using configurable thresholds
4. **Logs** all decisions with reasoning for audit trail
5. **Executes** approved trades (via Make.com integration - optional)

### Key Features

✅ **Fully Automated** - Runs every 15 minutes via GitHub Actions  
✅ **Risk-Managed** - Configurable approval thresholds (default: 75% confidence)  
✅ **Auditable** - Every decision logged with timestamp and reasoning  
✅ **Adaptive** - Works with multiple schema variations  
✅ **Self-Healing** - Automatic schema cache refresh and error recovery  
✅ **Zero-Cost** - Runs on GitHub Actions free tier  

---

## 📋 Quick Reference

### For First-Time Setup

```bash
cd ~/klarpakke
git pull
bash scripts/ultimate-setup.sh
```

### For Troubleshooting

```bash
cd ~/klarpakke
git pull
bash scripts/master-fix-and-test.sh
```

### For Daily Use

```bash
# Watch live runs
gh run watch

# List recent runs
gh run list --workflow="trading-analysis.yml" -L 5

# Test locally
python3 scripts/analyze_signals.py
```

---

## 📖 Documentation

| Guide | Description |
|-------|-------------|
| [QUICKSTART.md](./QUICKSTART.md) | Quick reference for common tasks |
| [README-AUTOMATION.md](./README-AUTOMATION.md) | Complete automation guide |
| [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) | Problem solving and diagnostics |

---

## 🔧 Available Scripts

### 🎯 Setup & Configuration

| Script | Purpose | When to Use |
|--------|---------|-------------|
| `master-fix-and-test.sh` | **⭐ RECOMMENDED** - Automatic fix & test | Always start here |
| `ultimate-setup.sh` | Full end-to-end setup | First time setup |
| `fix-schema-cache.py` | Fix REST API schema cache | Column not found errors |
| `adaptive-insert-signal.py` | Smart signal insert | Insert test signals |

### 🧪 Debug & Analysis

| Script | Purpose |
|--------|----------|
| `debug-aisignal.py` | Show all table contents |
| `analyze_signals.py` | Run analysis pipeline |
| `sync-secrets.sh` | Sync .env ↔️ GitHub Secrets |

### Full Script List

See [README-AUTOMATION.md](./README-AUTOMATION.md#-tilgjengelige-scripts) for complete list

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
         │ every 15 min
         ↓
┌────────┴────────────────┐
│  GitHub Actions         │
│  analyze_signals.py     │
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

## 🔑 Configuration

### Approval Thresholds

Edit `scripts/analyze_signals.py`:

```python
if confidence_score >= 75:        # High confidence
    decision = "APPROVED"
elif confidence_score >= 60:      # Medium confidence
    decision = "PENDING"         # Needs manual review
else:                              # Low confidence
    decision = "REJECTED"
```

### Workflow Schedule

Edit `.github/workflows/trading-analysis.yml`:

```yaml
schedule:
  - cron: '*/15 * * * *'  # Every 15 minutes
  # Options:
  # - '*/5 * * * *'      # Every 5 minutes
  # - '0 * * * *'        # Every hour
  # - '0 9-17 * * 1-5'   # 9am-5pm Mon-Fri
```

---

## 🔄 Workflow

### 1. Signal Creation

```sql
-- Example: Create signal in Supabase
INSERT INTO aisignal (
  pair, 
  signal_type, 
  confidence_score, 
  status
) VALUES (
  'BTCUSDT',  -- Trading pair
  'BUY',       -- BUY or SELL
  80,          -- 0-100 confidence
  'PENDING'    -- Initial status
);
```

### 2. Automatic Analysis

GitHub Actions runs every 15 minutes:

```bash
# Fetches PENDING signals
# Analyzes confidence_score
# Updates status to APPROVED/REJECTED
# Logs reasoning
```

### 3. Review Results

```sql
-- Check approved signals
SELECT 
  pair,
  signal_type,
  confidence_score,
  status,
  approved_by,
  approved_at,
  reasoning
FROM aisignal 
WHERE status = 'APPROVED'
ORDER BY approved_at DESC;
```

---

## 📊 Monitoring

### GitHub Actions

- **Live dashboard:** [Actions Tab](https://github.com/tombomann/klarpakke/actions)
- **Watch live:** `gh run watch`
- **View logs:** `gh run view --log`

### Supabase

- **Table Editor:** [Database](https://supabase.com/dashboard/project/swfyuwkptusceiouqlks/editor)
- **SQL Editor:** [SQL](https://supabase.com/dashboard/project/swfyuwkptusceiouqlks/sql/new)

---

## ✅ Success Checklist

Your system is working when:

- [ ] `bash scripts/master-fix-and-test.sh` completes successfully
- [ ] `python3 scripts/analyze_signals.py` processes signals
- [ ] GitHub Actions workflow shows green checkmark
- [ ] Supabase table updates (status changes)
- [ ] Approved signals have `approved_by` and `reasoning` filled

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
- **Frontend:** Webflow (optional)
- **Automation:** Make.com (optional)
- **AI:** Perplexity + Claude (signal generation)

---

## 📂 Project Structure

```
klarpakke/
├── scripts/
│   ├── master-fix-and-test.sh      # ⭐ START HERE
│   ├── ultimate-setup.sh           # Full setup
│   ├── analyze_signals.py          # Core analysis logic
│   ├── fix-schema-cache.py         # Schema fixes
│   ├── adaptive-insert-signal.py   # Smart insert
│   ├── debug-aisignal.py           # Diagnostics
│   └── sync-secrets.sh             # GitHub secrets
├── schema/
│   ├── supabase-core.sql           # Base schema
│   └── migrations/                 # Schema updates
├── .github/workflows/
│   └── trading-analysis.yml        # CI/CD pipeline
├── README.md                       # This file
├── README-AUTOMATION.md            # Full automation guide
├── QUICKSTART.md                   # Quick reference
└── TROUBLESHOOTING.md              # Problem solving
```

---

## 🚀 Next Steps

1. **Run full test:**
   ```bash
   cd ~/klarpakke && git pull && bash scripts/master-fix-and-test.sh
   ```

2. **Watch it work:**
   ```bash
   gh run watch
   ```

3. **Customize thresholds:**
   Edit `scripts/analyze_signals.py`

4. **Add Make.com integration:**
   See [README-AUTOMATION.md](./README-AUTOMATION.md)

---

## 📚 Learn More

- [Full Automation Guide](./README-AUTOMATION.md)
- [Quick Reference](./QUICKSTART.md)
- [Troubleshooting](./TROUBLESHOOTING.md)
- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Supabase Docs](https://supabase.com/docs)

---

**Ready? Let's get started!**

```bash
cd ~/klarpakke && bash scripts/master-fix-and-test.sh
```

🚀 **Klarpakke** - Enkel, risikostyrt, etterprøvbar trading for småsparere
