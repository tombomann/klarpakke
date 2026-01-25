# klarpakke.no Webflow CMS Setup

## Collections
1. **deployment_status**
   - ai_status (text): 🟢 Live
   - pricing_free (text): $0/month
   - pricing_pro (text): $49/month
   - pricing_elite (text): $99/month
   - last_deploy (date): now()
   - signals_today (number): 42

2. **ai_signals** 
   - pair (text): BTC/USD
   - direction (text): BUY
   - confidence (number): 85
   - pnl_pct (number): 2.3

## Dynamic Bindings
- Dashboard Hero: {deployment_status.ai_status}
- Pricing Table: {deployment_status.pricing_pro}
- Signals List: Collection list "ai_signals"
