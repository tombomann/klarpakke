# 🚀 Klarpakke - AI Trading Automation Platform

> **Web-first trading pipeline**: Signal → Risk → Execution → Logging  
> Built with: Webflow + Make.com + Supabase + Perplexity AI

[![Deploy & Test](https://github.com/tombomann/klarpakke/actions/workflows/deploy.yml/badge.svg)](https://github.com/tombomann/klarpakke/actions/workflows/deploy.yml)

---

## ⚡ ONE-CLICK INSTALL (ANBEFALT)

**Installer alt automatisk på 5 minutter:**

```bash
# 1. Klon repository
git clone https://github.com/tombomann/klarpakke.git
cd klarpakke

# 2. Kjør one-click installer
curl -fsSL https://raw.githubusercontent.com/tombomann/klarpakke/main/scripts/one-click-install.sh | bash
```

**Hva dette gjør:**
- ✅ Oppretter `.env` med Supabase-nøkler
- ✅ Verifiserer database-tabeller (4 tabeller)
- ✅ Deployer 6 Edge Functions til Supabase
- ✅ Setter opp GitHub Actions (auto-deploy + sync)
- ✅ Konfigurerer Webflow API integration
- ✅ Synker secrets til GitHub
- ✅ Klar for Webflow UI deployment

**Forventet output:**
```
🚀 Klarpakke One-Click Full Automation
=======================================

📦 Step 1/5: Bootstrap environment...
✅ Bootstrap complete

🔧 Step 2/5: Deploying Edge Functions...
✅ 6 functions deployed

🌐 Step 3/5: Webflow integration setup...
✅ Webflow credentials saved

🔐 Step 4/5: Syncing GitHub secrets...
✅ GitHub secrets synced

🎨 Step 5/5: Webflow UI deployment...
✅ Ready to deploy!

🎉 ONE-CLICK SETUP COMPLETE!
```

**Neste steg:**
```bash
# Deploy Webflow UI (2 min guided process)
bash scripts/webflow-one-click.sh

# Generate demo signals
make paper-seed

# Monitor logs
make edge-logs
```

---

## 📚 Manual Quickstart (hvis one-click feiler)

### 1. Klon & bootstrap
```bash
git clone https://github.com/tombomann/klarpakke.git
cd klarpakke
make bootstrap
```

**Hva dette gjør:**
- ✅ Lager `.env` med Supabase‑nøkler
- ✅ Verifiserer at DB/API er oppe
- ✅ Kjører smoke‑tester (REST + RLS)
- ✅ Printer neste steg for Edge Functions

### 2. Edge Functions + secrets

```bash
# Installer Supabase CLI (macOS først)
make edge-install

# Logg inn og link prosjekt
make edge-login

# Deploy Edge Functions + sett secrets
make edge-full
```

Dette gir deg:
- `generate-trading-signal` (AI‑signal fra Perplexity → Supabase)
- `update-positions` (PnL‑oppdatering fra børs → Supabase)
- Secrets (`PERPLEXITY_API_KEY`) satt i Supabase

### 3. One-click alt (anbefalt)

```bash
make auto
```

Kjører `edge-full` + setter GitHub secrets (for CI) i en kjede.

### 4. Verifiser
```bash
make test        # verify-tables + smoke-test
make edge-test   # kall edge‑funksjoner via HTTP
```

Forventet output (`make test`):
```text
✅ Table 'positions' exists
✅ Table 'signals' exists
✅ Table 'daily_risk_meter' exists
✅ Table 'ai_calls' exists
✅ INSERT works
✅ SELECT works
✅ Risk meter OK
```

---

## 🧱 Arkitektur: "Web‑first" trading pipeline

Klarpakke er bygget som en ren web‑pipeline der alt kan kjøres fra terminal, GitHub Actions eller Make.com – ingen manuelle klikk i konsoller etter init.

### Oversikt

```text
Perplexity → Supabase (signals, ai_calls)
          → Risk (daily_risk_meter)
          → Execution (positions)
          → Logging & KPIs

Webflow UI (klarpakke.no) ⇆ Supabase (public RLS)
Make.com ⇆ Supabase (service_role)
GitHub Actions ⇆ Supabase (service_role)
```

### Databasen (Supabase)

| Table              | Purpose          | Viktige felt                                  |
|--------------------|------------------|-----------------------------------------------|
| `positions`        | Aktive trades    | `symbol`, `entry_price`, `pnl_usd`, `status`  |
| `signals`          | AI‑ideer         | `symbol`, `direction`, `confidence`, `status` |
| `daily_risk_meter` | Dags‑risiko      | `total_risk_usd`, `max_risk_allowed`, `date`  |
| `ai_calls`         | AI‑kost/logging  | `endpoint`, `tokens_in`, `cost_usd`           |

- **RLS**: public read (`anon`), full write via `service_role`
- **Seed**: én rad i `daily_risk_meter` per dag, brukt som enkel «sircuit breaker»

---

## 🤖 Automatisering: hva er allerede gjort

### Bash + Makefile

Alle manuelle steg er erstattet med `make`‑targets og Bash‑script som følger samme standard:
- `set -euo pipefail`
- macOS‑sikre `curl`/`sed`/`head`‑kall
- API‑kall med HTTP‑code splitting (`###HTTP_CODE###`‑markør)

Nøkkel‑kommandoer:

```bash
make help          # list alle targets
make bootstrap     # end‑to‑end init (env + DB + smoke)
make test          # verify-tables + smoke-test
make status        # enkel status‑rapport

# Edge Functions
make edge-install  # supabase CLI
make edge-login    # supabase login
make edge-deploy   # deploy edge‑funksjoner
make edge-secrets  # set PERPLEXITY_API_KEY
make edge-full     # deploy + secrets + next‑steps

# GitHub Actions
make gh-secrets       # synk .env → GitHub secrets
make gh-sync-secrets  # trigge secrets‑sync workflow
make gh-test          # trigge scheduled‑tasks manuelt

# Webflow
make webflow-sync     # sync Supabase → Webflow CMS
make webflow-deploy   # deploy UI (interactive)

# One‑shot full automatisering
make auto          # edge-full + gh-secrets + oppsummering
```

---

## 🔄 Webflow Integration (100% Gratis)

**Auto-sync Supabase → Webflow CMS hver 5. minutt:**

### Setup
```bash
# 1. Få Webflow API token:
# - Gå til: https://webflow.com/dashboard/sites
# - Velg site → Settings → Integrations → API Access
# - Generate token → copy

# 2. Legg til .env
echo "WEBFLOW_API_TOKEN=your_token" >> .env
echo "WEBFLOW_COLLECTION_ID=your_collection_id" >> .env

# 3. Test sync manuelt
bash scripts/webflow-sync.sh

# 4. Aktiver auto-sync (GitHub Actions)
make gh-secrets  # synker WEBFLOW_* til GitHub
```

**Hva skjer:**
- ✅ GitHub Action kjører `webflow-sync.sh` hver 5. minutt
- ✅ Henter nye signals fra Supabase (`status=pending`)
- ✅ Pusher til Webflow CMS via API
- ✅ 100% gratis (GitHub Actions free tier = 2000 min/måned)

**Overvåk:**
- GitHub Actions: https://github.com/tombomann/klarpakke/actions/workflows/webflow-sync.yml
- Manuell trigger: `gh workflow run webflow-sync.yml`

---

## 🔄 Make.com blueprints (one click)

Vi håndterer Make som "lim" og importerer scenarier fra `make/flows/*.json`.

### Import (lokalt)

1) Lag `.env.migration` med:
- `MAKE_API_TOKEN`
- `MAKE_ORG_ID`

2) Kjør import:

