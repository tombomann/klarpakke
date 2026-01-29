# Klarpakke: AI-Drevet Krypto-Trading for Småsparere

**Project Status:** 🟢 Production Ready  
**Role:** Lead DevSecOps Product Engineer (Automation-First)  
**Mission:** Bygge en enkel, risikoredusert og etterprøvbar tradingplattform.

---

## 🎉 NEW: FULL AUTOMATION STACK

**Status:** ✅ Production-ready med automatisk CMS sync, health checks, og database maintenance

### Quick Commands

```bash
# 🔐 Secret Management
npm run secrets:validate        # Validate all secrets (local + remote)
npm run secrets:push-supabase   # Sync secrets to Supabase
npm run secrets:push-github     # Sync secrets to GitHub
npm run secrets:pull-supabase   # Pull secrets from Supabase

# 🔄 CMS Automation
npm run webflow:sync            # Manual Supabase → Webflow CMS sync

# 🧻 Database Management
npm run db:cleanup              # Remove invalid signals

# 🏥 Health Checks
npm run health:check            # Check Supabase + Webflow APIs
npm run health:full             # Full system health check
```

### GitHub Actions Workflows

**✅ Active Workflows:**
- **Daily CMS Sync** (06:00 UTC daily + manual trigger)
  - Syncs signals from Supabase to Webflow CMS
  - Skips duplicates automatically
  - Runs in production with GitHub Secrets

- **Database Health Check** (Every 6 hours)
  - Validates database connectivity
  - Checks data integrity
  - Reports failures immediately

- **Secrets Audit** (Weekly on Mondays)
  - Validates all required secrets
  - Tests API connections
  - Reports missing configurations

**🕹️ Manual Triggers:**
All workflows can be triggered manually from GitHub Actions tab.

---

## 🚀 ONE-CLICK (Supabase-first)

Backend er Supabase CLI‑drevet (migrations + Edge Functions + secrets) og kan deployes i én kommando. 

```bash
# 1. Clone repo
git clone https://github.com/tombomann/klarpakke.git
cd klarpakke

# 2. Setup environment
cp .env.example .env
# Edit .env with your credentials

# 3. Local dev (1 click)
npm run one:click

# 4. Deploy backend (1 click)
npm run deploy:backend

# 5. Run health check
npm run health:full
```

📚 **[Full Documentation →](docs/ONE-CLICK-DEPLOY.md)**

---

## 🎯 Quick Start (For Development)

### Option 1: Makefile (Legacy)

Makefile-kommandoer finnes fortsatt, men målet er at Supabase CLI‑flowen over er canonical. 

```bash
make bootstrap
make edge-full
make deploy-all
make edge-test-live
```

### Option 2: Manual Scripts

```bash
bash scripts/validate-env.sh
bash scripts/deploy-backend.sh
```

---

## 📚 Documentation

### Core Documentation
- **[Automation Setup Guide](.github/AUTOMATION-SETUP.md)** 🟢 **New! Start here for CI/CD**
- **[One-Click Deploy Guide](docs/ONE-CLICK-DEPLOY.md)** 👈 **Local dev!**
- **[Production Automation Plan](docs/PRODUCTION-PLAN.md)** 🚀 **20-30h roadmap for full 1-click**

### Design & Content
- **[Design System](docs/DESIGN.md)** (Farger, typografi, trafikklys, sider, pricing)
- **[Copy (Microcopy)](docs/COPY.md)** (Alle tekster til Webflow)
- **[Webflow Manual Guide](docs/WEBFLOW-MANUAL.md)** (Lær hvordan du unngår kode-som-tekst feil)
- **[Webflow Element IDs](docs/WEBFLOW-ELEMENT-IDS.md)** (Required IDs per side)
- **[Webflow Sitemap](docs/WEBFLOW-SITEMAP.md)** (Side struktur)
- **[Webflow QA Checklist](docs/WEBFLOW-QA-CHECKLIST.md)** (Testing)

### AI & Integration
- **[AI Model Playbook](docs/ai/MODEL-PLAYBOOK.md)** (Hvilken AI-modell til hva?)
- [AI Architecture & Context](docs/ai/CONTEXT.md)
- [Bubble Integration Guide](docs/ai/BUBBLE-CHECKLIST.md)

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────┐
│          WEBFLOW CLOUD (Frontend)               │
├─────────────────────────────────────────────────┤
│ • Landing, Pricing, Dashboard, Calculator       │
│ • Loader: web/snippets/webflow-footer-loader    │
│ • Auto-serves: klarpakke-site.js + calculator.js│
└──────────────┬───────────────────────────────────┘
               │ fetch() API calls
               ▼
