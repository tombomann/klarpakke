# Webflow Manual Deployment Guide 🎓

Denne guiden er for manuell oppdatering av Webflow-koden hvis automasjonsscriptene ikke kan brukes.

## ⚠️ KRITISK REGEL: `<script>` Tags

Webflow "Custom Code" bokser forventer **HTML**.
Hvis du skal lime inn JavaScript, **MÅ** du pakke det inn i script-tags.

**GALT (Vises som tekst på siden):**
```javascript
console.log('Hei');
```

**RIKTIG (Kjører som kode):**
```html
<script>
  console.log('Hei');
</script>
```

---

## Anbefalt: auto-deploy via GitHub Actions

Hvis dere har Webflow API token kan dere slippe manual steps helt.

Se: `docs/WEBFLOW-AUTODEPLOY.md`.

---

## Anbefalt fallback: én liten loader (alt automatisk)

Hvis dere ikke vil bruke GitHub Actions/Secrets, kan dere fortsatt minimere copy/paste ved å lime inn **kun en liten loader** i Project Settings.

1. Åpne `web/snippets/webflow-footer-loader.html` i repo.
2. Kopier innholdet.
3. Webflow Designer → Project Settings → Custom Code → **Footer Code (Before </body>)**.
4. Lim inn, lagre og publiser.
5. Bytt placeholder `YOUR_PROJECT_REF` og `YOUR_SUPABASE_ANON_KEY`.

**Viktig:** aldri legg `SUPABASE_SERVICE_ROLE_KEY` i Webflow/klientkode.

---

## Krav per side (IDs)

Sørg for at disse ID-ene finnes i Webflow, ellers vil scriptet ikke kunne koble seg på UI:

- Dashboard (`/app/dashboard`): `#signals-container`
- Settings (`/app/settings`): `#save-settings`, `#plan-select`, `#compound-toggle`
- Pricing (`/app/pricing`): knapper med `data-plan="paper|safe|pro|extrem"`
- Kalkulator (`/kalkulator`): `#calc-start`, `#calc-crypto-percent`, `#calc-plan`, `#calc-result-table` (valgfritt: `#crypto-percent-label`)

---

## Alternativ: full manuell liming (legacy)

Hvis du av en eller annen grunn ikke kan bruke loaderen:

### 1. Site-wide (klarpakke-site.js)
1. Kopier `web/klarpakke-site.js`.
2. Project Settings → Custom Code → Footer Code.
3. Pakk inn i `<script> ... </script>`.
4. Save & Publish.

### 2. Kalkulator (calculator.js)
1. Kopier `web/calculator.js`.
2. På siden `/kalkulator`: Page Settings → Custom Code → Before `</body>`.
3. Pakk inn i `<script> ... </script>`.
4. Publish.

---

## Feilsøking

| Symptom | Årsak | Løsning |
|---------|-------|---------|
| **Koden vises som tekst på nettsiden** | Mangler `<script>` tags | Legg til `<script>` før og `</script>` etter koden. |
| **Ingenting skjer (Dashboard er tomt)** | Mangler IDs / feil config / API-feil | Sjekk Console (F12) for feilmeldinger og verifiser at siden har forventede element-IDs. |
| **Gamle elementer vises fortsatt** | Caching / Gammel kode | Hard refresh / incognito, og sjekk at du ikke har limt inn kode på enkeltsider (Page Settings) også. |
