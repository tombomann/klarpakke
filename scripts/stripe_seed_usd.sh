#!/bin/bash
set -e
STRIPE_KEY="${STRIPE_SECRET_KEY}"
ENV="${ENVIRONMENT:-test}"
if [ -z "$STRIPE_KEY" ]; then
  echo "❌ ERROR: STRIPE_SECRET_KEY not set"
  exit 1
fi
echo "🚀 Seeding Stripe USD prices..."
> stripe_usd_prices.env
PRODUCT_PRO=$(curl -s "https://api.stripe.com/v1/products" -u "$STRIPE_KEY:" \
  -d "name=Klarpakke Pro" | jq -r '.id')
PRICE_PRO=$(curl -s "https://api.stripe.com/v1/prices" -u "$STRIPE_KEY:" \
  -d "product=$PRODUCT_PRO" -d "unit_amount=4900" -d "currency=usd" \
  -d "recurring[interval]=month" | jq -r '.id')
echo "STRIPE_PRICE_PRO_USD_49=$PRICE_PRO" >> stripe_usd_prices.env
echo "✅ Done! Prices: $PRICE_PRO"
