# 🚀 Klarpakke Webflow One-Click Deploy

## Setup (Kun én gang)

### Steg 1: Lim inn loader i Webflow

\`\`\`bash
cat ~/klarpakke/web/dist/webflow-loader.js | pbcopy
\`\`\`

**Deretter i Webflow:**
1. Åpne: https://webflow.com/dashboard/sites/klarpakke-c65071/designer
2. Klikk ⚙️ (Site settings) øverst til venstre  
3. Gå til **Custom Code**
4. Scroll ned til **Footer Code**
5. Lim inn (Cmd+V)
6. Klikk **Save**
7. Klikk **Publish** (oppe til høyre)

✅ **FERDIG!** Alle fremtidige oppdateringer skjer automatisk via jsDelivr CDN.

## Daglig utvikling

\`\`\`bash
# Gjør endringer i web/klarpakke-site.js eller calculator.js
git add .
git commit -m "feat: ny funksjonalitet"  
git push origin main

# ✅ CDN oppdateres automatisk innen 12 timer!
# 🔥 Force update: legg til ?v=TIMESTAMP i CDN URL
\`\`\`

## Test lokal

\`\`\`bash
cd ~/klarpakke
npm run build:web
open web/dist/klarpakke-site.js
\`\`\`

## Troubleshooting

**Problem:** Script laster ikke
- Sjekk Console (Cmd+Option+I): `[Klarpakke] Config loaded`
- Verifiser CDN: https://cdn.jsdelivr.net/gh/tombomann/klarpakke@main/web/dist/klarpakke-site.js
- Purge CDN: https://www.jsdelivr.com/tools/purge

**Problem:** Gamle endringer vises
- jsDelivr cache: 12 timer
- Force refresh: Cmd+Shift+R
- Eller bruk versjon-tag i URL
