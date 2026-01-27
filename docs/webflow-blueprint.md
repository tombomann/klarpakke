# Webflow Blueprint (Klarpakke)

## Sitemap (ryddig skille)

Public:
- `/`
- `/pricing`
- `/how-it-works`
- `/risk-safety`
- `/support`

App (demo / gated):
- `/app/signals`
- `/app/positions`
- `/app/risk`

## UI-kontrakt (HTML attributes)

Målet er å unngå inline JS og unike `id` i lister.

- På knapper:
  - `data-kp-action="APPROVE" | "REJECT"`
  - `data-signal-id="<uuid>"`

- Optional (status-tekst per kort):
  - `data-kp-status-for="<uuid>"`

## Webflow Custom Code (én gang, før </body>)

```html
<script src="https://swfyuwkptusceiouqlks.supabase.co/functions/v1/serve-js"></script>
```
