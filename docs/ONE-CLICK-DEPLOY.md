# Klarpakke One-Click Deploy Guide

**Deploy everything in one command.**

---

## Quick Start (60 seconds)

### 1. Set environment variables

```bash
export SUPABASE_PROJECT_ID=swfyuwkptusceiouqlks
export SUPABASE_ACCESS_TOKEN=your_token_here
export SUPABASE_ANON_KEY=your_anon_key
export WEBFLOW_API_TOKEN=your_webflow_token  # Optional
export WEBFLOW_SITE_ID=klarpakke-c65071       # Optional
```

**Or create `.env` file:**

```bash
SUPABASE_PROJECT_ID=swfyuwkptusceiouqlks
SUPABASE_ACCESS_TOKEN=sbp_xxx
SUPABASE_ANON_KEY=eyJxxx
WEBFLOW_API_TOKEN=xxx  # Optional
WEBFLOW_SITE_ID=klarpakke-c65071  # Optional
```

### 2. Run deploy

```bash
make deploy-all
```

**That's it!** 🎉

---

## What gets deployed

### Phase 1: Supabase Backend
- 6 Edge Functions deployed
- Secrets synced from `.env`
- Database schema ready

### Phase 2: Demo Data
- 5-10 paper trading signals created
- Test positions seeded
- Risk meter initialized

### Phase 3: Webflow UI
- Site-wide JavaScript injected
- App shell (dashboard, settings, pricing)
- Plan gating logic

### Phase 4: Calculator
- Compound interest calculator
- Ready to paste in `/kalkulator` page

### Phase 5: Verification
- Edge Functions health check
- Signal count verification
- Smoke tests passed

---

## Deployment Output

```
═══════════════════════════════════════════════════════════
  🚀 KLARPAKKE ONE-CLICK DEPLOY (v3.0)                    
═══════════════════════════════════════════════════════════

✓ Environment variables loaded

[1/5] Deploying Supabase Edge Functions...
  → Deploying generate-trading-signal...
  → Deploying approve-signal...
  → Deploying analyze-signal...
  → Deploying update-positions...
  → Deploying serve-js...
  → Deploying debug-env...
  → Setting secrets...
✓ Phase 1 complete: Backend deployed

[2/5] Seeding demo signals (paper trading)...
✓ Demo signals created

[3/5] Deploying Webflow UI...
  → Updating site-wide custom code...
  → Publishing to staging subdomain...
✓ Site published

[4/5] Deploying calculator...
  → Calculator code ready at: web/calculator.js
✓ Calculator script available

[5/5] Running smoke tests...
  → Testing Supabase Edge Function...
✓ Edge Functions responding
  → Checking demo signals...
    Found 8 pending signals

═══════════════════════════════════════════════════════════
  ✅ DEPLOYMENT COMPLETE!                                  
═══════════════════════════════════════════════════════════

🌐 Your app is live at:
   https://klarpakke-c65071.webflow.io/app/dashboard

📊 Supabase Dashboard:
   https://supabase.com/dashboard/project/swfyuwkptusceiouqlks

📋 Next steps:
   1. Test: Open dashboard and click 'Approve' on a signal
   2. Check: Verify calculator at /kalkulator
   3. Monitor: GitHub Actions for ongoing syncs

🔧 To redeploy:
   make deploy-all
```

---

## Manual Steps (if WEBFLOW_API_TOKEN not set)

If you don't have Webflow API token yet:

1. **Copy site JavaScript:**
   ```bash
   cat web/klarpakke-site.js | pbcopy
   ```

2. **Paste in Webflow:**
   - Go to: Webflow Designer → Project Settings → Custom Code
   - Scroll to: "Before </body>"
   - Paste code
   - Save & Publish

3. **Copy calculator JavaScript:**
   ```bash
   cat web/calculator.js | pbcopy
   ```

4. **Paste in `/kalkulator` page:**
   - Open page in Designer
   - Page Settings → Custom Code → Before </body>
   - Paste code
   - Save & Publish

---

## Troubleshooting

### "Missing required environment variables"

**Fix:** Set required vars:

```bash
export SUPABASE_PROJECT_ID=swfyuwkptusceiouqlks
export SUPABASE_ACCESS_TOKEN=your_token
```

### "Supabase CLI not installed"

**Fix:** Install Supabase CLI:

```bash
brew install supabase/tap/supabase
```

### "Edge Functions may not be ready yet"

**Why:** Functions can take 1-2 minutes to be fully available after deploy.

**Fix:** Wait 2 minutes and test manually:

```bash
curl https://swfyuwkptusceiouqlks.supabase.co/functions/v1/debug-env
```

### "Webflow API call may have failed"

**Fix:** Check token and site ID:

```bash
# Test token
curl https://api.webflow.com/v2/sites \
  -H "Authorization: Bearer $WEBFLOW_API_TOKEN"

# Should return list of your sites
```

---

## Environment Variables Reference

| Variable | Required | Description |
|----------|----------|-------------|
| `SUPABASE_PROJECT_ID` | ✅ Yes | Your Supabase project ID |
| `SUPABASE_ACCESS_TOKEN` | ✅ Yes | Supabase personal access token |
| `SUPABASE_ANON_KEY` | ⚠️ Recommended | Public anon key for frontend |
| `WEBFLOW_API_TOKEN` | ❌ Optional | Webflow API token (automates UI deploy) |
| `WEBFLOW_SITE_ID` | ❌ Optional | Webflow site ID (default: klarpakke-c65071) |
| `DATABASE_URL` | ❌ Optional | For psql smoke tests |

---

## What's NOT automated (yet)

1. **Webflow page structure:**
   - You must create pages (`/kalkulator`, `/app/pricing`, etc.) once in Designer
   - Add HTML elements with correct IDs (e.g., `calc-start`, `calc-crypto-percent`)

2. **Make.com scenarios:**
   - Blueprint files exist in `blueprints/`
   - Must be imported manually to Make.com (one-time)

3. **Custom domain:**
   - Script publishes to `*.webflow.io` subdomain
   - Custom domain (`klarpakke.no`) requires manual DNS setup

---

## Continuous Deployment (GitHub Actions)

Every push to `main` triggers:

1. **AI Healthcheck** (daily): Verifies Perplexity API
2. **Webflow Sync** (every 5 min): Syncs signals to CMS
3. **Auto-PR** (weekly): Creates maintenance PRs

See: `.github/workflows/`

---

## Advanced: Deploy from CI/CD

```yaml
# .github/workflows/deploy.yml
name: Deploy
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy everything
        env:
          SUPABASE_PROJECT_ID: ${{ secrets.SUPABASE_PROJECT_ID }}
          SUPABASE_ACCESS_TOKEN: ${{ secrets.SUPABASE_ACCESS_TOKEN }}
          WEBFLOW_API_TOKEN: ${{ secrets.WEBFLOW_API_TOKEN }}
        run: |
          make deploy-all
```

---

## Cost Estimate

| Service | Tier | Cost |
|---------|------|------|
| Supabase | Free | $0 |
| Webflow | Basic | $14/mo |
| Make.com | Core | $9/mo |
| TradingView | Essential | $14.95/mo |
| CoinGecko | Free | $0 |
| **Total** | | **~$38/mo** |

---

## Support

- **Docs:** [github.com/tombomann/klarpakke](https://github.com/tombomann/klarpakke)
- **Issues:** GitHub Issues
- **Logs:** `make edge-logs`

---

*Last updated: 27. januar 2026*
