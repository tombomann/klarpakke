#!/usr/bin/env bash
set -euo pipefail

MARKER="## 🧪 Webflow demo (papertrading)"
if grep -qF "$MARKER" README.md; then
  echo "README already has demo section."
  exit 0
fi

cat >> README.md <<'MD'

## 🧪 Webflow demo (papertrading)

Mål: Etter publish kan du teste hele flyten (signal → approve/reject → paper-execution → logging) uten ekte ordre.

### Webflow: tynn UI (anbefalt)

- Lag sider under `/app/*` (ryddig skille), f.eks. `/app/signals`, `/app/positions`, `/app/risk`.
- Legg inn **én** global JS-linje i Webflow (Project/Page settings → custom code), ikke lim inn store scriptblokker.
- Bruk `data-*` attributter (ikke `id`) så listevisning med mange kort fungerer.

Kontrakt (eksempel):
- På knapp: `data-kp-action="APPROVE"` eller `data-kp-action="REJECT"`
- På knapp eller kort: `data-signal-id="<uuid>"`

### Demo-tilgang

- Første demo: password-protect `/app/*`.
- Demo-passord (staging): `tom` (endre før prod).

### Innhold inn i Webflow (to modus)

1) CSV (fallback / manuelt): Webflow CMS støtter import av collection-items fra CSV.  
2) Automatisert (anbefalt): Sync fra Supabase via Make/Webflow API (rate limits + throttling).

### Publish-disciplin

- Kjør Audit før publish.
- Publish til staging først, så prod.
MD

echo "✅ Appended demo section to README.md"
