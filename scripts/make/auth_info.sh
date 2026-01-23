#!/usr/bin/env bash
set -euo pipefail

mask_tail () {
  local s="${1:-}"
  local n="${#s}"
  if [ "$n" -le 4 ]; then
    echo "****"
  else
    echo "****${s: -4}"
  fi
}

echo "BASE=${BASE:-<unset>}"
echo "ORG_ID=${ORG_ID:-<unset>}"
echo "TEAM_ID=${TEAM_ID:-<unset>}"

if [ -z "${MAKE_TOKEN:-}" ]; then
  echo "MAKE_TOKEN=<unset>"
else
  echo "MAKE_TOKEN_LEN=${#MAKE_TOKEN}"
  echo "MAKE_TOKEN_TAIL=$(mask_tail "$MAKE_TOKEN")"
fi
