#!/usr/bin/env bash
set -euo pipefail
: "${STRIPE_SECRET:?STRIPE_SECRET is required}"

starter_pid=$(curl -sS https://api.stripe.com/v1/products \
  -u ${STRIPE_SECRET}: \
  -d name="Klarpakke Starter" \
  -d statement_descriptor="Klarpakke Starter" | jq -r '.id')

starter_price=$(curl -sS https://api.stripe.com/v1/prices \
  -u ${STRIPE_SECRET}: \
  -d "currency=usd" \
  -d "unit_amount=0" \
  -d "recurring[interval]=month" \
  -d "product=${starter_pid}" | jq -r '.id')

auto_pid=$(curl -sS https://api.stripe.com/v1/products \
  -u ${STRIPE_SECRET}: \
  -d name="Klarpakke Autopakke" \
  -d statement_descriptor="Klarpakke Auto" | jq -r '.id')

auto_price=$(curl -sS https://api.stripe.com/v1/prices \
  -u ${STRIPE_SECRET}: \
  -d "currency=usd" \
  -d "unit_amount=4900" \
  -d "recurring[interval]=month" \
  -d "product=${auto_pid}" | jq -r '.id')

pro_pid=$(curl -sS https://api.stripe.com/v1/products \
  -u ${STRIPE_SECRET}: \
  -d name="Klarpakke Proffpakke" \
  -d statement_descriptor="Klarpakke Pro" | jq -r '.id')

pro_price=$(curl -sS https://api.stripe.com/v1/prices \
  -u ${STRIPE_SECRET}: \
  -d "currency=usd" \
  -d "unit_amount=9900" \
  -d "recurring[interval]=month" \
  -d "product=${pro_pid}" | jq -r '.id')

echo "STARTER_PRICE_ID_USD=${starter_price}"
echo "AUTOPAKKE_PRICE_ID_USD=${auto_price}"
echo "PROFFPAKKE_PRICE_ID_USD=${pro_price}"

cat > stripe_usd_prices.env <<EOF
STARTER_PRICE_ID_USD=${starter_price}
AUTOPAKKE_PRICE_ID_USD=${auto_price}
PROFFPAKKE_PRICE_ID_USD=${pro_price}
EOF

echo "Wrote stripe_usd_prices.env"
