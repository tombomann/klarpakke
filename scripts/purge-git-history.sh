#!/usr/bin/env bash
set -euo pipefail
trap 'echo "ERROR: purge failed" >&2' ERR

# Bruk: bash scripts/purge-git-history.sh --dry-run
#  - Kjør alltid på en fresh clone av repoet.
#  - Etterpå må du force-pushe til GitHub og gi beskjed til alle som har klonet.

DRY_RUN="${1:-}"
EXTRA_FLAGS=()
if [[ "${DRY_RUN}" == "--dry-run" ]]; then
  EXTRA_FLAGS=(--dry-run)
fi

if ! command -v git >/dev/null 2>&1; then
  echo "git mangler" >&2
  exit 1
fi

# git filter-repo kommer som et git-subkommando i nyere oppsett.
# Hvis denne feiler, må du installere git-filter-repo først.
# Se GitHub-dokumentasjonen om 'Removing sensitive data from a repository'.[1]
# [1] https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository

git filter-repo \
  --force \
  --invert-paths \
  --path '.env' \
  --path '.env.*' \
  --path 'node_modules/' \
  "${EXTRA_FLAGS[@]}"

echo "OK: filter-repo ferdig. Husk å verifisere og force-pushe manuelt."
