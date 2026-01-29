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
