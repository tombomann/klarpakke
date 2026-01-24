# AI Operating Policy (Klarpakke)

Dette er prosjektets faste arbeidsregler for endringer i codebase/automation.

## Sikkerhets-gate (<85%)
Hvis jeg er <85% sikker: STOPP.
- Still 1–2 presise spørsmål (loggutdrag, exit code, OS, branch, secrets/permissions).
- Ikke foreslå endringer/PR før dette er avklart.

## Loggbarhet
Alle endringer skal være sporbare i git:
- Små commits.
- Tydelige commit-meldinger (imperativ).
- PR-er skal være små og fokusert (helst 1–3 filer).

## Feilhåndtering (når noe feiler)
1) Reproduser feilen mentalt:
- Hva kjørte vi?
- Hvilken exit code fikk vi?
- Hvilken fil/linje feiler?

2) Klassifiser feilen:
(a) Syntax
(b) Manglende tool (jq/curl/gh)
(c) Manglende env/secrets
(d) API 4xx/5xx
(e) Permissions i GitHub Actions
(f) Race/CI-only problem

3) Foreslå minste endring som løser problemet
- Legg alltid til/oppdater en smoke test som fanger regressjon.

## Leveransekrav for alle endringer
Alltid lever:
- HVA gjort
- HVORFOR
- TEST
+ konkrete kommandoer (copy/paste)

## AUTO‑PR policy (kun hvis >85% sikker)
Hvis jeg er >85% sikker på fixen:
- Implementer endringen som PR (Auto‑PR via GitHub Actions hvis konfigurert).
- PR skal være liten og fokusert (maks 1–3 filer hvis mulig).
- Inkluder/oppdater `scripts/smoke.sh` (eller tilsvarende) når relevant.

Hvis jeg er ≤85% sikker:
- IKKE lag PR.
- Still 1–2 presise spørsmål først.

## GitHub Actions / PR-krav (må verifiseres før Auto‑PR)
Før Auto‑PR må følgende være sant:
- Workflow har permissions: `contents: write` og `pull-requests: write`.
- Repo-innstilling tillater at GitHub Actions kan opprette/approvere PR
  (“Allow GitHub Actions to create and approve pull requests”).
