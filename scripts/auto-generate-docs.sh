#!/bin/bash
set -euo pipefail

echo "🚀 Genererer Klarpakke dokumentasjon..."

# Opprett docs/WEBFLOW-SITEMAP.md
cat > docs/WEBFLOW-SITEMAP.md <<'SITEMAP'
# Klarpakke Webflow Sitemap + DOM Requirements

## Public Pages

### / (Landing)
**URL:** https://klarpakke.no/
**Required IDs:** Ingen
**Data Attributes:** data-kp-ref="binance"
**Scripts:** klarpakke-site.js

### /kalkulator
**URL:** https://klarpakke.no/kalkulator
**Required IDs:**
- calc-start (input number)
- calc-crypto-percent (range slider)
- calc-plan (select)
- calc-result-table (div)
- crypto-percent-label (optional)

### /opplaering
**URL:** https://klarpakke.no/opplaering
Copy: Se docs/COPY.md § /opplaering

### /risiko
**URL:** https://klarpakke.no/risiko
Copy: Se docs/COPY.md § /risiko

### /pricing
**URL:** https://klarpakke.no/pricing
**Data Attributes:** data-plan="paper|safe|pro|extrem"

## App Pages

### /app/dashboard
**Required IDs:**
- signals-container
- kp-toast

### /app/settings
**Required IDs:**
- plan-select
- compound-toggle
- save-settings
- kp-toast
SITEMAP

# Opprett docs/WEBFLOW-QA-CHECKLIST.md
cat > docs/WEBFLOW-QA-CHECKLIST.md <<'QA'
# Klarpakke Webflow QA Checklist

## Pre-Deploy
- [ ] Loader limt inn i Footer Code
- [ ] Ingen Code Embed i Navigator
- [ ] #kp-toast eksisterer globalt

## Per Side
### /kalkulator
- [ ] #calc-start (number input)
- [ ] #calc-crypto-percent (slider)
- [ ] #calc-plan (select)
- [ ] #calc-result-table (div)
- [ ] Slider oppdaterer tabell live
- [ ] Console: [Klarpakke] Calculator loaded

### /app/dashboard
- [ ] #signals-container eksisterer
- [ ] Viser "Laster signaler..." eller data
- [ ] Approve/Reject fungerer
- [ ] Toast viser norsk tekst

### /app/settings
- [ ] #plan-select dropdown
- [ ] #compound-toggle checkbox
- [ ] #save-settings button
- [ ] Lagring viser toast

### /pricing
- [ ] Alle knapper har data-plan attribute
- [ ] 4 planer vises (Paper, SAFE, PRO, EXTREM)
- [ ] Routing fungerer på klikk

## Browser Testing
- [ ] Chrome (latest)
- [ ] Safari (latest)
- [ ] Mobile iOS/Android
QA

# Opprett docs/WEBFLOW-ELEMENT-IDS.md
cat > docs/WEBFLOW-ELEMENT-IDS.md <<'IDS'
# Webflow Element IDs - Quick Reference

## Global (All Pages)
- kp-toast → Fixed div, bottom-right, display:none default

## /kalkulator
- calc-start → Input (type=number, default=5000)
- calc-crypto-percent → Input (type=range, 0-100, default=50)
- calc-plan → Select (paper|safe|pro|extrem)
- calc-result-table → Div (empty, filled by JS)
- crypto-percent-label → Span (shows "50%")

## /app/dashboard
- signals-container → Div (filled with signal cards)

## /app/settings
- plan-select → Select dropdown
- compound-toggle → Checkbox (checked=true)
- save-settings → Button
IDS

echo "✅ docs/WEBFLOW-SITEMAP.md"
echo "✅ docs/WEBFLOW-QA-CHECKLIST.md"
echo "✅ docs/WEBFLOW-ELEMENT-IDS.md"
echo ""
echo "📋 Filer opprettet i docs/"
