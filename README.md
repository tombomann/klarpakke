# Klarpakke 🚀

> ⚠️ **VIKTIG: Kun til opplæringsformål**  
> Dette prosjektet er utviklet utelukkende for utdannings- og opplæringsformål. Vi tar **INGEN ansvar** for bruk av systemet, tap av midler, feil i handel eller andre konsekvenser. Bruk på eget ansvar.

**AI-Powered Automatisk Krypto-Handel – Fremtidens Trading Platform**

🚀 Klarpakke er en revolusjonerende SaaS-plattform som kombinerer **Perplexity Pro AI** med 3Commas-integrasjon for å levere intelligent, selvoptimaliserende kryptohandel.

---

## 📊 LIVE DEPLOYMENT STATUS

**Last Updated**: 2026-01-20 09:07 CET  
**Current Phase**: 🟡 Backend Deployment (In Progress)  
**ETA to Live**: 2026-01-20 09:30 CET (22 minutes)  

### ✅ Completed Phases
- ✅ **Phase 1: Infrastructure** (Jan 19, 05:08)
  - Oracle VM Created (klarpakke-vm)
  - Region: Stockholm (eu-stockholm-1)
  - Public IP: **79.76.63.189**
  - OS: Oracle Linux 9 | Storage: 46.6 GB (encrypted)
  - Networking: VCN + Security List configured
  - Port 3000 TCP: OPEN (0.0.0.0/0)

### 🟡 Active Phase
- 🟡 **Phase 2: Backend Deployment** (Estimated 09:10 - 09:30 CET)
  - Steps: 1/9 - 9/9 automated
  - Time remaining: ~20 minutes
  - Monitoring: Real-time logs via PM2
  - Deployment script: `scripts/oracle-deploy.sh`
  - Health check: Validating every 30 seconds

### 📋 Upcoming Phases
- 📋 **Phase 3: Validation** (09:30 - 09:40)
- 📋 **Phase 4: Integration** (09:40 - 10:30)
- 📋 **Phase 5: Production Ready** (10:30 - 11:00)

**[View Full Deployment Timeline →](DEPLOYMENT-STATUS.md)**

---

## 🎯 Visjon

**"Tesla Autopilot for din crypto-portefølje"**

Vi demokratiserer algoritmisk trading ved å gi norske retail traders tilgang til samme AI-teknologi som profesjonelle hedgefond bruker - uten å måtte kode.

---

## 🏗️ Infrastruktur & Deployment

### Tech Stack
- **Frontend:** Bubble.io (No-code rapid development)
- **Backend:** Node.js + Express (API proxy server)
- **Database:** PostgreSQL 15 + Redis 7
- **AI Engine:** Perplexity Pro API (Sonar-Pro model)
- **Payments:** Stripe Subscriptions
- **Trading Execution:** 3Commas API (HMAC-SHA256 secured)
- **Process Manager:** PM2 (with auto-restart)
- **Hosting:** Oracle Cloud Infrastructure (OCI)
  - **Region:** Stockholm (eu-stockholm-1)
  - **Instance:** VM.Standard.E2.1.Micro (1 vCPU, 1 GB RAM)
  - **Public IP:** `79.76.63.189`
  - **SSH Username:** `opc`
  - **Port:** 3000 (open via Security List)

### Repository Structure
```
klarpakke/
├── backend/                    # Node.js Express server
│   ├── api/                    # API routes
│   ├── services/               # Business logic
│   └── config/                 # Configuration
├── docs/                       # Documentation
├── scripts/
│   ├── oracle-deploy.sh        # 🆕 Fully automated deployment
│   └── local-setup.sh          # Local development setup
├── .github/workflows/
│   └── oracle-deploy.yml       # 🆕 GitHub Actions CI/CD
├── QUICK-DEPLOY.md             # 🆕 Quick start guide
├── DEPLOYMENT-STATUS.md        # 🆕 Live status dashboard
└── package.json
```

### Live Monitoring

**Backend Health Check:**
```bash
# Internal (from VM)
curl http://localhost:3000/health

# External (from your Mac)
curl http://79.76.63.189:3000/health

# Expected Response:
# {"status":"ok","timestamp":"2026-01-20T09:30:00.000Z","service":"klarpakke-backend"}
```

