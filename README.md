# Klarpakke

> ⚠️ **VIKTIG: Kun til opplæringsformål**  
> Dette prosjektet er utviklet utelukkende for utdannings- og opplæringsformål. Vi tar **INGEN ansvar** for bruk av systemet, tap av midler, feil i handel eller andre konsekvenser. Bruk på eget ansvar.

**Automatisk krypto-handel – Ferdig pakke for norske traders**

🚀 Klarpakke er en SaaS-plattform som automatiserer kryptohandel via 3Commas-integrasjon med Stripe-betalinger.

---

## 🎯 Oversikt

**Status:** MVP i utvikling (70% ferdig)

**Tech Stack:**
- Frontend: Bubble.io (No-code)
- Betaling: Stripe Subscriptions
- Trading: 3Commas API (via proxy)
- Hosting: Bubble Cloud

**Live URL:** https://tom-58107.bubbleapps.io

---

## ✅ Ferdigstilte Features

### 1. Autentisering
- ✅ E-post/passord signup
- ✅ Login workflow
- ✅ Passord reset (via e-post)

### 2. Stripe Subscriptions
- ✅ 3 prisnivåer:
  - **Starter:** 0 NOK/måned (gratis)
  - **Autopakke:** 499 NOK/måned
  - **Proffpakke:** 999 NOK/måned
- ✅ Stripe Checkout Session workflow
- ✅ Subscription tier lagret i User database

### 3. 3Commas Proxy
- ✅ Backend API workflow for HMAC-SHA256 signering
- ✅ Sikker proxy til 3Commas API
- ✅ Node.js server-side script

---

## 🤖 Anbefalt Trading Bot Setup

Basert på analyse av norske traders' behov:

### Trading Bots (Anbefalt)
1. **3Commas** (Primær)
   - DCA (Dollar Cost Averaging) bots
   - Grid trading bots
   - Smart trading terminal
   - Paper trading for testing

2. **Freqtrade** (Avansert alternativ)
   - Open-source Python bot
   - Full tilpasning
   - Krever teknisk kompetanse

### Kryptobørser for Norske Brukere

**Tier 1 (Anbefalt - Norsk Support):**
- ✅ **Binance** - Støtter NOK, høy likviditet
- ✅ **Coinbase Pro** - Regulert, enkel onboarding
- ✅ **Kraken** - EU-regulert, god norsk support

**Tier 2 (Avansert):**
- **Bitfinex** - Margin trading
- **KuCoin** - Mange altcoins
- **Gate.io** - DeFi tokens

### Norske Regulatoriske Krav
- Alle brukere må verifisere KYC (Know Your Customer)
- Skatterapportering: Krypto er skattepliktig i Norge
- Anbefalt: Bruk Cointracking.io eller Koinly for skatteberegning

---

## ⚙️ Konfigurasjon

### Stripe API Keys (Test Node)

**Publishable Key:**
```
pk_test_51QagqPRpKC2VGKdN9bWZYfN1QhxS5hN5w7vzQNe8vjx1S1kW9M3cLLzFvMq7sPGsqJQzPNnYi6GFVWI3PJ22AvZ800rOGN4nSI
```

**Secret Key:**
```
sk_test_51QagqPRpKC2VGKdN9rXhJB1F7tKZxB8EJVGqTKSYMH9UJ6tLCF8JqbqZKmwZhG6v5F5vZQXXJKLYWmH4UQQhMZX900KXW8e5qo
```

### 3Commas API
- API Key: Genereres i 3Commas dashboard
- Secret: Lagres kryptert i Bubble database
- Permissions: Read + Write for bot management

---

## 🔧 Gjenstående Arbeid

### Prioritet 1 (Kritisk)
- [ ] Fix 6 gjenstående Bubble issues (type mismatches i popups)
- [ ] Fullstendig 3Commas API-integrasjon
- [ ] Test Stripe webhook for subscription events

### Prioritet 2 (Viktig)
- [ ] Dashboard: Vise aktive bots fra 3Commas
- [ ] Bot-konfigurasjon UI
- [ ] Trade history view
- [ ] Performance analytics

### Prioritet 3 (Nice-to-have)
- [ ] Perplexity AI chat-integrasjon for kundestøtte
- [ ] Multi-exchange support
- [ ] Norsk/Engelsk språkvalg

---

## 📚 Opplæringsressurser

- [3Commas Dokumentasjon](https://github.com/3commas-io/3commas-official-api-docs)
- [Freqtrade Guide](https://www.freqtrade.io/)
- [Skatteetaten: Kryptovaluta](https://www.skatteetaten.no/person/skatt/hjelp-til-riktig-skatt/aksjer-og-verdipapirer/kryptovaluta/)

---

## ⚖️ Ansvarsfraskrivelse

Dette systemet er **KUN** til utdannings- og opplæringsformål. Utviklerne tar **INGEN** ansvar for:
- Økonomisk tap fra trading
- Feil i bot-konfigurasjon
- API-feil eller børs-nedetid
- Skattemessige konsekvenser
- Sikkerhetshendelser

Handel med kryptovaluta innebærer betydelig risiko. Bruk kun midler du har råd til å tape.

---

## 📄 Lisens

MIT License - Se LICENSE fil for detaljer.

## 👨‍💻 Utvikler

**Tom Bomann**  
GitHub: [@tombomann](https://github.com/tombomann)
