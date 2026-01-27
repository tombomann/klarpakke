# 🚀 Klarpakke Quickstart

**Deploy entire stack in 10 minutes**

---

## 🎯 One-Command Deployment

```bash
cd ~/klarpakke && \
git pull origin main && \
chmod +x scripts/complete-deployment.sh && \
bash scripts/complete-deployment.sh
```

**What happens:**
1. Fixes Webflow field mapping (`reasoning` → `reason`)
2. Generates 3-5 demo signals in Supabase
3. Tests single signal sync to Webflow
4. Syncs all signals to Webflow CMS
5. Deploys Webflow UI (interactive guide)
6. Verifies deployment

**Time:** ~10 minutes (5 min automated + 5 min Webflow UI paste)

---

## 📊 What Gets Deployed

### Backend (Supabase)
- ✅ PostgreSQL database (4 tables)
- ✅ Edge Functions (6 functions)
- ✅ REST API endpoints
- ✅ RLS security policies

### Automation (GitHub Actions)
- ✅ Webflow sync (every 5 minutes)
- ✅ Deploy & test (on push to main)

### Frontend (Webflow)
- ✅ CMS Collection (signals)
- ✅ UI JavaScript (2.5 KB)
- ✅ Password protection
- ✅ Approve/reject buttons

---

## 🛠️ Prerequisites

### 1. Supabase Project
- ✅ Project created: `swfyuwkptusceiouqlks`
- ✅ API keys in `.env`
- ✅ Tables deployed (via DEPLOY-NOW.sql)

### 2. Webflow Site
- ✅ Site created: `klarpakke-c65071.webflow.io`
- ✅ CMS Collection created: "Signals"
- ✅ API token generated

### 3. GitHub Repository
- ✅ Repo cloned locally
- ✅ Secrets configured (via one-click-install.sh)

**Already done?** Run quickstart above! ⬆️

**Starting fresh?** Run this first:
```bash
cd ~/klarpakke
bash scripts/one-click-install.sh
```

---

## 💡 How It Works

### Signal Flow
```
1. Generate Signal (Supabase Edge Function)
   ↓
2. Store in Database (signals table)
   ↓
3. Sync to Webflow CMS (GitHub Actions every 5 min)
   ↓
4. Display in UI (Webflow Custom Code)
   ↓
5. User Approves/Rejects (JavaScript → Edge Function)
   ↓
6. Update Status (Supabase + Webflow)
```

### Field Mapping
```
Supabase Table       →  Webflow CMS
-------------------     -------------------
symbol (text)        →  symbol (PlainText)
direction (text)     →  direction (PlainText)
confidence (numeric) →  confidence (Number)
reasoning (text)     →  reason (PlainText)
status (text)        →  status (PlainText)
+ auto-generated     →  name (PlainText)
+ auto-generated     →  slug (PlainText)
```

**Key Fix:** `reasoning` → `reason` (field name mismatch)

---

## 🧪 Testing

### After Deployment

#### 1. Test Webflow CMS Sync
```bash
# Generate demo signals
make paper-seed

# Wait 5 minutes for auto-sync
# OR run manual sync:
bash scripts/webflow-sync.sh

# Check Webflow CMS:
open https://webflow.com/dashboard/sites/69743573d50cc16bbbe54344/collections/6978258967f5139c7426902d
```

#### 2. Test Webflow UI
```bash
# Open dashboard
open https://klarpakke-c65071.webflow.io/app/dashboard

# Enter password: tom

# Open Console (F12)
# Look for: [Klarpakke] UI script loaded

# Click 'Approve' button
# Expected: [Klarpakke] Success: {signal_id: "...", status: "approved"}
```

#### 3. Test Edge Functions
```bash
# Test generate-trading-signal
supabase functions invoke generate-trading-signal \
  --data '{"symbol":"BTC","timeframe":"1h"}'

# Expected:
# {"signal_id": "...", "symbol": "BTC", "direction": "BUY", ...}

# Check logs
make edge-logs
```

---

## 🔧 Troubleshooting

### Webflow Sync Fails (HTTP 400)
**Symptom:** `❌ BTC BUY (HTTP 400)`

