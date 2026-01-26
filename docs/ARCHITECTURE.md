# Klarpakke Architecture – Signal→Risk→Execution→Logging

## Overordnet Flow

```
┌──────────────┐
│  Perplexity  │ (Hourly AI signals)
│   Sonar-Pro  │
└──────┬───────┘
       │ Make scenario #2
       ↓
┌──────────────┐
│  Supabase    │
│   signals    │ (pending AI signals)
└──────┬───────┘
       │
       ↓
┌──────────────┐
│   Webflow    │ (User approves/rejects)
│  Dashboard   │
└──────┬───────┘
       │ Form submit
       ↓
┌──────────────┐
│  Supabase    │
│  positions   │ (open position)
└──────┬───────┘
       │
       ↓
┌──────────────┐
│ Risk Meter   │ (auto-update via Make)
│ Webflow CMS  │
└──────────────┘
```

---

## 1. Signal Generation (AI)

### Make Scenario: `02-ai-signals.json`

**Trigger**: Cron (every hour)  
**Flow**:
1. HTTP POST til `https://api.perplexity.ai/chat/completions`
2. Prompt: "Analyser BTC, ETH, SOL – gi BUY/SELL signaler"
3. Parse JSON response: `{"signals": [{"symbol": "BTCUSD", "direction": "BUY", "confidence": 75}]}`
4. For hver signal: INSERT INTO `signals` (status=pending)
5. Log API-kall til `ai_calls` (tokens, cost, latency)

### Supabase Table: `signals`

```sql
CREATE TABLE signals (
  id UUID PRIMARY KEY,
  symbol TEXT NOT NULL,
  direction TEXT, -- BUY/SELL/HOLD
  confidence NUMERIC, -- 0.0-1.0
  ai_model TEXT DEFAULT 'perplexity-sonar',
  status TEXT DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT now()
);
```

---

## 2. Risk Check (Pre-Execution)

### Make Scenario: `04-risk-check.json` (TODO)

**Trigger**: New signal approved by user  
**Logic**:
1. Fetch current `daily_risk_meter` → total_risk_usd
2. Calculate new position size based on:
   - `max_risk_allowed` (default: $5000)
   - `confidence` (høyere = større posisjon)
3. If `total_risk + new_position > max_risk` → REJECT
4. Else → CREATE position

### Supabase Table: `daily_risk_meter`

```sql
CREATE TABLE daily_risk_meter (
  id UUID PRIMARY KEY,
  date DATE DEFAULT CURRENT_DATE,
  total_risk_usd NUMERIC DEFAULT 0,
  max_risk_allowed NUMERIC DEFAULT 5000,
  risk_percent NUMERIC GENERATED ALWAYS AS (
    (total_risk_usd / max_risk_allowed) * 100
  ) STORED
);
```

---

## 3. Execution (Position Tracking)

### Make Scenario: `01-webflow-to-positions.json`

**Trigger**: Webflow form submit (user approves signal)  
**Flow**:
1. Extract: symbol, entry_price, quantity
2. INSERT INTO `positions` (status=open)
3. Update `daily_risk_meter.total_risk_usd`

### Supabase Table: `positions`

```sql
CREATE TABLE positions (
  id UUID PRIMARY KEY,
  user_id TEXT NOT NULL,
  symbol TEXT NOT NULL,
  entry_price NUMERIC,
  quantity NUMERIC,
  pnl_usd NUMERIC,
  status TEXT DEFAULT 'open',
  entry_time TIMESTAMP DEFAULT now()
);
```

---

## 4. Logging & Monitoring

### Make Scenario: `03-risk-dashboard-sync.json`

**Trigger**: Every 5 minutes  
**Flow**:
1. GET `daily_risk_meter` (latest)
2. GET `positions` WHERE status='open' → count
3. UPDATE Webflow CMS → Risk Meter widget

### Supabase Table: `ai_calls`

```sql
CREATE TABLE ai_calls (
  id UUID PRIMARY KEY,
  endpoint TEXT,
  prompt TEXT,
  response TEXT,
  tokens_in INT,
  tokens_out INT,
  cost_usd NUMERIC,
  latency_ms INT,
  created_at TIMESTAMP DEFAULT now()
);
```

---

## Security (RLS)

### Row-Level Security Policies

```sql
-- Public read (dashboard)
CREATE POLICY "Allow public read positions" 
  ON positions FOR SELECT USING (true);

-- Insert only via Make (secret key)
CREATE POLICY "Allow insert positions" 
  ON positions FOR INSERT WITH CHECK (true);
```

**Webflow browser** bruker `SUPABASE_ANON_KEY` (kun read).  
**Make scenarios** bruker `SUPABASE_SECRET_KEY` (read+write).

---

## KPIs & Evaluation

### Daglig Export (`scripts/export-kpis.sh`)

```sql
SELECT 
  COUNT(*) FILTER (WHERE pnl_usd > 0) / COUNT(*) AS winrate,
  AVG(pnl_usd) AS avg_pnl,
  MAX(total_risk_usd) AS max_drawdown
FROM positions
WHERE created_at >= CURRENT_DATE - INTERVAL '30 days';
```

**Output**: `reports/kpis-2026-01-26.json`

---

## Testing

### Smoke Test (`scripts/smoke-test.sh`)

1. Insert test signal → Supabase
2. Verifiser at Make trigger fungerer
3. Sjekk at Webflow dashboard oppdateres

### GitHub CI (`.github/workflows/health-check.yml`)

- Kjører smoke-test hver time
- Alerter hvis Supabase/Make/Perplexity feiler

---

## Neste Moderniseringer

1. **Real-time updates**: Supabase Realtime → Webflow via websocket
2. **Kill-switch**: User kan stoppe alle trades via dashboard
3. **Backtesting**: Historisk signal vs actual PnL tracking
