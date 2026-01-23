#!/usr/bin/env bash
set -euo pipefail

die(){ echo "FATAL: $*" >&2; exit 1; }

: "${BASE:?BASE not set}"
: "${MAKE_TOKEN:?MAKE_TOKEN not set}"

need(){ command -v "$1" >/dev/null 2>&1 || die "Missing dependency: $1"; }
need curl
need jq
need date

mkdir -p logs

name="${1:?usage: http_get.sh <name> <path> [querystring]}"
path="${2:?usage: http_get.sh <name> <path> [querystring]}"
qs="${3:-}"

ts="$(date '+%Y%m%d-%H%M%S')"
out="logs/${ts}-${name}.json"
tmp="$(mktemp)"

url="${BASE%/}/${path#/}"
if [[ -n "$qs" ]]; then url="${url}?${qs}"; fi

# -g for bracket-safe URLs (pg%5B...%5D etc)
http_code="$(
  curl -g -sS \
    -H "Authorization: Token ${MAKE_TOKEN}" \
    -H "Content-Type: application/json" \
    -o "$tmp" \
    -w '%{http_code}' \
    "$url" || true
)"

# Fail fast if not JSON (Make returns JSON errors too; this catches HTML, proxies, etc.)
jq -e . >/dev/null 2>&1 < "$tmp" || {
  echo "ERROR: Non-JSON response from $url (HTTP $http_code)" >&2
  head -c 400 "$tmp" >&2 || true
  exit 1
}

mv "$tmp" "$out"

# Hard gate on HTTP status
if [[ "$http_code" -lt 200 || "$http_code" -gt 299 ]]; then
  echo "ERROR: HTTP $http_code for $url (saved $out)" >&2
  # print minimal error fields if present
  jq -r '(.message // .error // .errors // .) | tostring' "$out" 2>/dev/null || true
  exit 1
fi

echo "OK: $name HTTP $http_code Saved: $out"
