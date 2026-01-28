# Klarpakke Production Automation Plan

**Mål:** Full "1-click" deploy – backend + Webflow + frontend – uten manuell copy/paste eller hackery.

**Tidsestimat:** 20–30 timer effektiv tid (3–5 arbeidsdager for 1 senior dev)  
**Dato:** Januar 2026  
**Status:** Planlegging (RFP)

---

## A) 15 Oppgaver i Prioritert Rekkefølge

### 🔴 P0 (Critical Path – Blocking)

#### 1. Standardiser Miljøvariabler Lokalt + GitHub
**Estimat:** 0.5–1 time

- Sikre at `.env` (lokalt) og GitHub Secrets inneholder samme sett:
  - `SUPABASE_PROJECT_REF`
  - `SUPABASE_ACCESS_TOKEN`
  - `SUPABASE_URL`
  - `SUPABASE_ANON_KEY`
  - `SUPABASE_SERVICE_ROLE_KEY`
  - `PPLX_API_KEY`
- Oppdater `.env.example` med evt. nye felt for Webflow-loader
- Dokumenter variabel-naming-konvensjon i `ONE-CLICK-DEPLOY.md`

**DoD:**
- [ ] `.env.example` har alle felt
- [ ] GitHub Secrets er aligned med `.env.example`
- [ ] `scripts/validate-env.sh` sjekker alle påkrevde variabler
- [ ] Deployment feiler med tydelig melding hvis noe mangler

---

#### 2. Supabase Backend "One-Click" fra CI
**Estimat:** 1–2 timer

- Bekrefte at `.github/workflows/supabase-backend-deploy.yml` er canonical (den eneste som deployer)
- Deaktivere/slette alle legacy deploy-workflows:
  - `deploy-one-click.yml`
  - `full-stack-deploy.yml`
  - `deploy-all.yml`
  - etc.
- Workflow skal:
  1. Validere env-variabler
  2. Kjøre `supabase db deploy` (migrations)
  3. Kjøre `supabase functions deploy` (alle Edge Functions)
  4. Kjøre `supabase secrets set --env-file .env.production`
  5. Kalle `debug-env` Edge Function for sanity-check
- Enablege `workflow_dispatch` for manuell trigger
- Legge til `environment` input: `staging` | `prod` (velger riktig GitHub Secrets-sett)

**DoD:**
- [ ] Canonical workflow kjører uten feil
- [ ] Alle legacy workflows er ryddet vekk eller eksplisitt deaktivert
- [ ] Workflow logger hver steg tydeligt
- [ ] `debug-env` kalles og logger "Environment OK" eller "Missing X"
- [ ] GitHub Actions dashboard viser grønt ved success

---

#### 3. Lokal Dev "One-Click"
**Estimat:** 1 time

- Bekrefte at `npm run one:click` kjører:
  1. `supabase start` (spinner opp lokal DB)
  2. `supabase db reset` (kjører migrations)
  3. Evt. `bash scripts/paper-seed.sh` hvis finnes (demo-data)
- Teste fullt:
  ```bash
  npm run one:click
  # Verifiser at supabase er oppe på localhost:54321
  # Bekreft at `http://localhost:54321/rest/v1/signals` returnerer SQL-feil (ikke connectivity-feil)
  ```
- Dokumenter at dette er eneste anbefalte lokal entrypoint
- Oppdater README Quick Start til å peke på `npm run one:click` (ikke Makefile-kommandoer)

**DoD:**
- [ ] `npm run one:click` spinner opp lokalt Supabase miljø
- [ ] Migrations kjører uten feil
- [ ] `supabase status` viser "running"
- [ ] `http://localhost:54321/rest/v1/debug-env` returnerer HTTP 200 (Edge Function works)

---

#### 4. Webflow-Loader som Single Source of Truth
**Estimat:** 1–2 timer

