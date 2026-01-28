# Klarpakke: AI-Drevet Krypto-Trading for Småsparere

**Project Status:** 🟢 Active Development  
**Role:** Lead DevSecOps Product Engineer (Automation-First)  
**Mission:** Bygge en enkel, risikoredusert og etterprøvbar tradingplattform.

---

## 🚀 FULL CI/CD AUTOMATION (NEW!)

**Status:** ✅ Production-ready GitHub Actions + Supabase CLI + Webflow integration

### Quick Setup

1. **Verify GitHub Secrets** (Settings → Secrets):
   ```
   ✅ SUPABASE_ACCESS_TOKEN
   ✅ SUPABASE_PROJECT_REF
   ✅ SUPABASE_URL
   ✅ SUPABASE_ANON_KEY
   ```

2. **Push to `main`** → Pipeline runs automatically:
   ```
   Stage 1: Lint & Build (minify JS)
      ↓
   Stage 2: Supabase Deploy (migrations + Edge Functions)
      ↓
   Stage 3: Webflow Setup (generate loader with config)
      ↓
   Stage 4: Health Check (verify connectivity)
      ↓
   Stage 5: Deploy to Staging (auto)
      ↓
   Stage 6: Deploy to Production (manual approval)
   ```

3. **Webflow Footer** (one-time setup):
   ```html
   <script src="https://cdn.jsdelivr.net/gh/tombomann/klarpakke@{COMMIT_SHA}/web/dist/webflow-loader.js"></script>
   ```

📖 **[Full Automation Guide →](.github/AUTOMATION-SETUP.md)**

### Available npm Scripts

```bash
# Build web assets (minify JS)
npm run build:web

# Generate Webflow loader with runtime config
npm run deploy:webflow

# Deploy backend
npm run deploy:backend

# Full CI chain (all three above)
npm run ci:all
```

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
```

📖 **[Full Documentation →](docs/ONE-CLICK-DEPLOY.md)**

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

- **[Automation Setup Guide](.github/AUTOMATION-SETUP.md)** 🟢 **New! Start here for CI/CD**
- **[One-Click Deploy Guide](docs/ONE-CLICK-DEPLOY.md)** 👈 **Local dev!**
- **[Production Automation Plan](docs/PRODUCTION-PLAN.md)** 🚀 **20-30h roadmap for full 1-click**
- **[Design System](docs/DESIGN.md)** (Farger, typografi, trafikklys, sider, pricing)
- **[Copy (Microcopy)](docs/COPY.md)** (Alle tekster til Webflow)
- **[AI Model Playbook](docs/ai/MODEL-PLAYBOOK.md)** (Hvilken AI-modell til hva?)
- **[Webflow Manual Guide](docs/WEBFLOW-MANUAL.md)** (Lær hvordan du unngår kode-som-tekst feil)
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
└──────────────┬──────────────────────────────────┘
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
└──────────────┬──────────────────────────────────┘
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

**✅ NEW WORKFLOW:** `.github/workflows/auto-deploy.yml` – Full stack automation

**Features:**
- ✅ Automatic lint + build on push to main
- ✅ Supabase migrations + Edge Functions deploy
- ✅ Webflow loader generation with runtime config
- ✅ Health checks (connectivity, syntax)
- ✅ Automatic staging deployment
- ✅ Manual approval gate for production
- ✅ Automatic release creation

**Legacy workflows** (marked deprecated):
- `deploy*.yml`, `one-click-deploy.yml`, `full-stack-deploy.yml`

**Required GitHub Secrets:**
- `SUPABASE_ACCESS_TOKEN`
- `SUPABASE_PROJECT_REF`
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SUPABASE_SERVICE_ROLE_KEY` (optional)
- `PPLX_API_KEY` (optional)

---

## 📋 Webflow Integration Checklist

### Element IDs Required (Per Side)

**Dashboard (`/app/dashboard`)**
- `#signals-container` – liste av trading signals
- `#kp-toast` – feedback toast (global)

**Settings (`/app/settings`)**
- `#save-settings` – lagre-knapp
- `#plan-select` – plan dropdown
- `#compound-toggle` – compound-switch

**Pricing (`/app/pricing`)**
- Buttons med `data-plan="paper|safe|pro|extrem"`

**Kalkulator (`/kalkulator`)**
- `#calc-start` – startbeløp input
- `#calc-crypto-percent` – crypto % slider
- `#calc-plan` – plan select
- `#calc-result-table` – resultat-tabell
- `#crypto-percent-label` – valgfritt: % label

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

## 🚀 Production Roadmap (20–30 hours)

**Full plan for full "1-click" automation:** Se [`docs/PRODUCTION-PLAN.md`](docs/PRODUCTION-PLAN.md)

**Quick summary:**

