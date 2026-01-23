# 🔧 Klarpakke Troubleshooting Guide

## 🚀 Quick Fix (Run This First!)

```bash
cd ~/klarpakke && git pull && bash scripts/master-fix-and-test.sh
```

This **automatically**:
- ✅ Fixes schema cache
- ✅ Discovers working schema
- ✅ Inserts test signal
- ✅ Tests analysis
- ✅ Reports status

---

## 🐛 Common Issues

### 1. `Could not find the 'confidence_score' column`

**Problem:** REST API schema cache is outdated

**Automatic Fix:**
```bash
python3 scripts/fix-schema-cache.py
```

**Manual Fix (SQL Editor):**
```sql
-- Refresh PostgREST cache
NOTIFY pgrst, 'reload schema';

-- Wait 2 seconds, then test
INSERT INTO aisignal (pair, signal_type, status)
VALUES ('BTCUSDT', 'BUY', 'PENDING');
```

---

### 2. `No pending signals found`

**Problem:** Table is empty or status format mismatch

**Debug:**
```bash
python3 scripts/debug-aisignal.py
```

**Fix:**
```bash
python3 scripts/adaptive-insert-signal.py
```

---

### 3. Duplicate columns in schema

**Problem:** Multiple migrations created duplicate columns

**Check:**
```sql
SELECT column_name, COUNT(*)
FROM information_schema.columns 
WHERE table_name = 'aisignal'
GROUP BY column_name
HAVING COUNT(*) > 1;
```

**This is usually OK** - PostgreSQL allows it. The REST API uses the first column.

**To clean up (optional):**
```sql
-- Backup first!
CREATE TABLE aisignal_backup AS SELECT * FROM aisignal;

-- Recreate table (advanced - ask for help)
DROP TABLE aisignal;
CREATE TABLE aisignal (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID,
  pair TEXT,
  signal_type TEXT,
  confidence_score INT CHECK (confidence_score BETWEEN 0 AND 100),
  status TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Restore data
INSERT INTO aisignal SELECT DISTINCT ON (id) * FROM aisignal_backup;
```

---

### 4. GitHub Actions workflow fails

**Problem:** Secrets not synced

**Fix:**
```bash
# Re-sync secrets
bash scripts/sync-secrets.sh push

# Verify
gh secret list

# Re-trigger
gh workflow run trading-analysis.yml
```

**Check logs:**
```bash
gh run list --workflow="trading-analysis.yml" -L 5
gh run view --log
```

---

### 5. Local test works, GitHub Actions fails

**Problem:** Environment variable mismatch

**Compare:**
```bash
# Local
cat .env.migration

# GitHub
gh secret list
```

**Fix:**
```bash
bash scripts/sync-secrets.sh push
```

---

### 6. Schema migration seems stuck

**Problem:** Migration ran but cache not updated

**Solution 1 - Restart PostgREST:**
```bash
# Via Supabase Dashboard:
# 1. Go to Project Settings
# 2. Click "Restart project"
# Wait 30 seconds
```

**Solution 2 - Force refresh:**
```sql
NOTIFY pgrst, 'reload schema';
NOTIFY pgrst, 'reload config';
```

**Solution 3 - Use direct DB connection:**
```bash
# Test via psql (bypasses REST API)
export PGPASSWORD="your_password"
psql "$SUPABASE_DB_URL" -c "SELECT * FROM aisignal LIMIT 1;"
```

---

## 📊 Diagnostic Commands

### Check everything
```bash
# Full diagnostic
bash scripts/master-fix-and-test.sh
```

### Check table state
```bash
python3 scripts/debug-aisignal.py
```

### Check schema cache
```bash
python3 scripts/fix-schema-cache.py
```

### Test insert
```bash
python3 scripts/adaptive-insert-signal.py
```

### Test analysis
```bash
python3 scripts/analyze_signals.py
```

---

## 🧠 Understanding The System

### How it works

