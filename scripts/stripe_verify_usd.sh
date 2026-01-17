#!/usr/bin/env bash
set -euo pipefail
: "${STRIPE_SECRET:?STRIPE_SECRET is required}"
: "${AUTOPAKKE_PRICE_ID_USD:?AUTOPAKKE_PRICE_ID_USD is required}"

curl -sS https://api.stripe.com/v1/prices/${AUTOPAKKE_PRICE_ID_USD} \
  -u ${STRIPE_SECRET}: | jq -e '.currency=="usd" and .recurring.interval=="month"'
echo "Stripe USD price verified."
