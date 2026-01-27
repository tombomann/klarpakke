# Ops / runbook

Dette er «hvordan vi kjører det senere» for Klarpakke: deploy, Webflow-sync og overvåking.

## 1) Required GitHub Secrets

Backend deploy (Supabase):
- `SUPABASE_ACCESS_TOKEN`
- `SUPABASE_PROJECT_REF`
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SUPABASE_SERVICE_ROLE_KEY`
- `PPLX_API_KEY`

Webflow deploy:
- `WEBFLOW_API_TOKEN`
- `WEBFLOW_SITE_ID`
- `KLARPAKKE_PUBLIC_CONFIG_URL` (f.eks. `https://<project-ref>.supabase.co/functions/v1/public-config`)

## 2) Deploy backend

Kjør GitHub Action workflow:
- `.github/workflows/supabase-backend-deploy.yml`

Dette deployer migrations + Edge Functions + secrets (inkl. `public-config`).

## 3) Deploy Webflow footer loader

Kjør GitHub Action workflow:
- `.github/workflows/webflow-deploy.yml`

Den kjører preflight og publiserer kun hvis config + assets er OK.

## 4) Overvåking / healthcheck

Workflow:
- `.github/workflows/healthcheck-webflow-loader.yml`

Kjører daglig og på manuell trigger. Ved failure opprettes/oppdateres en issue automatisk.

## 5) Lokal feilsøking

```bash
set -a; source .env; set +a
bash scripts/healthcheck-webflow-loader.sh
```
