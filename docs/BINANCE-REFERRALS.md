# Binance referrals / affiliate (Klarpakke)

Dette dokumentet beskriver hvor dere logger inn for å administrere referrals/affiliate-inntekter på Binance, og hvordan dere setter opp Klarpakke slik at referral-lenken kan brukes konsistent i Webflow + app uten manuell copy/paste.

## Hvor du logger inn (for å tjene penger)

1. Logg inn på Binance-kontoen som skal være “referrer”.
2. Gå til Referral/Referral Pro dashboard fra profilen din.
3. Der genererer/administrerer du referral-link og kan se statistikk/commission.

Nyttige innganger:
- Referral: https://www.binance.com/en/activity/referral
- Affiliate program: https://www.binance.com/en/events/affiliate

## Hvordan vi bruker referral-lenken i Klarpakke

**Mål:** Ikke hardkode referral-lenker i Webflow Designer (minimerer risiko for feil + “script som tekst”).

Anbefalt:
- Legg referral-lenken i GitHub Secrets (som en “config”-verdi)
- Deploy pipeline skyver den til Supabase Edge Function secrets
- Frontend bruker en Edge Function som returnerer “current referral url” (når vi implementerer den), slik at Webflow/JS alltid får riktig lenke.

## Secrets / variabler (navn)

Legg disse inn i GitHub Secrets (Actions secrets) eller i `.env` lokalt:

- `BINANCE_REFERRAL_URL` (hele referral-lenken)
- `BINANCE_REFERRAL_CODE` (valgfritt)
- `BINANCE_AFFILIATE_ID` (valgfritt)

Ved deploy settes de som Supabase Edge Function secrets automatisk via `scripts/deploy-backend.sh`.

> Merk: Dette dokumentet setter opp referral-sporet (marketing). Bruker-spesifikke Binance API keys (for trading) må håndteres per bruker og skal ikke lagres som globale environment variables.
