# Webflow auto-deploy (footer loader)

Mål: slippe manuell copy/paste i Webflow ved å la GitHub Actions oppdatere **Project Settings → Custom Code → Footer Code** automatisk.

Dette gjør at Webflow alltid laster siste:
- `web/klarpakke-site.js` (alle sider)
- `web/calculator.js` (kun `/kalkulator`)

## Hvordan det funker

1. Repoet har en template: `web/snippets/webflow-footer-loader.template.html`.
2. CI renderer template ved å sette inn verdier fra GitHub Secrets.
3. CI kaller Webflow API og oppdaterer “custom_code” + publiserer.

Workflow: `.github/workflows/webflow-deploy.yml`

## Secrets (GitHub)

Required:
- `WEBFLOW_API_TOKEN`
- `WEBFLOW_SITE_ID`
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

Optional:
- `KLARPAKKE_ASSET_BASE` (default: jsDelivr `...@main/web`)
- `KLARPAKKE_DEBUG` (`1`/`true` for ekstra logging)
- `WEBFLOW_PUBLISH_DOMAINS` (JSON-array string, default: `["*.webflow.io"]`)

## Lokal kjøring

```bash
set -a; source .env; set +a
bash scripts/webflow-deploy-loader.sh
```

## Sikkerhet

- `anon` key er ment å kunne ligge i klientkode, men `service_role` må aldri legges i Webflow/klient.
- RLS må være korrekt konfigurert for data du eksponerer via `anon`.
