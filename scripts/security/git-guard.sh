#!/usr/bin/env bash
set -euo pipefail

APPLY="${APPLY:-0}"

die(){ echo "FATAL: $*" >&2; exit 1; }
have(){ command -v "$1" >/dev/null 2>&1; }

have git || die "git missing"
have grep || die "grep missing"

echo "Mode: $([[ "$APPLY" == "1" ]] && echo APPLY || echo DRY-RUN)"

echo
echo "== Tracked sensitive files =="
git ls-files .env >/dev/null 2>&1 && echo "WARN: .env is tracked by git" || echo "OK: .env not tracked"
git ls-files logs >/dev/null 2>&1 && echo "WARN: logs/ is tracked by git" || echo "OK: logs/ not tracked"

echo
echo "== Suggested .gitignore entries =="
need=0
for entry in ".env" "logs/" "blueprints/" ; do
  if [[ -f .gitignore ]] && grep -qxF "$entry" .gitignore; then
    echo "OK: .gitignore already has $entry"
  else
    echo "ADD: $entry"
    need=1
  fi
done

if [[ "$APPLY" != "1" ]]; then
  echo
  echo "Dry-run only."
  echo "To write .gitignore updates: APPLY=1 bash scripts/security/git-guard.sh"
  exit 0
fi

touch .gitignore
for entry in ".env" "logs/" "blueprints/" ; do
  grep -qxF "$entry" .gitignore || echo "$entry" >> .gitignore
done

echo "✅ Updated .gitignore"
