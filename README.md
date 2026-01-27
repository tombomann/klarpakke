# Klarpakke: AI-Drevet Krypto-Trading for Småsparere

**Project Status:** 🟢 Active Development  
**Role:** Lead DevSecOps Product Engineer (Automation-First)  
**Mission:** Bygge en enkel, risikoredusert og etterprøvbar tradingplattform.

---

## 🚀 ONE-CLICK FULL DEPLOYMENT (NEW!)

**Deploy EVERYTHING in ONE command:**

```bash
# 1. Clone repo
git clone https://github.com/tombomann/klarpakke.git
cd klarpakke

# 2. Setup environment
cp .env.example .env
# Edit .env with your credentials

# 3. Run ONE-CLICK deploy
bash scripts/one-click-full-deploy.sh
```

**That's it!** Script will:
- ✅ Deploy 6 Supabase Edge Functions
- ✅ Apply database migrations
- ✅ Set all secrets
- ✅ Seed demo data (5 signals)
- ✅ Setup GitHub Actions CI/CD
- ✅ Verify deployment

**Total time:** ~3 minutes (including prompts)

### What Gets Deployed

| Component | Platform | Status |
|-----------|----------|--------|
| **Backend API** | Supabase Edge Functions | ✅ Auto-deployed |
| **Database** | PostgreSQL (Supabase) | ✅ Auto-migrated |
| **Frontend** | Webflow Cloud | ⚠️ Manual paste (30 sec) |
| **Automation** | Make.com | ⚠️ Manual import (blueprints/) |
| **CI/CD** | GitHub Actions | ✅ Auto-configured |

### Manual Steps (Optional)

