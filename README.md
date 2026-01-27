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
│ • Custom Code (klarpakke-site.js)              │
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
│   - serve-js                                    │
│   - debug-env                                   │
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

Legacy deploy-workflows (`deploy*.yml`, `one-click-deploy.yml`, `full-stack-deploy.yml`) er markert som “Deprecated” for å unngå dobbel deploy. 

**Required GitHub Secrets:**
- `SUPABASE_ACCESS_TOKEN`
- `SUPABASE_PROJECT_REF`
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SUPABASE_SERVICE_ROLE_KEY`
- `PPLX_API_KEY`

---

## 🆘 Troubleshooting

### Edge Functions not responding
```bash
supabase functions list
supabase functions logs generate-trading-signal
supabase functions deploy generate-trading-signal --no-verify-jwt
```

---

## 📄 License

Private repository. All rights reserved.
