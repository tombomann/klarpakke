#!/bin/bash
set -e

STRIPE_KEY="${STRIPE_SECRET_KEY:-demo_key}"
ENV="${ENVIRONMENT:-test}"

echo "💳 Stripe USD seeding ($ENV mode)..."
echo "STRIPE_PRODUCT_PRO=prod_demo_123" > stripe_usd_prices.env
echo "STRIPE_PRICE_PRO_USD=price_demo_49usd" >> stripe_usd_prices.env
echo "✅ Demo prices created (replace with real API call)"
