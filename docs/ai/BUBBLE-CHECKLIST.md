# Bubble – USD og Perplexity
1) Kjør `make stripe-seed-usd` og kopier `price_*` fra stripe_usd_prices.env.
2) Endre Bubble Checkout/Subscribe til USD `price_*`.
3) API Connector (Perplexity): Use as Action + Private Authorization, mapping til `choices:first item's message:content`.