┌─────────────────────────────────────────────────┐
│      SUPABASE (Backend + Database)              │
├─────────────────────────────────────────────────┤
│ • PostgreSQL (signals, positions, risk_meter)   │
│ • Edge Functions (deployed via CLI):            │
│   - generate-trading-signal                     │
│   - approve-signal                              │
│   - analyze-signal                              │
│   - update-positions                            │
│   - serve-js (serves bundled frontend)          │
│   - debug-env (sanity check)                    │
│ • Auto-sync to Webflow CMS (GitHub Actions)    │
└──────────────┬───────────────────────────────────┘
               │ Webhooks
               ▼
┌─────────────────────────────────────────────────┐
│         MAKE.COM (Automation)                   │
├─────────────────────────────────────────────────┤
│ • Signal ingestion (scheduled every 4h)         │
│ • AI calls (Perplexity Sonar Pro)               │
│ • CMS sync (Supabase → Webflow)                 │
└─────────────────────────────────────────────────┘
```

---

## 🔄 GitHub Actions (CI/CD)

### Active Workflows

#### 1. 📊 Daily CMS Sync
**File:** `.github/workflows/sync-cms-daily.yml`

**Schedule:** 06:00 UTC daily (07:00 CET)

**What it does:**
- Fetches new signals from Supabase
- Syncs to Webflow CMS collection
- Skips duplicates automatically
- Reports sync statistics

**Manual trigger:** Actions → Daily CMS Sync → Run workflow

#### 2. 🏥 Database Health Check
**File:** `.github/workflows/database-health-check.yml`

**Schedule:** Every 6 hours

**What it does:**
- Tests Supabase API connectivity
- Validates database schema
- Counts records
- Reports failures immediately

#### 3. 🔐 Secrets Audit
**File:** `.github/workflows/secrets-audit.yml`

**Schedule:** Weekly (Mondays at 12:00 UTC)

**What it does:**
- Validates all required secrets exist
- Tests API authentication
- Reports missing configurations
- Checks Supabase + Webflow connectivity

### Required GitHub Secrets

```bash
# Supabase
SUPABASE_URL
SUPABASE_ANON_KEY
SUPABASE_SERVICE_KEY  # Optional for admin operations
SUPABASE_ACCESS_TOKEN # For CLI operations
SUPABASE_PROJECT_REF  # Project reference

# Webflow
WEBFLOW_API_TOKEN
WEBFLOW_SITE_ID
WEBFLOW_SIGNALS_COLLECTION_ID

# AI (optional)
PPLX_API_KEY         # Perplexity API
```

**Setup:** Settings → Secrets and variables → Actions → New repository secret

---

## 📝 Scripts Overview

### Automation Scripts

| Script | Description | Usage |
|--------|-------------|-------|
| `validate-all-secrets.sh` | Validates all secrets (local + remote) | `npm run secrets:validate` |
| `secrets-push-to-supabase.sh` | Sync secrets to Supabase | `npm run secrets:push-supabase` |
| `secrets-push-to-github.sh` | Sync secrets to GitHub | `npm run secrets:push-github` |
| `secrets-pull-from-supabase.sh` | Pull secrets from Supabase | `npm run secrets:pull-supabase` |
| `sync-supabase-to-webflow-v2.js` | Manual CMS sync | `npm run webflow:sync` |
| `cleanup-database.js` | Remove invalid signals | `npm run db:cleanup` |
| `health-check.js` | System health check | `npm run health:check` |

### Testing Scripts

| Script | Description |
|--------|-------------|
| `test-supabase.js` | Test Supabase connection |
| `list-webflow-collections.js` | List Webflow CMS collections |
| `debug-sync-env.js` | Debug environment variables |

---

## 📍 Production Roadmap

### ✅ Completed (Phase 1)

- [x] Secret management system
- [x] CMS automation (Supabase → Webflow)
- [x] GitHub Actions CI/CD
- [x] Database health checks
- [x] Automated secrets auditing
- [x] Database cleanup scripts

### 🔄 In Progress (Phase 2)

**See GitHub Issues:**
- [Issue #30: Webflow Frontend Implementation](https://github.com/tombomann/klarpakke/issues/30)
- [Issue #31: Supabase Auth Integration](https://github.com/tombomann/klarpakke/issues/31)
- [Issue #32: Testing & Production Deployment](https://github.com/tombomann/klarpakke/issues/32)

### 📅 Next Steps

1. **Create Webflow pages** with required element IDs (2-3 hours)
2. **Integrate Supabase Auth** into login/signup flows (2-3 hours)
3. **End-to-end testing** across all pages (8 hours)
4. **Deploy to staging** for QA (1 hour)
5. **Deploy to production** after approval (1 hour)

**Total remaining:** ~15-20 hours (2-3 days)

**Full plan:** See [`docs/PRODUCTION-PLAN.md`](docs/PRODUCTION-PLAN.md)

---

## 📚 Webflow Integration Checklist

### Element IDs Required (Per Side)

**Dashboard (`/app/dashboard`)**
- `#signals-container` – liste av trading signals
- `#signal-item-template` – template for cloning
- `#loading-spinner` – loading state
- `#error-message` – error display
- `#filter-buy`, `#filter-sell`, `#filter-all` – filters

