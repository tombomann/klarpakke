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

## Anbefalt: liten loader (ikke stor blob)

For å minimere copy/paste-feil og unngå at store scriptblokker blir til “tekst”, anbefaler vi å lime inn **kun en liten loader** i Project Settings. Den loader alltid siste versjon av `web/klarpakke-site.js` fra repo/CDN.

1. Åpne `web/snippets/webflow-footer-loader.html` i repo.
2. Kopier innholdet.
3. Webflow Designer → Project Settings → Custom Code → **Footer Code (Before </body>)**.
4. Lim inn, lagre og publiser.

**Viktig:** aldri legg `SUPABASE_SERVICE_ROLE_KEY` i Webflow/klientkode (den er kun for server/Edge Functions).

---

## Alternativ: full manuell liming (legacy)

### 1. Hent Koden
Koden for hele nettstedet (Forside + Dashboard) ligger i filen `web/klarpakke-site.js`.
Kopier alt innholdet fra denne filen.

### 2. Gå til Webflow Project Settings
1. Åpne Webflow Designer.
2. Klikk på **Webflow-logoen** (øverst til venstre) -> **Project Settings**.
3. Gå til fanen **Custom Code**.

### 3. Lim Inn (Footer Code)
1. Finn boksen merket **"Footer Code"** (Code before `</body>` tag).
2. Slett eventuelt gammelt innhold.
3. Skriv `<script>`
4. Lim inn koden din.
5. Skriv `</script>` etter koden.

Resultatet i boksen skal se slik ut:

```html
<script>
// Klarpakke Full Site Engine...
(function() {
  ... masse kode ...
})();
</script>
```

### 4. Publiser
1. Klikk grønn **Save Changes** knapp.
2. Klikk blå **Publish** knapp (øverst til høyre).
3. Vent til det står "Published successfully".

---

## Feilsøking

| Symptom | Årsak | Løsning |
|---------|-------|---------|
| **Koden vises som tekst på nettsiden** | Mangler `<script>` tags | Legg til `<script>` før og `</script>` etter koden. |
| **Ingenting skjer (Dashboard er tomt)** | Mangler IDs / feil config / API-feil | Sjekk Console (F12) for feilmeldinger og verifiser at siden har forventede element-IDs. |
| **Gamle elementer vises fortsatt** | Caching / Gammel kode | Hard refresh / incognito, og sjekk at du ikke har limt inn kode på enkeltsider (Page Settings) også. |
