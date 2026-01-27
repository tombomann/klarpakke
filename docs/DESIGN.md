# Klarpakke Design (v1)

Mål: En moderne, rolig og konsistent stil på tvers av alle sider (public + `/app/*`).

Kjerneprinsipp: **Opplæring før salg**.
Vi forklarer alltid "hvorfor" på menneskespråk og bruker trafikklys kun for risiko/status (ikke som dekor).

---

## 1) Tone of voice (copy)

**Regel 1: Skriv så enkelt at alle forstår.**
- Korte setninger (1 idé per setning).
- Unngå sjargong (forklar ord som "volatilitet", "limit", "spread", "stop loss").
- Bruk "du"-språk: "Dette betyr for deg…", "Neste steg…".

**Regel 2: Ikke "selg", men veiled.**
- Unngå hype ("100x", "garantert", "gratis penger").
- Bruk trygghet og rammer: "Du må godkjenne", "systemet kan pause".

**Regel 3: Positiv + pedagogisk.**
- Dashboard/kalkulator: vis vekst, muligheter, compound-effekt.
- Opplæring/quiz: én ærlig seksjon om risiko, deretter fokus på strategi.
- Advarsler: kun i opplæring og quiz (ikke repeterende).

**Regel 4: Trafikklys = risiko, alltid.**
- Grønn: "Alt ok".
- Gul: "Vær obs / nærmer deg grensen".
- Rød: "Pause til i morgen" (fakta, ikke dramatikk).
- Sort (EXTREM): "Pause. Trykk 'Start på nytt' i morgen".

---

## 2) Farger (tokens)

Hold paletten stram: nøytrale flater + én primærfarge + trafikklys for status.

**Neutrals**
- `--bg`: `#F8FAFC`
- `--surface`: `#FFFFFF`
- `--text`: `#111827`
- `--text-muted`: `#6B7280`
- `--border`: `#E5E7EB`

**Brand (primær)**
- `--primary`: `#2563EB`
- `--primary-hover`: `#1D4ED8`

**Status (trafikklys)**
- `--ok`: `#4CAF50`
- `--warn`: `#FFC107`
- `--danger`: `#F44336`
- `--extreme`: `#111827`  /* Sort = "ekstra høy risiko" */

Tilgjengelighet:
- Bruk aldri farge alene; legg alltid på label/ikon ("Grønn", "Gul", "Rød", "Sort" + forklaring).
- Sjekk kontrast før vi låser endelig palett.

---

## 3) Typografi

Mål: Lesbar opplæring.
- Base font-size: 16–18px.
- Line-height: 1.5–1.7.
- Overskrifter med tydelig hierarki (H1/H2/H3).

---

## 4) UI-komponenter (minimum)

Disse skal gjenbrukes overalt:
- Container: max-width 1100–1200px, auto margins.
- Card: hvit bakgrunn, radius 12px, border `--border`, svak skygge.
- Button:
  - Primary: `--primary`.
  - Secondary: outline.
  - Danger: `--danger` (kun når det faktisk er risikohandling).
- Badge (status): `ok/warn/danger/extreme` + tekst.
- Info-box (opplæring): lys bakgrunn, ikon, 2–3 setninger.

---

## 5) Sider (IA v1)

**Public (opplæring)**
- `/opplaering`: "Start her", krypto 101, ordliste, vanlige feil.
- `/ressurser`: artikler (sammenligning/review/guide) for SEO + forklaring.
- `/risiko`: trafikklys + regler (dagsgrense/ukesgrense/kill-switch) i plain language.
- `/kalkulator`: compound interest calculator med positiv framing.

**App**
- `/app/dashboard`: status + trafikklys + forklaring (positiv tone).
- `/app/settings`: profil, risiko, varsler, compound ON/OFF.
- `/app/pricing`: planvalg (kan være mer "valg/tilgang" enn "salg").

---

## 6) Pricing (planer)

Målet er å være tydelig og pedagogisk.
Plan-kort skal alltid ha:
- Hvem den passer for.
- Hva som følger med.
- Trafikklys for risiko.
- "Krav før aktivering" (kun for EXTREM).

### Gratis (Paper) — $0
- Risiko: Grønn (ingen ekte penger).
- Inkluderer: 1 paper-trading konto, grunnopplæring, demo-signaler.
- Begrensning: ingen live execution.
- Budskap: "Lær uten risiko. Perfekt start."

### SAFE — $49
- Risiko: Grønn.
- Inkluderer: live signals + manuell godkjenning, standard risikorammer, opplæring, historikk/logg.
- Budskap: "Rolig tempo. Perfekt for læring."
- Risiko-parametere: 1% per trade, maks 3 posisjoner, 5% daglig limit.

### PRO — $99
- Risiko: Gul (mer aktiv / flere strategier).
- Inkluderer: flere strategier/markeder, mer avanserte signaler og rapporter.
- Budskap: "Mer strategi, mer vekst."
- Risiko-parametere: 2% per trade, maks 5 posisjoner, 10% daglig limit.

### EXTREM — HØY RISIKO — $199 (krever opplæring)
- Risiko: Sort (ekstra høy risiko).
- Inkluderer: høyere frekvens/mer aggressive strategier og flere signaler.
- **Krav:** må fullføre opplæring og bestå en enkel quiz før aktivering.
- Budskap (positiv): "Høy frekvens. For erfarne. Du får full kontroll. Systemet beskytter deg med automatiske grenser."
- Risiko-parametere: 5% per trade, maks 10 posisjoner, 15% daglig limit (hard stop, manuell restart).

---

## 7) Compound Interest (kritisk funksjon)

**Alle planer har compounding ON som default.**
- Posisjonsstørrelse = % av *current balance* (ikke startkapital).
- Brukeren kan slå av compound i `/app/settings`.

**Microcopy (positiv):**
- "Med compounding vokser trades når du tjener. Dette akselererer vekst."
- Dashboard-widget: "Dine trades er nå større fordi kontoen har vokst. Det er compound-effekten."

---

## 8) DoD for "pene sider"

Når vi sier at designet er "på plass", betyr det:
- Alle sider bruker samme tokens/komponenter.
- Trafikklys er konsistent og forklares med tekst.
- Ingen side har "rå" JS eller debug-tekst synlig.
- Opplæring er tilgjengelig fra alle `/app/*`-sider (lenke + infoboks).
- Kalkulator viser compound-effekt (side-by-side flat vs compound).
- Positiv tone overalt (dashboard, kalkulator, plan-kort).