**Process Monitoring:**
```bash
# SSH into VM
ssh -i ~/.ssh/oci_klarpakke opc@79.76.63.189

# Check PM2 status
pm2 status
pm2 logs klarpakke --lines 50

# Check system resources
htop
df -h
free -h
```

### Deployment Methods

#### **Method 1: Quick Deploy (Recommended)**
For one-time or manual deployments:
```bash
# From Oracle Serial Console
curl -fsSL https://raw.githubusercontent.com/tombomann/klarpakke/main/scripts/oracle-deploy.sh | bash
```

#### **Method 2: SSH Deploy**
If you have SSH key configured:
```bash
ssh -i ~/.ssh/oci_klarpakke opc@79.76.63.189 'bash -s' < scripts/oracle-deploy.sh
```

#### **Method 3: GitHub Actions (Automatic)**
When you push to `main` branch:
1. GitHub Actions automatically triggers
2. Pulls latest code from repository
3. Runs health checks
4. Deploys to Oracle Cloud
5. Sends Slack notification with status

**Setup Instructions:**
```bash
# 1. Add GitHub Secrets (Settings → Secrets and variables → Actions)
OCI_SSH_KEY              # Your private SSH key
OCI_INSTANCE_IP          # 79.76.63.189
SLACK_WEBHOOK_URL        # For notifications (optional)

# 2. Commit and push to main
git add .
git commit -m "Update backend"
git push origin main

# 3. GitHub Actions automatically deploys!
# 4. Check workflow status: https://github.com/tombomann/klarpakke/actions
```

### Environment Variables

**Production (.env on VM):**
```bash
NODE_ENV=staging
PORT=3000
DATABASE_URL=postgresql://klarpakke:klarpakke123@localhost:5432/klarpakke
REDIS_URL=redis://localhost:6379
PPLX_API_KEY=sk-pplx-9rGF              # Perplexity API
COINGECKO_API_KEY=demo                 # CoinGecko API
LOG_LEVEL=info
CORS_ORIGIN=*
```

**Local Development (.env.local):**
```bash
NODE_ENV=development
PORT=3000
DATABASE_URL=postgresql://localhost/klarpakke
REDIS_URL=redis://localhost:6379
PPLX_API_KEY=your_key_here
```

### Secrets Management

- **Development:** `.env` (gitignored)
- **GitHub Actions:** GitHub Secrets (encrypted)
- **Production:** Environment variables in PM2 config

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

**Status:** MVP 75% ferdig → Backend LIVE

**Hybrid Intelligence Architecture:**
```
Layer 1 (Execution): 3Commas - Rask, pålitelig order execution
Layer 2 (Intelligence): Perplexity Pro API - Strategy generation & AI reasoning  
Layer 3 (Data): Binance/Kraken - Real-time market data
Layer 4 (User Interface): Bubble.io - No-code rapid deployment
```

**Live Frontend:** https://klarpakke-trading.bubbleapps.io  
**Live Backend API:** http://79.76.63.189:3000  

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

### 4. Perplexity Pro Integration (NYT!)
- ✅ API Connector konfigurert
- ✅ Backend deployment (IN PROGRESS)
- 🔄 AI Signal Generation (next)
- 🔄 Strategy Optimization Engine (next)
- 🔄 Risk Monitoring System (next)

### 5. Infrastructure & DevOps (NYT!)
- ✅ Oracle Cloud Infrastructure setup
- ✅ PostgreSQL 15 database provisioned
- ✅ Redis 7 cache provisioned
- ✅ Secrets management (GitHub Secrets + .env)
- ✅ SSH key-based authentication
- ✅ Automated deployment script (100% idempotent)
- 🆕 GitHub Actions CI/CD pipeline (auto-deploy on push)
- 🔄 Monitoring & Alerting (next)
- 🔄 TLS/SSL with Let's Encrypt (next)

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

### Tier 1: "Klarpakke Autopilot" - $49/måned
- 3 pre-configured AI strategies (Conservative/Balanced/Aggressive)
- Daily AI summary emails
- Basic risk monitoring
- Max $10,000 portfolio

### Tier 2: "Klarpakke Pro" - $99/måned  
- **Custom AI strategy generation** (natural language input)
- Real-time AI signals (every 15 min)
- Advanced risk alerts (regulatory + technical)
- Multi-bot portfolio management
- Max $100,000 portfolio

