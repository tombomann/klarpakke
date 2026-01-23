#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=1
while [[ $# -gt 0 ]]; do
  case "$1" in
    --apply) DRY_RUN=0; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    *) echo "ERROR: unknown arg: $1" >&2; exit 2 ;;
  esac
done

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "ERROR: Not inside a git repo. Run: cd ~/klarpakke" >&2
  exit 1
fi

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "DRY-RUN: would write docs/automation/DECISIONS.md"
  exit 0
fi

mkdir -p docs/automation

cat > docs/automation/DECISIONS.md << 'MD'
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
MD

test -s docs/automation/DECISIONS.md
echo "WROTE: docs/automation/DECISIONS.md"
