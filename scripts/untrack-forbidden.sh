#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=0
if [[ "${1:-}" == "--dry-run" ]]; then DRY_RUN=1; fi

say(){ echo "== $*"; }

tracked="$(git ls-files -z | tr '\0' '\n')"

bad_env="$(printf "%s\n" "$tracked" \
  | awk '$0 ~ /^\.env$/ {print}
         $0 ~ /^\.env\./ && $0 !~ /^\.env\.example$/ {print}')"

bad_node="$(printf "%s\n" "$tracked" | awk '$0 ~ /^node_modules\// {print}')"

bad="$(printf "%s\n%s\n" "$bad_env" "$bad_node" | awk 'NF')"

if [[ -z "$bad" ]]; then
  say "No forbidden tracked paths found."
  exit 0
fi

say "Forbidden tracked paths:"
echo "$bad"

if [[ "$DRY_RUN" -eq 1 ]]; then
  say "Dry-run: not changing git index."
  exit 0
fi

# Untrack (beholder lokale filer)
# node_modules må fjernes med -r
if [[ -n "$bad_node" ]]; then
  git rm -r --cached --force node_modules
fi

# env-filer: fjern enkeltvis (kan være flere)
if [[ -n "$bad_env" ]]; then
  while IFS= read -r p; do
    [[ -z "$p" ]] && continue
    git rm --cached --force "$p"
  done <<< "$bad_env"
fi

say "Done. Now commit and push."