**Fix:**
```bash
# 1. Debug collection schema
bash scripts/debug-webflow-collection.sh

# 2. Check field mapping matches
# 3. Verify API token has 'cms:write' scope
# 4. Re-run complete deployment
bash scripts/complete-deployment.sh
```

### Webflow Sync Fails (HTTP 404)
**Symptom:** `❌ BTC BUY (HTTP 404)`

**Cause:** Wrong Collection ID

**Fix:**
```bash
# Get correct Collection ID
bash scripts/get-webflow-collection-id.sh

# Verify .env updated
cat .env | grep WEBFLOW_COLLECTION_ID

# Re-run sync
bash scripts/webflow-sync.sh
```

### Webflow UI Not Loading
**Symptom:** Console shows no `[Klarpakke]` messages

**Fix:**
1. Verify Custom Code saved: Project Settings → Custom Code
2. Hard refresh: Cmd+Shift+R
3. Check JavaScript syntax errors in Console
4. Re-paste JavaScript:
   ```bash
   bash scripts/webflow-one-click.sh
   ```

### Dashboard 404
**Symptom:** `/app/dashboard` returns 404

**Fix:**
1. Check page exists in Webflow: Pages panel → /app/dashboard
2. Verify page is published
3. Check password protection enabled
4. Re-publish site from Webflow Designer

---

## 📈 Monitoring

### Live Dashboards
- **Supabase**: https://supabase.com/dashboard/project/swfyuwkptusceiouqlks
- **Webflow CMS**: https://webflow.com/dashboard/sites/69743573d50cc16bbbe54344/collections/6978258967f5139c7426902d
- **GitHub Actions**: https://github.com/tombomann/klarpakke/actions
- **Live Site**: https://klarpakke-c65071.webflow.io/app/dashboard

### Key Metrics
```bash
# Supabase stats
make test

# Export KPIs (last 30 days)
bash scripts/export-kpis.sh 30

# Edge Function logs
make edge-logs

# Count synced signals
curl -s "${SUPABASE_URL}/rest/v1/signals?select=count" \
  -H "apikey: ${SUPABASE_ANON_KEY}" | jq .
```

---

## 📚 Next Steps

### Production Readiness
1. **Custom Domain**: Connect `klarpakke.no` in Webflow
2. **User Auth**: Replace password with Supabase Auth
3. **Real Trading**: Connect to broker API (Alpaca, Interactive Brokers)
4. **Monitoring**: Add Sentry for error tracking
5. **Alerts**: Setup Slack notifications via Make.com

### Paper Trading (7 days)
```bash
# Run paper trading validation
make paper-trading

# Target metrics:
# - Win rate: >65%
# - Reward/Risk: >1.5
# - Max drawdown: <10%
```

### Scale Up
1. Increase signal generation frequency (hourly → every 15 min)
2. Add more symbols (BTC, ETH, SPY, QQQ, etc.)
3. Implement portfolio management (position sizing, risk limits)
4. Add backtesting (test strategies on historical data)

---

## 🔗 Resources

- **Main README**: [README.md](./README.md)
- **Architecture**: [docs/ARCHITECTURE.md](./docs/ARCHITECTURE.md)
- **Webflow Deployment**: [docs/WEBFLOW-DEPLOYMENT.md](./docs/WEBFLOW-DEPLOYMENT.md)
- **Deployment Status**: [DEPLOYMENT-STATUS.md](./DEPLOYMENT-STATUS.md)

---

## ❓ FAQ

### Q: How long does deployment take?
A: ~10 minutes total (5 min automated + 5 min Webflow UI)

### Q: Do I need to manually sync signals?
A: No, GitHub Actions syncs every 5 minutes automatically.

### Q: Can I change the password?
A: Yes, in Webflow: Pages → /app/dashboard → Settings → Password Protection

### Q: How do I add more signals?
A: Run `make paper-seed` or call Edge Function `generate-trading-signal`

### Q: Is this production-ready?
A: No, it's a demo/MVP. Add auth, monitoring, and real broker integration for production.

---

**Last Updated**: 27. januar 2026  
**Version**: 1.0

🎉 **Ready to deploy? Run the one-command quickstart at the top!**
