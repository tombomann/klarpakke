# 🤖 Klarpakke Trading Analysis - FULL AUTOMATION

## 🚀 ONE-COMMAND SETUP (ULTIMATE)

```bash
cd ~/klarpakke && git pull && bash scripts/ultimate-setup.sh
```

Dette kjører **HELE** setupet automatisk:
1. ✅ Migrerer database (legger til alle kolonner)
2. ✅ Synker secrets til GitHub
3. ✅ Setter inn test-signal
4. ✅ Tester analyse lokalt
5. ✅ Trigger GitHub Actions workflow
6. ✅ Åpner monitoring dashboards

---

## 📋 Tilgjengelige Scripts

### 🎯 Setup & Configuration

| Script | Beskrivelse | Automatisk? |
|--------|-------------|-------------|
| `ultimate-setup.sh` | **ANBEFALT** - Kjør ALT automatisk | ✅ 100% |
| `ultimate-fix.sh` | Hent API keys + setup (browser interaction) | ⚡ 95% |
| `complete-setup.sh` | End-to-end via Supabase CLI | ⚡ 90% |
| `auto-fix-keys.sh` | Hent keys via Supabase CLI | ⚡ 80% |

### 🗄️ Database Migration

| Script | Beskrivelse | Krever |
|--------|-------------|--------|
| `auto-migrate-database.py` | Python migration via psycopg2/psql | `SUPABASE_DB_URL` |
| `auto-migrate-database.sh` | Bash migration via Supabase CLI | Supabase CLI |
| `schema/migrations/001_add_trading_fields.sql` | Manuell SQL migration | SQL Editor |

### 🧪 Testing & Debug

| Script | Beskrivelse |
|--------|-------------|
| `debug-aisignal.py` | Vis ALT i aisignal tabell |
| `insert-test-signal.py` | Legg til test-signal |
| `analyze_signals.py` | Kjør trading analysis |
| `test-analysis-local.sh` | Full lokal test |
| `debug-keys.sh` | Debug API keys |

### 🔄 Sync & Deploy

| Script | Beskrivelse |
|--------|-------------|
| `sync-secrets.sh` | Sync .env ↔️ GitHub Secrets |
| `push_files` | Push flere filer i én commit |

---

## 🎯 Bruksscenarier

### Scenario 1: Første gang setup

```bash
cd ~/klarpakke

# Pull siste kode
git pull

# Kjør ultimate setup (gjør ALT)
bash scripts/ultimate-setup.sh

# Ferdig! System kjører nå automatisk.
```

### Scenario 2: Fikse database schema

```bash
# Installer psycopg2 (optional, for raskere kjøring)
pip3 install psycopg2-binary

# Kjør automated migration
source .env.migration
export SUPABASE_DB_URL
python3 scripts/auto-migrate-database.py
```

### Scenario 3: Test lokalt

```bash
# 1. Debug hva som finnes
python3 scripts/debug-aisignal.py

# 2. Legg til test-signal
python3 scripts/insert-test-signal.py

# 3. Kjør analyse
python3 scripts/analyze_signals.py
```

### Scenario 4: Sync secrets til GitHub

```bash
# Push local .env til GitHub Secrets
bash scripts/sync-secrets.sh push

# Pull GitHub Secrets til local .env
bash scripts/sync-secrets.sh pull
```

### Scenario 5: Re-trigger alt

```bash
# Hvis noe feiler, kjør ultimate-setup på nytt
bash scripts/ultimate-setup.sh
```

---

## 🔧 Troubleshooting

### Problem: `confidence_score column not found`

**Løsning:**
```bash
# Run database migration
python3 scripts/auto-migrate-database.py
```

### Problem: `No pending signals`

**Debug:**
```bash
python3 scripts/debug-aisignal.py
```

**Fix:**
```bash
python3 scripts/insert-test-signal.py
```

### Problem: Workflow feiler i GitHub Actions

**Fix:**
```bash
# Re-sync secrets
bash scripts/sync-secrets.sh push

# Verify
gh secret list

# Re-trigger
gh workflow run trading-analysis.yml
```

---

## 📊 Monitoring

