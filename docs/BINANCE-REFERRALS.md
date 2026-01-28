# Binance referrals / affiliate (Klarpakke)

Dette dokumentet beskriver hvor dere logger inn for å administrere referrals/affiliate-inntekter på Binance, og hvordan dere setter opp Klarpakke slik at referral-lenken kan brukes konsistent i Webflow + app uten manuell copy/paste.

## Hvor du logger inn (for å tjene penger)

1. Logg inn på Binance-kontoen som skal være “referrer”.
2. Gå til Referral/Referral Pro dashboard fra profilen din.
3. Der genererer/administrerer du referral-link og kan se statistikk/commission.

Nyttige innganger:
- Referral: https://www.binance.com/en/activity/referral
- Affiliate program: https://www.binance.com/en/events/affiliate

## 1-click config (GitHub → Supabase → Webflow)

**Mål:** Ikke hardkode referral-lenker i Webflow Designer.

Flyt:
1. Legg referral-config i GitHub Actions Secrets eller `.env` lokalt.
2. Deploy (CI/CD eller `npm run deploy:backend`) skyver config inn i Supabase Edge Function secrets.
3. `public-config` Edge Function eksponerer kun “public” runtime config (inkl. referral URL) til frontend.
4. `web/klarpakke-site.js` henter config og “wires” alle Binance-CTA’er automatisk.

## Webflow: marker CTA’er (ingen lenker)

For å koble en knapp/lenke til Binance referral automatisk:
- Legg attribute på elementet: `data-kp-ref="binance"`
- (Valgfritt) styr target: `data-kp-ref-target="_blank"` eller `_self`

Da setter Klarpakke-scriptet `href` på `<a>` eller click-handler på `<button>` automatisk.

## Secrets / variabler (navn)

Legg disse inn i GitHub Secrets (Actions secrets) eller i `.env` lokalt:

- `BINANCE_REFERRAL_URL` (hele referral-lenken)
- `BINANCE_REFERRAL_CODE` (valgfritt)
- `BINANCE_AFFILIATE_ID` (valgfritt)

Ved deploy settes de som Supabase Edge Function secrets automatisk via `scripts/deploy-backend.sh`.

> Merk: Dette dokumentet setter opp referral-sporet (marketing). Bruker-spesifikke Binance API keys (for trading) må håndteres per bruker og skal ikke lagres som globale environment variables.
