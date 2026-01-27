# Klarpakke One-Click Deploy Guide

Deploy backend (Supabase) i én kommando, med Supabase CLI som **source of truth** (migrations + Edge Functions + secrets). 

---

## Quick Start (60 seconds)

### 1. Sett environment variables

Bruk `SUPABASE_PROJECT_REF` (foretrukket) eller `SUPABASE_PROJECT_ID` (alias). 

```bash
export SUPABASE_PROJECT_REF=swfyuwkptusceiouqlks
export SUPABASE_ACCESS_TOKEN=sbp_xxx
export SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co
export SUPABASE_ANON_KEY=eyJ...
export SUPABASE_SERVICE_ROLE_KEY=eyJ...
export PPLX_API_KEY=pplx-...
```

**Eller lag `.env` lokalt:**

```bash
SUPABASE_PROJECT_REF=swfyuwkptusceiouqlks
SUPABASE_ACCESS_TOKEN=sbp_xxx
SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co
SUPABASE_ANON_KEY=eyJ...
SUPABASE_SERVICE_ROLE_KEY=eyJ...
PPLX_API_KEY=pplx-...
```

### 2. Kjør deploy

```bash
npm run deploy:backend
```

Alternativt:

```bash
bash scripts/deploy-backend.sh
```

---

## Hva som deployes

- Database migrations (`supabase/migrations` → `supabase db deploy`).
- Edge Functions (auto-deploy av alle mapper under `supabase/functions/*`).
- Secrets (minimal env-fil → `supabase secrets set --env-file …`).
- Verifisering (best-effort kall mot `debug-env`, hvis `SUPABASE_URL` er satt).

---

## Lokal utvikling (1 click)

```bash
npm run one:click
```

Dette kjører `supabase start` + `supabase db reset` og forsøker demo-seed hvis `scripts/paper-seed.sh` finnes. 

---

## Webflow / frontend

Webflow-side-struktur og riktig DOM/IDs må lages i Designer (one-time), men JS-filene ligger klare i `web/` for injisering. 

---

## GitHub Actions (CI/CD)

**Canonical workflow:** `.github/workflows/supabase-backend-deploy.yml` (kjøres manuelt via `workflow_dispatch`).

Legacy deploy-workflows er markert som “Deprecated” for å unngå dobbel deploy. 

---

## Required GitHub Secrets

- `SUPABASE_ACCESS_TOKEN`
- `SUPABASE_PROJECT_REF`
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SUPABASE_SERVICE_ROLE_KEY`
- `PPLX_API_KEY`

---

## Troubleshooting

### "Missing required environment variables"

Sett minst:

```bash
export SUPABASE_PROJECT_REF=swfyuwkptusceiouqlks
export SUPABASE_ACCESS_TOKEN=sbp_xxx
```

### "Supabase CLI not installed"

```bash
brew install supabase/tap/supabase
```

---

*Last updated: 28. januar 2026*
