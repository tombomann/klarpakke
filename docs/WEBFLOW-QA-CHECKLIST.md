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
