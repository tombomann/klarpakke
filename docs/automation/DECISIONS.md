# Klarpakke – Decisions (2026-01-23)

## Git workflow (default)
- Default arbeidsflyt: branch + PR (ikke direkte push til main).
- Begrunnelse: tryggere review, enklere rollback, mindre risiko ved automatisering.

## Source of truth
- `blocks/mobile/` er source-of-truth og committes til GitHub.
- Ingen “terminal-generering” som eneste kopi (reduserer drift og heredoc-heng).

## Dev baseline
- macOS (Apple Silicon M1) er baseline for lokale scripts.
- Scripts skal være portable til Linux CI, men må ikke bruke GNU-only flags uten fallback.

## Heredoc-standard
- Bruk quoted delimiter: `<< 'EOF'` for å unngå lokal ekspansjon/substitution.
- EOF-linjen må stå alene uten whitespace.

## Curl Standard (permanent)
- source scripts/curl-safe.bash i alle scripts
- USERS=$(curl_safe URL -H ...)
