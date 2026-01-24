#!/usr/bin/env bash
set -euo pipefail

fail(){ echo "SMOKE FAIL: $*" >&2; exit 1; }

echo "== smoke: repo hygiene =="

# Liste trackede filer
TRACKED="$(git ls-files -z | tr '\0' '\n')"

# Block: .env og .env.* (men tillat .env.example)
BAD_ENV="$(printf "%s\n" "$TRACKED" \
  | awk '$0 ~ /^\.env$/ {print}
         $0 ~ /^\.env\./ && $0 !~ /^\.env\.example$/ {print}')"

# Block: node_modules/
BAD_NODE="$(printf "%s\n" "$TRACKED" | awk '$0 ~ /^node_modules\// {print}')"

BAD="${BAD_ENV}
${BAD_NODE}"

BAD="$(printf "%s\n" "$BAD" | awk 'NF')"

if [[ -n "${BAD}" ]]; then
  echo "Disallowed tracked paths found:"
  echo "${BAD}"
  fail "Untrack these files (git rm --cached) and keep them ignored."
fi

for cmd in bash git; do
  command -v "$cmd" >/dev/null 2>&1 || fail "Missing tool: $cmd"
done

echo "SMOKE OK"