**Settings (`/app/settings`)**
- `#save-settings` – lagre-knapp
- `#user-email-display` – user email
- `#logout-button` – logout
- `#theme-toggle` – dark/light mode

**Pricing (`/app/pricing`)**
- Buttons med `data-plan="paper|safe|pro|extrem"`

**Kalkulator (`/kalkulator`)**
- `#calc-start` – startbeløp input
- `#calc-crypto-percent` – crypto % slider
- `#calc-plan` – plan select
- `#calc-result-table` – resultat-tabell

**Full list:** See [`docs/WEBFLOW-ELEMENT-IDS.md`](docs/WEBFLOW-ELEMENT-IDS.md)

### Setup (One-Time)

1. **After first CI/CD run**, download webflow-loader artifact
2. **Webflow Project Settings → Custom Code → Footer**:
   ```html
   <script src="https://cdn.jsdelivr.net/gh/tombomann/klarpakke@{COMMIT_SHA}/web/dist/webflow-loader.js"></script>
   ```
3. **Publish** – loader will inject config + load scripts automatically

### After Deploy

- Hard refresh (`Cmd+Shift+R`) and open DevTools Console
- Check for "[Klarpakke]" logger messages
- Missing elements will be logged as warnings

---

## 😨 Troubleshooting

### CI/CD Pipeline Issues

**Check pipeline status:**
- Go to **Actions** tab → Select workflow → Latest run
- Click any failed job for detailed logs

**Missing secrets:**
- Go to **Settings → Secrets and variables → Actions**
- Verify all required secrets are set
- Run `npm run secrets:validate` locally

**Workflow not appearing:**
- Wait 1-2 minutes after pushing `.github/workflows/*.yml`
- Refresh Actions page
- Check YAML syntax with yamllint

### CMS Sync Issues

**Sync fails:**
```bash
# Test locally
npm run webflow:sync

# Check logs
tail -f /var/log/klarpakke-sync.log

# Validate secrets
npm run secrets:validate
```

**Duplicates created:**
- Sync script auto-detects duplicates by `symbol + direction`
- Check Webflow CMS for manual duplicates

### Backend Issues

**Edge Functions not responding**
```bash
supabase functions list
supabase functions logs generate-trading-signal
supabase functions deploy generate-trading-signal --no-verify-jwt
```

**Database connectivity**
```bash
# Run health check
npm run health:check

# Or full system check
npm run health:full
```

---

## 🧑‍💻 Contributing

### Development Workflow

1. Create feature branch: `git checkout -b feature/my-feature`
2. Make changes
3. Test locally: `npm run health:full`
4. Commit: `git commit -m "feat: my feature"`
5. Push: `git push origin feature/my-feature`
6. Create PR on GitHub
7. Wait for CI/CD checks to pass
8. Merge after approval

### Before Pushing

```bash
# Validate everything
npm run secrets:validate
npm run health:check
npm run webflow:sync  # Test sync

# Check no secrets in code
git diff | grep -E '(apikey|token|secret|password)'
```

---

## 📝 License

Private repository. All rights reserved.

---

## 🔗 Quick Links

- **GitHub Actions:** https://github.com/tombomann/klarpakke/actions
- **Supabase Dashboard:** https://supabase.com/dashboard/project/swfyuwkptusceiouqlks
- **Webflow Designer:** https://webflow.com/dashboard/sites/klarpakke/designer
- **Issues:** https://github.com/tombomann/klarpakke/issues

---

**Last Updated:** 2026-01-29
