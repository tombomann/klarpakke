# 🔧 Direction Constraint Fix Guide

> Fixes the `aisignal_direction_check` constraint to accept both uppercase and lowercase values

---

## 🐞 Problem

Current constraint:
```sql
CHECK (direction IN ('LONG', 'SHORT'))  -- Only exact case match
```

**Error when inserting:**
```
new row for relation "aisignal" violates check constraint "aisignal_direction_check"
```

---

## ✅ Solution

New constraint:
```sql
CHECK (UPPER(direction) IN ('LONG', 'SHORT'))  -- Case-insensitive
```

This accepts: `LONG`, `long`, `Long`, `SHORT`, `short`, `Short`

---

## 🚀 Quick Fix (3 Options)

### Option 1: Interactive Script (RECOMMENDED)

```bash
cd ~/klarpakke
git pull
chmod +x scripts/quick-constraint-fix.sh
./scripts/quick-constraint-fix.sh
```

**This will:**
1. Show you a menu with 3 options
2. Option 1: Opens SQL Editor in browser with SQL ready to copy
3. Option 2: Runs Python script to fix automatically
4. Option 3: Just shows the SQL

---

### Option 2: SQL Editor (Manual)

1. **Open SQL Editor:**
   ```bash
   open "https://supabase.com/dashboard/project/swfyuwkptusceiouqlks/sql/new"
   ```

2. **Copy-paste this SQL:**
   ```sql
   ALTER TABLE aisignal DROP CONSTRAINT IF EXISTS aisignal_direction_check;
   ALTER TABLE aisignal ADD CONSTRAINT aisignal_direction_check 
     CHECK (UPPER(direction) IN ('LONG', 'SHORT'));
   NOTIFY pgrst, 'reload schema';
   
   -- Test insert
   INSERT INTO aisignal (symbol, direction, entry_price, stop_loss, take_profit, confidence, status)
   VALUES ('BTCUSDT', 'LONG', 50000, 48000, 52000, 0.85, 'pending')
   ON CONFLICT DO NOTHING
   RETURNING id, symbol, direction, status;
   ```

3. **Click "Run"** or press **Cmd+Enter**

4. **Verify output:**
   ```
   ALTER TABLE
   ALTER TABLE
   NOTIFY
   
   id | symbol   | direction | status
   ---|----------|-----------|--------
   1  | BTCUSDT  | LONG      | pending
   ```

---

### Option 3: Python Script (Requires psycopg2)

```bash
cd ~/klarpakke
git pull

# Install psycopg2 if needed
pip3 install psycopg2-binary

# Run fix script
source .env.local
chmod +x scripts/fix-constraint-python.py
python3 scripts/fix-constraint-python.py
```

**Expected output:**
```
════════════════════════════════════════════════════════════════
🔧 FIXING DIRECTION CONSTRAINT
════════════════════════════════════════════════════════════════

🔌 Connecting to database...
   ✅ Connected

🗑️  Dropping old constraint...
   ✅ Dropped

➕ Adding new case-insensitive constraint...
   ✅ Constraint added: UPPER(direction) IN ('LONG', 'SHORT')

📡 Notifying PostgREST to reload schema...
   ✅ Notified

📊 Inserting test signal...
   ✅ Signal inserted:
      ID: 1
      Symbol: BTCUSDT LONG
      Confidence: 0.85
      Status: pending

📈 Database status:
   Total signals: 1
   Pending: 1
   Approved: 0

════════════════════════════════════════════════════════════════
✅ CONSTRAINT FIX COMPLETE!
════════════════════════════════════════════════════════════════
```

---

## 🧪 Test After Fix

### Test via REST API

```bash
source .env.local

# Test insert with LONG (uppercase)
curl -X POST \
  -H "apikey: $SUPABASE_SERVICE_ROLE_KEY" \
  -H "Authorization: Bearer $SUPABASE_SERVICE_ROLE_KEY" \
  -H "Content-Type: application/json" \
  -H "Prefer: return=representation" \
  -d '{"symbol":"BTCUSDT","direction":"LONG","entry_price":50000,"stop_loss":48000,"take_profit":52000,"confidence":0.85,"status":"pending"}' \
  "https://swfyuwkptusceiouqlks.supabase.co/rest/v1/aisignal" \
  | jq '.'

# Test insert with long (lowercase)
curl -X POST \
  -H "apikey: $SUPABASE_SERVICE_ROLE_KEY" \
  -H "Authorization: Bearer $SUPABASE_SERVICE_ROLE_KEY" \
  -H "Content-Type: application/json" \
  -H "Prefer: return=representation" \
  -d '{"symbol":"ETHUSDT","direction":"long","entry_price":3000,"stop_loss":2900,"take_profit":3100,"confidence":0.80,"status":"pending"}' \
  "https://swfyuwkptusceiouqlks.supabase.co/rest/v1/aisignal" \
  | jq '.'
```

**Both should succeed!**

### Verify Signals

```bash
curl -s \
  -H "apikey: $SUPABASE_SERVICE_ROLE_KEY" \
  -H "Authorization: Bearer $SUPABASE_SERVICE_ROLE_KEY" \
  "https://swfyuwkptusceiouqlks.supabase.co/rest/v1/aisignal?select=symbol,direction,status,confidence&order=created_at.desc&limit=5" \
  | jq '.'
```

**Expected:**
```json
[
  {
    "symbol": "ETHUSDT",
    "direction": "long",
    "status": "pending",
    "confidence": 0.8
  },
  {
    "symbol": "BTCUSDT",
    "direction": "LONG",
    "status": "pending",
    "confidence": 0.85
  }
]
```

---

## 🔗 Files Created

| File | Purpose | Usage |
|------|---------|-------|
| `scripts/fix-direction-constraint.sql` | Raw SQL | Copy-paste to SQL Editor |
| `scripts/fix-constraint-python.py` | Python fix script | Run with `python3` |
| `scripts/quick-constraint-fix.sh` | Interactive menu | Run for guided fix |

---

## ❓ Troubleshooting

### Error: "constraint already exists"

```sql
-- Force drop and recreate
ALTER TABLE aisignal DROP CONSTRAINT aisignal_direction_check CASCADE;
ALTER TABLE aisignal ADD CONSTRAINT aisignal_direction_check 
  CHECK (UPPER(direction) IN ('LONG', 'SHORT'));
```

### Error: "psycopg2 not installed"

```bash
pip3 install psycopg2-binary
```

### Error: "permission denied"

```bash
chmod +x scripts/quick-constraint-fix.sh
chmod +x scripts/fix-constraint-python.py
```

---

## 🚀 After Fixing

```bash
# Run full auto-fix
cd ~/klarpakke
git pull
./scripts/auto-fix-cli.sh

# Watch workflows
gh run watch
```

---

**📚 Related Docs:**
- [Main README](./README.md)
- [Auto-Fix Guide](./AUTO-FIX-README.md)
- [Troubleshooting](./TROUBLESHOOTING.md)
