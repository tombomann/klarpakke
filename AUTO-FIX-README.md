# 🤖 Klarpakke Auto-Fix

**Ett-kommando løsning for alle issues.**

## Quick Start

### Metode 1: Direkte fra GitHub (anbefalt)

```bash
cd ~/klarpakke
git pull
chmod +x scripts/auto-fix-complete.sh
./scripts/auto-fix-complete.sh
```

### Metode 2: One-liner

```bash
bash <(curl -s https://raw.githubusercontent.com/tombomann/klarpakke/main/scripts/auto-fix-complete.sh)
```

---

## Hva fikses automatisk?

| Issue | Løsning | Status |
|-------|----------|--------|
| API tilkobling | Tester REST API med service_role key | ✅ Auto |
| DB tilkobling | Verifiserer PostgreSQL connection | ✅ Auto |
| Duplikate kolonner | Kjører emergency-clean-duplicates.py | ✅ Auto |
| Direction constraint | Oppdaterer til å akseptere LONG/long | ✅ Auto |
| Signal insert | Adaptive insert eller direkte API | ✅ Auto |
| Workflows | Trigger multi-strategy-backtest.yml | ✅ Auto |

---

## Forutsetninger

### 1. Environment variables

Lag `.env.local` eller `.env.migration`:

```bash
cat > .env.local << 'EOF'
export SUPABASE_PROJECT_ID="swfyuwkptusceiouqlks"
export SUPABASE_SERVICE_ROLE_KEY="eyJhbG...din-ekte-key"
export SUPABASE_DB_URL="postgresql://postgres.swfyuwkptusceiouqlks:PASSWORD@aws-0-eu-central-1.pooler.supabase.com:6543/postgres"
EOF
```

**Hent verdier fra:**
- [API Settings](https://supabase.com/dashboard/project/swfyuwkptusceiouqlks/settings/api) → service_role key
- [Database Settings](https://supabase.com/dashboard/project/swfyuwkptusceiouqlks/settings/database) → Connection string (Transaction mode)

### 2. Verktøy (valgfritt, men anbefalt)

```bash
# PostgreSQL client (for DB fixes)
brew install postgresql

# GitHub CLI (for workflow trigger)
brew install gh
gh auth login

# jq (for JSON parsing)
brew install jq
```

---

## Detaljert Arbeidsflyt

### STEG 1: API Test
```bash
curl -s \
  -H "apikey: $SUPABASE_SERVICE_ROLE_KEY" \
  -H "Authorization: Bearer $SUPABASE_SERVICE_ROLE_KEY" \
  "https://swfyuwkptusceiouqlks.supabase.co/rest/v1/"
```

**Forventet:** HTTP 200  
**Hvis feil:** Sjekk at service_role key er korrekt

### STEG 2: DB Test
```bash
psql "$SUPABASE_DB_URL" -c "SELECT 1;"
```

**Forventet:** `?column? 1`  
**Hvis feil:** Sjekk password i DB_URL

### STEG 3: Schema Fix
```bash
python3 scripts/emergency-clean-duplicates.py
```

**Resultat:**
- Dropper aisignal table (CASCADE)
- Lager ny med riktig schema
- Fjerner duplikate kolonner
- Refresher PostgREST cache

### STEG 4: Signal Insert
```bash
# Adaptiv insert (prøver flere schemas)
python3 scripts/adaptive-insert-signal.py

# Hvis det feiler → direkte API
curl -X POST \
  -H "apikey: $SUPABASE_SERVICE_ROLE_KEY" \
  -H "Content-Type: application/json" \
  -d '{"symbol":"BTCUSDT","direction":"LONG","entry_price":50000,"confidence":0.85,"status":"pending"}' \
  "https://swfyuwkptusceiouqlks.supabase.co/rest/v1/aisignal"
```

### STEG 5: Workflows
```bash
gh workflow run multi-strategy-backtest.yml
gh run watch
```

---

## Feilsøking

### Problem: "Invalid API key" (HTTP 401)

**Løsning:**
```bash
# Hent ny key fra dashboard
open "https://supabase.com/dashboard/project/swfyuwkptusceiouqlks/settings/api"

# Oppdater GitHub Secrets
gh secret set SUPABASE_SERVICE_ROLE_KEY
# (paste key når prompted)
```

### Problem: "Tenant or user not found"

**Årsak:** Feil DB password  
**Løsning:**
```bash
# Hent connection string fra dashboard
open "https://supabase.com/dashboard/project/swfyuwkptusceiouqlks/settings/database"

# Kopier password fra URI
# postgresql://postgres:[PASSWORD]@...

# Oppdater .env.local
export SUPABASE_DB_URL="postgresql://postgres.swfyuwkptusceiouqlks:NYE_PASSWORD@..."
```

### Problem: "direction_check constraint violation"

**Årsak:** Gamle constraint tillater bare uppercase  
**Løsning:** Kjør auto-fix (oppdaterer automatisk)

### Problem: "duplicate column names"

**Løsning:**
```bash
python3 scripts/emergency-clean-duplicates.py
```

---

## Manual Fallback

Hvis auto-fix feiler:

### 1. Test API manuelt
```bash
export KEY="din-service-role-key"
curl -s -H "apikey: $KEY" -H "Authorization: Bearer $KEY" \
  "https://swfyuwkptusceiouqlks.supabase.co/rest/v1/aisignal?select=count"
```

### 2. Fikse schema via SQL Editor

**Gå til:** [Supabase SQL Editor](https://supabase.com/dashboard/project/swfyuwkptusceiouqlks/sql/new)

**Kjør:**
```sql
DROP TABLE IF EXISTS aisignal CASCADE;

CREATE TABLE aisignal (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  symbol TEXT NOT NULL,
  direction TEXT NOT NULL CHECK (direction IN ('LONG', 'SHORT', 'long', 'short')),
  entry_price NUMERIC,
  stop_loss NUMERIC,
  take_profit NUMERIC,
  confidence NUMERIC,
  status TEXT DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_aisignal_status ON aisignal(status);

NOTIFY pgrst, 'reload schema';
```

### 3. Insert test signal manuelt
```sql
INSERT INTO aisignal (symbol, direction, entry_price, confidence, status)
VALUES ('BTCUSDT', 'LONG', 50000, 0.85, 'pending');
```

---

## Etter Auto-Fix

### Verifiser alt fungerer:

```bash
# Sjekk signals via API
curl -s \
  -H "apikey: $SUPABASE_SERVICE_ROLE_KEY" \
  -H "Authorization: Bearer $SUPABASE_SERVICE_ROLE_KEY" \
  "https://swfyuwkptusceiouqlks.supabase.co/rest/v1/aisignal?select=symbol,direction,status&limit=5" \
  | jq '.'

# Watch workflows
gh run list -L 5

# View latest run
gh run watch
```

### Cleanup (valgfritt)

```bash
# Slett lokal .env (secrets er i GitHub)
rm .env.local

# Legg til .gitignore
echo '.env*' >> .gitignore
git add .gitignore
git commit -m "chore: Ignore env files"
```

---

## Support

**Issues:** [GitHub Issues](https://github.com/tombomann/klarpakke/issues)  
**Logs:** Se `/tmp/insert_log.txt` etter kjøring  
**Workflow Runs:** [Actions](https://github.com/tombomann/klarpakke/actions)

EOF
