# 📋 Make.com Import Guide

## Quick Start

### 1. Åpne Make.com
```bash
open "https://www.make.com/en/login"
```

**Eller** hvis du har EU region:
```bash
open "https://eu1.make.com/login"
```

### 2. For hver scenario (import i rekkefølge)

#### A) Scenario 01: Trading Signal Generator
**Fil**: `make/scenarios/01-trading-signal-generator.json`

1. Klikk **"Create a new scenario"** (+ ikon)
2. Klikk **"..."** (three dots øverst til høyre)
3. Velg **"Import Blueprint"**
4. Upload `01-trading-signal-generator.json`
5. Konfigurer modules:
   - **Perplexity API**: Legg til API key
   - **HTTP modules**: Legg til environment variables (se under)

#### B) Scenario 02: Position Tracker
**Fil**: `make/scenarios/02-position-tracker.json`

1. Import samme måte som 01
2. Sett scheduling: **Every 15 minutes**
3. Konfigurer environment variables

#### C) Scenario 03: Daily Risk Reset
**Fil**: `make/scenarios/03-daily-risk-reset.json`

1. Import samme måte
2. Sett scheduling: **Daily at 00:00 UTC**
3. Konfigurer environment variables

#### D) Scenario 04: Webflow Sync
**Fil**: `make/scenarios/04-webflow-sync.json`

1. Import samme måte
2. Setup webhook:
   - Gå til Supabase Dashboard → Database → Webhooks
   - Create new webhook for `signals` table
   - Events: INSERT, UPDATE
   - Condition: `status = 'approved'`
   - URL: [Webhook URL fra Make.com module 1]

---

## 🔧 Environment Variables (påkrevd for alle scenarios)

### I Make.com Scenario Settings:

**For ALLE 4 scenarios:**
```
SUPABASE_URL = https://swfyuwkptusceiouqlks.supabase.co
SUPABASE_ANON_KEY = [din anon key fra .env]
SUPABASE_SECRET_KEY = [din service_role key fra .env]
```

**Kun for Scenario 04 (Webflow):**
```
WEBFLOW_API_TOKEN = [din Webflow API token]
WEBFLOW_COLLECTION_ID = [din collection ID]
```

### Hvor finner du disse?

```bash
cd ~/klarpakke
cat .env
```

---

## ✅ Testing

### Test Scenario 01 (Trading Signal Generator)

1. Åpne scenario i Make.com
2. Klikk **"Run once"** (nederst til venstre)
3. Se at alle modules kjører grønt
4. Verifiser i Supabase:
   ```sql
   SELECT * FROM signals ORDER BY created_at DESC LIMIT 1;
   ```

### Test Scenario 02 (Position Tracker)

1. Først: Opprett en test position i Supabase
   ```sql
   INSERT INTO positions (user_id, symbol, entry_price, quantity, status)
   VALUES ('test', 'BTC', 50000, 0.001, 'open');
   ```
2. Kjør scenario manuelt ("Run once")
3. Sjekk at `current_price`, `pnl_usd`, `pnl_percent` oppdateres

---

## 🚨 Troubleshooting

### "API key not found"
- Sjekk at du har lagt til environment variables i scenario settings
- Klikk på gear icon i scenario → "Data store" eller "Variables"

### "Webhook not receiving data"
- Verifiser webhook URL i Supabase
- Test webhook med curl:
  ```bash
  curl -X POST "[WEBHOOK_URL]" \
    -H "Content-Type: application/json" \
    -d '{"record":{"symbol":"BTC","status":"approved"}}'
  ```

### "Perplexity API error"
- Sjekk at API key er gyldig
- Verifiser quota/limits på Perplexity dashboard

---

## 📊 Monitoring

### I Make.com:
- Gå til scenario → "History" tab
- Se alle runs + errors
- Download logs for debugging

### I Supabase:
```sql
-- Se siste 10 signals
SELECT * FROM signals ORDER BY created_at DESC LIMIT 10;

-- Se dagens risk
SELECT * FROM daily_risk_meter 
WHERE date = CURRENT_DATE;

-- Se åpne posisjoner
SELECT * FROM positions WHERE status = 'open';
```

---

## 🎯 Next Steps

1. ✅ Import scenarios 01-04
2. ✅ Configure environment variables
3. ✅ Test each scenario manually
4. ✅ Enable scheduling for 02 and 03
5. ✅ Setup Supabase webhook for 04
6. 🚀 Monitor for 24 hours
7. 📈 Review performance and adjust
