#!/usr/bin/env bash
set -euo pipefail

MARKER="## 🧪 Webflow demo (papertrading)"
if grep -qF "$MARKER" README.md; then
  echo "README already has demo section."
  exit 0
fi

cat >> README.md <<'MD'

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
MD

echo "✅ Appended demo section to README.md"
