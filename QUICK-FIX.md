# ⚡ QUICK FIX GUIDE

> **One-command fixes for all common Klarpakke issues**

---

## 🎯 Quick Commands

### 1️⃣ **FIX EVERYTHING** (Recommended)

```bash
cd ~/klarpakke && git pull && bash scripts/auto-fix-everything.sh
```

**Fixes:**
- ✅ Database duplicate columns
- ✅ Schema cache issues
- ✅ Inserts test signal
- ✅ Runs analysis
- ✅ Shows results

---

### 2️⃣ **Test Backtest Scripts**

```bash
cd ~/klarpakke && git pull

# Conservative strategy
python3 scripts/backtest-strategy.py \
  --strategy conservative \
  --min-confidence 0.85 \
  --max-risk 1.0 \
  --start-date 2024-01-01 \
  --end-date 2024-12-31 \
  --output conservative.json

# Moderate strategy
python3 scripts/backtest-strategy.py \
  --strategy moderate \
  --min-confidence 0.75 \
  --max-risk 2.0 \
  --start-date 2024-01-01 \
  --end-date 2024-12-31 \
  --output moderate.json
```

**Fixes:**
- ✅ File path errors
- ✅ Datetime warnings
- ✅ Generates JSON results

---

### 3️⃣ **Test Sentiment Aggregation**

```bash
cd ~/klarpakke && git pull

# BTC sentiment
python3 scripts/aggregate-sentiment.py \
  --symbol BTC \
  --base-confidence 0.75

# ETH sentiment with output file
python3 scripts/aggregate-sentiment.py \
  --symbol ETH \
  --base-confidence 0.80 \
  --output eth-sentiment.json
```

**Fixes:**
- ✅ Datetime warnings
- ✅ Mock data for testing (no API keys needed)
- ✅ Saves JSON output

---

### 4️⃣ **Setup GitHub Secrets**

```bash
cd ~/klarpakke && git pull

# Create .env.migration (if you don't have it)
cat > .env.migration << 'EOF'
SUPABASE_PROJECT_ID="swfyuwkptusceiouqlks"
SUPABASE_SERVICE_ROLE_KEY="your-service-role-key-here"
SUPABASE_DB_URL="postgresql://postgres.swfyuwkptusceiouqlks:PASSWORD@aws-0-eu-central-1.pooler.supabase.com:6543/postgres"
EOF

# Upload to GitHub Secrets
chmod +x scripts/setup-github-secrets.sh
./scripts/setup-github-secrets.sh
```

**Fixes:**
- ✅ No more .env files in repo
- ✅ Secure GitHub Secrets
- ✅ Auto-available in workflows

---

### 5️⃣ **Trigger GitHub Actions Workflows**

```bash
# Install gh CLI (if needed)
brew install gh
gh auth login

# Trigger workflows
gh workflow run multi-strategy-backtest.yml
gh workflow run trading-with-auto-issue.yml  # Has workflow_dispatch now!

# Watch live
gh run watch

# View recent runs
gh run list -L 5
```

**Fixes:**
- ✅ `requirements.txt` now exists
- ✅ Both workflows have `workflow_dispatch` trigger
- ✅ All dependencies installed

---

## 🐛 Common Issues

### Issue: "Duplicate columns in database"

**Solution:**
```bash
cd ~/klarpakke
git pull
source .env.migration
export SUPABASE_DB_URL
bash scripts/auto-fix-everything.sh
```

---

### Issue: "Could not find 'confidence_score' column"

**Solution:**
```bash
# Nuclear fix (recreates table)
cd ~/klarpakke
git pull
source .env.migration
export SUPABASE_DB_URL
chmod +x scripts/nuclear-fix-db.sh
echo "YES" | bash scripts/nuclear-fix-db.sh
```

---

### Issue: "FileNotFoundError: [Errno 2] No such file or directory: ''"

**Fixed!** Latest version handles output files without directory paths.

