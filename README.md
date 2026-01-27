# Klarpakke: AI-Drevet Krypto-Trading for Småsparere

**Project Status:** 🟢 Active Development  
**Role:** Lead DevSecOps Product Engineer (Automation-First)  
**Mission:** Bygge en enkel, risikoredusert og etterprøvbar tradingplattform.

---

## 🚀 One-Click Deploy (NEW!)

```bash
# Set required env vars
export SUPABASE_PROJECT_ID=swfyuwkptusceiouqlks
export SUPABASE_ACCESS_TOKEN=your_token

# Deploy everything
make deploy-all
```

**Done!** Backend + frontend + demo data deployed in 60 seconds.

📖 **[Full Deploy Guide →](docs/ONE-CLICK-DEPLOY.md)**

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

## 🎯 Quick Start (Manual)

### 1. Bootstrap Environment
```bash
make bootstrap
```
Verifies tools, environment variables, and runs smoke tests.

### 2. Deploy Backend (Supabase Edge Functions)
```bash
make edge-full
```
Deploys all functions (`generate-trading-signal`, `approve-signal`, etc.) and sets secrets.

### 3. Deploy Frontend (Webflow)
**One-Click Deploy:**
```bash
bash scripts/webflow-one-click.sh
```
Follow the interactive guide to:
1. Inject UI JavaScript
2. Set Password Protection (`tom123`)
3. Publish Site

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

## 🧭 Konkurrent-sider (sitemap-notater)

Målet her er ikke å kopiere UI, men å kopiere "hvilke sider som må finnes" for å gjøre onboarding, tillit, og self-serve support friksjonsfritt.

- 3Commas: Blog/ressurser, Help Center (getting started + plans + marketplace/signal-sider), tydelig planstruktur/prising.
- Bitsgap: Egen /pricing-side med plan-nivåer, mye innhold/ressurser i blog/compare-artikler.
- Pionex: Help Center med konkrete bot-guider (f.eks. grid bot), fokus på parameter/risiko-forklaringer.

---

## 🧾 Progress log

### 2026-01-27 — One-Click Deploy v3.0 🚀

**HVA gjort**
- Laget `scripts/one-click-deploy.sh` - full automasjon (backend + frontend + seed + test).
- Oppdatert Makefile med `make deploy-all` target.
- Dokumentert alt i `docs/ONE-CLICK-DEPLOY.md`.
- Lagt til positiv tone i alle tekster (`docs/COPY.md`).
- Laget compound calculator JS (`web/calculator.js`).

**HVORFOR**
- Eliminere manuell "copy-paste" workflow.
- Gjøre deploy til én kommando for CI/CD.
- Raskere iterasjon på UI + backend.

**TEST**
- Kjør `make deploy-all` og verifiser at:
  1. Edge Functions deployes og responderer.
  2. Demo-signaler opprettes i Supabase.
  3. Webflow publiseres (hvis WEBFLOW_API_TOKEN satt).
  4. Smoke test passerer.

### 2026-01-27 — Webflow deploy v2.0

**HVA gjort**
- Kjørt `scripts/webflow-one-click.sh` (v2.0) og injisert site-wide JS (Landing + Dashboard + Settings + Pricing).
- Verifisert at repo er "clean" (git up-to-date) før Webflow-injeksjon.
- Opprettet/validert Webflow-sider for app-ruter: `/app/settings` og `/app/pricing`.

**HVORFOR**
- Låse "web-first pipeline" i frontend: Signal → Risk → Execution → Logging (Webflow UI + Make + Supabase).
- Sørge for at JS aldri rendres som tekst (global footer-injeksjon i riktig felt).

**TEST**
- Webflow: Save + Publish etter oppdatert Footer code.
- Besøk `/app/settings` og `/app/pricing` (hard refresh / incognito) og sjekk at siden ikke viser rå JS, samt at console ikke spammer errors.

---

## 🛠 Automation & Workflows

### Makefile Targets
| Command | Description |
|---------|-------------|
| `make deploy-all` | 🚀 **One-click deploy** (backend + frontend + seed) |
| `make help` | Show all available commands |
| `make edge-test-live` | Test Edge Functions against live Supabase |
| `make paper-seed` | Generate demo signals for paper trading |
| `make webflow-export` | Export pending signals to CSV for CMS import |

### GitHub Actions
- **AI Healthcheck:** Runs daily to verify Perplexity API connectivity.
- **Stripe USD Seed:** Automates product/price creation in Stripe (Test/Live).
- **Auto-PR:** Creates Pull Requests for maintenance tasks automatically.

---

## 🔐 Security & Constraints

1. **README First:** All architectural changes start here.
2. **Secrets:** Never commit API keys. Use `.env` locally and GitHub Secrets for CI.
3. **Approvals:** All trading signals require manual approval via the Dashboard before execution.
4. **USD Pricing:** Stripe is the source of truth for pricing (USD).

---

## 📊 Evaluation & Metrics
See `docs/ai/CONTEXT.md` for details on signal accuracy tracking and Brier score evaluation.

---

## 🎨 Design Principles

**Tone:** Positiv + pedagogisk
- Dashboard/kalkulator: vis vekst, muligheter, compound-effekt.
- Opplæring/quiz: én ærlig seksjon om risiko, deretter fokus på strategi.
- Advarsler: kun i opplæring og quiz (ikke repeterende).

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

---

*Generated by Perplexity Sonar Reasoning Pro & Automation Pipeline*
