# Klarpakke Design (v0)

Mål: En moderne, rolig og konsistent stil på tvers av alle sider (public + `/app/*`).

Kjerneprinsipp: **Opplæring før salg**.
Vi forklarer alltid “hvorfor” på menneskespråk og bruker trafikklys kun for risiko/status (ikke som dekor).

---

## 1) Tone of voice (copy)

**Regel 1: Skriv så enkelt at alle forstår.**
- Korte setninger (1 idé per setning).
- Unngå sjargong (forklar ord som “volatilitet”, “limit”, “spread”, “stop loss”).
- Bruk “du”-språk: “Dette betyr for deg…”, “Neste steg…”.

**Regel 2: Ikke “selg”, men veiled.**
- Unngå hype (“100x”, “garantert”, “gratis penger”).
- Bruk trygghet og rammer: “Du må godkjenne”, “systemet kan pause”.

**Regel 3: Trafikklys = risiko, alltid.**
- Grønn: “Alt ok”.
- Gul: “Vær obs / nærmer deg grensen”.
- Rød: “Stopper automatisk for å beskytte deg”.

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
- `--extreme`: `#111827`  /* Sort = “ekstra høy risiko” */

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
- Badge (status): `ok/warn/danger` + tekst.
- Info-box (opplæring): lys bakgrunn, ikon, 2–3 setninger.

---

## 5) Sider (IA v0)

**Public (opplæring)**
- `/opplaering`: “Start her”, krypto 101, ordliste, vanlige feil.
- `/ressurser`: artikler (sammenligning/review/guide) for SEO + forklaring.
- `/risiko`: trafikklys + regler (dagsgrense/ukesgrense/kill-switch) i plain language.

**App**
- `/app/dashboard`: status + trafikklys + forklaring.
- `/app/settings`: profil, risiko, varsler.
- `/app/pricing`: planvalg (kan være mer “valg/tilgang” enn “salg”).

---

## 6) Pricing (planer)

Målet er å være tydelig og pedagogisk.
Plan-kort skal alltid ha:
- Hvem den passer for.
- Hva som følger med.
- Trafikklys for risiko.
- “Krav før aktivering” (kun for EXTREM).

### Gratis (Paper)
- Risiko: Grønn (ingen ekte penger).
- Inkluderer: 1 paper-trading konto, grunnopplæring, demo-signaler.
- Begrensning: ingen live execution.

### SAFE — $49
- Risiko: Grønn.
- Inkluderer: live signals + manuell godkjenning, standard risikorammer, opplæring, historikk/logg.
- Budskap: “Designet for småsparere som vil lære og holde risiko lav.”

### PRO — $99
- Risiko: Gul (mer aktiv / flere strategier).
- Inkluderer: flere strategier/markeder, mer avanserte signaler og rapporter.
- Budskap: “For deg som forstår grunnprinsippene og vil ha mer fleksibilitet.”

### EXTREM — HØY RISIKO — $199 (krever opplæring)
- Risiko: Sort (ekstra høy risiko).
- Inkluderer: høyere frekvens/mer aggressive strategier og flere signaler.
- **Krav:** må fullføre opplæring og bestå en enkel quiz før aktivering.
- Budskap (kort): “Dette er for erfarne. Du kan tape penger raskt. Vi stopper nye handler hvis du når risikogrensen.”

---

## 7) DoD for “pene sider”

Når vi sier at designet er “på plass”, betyr det:
- Alle sider bruker samme tokens/komponenter.
- Trafikklys er konsistent og forklares med tekst.
- Ingen side har “rå” JS eller debug-tekst synlig.
- Opplæring er tilgjengelig fra alle `/app/*`-sider (lenke + infoboks).