```bash
# Just pull latest and run
cd ~/klarpakke && git pull

python3 scripts/backtest-strategy.py \
  --strategy conservative \
  --min-confidence 0.85 \
  --max-risk 1.0 \
  --start-date 2024-01-01 \
  --end-date 2024-12-31 \
  --output results.json  # No directory needed!
```

---

### Issue: "DeprecationWarning: datetime.datetime.utcnow()"

**Fixed!** Latest version uses `datetime.now(timezone.utc)`.

```bash
cd ~/klarpakke && git pull
# No more warnings!
```

---

### Issue: "Workflow does not have 'workflow_dispatch' trigger"

**Fixed!** Both workflows now support manual triggers.

```bash
cd ~/klarpakke && git pull
gh workflow run trading-with-auto-issue.yml  # Works now!
gh workflow run multi-strategy-backtest.yml  # Works!
```

---

### Issue: "No file matched to [**/requirements.txt]"

**Fixed!** `requirements.txt` now exists in repo.

```bash
cd ~/klarpakke && git pull
cat requirements.txt  # Exists!
gh workflow run multi-strategy-backtest.yml  # Works now!
```

---

## 🚀 Complete Setup (From Scratch)

```bash
# 1. Clone and setup
cd ~ && git clone https://github.com/tombomann/klarpakke.git
cd klarpakke

# 2. Create .env.migration
cat > .env.migration << 'EOF'
SUPABASE_PROJECT_ID="swfyuwkptusceiouqlks"
SUPABASE_SERVICE_ROLE_KEY="your-service-role-key"
SUPABASE_DB_URL="postgresql://..."
EOF

# 3. Fix database and test everything
source .env.migration
export SUPABASE_DB_URL SUPABASE_PROJECT_ID SUPABASE_SERVICE_ROLE_KEY
bash scripts/auto-fix-everything.sh

# 4. Setup GitHub Secrets
chmod +x scripts/setup-github-secrets.sh
./scripts/setup-github-secrets.sh

# 5. Test workflows
gh workflow run multi-strategy-backtest.yml
gh run watch
```

---

## 📊 Status Check

### Check if everything works:

```bash
cd ~/klarpakke
git pull
source .env.migration
export SUPABASE_DB_URL SUPABASE_PROJECT_ID SUPABASE_SERVICE_ROLE_KEY

# 1. Database schema OK?
python3 scripts/debug-aisignal.py

# 2. Backtest works?
python3 scripts/backtest-strategy.py \
  --strategy conservative \
  --min-confidence 0.85 \
  --max-risk 1.0 \
  --start-date 2024-01-01 \
  --end-date 2024-12-31 \
  --output test.json

# 3. Sentiment works?
python3 scripts/aggregate-sentiment.py --symbol BTC --base-confidence 0.75

# 4. GitHub Secrets uploaded?
gh secret list

# 5. Workflows run?
gh run list -L 3
```

### ✅ All working if:
- `debug-aisignal.py` shows clean schema (no duplicates)
- `backtest-strategy.py` creates `test.json` file
- `aggregate-sentiment.py` shows sentiment results
- `gh secret list` shows 3 secrets
- `gh run list` shows successful runs

---

## 📚 Links

- **[Complete Automation Guide](./docs/AUTOMATION-GUIDE.md)** - Full documentation
- **[Main README](./README.md)** - Project overview
- **[Workflows](https://github.com/tombomann/klarpakke/actions)** - GitHub Actions

---

## 🆘 Help

**Still having issues?**

1. Check [docs/AUTOMATION-GUIDE.md](./docs/AUTOMATION-GUIDE.md)
2. Run `bash scripts/auto-fix-everything.sh`
3. Check GitHub Actions logs: `gh run view --log`
4. Create issue: `gh issue create`

---

**⚡ Updated:** 2026-01-24  
**🚀 Status:** All fixes deployed!
