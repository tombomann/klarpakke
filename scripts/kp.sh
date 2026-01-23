#!/usr/bin/env bash
set -euo pipefail
die(){ echo "FATAL: $*" >&2; exit 1; }

root() {
  if git rev-parse --show-toplevel >/dev/null 2>&1; then
    git rev-parse --show-toplevel
  else
    # fallback til avtalt path (1)
    echo "/Users/taj/klarpakke"
  fi
}

doctor() {
  local r; r="$(root)"
  test -d "$r" || die "Repo root not found at $r"
  cd "$r"

  test -f "scripts/make/env.sh" || die "Missing: scripts/make/env.sh (cd repo root?)"
  test -f ".env.example" || die "Missing: .env.example in repo root"
  test -f ".gitignore" || die "Missing: .gitignore"

  # .env må finnes lokalt for runtime, men ikke trackes
  test -f ".env" || die ".env missing. Create it: cp .env.example .env"

  if git ls-files --error-unmatch ".env" >/dev/null 2>&1; then
    die ".env is tracked. Fix: git rm --cached .env"
  fi
  if git ls-files --error-unmatch "logs" >/dev/null 2>&1; then
    die "logs/ is tracked. Fix: git rm --cached -r logs"
  fi

  echo "OK: doctor passed"
}

case "${1:-doctor}" in
  root) root ;;
  doctor) doctor ;;
  *) die "Usage: $0 {root|doctor}" ;;
esac