- Webflow-loader (`web/snippets/webflow-footer-loader.html`) skal være **eneste** JavaScript som deles inn i Webflow
- Loaderen skal:
  1. Lese `PROJECT_REF` + `ANON_KEY` fra `<meta>`-tags eller `window.KLARPAKKE_CONFIG`
  2. Fetche `web/klarpakke-site.js` fra Supabase Edge Function `serve-js` (eller CDN)
  3. Fetche `web/calculator.js` kun på `/kalkulator`
  4. Wrappe beide i `<script>`-tags for korrekt kjøring (ikke som tekst)
  5. Logg til console når ferdig
- Oppdatere WEBFLOW-MANUAL.md til å si:
  - "Lim inn BARE loaderen i Project Settings → Custom Code → Footer Code"
  - "Ikke lim inn `klarpakke-site.js` eller `calculator.js` direkte (gjør det til tekst)"
- Forbedre `web/snippets/webflow-footer-loader.html` dokumentasjon

**DoD:**
- [ ] Loader leses fra `web/snippets/webflow-footer-loader.html`
- [ ] Den fetcher korrekt JS fra backend
- [ ] `<script>`-tags er på plass (ikke bare tekst)
- [ ] Console logger "[Klarpakke] Site engine v2.2 loaded" (fra klarpakke-site.js)
- [ ] WEBFLOW-MANUAL.md har klare instruksjoner

---

### 🟠 P1 (High Priority – Blocks Webflow QA)

#### 5. Build-Steg for Bundlet Frontend-JS
**Estimat:** 2–4 timer

- Lage `npm run build:web`:
  1. Kopiere `web/klarpakke-site.js` og `web/calculator.js` til `dist/web/`
  2. Evt. minifisere (f.eks. terser) hvis nødvendig
  3. Legge til versjonshash i filnavn for cache-busting (f.eks. `klarpakke-site.2026-01-28.min.js`)
  4. Generere manifest over avhengigheter
- Oppdatere Edge Function `serve-js` til å serve disse bundlene
  - Eller: serve direkte fra `dist/web/` hvis du deployer det til Supabase Storage
- Kall `npm run build:web` som del av CI-pipelinnen før deploy

**DoD:**
- [ ] `npm run build:web` produserer `dist/web/*.js` filer
- [ ] Edge Function `serve-js` returnerer den riktige JS-versjonen
- [ ] Cache-busting virker (ny URL ved hver versjon)
- [ ] Loader henter fra riktig URL

---

#### 6. Kartlegg Alle Sider og Ruter + Nødvendige DOM-IDs
**Estimat:** 1–2 timer

**Public-sider (Webflow):**
- `/` (landing) – CTA til `/opplaering` og `/pricing`
- `/opplaering` – "Start her" + ordliste + 5 ting
- `/risiko` – trafikklys-forklaring
- `/ressurser` – SEO-innhold (artikler fra Supabase Collection)
- `/pricing` – plan-kort med `data-plan` buttons
- `/kalkulator` – compound-kalkulator

**App-sider (private):**
- `/app/dashboard` – signals + trafikklys + status
- `/app/settings` – plan-valg + compound-toggle
- `/app/pricing` – upgrade-side (samme som public `/pricing`?)

**Nødvendige element-IDs:**
- Global: `#kp-toast` (feedback)
- Dashboard: `#signals-container`
- Settings: `#save-settings`, `#plan-select`, `#compound-toggle`
- Pricing: buttons med `data-plan="paper|safe|pro|extrem"`
- Kalkulator: `#calc-start`, `#calc-crypto-percent`, `#calc-plan`, `#calc-result-table`

**Oppgave:** Opprett tabell i dokumentasjon som mapper hver side → required IDs + UI-komponenter.

**DoD:**
- [ ] Tabell over alle sider + slugs + required IDs
- [ ] Tabell over alle data-attributes som brukes
- [ ] Alle IDs dokumentert i WEBFLOW-MANUAL.md

---

#### 7. Webflow Build Checklist
**Estimat:** 1–2 timer

**Collections (valgfritt, men anbefalt):**
- `Artikler` for `/ressurser` (sync fra Supabase CMS?)
  - Felt: `title`, `slug`, `content`, `published_date`, `tags`