```
1. Signal created → aisignal table (status='PENDING')
2. GitHub Actions runs every 15 min
3. analyze_signals.py fetches PENDING signals
4. Analyzes confidence_score
5. Updates status to APPROVED/REJECTED
6. Sets approved_by, approved_at, reasoning
```

### Schema flexibility

The system now supports **multiple schema variations**:

**Modern schema:**
- `pair` (BTCUSDT)
- `signal_type` (BUY/SELL)
- `confidence_score` (0-100)
- `status` (PENDING/APPROVED/REJECTED)

**Legacy schema:**
- `symbol` (BTCUSDT)
- `direction` (LONG/SHORT)
- `confidence` (0.0-1.0)
- `status` (pending/approved/rejected)

Scripts automatically detect and adapt!

---

## 🛠️ Advanced Debugging

### Enable verbose logging

```bash
# Add to scripts
import logging
logging.basicConfig(level=logging.DEBUG)
```

### Test REST API directly

```bash
curl -X GET \
  "https://swfyuwkptusceiouqlks.supabase.co/rest/v1/aisignal?limit=1" \
  -H "apikey: $SUPABASE_SERVICE_ROLE_KEY" \
  -H "Authorization: Bearer $SUPABASE_SERVICE_ROLE_KEY"
```

### Test SQL directly

```bash
psql "$SUPABASE_DB_URL" << EOF
SELECT 
  column_name, 
  data_type,
  ordinal_position
FROM information_schema.columns 
WHERE table_name = 'aisignal'
ORDER BY ordinal_position;
EOF
```

### Check PostgREST logs

```bash
# Via Supabase Dashboard:
# Project > Logs > PostgREST logs
# Look for schema reload confirmations
```

---

## 🎯 Decision Tree

```
Problem?
└─ Can't insert signal?
   ├─ Try: python3 scripts/fix-schema-cache.py
   └─ Then: python3 scripts/adaptive-insert-signal.py
└─ No pending signals?
   ├─ Check: python3 scripts/debug-aisignal.py
   └─ Insert: python3 scripts/adaptive-insert-signal.py
└─ Analysis fails?
   ├─ Test: python3 scripts/analyze_signals.py
   └─ Check logs for specific error
└─ GitHub Actions fails?
   ├─ Sync: bash scripts/sync-secrets.sh push
   └─ Verify: gh secret list
└─ Everything broken?
   └─ Run: bash scripts/master-fix-and-test.sh
```

---

## 📞 Get Help

### Before asking for help, run:

```bash
# 1. Full diagnostic
bash scripts/master-fix-and-test.sh > ~/klarpakke-diagnostic.log 2>&1

# 2. Check schema
python3 scripts/debug-aisignal.py >> ~/klarpakke-diagnostic.log 2>&1

# 3. Share the log
cat ~/klarpakke-diagnostic.log
```

### Include in bug report:

1. Full output from `master-fix-and-test.sh`
2. Output from `debug-aisignal.py`
3. Recent GitHub Actions logs
4. Supabase project region
5. What you were trying to do

---

## ✅ Success Indicators

Your system is working when:

1. ✅ `python3 scripts/debug-aisignal.py` shows signals
2. ✅ `python3 scripts/analyze_signals.py` finds and processes signals
3. ✅ GitHub Actions workflow completes successfully (green checkmark)
4. ✅ Supabase table shows `status` updates
5. ✅ `approved_by` or `rejected_by` columns are populated

---

## 📚 Additional Resources

- [README-AUTOMATION.md](./README-AUTOMATION.md) - Full automation guide
- [QUICKSTART.md](./QUICKSTART.md) - Quick reference
- [GitHub Actions](https://github.com/tombomann/klarpakke/actions) - Live workflow status
- [Supabase Dashboard](https://supabase.com/dashboard/project/swfyuwkptusceiouqlks) - Database access

---

**Still stuck? Run the master fix:**

```bash
cd ~/klarpakke && git pull && bash scripts/master-fix-and-test.sh
```
