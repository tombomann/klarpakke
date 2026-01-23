#!/usr/bin/env bash
set -euo pipefail
die(){ echo "FATAL: $*" >&2; exit 1; }

command -v pbpaste >/dev/null 2>&1 || die "pbpaste finnes ikke (macOS-only)."

t="$(pbpaste | tr -d '\r\n')"
echo "CLIP_LEN=${#t}"

uuid_re='^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$'
if [[ "$t" =~ $uuid_re ]]; then
  echo "CLIP_MATCH=UUID_OK"
else
  echo "CLIP_MATCH=NO (forventer UUID slik Make viser i docs)"
fi
