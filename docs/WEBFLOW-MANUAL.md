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

## Steg-for-Steg Deploy

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
| **Ingenting skjer (Dashboard er tomt)** | Feil passord / API-feil | Sjekk Console (F12) for røde feilmeldinger. |
| **Gamle elementer vises fortsatt** | Caching / Gammel kode | Sjekk om du har limt inn kode på *enkeltsider* (Page Settings) også. Slett den, bruk kun Project Settings. |
