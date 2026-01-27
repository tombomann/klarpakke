# Webflow auto-deploy (footer loader)

Mål: slippe manuell copy/paste i Webflow ved å la GitHub Actions oppdatere **Project Settings → Custom Code → Footer Code** automatisk.

## To nivåer

### Level 1 (OK): Footer loader med inline config
- Webflow footer inneholder `SUPABASE_URL` + `SUPABASE_ANON_KEY`.
- Funker, men Webflow lagrer anon key i custom code.

### Level 2 (Best): Footer loader henter config fra Supabase Edge Function
I dette oppsettet inneholder Webflow footer kun en URL til en public config-endpoint:
- `https://<project-ref>.supabase.co/functions/v1/public-config`

`public-config` returnerer:
- `supabaseUrl`
- `supabaseAnonKey`
- `assetBase`
- `debug`

## Hvordan det funker

1. `supabase/functions/public-config` deployes som Edge Function.
2. Repoet har en template: `web/snippets/webflow-footer-loader.template.html`.
3. CI renderer template ved å sette inn `KLARPAKKE_PUBLIC_CONFIG_URL`.
4. CI kaller Webflow API og oppdaterer “custom_code” + publiserer.

Workflow: `.github/workflows/webflow-deploy.yml`

## Secrets (GitHub)

Required:
- `WEBFLOW_API_TOKEN`
- `WEBFLOW_SITE_ID`
- `KLARPAKKE_PUBLIC_CONFIG_URL`

Also required for Supabase deploy (public-config må få disse som secrets i Supabase):
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

Optional:
- `WEBFLOW_PUBLISH_DOMAINS` (JSON-array string, default: `["*.webflow.io"]`)
- `KLARPAKKE_ASSET_BASE` (default: jsDelivr `...@main/web`)
- `KLARPAKKE_DEBUG`

## Lokal kjøring

```bash
set -a; source .env; set +a
bash scripts/webflow-deploy-loader.sh
```

## Sikkerhet

- `anon` key er ment å kunne ligge i klientkode, men `service_role` må aldri legges i Webflow/klient.
- RLS må være korrekt konfigurert for data du eksponerer via `anon`.
