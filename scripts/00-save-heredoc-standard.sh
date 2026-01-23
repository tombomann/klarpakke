#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=1
DO_COMMIT=0
DO_PUSH=0
MSG="docs: add heredoc standard"

usage() {
  cat <<'USAGE'
Usage:
  bash scripts/00-save-heredoc-standard.sh [--apply] [--commit] [--push] [--message "msg"]

Defaults:
  --apply   writes files (otherwise dry-run)
  --commit  git commit
  --push    git push origin main (requires clean remote setup)
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --apply) DRY_RUN=0; shift ;;
    --commit) DO_COMMIT=1; shift ;;
    --push) DO_PUSH=1; shift ;;
    --message) MSG="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "ERROR: unknown arg: $1" >&2; usage; exit 2 ;;
  esac
done

require_repo() {
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "ERROR: Not inside a git repo. Run: cd ~/klarpakke (or clone repo first)." >&2
    exit 1
  fi
}

write_files() {
  mkdir -p docs/automation

  cat > docs/automation/HEREDOC-STANDARD.md << 'MD'
# Klarpakke heredoc-standard

Mål: færre «heredoc>»-heng, færre quoting-feil, og 100% etterprøvbar generering av filer.

## Standardregler
- Bruk alltid *quoted delimiter* for å unngå variabel-ekspansjon lokalt: `<< 'EOF'` eller `<<'EOF'`.
- Delimiter-linjen (EOF) skal stå helt alene uten innrykk.
- Bruk `<<-EOF` kun når du *bevisst* vil tillate innrykk med TAB (ikke spaces).
- Når du skriver til filer som krever sudo: bruk `sudo tee` i stedet for `>`.

## Godkjente mønstre (copy/paste)
### Skriv fil (ingen ekspansjon)
```bash
cat > path/to/file << 'EOF'
literal $DOLLAR and $(no_subst)
