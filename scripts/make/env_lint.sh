#!/usr/bin/env bash
set -euo pipefail
die(){ echo "FATAL: $*" >&2; exit 1; }

: "${BASE:?BASE not set}"
: "${ORG_ID:?ORG_ID not set}"
: "${TEAM_ID:?TEAM_ID not set}"
: "${MAKE_TOKEN:?MAKE_TOKEN not set}"

if [[ "$MAKE_TOKEN" =~ [[:space:]] ]]; then
  die "MAKE_TOKEN inneholder whitespace (mellomrom/newline). Kopier/lim inn på nytt uten linjeskift."
fi

if [[ "$MAKE_TOKEN" == Token\ * || "$MAKE_TOKEN" == Bearer\ * ]]; then
  die "MAKE_TOKEN skal være rå tokenverdi uten 'Token ' eller 'Bearer ' prefix."
fi

# Make-dok: Authorization: Token <uuid> [page:0]
uuid_re='^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$'
if [[ ! "$MAKE_TOKEN" =~ $uuid_re ]]; then
  die "MAKE_TOKEN matcher ikke UUID-formatet Make dokumenterer. Dette skjer typisk når du har kopiert token fra lista etterpå (delvis skjult), ikke fra dialogen som vises ved opprettelse. [page:1]"
fi

echo "OK: env_lint passed (BASE=$BASE ORG_ID=$ORG_ID TEAM_ID=$TEAM_ID TOKEN_LEN=${#MAKE_TOKEN})"