**Globale element-IDs:**
- Opprett tabell med element-navn → ID-navn
- F.eks.: "Dashboard Signals Container" → `#signals-container`

**Globale Custom Code plassering:**
- Project Settings → Custom Code → Footer Code (Before `</body>`):
  - Innhold av `web/snippets/webflow-footer-loader.html` (riktig PROJECT_REF + ANON_KEY)
- **IKKE:** lim inn store scripts direkte (gjør dem til tekst)

**Publiseringssteg:**
1. Build sider i Webflow Designer
2. Publiser til staging-domene (`klarpakke-staging.webflow.io`)
3. Verifiser DOM-IDs + API-kall i Browser Console
4. Når OK: publiser til prod-domene

**DoD:**
- [ ] Collections opprettet (hvis relevant)
- [ ] Alle required IDs finnes på hver side
- [ ] Loader ligger i Project Settings (nøyaktig format av `web/snippets/webflow-footer-loader.html`)
- [ ] Staging-publisering virker uten JavaScript-feil

---

#### 8. Done Definition Per Side
**Estimat:** 2–3 timer

Opprett checklist for hver side under `docs/WEBFLOW-CHECKLIST.md`:

**Landing**
- [ ] Bruker DESIGN.md tone + trafikklys-forklaring
- [ ] Har CTA-knapper til `/opplaering`, `/kalkulator`, `/pricing`
- [ ] Ingen rå JS/debug-tekst synlig
- [ ] Loader injiserer klarpakke-site.js uten feil (Console: "[Klarpakke] Site engine v2.2 loaded")

**Pricing**
- [ ] Viser alle 4 planer (Gratis, SAFE, PRO, EXTREM)
- [ ] Plan-kort har trafikklys-farge + parametere (max risk, positions, etc.)
- [ ] Plan-knapper har `data-plan="paper|safe|pro|extrem"`
- [ ] Klikk på EXTREM → router til `/opplaering?quiz=extrem`
- [ ] Klikk på andre → router til `/app/settings?plan=safe` osv.
- [ ] Sammenlignstabell implementert og lesbar
- [ ] Copy fra COPY.md anvendt

**Dashboard**
- [ ] Element `#signals-container` eksisterer
- [ ] Load av signals fra Supabase REST API virker (eller viser "Ingen pending signals")
- [ ] Approve/Reject knapper fungerer og kaller `approve-signal` Edge Function
- [ ] Feilmeldinger vises i toast, ikke raw HTTP-errors
- [ ] Trafikklys-widget med "Din vekst" + status
- [ ] Global infoboks: "Du får forslag. Du godkjenner. Vi logger alt."

**Settings**
- [ ] Element `#plan-select`, `#compound-toggle`, `#save-settings` eksisterer
- [ ] Klikk "Lagre" lagrer til Edge Function `update-user-settings` eller fallback localStorage
- [ ] Toast: "Settings saved" eller "Settings saved (local)"
- [ ] Microcopy fra COPY.md implementert

**Kalkulator**
- [ ] Input/slider/select med riktige IDs
- [ ] Slider oppdaterer label (crypto %)
- [ ] Tabell viser 1/3/5 år + anslått verdi + vekst
- [ ] Farger pr plan (grønn for SAFE, gul for PRO, sort for EXTREM)
- [ ] Disclaimer nederst
- [ ] CTA-knapp: "Start med paper trading"

**Opplæring/Quiz**
- [ ] `/opplaering` har alle seksjoner fra COPY.md
- [ ] Quiz for EXTREM: 5 spørsmål + bestått/ikke bestått-flow
- [ ] `/risiko` har trafikklys-forklaring
- [ ] Mikrocopy og tone align med DESIGN.md

---

#### 9. Forbedringer i `web/klarpakke-site.js` (Robust DOM-Ready)
**Estimat:** 2–3 timer

**Path-deteksjon (robust):**
```js
const rawPath = window.location.pathname || '/';
const path = rawPath.replace(/\/+$/, '') || '/';
const isDashboard = path === '/app/dashboard';
const isSettings = path === '/app/settings';
// etc.
```
Dette unngår feil hvis Webflow legger på trailing slash.

