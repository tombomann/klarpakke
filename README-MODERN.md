# Klarpakke – Cloud-Native Trading Platform for Småsparere

**Status**: ✅ Modernisert til 100% cloud stack (Webflow + Supabase + Make)

---

## Arkitektur (Web-Only)

```
Småsparer (browser)
    ↓
Webflow (UI + Forms)
    ↓
Make.com (automation)
    ↓
Supabase (database + RLS)
    ↓
Perplexity AI (signals)
```

**Ingen lokal utvikling** – alt kjøres i nettleser:
- Webflow Designer
- Supabase Studio  
- Make.com scenarios

---

## Database Schema (Supabase)

### `positions` – Åpne og lukkede handler
- `id`, `user_id`, `symbol`, `entry_price`, `quantity`
- `current_price`, `pnl_percent`, `pnl_usd`
- `status` (open/closed), `entry_time`, `exit_time`

### `signals` – AI-genererte trading signaler
- `id`, `symbol`, `direction` (BUY/SELL/HOLD)
- `confidence` (0.0-1.0), `reason`, `ai_model`
- `status` (pending/approved/rejected/executed)

### `daily_risk_meter` – Daglig risiko tracking
- `date`, `total_risk_usd`, `max_risk_allowed`
- `risk_percent` (auto-calculated), `active_positions_count`

### `ai_calls` – Logging av alle AI API-kall
- `endpoint`, `model`, `prompt`, `response`
- `tokens_in`, `tokens_out`, `cost_usd`, `latency_ms`

---

## Make.com Scenarios

### 1. Webflow Form → Supabase Positions
**Trigger**: User submits new position via form  
**Action**: Insert into `positions` table

### 2. Perplexity AI → Supabase Signals (Hourly)
**Trigger**: Every hour (cron)  
**Action**:  
1. Call Perplexity Sonar API  
2. Parse JSON signals  
3. Insert into `signals` table  
4. Log call to `ai_calls`

### 3. Supabase → Webflow Dashboard (Every 5 min)
**Trigger**: Every 5 minutes  
**Action**:  
1. Fetch latest risk from `daily_risk_meter`  
2. Update Webflow CMS collection  
3. Dashboard shows live data

---

## Deployment (1-Click)

```bash
# Deploy Supabase migrations
bash scripts/deploy-migrations.sh

# Test hele pipelinen
bash scripts/smoke-test.sh

# Export KPIs (daily)
bash scripts/export-kpis.sh
```

---

## Neste Steg

1. **Webflow** (1-2 timer):  
   - Opprett Collections: Positions, Signals, RiskMeter  
   - Lag Dashboard side med live widgets  

2. **Make** (1-2 timer):  
   - Import 3 blueprints fra `make/scenarios/`  
   - Test hver scenario manuelt  

3. **GitHub CI** (30 min):  
   - Verifiser at `.github/workflows/health-check.yml` kjører  

---

## Secrets (GitHub + Make)

```bash
# GitHub Secrets (repo settings)
PPLX_API_KEY=pplx-...
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=eyJ...
SUPABASE_SECRET_KEY=eyJ...
WEBFLOW_API_KEY=...
```

---

## Risiko & Mitigering

| Risiko | Løsning |
|--------|----------|
| Make rate-limit (Perplexity 60 req/min) | Exponential backoff i scenario |
| Supabase anon key i browser | RLS policies + query filters |
| Signal accuracy ikke validert | Track i `evaluation_framework.md` |
| Risiko-calc ikke real-time | Cron hver 1 min for risk update |

---

## Support

- **Arkitektur**: `docs/ARCHITECTURE.md`  
- **Supabase Schema**: `supabase/migrations/001_init.sql`  
- **Make Blueprints**: `make/scenarios/*.json`  

**MVP-mål**: Småsparere kan se live risk-meter og AI-signaler på klarpakke.no innen 3 dager.