### GitHub Actions

```bash
# Watch live
gh run watch

# List recent runs
gh run list --workflow="trading-analysis.yml" -L 10

# View logs
gh run view --log

# Open in browser
open https://github.com/tombomann/klarpakke/actions
```

### Supabase

```bash
# Open table editor
open https://supabase.com/dashboard/project/swfyuwkptusceiouqlks/editor

# Open SQL editor
open https://supabase.com/dashboard/project/swfyuwkptusceiouqlks/sql/new
```

### Local Testing

```bash
# Quick test
source .env.migration && \
export SUPABASE_PROJECT_ID SUPABASE_SERVICE_ROLE_KEY && \
python3 scripts/analyze_signals.py
```

---

## ⚙️ Configuration

### Approval Thresholds

Edit `scripts/analyze_signals.py`:

```python
# Current settings:
if confidence_score >= 75:
    decision = "APPROVED"
elif confidence_score >= 60:
    decision = "PENDING"
else:
    decision = "REJECTED"
```

### Workflow Frequency

Edit `.github/workflows/trading-analysis.yml`:

```yaml
schedule:
  - cron: '*/15 * * * *'  # Every 15 minutes
```

---

## 🗄️ Database Schema

### `aisignal` table columns:

```sql
-- Core fields (from original schema)
id UUID PRIMARY KEY
user_id UUID
pair TEXT  -- e.g., 'BTCUSDT'
signal_type TEXT  -- 'BUY', 'SELL', 'HOLD'
status TEXT  -- 'PENDING', 'APPROVED', 'REJECTED'
risk_usd NUMERIC
created_at TIMESTAMPTZ

-- Trading analysis fields (added by migration)
confidence_score INT  -- 0-100
entry_price NUMERIC(18,8)
stop_loss NUMERIC(18,8)
take_profit NUMERIC(18,8)

-- Approval tracking (added by migration)
approved_by TEXT  -- e.g., 'github_actions'
approved_at TIMESTAMPTZ
rejected_by TEXT
rejected_at TIMESTAMPTZ
reasoning TEXT
```

### To migrate manually:

```sql
ALTER TABLE aisignal 
ADD COLUMN IF NOT EXISTS confidence_score INT CHECK (confidence_score BETWEEN 0 AND 100),
ADD COLUMN IF NOT EXISTS entry_price NUMERIC(18,8),
ADD COLUMN IF NOT EXISTS stop_loss NUMERIC(18,8),
ADD COLUMN IF NOT EXISTS take_profit NUMERIC(18,8),
ADD COLUMN IF NOT EXISTS approved_by TEXT,
ADD COLUMN IF NOT EXISTS approved_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS rejected_by TEXT,
ADD COLUMN IF NOT EXISTS rejected_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS reasoning TEXT;
```

---

## 🎊 Success Indicators

✅ `ultimate-setup.sh` completes without errors  
✅ Local `analyze_signals.py` finds and processes signals  
✅ GitHub Actions workflow runs and turns green  
✅ Supabase `aisignal` table updates (status changes)  
✅ `approved_by` or `rejected_by` columns populated  

---

## 🚀 Production Checklist

- [ ] Database migrated (run `auto-migrate-database.py`)
- [ ] Secrets synced to GitHub (run `sync-secrets.sh push`)
- [ ] Local test passes (run `analyze_signals.py`)
- [ ] GitHub Actions workflow green (check Actions tab)
- [ ] Test signal approved/rejected (check Supabase)
- [ ] Monitoring dashboards accessible
- [ ] Approval thresholds tuned to strategy
- [ ] Workflow schedule set (default: every 15 min)

---

## 📚 Additional Resources

- [QUICKSTART.md](./QUICKSTART.md) - Quick reference guide
- [schema/supabase-core.sql](./schema/supabase-core.sql) - Original schema
- [schema/migrations/](./schema/migrations/) - Database migrations
- [.github/workflows/](../.github/workflows/) - CI/CD workflows

---

**Ready to automate?**

```bash
cd ~/klarpakke && bash scripts/ultimate-setup.sh
```

🎉 Full automation in one command!