```bash
bash scripts/import-now.sh
```

Målet er at blueprint/scheduling håndteres som *string* payload i Make API-kall (scriptet gjør double-encoding).

---

## 🧪 Webflow demo (papertrading)

Mål: Etter publish kan du teste hele flyten (signal → approve/reject → paper-execution → logging) uten ekte ordre.

### Webflow: tynn UI (anbefalt)

- Lag sider under `/app/*` (ryddig skille), f.eks. `/app/signals`, `/app/positions`, `/app/risk`.
- Legg inn **én** global JS-linje i Webflow (Project/Page settings → custom code), ikke lim inn store scriptblokker.
- Bruk `data-*` attributter (ikke `id`) så listevisning med mange kort fungerer.

Kontrakt (eksempel):
- På knapp: `data-kp-action="APPROVE"` eller `data-kp-action="REJECT"`
- På knapp eller kort: `data-signal-id="<uuid>"`

### Deploy Webflow UI

```bash
# Interactive 2-minutters guide
bash scripts/webflow-one-click.sh

# Hva dette gjør:
# 1. Kopierer web/klarpakke-ui.js til clipboard
# 2. Åpner Webflow Designer i browser
# 3. Guider deg gjennom: Paste JS → Password → Publish
# 4. Verifiserer deployment
```