**Event-delegation (scoped):**
- Dashboard approve/reject listeners skal lytte på `#signals-container`, ikke globalt `document`
- Pricing buttons skal lytte på pricing-section, ikke hele siden
- Unngår side-effects på andre sider

**Forbedret logging + feilhåndtering:**
```js
async function fetchJson(url, options) {
  logger.debug('fetchJson', url, { method: options?.method });
  // ... error handling ...
  if (!res.ok) {
    const text = await res.text().catch(() => '');
    throw new Error(`HTTP ${res.status}: ${res.statusText}${text ? ' – ' + text.slice(0, 120) : ''}`);
  }
}
```

**UI-feedback når config mangler:**
- I `initSettings`: "Innstillinger lagres kun lokalt (mangler backend-config)."
- I `initDashboard`: lenke til `/opplaering` som hjelp hvis signals mangler

**Self-test når `config.debug=true`:**
```js
if (config.debug) {
  logger.debug('Self-test: checking expected elements');
  if (isDashboard && !document.getElementById('signals-container')) {
    logger.warn('Self-test: missing #signals-container on dashboard');
  }
  // ... etc ...
}
```

**DoD:**
- [ ] Path-deteksjon robust (trailing slashes OK)
- [ ] Event-listeners scoped til relevante containere
- [ ] `fetchJson` logger detaljert når debug=true
- [ ] Alle feilmeldinger til bruker via toast (kort norsk tekst)
- [ ] Self-test logger missing elements i debug-mode

---

#### 10. Logging + Feilhåndtering Policy
**Estimat:** 1–2 timer

**Standardisert logging:**
- `logger.debug(...)`  – kun hvis `config.debug=true`
- `logger.info(...)` – normale meldinger
- `logger.warn(...)` – noe mistet (manglende element, fallback brukt)
- `logger.error(...)` – alvorlig feil, men ikke crash

**Toast-meldinger (bruker-visning):**
- Feil: "Det gikk ikke helt. Prøv igjen om litt."
- Suksess: "Lagret"
- Info: "Laster signaler…"
- Aldri raw HTTP-error-tekst

**Tomtilstander (empty states):**
- "Ingen nye signaler akkurat nå. Kom tilbake senere."
- "Ingen trades ennå. Godkjenn ditt første signal."
- "Ingen hendelser ennå. Når du godkjenner noe, dukker det opp her."

**Loading states:**
- "Henter signaler…"
- "Dette tar vanligvis noen sekunder."

**DoD:**
- [ ] Alle feilmeldinger i console er prefixet `[Klarpakke]`
- [ ] Alle UI-meldinger er norsk + human-readable
- [ ] Ingen stacktraces vist til bruker
- [ ] Debug-mode kan toggels via `localStorage.setItem('klarpakke_debug', '1')`

---

### 🟡 P2 (Medium Priority – Polish & Optimization)

#### 11. Konfig via Meta/Body Data
**Estimat:** 1–2 timer

- Webflow-template skal legge inn meta-tags:
  ```html
  <meta name="klarpakke:supabase-url" content="https://YOUR_PROJECT_REF.supabase.co">
  <meta name="klarpakke:supabase-anon-key" content="eyJ...">
  <meta name="klarpakke:debug" content="0">
  ```
- eller body-dataset:
  ```html
  <body data-supabase-url="..." data-supabase-anon-key="..." data-klarpakke-debug="0">
  ```
- Config-precedence:
  1. `window.KLARPAKKE_CONFIG` (hardkoding, for testing)
  2. Body `data-*` attributes (Webflow-rendered)
  3. Meta tags (fallback)
  4. `localStorage` (debug override)
- Da kan samme JS fungere for staging + prod uten rebuild

**DoD:**
- [ ] Meta-tags eller body-dataset settes av Webflow template
- [ ] `getConfig()` lyder alle kilder i riktig order
- [ ] Staging/prod kan bruke samme JS-fil (bare annen config)

---

#### 12. Script for Automatisk Generering av Webflow-Loader
**Estimat:** 1–2 timer

