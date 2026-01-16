# Klarpakke

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

## ⚙️ Konfigurasjon

### Stripe API Keys (Test Mode)

**Publishable Key:**
```
pk_test_51R4MjaCGsVawsLofv0qTRGKFzrPApoJzP7R6Npdu99eZLnZoimMXC2Vb5ux0ofG6q1K04Itec8A9lzslmPMxuyFE00g4iaeWdo
```

**Secret Key:**
```
sk_test_51R4MjaCGsVawsLofxGRjAnDDNElqd02WeELt2nsIDeI82MSWH6vRG7pJ1FuYETQPF1luuGMJzNChsbjBfwkhKpys00Acz0azoR
```

### Stripe Product IDs

- **Starter:** `price_1SpvkLCGsVawsLofNjLLs5X1` (0 NOK)
- **Autopakke:** `price_1SpvlaCGsVawsLofrrQxZqlr` (499 NOK)
- **Proffpakke:** `price_1Spvn5CGsVawsLofmVgWa7vJ` (999 NOK)

### 3Commas API (kommer snart)

**Environment Variables i Bubble:**
```
COMMAS_API_KEY=[din 3Commas API key]
COMMAS_API_SECRET=[din 3Commas secret]
```

**Hent keys fra:** https://3commas.io/api_access_tokens

---

## 🚧 Under Utvikling

### Dashboard
- ⏳ 3Commas OAuth connection
- ⏳ Bot-status visning (Repeating Group)
- ⏳ Real-time trading data

### Landing Page
- ⏳ Webflow integration (klarpakke.no)
- ⏳ Hero-seksjon med CTA
- ⏳ Pricing cards

---

## 📋 Testing

### Stripe Test Card

**Kortnummer:** `4242 4242 4242 4242`  
**Dato:** `12/26` (eller hvilken som helst fremtidig)  
**CVC:** `123`

### Test Workflow

1. Gå til https://tom-58107.bubbleapps.io
2. Registrer bruker: `test@klarpakke.no` / `TestPass123`
3. Gå til `/fakturering`
4. Klikk "Velg Autopakke"
5. Fyll inn Stripe test card
6. Sjekk at `subscription_tier = "autopakke"` i database

---

## 📊 Database Schema

### User
```
id: unique id
email: text
password_hash: password (Bubble-encrypted)
subscription_tier: text ("starter"|"autopakke"|"proff")
subscription_active: yes/no
stripe_customer_id: text
threecommas_api_token: text (encrypted)
threecommas_connected: yes/no
threecommas_account_id: text
created_at: date
```

---

## 🎯 Roadmap

### Uke 2 (Jan 16-22, 2026)
- [x] Stripe Checkout Session
- [x] Pricing cards
- [x] 3Commas proxy backend
- [ ] 3Commas OAuth flow
- [ ] Dashboard bot-data visning

### Uke 3 (Jan 23-29, 2026)
- [ ] Webflow landing page
- [ ] Beta-lansering (5-10 brukere)
- [ ] Feedback-loop

### Uke 4 (Jan 30 - Feb 5, 2026)
- [ ] Offentlig lansering
- [ ] Referral-system (Rewardful)
- [ ] Make.com automation

---

## 🔒 Sikkerhet

- ✅ API-nøkler kryptert i Bubble database
- ✅ Stripe webhooks for subscription-oppdatering
- ✅ 3Commas HMAC-SHA256 signering
- ✅ Ingen uttaks-tilgang på API-nøkler
- ✅ Read-only 3Commas permissions

---

## 📞 Kontakt

**Utvikler:** Tom Bomann  
**E-post:** [kontakt via GitHub]

---

## 📜 Lisens

Privat prosjekt – Ikke open source

---

**Sist oppdatert:** 16. januar 2026, kl 04:00 CET
