# 🚀 Klarpakke - AI Trading Automation Platform

> **Web-first trading pipeline**: Signal → Risk → Execution → Logging  
> Built with: Webflow + Make.com + Supabase + Perplexity AI

[![Deploy & Test](https://github.com/tombomann/klarpakke/actions/workflows/deploy.yml/badge.svg)](https://github.com/tombomann/klarpakke/actions/workflows/deploy.yml)

---

## ⚡ Quickstart (5 minutter)

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

### 3. Verifiser
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

### 4. Importer Make.com‑scenarier (valgfritt, Webflow‑delen)
```bash
make make-import
```

Følg instruksene for å importere 4 automasjons‑blueprints:
1. **Trading Signal Generator** – Perplexity → Supabase
2. **Position Tracker** – 15min PnL‑oppdateringer
3. **Daily Risk Reset** – 00:00 UTC reset + arkivering
4. **Webflow Sync** – Godkjente signaler → Webflow CMS

> 💡 **Klar filosofi:** all business‑logikk i Supabase (SQL + Edge Functions),
> alt «lim» i Make.com, all visning i Webflow.

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
- **Seed**: én rad i `daily_risk_meter` per dag, brukt som enkel «circuit breaker»

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

# One‑shot full automatisering
make auto          # edge-full + gh-secrets + oppsummering
```

### GitHub Actions (`.github/workflows/deploy.yml`)

- Kjører på `push` til `main` og PRs
- Setter opp `.env` fra GitHub Secrets
- Installerer `jq` + `curl`
- Kjører `verify-tables.sh` og `smoke-test.sh`
- Failer raskt hvis Supabase ikke svarer eller tabeller mangler

Resultat: **hver commit mot `main` er en faktisk helsesjekk av trading‑pipelinen**.

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

Alle API‑kall bruker wrapper‑funksjonen `req()` som splitter body og HTTP‑kode uten GNU‑avhengigheter.

---

## 🔄 Hva vi fortsatt kan automatisere (plan)

**Problem + DoD (≤4 punkter)**

1. Minimere manuelle steg i Supabase (SQL‑deploy + edge‑secrets)
2. Formalisere KPI‑eksport (30/90‑dager) som én kommando
3. Automatisere Make.com‑eval (status på alle scenario‑IDs via API)
4. Dokumentere full «Signal → Risk → Execution → Logging» som kjørbar CLI‑demo

### Arkitektur (flowchart som tabell)

| Steg | Komponent      | Input                         | Output                          |
|------|----------------|-------------------------------|----------------------------------|
| 1    | CLI/Makefile   | `.env`                        | Supabase URL/keys i env          |
| 2    | SQL (`DEPLOY`) | `DEPLOY-NOW.sql`              | Tabeller + RLS + seed            |
| 3    | Edge Functions | Supabase prosjekt + secrets   | `generate-trading-signal`, `update-positions` |
| 4    | Make.com       | Supabase keys + Webflow       | Scenarier som kjører på schedule/webhooks |
| 5    | GitHub Actions | Repo + Supabase secrets       | CI smoke‑tests på hvert push     |
| 6    | KPI‑skript     | Supabase `ai_calls`/`signals` | CSV/rapport for winrate/R/drawdown |

---

## 📈 Neste steg (konkrete automatiseringer)

Disse er neste kandidater å implementere i repoet (scripts + Makefile‑targets):

1. **`scripts/deploy-schema.sh`** – les `DEPLOY-NOW.sql` og kjør mot Supabase via `psql`/Supabase CLI (slik at vi kan kommentere inn `deploy-schema`‑jobben i GitHub Actions senere).
2. **`scripts/export-kpis.sh`** – eksisterer allerede, men README skal tydelig forklare hvordan den brukes for:
   - winrate per symbol
   - gjennomsnittlig R
   - maks drawdown
3. **`scripts/make-status.sh`** – enkel Make.com‑status via API (teamId + scenarioId), med summarisk output: `OK / PAUSED / BROKEN` per scenario.
4. **`scripts/demo-signal-run.sh`** – kjedet pipeline som:
   - kaller edge `generate-trading-signal`
   - sjekker at ny rad dukker opp i `signals`
   - oppdaterer `daily_risk_meter`

Alle nye scripts skal følge prosjekt‑standarden:
- `set -euo pipefail`
- `trap` for opprydding ved feil
- `curl -s -f -w "%{http_code}"` + `jq -e` for API

---

## 🔐 Miljøvariabler

### `.env` (lokalt)

```bash
# Supabase
SUPABASE_URL=https://swfyuwkptusceiouqlks.supabase.co
SUPABASE_ANON_KEY=eyJhbGc...
SUPABASE_SECRET_KEY=eyJhbGc...

# Make.com / Webflow (settes manuelt i Make‑scenarier)
WEBFLOW_API_TOKEN=...
WEBFLOW_COLLECTION_ID=...
```

### GitHub Secrets (CI)

Legg til i: `https://github.com/tombomann/klarpakke/settings/secrets/actions`

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SUPABASE_SECRET_KEY`

Deretter:
```bash
make gh-secrets
```

---

## 🧭 Filosofi: Klarpakke for småsparere

- **Enkel** – hele systemet skal kunne startes med `make bootstrap` + `make auto`
- **Risikoredusert** – all risiko logges i `daily_risk_meter`, og pipeline skal heller stoppe nye signaler enn å overskride `max_risk_allowed`
- **Etterprøvbar** – alle AI‑kall logges i `ai_calls`, alle signaler/trades er SQL‑spørrbare fra Supabase‑UI

Denne README beskriver "hva gjort" og "hvordan kjøre". For hver ny feature bør vi også legge til:
- kort **"HVA gjort"** i PR‑beskrivelse
- **"HVORFOR"** (risiko/edge) i commit‑melding
- **"TEST"** (kommando + forventet output)

## 🧪 Webflow demo (papertrading)

Mål: Etter publish kan du som demobruker teste hele flyten (signal → approve/reject → paper-execution → logging) uten ekte ordre.

### Webflow: tynn UI (anbefalt)
- Lag sider under `/app/*` (ryddig skille), f.eks. `/app/signals`, `/app/positions`, `/app/risk`.
- Legg inn **én** global JS-linje i Webflow (Project/Page settings → custom code), ikke lim inn store scriptblokker. [Webflow: Custom code i head/body] [web:89]
- Bruk `data-*` attributter (ikke `id`) så listevisning med mange kort fungerer.

Kontrakt (eksempel på attributter):
- På knapp: `data-kp-action="APPROVE"` eller `data-kp-action="REJECT"`
- På knapp eller kort: `data-signal-id="<uuid>"`

### Innhold inn i Webflow (to modus)
1) CSV (fallback / manuelt): Webflow CMS støtter import av collection-items fra CSV. [web:149][web:137]  
2) Automatisert (anbefalt): Sync fra Supabase via Make/Webflow API, men respekter rate limits. [web:114]

### Publish-disciplin
Kjør Audit-panel før publish, og fiks alt det Webflow flagger før du trykker publish. [web:81]

### Innlogging (demo)
Bruk enkel “password protected” for `/app/*` i første demo; ikke bygg ny auth rundt Webflow User Accounts nå (de er under endring/sunset i Webflow). [web:119]
