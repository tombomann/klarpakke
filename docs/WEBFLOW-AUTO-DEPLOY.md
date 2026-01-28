# 🤖 Webflow Automatic Deployment

## ✨ Hva er Dette?

Webflow-integrasjonen er nå **100% automatisert**! Når du pusher kode til `main`-branchen, skjer dette automatisk:

1. ✅ Bygger web assets (`klarpakke-site.js`, `calculator.js`)
2. ✅ Laster dem opp til CDN (jsDelivr)
3. ✅ Oppdaterer Webflow Custom Code via API
4. ✅ Publiserer Webflow-siten

**Du trenger IKKE å kopiere/lime inn kode i Webflow manuelt lenger!**

---

## 🚀 Quick Start

### **Steg 1: Sett GitHub Secrets** (én gang)

GitHub Secrets må settes før automatisk deploy fungerer:

```bash
cd ~/klarpakke

# Webflow secrets
grep "^WEBFLOW_API_TOKEN=" .env | cut -d= -f2 | xargs echo -n | gh secret set WEBFLOW_API_TOKEN
grep "^WEBFLOW_SITE_ID=" .env | cut -d= -f2 | xargs echo -n | gh secret set WEBFLOW_SITE_ID

# Verifiser
gh secret list | grep WEBFLOW
```

### **Steg 2: Push Kode**

Alt annet skjer automatisk:

```bash
# Gjør endringer i web/klarpakke-site.js eller web/calculator.js
nano web/klarpakke-site.js

# Commit og push
git add .
git commit -m "✨ feat: oppdatert dashboard UI"
git push origin main

# Følg med på deploy
gh run watch
```

### **Steg 3: Verifiser**

Når workflow er ferdig:

1. Åpne Webflow-siten: `https://<WEBFLOW_SITE_ID>.webflow.io`
2. Åpne DevTools (F12) → Console
3. Du skal se:
   ```javascript
   [Klarpakke] Config loaded <commit-sha>
   [Klarpakke] Main script loaded
   ```

---

## 🛠️ Manuell Deploy (hvis nødvendig)

Hvis du vil deploye uten å pushe til GitHub:

```bash
cd ~/klarpakke

# Kjør det nye scriptet
bash scripts/auto-deploy-webflow.sh
```

Dette krever:
- `WEBFLOW_API_TOKEN` i `.env`
- `WEBFLOW_SITE_ID` i `.env`
- `SUPABASE_URL` og `SUPABASE_ANON_KEY` i `.env`
- `jq` installert (`brew install jq`)

---

## 📄 Hva GitHub Actions Gjør

### **Workflow Steg**

| Steg | Beskrivelse | Tid |
|------|-------------|-----|
| **1. Lint & Build** | Validerer JS syntax og bygger web bundles | ~20s |
| **2. Supabase Deploy** | Deployer database migrations og Edge Functions | ~30s |
| **3. Webflow Deploy** | ✨ **NYTT!** Automatisk deploy til Webflow | ~15s |
| **4. Health Check** | Tester at Supabase API fungerer | ~10s |
| **5. Notify** | Logger status | ~5s |

**Total tid:** ~80 sekunder fra push til Webflow er oppdatert 🚀

### **Webflow Deploy Detaljer**

GitHub Actions genererer et inline loader script som:

```html
<script>
// Auto-generert av GitHub Actions
window.KLARPAKKE_CONFIG = {
  supabaseUrl: 'https://swfyuwkptusceiouqlks.supabase.co',
  supabaseAnonKey: 'eyJ...',
  version: '<commit-sha>',
  debug: false
};

// Laster scripts fra CDN
const CDN_BASE = 'https://cdn.jsdelivr.net/gh/tombomann/klarpakke@<commit-sha>/web/dist';
// ... (resten av loader-koden)
</script>
```

Dette scriptet:
1. Setter `window.KLARPAKKE_CONFIG` med Supabase credentials
2. Laster `klarpakke-site.js` fra CDN
3. Laster `calculator.js` hvis bruker er på `/kalkulator`

---

## 🔧 Feilsøking

### **Problem: Workflow feiler på "Deploy to Webflow"**

**Årsak:** Manglende eller ugyldige Webflow secrets.

**Løsning:**
```bash
# Sjekk om secrets er satt
gh secret list | grep WEBFLOW

# Hvis mangler, sett dem:
echo "YOUR_WEBFLOW_API_TOKEN" | gh secret set WEBFLOW_API_TOKEN
echo "YOUR_WEBFLOW_SITE_ID" | gh secret set WEBFLOW_SITE_ID
```

