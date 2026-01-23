#!/usr/bin/env bash
set -euo pipefail

die(){ echo "FATAL: $*" >&2; exit 1; }

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "${ROOT:-}" ]] || die "Not inside git repo. cd /Users/taj/klarpakke først."
cd "$ROOT"

mkdir -p logs
out="logs/support-bundle-$(date '+%Y%m%d-%H%M%S').txt"

redact() {
  # Rediger åpenbare secrets hvis de dukker opp i output
  sed -E \
    -e 's/(MAKE_TOKEN=).*/\1REDACTED/g' \
    -e 's/(Authorization: Token )[A-Za-z0-9-]+/\1REDACTED/g'
}

{
  echo "=== CONTEXT ==="
  echo "pwd: $(pwd)"
  echo "git: $(git rev-parse --short HEAD 2>/dev/null || true)"
  echo "uname: $(uname -a 2>/dev/null || true)"
  echo "zsh: $(zsh --version 2>/dev/null || true)"
  echo "bash: $(bash --version 2>/dev/null | head -n1 || true)"
  echo "make: $(make --version 2>/dev/null | head -n1 || true)"
  echo

  echo "=== KP DOCTOR ==="
  bash scripts/kp.sh doctor 2>&1 | redact
  echo

  echo "=== MAKEFILE (numbered) ==="
  nl -ba Makefile 2>&1 | redact
  echo

  echo "=== MAKEFILE (show invisibles) ==="
  sed -n '1,120l' Makefile 2>&1 | redact
  echo

  echo "=== ENV FILES PRESENT? (no content) ==="
  ls -la .env .env.example 2>&1 | redact
  echo

  echo "=== MAKE -n env (dry-run) ==="
  make -n env 2>&1 | redact
  echo

  echo "=== MAKE -s env (actual printed lines) ==="
  make -s env 2>&1 | redact
  echo
} > "$out"

echo "✅ Wrote $out"
echo "TIP: Share its content (it is redacted)."