- Lage `npm run gen:webflow-loader`:
  1. Les `SUPABASE_URL` + `SUPABASE_ANON_KEY` fra `.env`
  2. Generer `web/snippets/webflow-footer-loader.html` med riktige verdier
  3. Output: "Copy this into Webflow Project Settings → Custom Code → Footer Code"
- Eller: github Action som generer + pusher HTML-fil
- Brukeren trenger da bare å copy/paste én gang; deretter auto-updated via Supabase

**DoD:**
- [ ] `npm run gen:webflow-loader` produserer korrekt loader-HTML
- [ ] Output viser instruksjoner
- [ ] Loader har riktige PROJECT_REF + ANON_KEY innlagt

---

#### 13. Staging/Prod Miljøkabling
**Estimat:** 2–4 timer

- Lage separate Supabase-prosjekter:
  - `klarpakke-staging` (sandbox)
  - `klarpakke-prod` (production)
- GitHub Secrets:
  - `SUPABASE_PROJECT_REF_STAGING`, `SUPABASE_PROJECT_REF_PROD`
  - `SUPABASE_ACCESS_TOKEN_STAGING`, `SUPABASE_ACCESS_TOKEN_PROD`
  - etc.
- CI-workflow med `workflow_dispatch` input:
  ```yaml
  inputs:
    environment:
      type: choice
      options: [staging, prod]
  ```
- Workflow velger riktig Secrets-sett basert på input
- Webflow: separate custom code per miljø, eller parametrisert via meta-tags

**DoD:**
- [ ] To separate Supabase-prosjekter konfigurert
- [ ] GitHub Secrets separert per miljø
- [ ] Workflow kan deploye til begge
- [ ] Webflow kan bruke korrekt backend per domene

---

#### 14. Automatisk Sanity-Check Etter Deploy
**Estimat:** 1–2 timer

- Oppdatere `scripts/deploy-backend.sh` eller GitHub Actions:
  1. Kall Edge Function `debug-env` og verifiser at den returnerer `{"status": "ok"}`
  2. Kall `serve-js` og verifiser at den returnerer gyldig JavaScript
  3. Logg "Environment OK" eller "Environment FAILED: X" i GitHub Actions output
- Hvis noe feiler: GitHub Action fails (blokkerer deploy)

**DoD:**
- [ ] Deploy-skript kaller sanity-check-funksjoner
- [ ] Resultat logges tydelig i CI output
- [ ] Hvis failed: rød status i GitHub Actions

---

#### 15. Dokumentasjonsrunde
**Estimat:** 2 timer

- Oppdater `docs/ONE-CLICK-DEPLOY.md` med Webflow-del:
  - "One-time: legg inn loader i Webflow footer."
  - "Deretter: én GitHub Action → backend + JS oppdatert."
- Oppdater `docs/WEBFLOW-MANUAL.md` med nye prosesser
- Lag `docs/WEBFLOW-CHECKLIST.md` med DoD per side
- Oppdater README med lenker til alle nytt dokumentasjon
- Lag kort "Runbook" for rollback (hvordan revertere)

**DoD:**
- [ ] All dokumentasjon oppdatert + lesbar
- [ ] Ingen "TODO" eller placeholder-tekst
- [ ] Rollback-prosess dokumentert

---

## B) Tidsestimat Sammendrag

| # | Task | Min | Max | Avg |
|---|------|----|-----|-----|
| 1 | Miljøvar. | 0.5h | 1h | 0.75h |
| 2 | Backend CI | 1h | 2h | 1.5h |
| 3 | Lokal one:click | 1h | 1h | 1h |
| 4 | Webflow-loader | 1h | 2h | 1.5h |
| 5 | Build-steg JS | 2h | 4h | 3h |
| 6 | Kartlegg sider | 1h | 2h | 1.5h |
| 7 | Build checklist | 1h | 2h | 1.5h |
| 8 | Done Def. | 2h | 3h | 2.5h |
| 9 | Robusthet JS | 2h | 3h | 2.5h |
| 10 | Logging policy | 1h | 2h | 1.5h |
| 11 | Konfig meta | 1h | 2h | 1.5h |
| 12 | Gen. loader | 1h | 2h | 1.5h |
| 13 | Staging/prod | 2h | 4h | 3h |
| 14 | Sanity-check | 1h | 2h | 1.5h |
| 15 | Docs | 2h | 2h | 2h |
| **TOTAL** | | **19h** | **33h** | **26h** |

