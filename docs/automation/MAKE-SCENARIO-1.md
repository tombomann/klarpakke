# Make Scenario 1: Stripe → Hookdeck → Bubble Signal

## Flow
1. Stripe webhook (payment_intent.succeeded)
2. Hookdeck relay → Make HTTP listener
3. Make: Parse → Risk gate → Bubble API signal
4. Bubble: Display signal in UI

## Setup
- Hookdeck: Source → Make destination
- Make: New scenario, Webhook trigger
- Test: Stripe CLI test event
