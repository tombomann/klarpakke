#!/bin/bash
set -euo pipefail

STRIPE_KEY="${STRIPE_SECRET_KEY}"

if [ -z "$STRIPE_KEY" ]; then
  echo "❌ ERROR: STRIPE_SECRET_KEY not set"
  exit 1
fi

echo "💳 Stripe seed (test mode)"

# Pro price
PRO_ID=$(curl -s "https://api.stripe.com/v1/prices" -u "$STRIPE_KEY:" -d "unit_amount=4900" -d "currency=usd" -d "recurring[interval]=month" | jq -r '.id')
echo "STRIPE_PRICE_PRO_USD49=$PRO_ID"

# Elite price
ELITE_ID=$(curl -s "https://api.stripe.com/v1/prices" -u "$STRIPE_KEY:" -d "unit_amount=9900" -d "currency=usd" -d "recurring[interval]=month" | jq -r '.id')
echo "STRIPE_PRICE_ELITE_USD99=$ELITE_ID"

echo "✅ Stripe seed complete"