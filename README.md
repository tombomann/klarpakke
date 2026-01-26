# 🚀 Klarpakke - AI Trading Automation Platform

> **Web-first trading pipeline**: Signal → Risk → Execution → Logging  
> Built with: Webflow + Make.com + Supabase + Perplexity AI

[![Deploy & Test](https://github.com/tombomann/klarpakke/actions/workflows/deploy.yml/badge.svg)](https://github.com/tombomann/klarpakke/actions/workflows/deploy.yml)

---

## ⚡ Quickstart (5 minutes)

### 1. Clone & Setup
```bash
git clone https://github.com/tombomann/klarpakke.git
cd klarpakke
make bootstrap
```

**What this does:**
- ✅ Creates `.env` with your Supabase credentials
- ✅ Deploys database schema (4 tables)
- ✅ Verifies API endpoints
- ✅ Runs smoke tests

### 2. Verify
```bash
make test
```

**Expected output:**
```
✅ Table 'positions' exists
✅ Table 'signals' exists  
✅ Table 'daily_risk_meter' exists
✅ Table 'ai_calls' exists
✅ INSERT works
✅ SELECT works
✅ Risk meter OK
```

### 3. Import Make.com Scenarios
```bash
make make-import
```

Follow instructions to import 4 automation blueprints:
1. **Trading Signal Generator** - Perplexity → Supabase
2. **Position Tracker** - 15min PnL updates
3. **Daily Risk Reset** - 00:00 UTC cleanup
4. **Webflow Sync** - Approved signals → CMS

---

## 🗂️ Project Structure

```
klarpakke/
├── DEPLOY-NOW.sql              # Database schema (copy-paste to Supabase)
├── Makefile                    # Automation commands
├── .env                        # Credentials (git-ignored)
├── scripts/
│   ├── smoke-test.sh          # Full system verification
│   ├── verify-tables.sh       # Check API endpoints
│   ├── export-kpis.sh         # Generate reports
│   └── quick-fix-env.sh       # Setup .env
├── make/scenarios/
│   ├── 01-trading-signal-generator.json
│   ├── 02-position-tracker.json
│   ├── 03-daily-risk-reset.json
│   └── 04-webflow-sync.json
└── .github/workflows/
    └── deploy.yml             # CI/CD pipeline
```

---

## 📊 Database Schema

### Tables

| Table | Purpose | Key Fields |
|-------|---------|------------|
| `positions` | Active trades | `symbol`, `entry_price`, `pnl_usd`, `status` |
| `signals` | AI trade ideas | `symbol`, `direction`, `confidence`, `status` |
| `daily_risk_meter` | Risk tracking | `total_risk_usd`, `max_risk_allowed`, `date` |
| `ai_calls` | API usage logs | `endpoint`, `tokens_in`, `cost_usd` |

### RLS Policies
- **Read**: Public (anon key)
- **Write**: Authenticated (service_role key)

---

## 🛠️ Makefile Commands

### Core
```bash
make help          # Show all commands
make bootstrap     # Complete setup from scratch
make deploy        # Deploy database schema
make test          # Run verify + smoke tests
make kpi           # Export KPIs (30 days)
```

### Development
```bash
make status        # Show system status
make clean         # Remove temp files
make watch         # Auto-test on file changes (requires fswatch)
```

### Make.com
```bash
make make-import   # Import scenario instructions
make make-status   # Check configured scenarios
```

### Database
```bash
make db-backup     # Backup schema
make db-logs       # View Supabase logs (requires CLI)
```

---

## 🔧 Make.com Scenarios

### 1. Trading Signal Generator
**Trigger**: Manual/Scheduled  
**Flow**:
1. Call Perplexity API (sonar-pro)
2. Parse JSON signal
3. Insert to `signals` table
4. Check `daily_risk_meter`
5. Auto-approve if risk < $4000

### 2. Position Tracker
**Trigger**: Every 15 minutes  
**Flow**:
1. Fetch open positions
2. Get current prices (Binance API)
3. Calculate PnL
4. Update `positions` table

### 3. Daily Risk Reset
**Trigger**: Daily 00:00 UTC  
**Flow**:
1. Count open positions
2. Sum total risk
3. Insert new `daily_risk_meter` row
4. Archive old data (>90 days)

### 4. Webflow Sync
**Trigger**: Supabase webhook (approved signals)  
**Flow**:
1. Receive webhook
2. Push to Webflow CMS collection
3. Publish live

---

## 🔐 Environment Setup

### Required Variables

Create `.env` (or run `make bootstrap`):

```bash
# Supabase (from https://supabase.com/dashboard/project/swfyuwkptusceiouqlks/settings/api)
SUPABASE_URL=https://swfyuwkptusceiouqlks.supabase.co
SUPABASE_ANON_KEY=eyJhbGc...
SUPABASE_SECRET_KEY=eyJhbGc...  # service_role key

# Make.com (configure in scenario variables)
WEBFLOW_API_TOKEN=...
WEBFLOW_COLLECTION_ID=...
```

### GitHub Secrets (for CI/CD)

Add to: `https://github.com/tombomann/klarpakke/settings/secrets/actions`

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SUPABASE_SECRET_KEY`

---

## 🧪 Testing

### Manual Tests

1. **Verify tables exist:**
   ```bash
   bash scripts/verify-tables.sh
   ```

2. **Full smoke test:**
   ```bash
   bash scripts/smoke-test.sh
   ```

3. **Test signal insert:**
   ```bash
   curl -X POST "$SUPABASE_URL/rest/v1/signals" \
     -H "apikey: $SUPABASE_SECRET_KEY" \
     -H "Content-Type: application/json" \
     -d '{"symbol":"BTC","direction":"BUY","confidence":0.8}'
   ```

### CI/CD

GitHub Actions runs on:
- Push to `main` (if `DEPLOY-NOW.sql` or `scripts/` changed)
- Pull requests
- Manual trigger

**Pipeline:**
1. Setup environment
2. Verify tables
3. Run smoke tests
4. Notify on failure

---

## 📈 KPI Export

```bash
make kpi        # Last 30 days
make kpi-90     # Last 90 days
```

**Outputs:**
- Win rate
- Average R (reward/risk)
- Max drawdown
- Total signals
- Approved/rejected ratio

---

## 🚨 Troubleshooting

### Tables not found (404)

```bash
# 1. Verify in Supabase SQL Editor
open "https://supabase.com/dashboard/project/swfyuwkptusceiouqlks/editor"

# 2. Run this SQL:
SELECT tablename FROM pg_tables WHERE schemaname = 'public';

# 3. Refresh schema cache:
NOTIFY pgrst, 'reload schema';

# 4. Test again:
make verify
```

### Smoke test fails

```bash
# Check .env:
cat .env

# Verify credentials:
curl -H "apikey: $SUPABASE_ANON_KEY" "$SUPABASE_URL/rest/v1/"

# Re-run setup:
make bootstrap
```

### Make.com scenarios fail

1. Check environment variables in Make.com
2. Verify webhook URLs are correct
3. Test API calls manually:
   ```bash
   curl "$SUPABASE_URL/rest/v1/signals" \
     -H "apikey: $SUPABASE_ANON_KEY"
   ```

---

## 📚 Documentation

- [Supabase API Docs](https://supabase.com/docs/guides/api)
- [Make.com Webhooks](https://www.make.com/en/help/tools/webhooks)
- [Webflow API v2](https://developers.webflow.com/reference/v2)
- [Perplexity API](https://docs.perplexity.ai/)

---

## 🤝 Contributing

1. Fork repo
2. Create feature branch: `git checkout -b feature/my-feature`
3. Commit: `git commit -am 'Add feature'`
4. Push: `git push origin feature/my-feature`
5. Open PR

---

## 📄 License

MIT

---

## 🎯 Next Steps

1. ✅ **Setup complete** - Database deployed
2. 🔄 **Import Make.com scenarios** - `make make-import`
3. 🌐 **Configure Webflow** - Create CMS collection
4. 📊 **Backtest strategy** - Run historical simulations
5. 💰 **Paper trade** - Test with $100 limit
6. 🚀 **Go live** - Monitor daily

---

**Built with ❤️ for småsparere**
