# KLARPAKKE V1: MASTER ARCHITECTURE & PRODUCTION SPEC

> **Status:** LOCKED FOR PRODUCTION (V1)  
> **Role:** Safety-First Trading System for Retail Investors  
> **Key Principle:** Survival > Profit

---

## 1. Forretningsmodell & Prising
Modellen følger industristandard (SaaS/Bot-plattform) med feature-gating basert på risiko og kompleksitet.

### Gratis (Education Mode)
*   **Formål:** Læring uten risiko. Ingen execution-risiko for bruker eller plattform.
*   **Innhold:** Akademi, Papir-portefølje (simulert), Ukentlig markedsrapport.
*   **Begrensning:** Ingen API-nøkler kan lagres. Ingen "live" handel.

### Pro — $49/mnd (Execution)
*   **Formål:** For brukeren som er klar, men trenger stramme rammer.
*   **Execution:** Binance Spot (Auto-Exec).
*   **Kapasitet:** 1 Strategi, 1 Portefølje.
*   **Sikkerhet:** Full risikomotor + "Hard Stop Nå" knapp.
*   **Krav:** 7 dagers obligatorisk "Signal-Only" (kjøleperiode) før første handel.

### Elite — $99/mnd (Scale & Diversify)
*   **Formål:** For viderekomne som vil spre risiko.
*   **Execution:** Binance Spot + Crypto.com (når V1.1 KPI-gate er bestått).
*   **Kapasitet:** Opptil 3 Porteføljer (f.eks. BTC-fokus + Top10-mix).
*   **Data:** Avansert KPI-dashboard (Slippage, Latency, Blocked Reasons).
*   **Rabatt:** Årlig betaling gir 2 måneder gratis (~16% rabatt).

---

## 2. Risikomotor (Core Logic)
Reglene under er hardkodet i "Grønn Profil" (Standard) og kan ikke overstyres av brukeren.

### Grenseverdier (Låst)
| Type | Trigger (Drawdown) | Konsekvens |
| :--- | :--- | :--- |
| **Soft Stop** | -2% (Dag) / -5% (Uke) | **Signal-Only:** Nye kjøp blokkeres. Eksisterende posisjoner håndteres (Exit only). |
| **Hard Stop** | -4% (Dag) / -8% (Uke) | **Kill-Switch:** Alle Klarpakke-posisjoner selges umiddelbart. |

*   **Eksponering:** Maks 2 åpne posisjoner totalt. Maks 1 posisjon per coin.
*   **Risk per Trade:** Hard cap på 0,25% av equity (stop-loss avstand).

### Kill-Switch ("Hard Stop Nå")
En fysisk, rød knapp i UI + automatisk trigger ved Hard Stop.
1.  **Block:** Konto settes umiddelbart til `Close-Only`.
2.  **Clean-up:** API sender `Cancel All Open Orders` (fjerner "støy" i ordreboken).
3.  **Safety Window:** 60 sekunders nedtelling i app (bruker kan avbryte).
4.  **Terminate:** Systemet sender `Market Sell` på alle posisjoner merket med `tag:Klarpakke`.
    *   *Note:* Rører aldri brukerens manuelle posisjoner utenfor Klarpakke-systemet.

---

## 3. Univers & Datakilder (Deterministisk)
For å sikre etterprøvbarhet (audit), er handelsuniverset låst per uke.

### Kilde & Filter
*   **API:** CoinMarketCap (`/cryptocurrency/listings/latest`).
*   **Filter-logikk (Kjøres søndag kl 23:59 UTC):**
    1.  Hent Top 50 etter Market Cap.
    2.  Fjern Stablecoins (USDT, USDC, FDUSD, etc.).
    3.  **Likviditetsfilter:** Fjern coins med < $50M volum siste 24t.
    4.  Behold Top 10 av gjenværende liste.
*   **Resultat:** Listen lagres som `Universe_Version_YYYY_WW` og fryses for hele neste uke.

### Whitelist per Børs
Før en trade legges, sjekker systemet:
`Er coin i Univers?` **AND** `Finnes paret på Børs?` **AND** `Støtter paret API-basert Stop-Loss?`
*   Hvis **NEI**: Signalet blokkeres og logges med årsakskode (f.eks. `BLOCKED_CAPABILITY`).

---

## 4. Børsstrategi & Execution

### V1: Binance (Spot)
*   **Status:** Primary Execution Venue.
*   **Krav:** Bruker må ha API-nøkkel med "Enable Spot & Margin Trading" (Ingen withdrawals).
*   **Cash Buffer:** USDC (Anbefalt) eller USDT (Tillatt med advarsel).

### V1.1: Crypto.com (Exchange)
*   **Fase 1:** Read-Only (Import av saldo) ved V1 lansering.
*   **Fase 2:** Execution aktiveres kun når interne KPI-er er møtt:
    *   Order Reject Rate < 1% (7 dager snitt).
    *   API Latency < 2 sekunder (P95).

---

## 5. Teknisk Arkitektur & Stack

*   **Frontend/Logic:** **Bubble.io**
    *   Håndterer bruker, Stripe-abonnement, risikoregler, dashboard og varsling.
*   **Execution Layer:** **Python / AWS Lambda**
    *   Mellomlag som kalles av Bubble for tunge operasjoner.
    *   Ansvar: Ordre-ruting, Kill-Switch sekvensering ("Cancel -> Sell -> Confirm").
*   **Database:**
    *   **Bubble DB:** Brukerdata, porteføljestatus.
    *   **Audit Log (PostgreSQL):** Uforanderlig logg av alle signaler og ordre for etterprøvbarhet.

---

## 6. Roadmap & Implementering

### Sprint 1: The Safety Rails (Uke 1-2)
*   [ ] **CMC Univers-motor:** Jobb som genererer ukens `Universe_Version`.
*   [ ] **Kill-Switch Logic:** Python-script for `Cancel All` + `Market Close`.
*   [ ] **Bubble DB:** Implementere "Grønn Profil" regler og grenseverdier.
*   [ ] **Stripe:** Oppsett av produkter (Gratis/Pro/Elite) og Webhooks.

### Sprint 2: UX & Execution (Uke 3-4)
*   [ ] **Binance Adapter:** Kobling for Pro-brukere (Spot API).
*   [ ] **Trafikklys-Dashboard:** UI som viser status (Normal / Soft Stop / Hard Stop).
*   [ ] **Onboarding:** Tvungen 7-dagers "Signal-Only" flyt.
*   [ ] **Rapportering:** PDF-generering av ukesrapport.

## 🚀 Setup Status

### ✅ Completed
- [x] Supabase `api` schema created
- [x] RLS policies configured
- [x] Make.com scenarios automated
- [x] API test scripts

### 🔄 In Progress
- [ ] AI Agent configuration
- [ ] End-to-end testing
- [ ] Webflow integration

### 📋 Next Steps
1. Configure Make.com AI Agent
2. Connect scenarios to agent
3. Test signal approval flow