| # | Task | Est. Time | Priority |
|---|------|-----------|----------|
| 1 | ✅ GitHub Actions workflow | 1–2h | 🔴 P0 |
| 2 | ✅ Build scripts + web minification | 1–2h | 🔴 P0 |
| 3 | ✅ Webflow loader generator | 1–2h | 🔴 P0 |
| 4 | ✅ Supabase CLI integration | 1–2h | 🔴 P0 |
| 5 | Staging/prod environment gating | 2–4h | 🟠 P1 |
| 6 | Kartlegg sider/ruter/IDs | 1–2h | 🟠 P1 |
| 7 | Webflow build checklist | 1–2h | 🟠 P1 |
| 8 | Done Definition per side | 2–3h | 🟠 P1 |
| 9 | Robusthet i `klarpakke-site.js` | 2–3h | 🟠 P1 |
| 10 | Logging + feilhåndtering | 1–2h | 🟠 P1 |
| 11 | Auto sanity-check post-deploy | 1–2h | 🟡 P2 |
| 12 | Dokumentasjonsrunde | 2h | 🟡 P2 |

**Completed:**
- ✅ GitHub Actions auto-deploy workflow
- ✅ Web build + minify scripts
- ✅ Webflow loader generator
- ✅ Supabase CLI deployment

**Total:** ~20–30 timer, **3–5 arbeidsdager** for 1 senior dev.

---

## 🚨 Key Risks & Mitigation

| Risk | Impact | Mitigation |
|------|--------|------------|
| Feil Webflow-struktur → scripts gjør ingenting | Medium | Tydelig checklist + self-test i `klarpakke-site.js` debug-mode |
| Konfig-kaos (staging vs prod) | High | Separate `.env` + GitHub Secrets per miljø |
| "Script som tekst" i Webflow | High | **Forby manuell JS; kun loader i Project Settings** |
| Supabase-nøkler eksponert feil | Critical | Kun `ANON_KEY` i klienten, aldri `SERVICE_ROLE_KEY` |
| Edge Functions endres uten frontend-update | Medium | Streng konvensjon + versjonering |
| Supabase CLI mangler på CI-runner | Medium | Eksplisitt install step + cache |

---

## 📦 Staging → Prod Publishing

1. **Staging-runde**
   - Pipeline auto-deploys to staging on push to main
   - Download webflow-loader artifact
   - Update staging Webflow site + publish
   - QA: test kalkulator, pricing-routing, dashboard, settings

2. **Prod-runde**
   - Review deployed code
   - Go to **Actions → Auto-Deploy Pipeline → Latest run**
   - Find **deploy-production** job
   - Click **Review deployments → Approve**
   - Production deploy starts automatically

3. **Post-deploy**
   - Sett `config.debug=false` (default)
   - `localStorage.getItem('klarpakke_debug')=1` override for internt testing
   - Lag rollback-runbook (previous Supabase migration tag)

---

## 🔧 Proposed Improvements (No Backend Changes)

**Robust path-detection:**
```js
const rawPath = window.location.pathname || '/';
const path = rawPath.replace(/\/+$/, '') || '/';
const isDashboard = path === '/app/dashboard';
```

**Strammere event-delegation (avoid global side-effects):**
- Dashboard approve/reject listeners på `#signals-container`, ikke `document`

**Better fetch-logging & UI feedback:**
- Log `url` + method når `config.debug=true`
- Toast med kort norsk tekst, ikke raw HTTP-errors

**Soft self-test:**
- Når debug-mode: log missing elements ("missing #signals-container on /app/dashboard")

**Defensiv response-handling:**
- Ikke anta JSON-shape; log + remove card on success, toast on error

Se [`docs/PRODUCTION-PLAN.md`](docs/PRODUCTION-PLAN.md) for full detaljer.

---

## 🆘 Troubleshooting

### CI/CD Pipeline Issues

**Check pipeline status:**
- Go to **Actions** tab → **Auto-Deploy Pipeline** → Latest run
- Click any failed job for detailed logs

**Missing secrets:**
- Go to **Settings → Secrets and variables → Actions**
- Verify: `SUPABASE_ACCESS_TOKEN`, `SUPABASE_PROJECT_REF`, `SUPABASE_URL`, `SUPABASE_ANON_KEY`

**Webflow loader not loading:**
1. Open DevTools → Console
2. Check for `[Klarpakke]` logger output
3. Verify CDN URL is correct (commit SHA matches)
4. Hard refresh (`Cmd+Shift+R`)

### Backend Issues

**Edge Functions not responding**
```bash
supabase functions list
supabase functions logs generate-trading-signal
supabase functions deploy generate-trading-signal --no-verify-jwt
```

**Missing environment variables**
```bash
export SUPABASE_PROJECT_REF=your_project_ref
export SUPABASE_ACCESS_TOKEN=sbp_xxx
npm run deploy:backend
```

---

## 📄 License

Private repository. All rights reserved.
