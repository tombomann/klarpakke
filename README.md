# Klarpakke: AI-Drevet Krypto-Trading for Småsparere

**Project Status:** 🟢 Active Development  
**Role:** Lead DevSecOps Product Engineer (Automation-First)  
**Mission:** Bygge en enkel, risikoredusert og etterprøvbar tradingplattform.

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

- **[One-Click Deploy Guide](docs/ONE-CLICK-DEPLOY.md)** 👈 **START HERE!**
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

**Canonical deploy workflow:** `.github/workflows/supabase-backend-deploy.yml` (manual `workflow_dispatch`).

Legacy deploy-workflows (`deploy*.yml`, `one-click-deploy.yml`, `full-stack-deploy.yml`) er markert som "Deprecated" for å unngå dobbel deploy. 

**Required GitHub Secrets:**
- `SUPABASE_ACCESS_TOKEN`
- `SUPABASE_PROJECT_REF`
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SUPABASE_SERVICE_ROLE_KEY`
- `PPLX_API_KEY`

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

1. **Webflow Project Settings → Custom Code → Footer (Before `</body>`)**
   - Kopier innhold fra `web/snippets/webflow-footer-loader.html`
   - Oppdater `PROJECT_REF` og `SUPABASE_ANON_KEY` med riktige verdier fra `.env`

2. **Webflow Pages (Structure)**
   - Lag sider per rute: `/opplaering`, `/risiko`, `/ressurser`, `/pricing`, `/kalkulator`
   - Lag app-mappe: `/app/dashboard`, `/app/settings`, `/app/pricing`
   - Bruk IDs fra checklisten over

3. **Design Tokens**
   - Hent farger/typografi fra `docs/DESIGN.md`
   - Bruk trafikklys kun for risiko-status (grønn/gul/rød/sort)

### Etter Deploy

- Hard refresh (`Cmd+Shift+R`) og åpne DevTools Console
- Sjekk for "[Klarpakke]" logger-meldinger
- Hvis elements mangler: logger vil vise "No #signals-container found on page"

---

## 🚀 Production Roadmap (20–30 hours)

**Full plan for full "1-click" automation:** Se [`docs/PRODUCTION-PLAN.md`](docs/PRODUCTION-PLAN.md)

**Quick summary:**

| # | Task | Est. Time | Priority |
|---|------|-----------|----------|
| 1 | Standardiser `.env` + GitHub Secrets | 0.5–1h | 🔴 P0 |
| 2 | Supabase backend "one-click" fra CI | 1–2h | 🔴 P0 |
| 3 | Lokal `npm run one:click` test | 1h | 🔴 P0 |
| 4 | Webflow-loader som single source of truth | 1–2h | 🔴 P0 |
| 5 | Build-steg for bundlet JS | 2–4h | 🟠 P1 |
| 6 | Kartlegg sider/ruter/IDs | 1–2h | 🟠 P1 |
| 7 | Webflow build checklist | 1–2h | 🟠 P1 |
| 8 | Done Definition per side | 2–3h | 🟠 P1 |
| 9 | Robusthet i `klarpakke-site.js` | 2–3h | 🟠 P1 |
| 10 | Logging + feilhåndtering | 1–2h | 🟠 P1 |
| 11 | Konfig via meta/body data | 1–2h | 🟡 P2 |
| 12 | Script for auto-generering av loader | 1–2h | 🟡 P2 |
| 13 | Staging/prod miljøkabling | 2–4h | 🟡 P2 |
| 14 | Auto sanity-check post-deploy | 1–2h | 🟡 P2 |
| 15 | Dokumentasjonsrunde | 2h | 🟡 P2 |

**Total:** ~20–30 timer, **3–5 arbeidsdager** for 1 senior dev.

---

## 🚨 Key Risks & Mitigation

| Risk | Impact | Mitigation |
|------|--------|-----------|
| Feil Webflow-struktur → scripts gjør ingenting | Medium | Tydelig checklist + self-test i `klarpakke-site.js` debug-mode |
| Konfig-kaos (staging vs prod) | High | Separate `.env` + GitHub Secrets per miljø |
| "Script som tekst" i Webflow | High | **Forby manuell JS; kun loader i Project Settings** |
| Supabase-nøkler eksponert feil | Critical | Kun `ANON_KEY` i klienten, aldri `SERVICE_ROLE_KEY` |
| Edge Functions endres uten frontend-update | Medium | Streng konvensjon + versjonering |
| Supabase CLI mangler på CI-runner | Medium | Eksplisitt `brew install supabase/tap/supabase` step |

---

## 📦 Staging → Prod Publishing

1. **Staging-runde**
   - Run: `npm run deploy:backend` mot staging Supabase
   - Webflow: oppdater loader + sider, publiser til staging-domene
   - QA: test kalkulator, pricing-routing, dashboard, settings

2. **Prod-runde**
   - Trigger GitHub Action `supabase-backend-deploy.yml` med `environment=prod`
   - Webflow: publiser til prod-domene
   - Sanity-check: `debug-env` + live side-test

3. **Post-deploy**
   - Sett `config.debug=false` (default)
   - `localStorage.getItem('klarpakke_debug')=1` override for internt testing
   - Lag rollback-runbook (forrige Supabase migration tag)

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

### Edge Functions not responding
```bash
supabase functions list
supabase functions logs generate-trading-signal
supabase functions deploy generate-trading-signal --no-verify-jwt
```

### Webflow scripts not loading
1. Åpne DevTools → Console
2. Sjekk for `[Klarpakke]` logger-output
3. Verifiser at meta-tags eller body-dataset har `supabase-url` + `supabase-anon-key`
4. Hard refresh (`Cmd+Shift+R`)

### Missing environment variables
```bash
export SUPABASE_PROJECT_REF=your_project_ref
export SUPABASE_ACCESS_TOKEN=sbp_xxx
npm run deploy:backend
```

---

## 📄 License

Private repository. All rights reserved.
