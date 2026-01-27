# AI Model Playbook - Klarpakke

Denne guiden definerer hvilken AI-modell som skal brukes til ulike oppgaver i prosjektet for å sikre optimal kvalitet, hastighet og kostnadseffektivitet.

## 🎯 Anbefalt Modellvalg

| Oppgavetype | Anbefalt Modell | Hvorfor? |
|-------------|-----------------|----------|
| **Arkitektur & Design** | **Sonar Reasoning Pro** | Krever dyp resonnering ("tenke seg om"), håndtering av komplekse avhengigheter og unngåelse av hallusinasjoner på kritiske valg. |
| **Koding & Refaktorering** | **Gemini 2.5 Pro / GPT-5.2** | Best på ren syntaks, boilerplate-generering, og store kodebaser. Høy token-grense for kontekst. |
| **Quick Docs & API-søk** | **Sonar (Pro Search)** | Optimalisert for sanntids websøk. Finner raskt riktige endpoints, parametere og oppdatert dokumentasjon. |
| **Kreativitet & UI/UX** | **Claude 3.7 Sonnet** | Sterk på nyanse, tone-of-voice, og visuelle beskrivelser (CSS/Tailwind/Webflow). |

## 🛠️ Konkret Bruk i Klarpakke

### 1. "Plan A" Automasjon (Webflow + Supabase)
- **Design-fasen:** Bruk **Sonar Reasoning Pro**.
  - *Prompt:* "Design en robust 'contract' mellom Supabase Edge Function og Webflow frontend som håndterer 401/429 feil og optimistisk UI-oppdatering."
- **Implementasjon:** Bruk **Gemini 2.5 Pro**.
  - *Prompt:* "Skriv `klarpakke-ui.js` basert på denne kontrakten. Inkluder feilhåndtering, loading states og ren DOM-manipulasjon."
- **Verifisering:** Bruk **Sonar**.
  - *Prompt:* "Hva er Webflow API v2 endpoint for å oppdatere custom code på en side? Sjekk begrensninger."

### 2. Trading Strategi & Analyse
- **Markedsanalyse:** **Sonar Reasoning Pro** (via API).
  - Brukes i produksjon for å generere faktiske signaler. Har tilgang til sanntidsdata og resonnerer rundt flere kilder.
- **Backtesting-kode:** **GPT-5.2**.
  - For å skrive Python-scripts som tester strategier mot historiske data.

### 3. Dokumentasjon & README
- **Skriving:** **Claude 3.7 Sonnet**.
  - For å gjøre teksten klar, pedagogisk og velstrukturert.
- **Faktasjekk:** **Sonar**.
  - For å verifisere at lenker og kommandoer er korrekte.

## ⚠️ Anti-Patterns (Hva du IKKE bør gjøre)

- **Ikke bruk "Standard" modeller (raske/billige) til arkitektur.** De glemmer ofte edge-cases (sikkerhet, feilhåndtering) som Reasoning-modellene fanger opp.
- **Ikke bruk Reasoning-modeller til enkle oppslag.** Det er bortkastet tid (de tenker for lenge) og tokens.
- **Ikke stol blindt på kode fra modeller uten websøk (gamle biblioteker).** Sjekk alltid mot nyeste docs med Sonar.

## 🔄 Vedlikehold

Denne playbooken oppdateres når nye modeller (f.eks. GPT-6, Sonar Ultra) blir tilgjengelige og testet i prosjektet.
