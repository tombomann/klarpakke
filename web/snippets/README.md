# Webflow Custom Code Snippets

This folder contains generated Webflow Custom Code snippets with correct runtime configuration.

## Quick Start

### Generate Webflow Code (Staging)

```bash
cd ~/klarpakke
npm run gen:webflow-staging
```

**Output:** Code is automatically copied to clipboard!

### Generate Webflow Code (Production)

```bash
npm run gen:webflow-production
```

## Setup in Webflow

1. **Open Webflow Project Settings:**
   - Go to: https://webflow.com/dashboard/sites/klarpakke-c65071/settings/custom-code
   - Or: Open Designer → Click ⚙️ (top left) → Custom Code

2. **Paste in Footer Code:**
   - Scroll to "Footer Code (Before </body>)"
   - Paste the generated code (Cmd+V)
   - Click **Save Changes**

3. **Publish:**
   - Click **Publish** (top right)
   - Select domain (staging or production)
   - Click **Publish to selected domains**

## What Gets Generated

```html
<script>
  window.KLARPAKKE_CONFIG = {
    supabaseUrl: "https://YOUR_PROJECT_REF.supabase.co",
    supabaseAnonKey: "eyJ...",
    debug: true  // false for production
  };
</script>
<script src="https://cdn.jsdelivr.net/gh/tombomann/klarpakke@main/web/klarpakke-site.js"></script>
```

## Environment-Specific Settings

| Environment | Domain | Debug Mode | Source |
|-------------|--------|------------|--------|
| **Staging** | klarpakke-c65071.webflow.io | `true` | `.env` |
| **Production** | klarpakke.no | `false` | `.env` |

## Troubleshooting

### "Missing SUPABASE_URL"

```bash
# Make sure .env exists:
cp .env.example .env

# Fill in values from Supabase Dashboard:
# https://supabase.com/dashboard/project/_/settings/api
```

### CDN Not Loading

**Check URL format:**
```
✅ Correct: https://cdn.jsdelivr.net/gh/tombomann/klarpakke@main/web/klarpakke-site.js
❌ Wrong:   https://cdn.jsdelivr.net/gh/tombomann/klarpakke@main/web/dist/klarpakke-site.js
```

**Purge CDN cache:**
https://www.jsdelivr.com/tools/purge

### Script Shows as Text on Page

**Problem:** Missing `<script>` tags  
**Solution:** Use the generated snippet (already includes tags)

## Files

- `webflow-footer-loader-staging.html` - Generated staging config
- `webflow-footer-loader-production.html` - Generated production config
- `webflow-footer-loader.html` - Template (manual use)

## Notes

- ⚠️ **Never commit** `.env` with real credentials
- ✅ **Always use** `SUPABASE_ANON_KEY` (public, safe for frontend)
- ❌ **Never use** `SUPABASE_SECRET_KEY` in Webflow (server-only)
- 🔄 Re-generate after changing Supabase credentials
