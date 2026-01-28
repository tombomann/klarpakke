# Webflow API v2 Migration Guide

## Status

✅ **Workflow oppdatert**: Auto-deploy pipeline støtter nå både v2 og v1 API automatisk  
⚠️ **Anbefaling**: Oppgrader til v2 Site Token så snart som mulig

---

## Hvorfor migrere til v2?

Webflow API v1 er **deprecated** og vil fases ut. v2 gir:
- 🔒 **Bedre sikkerhet** med granulerte scopes
- 🚀 **Flere features** (custom code, pages, assets)
- 🛡️ **Fremtidssikret** integrasjon

Mer info: [Webflow v2 Migration Docs](https://developers.webflow.com/data/docs/migrating-to-v2)

---

## Hvordan migrere (5 min)

### Steg 1: Generer nytt v2 Site Token

1. Åpne [Webflow Dashboard](https://webflow.com/dashboard)
2. Velg ditt site
3. Gå til **Settings → Apps & Integrations → API access**
4. Sjekk eksisterende tokens:
   - Tokens med "⚠️ legacy API warning" er v1-tokens
   - Noter "Last used" dato for å se om de brukes aktivt

5. **Generer nytt token**:
   - Klikk **Generate API Token**
   - Velg nødvendige permissions (scopes):
     - ✅ `sites:read`
     - ✅ `sites:write`
     - ✅ `custom_code:read`
     - ✅ `custom_code:write`
     - ✅ `pages:read` (anbefalt)
     - ✅ `pages:write` (anbefalt)
   - Gi token et beskrivende navn: **"GitHub Actions CI/CD"**
   - **Kopier token** (vises kun én gang!)

### Steg 2: Oppdater GitHub Secret

#### Via CLI:
```bash
gh secret set WEBFLOW_API_TOKEN
# Paste v2 token når promptet dukker opp
```

#### Via GitHub UI:
1. Gå til **Settings → Secrets and variables → Actions**
2. Klikk **WEBFLOW_API_TOKEN** → **Update secret**
3. Lim inn det nye v2 tokenet
4. Klikk **Update secret**

### Steg 3: Verifiser at det fungerer

Trigger en ny deploy:
```bash
# Push en liten endring
git commit --allow-empty -m "chore: test Webflow v2 API"
git push origin main

# Følg med på workflow
gh run watch
```

Sjekk loggen for:
```
✅ Custom Code updated via API v2
✅ Site published (v2) at: 2026-01-28T...
```

I stedet for:
```
✅ Custom Code updated via API v1 (legacy)
⚠️  RECOMMENDATION: Migrate to v2 Site Token
```

### Steg 4: Rydd opp (valgfritt)

Når v2 fungerer:
1. Gå tilbake til Webflow → **API access**
2. Slett gamle v1 tokens som ikke lenger brukes
3. Behold bare det nye v2 tokenet

---

## Hva skjer hvis jeg ikke migrerer?

### Kortsiktig (nå)
✅ **Alt fungerer fortsatt!**
- Workflow faller automatisk tilbake til v1 API
- Du får en advarsel i loggen
- Ingen nedetid eller problemer

### Langsiktig (Webflow's deprecation timeline)
❌ **v1 API vil slutte å fungere**
- Webflow har annonsert deprecation av v1
- Nøyaktig dato er ikke satt enda
- Anbefalt å migrere før det blir tvunget

---

## Feilsøking

### Problem: Får fortsatt v1-advarsel etter oppdatering

**Årsak**: Du har limt inn et v1 token i stedet for v2

**Løsning**:
1. Gå tilbake til Webflow API access
2. Sjekk at tokenet du genererte **ikke** har legacy-advarselen
3. Generer et nytt v2 token hvis nødvendig
4. Oppdater GitHub Secret igjen

### Problem: Får 403 Forbidden med v2 token

**Årsak**: Token mangler nødvendige scopes

**Løsning**:
1. Slett tokenet i Webflow
2. Generer nytt med **alle** disse scopene:
   - `sites:read`
   - `sites:write`
   - `custom_code:read`
   - `custom_code:write`
3. Oppdater GitHub Secret

### Problem: Finner ikke WEBFLOW_SITE_ID

**Hent site ID via API**:
```bash
# Erstatt YOUR_V2_TOKEN med ditt nye token
curl -s "https://api.webflow.com/v2/sites" \
  -H "Authorization: Bearer YOUR_V2_TOKEN" \
  | jq -r '.sites[] | "\(.displayName): \(.id)"'
```

**Oppdater GitHub Secret**:
```bash
gh secret set WEBFLOW_SITE_ID
# Paste riktig site ID
```

---

## Teknisk dokumentasjon

### Hva endret seg i workflow?

Workflow (`.github/workflows/auto-deploy.yml`) prøver nå:

1. **Først**: v2 API endepunkt
   ```bash
   PUT https://api.webflow.com/v2/sites/{SITE_ID}/custom_code
   ```

2. **Hvis 401/403**: Automatisk fallback til v1
   ```bash
   PUT https://api.webflow.com/sites/{SITE_ID}/custom-code
   Header: accept-version: 1.0.0
   ```

3. **Logger hvilken versjon som ble brukt**

### API-forskjeller

#### v2 API (ny)
```json
{
  "scripts": [
    {
      "location": "footer",
      "code": "<script>...</script>"
    }
  ]
}
```

#### v1 API (legacy)
```json
{
  "customCode": {
    "footer": "<script>...</script>"
  }
}
```

---

## Referanser

- [Webflow v2 Migration Guide](https://developers.webflow.com/data/docs/migrating-to-v2)
- [Webflow v2 API Reference](https://developers.webflow.com/data/reference)
- [Site Tokens Guide](https://developers.webflow.com/data/docs/site-tokens)
- [Webflow API v1 Deprecation Notice](https://developers.webflow.com/data/docs/api-v1-deprecation)

---

## Kontakt

Spørsmål om migrasjonen?
- Sjekk workflow logs: `gh run view --log`
- Åpne issue i repo: [klarpakke/issues](https://github.com/tombomann/klarpakke/issues)
- Webflow support: developers@webflow.com
