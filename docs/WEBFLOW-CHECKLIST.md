# Webflow checklist (staging → prod)

Dette dokumentet er en praktisk sjekkliste for å bygge og publisere Klarpakke i Webflow uten manuell copy/paste av store scripts.

## 0) Regler (må følges)
- Bruk **kun** en liten loader i Webflow *Project Settings → Custom Code → Footer Code* (site-wide).
- Ikke lim inn `web/klarpakke-site.js` eller `web/calculator.js` direkte i Webflow (risiko for «script som tekst»).
- Aldri legg `SUPABASE_SERVICE_ROLE_KEY` i Webflow/klientkode (kun anon key).

## 1) Ruter og JS-moduler
`klarpakke-site.js` aktiverer moduler basert på at path ender med `/dashboard`, `/settings`, `/pricing`, `/kalkulator` eller `/calculator`.

| Side | Foreslått rute | Modul(er) | Required IDs / attrs |
|---|---|---|---|
| Landing | `/` | Marketing wiring (safe no-op) | (valgfritt) `#kp-toast`, (valgfritt) `[data-kp-ref="binance"]` |
| Pricing | `/pricing` (evt. `/app/pricing`) | Pricing | `data-plan="paper|safe|pro|extrem"` på CTA-elementer |
| Dashboard | `/app/dashboard` | Dashboard | `#signals-container` |
| Settings | `/app/settings` | Settings | `#save-settings`, `#plan-select`, `#compound-toggle` |
| Kalkulator | `/kalkulator` (evt. `/calculator`) | Calculator (`calculator.js`) | `#calc-start`, `#calc-crypto-percent`, `#calc-plan`, `#calc-result-table`, (optional) `#crypto-percent-label` |
| Opplæring/quiz | `/opplaering` | (Webflow UI + evt. egen quiz-JS) | Sørg for at `/opplaering?quiz=start` gir en tydelig start-state |
| Risiko | `/risiko` | (Webflow) | Trafikklys med tekstforklaring (ikke farge alene) |
| Ressurser | `/ressurser` | (Webflow) | (valgfritt) Collection hvis dere vil SEO/CMS |

## 2) Globale elementer (anbefalt)
- `#kp-toast` på alle sider (for feilmeldinger og success-toasts).
- Binance referral CTA-er: bruk `[data-kp-ref="binance"]` (eller legacy `[data-kp-binance-referral]`).

## 3) Webflow Custom Code (plassering)
- **Site-wide loader:** Project Settings → Custom Code → **Footer Code** (Before `</body>`).
- Unngå Page Settings custom code med mindre dere har en helt spesifikk edge-case.

## 4) Bygg per side (DoD)
### Landing
- CTA til `/opplaering`, `/pricing`, `/kalkulator`.
- Tone: pedagogisk, ikke hype.

### Pricing
- Alle plan-kort har CTA med riktig `data-plan`.
- `extrem` skal sende brukeren til `/opplaering?quiz=start`.
- Andre planer skal sende til `/app/settings?plan=...`.

### Dashboard
- `#signals-container` finnes.
- Tomtilstand finnes og ser bra ut når det er 0 signaler.
- Approve/Reject-knapper fungerer (renderes av JS).

### Settings
- `#save-settings` finnes og er tydelig primærhandling.
- `#plan-select` har alle planene.
- `#compound-toggle` finnes (default ON anbefalt).

### Kalkulator
- IDs matcher tabellen over.
- Slider oppdaterer label (hvis dere har `#crypto-percent-label`).
- Tabell rendres og oppdateres når input endres.
- Kort disclaimer nederst.

### Opplæring/quiz
- `/opplaering?quiz=start` starter flyten (f.eks. scroller til quiz, åpner quiz-seksjon, eller viser «Start quiz»-state).

## 5) QA (staging)
- Test disse rutene manuelt i staging:
- `/pricing` → klikk alle planer
- `/app/settings` → endre plan + compounding → lagre
- `/app/dashboard` → last signaler + approve/reject
- `/kalkulator` → endre startbeløp/slider/plan
- `/opplaering?quiz=start`

## 6) Publiseringssteg (staging → prod)
1. Publiser Webflow til staging-domene.
2. Kjør smoke-test (seksjon 5).
3. Publiser til prod-domene.
4. Sjekk at caching ikke viser gammel JS (bruk cache-busting/purge ved behov).

## 7) Debug-tips
- Sett debug lokalt i browser:
  - `localStorage.setItem('klarpakke_debug', '1')` (reload)
  - `localStorage.removeItem('klarpakke_debug')` (reload)
- Når noe ikke skjer: sjekk Console for warnings om manglende IDs.