**Realistisk:** 20–30 timer, **3–5 arbeidsdager** for 1 senior dev.

---

## C) Risikoer + Mitigering

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Feil Webflow-struktur → scripts gjør ingenting | Medium | Medium | Tydelig checklist + self-test i debug-mode |
| Konfig-kaos (staging vs prod) | High | Medium | Separate `.env` + GitHub Secrets + logging |
| "Script som tekst" i Webflow | High | High | **Forby manuell JS; kun loader** |
| Supabase-nøkler eksponert feil | Critical | Low | Code review + dokumentasjon (ANON_KEY only) |
| Edge Functions endres uten frontend-update | Medium | Medium | Streng konvensjon + versjonering |
| Supabase CLI mangler på CI-runner | Medium | Low | Eksplisitt install step |
| Webflow domene-url endres | Low | Low | URL er på env/meta-tag, ikke hardkoda |
| JavaScript bundles blir for stør | Low | Low | Monitorering av bundle-size |
| Cache-feil etter deploy | Medium | Medium | Cache-busting via versjonshash |

---

## D) Staging → Prod Publishing Plan

### Staging-runde
1. **Backend deploy:**
   ```bash
   npm run deploy:backend
   # eller: GitHub Actions med environment=staging
   ```
2. **Webflow:**
   - Oppdater loader (hvis nødvendig) med staging-Supabase-URL/anon-key
   - Build/oppdater alle sider
   - Publiser til staging-domene (`klarpakke-staging.webflow.io`)
3. **QA (manuell):**
   - Test kalkulator: input oppdateres live
   - Test pricing: knapper router korrekt
   - Test dashboard: henter signaler eller viser meningsfull tom-tilstand
   - Test settings: lagring fungerer
   - Check console: ingen errors, "[Klarpakke]" logger-output OK
4. **Venter på grønt** ✅

### Prod-runde
1. **Backend deploy:**
   ```bash
   # GitHub Actions: workflow_dispatch med environment=prod
   ```
2. **Webflow:**
   - Oppdater loader (hvis nødvendig) med prod-Supabase-URL/anon-key
   - Publiser til prod-domene
3. **Sanity-check (5 min):**
   - Besøk `/kalkulator` og test slider
   - Besøk `/app/dashboard` og bekreft signals laster
   - Check console: "[Klarpakke] Site engine v2.2 loaded" OK
4. **Post-deploy:**
   - Sett `config.debug=false` (default)
   - `localStorage.getItem('klarpakke_debug')='1'` override for internt testing
   - Dokumenter deploy-tid
   - Lag entry i "Deployment Log"

### Rollback-plan
- Hvis prod-deploy feiler: revert til forrige Supabase migration tag
  ```bash
  supabase db push --version <PREVIOUS_TAG>
  ```
- Hvis Webflow feiler: revert til staging-domene (brukere får redirect)

---

## E) Self-Check Before Production

**Før hver prod-deploy, verifiser:**

- [ ] Alle GitHub Secrets er satt (staging + prod)
- [ ] `.env` ikke committed (`.env` ligger i `.gitignore`)
- [ ] `SUPABASE_SERVICE_ROLE_KEY` **aldri** i Webflow/klienten
- [ ] Webflow-loader er den eneste JS i Project Settings
- [ ] Ingen stale cached-versjon av JS blir lastet (cache-buster virker?)
- [ ] Migrations + Edge Functions deployer uten errors
- [ ] `debug-env` returnerer 200 OK
- [ ] QA-testing gjort på staging
- [ ] Rollback-plan er dokumentert
- [ ] Deployment-tid skal være minimal: ~5-10 min (ikke "alle dag")

---

**Status:** Klar for implementering.