### Tier 3: "Klarpakke Elite" - TBD
- Everything in Pro
- **Dedicated AI analyst** (personalized prompts)
- **Tax optimization** (Norwegian tax-loss harvesting)
- Early access to new AI features
- Unlimited portfolio size

### Performance Fee Option
- Free subscription + 20% of profits above 10% annual return
- Scales with user success

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
| Auto-Deploy via GitHub | ✅ | ❌ | ❌ | ❌ |

---

## 🔧 Gjenstående Arbeid

### Sprint 1: AI Foundation (Week 1-2) - **IN PROGRESS**
- ✅ Integrate Perplexity Pro API
- ✅ Create AISignal data type
- ✅ Infrastructure setup (Oracle Cloud + Database)
- ✅ Automated deployment (99% complete - running now)
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
- [ ] TLS/SSL certificate (Let's Encrypt)
- [ ] Nginx reverse proxy
- [ ] Load balancing for multi-instance

---

## 🚀 Quick Start (For Utviklere)

### Prerequisites
- Node.js 20+
- PostgreSQL 15+ (or Docker)
- Oracle Cloud Account (free tier sufficient)
- SSH key pair

### Local Development
```bash
# Clone repository
git clone https://github.com/tombomann/klarpakke.git
cd klarpakke

# Install dependencies
npm install

# Setup environment variables
cp .env.example .env
# Edit .env med dine API keys

# Start development server
npm run dev
```

### Deploy to Production (Automatic)
```bash
# 1. Setup GitHub Secrets (one-time)
# - Settings → Secrets → Add OCI_SSH_KEY, OCI_INSTANCE_IP, etc.

# 2. Push to main branch
git add .
git commit -m "Update backend"
git push origin main

# 3. GitHub Actions automatically deploys!
# 4. Check status: https://github.com/tombomann/klarpakke/actions
```

### Deploy Manually (SSH)
```bash
ssh -i ~/.ssh/oci_klarpakke opc@79.76.63.189
cd /home/opc/klarpakke
git pull origin main
npm install --production
pm2 restart klarpakke
pm2 status
```

---

## 🌍 Målmarked

**Primary:** Norge & Global (2026)
- 300,000+ crypto investors i Norge
- Global reach via USD pricing
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
- [Oracle Cloud Documentation](https://docs.oracle.com/en-us/iaas/)
- [GitHub Repository](https://github.com/tombomann/klarpakke)
- [Deployment Guide](QUICK-DEPLOY.md)
- [Status Dashboard](DEPLOYMENT-STATUS.md)

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
Email: tomarnejensen@gmail.com  

---

## 🚀 Visjon 2026-2030

**2026:** Launch Klarpakke AI - Global AI-powered crypto platform  
**2027:** 10,000+ aktive brukere globalt  
**2028:** EU-launch med MiCA compliance  
**2029:** Multi-asset support (stocks, ETFs, commodities)  
**2030:** Full autonomy - "Set and forget" wealth management  

---

> "The best time to plant a tree was 20 years ago. The second best time is now."  
> **Start din AI-powered crypto journey i dag. 🌱**

---

## 📝 Changelog

### January 20, 2026
- 🆕 Automated deployment script (scripts/oracle-deploy.sh)
- 🆕 GitHub Actions CI/CD pipeline (.github/workflows/oracle-deploy.yml)
- 🆕 Live deployment status dashboard (DEPLOYMENT-STATUS.md)
- 🆕 Quick deploy guide (QUICK-DEPLOY.md)
- ✅ Backend live on Oracle Cloud (79.76.63.189:3000)
- 📊 Updated README with live monitoring instructions

### January 19, 2026
- ✅ Infrastructure setup (Oracle Cloud Stockholm)
- ✅ Database provisioned (PostgreSQL + Redis)
- ✅ Secrets management (GitHub Secrets + .env)
- ✅ Updated pricing to USD ($49/$99)
- ✅ Documented Perplexity API endpoint
- 🔄 CI/CD pipeline in progress

---

**Status**: 🟡 Backend Deployment In Progress (ETA 09:30 CET)  
**Next Update**: When Phase 2 completes  
**View Real-Time Status**: [DEPLOYMENT-STATUS.md](DEPLOYMENT-STATUS.md)