### **Problem: "Custom Code updated" men ingen endringer på Webflow-siten**

**Årsak:** CDN caching. jsDelivr kan ta opptil 5 minutter å oppdatere.

**Løsning:**
1. **Vent 5 minutter** og refresh siden
2. ELLER bruk purge URL:
   ```bash
   curl https://purge.jsdelivr.net/gh/tombomann/klarpakke@main/web/dist/klarpakke-site.js
   ```

### **Problem: DevTools viser "Failed to load main script"**

**Årsak:** Feil commit SHA eller filen finnes ikke på CDN.

**Løsning:**
1. Sjekk om filen finnes:
   ```bash
   COMMIT_SHA=$(git rev-parse HEAD)
   curl -I "https://cdn.jsdelivr.net/gh/tombomann/klarpakke@${COMMIT_SHA}/web/dist/klarpakke-site.js"
   ```
2. Hvis du får 404: vent 2-3 minutter (GitHub + CDN sync)

### **Problem: "[Klarpakke] Config loaded" vises, men ingen UI-oppdateringer**

**Årsak:** Manglende element-IDer i Webflow.

**Løsning:**
1. Åpne `docs/WEBFLOW-MANUAL.md` for å se nødvendige element-IDer
2. Eksempel for Dashboard:
   - `#signals-container` må eksistere for å vise trading signals
   - `#user-profile` må eksistere for å vise brukernavn

---

## 👀 Monitorering

### **Sjekk Siste Deploy**

```bash
# Se siste workflow-kjøring
gh run list --workflow=auto-deploy.yml --limit 1

# Last ned Webflow-summary
gh run download $(gh run list --workflow=auto-deploy.yml --limit 1 --json databaseId -q '.[0].databaseId') -n webflow-summary
cat webflow-summary.txt
```

### **Test Webflow Loader Manuelt**

Åpne DevTools Console på Webflow-siten og kjør:

```javascript
// Sjekk config
console.log(window.KLARPAKKE_CONFIG);

// Test Supabase connection
await window.supabase.from('profiles').select('*').limit(1);

// Sjekk hvilke scripts som er lastet
Array.from(document.scripts)
  .filter(s => s.src.includes('klarpakke'))
  .forEach(s => console.log(s.src));
```

---

## 🎓 Best Practices

### **1. Test Lokalt Først**

Bruk det manuelle scriptet for å teste uten å pushe:

```bash
# Test lokalt
bash scripts/auto-deploy-webflow.sh

# Hvis det fungerer, push til GitHub
git push origin main
```

### **2. Bruk Feature Branches**

Webflow auto-deploy kjører KUN på `main`-branchen:

```bash
# Arbeid på feature branch
git checkout -b feature/ny-kalkulator

# Gjør endringer og push
git push origin feature/ny-kalkulator

# INGEN Webflow deploy før merge til main
gh pr create --title "Ny kalkulator" --body "..."

# Etter merge til main: auto-deploy til Webflow
```

### **3. Overvåk CDN Cache**

Ved store oppdateringer, purge CDN manuelt:

```bash
COMMIT_SHA=$(git rev-parse HEAD)
curl https://purge.jsdelivr.net/gh/tombomann/klarpakke@${COMMIT_SHA}/web/dist/klarpakke-site.js
curl https://purge.jsdelivr.net/gh/tombomann/klarpakke@${COMMIT_SHA}/web/dist/calculator.js
```

---

## 📚 Relaterte Docs

- `docs/WEBFLOW-MANUAL.md` - Manuelle deploy-instruksjoner (backup)
- `docs/DESIGN.md` - UI/UX design guidelines
- `docs/COPY.md` - Copy/tekst for Webflow-sider
- `scripts/auto-deploy-webflow.sh` - Det manuelle deploy-scriptet

---

## ✨ Oppsummering

**Før:**
1. Rediger `web/klarpakke-site.js`
2. Bygg manuelt: `npm run build:web`
3. Åpne Webflow Designer
4. Kopier kode fra `web/dist/klarpakke-site.js`
5. Lim inn i Webflow Custom Code
6. Wrapper i `<script>` tags (ofte glemt!)
7. Publish manuelt

**Nå:**
1. Rediger `web/klarpakke-site.js`
2. `git push origin main`

🎉 **Det er alt!**
