#!/usr/bin/env bash
set -euo pipefail

die(){ echo "FATAL: $*" >&2; exit 1; }

: "${ORG_ID:?ORG_ID not set}"
: "${TEAM_ID:?TEAM_ID not set}"
: "${BASE:?BASE not set}"
: "${MAKE_TOKEN:?MAKE_TOKEN not set}"

# Fail fast hvis token ser maskert/trunkert ut (Make-token vises kun fullt ved opprettelse). [web:584]
bash scripts/make/env_lint.sh

bash scripts/make/http_get.sh organizations organizations "pg%5Blimit%5D=50"
bash scripts/make/http_get.sh teams teams "organizationId=${ORG_ID}&pg%5Blimit%5D=50"
bash scripts/make/http_get.sh scenarios_by_team scenarios "teamId=${TEAM_ID}&pg%5Blimit%5D=50"
bash scripts/make/http_get.sh scenario_folders_list scenarios-folders "teamId=${TEAM_ID}&pg%5Blimit%5D=50"

echo "OK: diagnose-auth-v2 passed"