### Demo-tilgang

- Første demo: password-protect `/app/*`.
- Demo-passord (staging): `tom` (endre før prod).

### Innhold inn i Webflow (to modus)

1) **CSV (fallback / manuelt)**: Webflow CMS støtter import av collection-items fra CSV.
   ```bash
   make webflow-export  # Eksporter signals til CSV
   # Importer manuelt i Webflow CMS
   ```

2) **Automatisert (anbefalt)**: Auto-sync via GitHub Actions (oppsatt av one-click installer).
   ```bash
   # Allerede aktivert - sjekk status:
   gh workflow view webflow-sync.yml
   ```

### Publish-disciplin

- Kjør Audit før publish.
- Publish til staging først, så prod.

---

## 🧪 Test‑skript (supabase‑fokus)

### `scripts/verify-tables.sh`

- Henter OpenAPI‑spec fra Supabase REST
- Printer alle tilgjengelige paths/tabeller
- Verifiserer at `positions`, `signals`, `daily_risk_meter`, `ai_calls` finnes
- Gir copy‑paste‑instruks for å kjøre `DEPLOY-NOW.sql` hvis noe mangler

### `scripts/smoke-test.sh`

- Laster `.env` hvis ikke allerede satt
- Verifiserer at `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SECRET_KEY` finnes
- Tester:
  1. REST‑tilkobling (GET `/rest/v1/`)
  2. At alle tabeller svarer med `200` på `?limit=1`
  3. `INSERT` i `signals` med `service_role`
  4. `SELECT` i `signals` med `anon`
  5. Les siste `daily_risk_meter` og printer nåværende risiko

---

## 🔐 Miljøvariabler

### `.env` (lokalt)

```bash
# Supabase
SUPABASE_URL=https://swfyuwkptusceiouqlks.supabase.co
SUPABASE_ANON_KEY=eyJhbGc...
SUPABASE_SECRET_KEY=eyJhbGc...

# Webflow (for auto-sync)
WEBFLOW_API_TOKEN=...
WEBFLOW_COLLECTION_ID=...

# Make.com (for import)
MAKE_API_TOKEN=...
MAKE_ORG_ID=...
```

---

## 🧭 Filosofi: Klarpakke for småsparere

- **Enkel** – hele systemet skal kunne startes med `curl ... | bash` (one-click)
- **Risikoredusert** – all risiko logges i `daily_risk_meter`, og pipeline skal heller stoppe nye signaler enn å overskride `max_risk_allowed`
- **Etterprøvbar** – alle AI‑kall logges i `ai_calls`, alle signaler/trades er SQL‑spørrbare fra Supabase‑UI

Denne README beskriver "hva gjort" og "hvordan kjøre". For hver ny feature bør vi også legge til:
- kort **"HVA gjort"** i PR‑beskrivelse
- **"HVORFOR"** (risiko/edge) i commit‑melding
- **"TEST"** (kommando + forventet output)

---

## 📊 Status & Dashboards

- **Supabase**: https://supabase.com/dashboard/project/swfyuwkptusceiouqlks
- **GitHub Actions**: https://github.com/tombomann/klarpakke/actions
- **Webflow**: https://webflow.com/dashboard/sites/klarpakke
- **Documentation**: Se `DEPLOYMENT-STATUS.md` for detaljert status

---

## 👥 Support

- **Issues**: https://github.com/tombomann/klarpakke/issues
- **Discussions**: https://github.com/tombomann/klarpakke/discussions

---

**Last updated**: 27. januar 2026  
**Version**: 2.0 (One-Click Automation)
