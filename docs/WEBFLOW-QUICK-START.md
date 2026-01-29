# Webflow Quick Start

## STEG 1: Lim inn loader (5 min)
1. Åpne Webflow Designer
2. ⚙️ → Custom Code → Footer Code
3. Lim inn loader (ligger i clipboard)
4. Save

## STEG 2: Fjern Code Embed (2 min)
1. I Navigator: høyreklikk "Code Embed"
2. Delete
3. Bekreft

## STEG 3: Opprett sider (2 timer)
### /kalkulator - PRIORITET 1
- Add Page → Name: kalkulator, Slug: /kalkulator
- Legg til elementer med IDs (se docs/WEBFLOW-ELEMENT-IDS.md)
- Copy fra docs/COPY.md § /kalkulator

### /opplaering - PRIORITET 2
- Add Page → Name: opplaering, Slug: /opplaering
- Copy fra docs/COPY.md § /opplaering

### /risiko - PRIORITET 3
- Add Page → Name: risiko, Slug: /risiko
- Copy fra docs/COPY.md § /risiko

## STEG 4: Legg til IDs på eksisterende sider
### Dashboard:
- signals-container → Container for signal-kort
- kp-toast → Global feedback toast

### Settings:
- plan-select → Dropdown
- compound-toggle → Checkbox
- save-settings → Button

### Pricing:
- data-plan="paper" → Knapp 1
- data-plan="safe" → Knapp 2
- data-plan="pro" → Knapp 3
- data-plan="extrem" → Knapp 4

## STEG 5: Publiser
- Klikk Publish (oppe til høyre)
- Test i Console: [Klarpakke] Site Engine loaded

## TROUBLESHOOTING
- Kode vises som tekst? → Sjekk at den BARE ligger i Footer Code
- JS fungerer ikke? → Hard refresh (Cmd+Shift+R)
- Console errors? → Sjekk at alle IDs er korrekte
