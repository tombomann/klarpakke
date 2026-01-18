# Klarpakke 🚀

> ⚠️ **VIKTIG: Kun til opplæringsformål**  
> Dette prosjektet er utviklet utelukkende for utdannings- og opplæringsformål. Vi tar **INGEN ansvar** for bruk av systemet, tap av midler, feil i handel eller andre konsekvenser. Bruk på eget ansvar.

**AI-Powered Automatisk Krypto-Handel – Fremtidens Trading Platform**

🚀 Klarpakke er en revolusjonerende SaaS-plattform som kombinerer **Perplexity Pro AI** med 3Commas-integrasjon for å levere intelligent, selvoptimaliserende kryptohandel.

---

## 🎯 Visjon

**"Tesla Autopilot for din crypto-portefølje"**

Vi demokratiserer algoritmisk trading ved å gi norske retail traders tilgang til samme AI-teknologi som profesjonelle hedgefond bruker - uten å måtte kode.

---

## 🧠 Hvorfor Klarpakke > Tradisjonelle Trading Bots

### Traditional Bots (3Commas/Freqtrade)
- ❌ Statiske algoritmer
- ❌ Ingen tilpasning til markedsregime
- ❌ Krever manuelle justeringer
- ❌ Ignorerer news/sentiment

### Klarpakke AI-Powered System
- ✅ **Real-time AI reasoning** over hele markedet
- ✅ **Context-aware beslutninger** (news, sentiment, on-chain data)
- ✅ **Natural language strategy generation**
- ✅ **Kontinuerlig læring og optimalisering**
- ✅ **Multi-modal analyse** (pris + fundamentals + sentiment)
- ✅ **Automatisk risikostyring**

---

## 🎯 Oversikt

**Status:** MVP 70% ferdig → AI-integrasjon i gang

**Hybrid Intelligence Architecture:**
```
Layer 1 (Execution): 3Commas - Rask, pålitelig order execution
Layer 2 (Intelligence): Perplexity Pro API - Strategy generation & AI reasoning  
Layer 3 (Data): Binance/Kraken - Real-time market data
Layer 4 (User Interface): Bubble.io - No-code rapid deployment
```

**Tech Stack:**
- Frontend: Bubble.io (No-code)
- AI Brain: Perplexity Pro API (Sonar-Pro model)
- Betaling: Stripe Subscriptions
- Trading Execution: 3Commas API (via HMAC-SHA256 proxy)
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
  - **Autopilot:** 399 NOK/måned (AI pre-configured strategies)
  - **Pro:** 799 NOK/måned (Custom AI strategy generation)
  - **Elite:** 1,999 NOK/måned (Dedicated AI analyst)
- ✅ Stripe Checkout Session workflow
- ✅ Subscription tier lagret i User database

### 3. 3Commas Proxy
- ✅ Backend API workflow for HMAC-SHA256 signering
- ✅ Sikker proxy til 3Commas API
- ✅ Node.js server-side script

### 4. Perplexity Pro Integration (NY!)
- ✅ API Connector konfigurert
- 🔄 AI Signal Generation (under utvikling)
- 🔄 Strategy Optimization Engine (under utvikling)
- 🔄 Risk Monitoring System (under utvikling)

---

## 🤖 AI-Powered Trading System

### Hvordan AI-en Fungerer

**1. Morning Market Analysis** (06:00 CET):
```
Perplexity AI scanner:
- Overnight price movements (BTC/ETH)
- Regulatory news (SEC, Finanstilsynet)
- On-chain metrics (exchange reserves, whale activity)
- Social sentiment (Twitter/Reddit)
- Technical indicators (RSI, MACD, volume)

Output: Dagens trading strategy + risikojusteringer
```

**2. Intraday Monitoring** (Hver 15. min):
```
Real-time checks:
- Er price action aligned med forecast?
- Deviation >5% → Analyser årsak
- Automatic actions: Pause bots / Adjust targets / Size positions

Output: Buy/Hold/Sell signals med confidence score
```

**3. Evening Summary** (22:00 CET):
```
Dagens performance review:
- Total PnL
- Win rate
- Largest drawdown moment
- Actionable insights for i morgen

Output: User-friendly email summary
```

**4. Weekly Strategy Review** (Søndag):
```
Analyser siste 7 dager:
- Hvilke strategies outperformed?
- Er vi i trend-following eller mean-reversion regime?
- Anbefaling: Continue / Rotate / Reduce risk

Output: Strategy rotation plan
```

### Natural Language Strategy Generation

**Example User Input:**
> "Jeg vil ha en konservativ DCA-strategi for ETH, maks 5% portfolio risk, kjøp på dips over 7%"

**Perplexity AI Output:**
```json
{
  "strategy_type": "DCA",
  "entry_conditions": {
    "price_drop": "7% from 7-day MA",
    "volume_confirmation": ">1.2x average",
    "rsi_oversold": "<35"
  },
  "position_size": "2.5% of portfolio per entry",
  "max_exposure": "5% total",
  "take_profit": "3%, 5%, 8% levels",
  "stop_loss": "-12% from entry",
  "expected_return_30d": "8% ± 4%",
  "confidence_score": 82,
  "reasoning": "Conservative DCA on established asset (ETH). Entry on 7% dips captures mean reversion while avoiding fakeouts via volume filter. Max 5% exposure limits downside to -0.6% portfolio impact even in worst case."
}
```

---

## 💰 Prismodell (Optimalisert for AI-Era)

### Tier 1: "Klarpakke Autopilot" - 399 NOK/måned
- 3 pre-configured AI strategies (Conservative/Balanced/Aggressive)
- Daily AI summary emails
- Basic risk monitoring
- Max 50,000 NOK portfolio