**Webflow deployment** (only needed once):
1. Copy `web/klarpakke-site.js` to clipboard
2. Open [Webflow Custom Code](https://webflow.com/design/klarpakke-c65071)
3. Paste in Footer Code (`<script>...</script>`)
4. Click Publish

**Make.com blueprints** (only needed for scheduled AI calls):
1. Import `blueprints/signal-ingestion.json` to Make.com
2. Configure schedule (every 4 hours)
3. Activate scenario

📖 **[Full Documentation →](docs/ONE-CLICK-DEPLOY.md)**

---

## 🎯 Quick Start (For Development)

### Option 1: Makefile (Recommended)

```bash
# Bootstrap: Validate tools + env
make bootstrap

# Deploy backend only
make edge-full

# Deploy + seed demo data
make deploy-all

# Test live APIs
make edge-test-live
```

### Option 2: Manual Scripts

```bash
# Validate environment
bash scripts/validate-env.sh

# Deploy Edge Functions
supabase functions deploy --no-verify-jwt

# Set secrets
bash scripts/fix-secrets.sh

# Seed demo data
bash scripts/paper-seed.sh
```

---

## 📚 Documentation

- **[One-Click Deploy Guide](docs/ONE-CLICK-DEPLOY.md)** 👈 **START HERE!**
- **[Design System](docs/DESIGN.md)** (Farger, typografi, trafikklys, sider, pricing)
- **[Copy (Microcopy)](docs/COPY.md)** (Alle tekster til Webflow)
- **[AI Model Playbook](docs/ai/MODEL-PLAYBOOK.md)** (Hvilken AI-modell til hva?)
- **[Webflow Manual Guide](docs/WEBFLOW-MANUAL.md)** (Lær hvordan du unngår kode-som-tekst feil)
- [AI Architecture & Context](docs/ai/CONTEXT.md)
- [Bubble Integration Guide](docs/ai/BUBBLE-CHECKLIST.md)

---

## 💰 Pricing Plans

| Plan | Price | Risk Level | Description |
|------|-------|------------|-------------|
| **Gratis (Paper)** | $0 | 🟢 Grønn | Lær uten risiko. Paper trading. |
| **SAFE** | $49 | 🟢 Grønn | Rolig tempo. 1% risk per trade. |
| **PRO** | $99 | 🟡 Gul | Mer strategi. 2% risk per trade. |
| **EXTREM** | $199 | ⚫ Sort | Høy frekvens. 5% risk per trade. Krever quiz. |

**Alle planer har compounding ON som default.**

Se [docs/DESIGN.md](docs/DESIGN.md) for detaljer.

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────┐
│          WEBFLOW CLOUD (Frontend)               │
├─────────────────────────────────────────────────┤
│ • Landing, Pricing, Dashboard, Calculator       │
│ • Custom Code (klarpakke-site.js)              │
│ • Password Protection (tom123)                  │
└──────────────┬──────────────────────────────────┘
               │ fetch() API calls
               ▼
┌─────────────────────────────────────────────────┐
│      SUPABASE (Backend + Database)              │
├─────────────────────────────────────────────────┤
│ • PostgreSQL (signals, positions, risk_meter)   │
│ • Edge Functions (6 deployed):                  │
│   - generate-trading-signal                     │
│   - approve-signal                              │
│   - analyze-signal                              │
│   - update-positions                            │
│   - serve-js                                    │
│   - debug-env                                   │
│ • RLS (Row Level Security)                      │
│ • Real-time subscriptions                       │
└──────────────┬──────────────────────────────────┘
               │ Webhooks
               ▼
┌─────────────────────────────────────────────────┐
│         MAKE.COM (Automation)                   │
├─────────────────────────────────────────────────┤
│ • Signal ingestion (scheduled every 4h)         │
│ • AI calls (Perplexity Sonar Pro)             │
│ • CMS sync (Supabase → Webflow)               │
│ • Email notifications (SendGrid)                │
└─────────────────────────────────────────────────┘
```

---

## 🛠 Makefile Commands

| Command | Description |
|---------|-------------|
| `make deploy-all` | 🚀 **One-click deploy** (backend + frontend + seed) |
| `make bootstrap` | Validate tools + environment |
| `make edge-full` | Deploy all Edge Functions |
| `make edge-test-live` | Test Edge Functions against live Supabase |
| `make paper-seed` | Generate demo signals for paper trading |
| `make webflow-export` | Export signals to CSV for Webflow CMS |
| `make help` | Show all available commands |

---

## 🔄 GitHub Actions (CI/CD)

**Auto-deployment on every push to `main`:**

```yaml
Workflow: .github/workflows/deploy.yml

Jobs:
  1. test        # Validate scripts + syntax
  2. deploy-backend  # Deploy Edge Functions + migrations
  3. verify      # Test APIs + check data
  4. notify      # Deployment summary
```

**Required GitHub Secrets:**
- `SUPABASE_ACCESS_TOKEN`
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SUPABASE_SERVICE_ROLE_KEY`
- `PPLX_API_KEY`

**Setup:** 
```bash
gh secret set SUPABASE_ACCESS_TOKEN < .env
gh secret set SUPABASE_URL < .env
# ... etc
```

---

## 🧾 Recent Updates

### 2026-01-27 — Full One-Click Automation v3.0 🚀

**HVA gjort**
- ✅ `scripts/one-click-full-deploy.sh` - komplett automasjon
- ✅ GitHub Actions workflow (CI/CD pipeline)
- ✅ Oppdatert `web/klarpakke-site.js` med loadSignals()
- ✅ Dokumentert alt i README + ONE-CLICK-DEPLOY.md

**HVORFOR**
- Eliminere manuell "copy-paste" workflow
- Gjøre deploy til ONE command
- Auto-deploy på hver git push

**TEST**
```bash
# Full deploy
bash scripts/one-click-full-deploy.sh

# Verify
curl $SUPABASE_URL/functions/v1/debug-env
open https://klarpakke-c65071.webflow.io/app/dashboard
```

### 2026-01-27 — Webflow deploy v2.0

**HVA gjort**
- Kjørt `scripts/webflow-one-click.sh` og injisert site-wide JS
- Verifisert at `/app/dashboard` har `#signals-container`
- Opprettet Webflow-sider for `/app/settings` og `/app/pricing`

**HVORFOR**
- Låse "web-first pipeline" i frontend
- Sørge for at JS aldri rendres som tekst

**TEST**
- Besøk dashboard (hard refresh / incognito)
- Sjekk at console logger: `[Klarpakke] Site engine v2.1 loaded`
- Verifiser at signals vises i grid

---

## 🔐 Security & Best Practices

1. **README First:** All architectural changes documented here
2. **Secrets:** Never commit API keys (use `.env` + GitHub Secrets)
3. **Approvals:** Manual approval required for all trading signals
4. **RLS:** Row Level Security enabled on all Supabase tables
5. **No-code first:** Prefer visual tools (Webflow, Make) over custom code

---

## 🎨 Design Principles

**Tone:** Positiv + pedagogisk
- Dashboard/kalkulator: vis vekst, muligheter, compound-effekt
- Opplæring/quiz: én ærlig seksjon om risiko, deretter fokus på strategi
- Advarsler: kun i opplæring og quiz (ikke repeterende)

**Trafikklys:**
- 🟢 Grønn: "Alt ok"
- 🟡 Gul: "Vær obs"
- 🔴 Rød: "Pause til i morgen"
- ⚫ Sort (EXTREM): "Pause. Trykk 'Start på nytt' i morgen"

Se [docs/DESIGN.md](docs/DESIGN.md) for full guide.

---

## 📈 Tech Stack

- **Backend:** Supabase (Edge Functions, PostgreSQL, Realtime)
- **Frontend:** Webflow (UI/UX) + Custom JavaScript
- **Automation:** Make.com (scenarios, webhooks)
- **AI:** Perplexity Sonar Pro
- **Trading:** TradingView (signals) → Binance (execution)
- **Price Data:** CoinGecko API
- **CI/CD:** GitHub Actions
- **Version Control:** GitHub

---

## 🆘 Troubleshooting

### Edge Functions not responding
```bash
# Check deployment status
supabase functions list

# Check logs
supabase functions logs generate-trading-signal

# Redeploy
supabase functions deploy generate-trading-signal --no-verify-jwt
```

### Webflow shows blank dashboard
```bash
# Verify signals in database
curl "$SUPABASE_URL/rest/v1/signals?status=eq.pending" \
  -H "apikey: $SUPABASE_ANON_KEY"

# Check browser console
# Should see: [Klarpakke] Site engine v2.1 loaded
```

### Make.com scenarios not running
1. Check scenario is "ON" (not paused)
2. Verify connections are authorized
3. Check execution history for errors
4. Re-import blueprint if needed

---

## 🤝 Contributing

This is a solo project, but contributions welcome!

1. Fork repo
2. Create feature branch
3. Follow existing code style
4. Test with `make bootstrap && make edge-test-live`
5. Submit PR with clear description

---

## 📄 License

Private repository. All rights reserved.

---

*Built with ❤️ by tombomann | Powered by Perplexity AI, Supabase, Webflow*
