#!/usr/bin/env bash
set -euo pipefail

# Local helper to deploy the Webflow footer loader.
# Usage:
#   set -a; source .env; set +a
#   bash scripts/webflow-deploy-loader.sh

: "${WEBFLOW_API_TOKEN:?Missing WEBFLOW_API_TOKEN}"
: "${WEBFLOW_SITE_ID:?Missing WEBFLOW_SITE_ID}"
: "${KLARPAKKE_PUBLIC_CONFIG_URL:?Missing KLARPAKKE_PUBLIC_CONFIG_URL}"

command -v jq >/dev/null || { echo "❌ jq is required"; exit 1; }

bash scripts/webflow-set-footer-loader.sh