### Tier 2: "Klarpakke Pro" - 799 NOK/måned  
- **Custom AI strategy generation** (natural language input)
- Real-time AI signals (every 15 min)
- Advanced risk alerts (regulatory + technical)
- Multi-bot portfolio management
- Max 500,000 NOK portfolio

### Tier 3: "Klarpakke Elite" - 1,999 NOK/måned
- Everything in Pro
- **Dedicated AI analyst** (personalized prompts)
- **Tax optimization** (Norwegian tax-loss harvesting)
- Early access to new AI features
- Unlimited portfolio size

### Performance Fee Option
- Free subscription + 20% of profits above 10% annual return
- Scales with user success

---

## 🏗️ Arkitektur & Database

### Data Types
1. **Bot** - Trading bot configurations
2. **Trade** - Individual trade history
3. **AISignal** - AI-generated market signals (NY!)
4. **Subscription** - Stripe subscription data
5. **User** - Authentication
6. **UserProfile** - Extended user data

### API Integrations
- ✅ Perplexity Pro (Sonar-Pro model)
- ✅ 3Commas (Bot execution)
- ✅ Stripe (Payments)
- ✅ Coinbase/Binance (Market data via 3Commas)

---

## 📈 Competitive Advantage

| Feature | Klarpakke AI | Cryptohopper | 3Commas | Freqtrade |
|---------|--------------|--------------|---------|----------|
| AI Strategy Generation | ✅ | ❌ | ❌ | ❌ |
| Real-time News Analysis | ✅ | ❌ | ❌ | ❌ |
| Natural Language Input | ✅ | ❌ | ❌ | ❌ |
| Continuous Optimization | ✅ | ⚠️ | ⚠️ | ❌ |
| No-Code Setup | ✅ | ✅ | ✅ | ❌ |
| Norwegian Tax Optimization | ✅ | ❌ | ❌ | ❌ |

---

## 🔧 Gjenstående Arbeid

### Sprint 1: AI Foundation (Week 1-2) - IN PROGRESS
- ✅ Integrate Perplexity Pro API
- ✅ Create AISignal data type (✅ JAN 18, 2026)
- 🔄 Build prompt template system
- 🔄 Test signal generation (>70% accuracy)


### Sprint 2: Strategy Generation (Week 3-4)
- [ ] Natural language strategy input UI
- [ ] Perplexity → 3Commas translator
- [ ] Backtesting simulation
- [ ] Strategy approval workflow

### Sprint 3: Risk & Monitoring (Week 5-6)  
- [ ] 15-min monitoring loop
- [ ] Alert system (email + in-app)
- [ ] Emergency stop-loss override
- [ ] Risk dashboard

### Sprint 4: Self-Improvement (Week 7-8)
- [ ] Track AI signal accuracy
- [ ] Meta-learning loop (optimize prompts)
- [ ] A/B testing framework
- [ ] Performance analytics

### Prioritet 2 (Post-MVP)
- [ ] Dashboard: Vise aktive bots fra 3Commas
- [ ] Multi-exchange support (Kraken, Coinbase direct)
- [ ] Norsk/Engelsk språkvalg
- [ ] Mobile app (iOS/Android)

---

## 🌍 Målmarked

**Primary:** Norge (2026)
- 300,000+ crypto investors
- Høy digital literacy
- Sterk demand for automated solutions

**Secondary:** Norden (2027)
- Sverige, Danmark, Finland
- Similar regulatory environment
- 2M+ potential users

**Tertiary:** EU (2028)
- MiCA-compliant from day 1
- 50M+ addressable market

---

## 📚 Opplæringsressurser

### For Brukere
- [3Commas Dokumentasjon](https://github.com/3commas-io/3commas-official-api-docs)
- [Skatteetaten: Kryptovaluta](https://www.skatteetaten.no/person/skatt/hjelp-til-riktig-skatt/aksjer-og-verdipapirer/kryptovaluta/)
- [Klarpakke YouTube Kanal](https://youtube.com/@klarpakke) (kommer snart)

### For Utviklere
- [Perplexity API Docs](https://docs.perplexity.ai/)
- [Bubble.io Manual](https://manual.bubble.io/)
- [Freqtrade Strategy Guide](https://www.freqtrade.io/en/stable/strategy-customization/)

---

## ⚖️ Ansvarsfraskrivelse

Dette systemet er **KUN** til utdannings- og opplæringsformål. Utviklerne tar **INGEN** ansvar for:

- 💸 Økonomisk tap fra trading
- 🤖 Feil i AI-genererte strategier  
- 🔧 Bot-konfigurasjonsfeil
- 📉 API-feil eller børs-nedetid
- 📊 Skattemessige konsekvenser
- 🔒 Sikkerhetshendelser

**Handel med kryptovaluta innebærer betydelig risiko.**  
Bruk kun midler du har råd til å tape.

AI-systemer er ikke ufeilbarlige. Alltid gjør din egen research (DYOR).

---

## 📜 Lisens

MIT License - Se LICENSE fil for detaljer.

---

## 👨‍💻 Utvikler

**Tom Bomann**  
GitHub: [@tombomann](https://github.com/tombomann)  
Twitter: [@tombomann](https://twitter.com/tombomann)

---

## 🚀 Visjon 2026-2030

**2026:** Launch Klarpakke AI - Norge's første AI-powered crypto platform  
**2027:** Ekspansjon Norden - 10,000+ aktive brukere  
**2028:** EU-launch med MiCA compliance  
**2029:** Multi-asset support (stocks, ETFs, commodities)  
**2030:** Full autonomy - "Set and forget" wealth management

---

> "The best time to plant a tree was 20 years ago. The second best time is now."  
> **Start din AI-powered crypto journey i dag. 🌱**
